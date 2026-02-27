import { Tray, Menu, nativeImage, BrowserWindow } from 'electron';
import * as path from 'path';

export class TrayManager {
  private tray: Tray | null = null;

  create(mainWindow: BrowserWindow): void {
    const iconPath = path.join(__dirname, '../../assets/icon.ico');
    let icon: Electron.NativeImage;
    try {
      icon = nativeImage.createFromPath(iconPath);
    } catch {
      icon = nativeImage.createEmpty();
    }

    this.tray = new Tray(icon);
    this.tray.setToolTip('同人誌進捗管理');

    const contextMenu = Menu.buildFromTemplate([
      {
        label: '表示',
        click: () => {
          mainWindow.show();
          mainWindow.focus();
        },
      },
      { type: 'separator' },
      {
        label: '終了',
        click: () => {
          mainWindow.destroy();
        },
      },
    ]);

    this.tray.setContextMenu(contextMenu);
    this.tray.on('double-click', () => {
      mainWindow.show();
      mainWindow.focus();
    });
  }

  destroy(): void {
    if (this.tray) {
      this.tray.destroy();
      this.tray = null;
    }
  }
}
