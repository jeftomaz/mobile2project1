/// Formatação de datas em português, sem dependência do pacote `intl`.
class DateFormatPt {
  static const _months = [
    'janeiro',
    'fevereiro',
    'março',
    'abril',
    'maio',
    'junho',
    'julho',
    'agosto',
    'setembro',
    'outubro',
    'novembro',
    'dezembro',
  ];

  /// Ex.: "Junho de 2026" — usado nos cabeçalhos de mês do diário.
  static String monthYear(DateTime d) {
    final m = _months[d.month - 1];
    return '${m[0].toUpperCase()}${m.substring(1)} de ${d.year}';
  }

  /// Ex.: "3 de junho de 2026".
  static String longDate(DateTime d) =>
      '${d.day} de ${_months[d.month - 1]} de ${d.year}';

  /// Ex.: "03/06/2026".
  static String shortDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
