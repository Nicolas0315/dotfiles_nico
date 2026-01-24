# Dotfiles Nico - Claude Code & Codex 統合設定

> Claude Code（実装担当）と Codex（レビュー・管理担当）の設定を一元管理する dotfiles リポジトリ

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## 概要

このリポジトリは、AI 開発ツール（Claude Code、Codex）の設定を統一管理し、クロスプラットフォーム（Mac/Windows）でシームレスに利用できるようにします。

### 主な機能

- **ツール別設定**: Claude Code（実装）と Codex（レビュー）で異なる役割を明確化
- **自動引き継ぎ**: `/handoff` コマンドで実装からレビューへ自動移行
- **一元管理**: すべての設定をこのリポジトリで管理
- **シンボリックリンク**: スクリプトで自動的に適切な場所にリンク
- **クロスプラットフォーム**: Mac と Windows の両方をサポート

---

## 📁 ディレクトリ構造

```
dotfiles_nico/
├── README.md                          # このファイル
├── AGENTS.md                          # 共通の Core Philosophy
├── CLAUDE.md                          # Claude Code 専用設定（実装担当）
├── CODEX.md                           # Codex 専用設定（レビュー・管理担当）
├── mappings.txt                       # シンボリックリンクマッピング
├── projects.txt                       # プロジェクトリスト
│
├── claudecode/                        # Claude Code 専用リソース
│   ├── agents/                        # 9 エージェント（planner, tdd-guide, etc.）
│   ├── commands/                      # 15 コマンド（/plan, /tdd, /handoff, etc.）
│   ├── skills/                        # スキル定義
│   ├── rules/                         # コーディング規約（8ファイル）
│   ├── hooks/                         # 自動化フック
│   └── examples/                      # 設定例
│
├── codex/                             # Codex 専用リソース
│   ├── config.toml                    # Codex 設定
│   ├── rules/                         # レビュー規約
│   └── skills/                        # レビュー・管理スキル
│       └── auto-review/               # 自動レビュースキル
│
├── scripts/                           # 自動化スクリプト
│   ├── link_dotfiles.sh               # シンボリックリンク作成（Mac/Linux）
│   ├── link_dotfiles.ps1              # シンボリックリンク作成（Windows）
│   ├── sync_projects.sh               # プロジェクト同期（Mac/Linux）
│   ├── sync_projects.ps1              # プロジェクト同期（Windows）
│   ├── handoff-to-codex.sh            # Codex 自動起動スクリプト
│   └── review-handoff-wrapper.sh      # レビューラッパー
│
└── docs/                              # ドキュメント
    └── HANDOFF_WORKFLOW.md            # ハンドオフワークフロー詳細
```

---

## 🎯 Claude Code と Codex の使い分け

### Claude Code（実装担当）

**役割**: コーディング・実装専門エンジニア

**責務**:
- 機能実装・新機能の設計
- テスト駆動開発（TDD）
- デバッグ・バグ修正
- ビルドエラー修正

**主なコマンド**:
- `/plan` - 実装計画作成
- `/tdd` - TDD ワークフロー開始
- `/build-fix` - ビルドエラー解決
- `/handoff` - **Codex に自動引き継ぎ**

**設定ファイル**: `CLAUDE.md` → `~/.claude/CLAUDE.md`

---

### Codex（レビュー・管理担当）

**役割**: コードレビュー・品質管理・ドキュメント・バージョン管理専門

**責務**:
- コードレビュー（品質・セキュリティ）
- セキュリティ監査
- ドキュメント管理
- Git/GitHub 操作（コミット、PR、Issue）
- 品質保証

**主なコマンド**:
- `/code-review` - コードレビュー実行
- `/verify` - 実装検証
- `/update-docs` - ドキュメント更新
- `/refactor-clean` - デッドコード削除
- `codex review-handoff` - **Claude Code からの引き継ぎ受信**

**設定ファイル**: `CODEX.md` → `~/.codex/AGENTS.md`

---

## 🚀 クイックスタート（Mac）

### 1. リポジトリクローン

```bash
cd ~/work
git clone https://github.com/Nicolas0315/dotfiles_nico.git
cd dotfiles_nico
```

### 2. シンボリックリンク作成

