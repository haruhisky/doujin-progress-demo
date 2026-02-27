import { BaseLLMProvider } from './base';

export class OpenAIProvider extends BaseLLMProvider {
  name = 'openai';

  async analyze(prompt: string, apiKey: string, model: string): Promise<string> {
    const response = await this.httpPost(
      'https://api.openai.com/v1/chat/completions',
      { Authorization: `Bearer ${apiKey}` },
      {
        model: model || 'gpt-4o',
        messages: [
          { role: 'system', content: 'あなたは同人漫画制作の進捗管理アシスタントです。データに基づいて現実的な分析と提言を行ってください。' },
          { role: 'user', content: prompt },
        ],
        temperature: 0.3,
      }
    );
    const parsed = JSON.parse(response);
    return parsed.choices[0].message.content;
  }
}
