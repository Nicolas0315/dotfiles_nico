# AGENTS.md

このファイルは、New Browse プロジェクトでAIエージェントが効果的に作業するためのガイドラインです。

# Agent Instructions

- このリポジトリで動作するすべてのAIエージェントは日本語で回答すること
- コードは英語命名を使用してよいが、説明コメント・レビューは日本語で行うこと
- 不明点がある場合も日本語で質問すること
- UI/ドキュメント/ユーザー向けメッセージは日本語で記述すること

---

## 📚 リファレンスリソース

このプロジェクトには `C:\Users\ogosh\Desktop\eiai\_refs\everything-claude-code` に、Claude Code のベストプラクティス集が配置されています。

### リファレンスの構成

```bash
_refs/everything-claude-code/
├── agents/           # サブエージェント定義（planner, architect, code-reviewer等）
├── skills/           # ワークフロー定義とドメイン知識
├── commands/         # スラッシュコマンド（/tdd, /plan, /code-review等）
├── rules/            # 常に従うべきガイドライン
├── hooks/            # トリガーベースの自動化
├── mcp-configs/      # MCPサーバー設定
└── examples/         # 設定例
```

### 活用方法

#### 1. サブエージェントの参照

複雑なタスクを実行する際は、`_refs/everything-claude-code/agents/` 内のエージェント定義を参照してください：

- **planner.md** - 機能実装の計画立案
- **architect.md** - システム設計の意思決定
- **code-reviewer.md** - コード品質とセキュリティレビュー
- **tdd-guide.md** - テスト駆動開発
- **security-reviewer.md** - 脆弱性分析
- **build-error-resolver.md** - ビルドエラーの修正
- **e2e-runner.md** - E2Eテスト
- **refactor-cleaner.md** - デッドコードのクリーンアップ
- **doc-updater.md** - ドキュメント同期

#### 2. スキルの参照

ワークフロー定義やベストプラクティスは `_refs/everything-claude-code/skills/` を参照：

