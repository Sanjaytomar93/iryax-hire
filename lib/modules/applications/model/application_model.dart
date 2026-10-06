import 'package:intl/intl.dart';

import '../../home/model/job_model.dart';

class ApplicationInterviewModel {
  final String subject;
  final String round;
  final String mode;
  final String address;
  final String link;
  final String interviewStatus;
  final String responseStatus;
  final String note;
  final DateTime? scheduledAt;

  const ApplicationInterviewModel({
    required this.subject,
    required this.round,
    required this.mode,
    required this.address,
    required this.link,
    required this.interviewStatus,
    required this.responseStatus,
    required this.note,
    required this.scheduledAt,
  });

  factory ApplicationInterviewModel.empty() {
    return const ApplicationInterviewModel(
      subject: '',
      round: '',
      mode: '',
      address: '',
      link: '',
      interviewStatus: '',
      responseStatus: '',
      note: '',
      scheduledAt: null,
    );
  }

  factory ApplicationInterviewModel.fromJson(
      Map<String, dynamic> json,
      ) {
    final Map<String, dynamic> nestedInterview =
    _findInterviewMap(json);

    final String subject = _firstNonEmpty([
      nestedInterview['subject'],
      nestedInterview['interviewSubject'],
      json['interviewSubject'],
    ]);

    final String round = _firstNonEmpty([
      nestedInterview['round'],
      nestedInterview['interviewRound'],
      nestedInterview['roundName'],
      nestedInterview['type'],
      nestedInterview['title'],
      json['interviewRound'],
      json['interviewType'],
      json['roundName'],
    ]);

    final String rawMode = _firstNonEmpty([
      nestedInterview['mode'],
      nestedInterview['interviewMode'],
      nestedInterview['meetingMode'],
      nestedInterview['locationType'],
      json['interviewMode'],
      json['meetingMode'],
    ]);

    final String interviewStatus = _firstNonEmpty([
      nestedInterview['interviewStatus'],
      nestedInterview['status'],
      json['interviewStatus'],
    ]);

    final String responseStatus = _firstNonEmpty([
      nestedInterview['responseStatus'],
      nestedInterview['candidateStatus'],
      nestedInterview['confirmationStatus'],
      nestedInterview['candidateInterviewStatus'],
      json['candidateInterviewStatus'],
      json['interviewResponseStatus'],
    ]);

    final String note = _firstNonEmpty([
      nestedInterview['note'],
      nestedInterview['candidateInterviewNote'],
      json['candidateInterviewNote'],
    ]);

    final DateTime? scheduledAt = _parseScheduledDate(
      interview: nestedInterview,
      root: json,
    );

    final String link = _firstNonEmpty([
      nestedInterview['link'],
      nestedInterview['meetingLink'],
      nestedInterview['interviewLink'],
      nestedInterview['meetLink'],
      nestedInterview['url'],
      json['interviewLink'],
      json['meetingLink'],
      json['meetLink'],
      json['meetingUrl'],
      json['interviewUrl'],
    ]);

    final String normalizedMode =
    rawMode.trim().toLowerCase();

    final bool knownOnlineMode =
        normalizedMode == 'online' ||
            normalizedMode == 'virtual' ||
            normalizedMode == 'remote';

    final bool knownOfflineMode =
        normalizedMode == 'offline' ||
            normalizedMode == 'onsite' ||
            normalizedMode == 'on site' ||
            normalizedMode == 'in person' ||
            normalizedMode == 'in-person';

    /*
     * The backend sometimes places the complete physical
     * interview venue inside interviewMode.
     */
    final bool modeContainsVenue =
        rawMode.isNotEmpty &&
            !knownOnlineMode &&
            !knownOfflineMode;

    String parsedMode = '';

    if (scheduledAt != null) {
      if (knownOnlineMode || link.isNotEmpty) {
        parsedMode = 'Online';
      } else {
        parsedMode = 'Offline';
      }
    }

    /*
     * Never use json['address'] here.
     *
     * Root address is the candidate's residential address,
     * not the interview venue.
     */
    final String explicitInterviewAddress =
    _firstNonEmpty([
      nestedInterview['address'],
      nestedInterview['venue'],
      nestedInterview['location'],
      nestedInterview['interviewAddress'],
      nestedInterview['interviewLocation'],
      json['interviewAddress'],
      json['interviewVenue'],
      json['interviewLocation'],
    ]);

    final String parsedAddress =
    scheduledAt == null
        ? ''
        : modeContainsVenue
        ? rawMode
        : explicitInterviewAddress;

    return ApplicationInterviewModel(
      subject: subject,
      round: round,
      mode: parsedMode,
      address: parsedAddress,
      link: scheduledAt != null ? link : '',
      interviewStatus: interviewStatus,
      responseStatus: responseStatus,
      note: note,
      scheduledAt: scheduledAt,
    );
  }

