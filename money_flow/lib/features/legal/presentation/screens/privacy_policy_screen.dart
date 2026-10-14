import 'package:flutter/material.dart';

import 'legal_document_screen.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalDocumentScreen(
      title: 'Política de Privacidad',
      sections: [
        LegalSection(
          heading: 'Información que organizas',
          body: 'MoneyFlow puede procesar la información que incorporas para administrar tus finanzas personales, por ejemplo movimientos, categorías, presupuestos y preferencias de la aplicación. Procura no incluir datos que no necesites para usar el servicio.',
        ),
        LegalSection(
          heading: 'Finalidad del uso',
          body: 'Usamos esa información para mostrar tus registros, cálculos y resúmenes dentro de la aplicación, así como para mantener sus funciones. Este borrador no describe condiciones definitivas de conservación, tratamiento o transferencia de datos.',
        ),
        LegalSection(
          heading: 'Tus controles',
          body: 'Puedes revisar la información que registras y ajustar las preferencias disponibles en la aplicación. Las opciones y derechos definitivos relacionados con tus datos se confirmarán después de la revisión jurídica correspondiente.',
        ),
        LegalSection(
          heading: 'Seguridad de tu cuenta',
          body: 'Protege tu dispositivo, tus credenciales y el acceso a tu cuenta. Las medidas y responsabilidades definitivas relacionadas con la seguridad se documentarán después de la revisión técnica y jurídica correspondiente.',
        ),
        LegalSection(
          heading: 'Consultas sobre privacidad',
          body: 'Para compartir una consulta sobre este borrador de privacidad, escribe a support@tatacode.com. Esta dirección atiende soporte mientras se completa la revisión jurídica del documento.',
        ),
      ],
    );
  }
}
