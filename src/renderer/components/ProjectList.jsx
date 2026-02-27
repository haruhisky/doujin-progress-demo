import React from 'react';
import { useProjects } from '../hooks/useProjects';
import '../styles/project-list.css';

export default function ProjectList({ onSelect, onCreate }) {
  const { projects, loading } = useProjects();

  if (loading) return <div className="loading">読み込み中...</div>;

  const active = projects.filter(p => !p.isArchived);
  const archived = projects.filter(p => p.isArchived);

  return (
    <div className="project-list">
      <div className="project-list-header">
        <h2>プロジェクト一覧</h2>
        <button className="btn btn-primary" onClick={onCreate}>
          + 新規プロジェクト
        </button>
      </div>

      {active.length === 0 && (
        <div className="empty-state">
          <p>プロジェクトがありません</p>
          <p>「新規プロジェクト」をクリックして最初のプロジェクトを作成しましょう</p>
        </div>
      )}

      <div className="project-cards">
        {active.map(project => (
          <ProjectCard key={project.id} project={project} onClick={() => onSelect(project.id)} />
        ))}
      </div>

      {archived.length > 0 && (
        <>
          <h3 className="section-title">アーカイブ済み</h3>
          <div className="project-cards project-cards-archived">
            {archived.map(project => (
              <ProjectCard key={project.id} project={project} onClick={() => onSelect(project.id)} />
            ))}
          </div>
        </>
      )}
    </div>
  );
}

function ProjectCard({ project, onClick }) {
  const deadlineText = project.deadline
    ? formatDeadline(project.deadline)
    : '締切未設定';

  return (
    <div className="project-card" onClick={onClick}>
      <h3 className="project-card-name">{project.name}</h3>
      <div className="project-card-meta">
        <span>{project.totalPages}ページ</span>
        <span className={`deadline ${isOverdue(project.deadline) ? 'overdue' : ''}`}>
          {deadlineText}
        </span>
      </div>
      <div className="project-card-phases">
        {project.phases.sort((a, b) => a.order - b.order).map(phase => (
          <span key={phase.id} className="phase-tag">{phase.label}</span>
        ))}
      </div>
    </div>
  );
}

function formatDeadline(deadline) {
  const d = new Date(deadline);
  const now = new Date();
  const diff = Math.ceil((d.getTime() - now.getTime()) / (1000 * 60 * 60 * 24));
  const dateStr = `${d.getMonth() + 1}/${d.getDate()}`;
  if (diff < 0) return `${dateStr} (${Math.abs(diff)}日超過)`;
  if (diff === 0) return `${dateStr} (今日)`;
  return `${dateStr} (残り${diff}日)`;
}

function isOverdue(deadline) {
  if (!deadline) return false;
  return new Date(deadline) < new Date();
}