- **coding-standards.md** - 言語別ベストプラクティス
- **frontend-patterns.md** - React、TypeScriptパターン
- **tdd-workflow/** - TDD方法論
- **security-review/** - セキュリティチェックリスト

#### 3. ルールの参照

常に従うべきガイドラインは `_refs/everything-claude-code/rules/` を参照：

- **security.md** - セキュリティチェック（必須）
- **coding-style.md** - イミュータビリティ、ファイル構成
- **testing.md** - TDD、80%カバレッジ要件
- **git-workflow.md** - コミットフォーマット、PRプロセス
- **agents.md** - サブエージェントへの委譲タイミング
- **performance.md** - モデル選択、コンテキスト管理

#### 4. 使用例

```markdown
# 複雑な機能実装時
1. `_refs/everything-claude-code/agents/planner.md` を参照して実装計画を立案
2. `_refs/everything-claude-code/skills/tdd-workflow/` に従ってテスト駆動開発
3. `_refs/everything-claude-code/agents/code-reviewer.md` でコードレビュー
4. `_refs/everything-claude-code/agents/security-reviewer.md` でセキュリティチェック
```

### 重要な注意事項

**コンテキストウィンドウ管理**:

- すべてのMCPを同時に有効化しないこと
- 200kコンテキストウィンドウが70kまで縮小する可能性があります
- 推奨設定:
  - 20-30個のMCPを設定
  - プロジェクトごとに10個未満を有効化
  - アクティブなツールは80個未満

---

## 🧭 重要ドキュメント

- `README.md` - プロジェクト概要 / 主要機能
- `VISION.md` - プロジェクトのビジョンと目標
- `CHANGELOG.md` - 変更履歴
- `docs/DEVELOPMENT.md` - 開発ガイドライン
- `docs/ARCHITECTURE.md` - システムアーキテクチャ
- `docs/PROJECT_STRUCTURE.md` - プロジェクト構造
- `docs/GIT_WORKFLOW.md` - Gitワークフロー
- `docs/VERSIONING.md` - バージョン管理
- `docs/PRIVACY_SECURITY.md` - プライバシーとセキュリティ
- `docs/BROWSER_KNOWLEDGE_INTEGRATION.md` - ブラウザと知識管理の統合
- `docs/EXTERNAL_INTEGRATIONS.md` - 外部サービス統合
- `docs/CLI_TOOLS.md` - CLIツールガイド
- `docs/GITHUB_ISSUES.md` - GitHub Issues管理
- `docs/CONTRIBUTING.md` - コントリビューションガイド

---

## プロジェクト概要

**New Browse** は、メモ帳、LLM、データベースを統合した次世代ブラウザです。視認性の高いダッシュボードとLLMを使った知識整理機能を備えています。

### ビジョン

**「ものを調べる体験を知識を蓄えていく体験へと進化させる」**

Notion + Obsidian + Chrome + NotebookLM を統合した次世代の知識管理ブラウザを目指しています。

### 主要機能

- 📊 **ダッシュボード**: すべての情報を一目で確認できる統合ダッシュボード
- 🌐 **ブラウザ機能**: タブ管理、ナビゲーション、アドレスバー、ブックマーク・記事保存
- ✅ **ToDo管理**: 看板方式（カンバン）のToDoボードでタスクを視覚的に管理
- 📝 **メモ帳機能**: シンプルなメモエディタ、サイドバーでのクイックアクセス
- 📄 **ブロックエディタ**: Notion風のブロックベースエディタで柔軟なコンテンツ作成
- 🧠 **知識整理**: LLMのパワーを使って読んだもの・見たもの・感じたことを整理・可視化
- 🤖 **LLM統合**: AIアシスタントとのチャット機能（クラウドAPI、オプション）
- 💾 **データベース統合**: SQLiteによるメモ、ブックマーク、履歴、ToDo、記事、知識エントリー、ページの永続化

### 設計原則

- **シンプルさ優先**: 無駄な機能は削ぎ落とし、メンテナンス性を重視
- **YAGNI原則**: 必要になるまで実装しない
- **最小限の依存関係**: 必要な依存関係のみを使用
- **プライバシー第一**: 完全ローカル動作、外部通信なし（オプション機能を除く）

### 主要技術スタック

- **フロントエンド**: React 18 + TypeScript + Vite
- **バックエンド**: Tauri (Rust)
- **データベース**: SQLite (rusqlite) - 完全ローカル
- **UI**: カスタムCSS（ダークテーマ）
- **テスト**: Vitest + React Testing Library

### ディレクトリ構造（主要）

```
new-browse/
├── src/                    # フロントエンド（React + TypeScript）
│   ├── components/         # Reactコンポーネント
│   ├── services/           # ビジネスロジック・API
│   ├── hooks/              # カスタムフック
│   ├── types/              # TypeScript型定義
│   ├── utils/              # ユーティリティ関数
│   ├── constants/          # 定数
│   └── test/               # テストヘルパー
├── src-tauri/              # バックエンド（Rust）
│   ├── src/                # Rustソースコード
│   ├── Cargo.toml          # Rust依存関係
│   └── tauri.conf.json     # Tauri設定
├── docs/                   # ドキュメント
├── scripts/                # PowerShellスクリプト
├── .github/                # GitHub設定（Issue/PRテンプレート）
└── tests/                  # テストファイル
```

---

## 開発環境のヒント

### セットアップ

```bash
# 初回セットアップ（依存関係インストール、環境確認）
npm run setup

# 環境チェック
npm run check
```

### 開発サーバー

```bash
# Tauri開発モード（推奨）
npm run tauri:dev

# Vite開発モード（フロントエンドのみ）
npm run dev
```

### テスト

```bash
# テスト実行
npm run test

# ウォッチモード
npm run test:watch

# カバレッジ
npm run test:coverage

# UIモード
npm run test:ui

# CI用（ウォッチなし）
npm run test:ci
```

### ビルド

```bash
# フロントエンドビルド
npm run build

# Tauriアプリビルド
npm run tauri:build
```

### リント・クリーンアップ

```bash
# リント実行
npm run lint

# クリーンアップ（node_modules、dist、target削除）
npm run clean
```

### GitHub管理

```bash
# GitHub CLIツール
npm run github

# 使用例
npm run github issues-create    # Issue作成
npm run github issues-list      # Issue一覧
npm run github pr-create        # PR作成
npm run github release-create   # リリース作成
```

詳細は `docs/CLI_TOOLS.md` と `docs/GITHUB_ISSUES.md` を参照してください。

---

## 主要ファイル/モジュール

### フロントエンド（React + TypeScript）

- `src/App.tsx` - メインアプリケーションコンポーネント
- `src/main.tsx` - エントリーポイント
- `src/components/` - UIコンポーネント
- `src/services/` - ビジネスロジック（データベース、LLM、ブラウザ）
- `src/hooks/` - カスタムReactフック
- `src/types/` - TypeScript型定義
- `src/utils/` - ユーティリティ関数

### バックエンド（Rust + Tauri）

- `src-tauri/src/main.rs` - Tauriメインエントリーポイント
- `src-tauri/src/commands.rs` - Tauriコマンド（フロントエンド↔バックエンド通信）
- `src-tauri/src/database.rs` - SQLiteデータベース操作
- `src-tauri/Cargo.toml` - Rust依存関係
- `src-tauri/tauri.conf.json` - Tauri設定

### 設定ファイル

- `vite.config.ts` - Vite設定
- `vitest.config.ts` - Vitest設定
- `tsconfig.json` - TypeScript設定
- `package.json` - npm依存関係とスクリプト

---

## コーディングスタイル

### TypeScript/React

- **関数コンポーネント**: クラスコンポーネントは使用しない
- **型安全性**: `any` の使用を避け、明示的な型注釈を優先
- **命名規則**:
  - 変数・関数: `camelCase`
  - コンポーネント・型: `PascalCase`
  - 定数: `UPPER_SNAKE_CASE`
  - ファイル: `kebab-case.tsx` または `PascalCase.tsx`（コンポーネント）
- **フック**: カスタムフックは `use` プレフィックスを使用
- **イミュータビリティ**: 状態の直接変更を避ける

### Rust

- **命名規則**:
  - 変数・関数: `snake_case`
  - 型・構造体: `PascalCase`
  - 定数: `UPPER_SNAKE_CASE`
- **エラーハンドリング**: `Result<T, E>` を使用
- **所有権**: Rustの所有権システムを理解して使用

### CSS

- **ダークテーマ**: デフォルトでダークテーマを使用
- **カスタムプロパティ**: CSS変数を活用
- **BEM記法**: 推奨（Block__Element--Modifier）

---

## テスト手順

### ユニットテスト

```bash
# すべてのテストを実行
npm run test

# 特定のファイルをテスト
npm run test -- src/components/Dashboard.test.tsx

# ウォッチモード
npm run test:watch
```

### カバレッジ

```bash
# カバレッジレポート生成
npm run test:coverage

# カバレッジ目標: 80%以上
```

### E2Eテスト

```bash
# Tauriアプリを起動してE2Eテスト
npm run tauri:dev
# 別ターミナルでテスト実行
npm run test:e2e
```

---

## コミット/PR

### コミット規約

Conventional Commits形式を使用：

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Type**:
- `feat`: 新機能
- `fix`: バグ修正
- `docs`: ドキュメント変更
- `style`: コードスタイル変更（機能に影響なし）
- `refactor`: リファクタリング
- `test`: テスト追加・修正
- `chore`: ビルド・ツール変更

**例**:
```
feat(dashboard): ダッシュボードにToDoウィジェット追加

- ToDoウィジェットコンポーネントを実装
- ダッシュボードレイアウトに統合
- テスト追加

Closes #123
```

### ブランチ戦略

- `main` - 安定版（リリース可能）
- `develop` - 開発版
- `feature/*` - 新機能開発
- `fix/*` - バグ修正
- `docs/*` - ドキュメント更新

詳細は `docs/GIT_WORKFLOW.md` を参照してください。

---

## GitHub Issues管理

### Issue作成

```bash
# CLIツールでIssue作成
npm run github issues-create

# または手動でGitHub UIから作成
# テンプレート: .github/ISSUE_TEMPLATE/
```

### Issueラベル

- `bug` - バグ報告
- `feature` - 新機能リクエスト
- `enhancement` - 既存機能の改善
- `documentation` - ドキュメント関連
- `good first issue` - 初心者向け
- `help wanted` - ヘルプ募集
- `priority: high/medium/low` - 優先度

詳細は `docs/GITHUB_ISSUES.md` を参照してください。

---

## セキュリティとプライバシー

### プライバシー原則

- **完全ローカル動作**: すべてのデータはローカルのSQLiteデータベースに保存
- **外部通信なし**: 開発会社やサーバーとの通信は一切行わない（オプション機能を除く）
- **データ収集なし**: 使用状況、クラッシュレポート、個人情報の収集は一切行わない

### 唯一の外部通信

- **Webページの表示（iframe）**: ブラウザとしての機能。データは保存されません
- **LLM API（オプション）**: ユーザーが明示的に設定した場合のみ
- **Googleカレンダー連携（オプション）**: ユーザーが接続した場合のみ

### セキュリティチェックリスト

- APIキーは環境変数で管理（`.env`）
- SQLインジェクション対策（パラメータ化クエリ）
- XSS対策（React自動エスケープ）
- CSRF対策（Tauri CSP設定）

詳細は `docs/PRIVACY_SECURITY.md` を参照してください。

---

## よくあるタスク

### 新しいコンポーネント追加

1. `src/components/` に新しいコンポーネントファイルを作成
2. TypeScript型定義を `src/types/` に追加（必要に応じて）
3. テストファイルを作成（`*.test.tsx`）
4. `App.tsx` または親コンポーネントにインポート

### 新しいTauriコマンド追加

1. `src-tauri/src/commands.rs` に新しいコマンドを実装
2. `src-tauri/src/main.rs` の `tauri::Builder` にコマンドを登録
3. フロントエンド側で `invoke()` を使用してコマンドを呼び出し
4. TypeScript型定義を追加

### データベーススキーマ変更

1. `src-tauri/src/database.rs` でマイグレーションを実装
2. 新しいテーブル/カラムを追加
3. Rust構造体を更新
4. フロントエンド側の型定義を更新

### 外部サービス統合

1. `docs/EXTERNAL_INTEGRATIONS.md` を参照
2. 必要に応じて認証フローを実装
3. プライバシーポリシーを更新
4. ユーザーに明示的な同意を求める

---

## 📊 プロジェクト状態管理

**重要**: このセクションは、機能の実装・変更時に必ず更新してください。

**最終更新**: 2026-01-19（リファレンスリソース（everything-claude-code）の活用方法を追加）

### ✅ 実装済み機能

#### コア機能

- プロジェクト構造とセットアップスクリプト
- Tauri + React + TypeScript基盤
- Vite開発環境
- Vitest + React Testing Libraryテスト環境
- CLIツール（setup、check、lint、clean、github）
- GitHub Issues管理スクリプト

#### ドキュメント

- プロジェクト概要（README.md）
- ビジョン（VISION.md）
- 開発ガイドライン（docs/DEVELOPMENT.md）
- アーキテクチャ設計（docs/ARCHITECTURE.md）
- プロジェクト構造（docs/PROJECT_STRUCTURE.md）
- Gitワークフロー（docs/GIT_WORKFLOW.md）
- バージョン管理（docs/VERSIONING.md）
- プライバシーとセキュリティ（docs/PRIVACY_SECURITY.md）
- CLIツールガイド（docs/CLI_TOOLS.md）
- GitHub Issues管理（docs/GITHUB_ISSUES.md）
- コントリビューションガイド（docs/CONTRIBUTING.md）

### 🚧 進行中/今後

#### Phase 1: 基本機能

- [ ] ダッシュボードUI実装
- [ ] ブラウザ機能（タブ管理、ナビゲーション）
- [ ] SQLiteデータベース統合
- [ ] メモ帳機能
- [ ] ブックマーク機能

#### Phase 2: 高度な機能

- [ ] ToDo管理（カンバンボード）
- [ ] ブロックエディタ（Notion風）
- [ ] LLM統合（チャット機能）
- [ ] 知識整理機能

#### Phase 3: 統合と最適化

- [ ] Googleカレンダー連携
- [ ] パフォーマンス最適化
- [ ] E2Eテスト
- [ ] リリースビルド

### 📝 更新ルール

1. **新機能実装時**: 「実装済み機能」に追加
2. **機能変更時**: 既存項目を更新
3. **バグ修正時**: 該当機能の説明を更新
4. **新タスク追加時**: 「進行中/今後」に追加
5. **優先度変更時**: 適切なセクションへ移動

**更新時の注意事項**:
- 更新日時を必ず更新する
- 実装済み機能は具体的に記述する（該当ファイルまで明記）
- 完了したタスクは「実装済み機能」に移動する

---

**このセクションの目的**: Agentがプロジェクトの現在の状態を正確に把握し、適切な判断と実装を行うための情報を提供します。
