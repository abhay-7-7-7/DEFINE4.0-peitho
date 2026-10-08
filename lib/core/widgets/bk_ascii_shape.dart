// lib/core/widgets/bk_ascii_shape.dart
// BoldKit ASCII Shape - animated ASCII art rendered via RichText/TextSpan.
// Supports 17 shape types, 4 charsets, 4 sizes, 3 speeds, multicolor & single-color modes.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../theme/bk_tokens.dart';

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

enum BkAsciiShapeType {
  torus,
  donut,
  sphere,
  cube,
  helix,
  trefoilKnot,
  geodesicDome,
  saturn,
  hyperboloid,
  dna,
  spiral,
  rose,
  wave,
  vortex,
  pulse,
  matrix,
  grid,
}

enum BkAsciiSize {
  sm, // 24 cols x 12 rows
  md, // 48 cols x 24 rows
  lg, // 72 cols x 36 rows
  hero, // 120 cols x 60 rows
}

enum BkAsciiCharset {
  blocks,
  braille,
  classic,
  line,
  dots,
}

enum BkAsciiSpeed {
  slow,
  normal,
  fast,
}

// ---------------------------------------------------------------------------
// Extensions
// ---------------------------------------------------------------------------

extension _BkAsciiSizeExt on BkAsciiSize {
  int get cols {
    switch (this) {
      case BkAsciiSize.sm:
        return 24;
      case BkAsciiSize.md:
        return 48;
      case BkAsciiSize.lg:
        return 72;
      case BkAsciiSize.hero:
        return 120;
    }
  }

  int get rows {
    switch (this) {
      case BkAsciiSize.sm:
        return 12;
      case BkAsciiSize.md:
        return 24;
      case BkAsciiSize.lg:
        return 36;
      case BkAsciiSize.hero:
        return 60;
    }
  }
}

extension _BkAsciiSpeedExt on BkAsciiSpeed {
  double get multiplier {
    switch (this) {
      case BkAsciiSpeed.slow:
        return 0.4;
      case BkAsciiSpeed.normal:
        return 1.0;
      case BkAsciiSpeed.fast:
        return 2.2;
    }
  }
}