  static Map<String, dynamic> _findInterviewMap(
      Map<String, dynamic> json,
      ) {
    const List<String> possibleKeys = [
      'interview',
      'interviewDetails',
      'interviewSchedule',
      'scheduledInterview',
      'interviewData',
      'schedule',
    ];

    for (final String key in possibleKeys) {
      final dynamic value = json[key];

      if (value is Map) {
        return Map<String, dynamic>.from(value);
      }
    }

    final dynamic interviews = json['interviews'];

    if (interviews is List && interviews.isNotEmpty) {
      final dynamic lastInterview = interviews.last;

      if (lastInterview is Map) {
        return Map<String, dynamic>.from(
          lastInterview,
        );
      }
    }

    return <String, dynamic>{};
  }

  static DateTime? _parseScheduledDate({
    required Map<String, dynamic> interview,
    required Map<String, dynamic> root,
  }) {
    final String completeDateTime =
    _firstNonEmpty([
      interview['scheduledAt'],
      interview['scheduledDateTime'],
      interview['dateTime'],
      interview['interviewDateTime'],
      interview['startTime'],
      interview['scheduledFor'],
      interview['interviewTime'],
      root['interviewTime'],
      root['interviewScheduledAt'],
      root['scheduledInterviewAt'],
      root['interviewDateTime'],
      root['scheduledAt'],
    ]);

    final DateTime? completeParsed =
    _tryParseDate(completeDateTime);

    if (completeParsed != null) {
      return completeParsed;
    }

    final String date = _firstNonEmpty([
      interview['date'],
      interview['interviewDate'],
      interview['scheduledDate'],
      root['interviewDate'],
      root['scheduledDate'],
    ]);

    final String time = _firstNonEmpty([
      interview['time'],
      interview['scheduledTime'],
      root['scheduledTime'],
    ]);

    if (date.isEmpty) {
      return null;
    }

    if (time.isNotEmpty) {
      final DateTime? combined =
      _tryParseDate('${date}T$time');

      if (combined != null) {
        return combined;
      }

      final DateTime? displayFormat =
      _tryParseDisplayDate(
        '$date $time',
      );

      if (displayFormat != null) {
        return displayFormat;
      }
    }

    return _tryParseDate(date);
  }

  static DateTime? _tryParseDate(
      String value,
      ) {
    final String text = value.trim();

    if (text.isEmpty) {
      return null;
    }

    final DateTime? direct =
    DateTime.tryParse(text);

    if (direct != null) {
      return direct;
    }

    return _tryParseDisplayDate(text);
  }

  static DateTime? _tryParseDisplayDate(
      String value,
      ) {
    const List<String> formats = [
      'yyyy-MM-dd HH:mm',
      'yyyy-MM-dd hh:mm a',
      'dd/MM/yyyy hh:mm a',
      'dd/MM/yyyy HH:mm',
      'dd-MM-yyyy hh:mm a',
      'dd-MM-yyyy HH:mm',
    ];

    for (final String format in formats) {
      try {
        return DateFormat(format).parse(value);
      } catch (_) {
        // Try the next supported format.
      }
    }

    return null;
  }

  static String _firstNonEmpty(
      List<dynamic> values,
      ) {
    for (final dynamic value in values) {
      final String text =
          value?.toString().trim() ?? '';

      if (text.isNotEmpty &&
          text.toLowerCase() != 'null') {
        return text;
      }
    }

    return '';
  }

  /*
   * A valid interview schedule requires interviewTime.
   *
   * Candidate address, mode, or link alone must not
   * create an interview stage.
   */
  bool get hasSchedule {
    return scheduledAt != null;
  }

  bool get isInvited {
    return interviewStatus
        .trim()
        .toLowerCase()
        .contains('invited');
  }

