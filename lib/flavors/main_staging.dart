import '../app/bootstrap.dart';
import '../config/environment.dart';

Future<void> main() async {
  await bootstrap(Environment.staging);
}
