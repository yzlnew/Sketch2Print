#!/usr/bin/env python3

import argparse
import copy
import os
import posixpath
import uuid
import zipfile
import xml.etree.ElementTree as ET


CORE_NS = "http://schemas.microsoft.com/3dmanufacturing/core/2015/02"
REL_NS = "http://schemas.openxmlformats.org/package/2006/relationships"
CT_NS = "http://schemas.openxmlformats.org/package/2006/content-types"
PROD_NS = "http://schemas.microsoft.com/3dmanufacturing/production/2015/06"

ET.register_namespace("", CORE_NS)
ET.register_namespace("p", PROD_NS)


def qn(ns: str, tag: str) -> str:
    return f"{{{ns}}}{tag}"


def load_package(path: str):
    with zipfile.ZipFile(path) as zf:
        model_xml = zf.read("3D/3dmodel.model")
        root = ET.fromstring(model_xml)
        extra_files = {}
        for name in zf.namelist():
            if name in {"3D/3dmodel.model", "[Content_Types].xml", "_rels/.rels"}:
                continue
            extra_files[name] = zf.read(name)
        return root, extra_files


def iter_base_materials(root):
    resources = root.find(qn(CORE_NS, "resources"))
    if resources is None:
        return []
    return resources.findall(qn(CORE_NS, "basematerials"))


def build_material_map(roots):
    merged = []
    merged_index = {}
    root_maps = []

    for root in roots:
        local_lookup = {}
        for basematerials in iter_base_materials(root):
            local_id = basematerials.attrib.get("id")
            bases = basematerials.findall(qn(CORE_NS, "base"))
            for idx, base in enumerate(bases):
                key = (
                    base.attrib.get("name", ""),
                    base.attrib.get("displaycolor", ""),
                    base.attrib.get("displaypropertiesid", ""),
                )
                if key not in merged_index:
                    merged_index[key] = len(merged)
                    merged.append(copy.deepcopy(base))
                local_lookup[(local_id, str(idx))] = merged_index[key]
        root_maps.append(local_lookup)

    return merged, root_maps


def compute_bbox(obj):
    mesh = obj.find(qn(CORE_NS, "mesh"))
    if mesh is None:
        return (0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
    vertices = mesh.find(qn(CORE_NS, "vertices"))
    if vertices is None:
        return (0.0, 0.0, 0.0, 0.0, 0.0, 0.0)

    xs = []
    ys = []
    zs = []
    for vertex in vertices.findall(qn(CORE_NS, "vertex")):
        xs.append(float(vertex.attrib["x"]))
        ys.append(float(vertex.attrib["y"]))
        zs.append(float(vertex.attrib["z"]))

    if not xs:
        return (0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
    return (min(xs), max(xs), min(ys), max(ys), min(zs), max(zs))


def make_transform(tx, ty, tz):
    return f"1 0 0 0 1 0 0 0 1 {tx:.6f} {ty:.6f} {tz:.6f}"


def main():
    parser = argparse.ArgumentParser(description="Merge single-object 3MF files into one multi-object 3MF.")
    parser.add_argument("inputs", nargs="+", help="Input 3MF files to merge")
    parser.add_argument("-o", "--output", required=True, help="Output 3MF path")
    parser.add_argument("--gap", type=float, default=6.0, help="Gap between laid-out parts in mm")
    args = parser.parse_args()

    roots = []
    extras = []
    for path in args.inputs:
        root, extra_files = load_package(path)
        roots.append(root)
        extras.append(extra_files)

    merged_bases, root_material_maps = build_material_map(roots)

    first_root = roots[0]
    merged_root = ET.Element(first_root.tag, first_root.attrib)

    for child in list(first_root):
        if child.tag not in {qn(CORE_NS, "resources"), qn(CORE_NS, "build")}:
            merged_root.append(copy.deepcopy(child))

    resources = ET.SubElement(merged_root, qn(CORE_NS, "resources"))
    if merged_bases:
        merged_base_node = ET.SubElement(resources, qn(CORE_NS, "basematerials"), {"id": "1"})
        for base in merged_bases:
            merged_base_node.append(base)

    build = ET.SubElement(merged_root, qn(CORE_NS, "build"))

    next_object_id = 2
    cursor_x = 0.0
    copied_extra = {}

    for idx, root in enumerate(roots):
        source_resources = root.find(qn(CORE_NS, "resources"))
        if source_resources is None:
            continue

        for object_node in source_resources.findall(qn(CORE_NS, "object")):
            new_object = copy.deepcopy(object_node)
            new_object.attrib["id"] = str(next_object_id)
            new_object.attrib[f"{{{PROD_NS}}}UUID"] = str(uuid.uuid4())

            old_pid = new_object.attrib.get("pid")
            old_pindex = new_object.attrib.get("pindex")
            if old_pid is not None and old_pindex is not None:
                mapped = root_material_maps[idx].get((old_pid, old_pindex))
                if mapped is not None:
                    new_object.attrib["pid"] = "1"
                    new_object.attrib["pindex"] = str(mapped)
                else:
                    new_object.attrib.pop("pid", None)
                    new_object.attrib.pop("pindex", None)

            resources.append(new_object)

            min_x, max_x, min_y, _max_y, min_z, _max_z = compute_bbox(new_object)
            tx = cursor_x - min_x
            ty = -min_y
            tz = -min_z
            ET.SubElement(
                build,
                qn(CORE_NS, "item"),
                {
                    "objectid": str(next_object_id),
                    "transform": make_transform(tx, ty, tz),
                    f"{{{PROD_NS}}}UUID": str(uuid.uuid4()),
                },
            )
            cursor_x += (max_x - min_x) + args.gap
            next_object_id += 1

        for name, data in extras[idx].items():
            target_name = name
            while target_name in copied_extra:
                dirname, basename = posixpath.split(target_name)
                target_name = posixpath.join(dirname, f"{uuid.uuid4().hex}_{basename}")
            copied_extra[target_name] = data

    model_bytes = ET.tostring(merged_root, encoding="utf-8", xml_declaration=True)
    content_types = b"""<?xml version="1.0" encoding="utf-8"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
\t<Default Extension="jpeg" ContentType="image/jpeg"/>
\t<Default Extension="jpg" ContentType="image/jpeg"/>
\t<Default Extension="model" ContentType="application/vnd.ms-package.3dmanufacturing-3dmodel+xml"/>
\t<Default Extension="png" ContentType="image/png"/>
\t<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
\t<Default Extension="texture" ContentType="application/vnd.ms-package.3dmanufacturing-3dmodeltexture"/>
</Types>
"""
    rels = b"""<?xml version="1.0" encoding="utf-8"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
\t<Relationship Type="http://schemas.microsoft.com/3dmanufacturing/2013/01/3dmodel" Target="/3D/3dmodel.model" Id="rel0"/>
</Relationships>
"""

    os.makedirs(os.path.dirname(os.path.abspath(args.output)), exist_ok=True)
    with zipfile.ZipFile(args.output, "w", compression=zipfile.ZIP_DEFLATED) as zf:
        zf.writestr("3D/3dmodel.model", model_bytes)
        zf.writestr("[Content_Types].xml", content_types)
        zf.writestr("_rels/.rels", rels)
        for name, data in copied_extra.items():
            zf.writestr(name, data)


if __name__ == "__main__":
    main()
