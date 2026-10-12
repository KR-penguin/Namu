enum AiResponseLocale {
  ko('ko'),
  en('en'),
  ja('ja'),
  zhHans('zh-Hans'),
  es('es');

  const AiResponseLocale(this.wireTag);

  final String wireTag;
}