List<String> _charsetChars(BkAsciiCharset charset) {
  switch (charset) {
    case BkAsciiCharset.blocks:
      return const [' ', '\u2591', '\u2592', '\u2593', '\u2588'];
    case BkAsciiCharset.braille:
      return const [
        ' ',
        '\u2801',
        '\u2803',
        '\u2807',
        '\u280f',
        '\u281f',
        '\u283f',
        '\u287f',
        '\u28ff'
      ];
    case BkAsciiCharset.classic:
      return const ['.', ':', 'o', '*', '#', '@'];
    case BkAsciiCharset.line:
      return const [' ', '-', '+', '/', '|', r'\', 'X', '#'];
    case BkAsciiCharset.dots:
      return const [
        ' ',
        '\u00b7',
        '\u2218',
        '\u2022',
        '\u25cf',
        '\u25c9',
        '\u25ce',
        '\u25cb'
      ];
  }
}

List<Color> _multicolorPalette(BuildContext context) {
  final t = BkTokens.of(context);
  return [
    t.primary,
    t.secondary,
    t.accent,
    t.warning,
    t.info,
    t.success,
    t.primary.withValues(alpha: 0.7),
    t.secondary.withValues(alpha: 0.7),
  ];
}

// ---------------------------------------------------------------------------
// ASCII Grid Computer
// ---------------------------------------------------------------------------

class _AsciiGrid {
  _AsciiGrid({
    required this.cols,
    required this.rows,
    required this.chars,
    required this.t,
    required this.shapeType,
    this.matrixHeads,
    this.matrixChars,
  });

  final int cols;
  final int rows;
  final List<String> chars;
  final double t;
  final BkAsciiShapeType shapeType;
  final List<int>? matrixHeads;
  final List<List<int>>? matrixChars;

  List<int> compute() {
    switch (shapeType) {
      case BkAsciiShapeType.spiral:
        return _spiral();
      case BkAsciiShapeType.wave:
        return _wave();
      case BkAsciiShapeType.sphere:
        return _sphere();
      case BkAsciiShapeType.torus:
        return _torus();
      case BkAsciiShapeType.donut:
        return _torus();
      case BkAsciiShapeType.helix:
        return _helix();
      case BkAsciiShapeType.cube:
        return _cube();
      case BkAsciiShapeType.matrix:
        return _matrix();
      case BkAsciiShapeType.rose:
        return _rose();
      case BkAsciiShapeType.vortex:
        return _vortex();
      case BkAsciiShapeType.pulse:
        return _pulse();
      case BkAsciiShapeType.dna:
        return _dna();
      case BkAsciiShapeType.trefoilKnot:
        return _trefoilKnot();
      case BkAsciiShapeType.geodesicDome:
        return _geodesicDome();
      case BkAsciiShapeType.saturn:
        return _saturn();
      case BkAsciiShapeType.hyperboloid:
        return _hyperboloid();
      case BkAsciiShapeType.grid:
        return _grid();
    }
  }

  int _ci(double val) => (val.clamp(0.0, 1.0) * (chars.length - 1)).round();

  List<int> _spiral() {
    final cx = cols / 2.0;
    final cy = rows / 2.0;
    final result = <int>[];
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final dx = (c - cx) * 2.0;
        final dy = (r - cy).toDouble();
        final dist = math.sqrt(dx * dx + dy * dy);
        final angle = math.atan2(dy, dx);
        final val = (math.sin(dist * 0.5 - t * 4.0 + angle * 2.0) + 1) * 0.5;
        result.add(_ci(val));
      }
    }
    return result;
  }

  List<int> _wave() {
    final result = <int>[];
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final val =
            (math.sin(c * 0.3 - t * 3.0) * math.sin(r * 0.3 + t * 2.0) + 1) *
                0.5;
        result.add(_ci(val));
      }
    }
    return result;
  }

  List<int> _sphere() {
    final result = <int>[];
    final angle = t * 1.2;
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final nx = (c / cols) * 2.0 - 1.0;
        final ny = ((r / rows) * 2.0 - 1.0) * (rows / (cols * 0.5));
        final r2 = nx * nx + ny * ny;
        if (r2 > 1.0) {
          result.add(0);
        } else {
          final z = math.sqrt(1.0 - r2);
          final lx = math.cos(angle);
          final ly = math.sin(angle) * 0.5;
          const lz = 0.5;
          final light = (lx * nx + ly * ny + lz * z).clamp(0.0, 1.0);
          result.add(_ci(light));
        }
      }
    }
    return result;
  }

  List<int> _torus() {
    const R = 1.0;
    const r = 0.4;
    final grid = List<double>.filled(rows * cols, -double.infinity);
    final zBuf = List<double>.filled(rows * cols, -double.infinity);
    const thetaSteps = 180;
    const phiSteps = 80;
    final A = t * 1.5;
    final B = t * 0.7;

    for (int ti = 0; ti < thetaSteps; ti++) {
      final theta = ti * 2 * math.pi / thetaSteps;
      for (int phi = 0; phi < phiSteps; phi++) {
        final phiA = phi * 2 * math.pi / phiSteps;
        final x0 = (R + r * math.cos(theta)) * math.cos(phiA);
        final y0 = (R + r * math.cos(theta)) * math.sin(phiA);
        final z0 = r * math.sin(theta);

        final x1 = x0;
        final y1 = y0 * math.cos(A) - z0 * math.sin(A);
        final z1 = y0 * math.sin(A) + z0 * math.cos(A);

        final x2 = x1 * math.cos(B) - y1 * math.sin(B);
        final y2 = x1 * math.sin(B) + y1 * math.cos(B);
        final z2 = z1;

        final zOff = 3.0 + z2;
        if (zOff <= 0) continue;
        final projX = x2 / zOff;
        final projY = y2 / zOff;

        final sc = math.min(cols, rows) * 0.38;
        final col = ((projX * sc) + cols / 2).round();
        final row = ((projY * sc * 0.5) + rows / 2).round();

        if (col < 0 || col >= cols || row < 0 || row >= rows) continue;

        final idx = row * cols + col;
        if (z2 > zBuf[idx]) {
          zBuf[idx] = z2;
          final nx = math.cos(theta) * math.cos(phiA);
          final ny = math.cos(theta) * math.sin(phiA);
          final nz = math.sin(theta);
          final light = (nx * 0.6 + ny * 0.4 + nz * 0.6).clamp(0.0, 1.0);
          grid[idx] = light;
        }
      }
    }

    return grid.map((v) => v == -double.infinity ? 0 : _ci(v)).toList();
  }

  List<int> _helix() {
    final result = List<int>.filled(rows * cols, 0);
    for (int r = 0; r < rows; r++) {
      final frac = r / rows;
      final angle = frac * 4 * 2 * math.pi + t * 2.0;
      final cx1 = (cols / 2) + (cols * 0.3) * math.cos(angle);
      final cx2 = (cols / 2) + (cols * 0.3) * math.cos(angle + math.pi);

      for (int c = 0; c < cols; c++) {
        final d1 = (c - cx1).abs();
        final d2 = (c - cx2).abs();
        final d = math.min(d1, d2);
        final val = (1.0 - (d / 2.5)).clamp(0.0, 1.0);
        result[r * cols + c] = _ci(val);
      }

      if (r % 6 == 0) {
        final minC = math.min(cx1, cx2).round().clamp(0, cols - 1);
        final maxC = math.max(cx1, cx2).round().clamp(0, cols - 1);
        for (int c = minC; c <= maxC; c++) {
          result[r * cols + c] = _ci(0.55);
        }
      }
    }
    return result;
  }

  List<int> _cube() {
    final result = List<int>.filled(rows * cols, 0);

    final verts = [
      [-1.0, -1.0, -1.0],
      [1.0, -1.0, -1.0],
      [1.0, 1.0, -1.0],
      [-1.0, 1.0, -1.0],
      [-1.0, -1.0, 1.0],
      [1.0, -1.0, 1.0],
      [1.0, 1.0, 1.0],
      [-1.0, 1.0, 1.0],
    ];
    const edges = [
      [0, 1],
      [1, 2],
      [2, 3],
      [3, 0],
      [4, 5],
      [5, 6],
      [6, 7],
      [7, 4],
      [0, 4],
      [1, 5],
      [2, 6],
      [3, 7],
    ];

    final ax = t * 0.7;
    final ay = t * 1.1;

    List<double> rotPt(List<double> v) {
      final x1 = v[0] * math.cos(ay) + v[2] * math.sin(ay);
      final z1 = -v[0] * math.sin(ay) + v[2] * math.cos(ay);
      final y1 = v[1];
      final y2 = y1 * math.cos(ax) - z1 * math.sin(ax);
      final z2 = y1 * math.sin(ax) + z1 * math.cos(ax);
      return [x1, y2, z2];
    }

    (int, int) proj(List<double> v) {
      final rv = rotPt(v);
      final z = rv[2] + 4.0;
      final px = rv[0] / z;
      final py = rv[1] / z;
      final sc = math.min(cols, rows) * 0.35;
      return ((px * sc + cols / 2).round(), (py * sc * 0.5 + rows / 2).round());
    }

    void drawLine(int c0, int r0, int c1, int r1) {
      final steps = math.max((c1 - c0).abs(), (r1 - r0).abs()) * 2 + 1;
      for (int s = 0; s <= steps; s++) {
        final ic = (c0 + (c1 - c0) * s / steps).round();
        final ir = (r0 + (r1 - r0) * s / steps).round();
        if (ic >= 0 && ic < cols && ir >= 0 && ir < rows) {
          result[ir * cols + ic] = chars.length - 1;
        }
      }
    }

    for (final edge in edges) {
      final (c0, r0) = proj(verts[edge[0]]);
      final (c1, r1) = proj(verts[edge[1]]);
      drawLine(c0, r0, c1, r1);
    }

    return result;
  }

  List<int> _matrix() {
    final heads = matrixHeads ?? List<int>.generate(cols, (i) => i % rows);
    final result = <int>[];
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final head = heads[c];
        if (r == head) {
          result.add(chars.length - 1);
        } else {
          final dist = (head - r + rows) % rows;
          if (dist < rows ~/ 3) {
            final val = 1.0 - dist / (rows / 3.0);
            result.add(_ci(val));
          } else {
            final mc = matrixChars?[c][r] ?? 0;
            result.add(mc > 0 ? (mc ~/ 2).clamp(0, chars.length - 1) : 0);
          }
        }
      }
    }
    return result;
  }

  List<int> _rose() {
    final result = List<int>.filled(rows * cols, 0);
    const k = 5.0;
    const steps = 2000;
    final cx = cols / 2.0;
    final cy = rows / 2.0;
    final sc = math.min(cols * 0.5, rows * 0.9);

    for (int s = 0; s <= steps; s++) {
      final theta = s / steps * 2 * math.pi + t * 0.5;
      final rVal = math.cos(k * theta);
      final x = rVal * math.cos(theta);
      final y = rVal * math.sin(theta);
      final col = (cx + x * sc * 0.48).round();
      final row = (cy + y * sc * 0.9).round();
      if (col >= 0 && col < cols && row >= 0 && row < rows) {
        result[row * cols + col] = chars.length - 1;
        for (final dr in [-1, 0, 1]) {
          for (final dc in [-1, 0, 1]) {
            final nc = col + dc;
            final nr = row + dr;
            if (nc >= 0 && nc < cols && nr >= 0 && nr < rows) {
              if (result[nr * cols + nc] < chars.length - 2) {
                result[nr * cols + nc] =
                    (chars.length - 2).clamp(1, chars.length - 1);
              }
            }
          }
        }
      }
    }
    return result;
  }

  List<int> _vortex() {
    final result = <int>[];
    final cx = cols / 2.0;
    final cy = rows / 2.0;
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final dx = (c - cx) * 2.0;
        final dy = (r - cy).toDouble();
        final dist = math.sqrt(dx * dx + dy * dy);
        final angle = math.atan2(dy, dx);
        final twist = dist * 0.15 - t * 3.0;
        final val =
            (math.sin(angle * 3.0 + twist) * math.exp(-dist * 0.06) + 1) * 0.5;
        result.add(_ci(val));
      }
    }
    return result;
  }

  List<int> _pulse() {
    final result = <int>[];
    final cx = cols / 2.0;
    final cy = rows / 2.0;
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final dx = (c - cx) * 2.0;
        final dy = (r - cy).toDouble();
        final dist = math.sqrt(dx * dx + dy * dy);
        final ring1 = math.sin(dist * 0.4 - t * 5.0);
        final ring2 = math.sin(dist * 0.3 - t * 3.5 + 1.0) * 0.5;
        final val = ((ring1 + ring2) / 1.5 + 1) * 0.5;
        result.add(_ci(val));
      }
    }
    return result;
  }

  List<int> _dna() {
    final result = List<int>.filled(rows * cols, 0);
    final cx = cols / 2.0;
    for (int r = 0; r < rows; r++) {
      final phase = r * 0.35 + t * 2.0;
      final strand1 = cx + (cols * 0.28) * math.cos(phase);
      final strand2 = cx + (cols * 0.28) * math.cos(phase + math.pi);
      for (int c = 0; c < cols; c++) {
        final d1 = (c - strand1).abs();
        final d2 = (c - strand2).abs();
        final val = math.max(
          (1.0 - d1 / 2.5).clamp(0.0, 1.0),
          (1.0 - d2 / 2.5).clamp(0.0, 1.0),
        );
        result[r * cols + c] = _ci(val);
      }
      if (r % 6 == 0) {
        final minC = math.min(strand1, strand2).round().clamp(0, cols - 1);
        final maxC = math.max(strand1, strand2).round().clamp(0, cols - 1);
        for (int c = minC; c <= maxC; c++) {
          result[r * cols + c] = _ci(0.5);
        }
      }
    }
    return result;
  }

  List<int> _trefoilKnot() {
    final result = List<int>.filled(rows * cols, 0);
    const steps = 600;
    final cx = cols / 2.0;
    final cy = rows / 2.0;
    final sc = math.min(cols * 0.4, rows * 0.8);

    for (int s = 0; s <= steps; s++) {
      final tp = s / steps * 2 * math.pi + t * 0.6;
      final x = math.sin(tp) + 2 * math.sin(2 * tp);
      final y = math.cos(tp) - 2 * math.cos(2 * tp);
      final col = (cx + x * sc * 0.22).round();
      final row = (cy + y * sc * 0.42).round();
      if (col >= 0 && col < cols && row >= 0 && row < rows) {
        result[row * cols + col] = chars.length - 1;
        if (col > 0) {
          result[row * cols + col - 1] =
              math.max(result[row * cols + col - 1], chars.length - 2);
        }
        if (col < cols - 1) {
          result[row * cols + col + 1] =
              math.max(result[row * cols + col + 1], chars.length - 2);
        }
      }
    }
    return result;
  }

  List<int> _geodesicDome() {
    final result = List<int>.filled(rows * cols, 0);
    const latLines = 6;
    const lonLines = 12;
    const steps = 100;
    final cx = cols / 2.0;
    final cy = rows / 2.0;
    final sc = math.min(cols * 0.48, rows * 0.95);
    final ax = t * 0.5;
    final ay = t * 0.3;

    List<double> rotPt(double x, double y, double z) {
      final x1 = x * math.cos(ay) + z * math.sin(ay);
      final z1 = -x * math.sin(ay) + z * math.cos(ay);
      final y2 = y * math.cos(ax) - z1 * math.sin(ax);
      final z2 = y * math.sin(ax) + z1 * math.cos(ax);
      return [x1, y2, z2];
    }

    void plot(double x, double y, double z) {
      final rp = rotPt(x, y, z);
      if (rp[1] > -0.1) {
        final c = (cx + rp[0] * sc * 0.5).round();
        final r = (cy - rp[1] * sc).round();
        if (c >= 0 && c < cols && r >= 0 && r < rows) {
          result[r * cols + c] = chars.length - 1;
        }
      }
    }

    for (int l = 0; l <= latLines; l++) {
      final lat = (l / latLines) * math.pi / 2;
      for (int s = 0; s <= steps * 2; s++) {
        final lonRad = s / (steps * 2) * 2 * math.pi;
        plot(math.cos(lat) * math.cos(lonRad), math.sin(lat),
            math.cos(lat) * math.sin(lonRad));
      }
    }

    for (int l = 0; l < lonLines; l++) {
      final lon = l * math.pi * 2 / lonLines;
      for (int s = 0; s <= steps; s++) {
        final lat = s / steps * math.pi / 2;
        plot(math.cos(lat) * math.cos(lon), math.sin(lat),
            math.cos(lat) * math.sin(lon));
      }
    }

    return result;
  }

  List<int> _saturn() {
    final result = List<int>.filled(rows * cols, 0);
    final cx = cols / 2.0;
    final cy = rows / 2.0;
    final sc = math.min(cols * 0.38, rows * 0.75);
    final tilt = math.pi / 5 + math.sin(t * 0.3) * 0.2;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final nx = (c - cx) / sc * 2.0;
        final ny = (r - cy) / sc * 4.0;
        final r2 = nx * nx + ny * ny;
        if (r2 <= 1.0) {
          final z = math.sqrt(1.0 - r2);
          final light = (0.6 * nx + 0.4 * z).clamp(0.0, 1.0);
          result[r * cols + c] = _ci(light);
        }
      }
    }

    for (int ri = 0; ri < 3; ri++) {
      final ringR = sc * (1.4 + ri * 0.25);
      for (int s = 0; s <= 400; s++) {
        final theta = s / 400 * 2 * math.pi;
        final rx = math.cos(theta) * ringR;
        final ry = math.sin(theta) * ringR * math.sin(tilt);
        final c = (cx + rx * 0.5).round();
        final r = (cy + ry * 0.5).round();
        if (c >= 0 && c < cols && r >= 0 && r < rows) {
          if (result[r * cols + c] == 0) {
            result[r * cols + c] = _ci(0.4 + ri * 0.1);
          }
        }
      }
    }

    return result;
  }

  List<int> _hyperboloid() {
    final result = List<int>.filled(rows * cols, 0);
    final cx = cols / 2.0;
    final cy = rows / 2.0;
    const aLines = 20;
    const steps = 200;
    final sc = math.min(cols * 0.48, rows * 0.95);

    for (int li = 0; li < aLines; li++) {
      final phi = li / aLines * 2 * math.pi;
      for (int s = 0; s <= steps; s++) {
        final u = (s / steps) * 2.0 - 1.0;
        final ch = (math.exp(u) + math.exp(-u)) / 2;
        final sh = (math.exp(u) - math.exp(-u)) / 2;
        final x = ch * math.cos(phi + t * 0.5);
        final y = ch * math.sin(phi + t * 0.5);
        final z = sh;
        final px = x * 0.7 - y * 0.7;
        final py = (x * 0.4 + y * 0.4) - z * 0.8;
        final c = (cx + px * sc * 0.25).round();
        final r = (cy + py * sc * 0.4).round();
        if (c >= 0 && c < cols && r >= 0 && r < rows) {
          result[r * cols + c] = chars.length - 1;
        }
      }
    }
    return result;
  }

  List<int> _grid() {
    final result = <int>[];
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final onH = r % 4 == 0;
        final onV = c % 6 == 0;
        if (onH && onV) {
          result.add(chars.length - 1);
        } else if (onH || onV) {
          final phase = (onH ? c : r) * 0.3 - t * 2.0;
          final val = (math.sin(phase) + 1) * 0.4 + 0.2;
          result.add(_ci(val));
        } else {
          result.add(0);
        }
      }
    }
    return result;
  }
}