```bash
chmod +x scripts/link_dotfiles.sh
./scripts/link_dotfiles.sh --root "$PWD" --map "$PWD/mappings.txt"
```

これにより以下のリンクが作成されます：
- `~/.claude/CLAUDE.md` → `dotfiles_nico/CLAUDE.md`
- `~/.claude/agents` → `dotfiles_nico/claudecode/agents`
- `~/.claude/commands` → `dotfiles_nico/claudecode/commands`
- `~/.claude/rules` → `dotfiles_nico/claudecode/rules`
- `~/.claude/hooks` → `dotfiles_nico/claudecode/hooks`
- `~/.codex/AGENTS.md` → `dotfiles_nico/CODEX.md`
- `~/.codex/skills/auto-review` → `dotfiles_nico/codex/skills/auto-review`

### 3. プロジェクトリスト更新（オプション）

```bash
# projects.txt を編集してプロジェクトパスを追加
vim projects.txt

# AGENTS.md をプロジェクトに同期
chmod +x scripts/sync_projects.sh
./scripts/sync_projects.sh --root "$PWD" --projects "$PWD/projects.txt"
```

### 4. tmux 連携設定（推奨）

```bash
# ~/.zshrc に追加
echo 'export HANDOFF_LAUNCH_METHOD=tmux' >> ~/.zshrc
source ~/.zshrc
```

---

## 🪟 クイックスタート（Windows）

### 1. リポジトリクローン

```powershell
# PowerShell を管理者権限で起動
cd $env:USERPROFILE\work
git clone https://github.com/Nicolas0315/dotfiles_nico.git
cd dotfiles_nico
```

### 2. 実行ポリシー確認

```powershell
# 現在の実行ポリシー確認
Get-ExecutionPolicy

# RemoteSigned または Unrestricted に変更（必要に応じて）
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### 3. シンボリックリンク作成

```powershell
# 管理者権限の PowerShell で実行
powershell -ExecutionPolicy Bypass -File scripts\link_dotfiles.ps1 `
  -DotfilesRoot "$env:USERPROFILE\work\dotfiles_nico" `
  -MappingFile "$env:USERPROFILE\work\dotfiles_nico\mappings.txt"
```

これにより以下のリンクが作成されます：
- `C:\Users\<user>\.claude\CLAUDE.md` → `dotfiles_nico\CLAUDE.md`
- `C:\Users\<user>\.claude\agents` → `dotfiles_nico\claudecode\agents`
- `C:\Users\<user>\.claude\commands` → `dotfiles_nico\claudecode\commands`
- `C:\Users\<user>\.claude\rules` → `dotfiles_nico\claudecode\rules`
- `C:\Users\<user>\.claude\hooks` → `dotfiles_nico\claudecode\hooks`
- `C:\Users\<user>\.codex\AGENTS.md` → `dotfiles_nico\CODEX.md`

**注意**: Windows ではシンボリックリンクに管理者権限が必要です。権限がない場合、スクリプトは自動的にハードリンクまたはジャンクションにフォールバックします。

### 4. プロジェクトリスト更新（オプション）

```powershell
# projects.txt を編集して Windows パスを有効化
notepad projects.txt

# 例: コメントを外す
# C:\Users\ogosh\Desktop\my-project  # ← コメントアウト解除

# AGENTS.md をプロジェクトに同期
powershell -ExecutionPolicy Bypass -File scripts\sync_projects.ps1 `
  -DotfilesRoot "$env:USERPROFILE\work\dotfiles_nico" `
  -ProjectsFile "$env:USERPROFILE\work\dotfiles_nico\projects.txt"
```

### 5. ターミナル設定

Windows では tmux が使えないため、代わりに Windows Terminal を使用：

```powershell
# 環境変数設定（PowerShell プロファイルに追加）
notepad $PROFILE

# 以下を追加：
$env:HANDOFF_LAUNCH_METHOD = "terminal-tab"
```

Windows Terminal で `/handoff` を実行すると、新しいタブで Codex が起動します。

---

## 💡 基本的な使い方

### ワークフロー: 機能実装からレビューまで

#### Step 1: 実装（Claude Code）

```bash
# Claude Code セッション開始
claude code

# 1. 計画作成
/plan

