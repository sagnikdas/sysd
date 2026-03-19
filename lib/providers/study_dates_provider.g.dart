// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_dates_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(StudyDates)
final studyDatesProvider = StudyDatesProvider._();

final class StudyDatesProvider
    extends $NotifierProvider<StudyDates, List<StudyDay>> {
  StudyDatesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'studyDatesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$studyDatesHash();

  @$internal
  @override
  StudyDates create() => StudyDates();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<StudyDay> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<StudyDay>>(value),
    );
  }
}

String _$studyDatesHash() => r'0924c08cf776656ebf4a7004e51eb86103abce99';

abstract class _$StudyDates extends $Notifier<List<StudyDay>> {
  List<StudyDay> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<StudyDay>, List<StudyDay>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<StudyDay>, List<StudyDay>>,
              List<StudyDay>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
