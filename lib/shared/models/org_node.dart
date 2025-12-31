import 'package:flutter/material.dart';

class OrgNode {
  const OrgNode({
    required this.id,
    required this.label,
    required this.position,
    this.parentId,
  });

  final String id;
  final String label;
  final Offset position;
  final String? parentId;

  OrgNode copyWith({
    String? id,
    String? label,
    Offset? position,
    String? parentId,
  }) {
    return OrgNode(
      id: id ?? this.id,
      label: label ?? this.label,
      position: position ?? this.position,
      parentId: parentId ?? this.parentId,
    );
  }
}
