class ApplicationSubmittedModel {
  const ApplicationSubmittedModel({
    required this.title,
    required this.subtitle,
    required this.applicationIdLabel,
    required this.applicationIdValue,
    required this.verificationText,
    required this.buttonText,
    required this.accessibleNote,
    required this.needHelpPrefix,
    required this.contactSupportText,
  });

  final String title;
  final String subtitle;
  final String applicationIdLabel;
  final String applicationIdValue;
  final String verificationText;
  final String buttonText;
  final String accessibleNote;
  final String needHelpPrefix;
  final String contactSupportText;

  static const dummy = ApplicationSubmittedModel(
    title: 'Application Submitted!',
    subtitle: 'Your kitchen application is under review.',
    applicationIdLabel: 'Application ID',
    applicationIdValue: 'EAT-982467-NOL',
    verificationText: 'We\'ll verify your details and respond back within 24-48 hours.',
    buttonText: 'Go to Dashboard',
    accessibleNote: 'Dashboard is accessible after profile verification',
    needHelpPrefix: 'Need help? ',
    contactSupportText: 'Contact Support',
  );

  ApplicationSubmittedModel copyWith({
    String? title,
    String? subtitle,
    String? applicationIdLabel,
    String? applicationIdValue,
    String? verificationText,
    String? buttonText,
    String? accessibleNote,
    String? needHelpPrefix,
    String? contactSupportText,
  }) {
    return ApplicationSubmittedModel(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      applicationIdLabel: applicationIdLabel ?? this.applicationIdLabel,
      applicationIdValue: applicationIdValue ?? this.applicationIdValue,
      verificationText: verificationText ?? this.verificationText,
      buttonText: buttonText ?? this.buttonText,
      accessibleNote: accessibleNote ?? this.accessibleNote,
      needHelpPrefix: needHelpPrefix ?? this.needHelpPrefix,
      contactSupportText: contactSupportText ?? this.contactSupportText,
    );
  }
}

