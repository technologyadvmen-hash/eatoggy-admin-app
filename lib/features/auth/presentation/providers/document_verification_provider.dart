import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/document_verification_model.dart';
import '../../data/repositories/auth_repository.dart';

class DocumentVerificationState {
  const DocumentVerificationState({
    required this.data,
    required this.documents,
    this.isLoading = false,
    this.errorMessage,
  });

  final DocumentVerificationModel data;
  final List<DocumentItem> documents;
  final bool isLoading;
  final String? errorMessage;

  DocumentVerificationState copyWith({
    DocumentVerificationModel? data,
    List<DocumentItem>? documents,
    bool? isLoading,
    String? errorMessage,
  }) {
    return DocumentVerificationState(
      data: data ?? this.data,
      documents: documents ?? this.documents,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class DocumentVerificationNotifier
    extends Notifier<DocumentVerificationState> {
  final ImagePicker _picker = ImagePicker();
  final AuthRepository _authRepository = AuthRepository();

  @override
  DocumentVerificationState build() {
    const dummyModel = DocumentVerificationModel.dummy;
    return DocumentVerificationState(
      data: dummyModel,
      documents: dummyModel.defaultDocuments,
    );
  }

  Future<void> pickDocument(String docId, ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (image != null) {
        final updatedList = state.documents.map((doc) {
          if (doc.id == docId) {
            return doc.copyWith(
              isUploaded: true,
              filePath: image.path,
              fileType: image.name.split('.').last.toUpperCase(),
            );
          }
          return doc;
        }).toList();

        state = state.copyWith(documents: updatedList, errorMessage: null);
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to pick image: ${e.toString()}',
      );
    }
  }

  void removeDocument(String docId) {
    final updatedList = state.documents.map((doc) {
      if (doc.id == docId) {
        return doc.copyWith(
          isUploaded: false,
          filePath: null,
          fileType: null,
        );
      }
      return doc;
    }).toList();

    state = state.copyWith(documents: updatedList, errorMessage: null);
  }

  Future<bool> submitDocuments({
    required VoidCallback onSuccess,
    required ValueChanged<String> onError,
  }) async {
    final gstDoc = state.documents.cast<DocumentItem?>().firstWhere(
          (d) => d?.id == 'gst',
          orElse: () => null,
        );
    final fssaiDoc = state.documents.cast<DocumentItem?>().firstWhere(
          (d) => d?.id == 'fssai',
          orElse: () => null,
        );

    if (gstDoc?.filePath == null || !File(gstDoc!.filePath!).existsSync()) {
      const msg = 'Please upload your GST Certificate';
      state = state.copyWith(errorMessage: msg);
      onError(msg);
      return false;
    }

    if (fssaiDoc?.filePath == null || !File(fssaiDoc!.filePath!).existsSync()) {
      const msg = 'Please upload your FSSAI Food License';
      state = state.copyWith(errorMessage: msg);
      onError(msg);
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _authRepository.uploadBusinessDocs(
        gstCertificate: File(gstDoc.filePath!),
        foodLicense: File(fssaiDoc.filePath!),
      );

      state = state.copyWith(isLoading: false);
      onSuccess();
      return true;
    } catch (e) {
      final errorMsg = e.toString();
      state = state.copyWith(isLoading: false, errorMessage: errorMsg);
      onError(errorMsg);
      return false;
    }
  }
}

final documentVerificationProvider = NotifierProvider<
    DocumentVerificationNotifier, DocumentVerificationState>(
  DocumentVerificationNotifier.new,
);
