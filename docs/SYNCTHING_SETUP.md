# Syncthing で dotfiles を同期する

P2P ファイル同期ツール **Syncthing** を使って、Mac と Windows 間で dotfiles_nico を自動同期する方法。

---

## 概要

### Syncthing とは

- **P2P ファイル同期**: クラウドを介さず、デバイス間で直接同期
- **プライバシー重視**: データは自分のデバイス間でのみ移動
- **暗号化**: すべての通信が TLS で暗号化
- **クロスプラットフォーム**: Windows、Mac、Linux、Android をサポート
- **オープンソース**: 完全に無料

### メリット

✅ **クラウド不要**: Dropbox や OneDrive のようなクラウドストレージ不要
✅ **リアルタイム同期**: ファイル変更を即座に他デバイスに反映
✅ **プライバシー**: データは自分のデバイスのみに存在
✅ **容量無制限**: ストレージ容量はローカルディスクに依存
✅ **競合解決**: 同時編集時の競合を自動検出

### Git との併用

Syncthing と Git を併用する推奨構成：

- **Syncthing**: ファイルの自動同期（リアルタイム）
- **Git**: バージョン管理、バックアップ、履歴管理

```
┌─────────┐                    ┌─────────┐
│   Mac   │ ←─── Syncthing ───→│ Windows │
└────┬────┘                    └────┬────┘
     │                              │
     └────── Git (GitHub) ──────────┘
```

---

## インストール

### Mac

```bash
# Homebrew でインストール
brew install syncthing

# 起動
syncthing

# バックグラウンドで自動起動（オプション）
brew services start syncthing
```

### Windows

**方法1: インストーラー（推奨）**

