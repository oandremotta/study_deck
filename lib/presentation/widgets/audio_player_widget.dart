import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/extensions/context_extensions.dart';
import '../../domain/entities/card.dart' as domain;
import '../providers/audio_providers.dart';

/// UC201-UC205: Audio player widget for cards.
///
/// Displays audio controls for:
/// - TTS audio playback (UC201, UC202)
/// - Pronunciation playback (UC203)
/// - Speed control (UC205)
class CardAudioPlayer extends ConsumerWidget {
  final domain.Card card;
  final bool showTts;
  final bool showPronunciation;
  final bool compact;

  const CardAudioPlayer({
    super.key,
    required this.card,
    this.showTts = true,
    this.showPronunciation = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(audioPlayerNotifierProvider);
    final hasTts = card.hasAudio;
    final hasPronunciation = card.hasPronunciation;

    // Don't show if no audio available
    if (!hasTts && !hasPronunciation) {
      return const SizedBox.shrink();
    }

    if (compact) {
      return _buildCompactPlayer(context, ref, audioState, hasTts, hasPronunciation);
    }

    return _buildFullPlayer(context, ref, audioState, hasTts, hasPronunciation);
  }

  Widget _buildCompactPlayer(
    BuildContext context,
    WidgetRef ref,
    AudioPlayerState audioState,
    bool hasTts,
    bool hasPronunciation,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasTts && showTts)
          _AudioButton(
            icon: Icons.volume_up,
            label: 'Áudio',
            isPlaying: audioState.isPlaying &&
                audioState.currentCardId == card.id &&
                audioState.currentType == AudioType.tts,
            isLoading: audioState.isLoading &&
                audioState.currentCardId == card.id &&
                audioState.currentType == AudioType.tts,
            onPressed: () => _playTts(ref),
            compact: true,
          ),
        if (hasPronunciation && showPronunciation) ...[
          if (hasTts && showTts) const SizedBox(width: 8),
          _AudioButton(
            icon: Icons.mic,
            label: 'Pronúncia',
            isPlaying: audioState.isPlaying &&
                audioState.currentCardId == card.id &&
                audioState.currentType == AudioType.pronunciation,
            isLoading: audioState.isLoading &&
                audioState.currentCardId == card.id &&
                audioState.currentType == AudioType.pronunciation,
            onPressed: () => _playPronunciation(ref),
            compact: true,
          ),
        ],
      ],
    );
  }

  Widget _buildFullPlayer(
    BuildContext context,
    WidgetRef ref,
    AudioPlayerState audioState,
    bool hasTts,
    bool hasPronunciation,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.headphones,
                  size: 18,
                  color: context.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Áudio',
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (hasTts && showTts)
                  _AudioButton(
                    icon: Icons.volume_up,
                    label: 'Ouvir TTS',
                    isPlaying: audioState.isPlaying &&
                        audioState.currentCardId == card.id &&
                        audioState.currentType == AudioType.tts,
                    isLoading: audioState.isLoading &&
                        audioState.currentCardId == card.id &&
                        audioState.currentType == AudioType.tts,
                    onPressed: () => _playTts(ref),
                  ),
                if (hasPronunciation && showPronunciation)
                  _AudioButton(
                    icon: Icons.mic,
                    label: 'Minha pronúncia',
                    isPlaying: audioState.isPlaying &&
                        audioState.currentCardId == card.id &&
                        audioState.currentType == AudioType.pronunciation,
                    isLoading: audioState.isLoading &&
                        audioState.currentCardId == card.id &&
                        audioState.currentType == AudioType.pronunciation,
                    onPressed: () => _playPronunciation(ref),
                  ),
              ],
            ),
            if (audioState.error != null &&
                audioState.currentCardId == card.id) ...[
              const SizedBox(height: 8),
              Text(
                audioState.error!,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.error,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _playTts(WidgetRef ref) {
    if (card.audioUrl == null) return;
    ref.read(audioPlayerNotifierProvider.notifier).toggle(
          card.id,
          card.audioUrl!,
          AudioType.tts,
        );
  }

  void _playPronunciation(WidgetRef ref) {
    if (card.pronunciationUrl == null) return;
    ref.read(audioPlayerNotifierProvider.notifier).toggle(
          card.id,
          card.pronunciationUrl!,
          AudioType.pronunciation,
        );
  }
}

/// Individual audio button.
class _AudioButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isPlaying;
  final bool isLoading;
  final VoidCallback onPressed;
  final bool compact;

  const _AudioButton({
    required this.icon,
    required this.label,
    required this.isPlaying,
    required this.isLoading,
    required this.onPressed,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return IconButton(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                isPlaying ? Icons.stop : icon,
                color: isPlaying ? context.colorScheme.primary : null,
              ),
        tooltip: label,
      );
    }

    return FilledButton.tonalIcon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(
              isPlaying ? Icons.stop : icon,
              size: 18,
            ),
      label: Text(isPlaying ? 'Parar' : label),
    );
  }
}

/// UC205: Audio speed selector widget.
class AudioSpeedSelector extends ConsumerWidget {
  final ValueChanged<double>? onChanged;

  const AudioSpeedSelector({super.key, this.onChanged});

  static const List<double> speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(audioSettingsProvider);

    return settingsAsync.when(
      data: (settings) {
        return PopupMenuButton<double>(
          initialValue: settings.defaultSpeed,
          onSelected: (speed) async {
            await saveAudioSpeed(speed);
            ref.invalidate(audioSettingsProvider);
            onChanged?.call(speed);
          },
          itemBuilder: (context) => speeds.map((speed) {
            return PopupMenuItem(
              value: speed,
              child: Text('${speed}x'),
            );
          }).toList(),
          child: Chip(
            avatar: const Icon(Icons.speed, size: 16),
            label: Text('${settings.defaultSpeed}x'),
          ),
        );
      },
      loading: () => const Chip(
        avatar: Icon(Icons.speed, size: 16),
        label: Text('1.0x'),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
