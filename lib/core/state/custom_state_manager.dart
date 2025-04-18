import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// نوع مخصص للعمال للتوافق مع GetX
typedef WorkerCallback = StreamSubscription<dynamic>;

/// مدير حالة مخصص يوفر وظائف إضافية فوق Rx
class CustomStateManager<T> {
  final Rx<T> _state;
  final T initialState;

  CustomStateManager(this.initialState) : _state = initialState.obs;

  T get state => _state.value;
  set state(T value) => _state.value = value;

  Stream<T> get stream => _state.stream;

  void update(void Function(T state) updater) {
    updater(_state.value);
    _state.refresh();
  }

  Widget obx(
    Widget Function(T state) builder, {
    Widget? onLoading,
    Widget? onError,
    Widget? onEmpty,
  }) {
    return Obx(() {
      final value = _state.value;
      if (value == null && onEmpty != null) return onEmpty;
      return builder(value);
    });
  }

  /// استدعاء دالة في كل مرة تتغير فيها القيمة
  WorkerCallback ever(void Function(T state) callback) {
    return _state.listen(callback);
  }

  /// استدعاء دالة مرة واحدة فقط عند أول تغيير
  WorkerCallback once(void Function(T state) callback) {
    bool called = false;
    return _state.listen((value) {
      if (!called) {
        called = true;
        callback(value);
      }
    });
  }

  /// استدعاء دالة بعد فترة من الزمن من آخر تغيير
  WorkerCallback debounce(
    void Function(T state) callback, {
    Duration? time,
  }) {
    final duration = time ?? const Duration(milliseconds: 800);
    Timer? timer;

    return _state.listen((value) {
      if (timer?.isActive ?? false) timer?.cancel();
      timer = Timer(duration, () => callback(value));
    });
  }

  /// استدعاء دالة على فترات زمنية منتظمة
  WorkerCallback interval(
    void Function(T state) callback, {
    Duration? time,
  }) {
    final duration = time ?? const Duration(milliseconds: 400);
    Timer? timer;
    late StreamSubscription<T> subscription;

    subscription = _state.listen((value) {
      if (timer == null || !timer!.isActive) {
        callback(value);
        timer = Timer.periodic(duration, (_) {
          callback(value);
        });
      }
    });

    return subscription;
  }

  void dispose() {
    // ليس هناك حاجة لإزالة Workers لأن GetX يقوم بذلك تلقائيًا
  }
}

/// مدير حالة للتعامل مع الحالات المعقدة والمتداخلة
class DeepStateManager<T> extends CustomStateManager<T> {
  DeepStateManager(super.initialState);

  void updateNested<K>(
    K Function(T state) selector,
    void Function(K value) updater,
  ) {
    final currentState = state;
    final nestedValue = selector(currentState);
    updater(nestedValue);
    _state.refresh();
  }

  Widget nestedObx<K>(
    K Function(T state) selector,
    Widget Function(K value) builder, {
    Widget? onLoading,
    Widget? onError,
    Widget? onEmpty,
  }) {
    return Obx(() {
      final value = selector(state);
      if (value == null && onEmpty != null) return onEmpty;
      return builder(value);
    });
  }
}