// ---------------------------------------------------------------------------
// Main Widget
// ---------------------------------------------------------------------------

class BkAsciiShape extends StatefulWidget {
  const BkAsciiShape({
    super.key,
    required this.shape,
    this.size = BkAsciiSize.md,
    this.charset = BkAsciiCharset.blocks,
    this.speed = BkAsciiSpeed.normal,
    this.animated = true,
    this.multicolor = false,
    this.color,
  });

  final BkAsciiShapeType shape;
  final BkAsciiSize size;
  final BkAsciiCharset charset;
  final BkAsciiSpeed speed;
  final bool animated;
  final bool multicolor;
  final Color? color;

  @override
  State<BkAsciiShape> createState() => _BkAsciiShapeState();
}

class _BkAsciiShapeState extends State<BkAsciiShape>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  double _elapsed = 0.0;
  DateTime _lastTime = DateTime.now();

  late List<int> _matrixHeads;
  late List<List<int>> _matrixChars;
  int _matrixFrameCounter = 0;
  final math.Random _rng = math.Random();

  @override
  void initState() {
    super.initState();
    _initMatrix();
    _ticker = createTicker(_onTick);
    if (widget.animated) _ticker.start();
  }

  void _initMatrix() {
    final cols = widget.size.cols;
    final rows = widget.size.rows;
    _matrixHeads = List<int>.generate(cols, (i) => _rng.nextInt(rows));
    _matrixChars = List<List<int>>.generate(
      cols,
      (_) => List<int>.generate(rows, (__) => _rng.nextInt(5)),
    );
  }

  void _onTick(Duration elapsed) {
    final now = DateTime.now();
    final dt = now.difference(_lastTime).inMicroseconds / 1e6;
    _lastTime = now;
    _elapsed += dt * widget.speed.multiplier;

    if (widget.shape == BkAsciiShapeType.matrix) {
      _matrixFrameCounter++;
      if (_matrixFrameCounter >= 4) {
        _matrixFrameCounter = 0;
        final cols = widget.size.cols;
        final rows = widget.size.rows;
        for (int c = 0; c < cols; c++) {
          _matrixHeads[c] = (_matrixHeads[c] + 1) % rows;
          for (int i = 0; i < 3; i++) {
            final r = _rng.nextInt(rows);
            _matrixChars[c][r] = _rng.nextInt(5);
          }
        }
      }
    }

    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(BkAsciiShape oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animated && !_ticker.isActive) {
      _lastTime = DateTime.now();
      _ticker.start();
    } else if (!widget.animated && _ticker.isActive) {
      _ticker.stop();
    }
    if (oldWidget.size != widget.size || oldWidget.shape != widget.shape) {
      _initMatrix();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnims = MediaQuery.of(context).disableAnimations;
    if (disableAnims && _ticker.isActive) _ticker.stop();

    final chars = _charsetChars(widget.charset);
    final cols = widget.size.cols;
    final rows = widget.size.rows;

    final grid = _AsciiGrid(
      cols: cols,
      rows: rows,
      chars: chars,
      t: _elapsed,
      shapeType: widget.shape,
      matrixHeads:
          widget.shape == BkAsciiShapeType.matrix ? _matrixHeads : null,
      matrixChars:
          widget.shape == BkAsciiShapeType.matrix ? _matrixChars : null,
    ).compute();

    final palette = widget.multicolor ? _multicolorPalette(context) : null;
    final baseColor = widget.color ?? Theme.of(context).colorScheme.primary;

    const double fontSize = 7.0;
    const double lineHeight = 1.18;

    final spans = <InlineSpan>[];
    for (int r = 0; r < rows; r++) {
      final rowColor =
          palette != null ? palette[r % palette.length] : baseColor;
      final rowBuf = StringBuffer();
      for (int c = 0; c < cols; c++) {
        final ci = grid[r * cols + c];
        rowBuf.write(chars[ci]);
      }
      rowBuf.write('\n');
      spans.add(TextSpan(
        text: rowBuf.toString(),
        style: TextStyle(color: rowColor),
      ));
    }

    return RepaintBoundary(
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontFamily: 'DM Mono',
            fontFamilyFallback: ['Courier New', 'monospace'],
            fontSize: fontSize,
            height: lineHeight,
            letterSpacing: 0.0,
          ),
          children: spans,
        ),
      ),
    );
  }
}