1. [Syncthing ダウンロードページ](https://syncthing.net/downloads/) にアクセス
2. **Windows (64-bit)** の **Installer** をダウンロード
3. インストーラーを実行
4. スタートメニューから "Syncthing" を起動

**方法2: Chocolatey**

```powershell
# 管理者権限の PowerShell で実行
choco install syncthing

# 起動
syncthing.exe
```

**方法3: Scoop**

```powershell
scoop install syncthing

# 起動
syncthing
```

### Linux

```bash
# Ubuntu/Debian
sudo apt install syncthing

# Arch Linux
sudo pacman -S syncthing

# 起動
syncthing
```

---

## 初期設定

### Step 1: Syncthing を起動

**Mac:**
```bash
syncthing
```

**Windows:**
スタートメニュー → "Syncthing"

初回起動時、ブラウザで Web UI が自動的に開きます：
- URL: `http://127.0.0.1:8384`

### Step 2: デバイスの追加

#### Mac で設定

1. Web UI を開く: `http://127.0.0.1:8384`
2. 右上の **"Actions"** → **"Show ID"**
3. デバイス ID をコピー（または QR コード表示）

#### Windows で設定

1. Web UI を開く: `http://127.0.0.1:8384`
2. 右下の **"Add Remote Device"**
3. Mac のデバイス ID を貼り付け
4. **"Save"**

#### Mac で承認

1. Mac の Web UI に通知が表示される
2. **"Add Device"** をクリック
3. **"Save"**

これでデバイス間の接続が確立されます。

---

## dotfiles_nico の同期設定

### Step 3: フォルダの追加（Mac）

1. Mac の Syncthing Web UI を開く
2. **"Add Folder"** をクリック
3. 設定:

```
Folder Label: dotfiles_nico
Folder ID: dotfiles_nico (自動生成)
Folder Path: /Users/s30519/work/dotfiles_nico
```

4. **"Sharing"** タブ:
   - Windows デバイスにチェック

5. **"Ignore Patterns"** タブ（重要）:

```
# Git 管理ファイルを除外
.git
.gitignore

# macOS システムファイル
.DS_Store
.AppleDouble
.LSOverride

# Windows システムファイル
Thumbs.db
desktop.ini
$RECYCLE.BIN/

# エディタ一時ファイル
*.swp
*.swo
*~
.*.sw?

# Node modules（もしあれば）
node_modules/

# ビルド成果物
dist/
build/
*.log
```

6. **"Save"**

### Step 4: フォルダの承認（Windows）

1. Windows の Syncthing Web UI に通知が表示される
2. **"Add"** をクリック
3. Folder Path を設定:
   ```
   C:\Users\ogosh\work\dotfiles_nico
   ```
4. **"Save"**

### Step 5: 同期の確認

Web UI で同期状態を確認：
- **"Up to Date"**: 同期完了
- **"Syncing"**: 同期中
- **"Out of Sync"**: 同期エラー

---

## .stignore ファイルの作成

dotfiles_nico ディレクトリに `.stignore` ファイルを作成し、同期から除外するファイルを指定：

```bash
# Mac
cat > /Users/s30519/work/dotfiles_nico/.stignore <<'EOF'
# Git 管理ファイル（Git で管理するため除外）
.git
.gitignore
.gitattributes

# システムファイル
.DS_Store
.AppleDouble
.LSOverride
Thumbs.db
desktop.ini
$RECYCLE.BIN/

# エディタ一時ファイル
*.swp
*.swo
*~
.*.sw?
.vscode/
.idea/

# ログファイル
*.log

# バックアップファイル
*.bak
*.backup
*~

# Claude/Codex キャッシュ（同期不要）
.claude/cache/
.claude/history.jsonl
.codex/cache/
.codex/history.jsonl

# 一時ファイル
tmp/
temp/
EOF
```

**Windows:**
```powershell
# PowerShell
@"
# Git 管理ファイル
.git
.gitignore
.gitattributes

# システムファイル
.DS_Store
Thumbs.db
desktop.ini
`$RECYCLE.BIN/

# エディタ一時ファイル
*.swp
*.swo
*~
.*.sw?

# Claude/Codex キャッシュ
.claude/cache/
.claude/history.jsonl
.codex/cache/
.codex/history.jsonl
"@ | Out-File -FilePath "$env:USERPROFILE\work\dotfiles_nico\.stignore" -Encoding utf8
```

---

## Git との併用ベストプラクティス

### 推奨ワークフロー

#### 日常的な編集（Syncthing）

```bash
# Mac で編集
vim ~/work/dotfiles_nico/CLAUDE.md

# Syncthing が自動的に Windows に同期
# Windows でも即座に変更が反映される
```

#### 重要な変更（Git でコミット）

```bash
# Mac で編集完了後
cd ~/work/dotfiles_nico
git add CLAUDE.md
git commit -m "feat: update Claude configuration"
git push origin main

# Windows で pull
cd C:\Users\ogosh\work\dotfiles_nico
git pull origin main
```

### ルール

1. **Syncthing**: リアルタイム同期に使用
2. **Git**: バージョン管理・バックアップに使用
3. **`.git` ディレクトリは Syncthing から除外**（`.stignore` で設定済み）
4. **重要な変更は Git でコミット**

---

## 競合の回避

### 競合が発生する場合

- Mac と Windows で同じファイルを同時編集
- 同期前に両方で変更をコミット

### 競合解決

Syncthing は競合を自動検出し、競合ファイルを作成：

```
CLAUDE.md
CLAUDE.sync-conflict-20260123-193000.md
```

**手動解決:**

```bash
# 1. 競合ファイルを確認
cat CLAUDE.sync-conflict-*.md

# 2. 内容をマージ
vim CLAUDE.md

# 3. 競合ファイルを削除
rm CLAUDE.sync-conflict-*.md

# 4. Git でコミット
git add CLAUDE.md
git commit -m "fix: resolve sync conflict"
git push
```

### ベストプラクティス

✅ **1つのマシンで集中して作業**
✅ **変更後は Syncthing の同期完了を確認**
✅ **重要な変更は Git でコミット**
✅ **Git でコミット前に `git pull` で最新を取得**

---

## 自動起動設定

### Mac

**Launch Agent で自動起動:**

```bash
# Homebrew services で自動起動
brew services start syncthing

# 確認
brew services list

# 停止
brew services stop syncthing
```

### Windows

**スタートアップに登録:**

1. `Win + R` → `shell:startup` を実行
2. スタートアップフォルダが開く
3. Syncthing のショートカットを配置:
   ```
   C:\Program Files\Syncthing\syncthing.exe
   ```

**またはサービスとして登録（推奨）:**

1. [SyncTrayzor](https://github.com/canton7/SyncTrayzor) をインストール（Syncthing の Windows GUI）
2. 設定で "Start SyncTrayzor automatically on login" を有効化

---

## SyncTrayzor（Windows 推奨）

### インストール

```powershell
# Chocolatey
choco install synctrayzor

# または公式サイトからダウンロード
# https://github.com/canton7/SyncTrayzor/releases
```

### 特徴

- **システムトレイ常駐**: タスクバーから簡単にアクセス
- **自動起動**: Windows ログイン時に自動起動
- **通知**: 同期状態をリアルタイムで通知
- **簡単設定**: GUI で簡単に設定可能

---

## トラブルシューティング

### デバイスが見つからない

**症状**: Mac と Windows が接続できない

**解決方法:**

1. **同じネットワーク上にいるか確認**
   ```bash
   # Mac で IP 確認
   ifconfig | grep inet

   # Windows で IP 確認
   ipconfig
   ```

2. **ファイアウォール設定確認**
   - Mac: システム環境設定 → セキュリティとプライバシー → ファイアウォール
   - Windows: Windows Defender ファイアウォール → Syncthing を許可

3. **リレーサーバー経由で接続**（自動）
   - Syncthing は自動的にリレーサーバーを使用
   - 直接接続できない場合でも同期可能

### 同期が遅い

**症状**: ファイル変更が反映されない

**解決方法:**

1. **Web UI で同期状態確認**
   - "Out of Sync" の場合、エラーログを確認

2. **ファイル監視の有効化**
   - フォルダ設定 → "Advanced" → "Watch for Changes" を有効

3. **スキャン間隔の短縮**
   - フォルダ設定 → "Advanced" → "Rescan Interval" を短くする（例: 60秒）

### .git が同期されてしまう

**症状**: `.git` ディレクトリが同期されている

**解決方法:**

```bash
# .stignore を確認
cat ~/work/dotfiles_nico/.stignore

# .git が含まれているか確認
# 含まれていない場合は追加
echo ".git" >> ~/work/dotfiles_nico/.stignore

# Syncthing を再スキャン
# Web UI → フォルダ → "Rescan"
```

### 競合が頻発する

**症状**: sync-conflict ファイルが大量生成

**解決方法:**

1. **同時編集を避ける**
   - 1つのマシンで集中して作業
   - 作業前に同期完了を確認

2. **Git でバージョン管理**
   - 重要な変更前に Git コミット
   - `git pull` で最新を取得

3. **ファイルロック機能を使用（オプション）**
   - フォルダ設定 → "Advanced" → "File Pull Order" を "oldest first" に設定

---

## セキュリティ設定

### Web UI のパスワード保護

**推奨**: Web UI にパスワードを設定

1. Web UI → "Actions" → "Settings"
2. "GUI" タブ
3. "GUI Authentication User" と "GUI Authentication Password" を設定
4. "Save"

### HTTPS の有効化（オプション）

1. Web UI → "Actions" → "Settings"
2. "GUI" タブ
3. "Use HTTPS for GUI" を有効
4. "Save"

---

## よくある質問

### Q1: Git と Syncthing の違いは？

**A:**
- **Git**: バージョン管理、履歴保存、意図的なコミット
- **Syncthing**: リアルタイム同期、自動、バージョン管理なし

両方を併用することで、リアルタイム同期とバージョン管理の両方を実現。

### Q2: .git ディレクトリを同期すべき？

**A:** いいえ。`.stignore` で除外し、Git で管理してください。

理由:
- Git リポジトリが破損する可能性
- 競合が発生しやすい
- Git の `push`/`pull` で十分

### Q3: Syncthing がダウンしたら？

**A:** 問題ありません。

- ファイルはローカルに存在
- Syncthing 再起動で自動的に同期再開
- Git でバックアップもあるため安全

### Q4: モバイル（スマホ）でも使える？

**A:** はい。Android で利用可能。

- Google Play で "Syncthing" を検索
- dotfiles_nico をスマホで閲覧・編集可能
- iOS は非公式アプリあり（Möbius Sync）

### Q5: 複数の Mac/Windows マシンで同期できる？

**A:** はい、無制限にデバイス追加可能。

```
Mac 1 ←→ Mac 2 ←→ Windows 1 ←→ Windows 2
```

すべてのデバイスが自動的に同期されます。

---

## まとめ

### セットアップ手順（復習）

1. ✅ Syncthing インストール（Mac + Windows）
2. ✅ デバイス接続
3. ✅ dotfiles_nico フォルダ共有
4. ✅ `.stignore` 作成（`.git` 除外）
5. ✅ 自動起動設定
6. ✅ Git との併用ワークフロー確認

### ベストプラクティス

✅ **Syncthing**: リアルタイム同期に使用
✅ **Git**: バージョン管理・バックアップに使用
✅ **`.git` は除外**（`.stignore`）
✅ **同時編集を避ける**
✅ **重要な変更は Git でコミット**

---

## 関連リンク

- [Syncthing 公式サイト](https://syncthing.net/)
- [Syncthing ドキュメント](https://docs.syncthing.net/)
- [SyncTrayzor（Windows GUI）](https://github.com/canton7/SyncTrayzor)
- [README.md](../README.md)
- [WINDOWS_SETUP.md](WINDOWS_SETUP.md)

---

**Happy Syncing! 🔄**
