import 'package:flutter/material.dart';

import 'legal_document_screen.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalDocumentScreen(
      title: 'Términos de Servicio',
      sections: [
        LegalSection(
          heading: 'Uso de MoneyFlow',
          body: 'MoneyFlow te ayuda a organizar información financiera personal, como ingresos, gastos, presupuestos y metas. Usa la aplicación de manera responsable y proporciona información precisa para que las funciones puedan ofrecerte resultados útiles.',
        ),
        LegalSection(
          heading: 'Tus decisiones financieras',
          body: 'La información mostrada por MoneyFlow sirve como apoyo para tu organización personal. No constituye asesoramiento financiero, contable, fiscal ni legal. Las decisiones que tomes con base en esta información son exclusivamente tuyas.',
        ),
        LegalSection(
          heading: 'Cuenta y seguridad',
          body: 'Eres responsable de proteger las credenciales de tu cuenta y de avisarnos si detectas un uso no autorizado. No compartas tu contraseña ni permitas que otras personas accedan a tu información desde dispositivos que no controles.',
        ),
        LegalSection(
          heading: 'Disponibilidad y cambios',
          body: 'Podemos ajustar, mejorar o retirar funciones para mantener y evolucionar la aplicación. Cuando estos términos estén revisados y vigentes, comunicaremos las condiciones aplicables y cualquier cambio relevante de forma clara.',
        ),
        LegalSection(
          heading: 'Contacto',
          body: 'Si tienes preguntas sobre este borrador o sobre el uso de la aplicación, puedes escribir a support@tatacode.com.',
        ),
      ],
    );
  }
}
