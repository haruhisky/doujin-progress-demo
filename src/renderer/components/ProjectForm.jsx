import React, { useState, useEffect } from 'react';
import DatePicker from './common/DatePicker';

const DEFAULT_PHASES = [
  { label: 'ネーム', folderName: 'ネーム', trackingMethod: 'manual', filePatterns: ['*.png', '*.jpg', '*.jpeg'], order: 0 },
  { label: '下書き', folderName: '下書き', trackingMethod: 'folder', filePatterns: ['*.psd', '*.clip', '*.png'], order: 1 },
  { label: 'ペン入れ', folderName: 'ペン入れ', trackingMethod: 'folder', filePatterns: ['*.psd', '*.clip', '*.png'], order: 2 },
  { label: '仕上げ', folderName: '仕上げ', trackingMethod: 'folder', filePatterns: ['*.psd', '*.clip', '*.png'], order: 3 },
];

export default function ProjectForm({ projectId, onSaved, onCancel }) {
  const isEdit = !!projectId;
  const [name, setName] = useState('');
  const [totalPages, setTotalPages] = useState(16);
  const [deadline, setDeadline] = useState(null);
  const [rootFolder, setRootFolder] = useState('');
  const [phases, setPhases] = useState(DEFAULT_PHASES);
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    if (isEdit) {
      window.electronAPI.getProject(projectId).then(project => {
        if (project) {
          setName(project.name);
          setTotalPages(project.totalPages);
          setDeadline(project.deadline ? project.deadline.split('T')[0] : null);
          setRootFolder(project.rootFolder);
          setPhases(project.phases);
        }
      });
    } else {
      window.electronAPI.getSettings().then(settings => {
        if (settings.defaultPhases && settings.defaultPhases.length > 0) {
          setPhases(settings.defaultPhases);
        }
      });
    }
  }, [projectId, isEdit]);

  const handleSelectFolder = async () => {
    const folder = await window.electronAPI.selectFolder();
    if (folder) setRootFolder(folder);
  };

  const handlePhaseChange = (index, field, value) => {
    const updated = [...phases];
    updated[index] = { ...updated[index], [field]: value };
    setPhases(updated);
  };

  const addPhase = () => {
    setPhases([...phases, {
      label: '',
      folderName: '',
      trackingMethod: 'folder',
      filePatterns: ['*.psd', '*.clip', '*.png'],
      order: phases.length,
    }]);
  };

  const removePhase = (index) => {
    setPhases(phases.filter((_, i) => i !== index).map((p, i) => ({ ...p, order: i })));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!name.trim() || !rootFolder) return;
    setSaving(true);
    try {
      const data = {
        name: name.trim(),
        totalPages,
        deadline: deadline ? new Date(deadline + 'T23:59:59').toISOString() : null,
        rootFolder,
        phases: phases.map(({ id, ...rest }) => rest),
      };
      let project;
      if (isEdit) {
        project = await window.electronAPI.updateProject(projectId, data);
      } else {
        project = await window.electronAPI.createProject(data);
      }
      onSaved(project);
    } catch (err) {
      console.error('Failed to save project:', err);
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="project-form">
      <h2>{isEdit ? 'プロジェクト編集' : '新規プロジェクト'}</h2>
      <form onSubmit={handleSubmit}>
        <div className="form-group">
          <label>プロジェクト名</label>
          <input type="text" value={name} onChange={(e) => setName(e.target.value)} placeholder="例: 冬コミ新刊" required />
        </div>

        <div className="form-row">
          <div className="form-group">
            <label>総ページ数</label>
            <input type="number" value={totalPages} onChange={(e) => setTotalPages(parseInt(e.target.value) || 0)} min="1" required />
          </div>
          <div className="form-group">
            <DatePicker label="締切" value={deadline} onChange={setDeadline} clearable />
          </div>
        </div>

        <div className="form-group">
          <label>プロジェクトフォルダ</label>
          <div className="folder-select">
            <input type="text" value={rootFolder} readOnly placeholder="フォルダを選択..." />
            <button type="button" className="btn" onClick={handleSelectFolder}>選択</button>
          </div>
        </div>

        <div className="form-group">
          <label>工程設定</label>
          <div className="phases-editor">
            {phases.map((phase, i) => (
              <div key={i} className="phase-row">
                <input
                  type="text"
                  value={phase.label}
                  onChange={(e) => handlePhaseChange(i, 'label', e.target.value)}
                  placeholder="工程名"
                />
                <input
                  type="text"
                  value={phase.folderName}
                  onChange={(e) => handlePhaseChange(i, 'folderName', e.target.value)}
                  placeholder="フォルダ名"
                />
                <select
                  value={phase.trackingMethod}
                  onChange={(e) => handlePhaseChange(i, 'trackingMethod', e.target.value)}
                >
                  <option value="folder">フォルダ監視</option>
                  <option value="manual">手動入力</option>
                </select>
                <button type="button" className="btn btn-danger btn-sm" onClick={() => removePhase(i)}>×</button>
              </div>
            ))}
            <button type="button" className="btn btn-sm" onClick={addPhase}>+ 工程を追加</button>
          </div>
        </div>

        <div className="form-actions">
          <button type="button" className="btn" onClick={onCancel}>キャンセル</button>
          <button type="submit" className="btn btn-primary" disabled={saving || !name.trim() || !rootFolder}>
            {saving ? '保存中...' : (isEdit ? '更新' : '作成')}
          </button>
        </div>
      </form>
    </div>
  );
}
