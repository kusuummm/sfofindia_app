import 'package:flutter/material.dart';

class ServiceProgram {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String imagePath;
  final IconData icon;
  final List<String> benefits;
  final List<String> eligibleCriteria;

  const ServiceProgram({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.imagePath,
    required this.icon,
    required this.benefits,
    required this.eligibleCriteria,
  });
}
