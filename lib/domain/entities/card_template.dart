import 'package:equatable/equatable.dart';

/// UC195-UC200: Card template types for structured creation.
///
/// Templates provide predefined field structures to guide card creation:
/// - Definition: Concept-based cards with term definitions
/// - QandA: Question and answer format
/// - Cloze: Fill-in-the-blank style
/// - TrueFalse: True/false assertion cards
enum CardTemplateType {
  /// UC196: Definition template - "O que é X?"
  definition,

  /// UC197: Q&A template - Open question format
  qAndA,

  /// UC198: Cloze template - Fill in the blank "_____"
  cloze,

  /// UC199: True/False template - Assertion verification
  trueFalse,
}

extension CardTemplateTypeExtension on CardTemplateType {
  /// Display name in Portuguese.
  String get displayName {
    switch (this) {
      case CardTemplateType.definition:
        return 'Definição';
      case CardTemplateType.qAndA:
        return 'Pergunta e Resposta';
      case CardTemplateType.cloze:
        return 'Lacuna (Cloze)';
      case CardTemplateType.trueFalse:
        return 'Verdadeiro ou Falso';
    }
  }

  /// Short description of the template.
  String get description {
    switch (this) {
      case CardTemplateType.definition:
        return 'O que é [termo]? Define conceitos e vocabulário.';
      case CardTemplateType.qAndA:
        return 'Formato aberto de pergunta e resposta.';
      case CardTemplateType.cloze:
        return 'Complete: "O _____ é responsável por..."';
      case CardTemplateType.trueFalse:
        return 'Afirmação para classificar como V ou F.';
    }
  }

  /// Icon for the template.
  String get iconName {
    switch (this) {
      case CardTemplateType.definition:
        return 'book';
      case CardTemplateType.qAndA:
        return 'question_answer';
      case CardTemplateType.cloze:
        return 'text_fields';
      case CardTemplateType.trueFalse:
        return 'check_circle';
    }
  }

  /// Placeholder for the question field.
  String get questionPlaceholder {
    switch (this) {
      case CardTemplateType.definition:
        return 'O que é [termo]?';
      case CardTemplateType.qAndA:
        return 'Qual/Como/Por que...?';
      case CardTemplateType.cloze:
        return 'O _____ é responsável por...';
      case CardTemplateType.trueFalse:
        return '[Afirmação] (Verdadeiro ou Falso?)';
    }
  }

  /// Placeholder for the summary field.
  String get summaryPlaceholder {
    switch (this) {
      case CardTemplateType.definition:
        return 'Definição curta e direta do termo';
      case CardTemplateType.qAndA:
        return 'Resposta curta e objetiva';
      case CardTemplateType.cloze:
        return 'Palavra ou frase que completa a lacuna';
      case CardTemplateType.trueFalse:
        return 'Verdadeiro / Falso + breve justificativa';
    }
  }

  /// Placeholder for the key phrase field.
  String get keyPhrasePlaceholder {
    switch (this) {
      case CardTemplateType.definition:
        return '[Termo] é [definição essencial]';
      case CardTemplateType.qAndA:
        return 'Frase que resume a resposta';
      case CardTemplateType.cloze:
        return 'A resposta correta é [termo]';
      case CardTemplateType.trueFalse:
        return 'É [verdadeiro/falso] porque...';
    }
  }

  /// Example question for this template.
  String get exampleQuestion {
    switch (this) {
      case CardTemplateType.definition:
        return 'O que é mitocôndria?';
      case CardTemplateType.qAndA:
        return 'Qual a função principal do coração?';
      case CardTemplateType.cloze:
        return 'O _____ é a maior glândula do corpo humano.';
      case CardTemplateType.trueFalse:
        return 'A Terra é o terceiro planeta do sistema solar.';
    }
  }

  /// Example summary for this template.
  String get exampleSummary {
    switch (this) {
      case CardTemplateType.definition:
        return 'Organela responsável pela produção de energia celular (ATP).';
      case CardTemplateType.qAndA:
        return 'Bombear sangue para todo o corpo através do sistema circulatório.';
      case CardTemplateType.cloze:
        return 'Fígado';
      case CardTemplateType.trueFalse:
        return 'Verdadeiro. Mercúrio e Vênus estão mais próximos do Sol.';
    }
  }

  /// Example key phrase for this template.
  String get exampleKeyPhrase {
    switch (this) {
      case CardTemplateType.definition:
        return 'Mitocôndria é a usina de energia da célula.';
      case CardTemplateType.qAndA:
        return 'O coração bombeia sangue para todo o corpo.';
      case CardTemplateType.cloze:
        return 'O fígado é a maior glândula do corpo.';
      case CardTemplateType.trueFalse:
        return 'Terra é o 3º planeta, após Mercúrio e Vênus.';
    }
  }
}