# 2. TDD 開始
/tdd

# 3. 実装
[コーディング作業...]

# 4. テスト実行
npm test
# Coverage: 87% ✓

# 5. ビルド確認
npm run build
# Success ✓
```

#### Step 2: 自動引き継ぎ

```bash
# 実装完了後、ハンドオフコマンド実行
/handoff
```

プロンプトに回答：
- **実装サマリー**: 何を実装したか（1-3文）
- **テストカバレッジ**: 現在のカバレッジ
- **既知の問題**: TODO や制限事項

#### Step 3: 自動レビュー（Codex）

システムが自動的に：
1. コンテキストを `~/.codex/handoff.json` に保存
2. Codex セッションを起動（tmux の新しい pane）
3. Codex が包括的レビューを実行

Codex のレビュー内容：
- コード品質チェック
- セキュリティ監査
- テスト検証（80%以上カバレッジ）
- ドキュメントチェック

#### Step 4: アクション実行

Codex がレビュー結果を報告し、選択肢を提示：
- 問題を修正する
- ドキュメントを更新する
- コミットを作成する
- PR を作成する

---

## 🛠️ 便利な機能

### 1. `/handoff` による自動引き継ぎ

**最大の特徴**: Claude Code から Codex への完全自動引き継ぎ

```bash
# Claude Code で実装完了後
/handoff

# 自動的に：
# 1. 実装コンテキスト保存
# 2. Codex セッション起動
# 3. 包括的レビュー実行
# 4. 結果レポート生成
```

詳細: `docs/HANDOFF_WORKFLOW.md`

---

### 2. エージェントによるタスク自動化

#### 実装系エージェント（Claude Code）

| エージェント | 用途 | コマンド |
|-------------|------|---------|
| planner | 実装計画作成 | 自動 |
| architect | アーキテクチャ設計 | 自動 |
| tdd-guide | TDD 実践 | `/tdd` |
| build-error-resolver | ビルドエラー修正 | `/build-fix` |

#### レビュー系エージェント（Codex）

| エージェント | 用途 | コマンド |
|-------------|------|---------|
| code-reviewer | コード品質レビュー | `/code-review` |
| security-reviewer | セキュリティ監査 | 自動 |
| doc-updater | ドキュメント更新 | `/update-docs` |
| refactor-cleaner | デッドコード削除 | `/refactor-clean` |

---

### 3. ルールによる品質保証

Claude Code と Codex は以下のルールを自動的に適用：

#### コーディングスタイル（`rules/coding-style.md`）
- イミュータビリティ厳守
- 小さいファイル（200-400行、最大800行）
- 包括的エラーハンドリング
- 入力バリデーション必須

#### セキュリティ（`rules/security.md`）
- ハードコードシークレット禁止
- SQL インジェクション対策
- XSS 対策
- 環境変数での機密情報管理

#### テスト（`rules/testing.md`）
- 80%以上のカバレッジ必須
- TDD（テスト駆動開発）
- Unit + Integration + E2E

#### Git ワークフロー（`rules/git-workflow.md`）
- Conventional Commits 形式
- 詳細なコミットメッセージ
- PR 作成時の包括的サマリー

---

### 4. Hook による自動化

実行前後に自動的にチェック・処理を実行：

**PreToolUse フック**:
- tmux リマインダー（長時間コマンド時）
- Git push レビュー
- 不要なドキュメント作成抑制

**PostToolUse フック**:
- Prettier 自動フォーマット
- TypeScript 型チェック
- console.log 検出警告

**Session フック**:
- コンテキスト永続化
- パッケージマネージャー検出

---

## 📚 主要コマンド一覧

### Claude Code（実装）

```bash
/plan              # 実装計画作成
/tdd               # TDD ワークフロー開始
/build-fix         # ビルドエラー解決
/checkpoint        # 作業状態保存
/handoff           # Codex に自動引き継ぎ（★重要）
```

### Codex（レビュー・管理）

```bash
/code-review       # コードレビュー実行
/verify            # 実装検証
/update-docs       # ドキュメント更新
/refactor-clean    # デッドコード削除
/e2e               # E2E テスト実行
/learn             # セッションからパターン抽出

