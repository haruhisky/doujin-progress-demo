import * as https from 'https';
import { LLMProvider } from '../types';

export abstract class BaseLLMProvider implements LLMProvider {
  abstract name: string;

  abstract analyze(prompt: string, apiKey: string, model: string): Promise<string>;

  protected httpPost(url: string, headers: Record<string, string>, body: object): Promise<string> {
    return new Promise((resolve, reject) => {
      const urlObj = new URL(url);
      const data = JSON.stringify(body);

      const req = https.request(
        {
          hostname: urlObj.hostname,
          port: 443,
          path: urlObj.pathname,
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Content-Length': Buffer.byteLength(data),
            ...headers,
          },
        },
        (res) => {
          let responseData = '';
          res.on('data', (chunk) => (responseData += chunk));
          res.on('end', () => {
            if (res.statusCode && res.statusCode >= 200 && res.statusCode < 300) {
              resolve(responseData);
            } else {
              reject(new Error(`HTTP ${res.statusCode}: ${responseData}`));
            }
          });
        }
      );

      req.on('error', reject);
      req.write(data);
      req.end();
    });
  }
}
