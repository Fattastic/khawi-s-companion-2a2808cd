List<String> quickReplyTemplates({required bool isRtl}) {
  if (isRtl) {
    return const [
      'أنا قريب من نقطة الالتقاء',
      'وصلت الآن',
      'تقدر تحدد موقعك بدقة؟',
      'بتأخر 5 دقائق',
      'شكرًا، في الطريق',
    ];
  }

  return const [
    'I am near the pickup point',
    'I just arrived',
    'Can you share your exact location?',
    'Running 5 minutes late',
    'Thanks, on my way',
  ];
}
