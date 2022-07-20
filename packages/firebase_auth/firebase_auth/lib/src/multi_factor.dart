part of firebase_auth;

/// Defines multi-factor related properties and operations pertaining to a [User].
/// This class acts as the main entry point for enrolling or un-enrolling
/// second factors for a user, and provides access to their currently enrolled factors.
class MultiFactor {
  MultiFactorPlatform _delegate;

  MultiFactor._(this._delegate);

  /// Returns a session identifier for a second factor enrollment operation.
  Future<MultiFactorSession> getSession() {
    return _delegate.getSession();
  }

  /// Enrolls a second factor as identified by the [MultiFactorAssertion] parameter for the current user.
  ///
  /// [displayName] can be used to provide a display name for the second factor.
  Future<void> enroll(
    MultiFactorAssertionPlatform assertion, {
    String? displayName,
  }) async {
    return _delegate.enroll(assertion, displayName: displayName);
  }

  /// Unenrolls a second factor from this user.
  ///
  /// [factorUid] is the unique identifier of the second factor to unenroll.
  /// [multiFactorInfo] is the [MultiFactorInfo] of the second factor to unenroll.
  /// Only one of [factorUid] or [multiFactorInfo] should be provided.
  Future<void> unenroll({String? factorUid, MultiFactorInfo? multiFactorInfo}) {
    return _delegate.unenroll(
      factorUid: factorUid,
      multiFactorInfo: multiFactorInfo,
    );
  }

  /// Returns a list of the [MultiFactorInfo] already associated with this user.
  Future<List<MultiFactorInfo>> getEnrolledFactors() {
    return _delegate.getEnrolledFactors();
  }
}

/// Provider for generating a PhoneMultiFactorAssertion.
class PhoneMultiFactorGenerator {
  /// Transforms a PhoneAuthCredential into a [MultiFactorAssertion]
  /// which can be used to confirm ownership of a phone second factor.
  static MultiFactorAssertionPlatform getAssertion(
    PhoneAuthCredential credential,
  ) {
    return PhoneMultiFactorGeneratorPlatform.instance.getAssertion(credential);
  }
}
