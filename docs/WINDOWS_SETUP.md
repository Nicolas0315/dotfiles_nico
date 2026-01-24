# Windows セットアップガイド

Windows で dotfiles_nico をセットアップする詳細ガイドです。

---

## 前提条件

### 必須
- Windows 10/11
- PowerShell 5.1 以上
- Git for Windows
- Claude Code CLI
- Codex CLI（オプション）

### 推奨
- Windows Terminal
- PowerShell 7+
- 管理者権限

---

## セットアップ手順

### Step 1: PowerShell を管理者権限で起動

1. スタートメニューで "PowerShell" を検索
2. 右クリック → **"管理者として実行"**
3. UAC（ユーザーアカウント制御）で「はい」をクリック

### Step 2: 実行ポリシーの設定

```powershell
# 現在のポリシー確認
Get-ExecutionPolicy

# RemoteSigned に変更（推奨）
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

# 確認
Get-ExecutionPolicy
# 出力: RemoteSigned
```

**実行ポリシーの種類:**
- `Restricted`: デフォルト、スクリプト実行不可
- `RemoteSigned`: ローカルスクリプトは実行可、ダウンロードしたスクリプトは署名が必要
- `Unrestricted`: すべて実行可（非推奨）

### Step 3: リポジトリクローン

```powershell
# 作業ディレクトリに移動
cd $env:USERPROFILE\work

# ディレクトリが存在しない場合は作成
New-Item -ItemType Directory -Force -Path $env:USERPROFILE\work

# リポジトリクローン
git clone https://github.com/Nicolas0315/dotfiles_nico.git
cd dotfiles_nico

# 確認
Get-ChildItem
```

### Step 4: シンボリックリンク作成

```powershell
# 管理者権限の PowerShell で実行
powershell -ExecutionPolicy Bypass -File scripts\link_dotfiles.ps1 `
  -DotfilesRoot "$PWD" `
  -MappingFile "$PWD\mappings.txt"
```

**出力例:**
```
Linked: C:\Users\YourName\.claude\CLAUDE.md -> C:\Users\YourName\work\dotfiles_nico\CLAUDE.md
Linked: C:\Users\YourName\.claude\agents -> C:\Users\YourName\work\dotfiles_nico\claudecode\agents
Linked: C:\Users\YourName\.claude\commands -> C:\Users\YourName\work\dotfiles_nico\claudecode\commands
...
```

**管理者権限がない場合:**
スクリプトは自動的にハードリンクまたはジャンクションを使用します。

### Step 5: リンク確認

```powershell
# シンボリックリンク確認
Get-Item $env:USERPROFILE\.claude\CLAUDE.md | Select-Object FullName, LinkType, Target
Get-Item $env:USERPROFILE\.codex\AGENTS.md | Select-Object FullName, LinkType, Target

# ディレクトリ確認
Get-ChildItem $env:USERPROFILE\.claude
Get-ChildItem $env:USERPROFILE\.codex
```

### Step 6: プロジェクトリスト更新（オプション）

```powershell
# projects.txt を編集
notepad projects.txt
```

**編集内容:**
```text
# Windows paths（コメント解除）
C:\Users\ogosh\Desktop\eiai\video-analysis
C:\Users\ogosh\Desktop\my-project

# Mac paths（コメントアウト）
# /Users/s30519/work/eiai-video-analysis
```

**プロジェクトに同期:**
```powershell
powershell -ExecutionPolicy Bypass -File scripts\sync_projects.ps1 `
  -DotfilesRoot "$PWD" `
  -ProjectsFile "$PWD\projects.txt"
```

### Step 7: 環境変数設定

```powershell
# PowerShell プロファイル編集
notepad $PROFILE

# ファイルが存在しない場合は作成
if (!(Test-Path $PROFILE)) {
    New-Item -Path $PROFILE -ItemType File -Force
}
notepad $PROFILE
```

**プロファイルに追加:**
```powershell
# Handoff method
$env:HANDOFF_LAUNCH_METHOD = "terminal-tab"

# その他の設定（オプション）
# $env:CLAUDE_API_KEY = "your-api-key"
```

**プロファイル再読み込み:**
```powershell
. $PROFILE
```

### Step 8: 動作確認

```powershell
# Claude Code コマンド確認
claude --version

# Codex コマンド確認（オプション）
codex --version

# /handoff コマンド確認
Get-Content $env:USERPROFILE\.claude\commands\handoff.md | Select-Object -First 10
```

---

## Windows Terminal 設定（推奨）

### インストール

```powershell
# Windows Terminal インストール
winget install --id Microsoft.WindowsTerminal -e

# 確認
wt --version
```

### 設定

1. Windows Terminal を起動
2. `Ctrl + ,` で設定を開く
3. プロファイル追加（オプション）

**settings.json に追加（オプション）:**
```json
{
  "profiles": {
    "list": [
      {
        "name": "Claude Code",
        "commandline": "powershell.exe -NoExit -Command \"claude code\"",
        "startingDirectory": "%USERPROFILE%\\work"
      },
      {
        "name": "Codex",
        "commandline": "powershell.exe -NoExit -Command \"codex\"",
        "startingDirectory": "%USERPROFILE%\\work"
      }
    ]
  }
}
```

---

## /handoff 動作確認

### テスト実行

```powershell
# 1. Claude Code 起動
claude code

# 2. テストプロジェクト作成
cd $env:USERPROFILE\work
mkdir test-handoff
cd test-handoff

# 3. 簡単なファイル作成
echo "console.log('Hello World');" > index.js

# 4. Git 初期化
git init
git add .
git commit -m "initial commit"

# 5. Claude Code で /handoff テスト
# claude code セッション内で:
/handoff
```