# コマンドライン
codex review-handoff    # Claude Code からの引き継ぎ受信
```

---

## 🔧 カスタマイズ

### mappings.txt の編集

シンボリックリンクのマッピングを変更：

```text
# Format: source:destination
CLAUDE.md:~/.claude/CLAUDE.md
CODEX.md:~/.codex/AGENTS.md
claudecode/agents:~/.claude/agents
claudecode/commands:~/.claude/commands
claudecode/rules:~/.claude/rules
claudecode/hooks:~/.claude/hooks
codex/skills/auto-review:~/.codex/skills/auto-review
```

編集後、再度リンクスクリプトを実行：

```bash
./scripts/link_dotfiles.sh --root "$PWD" --map "$PWD/mappings.txt"
```

---

### projects.txt の編集

AGENTS.md を同期するプロジェクトを追加：

```text
# Mac paths
/Users/s30519/work/eiai-video-analysis
/Users/s30519/work/my-awesome-project

# Windows paths（コメントアウトして Mac のみ使用）
# C:\Users\ogosh\Desktop\my-project
```

編集後、同期スクリプトを実行：

```bash
./scripts/sync_projects.sh --root "$PWD" --projects "$PWD/projects.txt"
```

---

## 🐛 トラブルシューティング

### Codex が起動しない

```bash
# スクリプトの実行権限確認
ls -la ~/.claude/scripts/handoff-to-codex.sh

# 実行権限付与
chmod +x ~/.claude/scripts/handoff-to-codex.sh
```

### シンボリックリンクが作成されない

```bash
# 既存リンクを削除
rm ~/.claude/CLAUDE.md
rm ~/.codex/AGENTS.md

# 再度リンク作成
./scripts/link_dotfiles.sh --root "$PWD" --map "$PWD/mappings.txt" --force
```

### /handoff コマンドが見つからない

```bash
# コマンドファイル確認
ls ~/.claude/commands/handoff.md

# 存在しない場合、シンボリックリンク再作成
./scripts/link_dotfiles.sh --root "$PWD" --map "$PWD/mappings.txt"
```

### tmux で新しい pane が開かない

```bash
# tmux セッション内か確認
echo $TMUX

# 空の場合、tmux セッション開始
tmux new -s dev

# または環境変数設定
export HANDOFF_LAUNCH_METHOD=terminal-tab
```

### Windows 特有の問題

#### 管理者権限エラー

```powershell
# PowerShell を右クリック → "管理者として実行"
# その後、再度リンクスクリプトを実行
```

#### 実行ポリシーエラー

```powershell
# エラー: このシステムではスクリプトの実行が無効になっています

# 解決方法:
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

# または一時的にバイパス:
powershell -ExecutionPolicy Bypass -File scripts\link_dotfiles.ps1 ...
```

#### シンボリックリンクが作成できない

```powershell
# スクリプトは自動的にハードリンクまたはジャンクションにフォールバック
# 確認:
Get-Item $env:USERPROFILE\.claude\CLAUDE.md | Select-Object LinkType

# LinkType が表示されれば成功
```

#### Windows Terminal でタブが開かない

```powershell
# Windows Terminal がインストールされているか確認
winget list --name "Windows Terminal"

# インストール:
winget install --id Microsoft.WindowsTerminal -e

# 環境変数設定:
$env:HANDOFF_LAUNCH_METHOD = "terminal-tab"
```

---

## 📖 詳細ドキュメント

- `AGENTS.md` - 共通の Core Philosophy
- `CLAUDE.md` - Claude Code 専用設定（実装担当）
- `CODEX.md` - Codex 専用設定（レビュー・管理担当）
- `docs/HANDOFF_WORKFLOW.md` - /handoff コマンド詳細ガイド
- `docs/WINDOWS_SETUP.md` - Windows セットアップガイド
- `docs/SYNCTHING_SETUP.md` - Syncthing で P2P 同期
- `claudecode/commands/handoff.md` - /handoff コマンド仕様
- `codex/skills/auto-review/review-handoff.md` - 自動レビュー詳細

---

## 🔄 更新方法

### 設定を更新したい

1. このリポジトリで設定ファイルを編集
2. Git にコミット・プッシュ
3. シンボリックリンク経由で自動反映

```bash
# 例: Claude Code の設定を更新
vim CLAUDE.md

