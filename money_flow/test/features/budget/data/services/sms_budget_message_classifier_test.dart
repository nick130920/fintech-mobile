import 'package:flutter_test/flutter_test.dart';
import 'package:money_flow/features/budget/data/services/sms_budget_message_classifier.dart';

void main() {
  const classifier = SmsBudgetMessageClassifier();

  group('retains transaction and ambiguous financial evidence', () {
    for (final body in [
      'Compraste por \$1.234.567,89 en TIENDA con tu tarjeta.',
      'Por \$45,200.00 realizaste una compra en MERCADO.',
      'Retiraste COP 80000 de tu cuenta.',
      'Pago realizado por 50.000 pesos.',
      'Transferencia enviada: débito de COP 20000.',
      'Recibiste una transferencia de \$300.000.',
      'A tu cuenta se acreditó una transferencia por 45000 COP.',
      'Abono recibido en cuenta: 120000 pesos.',
      'Compra aprobada por EUR 25.50.',
      'You paid USD 25.00 at STORE.',
      'Saldo disponible: \$50.000.',
      'Movimiento en tu cuenta. Revisa los detalles.',
      'Transferencia por 45000.',
      'Pago de nómina recibido.',
      'Tarjeta: compra 45200 en TIENDA.',
      'Compraste \$50.000. Si no reconoces esta compra llama al banco.',
      'Compraste \$50.000. Si no realizaste esta solicitud, llama al banco. No compartas tu código.',
      'Pago exitoso de \$50.000. No compartas tu código de seguridad.',
      'Transferencia recibida de \$80.000. Aprovecha nuestras promociones.',
      'Compraste \$30.000. Gana puntos en tu próxima compra.',
      'REALIZASTE una COMPRA por COP 45000. No compartas tu clave.',
      'Se debitaron 80000 pesos de tu cuenta. Aprovecha nuestras ofertas.',
      'Recibiste dinero: 20000 pesos. No compartas tu código.',
      'Compra por \$45.200,00 APROBADA. Promoción del mes disponible.',
      'Se debitó de tu cuenta COP 20000. No compartas tu clave.',
      'Hiciste una transferencia de 60000 pesos. Aprovecha nuestras ofertas.',
      'Tu pago de COP 50000 fue procesado. No compartas tu código.',
      'Compra por \$50.000 en TIENDA. No compartas tu código de seguridad.',
      'Transferencia por EUR 75. Nunca compartas tu clave.',
      'Tu pago de COP 70000 fue aprobado. No compartas tu código.',
    ]) {
      test(body, () => expect(classifier.shouldInclude(body), isTrue));
    }
  });

  group('excludes clear non-transaction messages', () {
    for (final body in <String?>[
      null,
      '',
      '   ',
      'Nos vemos mañana a las 8.',
      'Tu pedido 123456 llegará mañana.',
      'Tu código de verificación es 123456. No lo compartas.',
      'OTP 829102 para ingresar a tu cuenta.',
      'Clave dinámica para autorizar compra de \$50.000: 123456.',
      'No compartas tu código OTP 123456 para autorizar una compra de \$50.000.',
      'Nunca compartas tu clave 654321 para una compra.',
      'No compartas tu código para autorizar una transferencia.',
      'Tu código OTP 123456 para autorizar una compra de \$50.000. Si no realizaste esta solicitud, ignora este mensaje.',
      'Tu código OTP 123456 para autorizar una compra de \$50.000. Si no hiciste esta solicitud, ignora este mensaje.',
      'Tu código OTP 123456 para autorizar una compra de \$50.000. Si no reconoces esta solicitud, ignora este mensaje.',
      'Tu código OTP 123456 para autorizar una compra de \$50.000. Si realizaste esta solicitud, ingresa el código.',
      'Tu código OTP 123456 para autorizar una compra de \$50.000. Una vez aprobada, recibirás la confirmación.',
      'Tu código para autorizar un pago de EUR 75. Cuando sea aprobado recibirás un aviso.',
      'Tu OTP para un pago de COP 70000 que será aprobado al ingresar el código.',
      'Your verification code for a USD 25.00 payment is 123456.',
      'Tu código para el pago de \$50.000 es 123456.',
      'Recibiste un código para autorizar una compra por \$50.000.',
      'Código recibido para autorizar compra de \$50.000: 123456.',
      'Usa 123456 para iniciar sesión en tu cuenta con saldo \$50.000.',
      'Nuevo inicio de sesión en tu cuenta. Cambia tu contraseña.',
      'Alerta de seguridad: nunca compartas los datos de tu tarjeta.',
      'Compra hoy y gana \$20.000 de cashback.',
      'Compra hoy por solo \$50.000 en nuestra tienda.',
      'Promoción: pago con tarjeta por \$50.000 y recibe un regalo.',
      'Promoción: paga con tu tarjeta y recibe 20% de descuento.',
      'Tienes un crédito preaprobado de \$5.000.000. Solicítalo hoy.',
      'Aprovecha tu cupo disponible de \$1.000.000.',
    ]) {
      test('$body', () => expect(classifier.shouldInclude(body), isFalse));
    }
  });
}
