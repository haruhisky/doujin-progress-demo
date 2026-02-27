export interface LLMProvider {
  name: string;
  analyze(prompt: string, apiKey: string, model: string): Promise<string>;
}

export interface AnalysisResult {
  success: boolean;
  text: string;
  error?: string;
}
