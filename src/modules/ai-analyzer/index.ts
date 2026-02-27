import { EventBus } from '../../core/event-bus';
import { AppModule } from '../../core/module-manager';
import { LLMProvider, AnalysisResult } from './types';
import { OpenAIProvider } from './providers/openai';
import { AnthropicProvider } from './providers/anthropic';
import { GoogleProvider } from './providers/google';
import { buildAnalysisPrompt } from './prompt-builder';
import { Project, ProgressSnapshot, ProgressRecord, AppSettings } from '../project-manager/types';
import { WorkMateSummary } from '../workmate-reader/types';

export class AIAnalyzer implements AppModule {
  readonly name = 'ai-analyzer';
  private providers: Map<string, LLMProvider> = new Map();

  async initialize(_eventBus: EventBus): Promise<void> {
    this.providers.set('openai', new OpenAIProvider());
    this.providers.set('anthropic', new AnthropicProvider());
    this.providers.set('google', new GoogleProvider());
  }

  async dispose(): Promise<void> {
    this.providers.clear();
  }

  async analyze(
    project: Project,
    snapshot: ProgressSnapshot,
    records: ProgressRecord[],
    workMateData: WorkMateSummary | null,
    settings: AppSettings
  ): Promise<AnalysisResult> {
    if (!settings.llmProvider || !settings.llmApiKey) {
      return {
        success: false,
        text: '',
        error: 'AI分析を使用するには、設定画面でLLMプロバイダーとAPIキーを設定してください。',
      };
    }

    const provider = this.providers.get(settings.llmProvider);
    if (!provider) {
      return {
        success: false,
        text: '',
        error: `不明なLLMプロバイダー: ${settings.llmProvider}`,
      };
    }

    const prompt = buildAnalysisPrompt(project, snapshot, records, workMateData);

    try {
      const text = await provider.analyze(prompt, settings.llmApiKey, settings.llmModel);
      return { success: true, text };
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      return {
        success: false,
        text: '',
        error: `AI分析中にエラーが発生しました: ${message}`,
      };
    }
  }
}
