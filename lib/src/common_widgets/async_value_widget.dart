import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AsyncValueWidget<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final Widget Function() loading;
  final Widget Function(Object error, StackTrace? stackTrace) error;

  const AsyncValueWidget({
    super.key,
    required this.value,
    required this.data,
    required this.loading,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      loading: loading,
      error: error,
    );
  }
}

// A more specific Sliver version for use in CustomScrollViews etc.
class AsyncValueSliverWidget<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final Widget Function() loading;
  final Widget Function(Object error, StackTrace? stackTrace) error;

  const AsyncValueSliverWidget({
    super.key,
    required this.value,
    required this.data,
    required this.loading,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      loading: loading,
      error: error,
    );
  }
} 