  bool get isOnline {
    return mode.trim().toLowerCase() == 'online';
  }

  bool get isOffline {
    return hasSchedule && !isOnline;
  }

  bool get isConfirmed {
    return responseStatus
        .trim()
        .toLowerCase() ==
        'confirmed';
  }

  bool get isDeclined {
    return responseStatus
        .trim()
        .toLowerCase() ==
        'declined';
  }

  bool get canRespond {
    return hasSchedule &&
        !isConfirmed &&
        !isDeclined;
  }

  String get displayMode {
    if (!hasSchedule) {
      return '';
    }

    return isOnline ? 'Online' : 'Offline';
  }

  String get placeOrLink {
    if (!hasSchedule) {
      return '';
    }

    if (isOnline && link.trim().isNotEmpty) {
      return link.trim();
    }

    if (address.trim().isNotEmpty) {
      return address.trim();
    }

    return displayMode;
  }

  String get timelineTitle {
    final String normalizedRound =
    round.trim().toLowerCase();

    final String normalizedSubject =
    subject.trim().toLowerCase();

    if (normalizedRound.contains('hr') ||
        normalizedSubject.contains('hr round')) {
      return 'HR Round Interview';
    }

    if (normalizedRound.contains('technical') ||
        normalizedSubject.contains('technical')) {
      return 'Technical Interview';
    }

    if (normalizedRound.contains('screen') ||
        normalizedRound.contains('initial') ||
        normalizedSubject.contains('screening') ||
        normalizedSubject.contains('initial')) {
      return 'Initial Screening Interview';
    }

    /*
     * Backend currently sends a generic Interview tracker.
     * Map it to Technical Interview for the Figma flow.
     */
    return 'Technical Interview';
  }
}

class ApplicationDocumentHistoryModel {
  final String id;
  final String content;
  final String documentType;
  final String sentAt;
  final String attachmentPath;
  final String signedPath;
  final String signedAt;

  const ApplicationDocumentHistoryModel({
    required this.id,
    required this.content,
    required this.documentType,
    required this.sentAt,
    required this.attachmentPath,
    required this.signedPath,
    required this.signedAt,
  });

  factory ApplicationDocumentHistoryModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return ApplicationDocumentHistoryModel(
      id: (json['_id'] ?? json['id'])
          ?.toString() ??
          '',
      content:
      json['content']?.toString() ?? '',
      documentType:
      json['documentType']?.toString() ?? '',
      sentAt:
      json['sentAt']?.toString() ?? '',
      attachmentPath:
      json['attachmentPath']?.toString() ?? '',
      signedPath:
      json['signedPath']?.toString() ?? '',
      signedAt:
      json['signedAt']?.toString() ?? '',
    );
  }

  bool get isOfferDocument {
    final String value =
    documentType.trim().toLowerCase();

    return value.contains('offer') ||
        value.contains('appointment');
  }

  bool get hasValidDate {
    return DateTime.tryParse(sentAt) != null ||
        DateTime.tryParse(signedAt) != null;
  }

  DateTime get documentDate {
    final DateTime? sentDate =
    DateTime.tryParse(sentAt);

    if (sentDate != null) {
      return sentDate;
    }

    final DateTime? signedDate =
    DateTime.tryParse(signedAt);

    return signedDate ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }
}

class ApplicationModel {
  final String id;
  final String status;
  final String appliedAt;
  final String updatedAt;

  final JobModel job;
  final ApplicationInterviewModel interview;

  final String offerLetter;
  final String documentType;
  final String offerSentAt;
  final String adminAttachment;
  final String candidateAgreementsUpload;
  final String docReviewStatus;

  final List<ApplicationDocumentHistoryModel>
  documentHistory;

  const ApplicationModel({
    required this.id,
    required this.status,
    required this.appliedAt,
    required this.updatedAt,
    required this.job,
    required this.interview,
    required this.offerLetter,
    required this.documentType,
    required this.offerSentAt,
    required this.adminAttachment,
    required this.candidateAgreementsUpload,
    required this.docReviewStatus,
    required this.documentHistory,
  });

