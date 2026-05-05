import 'package:dartz/dartz.dart';
import 'package:ehbien_lotto_admin/core/errors/failure.dart';

typedef EitherFailure<T> = Either<Failure, T>;
typedef EitherVoid       = Either<Failure, void>;
typedef FirestoreStream<T> = Stream<T>;
