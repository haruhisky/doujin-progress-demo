import React, { useState, useEffect } from 'react';
import '../styles/settings.css';

const PROVIDERS = [
  { value: '', label: '未設定' },
  { value: 'openai', label: 'OpenAI (GPT-4o)' },
  { value: 'anthropic', label: 'Anthropic (Claude)' },
  { value: 'google', label: 'Google (Gemini)' },
];

const DEFAULT_MODELS = {
  openai: 'gpt-4o',
  anthropic: 'claude-sonnet-4-20250514',
  google: 'gemini-2.0-flash',
};

export default function SettingsView({ onBack }) {
  const [settings, setSettings] = useState(null);
  const [saving, setSaving] = useState(false);
  const [workMateAvailable, setWorkMateAvailable] = useState(false);

  useEffect(() => {
    Promise.all([
      window.electronAPI.getSettings(),
      window.electronAPI.isWorkMateAvailable(),
    ]).then(([s, available]) => {
      setSettings(s);
      setWorkMateAvailable(available);
    });
  }, []);

  if (!settings) return <div className="loading">読み込み中...</div>;

  const handleChange = (field, value) => {
    const updated = { ...settings, [field]: value };
    if (field === 'llmProvider' && value) {
      updated.llmModel = DEFAULT_MODELS[value] || '';
    }
    setSettings(updated);
  };

  const handleSave = async () => {
    setSaving(true);
    try {
      await window.electronAPI.saveSettings(settings);
    } catch (err) {
      console.error('Failed to save settings:', err);
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="settings-view">
      <div className="settings-header">
        <button className="btn btn-back" onClick={onBack}>← 戻る</button>
        <h2>設定</h2>
      </div>

      <section className="settings-section">
        <h3>Work Mate連携</h3>
        <div className="form-group">
          <label>Work Mateデータフォルダ</label>
          <input
            type="text"
            value={settings.workMateDataDir}
            onChange={(e) => handleChange('workMateDataDir', e.target.value)}
            placeholder="%APPDATA%/WorkMate/sessions"
          />
          <div className={`status-badge ${workMateAvailable ? 'status-ok' : 'status-warn'}`}>
            {workMateAvailable ? 'Work Mateのデータを検出しました' : 'Work Mateのデータが見つかりません'}
          </div>
        </div>
      </section>

      <section className="settings-section">
        <h3>AI分析設定</h3>
        <div className="form-group">
          <label>LLMプロバイダー</label>
          <select
            value={settings.llmProvider || ''}
            onChange={(e) => handleChange('llmProvider', e.target.value || null)}
          >
            {PROVIDERS.map(p => (
              <option key={p.value} value={p.value}>{p.label}</option>
            ))}
          </select>
        </div>

        {settings.llmProvider && (
          <>
            <div className="form-group">
              <label>APIキー</label>
              <input
                type="password"
                value={settings.llmApiKey}
                onChange={(e) => handleChange('llmApiKey', e.target.value)}
                placeholder="sk-..."
              />
            </div>
            <div className="form-group">
              <label>モデル</label>
              <input
                type="text"
                value={settings.llmModel}
                onChange={(e) => handleChange('llmModel', e.target.value)}
                placeholder={DEFAULT_MODELS[settings.llmProvider] || ''}
              />
            </div>
          </>
        )}
      </section>

      <div className="form-actions">
        <button className="btn btn-primary" onClick={handleSave} disabled={saving}>
          {saving ? '保存中...' : '設定を保存'}
        </button>
      </div>
    </div>
  );
}
