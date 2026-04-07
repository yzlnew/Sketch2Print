# OpenSCAD 常见坑与避坑指南

生成 .scad 代码时容易踩的坑，基于实际迭代经验总结。

## 1. BOSL2 `orient` 参数导致空白渲染

**现象：** 使用 `cyl(..., orient=BACK)` 等 orient 参数时，渲染输出完全空白。

**原因：** `orient` 会改变对象的朝向轴，与 `translate`/`rotate` 组合时容易导致几何体跑到视野外或产生无效几何。

**正确做法：** 用标准 `rotate([90,0,0])` 代替 `orient`，行为更可预测：
```openscad
// ❌ 容易出问题
translate([0, 5, 50])
    cyl(h=12, d=60, anchor=BOTTOM, orient=BACK);

// ✅ 可预测
translate([0, 5, 50])
    rotate([90, 0, 0])
        cylinder(h=12, d=60, center=true);
```

**建议：** BOSL2 的 `orient` 适合在 Attachments 系统内部使用（`attach()`、`position()`）。独立放置时优先用 `rotate()`。

## 2. `hull()` 连接不同形状产生意外锥体

**现象：** 用 `hull()` 连接顶部圆柱和底部长方体，期望得到平板过渡，实际得到漏斗/锥体形状。

**原因：** `hull()` 计算的是所有子几何体顶点的凸包。圆柱的圆形截面和长方体的矩形截面凸包会产生渐变过渡。

**正确做法：** 需要平整连接时，直接用单一 `cube()` 作为背板，不要用 hull 在异形之间过渡：
```openscad
// ❌ 产生锥体
hull() {
    translate([0,0,80]) cylinder(r=30, h=3);
    cube([35, 3, 50], center=true);
}

// ✅ 统一背板 + 分别附加结构
cube([65, 3, 110]);  // 背板
// 在背板前面附加传感器环和充电器盒
```

## 3. 首版设计不要过度使用 BOSL2

**现象：** 首版代码大量使用 BOSL2 的 `cuboid`、`cyl`、`diff()`、`attach()`、`tag("remove")` 等高级功能，调试困难——一旦渲染异常，难以定位是哪个 BOSL2 特性的问题。

**正确做法：**
- **首版（001）用原生 OpenSCAD**：`cube()`、`cylinder()`、`difference()`、`union()`、`translate()`、`rotate()`
- **后续迭代逐步引入 BOSL2**：先确认基本形状正确，再用 BOSL2 加圆角、倒角等细节
- BOSL2 最适合的场景：`cuboid` 的 `rounding`/`chamfer`、`tube()`、`path_sweep()` 等原生 OpenSCAD 实现复杂的功能

```openscad
// 首版：原生 OpenSCAD，确保形状正确
difference() {
    cube([40, 20, 10], center=true);
    cylinder(h=11, d=6, center=true);
}

// 后续版本：引入 BOSL2 加细节
diff()
cuboid([40,20,10], rounding=2, edges="Z") {
    tag("remove") cyl(h=11, d=6);
}
```

## 4. 渲染验证要多角度查看

**现象：** 默认渲染角度可能正好看到背板正面，看不到前方的关键结构（环形夹、口袋等）。

**正确做法：** 首次渲染后，如果结构被遮挡，用 `--camera` 参数换角度确认：
```bash
# 默认角度
render-scad.sh model.scad --output model.png

# 前方 45° 俯视
render-scad.sh model.scad --output model_front.png --camera 60,60,50,0,8,45,220
```

## 5. `difference()` 中的 z-fighting

**现象：** 布尔减法后表面闪烁或残留薄片。

**正确做法：** 被减去的形状要比被减的主体多出 0.01-0.1mm：
```openscad
difference() {
    cube([30, 30, 10]);
    // ❌ 恰好齐平
    translate([5, 5, 0]) cube([20, 20, 10]);
    // ✅ 多出 0.01
    translate([5, 5, -0.01]) cube([20, 20, 10.02]);
}
```