**期待される動作:**
1. ハンドオフコンテキスト入力プロンプト表示
2. コンテキスト保存完了
3. Windows Terminal の新しいタブで Codex が起動
4. Codex が自動的にレビュー開始

---

## トラブルシューティング

### 管理者権限エラー

**エラー:**
```
New-Item : アクセスが拒否されました。
```

**解決方法:**
1. PowerShell を右クリック
2. "管理者として実行" を選択
3. スクリプトを再実行

---

### 実行ポリシーエラー

**エラー:**
```
このシステムではスクリプトの実行が無効になっているため、
ファイル link_dotfiles.ps1 を読み込めません。
```

**解決方法 1: 実行ポリシー変更**
```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**解決方法 2: 一時的にバイパス**
```powershell
powershell -ExecutionPolicy Bypass -File scripts\link_dotfiles.ps1 ...
```

---

### シンボリックリンクが作成できない

**エラー:**
```
New-Item : シンボリック リンクを作成するには、SeCreateSymbolicLinkPrivilege が必要です。
```

**解決方法:**
スクリプトは自動的にハードリンクまたはジャンクションにフォールバックします。

**手動確認:**
```powershell
# リンクタイプ確認
Get-Item $env:USERPROFILE\.claude\CLAUDE.md | Select-Object LinkType

# 出力例:
# HardLink または Junction
```

---

### Windows Terminal が起動しない

**エラー:**
新しいタブが開かない

**解決方法 1: Windows Terminal インストール確認**
```powershell
winget list --name "Windows Terminal"

# インストールされていない場合:
winget install --id Microsoft.WindowsTerminal -e
```

**解決方法 2: 環境変数確認**
```powershell
# プロファイル確認
Get-Content $PROFILE

# 設定されていない場合:
echo '$env:HANDOFF_LAUNCH_METHOD = "terminal-tab"' >> $PROFILE
. $PROFILE
```

---

### パスにスペースが含まれる場合

```powershell
# ダブルクォートで囲む
powershell -ExecutionPolicy Bypass -File scripts\link_dotfiles.ps1 `
  -DotfilesRoot "C:\Users\My Name\work\dotfiles_nico" `
  -MappingFile "C:\Users\My Name\work\dotfiles_nico\mappings.txt"
```

---

### Git が見つからない

**エラー:**
```
git : 用語 'git' は、コマンドレット、関数、スクリプト ファイル、
または操作可能なプログラムの名前として認識されません。
```

**解決方法:**
```powershell
# Git for Windows インストール
winget install --id Git.Git -e

# PATH 確認
$env:PATH -split ';' | Select-String git

# PowerShell 再起動
```

---

## よくある質問

### Q1: WSL でも使える？

**A:** はい、WSL (Windows Subsystem for Linux) でも使えます。

```bash
# WSL 内で Mac/Linux 手順を実行
cd ~/work
git clone https://github.com/Nicolas0315/dotfiles_nico.git
cd dotfiles_nico
./scripts/link_dotfiles.sh --root "$PWD" --map "$PWD/mappings.txt"
```

### Q2: Windows と Mac で同じリポジトリを共有できる？

**A:** はい、可能です。`projects.txt` に両方のパスを記載してください。

```text
# Windows
C:\Users\ogosh\work\my-project

# Mac
/Users/s30519/work/my-project
```

スクリプトは存在しないパスを自動的にスキップします。

### Q3: シンボリックリンクとハードリンクの違いは？

**A:**
- **シンボリックリンク**: ショートカットのようなもの（管理者権限必要）
- **ハードリンク**: ファイルの実体を共有（管理者権限不要、ファイルのみ）
- **ジャンクション**: ディレクトリのリンク（管理者権限不要、ディレクトリのみ）

スクリプトは自動的に最適な方法を選択します。

### Q4: OneDrive/Dropbox にリポジトリを置ける？

**A:** 可能ですが、推奨しません。

- シンボリックリンクが同期されない可能性
- パフォーマンス低下
- 競合の可能性

ローカルディレクトリに配置し、Git でバージョン管理することを推奨します。

---

## アンインストール

### シンボリックリンクを削除

```powershell
# 手動削除
Remove-Item $env:USERPROFILE\.claude\CLAUDE.md
Remove-Item $env:USERPROFILE\.claude\agents
Remove-Item $env:USERPROFILE\.claude\commands
Remove-Item $env:USERPROFILE\.claude\rules
Remove-Item $env:USERPROFILE\.claude\hooks
Remove-Item $env:USERPROFILE\.claude\skills
Remove-Item $env:USERPROFILE\.codex\AGENTS.md

# または一括削除スクリプト（作成必要）
```

### リポジトリ削除

```powershell
cd $env:USERPROFILE\work
Remove-Item -Recurse -Force dotfiles_nico
```

### 環境変数削除

```powershell
# プロファイル編集
notepad $PROFILE

# 以下の行を削除:
# $env:HANDOFF_LAUNCH_METHOD = "terminal-tab"
```

---

## 次のステップ

1. [README.md](../README.md) でワークフローを確認
2. [HANDOFF_WORKFLOW.md](HANDOFF_WORKFLOW.md) で `/handoff` の詳細を確認
3. 実際のプロジェクトで試してみる

---

**Happy Coding on Windows! 🪟**