/// UC200: Template suggestion based on content analysis.
class TemplateSuggestion extends Equatable {
  final CardTemplateType suggestedTemplate;
  final double confidence;
  final String reason;

  const TemplateSuggestion({
    required this.suggestedTemplate,
    required this.confidence,
    required this.reason,
  });

  @override
  List<Object?> get props => [suggestedTemplate, confidence, reason];
}

/// UC200: Suggests the best template based on content patterns.
TemplateSuggestion suggestTemplate(String content) {
  final lowerContent = content.toLowerCase().trim();

  // Check for cloze pattern (underscores or blanks)
  if (lowerContent.contains('_____') ||
      lowerContent.contains('____') ||
      lowerContent.contains('[...]') ||
      lowerContent.contains('(...)')) {
    return const TemplateSuggestion(
      suggestedTemplate: CardTemplateType.cloze,
      confidence: 0.95,
      reason: 'Detectada lacuna para preenchimento.',
    );
  }

  // Check for true/false patterns
  if (lowerContent.contains('verdadeiro ou falso') ||
      lowerContent.contains('v ou f') ||
      lowerContent.startsWith('é verdade que') ||
      lowerContent.startsWith('é correto afirmar')) {
    return const TemplateSuggestion(
      suggestedTemplate: CardTemplateType.trueFalse,
      confidence: 0.90,
      reason: 'Detectado padrão de afirmação verdadeiro/falso.',
    );
  }

  // Check for definition patterns
  if (lowerContent.startsWith('o que é') ||
      lowerContent.startsWith('o que são') ||
      lowerContent.startsWith('defina') ||
      lowerContent.startsWith('definição de') ||
      lowerContent.contains('significa') ||
      lowerContent.contains('conceito de')) {
    return const TemplateSuggestion(
      suggestedTemplate: CardTemplateType.definition,
      confidence: 0.85,
      reason: 'Detectado padrão de definição de conceito.',
    );
  }

  // Check for Q&A patterns (general questions)
  if (lowerContent.startsWith('qual') ||
      lowerContent.startsWith('quais') ||
      lowerContent.startsWith('como') ||
      lowerContent.startsWith('por que') ||
      lowerContent.startsWith('quando') ||
      lowerContent.startsWith('onde') ||
      lowerContent.startsWith('quem') ||
      lowerContent.endsWith('?')) {
    return const TemplateSuggestion(
      suggestedTemplate: CardTemplateType.qAndA,
      confidence: 0.80,
      reason: 'Detectada pergunta aberta.',
    );
  }

  // Default to Q&A for unknown patterns
  return const TemplateSuggestion(
    suggestedTemplate: CardTemplateType.qAndA,
    confidence: 0.50,
    reason: 'Formato padrão de pergunta e resposta.',
  );
}

/// Validates if content follows the expected template pattern.
class TemplateValidation {
  final bool isValid;
  final String? warning;
  final String? suggestion;

  const TemplateValidation({
    required this.isValid,
    this.warning,
    this.suggestion,
  });

  static TemplateValidation validate(CardTemplateType template, String question) {
    final lowerQuestion = question.toLowerCase().trim();

    switch (template) {
      case CardTemplateType.definition:
        if (!lowerQuestion.startsWith('o que') &&
            !lowerQuestion.startsWith('defina') &&
            !lowerQuestion.contains('significa')) {
          return TemplateValidation(
            isValid: true,
            warning: 'Dica: Perguntas de definição geralmente começam com "O que é..."',
            suggestion: 'O que é ${lowerQuestion.replaceAll('?', '')}?',
          );
        }
        break;

      case CardTemplateType.cloze:
        if (!question.contains('_____') &&
            !question.contains('____') &&
            !question.contains('[...]')) {
          return const TemplateValidation(
            isValid: false,
            warning: 'Cards do tipo lacuna precisam ter _____ onde a resposta vai.',
            suggestion: null,
          );
        }
        break;

      case CardTemplateType.trueFalse:
        if (lowerQuestion.endsWith('?')) {
          return TemplateValidation(
            isValid: true,
            warning: 'Dica: Cards V/F funcionam melhor como afirmações, não perguntas.',
            suggestion: question.replaceAll('?', '.'),
          );
        }
        break;

      case CardTemplateType.qAndA:
        // Q&A is flexible, no specific validation
        break;
    }

    return const TemplateValidation(isValid: true);
  }
}
