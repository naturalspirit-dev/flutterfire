// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_odm_example/movie.dart';
import 'package:cloud_firestore_odm_generator_integration_test/simple.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'common.dart';

void main() {
  group('DocumentReference', () {
    late FirebaseFirestore defaultFirestore;
    late FirebaseFirestore customFirestore;

    setUpAll(() async {
      defaultFirestore = FirebaseFirestore.instanceFor(
        app: await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: 'AIzaSyAHAsf51D0A407EklG1bs-5wA7EbyfNFg0',
            appId: '1:448618578101:ios:3a3c8ae9cb0b6408ac3efc',
            messagingSenderId: '448618578101',
            projectId: 'react-native-firebase-testing',
            authDomain: 'react-native-firebase-testing.firebaseapp.com',
            iosClientId:
                '448618578101-m53gtqfnqipj12pts10590l37npccd2r.apps.googleusercontent.com',
          ),
        ),
      );
      customFirestore = FirebaseFirestore.instanceFor(
        app: await Firebase.initializeApp(
          name: 'custom-document-app',
          options: FirebaseOptions(
            apiKey: defaultFirestore.app.options.apiKey,
            appId: defaultFirestore.app.options.appId,
            messagingSenderId: defaultFirestore.app.options.messagingSenderId,
            projectId: defaultFirestore.app.options.projectId,
          ),
        ),
      );
    });

    group('any document', () {
      test('delete', () async {
        final collection = await initializeTest(MovieCollectionReference());

        await collection.doc('123').set(createMovie(title: 'title'));

        expect(
          await collection.doc('123').get().then((e) => e.exists),
          true,
        );

        await collection.doc('123').delete();

        expect(
          await collection.doc('123').get().then((e) => e.exists),
          false,
        );
      });

      test('reference', () async {
        expect(
          MovieCollectionReference().doc('123').reference,
          isA<DocumentReference<Movie>>()
              .having((e) => e.path, 'path', 'firestore-example-app/123'),
        );

        expect(
          MovieCollectionReference().doc('123').comments.doc('456').reference,
          isA<DocumentReference<Comment>>().having(
            (e) => e.path,
            'path',
            'firestore-example-app/123/comments/456',
          ),
        );
      });

      group('get', () {
        test('supports const GetOptions', () async {
          final collection = await initializeTest(MovieCollectionReference());

          await collection.doc('123').set(createMovie(title: 'title'));

          expect(
            await collection
                .doc('123')
                .get(const GetOptions(source: Source.cache)),
            isA<MovieDocumentSnapshot>()
                .having((e) => e.data?.title, 'data.title', 'title')
                .having(
                  (e) => e.metadata.isFromCache,
                  'metadata.isFromCache',
                  true,
                ),
          );
        });
      });

      group('snapshots', () {
        test('calls listeners when value changes', () async {
          final collection = await initializeTest(MovieCollectionReference());

          final stream = StreamQueue(collection.doc('123').snapshots());

          expect(
            await stream.next,
            isA<MovieDocumentSnapshot>()
                .having((e) => e.exists, 'exists', false),
          );

          await collection.doc('123').set(createMovie(title: 'title'));

          expect(
            await stream.next,
            isA<MovieDocumentSnapshot>()
                .having((e) => e.exists, 'exists', true)
                .having((e) => e.data?.title, 'data.title', 'title'),
          );
        });
      });

      group('update', () {
        test('allows modifying only one property of an object', () async {
          final ref = await initializeTest(moviesRef);

          await ref.doc('123').set(
                Movie(
                  genre: [],
                  likes: 42,
                  poster: 'foo',
                  rated: 'good',
                  runtime: 'runtime',
                  title: 'title',
                  year: 0,
                ),
              );

          expect(
            await ref.doc('123').get().then((e) => e.data),
            isA<Movie>()
                .having((e) => e.genre, 'genre', isEmpty)
                .having((e) => e.likes, 'likes', 42)
                .having((e) => e.poster, 'poster', 'foo')
                .having((e) => e.rated, 'rated', 'good')
                .having((e) => e.runtime, 'runtime', 'runtime')
                .having((e) => e.title, 'title', 'title')
                .having((e) => e.year, 'year', 0),
          );

          await ref.doc('123').update(
            genre: ['genre'],
          );

          expect(
            await ref.doc('123').get().then((e) => e.data),
            isA<Movie>()
                .having((e) => e.genre, 'genre', ['genre'])
                .having((e) => e.likes, 'likes', 42)
                .having((e) => e.poster, 'poster', 'foo')
                .having((e) => e.rated, 'rated', 'good')
                .having((e) => e.runtime, 'runtime', 'runtime')
                .having((e) => e.title, 'title', 'title')
                .having((e) => e.year, 'year', 0),
          );
        });

        test('can set a property to null', () async {
          final ref = await initializeTest(moviesRef);

          await ref.doc('123').set(
                Movie(
                  genre: [],
                  likes: 42,
                  poster: 'foo',
                  rated: 'good',
                  runtime: 'runtime',
                  title: 'title',
                  year: 0,
                ),
              );

          expect(
            await ref.doc('123').get().then((e) => e.data),
            isA<Movie>()
                .having((e) => e.genre, 'genre', isEmpty)
                .having((e) => e.likes, 'likes', 42)
                .having((e) => e.poster, 'poster', 'foo')
                .having((e) => e.rated, 'rated', 'good')
                .having((e) => e.runtime, 'runtime', 'runtime')
                .having((e) => e.title, 'title', 'title')
                .having((e) => e.year, 'year', 0),
          );

          await ref.doc('123').update(
                // ignore: avoid_redundant_argument_values, false positive
                genre: null,
              );

          expect(
            await ref.doc('123').get().then((e) => e.data),
            isA<Movie>()
                .having((e) => e.genre, 'genre', null)
                .having((e) => e.likes, 'likes', 42)
                .having((e) => e.poster, 'poster', 'foo')
                .having((e) => e.rated, 'rated', 'good')
                .having((e) => e.runtime, 'runtime', 'runtime')
                .having((e) => e.title, 'title', 'title')
                .having((e) => e.year, 'year', 0),
          );
        });
      });

      test('metadata', () async {
        final collection = await initializeTest(MovieCollectionReference());

        final doc = collection.doc('123');
        await doc.set(createMovie(title: 'Foo'));

        final snap = await doc.get(const GetOptions(source: Source.server));

        expect(snap.metadata.isFromCache, false);

        final snap2 = await doc.get(const GetOptions(source: Source.cache));

        expect(snap2.metadata.isFromCache, true);
      });

      test('exists', () async {
        final collection = await initializeTest(MovieCollectionReference());

        await collection.doc('123').set(createMovie(title: 'Foo'));

        expect(
          await collection.doc().get().then((d) => d.exists),
          false,
        );
        expect(
          await collection.doc('123').get().then((d) => d.exists),
          true,
        );
      });
    });

    group('root document reference', () {
      test(
          'can make fromJson optional if model is annotated by JsonSerializable',
          () async {
        final collection = await initializeTest(optionalJsonRef);

        await collection.doc('123').set(OptionalJson(42));

        expect(
          await collection.doc('123').get().then((value) => value.data?.value),
          42,
        );
      });

      test(
          'if fromJson/toJson are specified, use them even if the model is annotated by JsonSerializable',
          () async {
        final collection = await initializeTest(mixedJsonRef);

        await collection.doc('123').set(MixedJson(42));

        final rawSnapshot = await FirebaseFirestore.instance
            .collection('root')
            .doc('123')
            .get();

        expect(rawSnapshot.data(), {'foo': 42});
        expect(
          await collection.doc('123').get().then((value) => value.data?.value),
          42,
        );
      });

      test('overrides ==', () {
        expect(
          MovieCollectionReference().doc('123'),
          MovieCollectionReference(defaultFirestore).doc('123'),
        );
        expect(
          MovieCollectionReference().doc('123'),
          isNot(MovieCollectionReference().doc('456')),
        );

        expect(
          MovieCollectionReference(customFirestore).doc('123'),
          isNot(MovieCollectionReference().doc('123')),
        );
        expect(
          MovieCollectionReference(customFirestore).doc('123'),
          MovieCollectionReference(customFirestore).doc('123'),
        );
      });
    });

    group('sub documentReference', () {
      test('overrides ==', () {
        expect(
          MovieCollectionReference().doc('123').comments.doc('123'),
          MovieCollectionReference(defaultFirestore)
              .doc('123')
              .comments
              .doc('123'),
        );
        expect(
          MovieCollectionReference().doc('123').comments.doc('123'),
          isNot(MovieCollectionReference().doc('456').comments.doc('123')),
        );
        expect(
          MovieCollectionReference().doc('123').comments.doc('123'),
          isNot(MovieCollectionReference().doc('123').comments.doc('456')),
        );

        expect(
          MovieCollectionReference(customFirestore)
              .doc('123')
              .comments
              .doc('123'),
          isNot(MovieCollectionReference().doc('123').comments.doc('123')),
        );
        expect(
          MovieCollectionReference(customFirestore)
              .doc('123')
              .comments
              .doc('123'),
          MovieCollectionReference(customFirestore)
              .doc('123')
              .comments
              .doc('123'),
        );
      });
    });
  });
}
