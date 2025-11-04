/*
 * Copyright (c) 2021 Simform Solutions
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

import 'package:flutter/material.dart';

class TargetPositionService {
  /// A service class that handles positioning calculations for showcase
  /// targets.
  ///
  /// This class calculates and provides the position and dimensions of a
  /// target widget within the context of the showcase overlay. It's
  /// responsible for:
  ///
  /// - Determining the exact position of a target widget in global coordinates.
  /// - Computing the boundaries of the target widget with optional padding.
  /// - Providing helper methods for tooltip positioning around the target.
  /// - Ensuring the target stays within screen bounds.
  /// - Supporting different ancestral coordinate systems.
  TargetPositionService({
    required this.renderBox,
    required this.overlayBox,
    required this.screenSize,
    this.padding = EdgeInsets.zero,
    this.rootRenderObject,
  }) : assert(overlayBox != null, 'overlayBox must be the ROOT overlay');

  final RenderBox? renderBox;
  final RenderBox? overlayBox; // root overlay RenderBox
  final EdgeInsets padding;
  final Size screenSize; // == overlayBox.size
  final RenderObject? rootRenderObject;

  // Caching fields to avoid redundant calculations
  Rect? _cachedRect;
  Rect? _cachedRectForOverlay;

  // Flag to track if dimensions have changed and cache needs to be invalidated
  bool _dimensionsChanged = true;

  /// Highlight rect = overlay rect ± padding, clamped to overlay bounds.
  Rect getRect() {
    if (renderBox == null) return Rect.zero;
    if (_cachedRect != null && !_dimensionsChanged) return _cachedRect!;

    final r = _computeOverlayRect();
    final left = (r.left - padding.left).clamp(0.0, screenSize.width);
    final top = (r.top - padding.top).clamp(0.0, screenSize.height);
    final right = (r.right + padding.right).clamp(0.0, screenSize.width);
    final bottom = (r.bottom + padding.bottom).clamp(0.0, screenSize.height);
    _dimensionsChanged = false;
    return _cachedRect = Rect.fromLTRB(left, top, right, bottom);
  }

  Rect _computeOverlayRect() {
    final rb = renderBox!;
    final origin = rb.localToGlobal(Offset.zero, ancestor: overlayBox);
    return origin & rb.size;
  }

  Rect getRectForOverlay() {
    if (renderBox == null) return Rect.zero;
    if (_cachedRectForOverlay != null && !_dimensionsChanged) {
      return _cachedRectForOverlay!;
    }
    final rect = _computeOverlayRect();
    _dimensionsChanged = false;
    return _cachedRectForOverlay = rect;
  }

  double getTop() => getRect().top;
  double getBottom() => getRect().bottom;
  double getLeft() => getRect().left;
  double getRight() => getRect().right;
  double getHeight() => getRect().height;
  double getWidth() => getRect().width;
  double getCenter() => (getLeft() + getRight()) * 0.5;

  Offset topLeft() => getRectForOverlay().topLeft;
  Offset getOffset() => getRectForOverlay().center;
}
