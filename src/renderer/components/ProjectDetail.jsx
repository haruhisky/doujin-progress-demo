import React, { useState } from 'react';
import { useProject } from '../hooks/useProjects';
import { useProgress } from '../hooks/useProgress';
import PhaseProgressBar from './PhaseProgressBar';
import GanttChart from './GanttChart';
import AIAnalysisPanel from './AIAnalysisPanel';
import Modal from './common/Modal';
import '../styles/project-detail.css';

export default function ProjectDetail({ projectId, onBack, onEdit }) {
  const { project, loading: pLoading } = useProject(projectId);
  const { snapshot, ganttData, loading: prLoading } = useProgress(projectId);
  const [showDeleteConfirm, setShowDeleteConfirm] = useState(false);
  const [activeTab, setActiveTab] = useState('progress');

  if (pLoading || prLoading) return <div className="loading">読み込み中...</div>;
  if (!project) return <div className="error">プロジェクトが見つかりません</div>;

  const handleDelete = async () => {
    await window.electronAPI.deleteProject(projectId);
    onBack();
  };

  const handleArchive = async () => {
    await window.electronAPI.updateProject(projectId, { isArchived: !project.isArchived });
    onBack();
  };

  const deadlineText = project.deadline ? formatDeadline(project.deadline) : '未設定';

  return (
    <div className="project-detail">
      <div className="detail-header">
        <button className="btn btn-back" onClick={onBack}>← 戻る</button>
        <div className="detail-title-group">
          <h2>{project.name}</h2>
          <div className="detail-meta">
            <span>{project.totalPages}ページ</span>
            <span>締切: {deadlineText}</span>
            <span>フォルダ: {project.rootFolder}</span>
          </div>
        </div>
        <div className="detail-actions">
          <button className="btn" onClick={() => onEdit(projectId)}>編集</button>
          <button className="btn" onClick={handleArchive}>
            {project.isArchived ? 'アーカイブ解除' : 'アーカイブ'}
          </button>
          <button className="btn btn-danger" onClick={() => setShowDeleteConfirm(true)}>削除</button>
        </div>
      </div>

      <div className="detail-tabs">
        <button className={`tab ${activeTab === 'progress' ? 'active' : ''}`} onClick={() => setActiveTab('progress')}>進捗</button>
        <button className={`tab ${activeTab === 'gantt' ? 'active' : ''}`} onClick={() => setActiveTab('gantt')}>ガントチャート</button>
        <button className={`tab ${activeTab === 'ai' ? 'active' : ''}`} onClick={() => setActiveTab('ai')}>AI分析</button>
      </div>

      <div className="detail-content">
        {activeTab === 'progress' && snapshot && (
          <PhaseProgressBar phases={snapshot.phases} projectId={projectId} />
        )}
        {activeTab === 'gantt' && (
          <GanttChart
            data={ganttData}
            phases={project.phases.sort((a, b) => a.order - b.order)}
            deadline={project.deadline}
          />
        )}
        {activeTab === 'ai' && (
          <AIAnalysisPanel projectId={projectId} />
        )}
      </div>

      <Modal isOpen={showDeleteConfirm} onClose={() => setShowDeleteConfirm(false)} title="プロジェクト削除">
        <p>「{project.name}」を削除しますか？この操作は取り消せません。</p>
        <div className="form-actions">
          <button className="btn" onClick={() => setShowDeleteConfirm(false)}>キャンセル</button>
          <button className="btn btn-danger" onClick={handleDelete}>削除する</button>
        </div>
      </Modal>
    </div>
  );
}

function formatDeadline(deadline) {
  const d = new Date(deadline);
  const now = new Date();
  const diff = Math.ceil((d.getTime() - now.getTime()) / (1000 * 60 * 60 * 24));
  const dateStr = `${d.getFullYear()}/${d.getMonth() + 1}/${d.getDate()}`;
  if (diff < 0) return `${dateStr} (${Math.abs(diff)}日超過)`;
  if (diff === 0) return `${dateStr} (今日)`;
  return `${dateStr} (残り${diff}日)`;
}
