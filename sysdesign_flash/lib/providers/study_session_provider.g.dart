// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_session_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(studySession)
final studySessionProvider = StudySessionFamily._();

final class StudySessionProvider
    extends $FunctionalProvider<StudySession, StudySession, StudySession>
    with $Provider<StudySession> {
  StudySessionProvider._({
    required StudySessionFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'studySessionProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$studySessionHash();

  @override
  String toString() {
    return r'studySessionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<StudySession> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  StudySession create(Ref ref) {
    final argument = this.argument as int;
    return studySession(ref, maxNew: argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StudySession value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StudySession>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is StudySessionProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$studySessionHash() => r'01a78f650c846ecbaec0d53d4a5b3ac5bf305e4b';

final class StudySessionFamily extends $Family
    with $FunctionalFamilyOverride<StudySession, int> {
  StudySessionFamily._()
    : super(
        retry: null,
        name: r'studySessionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  StudySessionProvider call({int maxNew = 5}) =>
      StudySessionProvider._(argument: maxNew, from: this);

  @override
  String toString() => r'studySessionProvider';
}
