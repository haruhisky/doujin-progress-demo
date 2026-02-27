import React, { useState } from 'react';
import ProjectList from './components/ProjectList';
import ProjectDetail from './components/ProjectDetail';
import ProjectForm from './components/ProjectForm';
import SettingsView from './components/SettingsView';

const VIEWS = { LIST: 'list', DETAIL: 'detail', CREATE: 'create', EDIT: 'edit', SETTINGS: 'settings' };

export default function App() {
  const [view, setView] = useState(VIEWS.LIST);
  const [selectedProjectId, setSelectedProjectId] = useState(null);
  const [editProjectId, setEditProjectId] = useState(null);

  const navigateToList = () => { setView(VIEWS.LIST); setSelectedProjectId(null); };
  const navigateToDetail = (id) => { setSelectedProjectId(id); setView(VIEWS.DETAIL); };
  const navigateToCreate = () => setView(VIEWS.CREATE);
  const navigateToEdit = (id) => { setEditProjectId(id); setView(VIEWS.EDIT); };
  const navigateToSettings = () => setView(VIEWS.SETTINGS);

  return (
    <div className="app">
      <header className="app-header">
        <h1 onClick={navigateToList} style={{ cursor: 'pointer' }}>同人誌進捗管理</h1>
        <nav className="app-nav">
          <button className="nav-btn" onClick={navigateToList}>プロジェクト一覧</button>
          <button className="nav-btn" onClick={navigateToSettings}>設定</button>
        </nav>
      </header>
      <main className="app-main">
        {view === VIEWS.LIST && (
          <ProjectList
            onSelect={navigateToDetail}
            onCreate={navigateToCreate}
          />
        )}
        {view === VIEWS.DETAIL && selectedProjectId && (
          <ProjectDetail
            projectId={selectedProjectId}
            onBack={navigateToList}
            onEdit={navigateToEdit}
          />
        )}
        {view === VIEWS.CREATE && (
          <ProjectForm
            onSaved={(project) => navigateToDetail(project.id)}
            onCancel={navigateToList}
          />
        )}
        {view === VIEWS.EDIT && editProjectId && (
          <ProjectForm
            projectId={editProjectId}
            onSaved={(project) => navigateToDetail(project.id)}
            onCancel={() => navigateToDetail(editProjectId)}
          />
        )}
        {view === VIEWS.SETTINGS && (
          <SettingsView onBack={navigateToList} />
        )}
      </main>
    </div>
  );
}
