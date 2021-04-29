// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore;

/// A document reference that can be either a [DocumentReference] or a [WithConverterDocumentReference].
@immutable
abstract class AnyDocumentReference {
  /// The Firestore instance associated with this document reference.
  FirebaseFirestore get firestore;

  /// This document's given ID within the collection.
  String get id;

  /// The parent [CollectionReference] of this document.
  CollectionReference get parent;

  /// A string representing the path of the referenced document (relative to the
  /// root of the database).
  String get path;

  /// Gets a [CollectionReference] instance that refers to the collection at the
  /// specified path, relative from this [DocumentReference].
  CollectionReference collection(String collectionPath);

  /// Deletes the current document from the collection.
  Future<void> delete();

  /// Updates data on the document. Data will be merged with any existing
  /// document data.
  ///
  /// If no document exists yet, the update will fail.
  Future<void> update(Map<String, Object?> data);
}

@immutable
abstract class _DocumentReference<T, Snapshot> implements AnyDocumentReference {
  /// Reads the document referenced by this [DocumentReference].
  ///
  /// By providing [options], this method can be configured to fetch results only
  /// from the server, only from the local cache or attempt to fetch results
  /// from the server and fall back to the cache (which is the default).
  Future<Snapshot> get([GetOptions? options]);

  /// Notifies of document updates at this location.
  ///
  /// An initial event is immediately sent, and further events will be
  /// sent whenever the document is modified.
  Stream<Snapshot> snapshots({bool includeMetadataChanges = false});

  /// Sets data on the document, overwriting any existing data. If the document
  /// does not yet exist, it will be created.
  ///
  /// If [SetOptions] are provided, the data will be merged into an existing
  /// document instead of overwriting.
  Future<void> set(T data, [SetOptions? options]);
}

/// A [DocumentReference] refers to a document location in a [FirebaseFirestore] database
/// and can be used to write, read, or listen to the location.
///
/// The document at the referenced location may or may not exist.
/// A [DocumentReference] can also be used to create a [CollectionReference]
/// to a subcollection.
@immutable
class DocumentReference
    implements _DocumentReference<Map<String, dynamic>, DocumentSnapshot> {
  DocumentReference._(this.firestore, this._delegate) {
    DocumentReferencePlatform.verifyExtends(_delegate);
  }

  final DocumentReferencePlatform _delegate;

  @override
  final FirebaseFirestore firestore;

  @override
  String get id => _delegate.id;

  @override
  CollectionReference get parent =>
      CollectionReference._(firestore, _delegate.parent);

  @override
  String get path => _delegate.path;

  @override
  CollectionReference collection(String collectionPath) {
    assert(collectionPath.isNotEmpty,
        'a collectionPath path must be a non-empty string');
    assert(!collectionPath.contains('//'),
        'a collection path must not contain "//"');
    assert(isValidCollectionPath(collectionPath),
        'a collection path must point to a valid collection.');

    return CollectionReference._(
      firestore,
      _delegate.collection(collectionPath),
    );
  }

  @override
  Future<void> delete() => _delegate.delete();

  @override
  Future<DocumentSnapshot> get([GetOptions? options]) async {
    return DocumentSnapshot._(
      firestore,
      await _delegate.get(options ?? const GetOptions()),
    );
  }

  @override
  Stream<DocumentSnapshot> snapshots({bool includeMetadataChanges = false}) {
    return _delegate
        .snapshots(includeMetadataChanges: includeMetadataChanges)
        .map((delegateSnapshot) =>
            DocumentSnapshot._(firestore, delegateSnapshot));
  }

  @override
  Future<void> set(Map<String, dynamic> data, [SetOptions? options]) {
    return _delegate.set(
        _CodecUtility.replaceValueWithDelegatesInMap(data)!, options);
  }

  @override
  Future<void> update(Map<String, Object?> data) {
    return _delegate
        .update(_CodecUtility.replaceValueWithDelegatesInMap(data)!);
  }

  /// Transforms a [DocumentReference] to manipulate a custom object instead
  /// of a `Map<String, dynamic>`.
  ///
  /// This makes both read and write operations type-safe.
  ///
  /// ```dart
  /// final modelRef = FirebaseFirestore
  ///     .instance
  ///     .collection('models')
  ///     .doc('123')
  ///     .withConverter<Model>(
  ///       fromFirestore: (json) => Model.fromJson(json),
  ///       toFirestore: (model) => model.toJson(),
  ///     );
  ///
  /// Future<void> main() async {
  ///   // Writes now take a Model as parameter instead of a Map
  ///   await johnRef.set(Model());
  ///
  ///   // Reads now return a Model instead of a Map
  ///   final Model model = await modelRef.get().then((s) => s.data());
  /// }
  /// ```
  WithConverterDocumentReference<T> withConverter<T>({
    required FromFirestore<T> fromFirestore,
    required ToFirestore<T> toFirestore,
  }) {
    return WithConverterDocumentReference._(this, fromFirestore, toFirestore);
  }

  @override
  bool operator ==(Object other) =>
      other is DocumentReference &&
      other.firestore == firestore &&
      other.path == path;

  @override
  int get hashCode => hashValues(firestore, path);

  @override
  String toString() => '$DocumentReference($path)';
}

