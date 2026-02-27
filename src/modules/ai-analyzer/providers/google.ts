import { BaseLLMProvider } from './base';

export class GoogleProvider extends BaseLLMProvider {
  name = 'google';

  async analyze(prompt: string, apiKey: string, model: string): Promise<string> {
    const modelId = model || 'gemini-2.0-flash';
    const response = await this.httpPost(
      `https://generativelanguage.googleapis.com/v1beta/models/${modelId}:generateContent?key=${apiKey}`,
      {},
      {
        systemInstruction: {
          parts: [{ text: 'あなたは同人漫画制作の進捗管理アシスタントです。データに基づいて現実的な分析と提言を行ってください。' }],
        },
        contents: [
          { role: 'user', parts: [{ text: prompt }] },
        ],
        generationConfig: { temperature: 0.3 },
      }
    );
    const parsed = JSON.parse(response);
    return parsed.candidates[0].content.parts[0].text;
  }
}
