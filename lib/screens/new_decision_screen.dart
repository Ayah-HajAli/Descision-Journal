import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../data/store.dart';
import '../models/decision.dart';
import '../theme/app_theme.dart';
import '../widgets/video_preview_player.dart';

class NewDecisionScreen extends StatefulWidget {
  final DecisionStore store;
  const NewDecisionScreen({super.key, required this.store});

  @override
  State<NewDecisionScreen> createState() => _NewDecisionScreenState();
}

class _NewDecisionScreenState extends State<NewDecisionScreen> {
  final _titleController = TextEditingController();
  final _predictionController = TextEditingController();
  DecisionCategory _category = DecisionCategory.career;
  double _confidence = 65;
  DateTime _revealDate = DateTime.now().add(const Duration(days: 30));
  String? _videoPath;
  bool _recording = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_onFieldChanged);
    _predictionController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() => setState(() {});

  @override
  void dispose() {
    _titleController.removeListener(_onFieldChanged);
    _predictionController.removeListener(_onFieldChanged);
    _titleController.dispose();
    _predictionController.dispose();
    super.dispose();
  }

  bool get _canSave =>
      _titleController.text.trim().isNotEmpty &&
      _predictionController.text.trim().isNotEmpty;

  /// image_picker's live camera capture only has a real implementation on
  /// iOS and Android. On macOS/Windows/Linux/web there's no sandboxed
  /// camera entitlement wired up, so calling ImageSource.camera there
  /// doesn't fail gracefully — it can crash the whole process. We detect
  /// that up front and fall back to picking an existing video file
  /// instead, so testing on desktop never crashes the app.
  bool get _canUseLiveCamera =>
      !kIsWeb && (Platform.isIOS || Platform.isAndroid);

  void _save() {
    widget.store.addDecision(
      Decision(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        category: _category,
        prediction: _predictionController.text.trim(),
        confidence: _confidence.round(),
        createdAt: DateTime.now(),
        revealDate: _revealDate,
        videoPath: _videoPath,
      ),
    );
    Navigator.of(context).pop();
  }

  Future<void> _recordVideo() async {
    setState(() => _recording = true);
    try {
      final XFile? file = await _picker.pickVideo(
        source: _canUseLiveCamera ? ImageSource.camera : ImageSource.gallery,
        maxDuration: const Duration(seconds: 90),
        preferredCameraDevice: CameraDevice.front,
      );
      if (file != null) {
        setState(() => _videoPath = file.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_canUseLiveCamera
                ? "Couldn't open the camera: $e"
                : "Couldn't open the file picker: $e"),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _recording = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _revealDate,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) setState(() => _revealDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.violet,
      appBar: AppBar(
        backgroundColor: AppColors.violet,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.ink),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Seal a decision', style: theme.textTheme.titleLarge),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            Text(
              "Once you save this, your prediction is locked until the reveal date. No editing.",
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: AppColors.ink.withOpacity(0.7)),
            ),
            const SizedBox(height: 24),
            _Label('THE DECISION'),
            _WhiteField(
              controller: _titleController,
              hint: 'e.g. Take the new job offer',
              maxLines: 1,
            ),
            const SizedBox(height: 20),
            _Label('CATEGORY'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: DecisionCategory.values.map((c) {
                final selected = c == _category;
                return GestureDetector(
                  onTap: () => setState(() => _category = c),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.ink : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      c.label,
                      style: TextStyle(
                        color: selected ? AppColors.cream : AppColors.ink,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            _Label('WHAT DO YOU BELIEVE WILL HAPPEN?'),
            _WhiteField(
              controller: _predictionController,
              hint:
                  "Be specific. What do you think will happen, and why? Future you will compare this to reality.",
              maxLines: 5,
            ),
            const SizedBox(height: 20),
            _Label('HOW SURE ARE YOU? ${_confidence.round()}%'),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.ink,
                inactiveTrackColor: Colors.white,
                thumbColor: AppColors.ink,
                overlayColor: AppColors.ink.withOpacity(0.1),
              ),
              child: Slider(
                value: _confidence,
                min: 0,
                max: 100,
                divisions: 20,
                onChanged: (v) => setState(() => _confidence = v),
              ),
            ),
            const SizedBox(height: 12),
            _Label('RECORD YOURSELF MAKING THIS DECISION (OPTIONAL)'),
            _VideoRecorderField(
              videoPath: _videoPath,
              recording: _recording,
              canUseLiveCamera: _canUseLiveCamera,
              onRecord: _recordVideo,
              onRemove: () => setState(() => _videoPath = null),
            ),
            const SizedBox(height: 20),
            _Label('WHEN SHOULD THIS UNLOCK?'),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 18),
                    const SizedBox(width: 10),
                    Text(
                      DateFormat('EEEE, MMM d, yyyy').format(_revealDate),
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _canSave ? _save : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.ink,
                  disabledBackgroundColor: AppColors.ink.withOpacity(0.3),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_rounded, size: 18, color: AppColors.cream),
                    const SizedBox(width: 8),
                    Text(
                      'Seal it',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(color: AppColors.cream),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoRecorderField extends StatelessWidget {
  final String? videoPath;
  final bool recording;
  final bool canUseLiveCamera;
  final VoidCallback onRecord;
  final VoidCallback onRemove;

  const _VideoRecorderField({
    required this.videoPath,
    required this.recording,
    required this.canUseLiveCamera,
    required this.onRecord,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (videoPath != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          VideoPreviewPlayer(path: videoPath!),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: recording ? null : onRecord,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.ink,
                    side: BorderSide(color: AppColors.ink.withOpacity(0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Re-record'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onRemove,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.coral,
                    side: const BorderSide(color: AppColors.coral),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  label: const Text('Remove'),
                ),
              ),
            ],
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: recording ? null : onRecord,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.ink.withOpacity(0.15),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: AppColors.ink,
                shape: BoxShape.circle,
              ),
              child: recording
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: CircularProgressIndicator(
                        color: AppColors.cream,
                        strokeWidth: 2.2,
                      ),
                    )
                  : Icon(
                      canUseLiveCamera
                          ? Icons.videocam_rounded
                          : Icons.video_file_rounded,
                      color: AppColors.cream,
                      size: 22,
                    ),
            ),
            const SizedBox(height: 10),
            Text(
              recording
                  ? (canUseLiveCamera ? 'Opening camera…' : 'Opening file picker…')
                  : (canUseLiveCamera
                      ? 'Tap to record a short video'
                      : 'Tap to choose a video file'),
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
            ),
            const SizedBox(height: 4),
            Text(
              canUseLiveCamera
                  ? "Say why you're deciding this, out loud — it'll be sealed with the text."
                  : "Live camera recording works on iOS/Android. On desktop, pick an existing clip instead.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.ink.withOpacity(0.55)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
          color: AppColors.ink.withOpacity(0.6),
        ),
      ),
    );
  }
}

class _WhiteField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;

  const _WhiteField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.ink.withOpacity(0.35)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