git add CLAUDE.md
git commit -m "feat: update Claude Code configuration"
git push origin main

# シンボリックリンクなので即座に反映される
```

### 新しいマシンでセットアップ

**Mac/Linux:**

```bash
# 1. リポジトリクローン
git clone https://github.com/Nicolas0315/dotfiles_nico.git
cd dotfiles_nico

# 2. シンボリックリンク作成
./scripts/link_dotfiles.sh --root "$PWD" --map "$PWD/mappings.txt"

# 3. tmux 設定
echo 'export HANDOFF_LAUNCH_METHOD=tmux' >> ~/.zshrc
source ~/.zshrc

# 完了！
```

**Windows:**

```powershell
# 1. PowerShell を管理者権限で起動
# 2. リポジトリクローン
cd $env:USERPROFILE\work
git clone https://github.com/Nicolas0315/dotfiles_nico.git
cd dotfiles_nico

# 3. 実行ポリシー設定
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

# 4. シンボリックリンク作成
powershell -ExecutionPolicy Bypass -File scripts\link_dotfiles.ps1 `
  -DotfilesRoot "$PWD" `
  -MappingFile "$PWD\mappings.txt"

# 5. 環境変数設定
notepad $PROFILE
# 以下を追加: $env:HANDOFF_LAUNCH_METHOD = "terminal-tab"

# 完了！
```

---

## 🔄 Syncthing で P2P 同期（推奨）

複数デバイス間で dotfiles をリアルタイム同期したい場合、**Syncthing** の使用を推奨します。

### Syncthing とは

- **P2P ファイル同期**: クラウドを介さず、デバイス間で直接同期
- **プライバシー重視**: データは自分のデバイス間でのみ移動
- **暗号化通信**: すべての通信が TLS で暗号化
- **無料・オープンソース**: 完全に無料で容量制限なし

### クイックセットアップ

#### 1. インストール

**Mac:**
```bash
brew install syncthing
brew services start syncthing
```

**Windows:**
[公式サイト](https://syncthing.net/downloads/)からインストーラーをダウンロード

#### 2. デバイス接続

1. 両方のデバイスで Syncthing を起動
2. Web UI を開く: `http://127.0.0.1:8384`
3. デバイス ID を交換して接続

#### 3. dotfiles_nico を共有

1. "Add Folder" で dotfiles_nico ディレクトリを追加
2. 接続したデバイスと共有
3. `.stignore` で `.git` ディレクトリを除外（重要）

### Git との併用

- **Syncthing**: リアルタイム同期（日常的な編集）
- **Git**: バージョン管理・バックアップ（重要な変更時）

```
Mac ←─ Syncthing ─→ Windows
 │                      │
 └──── Git (GitHub) ────┘
```

### 詳細ガイド

完全なセットアップ手順、トラブルシューティング、ベストプラクティスは：

📘 **[docs/SYNCTHING_SETUP.md](docs/SYNCTHING_SETUP.md)**

---

## 🌟 ベストプラクティス

### 1. 実装は Claude Code、レビューは Codex

```bash
# 実装フェーズ
claude code
/plan
/tdd
[実装...]
/handoff

# レビューフェーズ（自動）
# Codex が自動起動してレビュー
```

### 2. /handoff を習慣化

実装完了したら必ず `/handoff` を実行：
- コンテキストが自動保存される
- レビューが自動実行される
- 品質が一定に保たれる

### 3. tmux を活用

tmux 使用で、Claude Code と Codex を並べて作業：
- 左: Claude Code（実装）
- 右: Codex（レビュー）

### 4. Git は Codex に任せる

コミット・PR 作成は Codex に任せる：
- Conventional Commits 形式を自動適用
- 包括的なコミットメッセージ
- PR サマリー自動生成

---

## 📜 ライセンス

MIT License

---

## 🤝 コントリビューション

Issues、Pull Requests 歓迎です！

1. Fork this repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📞 サポート

問題が発生した場合：

1. `docs/HANDOFF_WORKFLOW.md` を確認
2. トラブルシューティングセクションを確認
3. GitHub Issues で質問

---

**Happy Coding with Claude Code & Codex! 🚀**
