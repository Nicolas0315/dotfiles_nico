# Handoff Workflow - Claude Code から Codex への自動引き継ぎ

## 概要

Claude Code（実装担当）から Codex（レビュー・管理担当）への自動引き継ぎを実現する `/handoff` コマンドの使い方。

---

## 基本ワークフロー

### 1. 実装フェーズ（Claude Code）

```bash
# Claude Code で実装作業
claude code

# 実装作業
/plan              # 計画作成
/tdd               # TDD実践
[コーディング...]  # 機能実装
/build-fix         # ビルドエラー修正（必要に応じて）
```

### 2. 完了チェック

実装完了前の確認：
- [ ] すべてのテスト合格（80%以上カバレッジ）
- [ ] ビルド成功（型エラーなし）
- [ ] イミュータビリティ原則遵守
- [ ] console.log 削除済み

### 3. ハンドオフ実行

```bash
/handoff
```

プロンプトに回答：
- **実装サマリー**: 何を実装したか（1-3文）
- **変更ファイル**: 自動検出（確認のみ）
- **テストカバレッジ**: 現在のカバレッジ
- **既知の問題**: TODO や制限事項

### 4. 自動処理

システムが自動的に：
1. コンテキストを `~/.claude/handoff.json` に保存
2. Codex セッションを起動（tmux または新規タブ）
3. Codex が自動レビュー開始

### 5. レビューフェーズ（Codex - 自動）

Codex が自動的に：
```bash
# 自動実行される
codex review-handoff

# 実施内容：
1. コードレビュー (/code-review)
2. セキュリティ監査
3. テスト検証
4. ドキュメントチェック
5. 結果レポート生成
```

### 6. アクション選択

Codex がレビュー結果を元に選択肢を提示：
- 問題を修正する
- ドキュメントを更新する
- コミットを作成する
- PR を作成する

---

## 使用例

### シナリオ: ユーザー認証機能の実装

#### Phase 1: 実装（Claude Code）

```bash
# Claude Code セッション
$ claude code

# 1. 計画
/plan

# User provides requirements:
# "JWT ベースのユーザー認証を実装"

# Planner creates implementation plan

# 2. TDD開始
/tdd

# 3. 実装
# - src/auth/login.ts
# - src/auth/register.ts
# - tests/auth.test.ts

# 4. テスト実行
npm test
# Coverage: 87% ✓

# 5. ビルド確認
npm run build
# Success ✓

# 6. ハンドオフ
/handoff
```

#### ハンドオフダイアログ

```
/handoff

実装サマリーを入力してください:
> JWT ベースのユーザー認証を実装。login と register エンドポイント追加。

変更ファイル（自動検出）:
  • src/auth/login.ts
  • src/auth/register.ts
  • tests/auth.test.ts

テストカバレッジ: 87%

既知の問題やTODO:
> レート制限未実装

✓ ハンドオフコンテキスト保存完了
✓ Codex セッション起動中...
```

#### Phase 2: レビュー（Codex - 自動）

```bash
# Codex が新しい tmux pane で自動起動

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 Handoff Received from Claude Code
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📌 Implementation Summary:
JWT ベースのユーザー認証を実装。login と register エンドポイント追加。

📁 Changed Files (3):
  • src/auth/login.ts
  • src/auth/register.ts
  • tests/auth.test.ts

📊 Test Coverage: 87%

🌿 Branch: feature/auth

⚠️  Known Issues:
  • レート制限未実装

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔍 Starting Comprehensive Review...

1. Code Quality Review...
   ✓ PASS - 良好なコード品質

2. Security Audit...
   ⚠️  1 MEDIUM issue:
   - レート制限未実装 (login.ts:45)

   ⚠️  1 LOW issue:
   - JWT シークレットが短い (config.ts:12)

3. Test Verification...
   ✓ PASS - 87% coverage
   ⚠️  E2E test 推奨（ログインフロー）

4. Documentation Check...
   ⚠️  Update needed:
   - README.md (認証セットアップ手順)
   - API.md (/login, /register エンドポイント)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📝 Review Summary:
Overall: ✓ APPROVED with minor fixes

Critical: 0
High: 0
Medium: 1 (rate limiting)
Low: 1 (JWT secret)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

次のアクションを選択してください:
1. Medium/Low 問題を Issue 化して、ドキュメント更新後コミット（推奨）
2. すべての問題修正後コミット
3. そのままコミット（問題を TODO として記録）
4. 詳細レポート表示
```

#### ユーザー選択: オプション1

