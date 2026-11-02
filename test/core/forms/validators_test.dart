import 'package:flutter_test/flutter_test.dart';
import 'package:template/core/forms/validators.dart';

void main() {
  test('required rejects null, empty and whitespace', () {
    final rule = Validators.required();
    expect(rule(null), isNotNull);
    expect(rule('   '), isNotNull);
    expect(rule('a'), isNull);
  });

  test('optional rules accept empty values', () {
    for (final rule in [
      Validators.email(),
      Validators.phone(),
      Validators.url(),
      Validators.numeric(),
      Validators.password(),
    ]) {
      expect(rule(''), isNull);
    }
  });

  test('email', () {
    final rule = Validators.email();
    expect(rule('a.b+c@mail.example.com'), isNull);
    for (final bad in ['a', 'a@', '@b.com', 'a@b', 'a b@c.com']) {
      expect(rule(bad), isNotNull, reason: bad);
    }
  });

  test('password names the first unmet requirement', () {
    final rule = Validators.password();
    expect(rule('Ab1'), contains('8'));
    expect(rule('abcdefg1'), contains('uppercase'));
    expect(rule('ABCDEFG1'), contains('lowercase'));
    expect(rule('Abcdefgh'), contains('number'));
    expect(rule('Abcdefg1'), isNull);
  });

  test('phone needs enough digits', () {
    final rule = Validators.phone();
    expect(rule('+1 (555) 000-1234'), isNull);
    expect(rule('-- -- -- --'), isNotNull);
  });

  test('name accepts international names', () {
    final rule = Validators.name();
    expect(rule("Renée O'Brien-Núñez"), isNull);
    expect(rule('রহিম'), isNull);
    expect(rule('Bob123'), isNotNull);
  });

  test('url requires http(s) and a host', () {
    final rule = Validators.url();
    expect(rule('https://example.com'), isNull);
    expect(rule('ftp://example.com'), isNotNull);
    expect(rule('example'), isNotNull);
  });

  test('range and match', () {
    expect(Validators.range(1, 5)('6'), isNotNull);
    expect(Validators.range(1, 5)('3'), isNull);
    expect(Validators.match(() => 'a')('b'), isNotNull);
    expect(Validators.match(() => 'a')('a'), isNull);
  });

  test('compose returns the first error', () {
    final rule = Validators.compose([Validators.required('first'), Validators.email('second')]);
    expect(rule(''), 'first');
    expect(rule('x'), 'second');
    expect(rule('x@y.co'), isNull);
  });

  test('password strength grows with complexity', () {
    expect(PasswordStrength.of(''), PasswordStrength.empty);
    expect(PasswordStrength.of('abc'), PasswordStrength.weak);
    expect(PasswordStrength.of('Abcdefg1!xyzq'), PasswordStrength.strong);
  });
}