/// A [DocumentReference] refers to a document location in a [FirebaseFirestore] database
/// and can be used to write, read, or listen to the location.
///
/// The document at the referenced location may or may not exist.
/// A [DocumentReference] can also be used to create a [CollectionReference]
/// to a subcollection.
@immutable
class WithConverterDocumentReference<T>
    implements _DocumentReference<T, WithConverterDocumentSnapshot<T>> {
  WithConverterDocumentReference._(
    this._originalDocumentReference,
    this._fromFirestore,
    this._toFirestore,
  );

  final DocumentReference _originalDocumentReference;
  final FromFirestore<T> _fromFirestore;
  final ToFirestore<T> _toFirestore;

  @override
  CollectionReference collection(String collectionPath) {
    return _originalDocumentReference.collection(collectionPath);
  }

  @override
  Future<void> delete() {
    return _originalDocumentReference.delete();
  }

  @override
  Future<WithConverterDocumentSnapshot<T>> get([GetOptions? options]) {
    return _originalDocumentReference.get(options).then((snapshot) {
      return WithConverterDocumentSnapshot<T>._(
        snapshot,
        _fromFirestore,
        _toFirestore,
      );
    });
  }

  @override
  FirebaseFirestore get firestore => _originalDocumentReference.firestore;

  @override
  String get id => _originalDocumentReference.id;

  @override
  CollectionReference get parent => _originalDocumentReference.parent;

  @override
  String get path => _originalDocumentReference.path;

  @override
  Future<void> set(T data, [SetOptions? options]) {
    return _originalDocumentReference.set(
      _toFirestore(data, options),
      options,
    );
  }

  @override
  Stream<WithConverterDocumentSnapshot<T>> snapshots({
    bool includeMetadataChanges = false,
  }) {
    return _originalDocumentReference
        .snapshots(includeMetadataChanges: includeMetadataChanges)
        .map((snapshot) {
      return WithConverterDocumentSnapshot<T>._(
        snapshot,
        _fromFirestore,
        _toFirestore,
      );
    });
  }

  @override
  Future<void> update(Map<String, Object?> data) {
    return _originalDocumentReference.update(data);
  }

  @override
  bool operator ==(Object other) =>
      other is WithConverterDocumentReference<T> &&
      other.runtimeType == runtimeType &&
      other._originalDocumentReference == _originalDocumentReference &&
      other._fromFirestore == _fromFirestore &&
      other._toFirestore == _toFirestore;

  @override
  int get hashCode => hashValues(
      runtimeType, _originalDocumentReference, _fromFirestore, _toFirestore);

  @override
  String toString() => 'WithConverterDocumentReference<$T>($path)';
}