```
選択: 1

✓ GitHub Issue #45 作成: "認証にレート制限追加"
✓ GitHub Issue #46 作成: "JWT シークレット強化"

📝 ドキュメント更新中...
✓ README.md 更新（認証セットアップ手順追加）
✓ API.md 更新（エンドポイント仕様追加）

📦 コミット作成中...

git commit -m "feat: JWT ベースのユーザー認証実装

- login と register エンドポイント追加
- JWT トークン生成・検証機能
- 認証ミドルウェア実装
- テストカバレッジ 87%

TODO:
- レート制限実装 (#45)
- JWT シークレット強化 (#46)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"

✓ コミット完了 (abc1234)

PR を作成しますか? (y/n): y

✓ PR #123 作成完了
  URL: https://github.com/user/repo/pull/123

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ ハンドオフ完了
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## 設定

### tmux 連携（推奨）

tmux 使用時、自動的に新しい pane で Codex が起動：

```bash
# ~/.bashrc または ~/.zshrc
export HANDOFF_LAUNCH_METHOD=tmux
```

### Terminal タブモード

tmux 未使用時、新しいターミナルタブで起動：

```bash
export HANDOFF_LAUNCH_METHOD=terminal-tab
```

### 手動モード

自動起動を無効化：

```bash
export HANDOFF_LAUNCH_METHOD=manual
```

この場合、手動で実行：
```bash
codex review-handoff
```

---

## セットアップ

### 1. スクリプトのシンボリックリンク作成

```bash
mkdir -p ~/.claude/scripts
ln -sf ~/work/dotfiles_nico/scripts/handoff-to-codex.sh ~/.claude/scripts/
```

### 2. Codex スキルのシンボリックリンク作成

```bash
mkdir -p ~/.codex/skills
ln -sf ~/work/dotfiles_nico/codex/skills/auto-review ~/.codex/skills/
```

### 3. `codex` コマンドエイリアス設定（オプション）

```bash
# ~/.bashrc または ~/.zshrc
alias codex='claude code --profile codex'

# または専用の codex CLI がある場合はそれを使用
```

---

## トラブルシューティング

### Codex が起動しない

```bash
# スクリプトが実行可能か確認
ls -la ~/.claude/scripts/handoff-to-codex.sh

# 実行権限付与
chmod +x ~/.claude/scripts/handoff-to-codex.sh
```

### ハンドオフファイルが見つからない

```bash
# ハンドオフファイル確認
cat ~/.claude/handoff.json

# 存在しない場合、Claude Code で /handoff を再実行
```

### tmux が認識されない

```bash
# tmux セッション内か確認
echo $TMUX

# 空の場合、tmux セッションを開始
tmux new -s dev
```

### 手動で Codex レビュー実行

```bash
cd /path/to/project
codex review-handoff
```

---

## ファイル構成

```
dotfiles_nico/
├── CLAUDE.md                                    # Claude Code 設定
├── CODEX.md                                     # Codex 設定
├── claudecode/
│   └── commands/
│       └── handoff.md                           # /handoff コマンド定義
├── codex/
│   └── skills/
│       └── auto-review/
│           └── review-handoff.md                # 自動レビュースキル
├── scripts/
│   ├── handoff-to-codex.sh                      # ハンドオフスクリプト
│   └── review-handoff-wrapper.sh                # レビューラッパー
└── docs/
    └── HANDOFF_WORKFLOW.md                      # このドキュメント

~/.claude/
├── handoff.json                                 # ハンドオフコンテキスト
└── scripts/
    └── handoff-to-codex.sh -> dotfiles_nico/scripts/handoff-to-codex.sh

~/.codex/
├── handoff.json                                 # Codex側コンテキスト
└── skills/
    └── auto-review -> dotfiles_nico/codex/skills/auto-review
```

---

## 利点

### 1. コンテキスト保持
実装の全てのコンテキストが自動的に引き継がれ、情報の損失なし

### 2. 一貫した品質
すべてのハンドオフで同じレビュープロセスが実行される

### 3. 時間節約
手動でのコンテキスト共有、レビュー依頼が不要

### 4. 明確な役割分担
Claude Code（実装）と Codex（レビュー）の責務が明確

### 5. 自動化された品質チェック
セキュリティ、テスト、ドキュメントの包括的チェック

---

## 次のステップ

1. 実際のプロジェクトで `/handoff` を試す
2. レビュープロセスをカスタマイズ（必要に応じて）
3. チーム全体で採用を検討
4. フィードバックを元に改善

---

## 関連ドキュメント

- `~/.claude/commands/handoff.md` - /handoff コマンド詳細
- `~/.codex/skills/auto-review/review-handoff.md` - 自動レビュースキル詳細
- `CLAUDE.md` - Claude Code 設定
- `CODEX.md` - Codex 設定