  factory ApplicationModel.fromJson(
      Map<String, dynamic> json,
      ) {
    final dynamic jobData =
        json['jobId'] ??
            json['job'] ??
            <String, dynamic>{};

    final dynamic historyData =
    json['documentHistory'];

    final List<ApplicationDocumentHistoryModel>
    history = historyData is List
        ? historyData
        .whereType<Map>()
        .map(
          (Map item) =>
          ApplicationDocumentHistoryModel
              .fromJson(
            Map<String, dynamic>.from(item),
          ),
    )
        .toList()
        : <ApplicationDocumentHistoryModel>[];

    return ApplicationModel(
      id: (json['_id'] ?? json['id'])
          ?.toString() ??
          '',
      status:
      json['status']?.toString() ?? 'Pending',
      appliedAt:
      (json['appliedAt'] ??
          json['createdAt'])
          ?.toString() ??
          '',
      updatedAt:
      json['updatedAt']?.toString() ?? '',
      job: jobData is Map
          ? JobModel.fromJson(
        Map<String, dynamic>.from(jobData),
      )
          : JobModel.fromJson(
        <String, dynamic>{},
      ),
      interview:
      ApplicationInterviewModel.fromJson(json),
      offerLetter:
      json['offerLetter']?.toString() ?? '',
      documentType:
      json['documentType']?.toString() ?? '',
      offerSentAt:
      json['offerSentAt']?.toString() ?? '',
      adminAttachment:
      json['adminAttachment']?.toString() ?? '',
      candidateAgreementsUpload:
      json['candidateAgreementsUpload']
          ?.toString() ??
          '',
      docReviewStatus:
      json['docReviewStatus']?.toString() ??
          'Not Sent',
      documentHistory: history,
    );
  }

  bool get hasInterview {
    return interview.hasSchedule;
  }

  bool get isInterviewSelected {
    return interview.hasSchedule;
  }

  bool get hasOfferLetter {
    if (offerLetter.trim().isNotEmpty) {
      return true;
    }

    if (adminAttachment.trim().isNotEmpty) {
      return true;
    }

    return documentHistory.any(
          (document) =>
      document.isOfferDocument &&
          (document.content.trim().isNotEmpty ||
              document.attachmentPath.trim().isNotEmpty ||
              document.signedPath.trim().isNotEmpty),
    );
  }
  String get cardStatus {
    final String value = _normalizeStatus(status);

    /*
     * Offer Letter takes priority over Selected or
     * previously confirmed interview status.
     */
    if (hasOfferLetter) {
      return 'Offer Letter';
    }

    if (interview.isConfirmed &&
        interview.hasSchedule) {
      return 'Interview Confirmed';
    }

    if (interview.isDeclined &&
        interview.hasSchedule) {
      return 'Interview Reschedule Requested';
    }

    if (interview.hasSchedule) {
      return 'Selected for Interview';
    }

    if (value.contains('offer')) {
      return 'Offer Letter';
    }

    if (value.contains('selected') ||
        value.contains('accepted') ||
        value.contains('hired')) {
      return 'Selected';
    }

    if (value.contains('shortlist')) {
      return 'Application Shortlisted';
    }

    if (value.contains('review')) {
      return 'Application Reviewed';
    }

    if (value.contains('reject')) {
      return 'Application Rejected';
    }

    if (value.contains('submitted') ||
        value.contains('pending') ||
        value.contains('applied')) {
      return 'Application Submitted';
    }

    return status.trim().isEmpty
        ? 'Application Submitted'
        : status.trim();
  }

  String get displayStatus => cardStatus;

  String get displayRole {
    final String value = job.role.trim();

    return value.isEmpty
        ? 'Not Available'
        : value;
  }

  String get displayDocumentType {
    final String type = documentType.trim();

    if (type.isNotEmpty) {
      return _formatDocumentType(type);
    }

    final ApplicationDocumentHistoryModel?
    document = latestOfferDocument;

    if (document != null &&
        document.documentType.trim().isNotEmpty) {
      return _formatDocumentType(
        document.documentType,
      );
    }

    return 'Offer Letter';
  }

  String get offerContent {
    final String value = offerLetter.trim();

    if (value.isNotEmpty && !_looksLikeFilePath(value)) {
      return value;
    }

    return latestOfferDocument?.content.trim() ?? '';
  }

