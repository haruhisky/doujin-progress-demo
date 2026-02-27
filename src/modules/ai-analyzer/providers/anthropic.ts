import { BaseLLMProvider } from './base';

export class AnthropicProvider extends BaseLLMProvider {
  name = 'anthropic';

  async analyze(prompt: string, apiKey: string, model: string): Promise<string> {
    const response = await this.httpPost(
      'https://api.anthropic.com/v1/messages',
      {
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
      },
      {
        model: model || 'claude-sonnet-4-20250514',
        max_tokens: 2048,
        system: 'あなたは同人漫画制作の進捗管理アシスタントです。データに基づいて現実的な分析と提言を行ってください。',
        messages: [
          { role: 'user', content: prompt },
        ],
      }
    );
    const parsed = JSON.parse(response);
    return parsed.content[0].text;
  }
}
