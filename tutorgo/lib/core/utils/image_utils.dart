import 'dart:convert';
import 'package:flutter/material.dart';

/// Builds an [ImageProvider] from a stored profile-image value.
///
/// Profile images may be persisted as a network URL, a `data:` URI, or a raw
/// base64-encoded image (the app encodes picked files with `base64Encode`).
/// Returns `null` when there is nothing usable to render so callers can fall
/// back to a placeholder icon.
ImageProvider? profileImageProvider(dynamic raw) {
  if (raw == null) return null;
  final value = raw.toString().trim();
  if (value.isEmpty) return null;

  if (value.startsWith('http://') || value.startsWith('https://')) {
    return NetworkImage(value);
  }

  // Strip an optional `data:image/...;base64,` prefix.
  final base64Part = value.startsWith('data:') && value.contains(',')
      ? value.substring(value.indexOf(',') + 1)
      : value;

  try {
    return MemoryImage(base64Decode(base64Part));
  } catch (_) {
    return null;
  }
}