  String get offerAttachmentPath {
    if (adminAttachment.trim().isNotEmpty) {
      return adminAttachment.trim();
    }

    final String directOffer = offerLetter.trim();

    if (directOffer.isNotEmpty &&
        _looksLikeFilePath(directOffer)) {
      return directOffer;
    }

    final ApplicationDocumentHistoryModel? document =
        latestOfferDocument;

    if (document != null &&
        document.attachmentPath.trim().isNotEmpty) {
      return document.attachmentPath.trim();
    }

    return '';
  }


  static bool _looksLikeFilePath(String value) {
    final String normalized =
        value.trim().toLowerCase().split('?').first;

    return normalized.endsWith('.pdf') ||
        normalized.endsWith('.doc') ||
        normalized.endsWith('.docx') ||
        normalized.endsWith('.jpg') ||
        normalized.endsWith('.jpeg') ||
        normalized.endsWith('.png') ||
        normalized.startsWith('uploads/') ||
        normalized.startsWith('/uploads/') ||
        normalized.startsWith('http://') ||
        normalized.startsWith('https://');
  }

  String get signedOfferPath {
    if (candidateAgreementsUpload
        .trim()
        .isNotEmpty) {
      return candidateAgreementsUpload.trim();
    }

    final List<ApplicationDocumentHistoryModel>
    signedDocuments =
    documentHistory.where(
          (ApplicationDocumentHistoryModel document) {
        return document.isOfferDocument &&
            document.signedPath.trim().isNotEmpty;
      },
    ).toList();

    if (signedDocuments.isEmpty) {
      return '';
    }

    signedDocuments.sort(
          (
          ApplicationDocumentHistoryModel first,
          ApplicationDocumentHistoryModel second,
          ) {
        return second.documentDate.compareTo(
          first.documentDate,
        );
      },
    );

    return signedDocuments.first.signedPath.trim();
  }

  bool get hasSignedOffer {
    return signedOfferPath.isNotEmpty;
  }

  ApplicationDocumentHistoryModel?
  get latestOfferDocument {
    final List<ApplicationDocumentHistoryModel>
    offerDocuments =
    documentHistory.where(
          (ApplicationDocumentHistoryModel document) {
        return document.isOfferDocument;
      },
    ).toList();

    if (offerDocuments.isEmpty) {
      return null;
    }

    offerDocuments.sort(
          (
          ApplicationDocumentHistoryModel first,
          ApplicationDocumentHistoryModel second,
          ) {
        return second.documentDate.compareTo(
          first.documentDate,
        );
      },
    );

    return offerDocuments.first;
  }

  DateTime? get offerIssueDate {
    final DateTime? sentDate =
    DateTime.tryParse(offerSentAt);

    if (sentDate != null) {
      return sentDate.toLocal();
    }

    final ApplicationDocumentHistoryModel?
    document = latestOfferDocument;

    if (document != null &&
        document.hasValidDate) {
      return document.documentDate.toLocal();
    }

    final DateTime? updateDate =
    DateTime.tryParse(updatedAt);

    if (updateDate != null) {
      return updateDate.toLocal();
    }

    final DateTime? appliedDate =
    DateTime.tryParse(appliedAt);

    return appliedDate?.toLocal();
  }

  String get formattedOfferDate {
    final DateTime? date = offerIssueDate;

    if (date == null) {
      return '--/--/----';
    }

    final String day =
    date.day.toString().padLeft(2, '0');

    final String month =
    date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  static String _normalizeStatus(
      String value,
      ) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .replaceAll(
      RegExp(r'\s+'),
      ' ',
    );
  }

  static String _formatDocumentType(
      String value,
      ) {
    final String normalized = value
        .trim()
        .toLowerCase()
        .replaceAll('_', ' ')
        .replaceAll('-', ' ');

    if (normalized == 'offer' ||
        normalized == 'offer letter' ||
        normalized == 'offerletter') {
      return 'Offer Letter';
    }

    if (normalized.contains('appointment')) {
      return 'Appointment Letter';
    }

    return value.trim();
  }


  String get offerFileSource {
    if (adminAttachment.trim().isNotEmpty) {
      return 'adminAttachment';
    }

    final ApplicationDocumentHistoryModel? document =
        latestOfferDocument;

    if (document != null &&
        document.attachmentPath.trim().isNotEmpty) {
      return 'documentHistory.attachmentPath';
    }

    if (offerLetter.trim().isNotEmpty) {
      return 'offerLetter text only';
    }

    return 'not available';
  }
}