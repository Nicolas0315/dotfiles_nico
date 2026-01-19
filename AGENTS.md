# AGENTS.md

このファイルは、NEXI / EIAI 動画分析・インフルエンサーマッチング基盤でAIエージェントが効果的に作業するためのガイドラインです。

# Agent Instructions

- このリポジトリで動作するすべてのAIエージェントは日本語で回答すること
- コードは英語命名を使用してよいが、説明コメント・レビューは日本語で行うこと
- 不明点がある場合も日本語で質問すること
- UI/ドキュメント/ユーザー向けメッセージは日本語で記述すること

## 📦 Agent Skills

このプロジェクトは [Agent Skills](https://agentskills.io) オープンスタンダードに対応しています。

### 利用可能なスキル

| スキル | 説明 | パス |
|--------|------|------|
| **video-analysis** | AI動画分析 | `.skills/video-analysis/SKILL.md` |
| **api-development** | FastAPIバックエンド開発 | `.skills/api-development/SKILL.md` |
| **ctr-optimization** | CTR最適化分析 | `.skills/ctr-optimization/SKILL.md` |
| **project-manager** | プロジェクト整理/優先順位付け | `.skills/project-manager/SKILL.md` |
| **agent-browser** | ブラウザ自動化 | `.skills/agent-browser/SKILL.md` |
| **vibium** | ブラウザ自動化（MCP統合） | `.skills/vibium/SKILL.md` |

詳細は `.skills/README.md` を参照してください。

---

## 🧭 重要ドキュメント

- `README.md` - プロジェクト概要 / 主要コンポーネント
- `docs/README.md` - ドキュメント索引
- `docs/project/ARCHITECTURE.md` - 現行アーキテクチャ
- `docs/project/ARCHITECTURE_REDESIGN.md` - FastAPI + htmx 再設計
- `docs/project/REFACTORING_PROGRESS.md` - リファクタ進捗
- `docs/api/API_REFERENCE.md` - APIリファレンス
- `docs/testing/README.md` - テスト手順
- `docs/development/COMMIT_POLICY.md` - コミット規約
- `docs/project/GIT_WORKFLOW.md` - ブランチ/PR運用
- `docs/operations/MCP_GUIDE.md` - MCPガイド
- `docs/operations/MCP_SETUP.md` - MCPセットアップ
- `docs/planning/TODO.md` - 優先タスク
- `docs/issues/ISSUES_TIMELINE.md` - Issueタイムライン

---

## プロジェクト概要

UGC動画のAI分析、クリエイティブのCTR最適化、インフルエンサー管理/マッチング、配信実績の紐付け・レポーティングまでを一体化したプラットフォームです。

### 主要コンポーネント

- `api/`: FastAPIバックエンド（API + Jinja2/htmx UI）
- `src/video_analysis/`: 分析コア、LLMプロバイダー、パイプライン
- `dashboard/`: Next.js UI（App Router）
- `orchestrator/`: Fastify + Redis オーケストレーター（任意）
- `dashboards/`: Streamlitダッシュボード群（任意/レガシー）

### 主要技術スタック

- **バックエンド**: Python 3.12+（3.13+対応）, FastAPI, SQLAlchemy, Jinja2, htmx
- **AI/分析**: Google Gemini (gemini-2.5-flash), OpenAI GPT-4 Vision, Whisper, MediaPipe, YOLO
- **DB**: SQLite（開発）, Supabase/PostgreSQL（本番）
- **フロントエンド**: Next.js 15, TypeScript, Tailwind CSS
- **オーケストレーション**: Fastify (TS), Redis（任意）
- **外部連携**: Apify（TikTok/サイトスクレイピング）

### ディレクトリ構造（主要）

```
video-analysis/
├── api/                    # FastAPI アプリ（routes/services/templates/static）
├── auth/                   # 認証/認可
├── config/                 # 設定/環境変数
├── database/               # DBモデル/マネージャ
├── src/video_analysis/     # 分析コア/LLM/パイプライン
├── dashboard/              # Next.js ダッシュボード
├── orchestrator/           # TSオーケストレーター（任意）
├── dashboards/             # Streamlit（任意/レガシー）
├── scripts/                # バッチ/運用スクリプト
├── docs/                   # ドキュメント
└── uploads/ thumbnails/ exports/ logs/  # 生成物
```

---

## 開発環境のヒント

### APIサーバー（FastAPI）

```bash
python -m uvicorn api.main:app --reload --host 0.0.0.0 --port 8000
```

### Jinja2/htmx UI

- APIサーバー起動後、`http://localhost:8000/` にアクセス
- テンプレート: `api/templates/`

### Next.jsダッシュボード

```bash
cd dashboard
npm install
npm run dev
```

### オーケストレーター（任意）

```bash
cd orchestrator
npm install
npm run dev
```

### Streamlitダッシュボード（任意）

```bash
python main.py dashboard
```

### バッチ分析/紐付け

```bash
python analyze_and_store.py /path/to/videos
python scripts/batch_analyze_and_link.py
```

### MCP設定（任意）

- 設定例: `.cursor/mcp.json.example`
- セットアップ: `scripts/setup_mcp.sh` / `scripts/setup_mcp.ps1`

### Windows一括起動

```powershell
.\start_all_servers.bat
.\stop_all_servers.bat
```

### agent-browser（ブラウザ自動化）

このプロジェクトには `agent-browser` が統合されています。AIエージェントがブラウザ操作を自動化する際に使用できます。

#### インストール

```bash
cd video-analysis
npm install
agent-browser install  # Chromiumをダウンロード
```

#### 基本的な使用方法

```bash
# URLを開く
agent-browser open http://localhost:8000

# スナップショットを取得（AIエージェント推奨）
agent-browser snapshot -i --json  # インタラクティブ要素のみ、JSON形式

# 要素をクリック（refを使用）
agent-browser click @e2

# フォームに入力
agent-browser fill @e3 "test@example.com"

# テキストを取得
agent-browser get text @e1

# スクリーンショット
agent-browser screenshot page.png

# ブラウザを閉じる
agent-browser close
```

#### AIエージェント向け推奨ワークフロー

1. **ページを開いてスナップショット取得**
   ```bash
   agent-browser open <url>
   agent-browser snapshot -i --json
   ```

2. **スナップショットからrefを特定**
   - スナップショットには各要素に `@e1`, `@e2` などのrefが付与されます
   - AIエージェントはこのrefを使用して要素を操作します

3. **refを使用して操作**
   ```bash
   agent-browser click @e2
   agent-browser fill @e3 "input text"
   ```

4. **ページ変更後は再スナップショット**
   ```bash
   agent-browser snapshot -i --json
   ```

#### セッション管理

複数のブラウザインスタンスを同時に管理できます：

```bash
# セッションを指定
agent-browser --session agent1 open site-a.com
agent-browser --session agent2 open site-b.com

# セッション一覧
agent-browser session list
```

#### 詳細なコマンド

すべてのコマンドは `agent-browser --help` で確認できます。主要なコマンド：

- **ナビゲーション**: `open`, `back`, `forward`, `reload`
- **操作**: `click`, `fill`, `type`, `hover`, `scroll`
- **情報取得**: `get text`, `get html`, `get url`, `get title`
- **待機**: `wait <selector>`, `wait <ms>`
- **デバッグ**: `screenshot`, `console`, `errors`

詳細は [agent-browser README](https://github.com/vercel-labs/agent-browser) を参照してください。

### Vibium（ブラウザ自動化 - MCP統合）

このプロジェクトには `vibium` も統合されています。VibiumはMCPサーバー内蔵で、Claude Codeから直接使用できます。WebDriver BiDiベースで軽量（約10MB）です。

#### インストール

```bash
# JavaScript/TypeScript
cd video-analysis
npm install

# Python
pip install -r requirements.txt
```

Vibiumは自動的にChrome for Testingをダウンロードします（初回インストール時）。

#### MCP設定（Claude Code用）

MCP設定ファイル（`~/.cursor/mcp.json`）に自動的に追加されます：

```json
{
  "mcpServers": {
    "vibium": {
      "command": "npx",
      "args": ["-y", "vibium"]
    }
  }
}
```

設定スクリプトを実行：
```bash
./scripts/setup_mcp.sh
```

#### JavaScript/TypeScriptでの使用

**同期API:**
```javascript
const { browserSync } = require('vibium')

const vibe = browserSync.launch()
vibe.go('https://example.com')

const png = vibe.screenshot()
require('fs').writeFileSync('screenshot.png', png)

const link = vibe.find('a')
link.click()
vibe.quit()
```

**非同期API:**
```javascript
import { browser } from 'vibium'

const vibe = await browser.launch()
await vibe.go('https://example.com')

const png = await vibe.screenshot()
await fs.writeFile('screenshot.png', png)

const link = await vibe.find('a')
await link.click()
await vibe.quit()
```

#### Pythonでの使用

**同期API:**
```python
from vibium import browser_sync as browser

vibe = browser.launch()
vibe.go("https://example.com")

png = vibe.screenshot()
with open("screenshot.png", "wb") as f:
    f.write(png)

link = vibe.find("a")
link.click()
vibe.quit()
```

**非同期API:**
```python
import asyncio
from vibium import browser

async def main():
    vibe = await browser.launch()
    await vibe.go("https://example.com")
    
    png = await vibe.screenshot()
    with open("screenshot.png", "wb") as f:
        f.write(png)
    
    link = await vibe.find("a")
    await link.click()
    await vibe.quit()

asyncio.run(main())
```

#### Claude Codeでの使用

MCP設定後、Claude Codeから直接使用できます：

```
「example.comにアクセスして最初のリンクをクリックして」
```

利用可能なMCPツール：
- `browser_launch` - ブラウザを起動（デフォルトで表示）
- `browser_navigate` - URLに移動
- `browser_find` - CSSセレクタで要素を検索
- `browser_click` - 要素をクリック
- `browser_type` - 要素にテキストを入力
- `browser_screenshot` - ビューポートをキャプチャ（base64またはファイル保存）
- `browser_quit` - ブラウザを閉じる

#### Vibiumの特徴

- **AI-native**: MCPサーバー内蔵、Claude Codeで即座に使用可能
- **ゼロ設定**: インストール時に自動でブラウザをダウンロード
- **標準準拠**: WebDriver BiDiベース（企業の独自プロトコルではない）
- **軽量**: 約10MBの単一バイナリ、ランタイム依存なし
- **自動待機**: 要素が表示されるまで自動的に待機

詳細は [Vibium README](https://github.com/VibiumDev/vibium) を参照してください。

---

## 主要ファイル/モジュール

- `api/main.py` - FastAPIアプリ（ルーター統合）
- `api/routes/*.py` - 機能別API（video/analytics/influencer/scraping/import/creative/export/health/web）
- `api/services/*.py` - サービス層
- `api/templates/` - Jinja2/htmx UI
- `database/manager.py` - SQLAlchemyモデル & DB操作
- `database/connection.py` - DB接続管理
- `auth/fastapi_routes.py` - 認証API
- `src/video_analysis/analysis/llm/providers.py` - LLMプロバイダー
- `src/video_analysis/analysis/llm/prompts.py` - 分析プロンプト
- `config/settings.py` - 環境変数と設定
- `scripts/` - バッチ分析、環境検証、DBメンテナンス

---

## ビルドとテスト

### Python依存関係

```bash
pip install -r requirements.txt
pip install -r requirements-dev.txt
```

### テスト

```bash
pytest tests/ -v
pytest -m integration tests/ -v
```

### Next.js

```bash
cd dashboard
npm run lint
npm run build
```

### Orchestrator（任意）

```bash
cd orchestrator
npm run build
```

---

## コーディングスタイル

### Python

- Black / isort / mypy を使用（`requirements-dev.txt`）
- 型ヒントとdocstringを付与
- 命名: `snake_case` / `PascalCase` / `UPPER_SNAKE_CASE`

### TypeScript/Next.js

- 関数コンポーネントのみ
- 明示的な型注釈を優先
- 命名: `camelCase` / `PascalCase`

### テンプレート（Jinja2/htmx）

- 画面: `api/templates/`
- 部分更新は `api/templates/partials/` を使用

---

## テスト手順（API）

```bash
# 動画分析
curl -X POST "http://localhost:8000/api/analyze?llm_provider=gemini&analysis_mode=ctr_optimized" \
  -H "Content-Type: multipart/form-data" \
  -F "file=@test_video.mp4"

# 進捗確認
curl "http://localhost:8000/api/jobs/{job_id}/progress"

# 一覧/検索
curl "http://localhost:8000/api/videos"
curl "http://localhost:8000/api/search?q=query"
```

---

## コミット/PR

- コミット規約: `docs/development/COMMIT_POLICY.md`
- ブランチ運用: `docs/project/GIT_WORKFLOW.md`
- PRテンプレート: `.github/pull_request_template.md`

---

## コーディング開始前のTODO確認プロセス

**重要**: コーディングタスクを開始する前に、必ず以下を実行してください。

1. `docs/planning/TODO.md` を確認・更新
2. GitHub Issue（`gh issue list --state open`）を確認
3. `docs/issues/ISSUES_TIMELINE.md` を更新（着手/完了時）
4. 既存実装を確認して重複を避ける

---

## イシュー・スケジュール管理（必須）

**必須ルール**: Issue管理とスケジュール管理は `docs/issues/ISSUES_TIMELINE.md` を必ず更新して運用すること。

- 対象ファイル: `docs/issues/ISSUES_TIMELINE.md`
- Windowsパス: `C:\Users\ogosh\Desktop\eiai\video-analysis\docs\issues\ISSUES_TIMELINE.md`
- Issue作成・着手・完了で必ず更新

---

## デプロイ

- 参照: `docs/operations/DEPLOYMENT.md`
- バックエンド: Railway/Render
- フロント: Vercel

---

## よくあるタスク

### 新しいAPIエンドポイント追加

1. `api/routes/` にルーター追加
2. `api/main.py` に `include_router`
3. 必要に応じて `api/services/` を追加
4. テスト追加

### 新しいLLMプロバイダー追加

1. `src/video_analysis/analysis/llm/providers.py` に実装
2. `src/video_analysis/analysis/llm/prompts.py` に追加
3. API/UI側の選択肢を更新

### スクレイピング拡張

1. `api/routes/scraping.py` を更新
2. `api/apify_*` / `api/tiktok_*` を追加
3. DB保存・UI表示を更新

### データインポート/紐付け

1. `api/raw_data_processor.py` / `api/performance_importer.py` を更新
2. `database/manager.py` を更新
3. `scripts/batch_analyze_and_link.py` を確認

---

## セキュリティ

- APIキーは `.env` で管理（`.env.example` を参照）
- `config/settings.py` の検証を通すこと
- 詳細: `docs/security/SECURITY.md`

---

## LLMプロバイダー使用例

```python
from src.video_analysis.analysis.llm.providers import GeminiProvider, OpenAIProvider, AnalysisMode

provider = GeminiProvider(api_key, "gemini-2.5-flash")
analysis = provider.analyze_frame(frame, analysis_mode=AnalysisMode.CTR_OPTIMIZED)

openai_provider = OpenAIProvider(api_key, "gpt-4-vision-preview")
analysis = openai_provider.analyze_frame(frame, analysis_mode=AnalysisMode.CTR_OPTIMIZED)
```

---

## 📊 プロジェクト状態管理

**重要**: このセクションは、機能の実装・変更時に必ず更新してください。

**最終更新**: 2026-01-12（Ralph Loop反復実行スクリプト追加）

### ✅ 実装済み機能

#### バックエンド (FastAPI)

- ルーティング分割: `api/routes/*`（health/video/analytics/influencer/scraping/import/creative/export/web）
- ジョブ進捗: `/api/jobs/{job_id}/progress`（`api/progress_stream.py`）
- 監視: `/api/health`, `/api/metrics`, `/api/alerts`
- 認証/認可: JWT + RBAC（`auth/`）
- ログ管理: `api/log_routes.py`
- セキュリティ: レート制限/ヘッダー付与
- Jinja2/htmx UI: `api/templates/`, `api/static/`

#### 動画分析/AI

- LLMフレーム分析（Gemini/OpenAI）
- CTR最適化プロンプト（`ctr_optimized` 固定）
- Whisper音声転写（常時有効）
- OCR/物体検出/音声特徴量
- Gemini動画直接分析 + 自動圧縮（FFmpeg）
- サムネイル自動生成

#### データ/パイプライン

- SQLAlchemy管理（`database/`）
- Rawデータインポート（CSV/JSON/Excel）
- 配信実績インポート + クリエイティブ紐付け
- 検索インデックス（`api/search_engine.py`）
- CSV/JSONエクスポート（`/api/export/*`）

#### スクレイピング/インフルエンサー

- Apify連携（TikTok/サイト）
- スクレイピングジョブ管理
- インフルエンサーCRUD

#### フロントエンド

- FastAPIテンプレートUI（htmx）
- Next.jsダッシュボード（`dashboard/`）
- Streamlitダッシュボード（`dashboards/`）

#### オーケストレーション（任意）

- TSオーケストレーター（Fastify + Redis）
- Python Redisワーカー（`api/redis_worker.py`）

#### AI運用/エージェント支援

- 反復実行スクリプト（`scripts/ralph_loop.py`）

### 🚧 進行中/今後

- TikTok動画100本バッチ分析と配信データ紐付け（`docs/planning/TODO.md`）
- NEXI: インフルエンサーマッチング機能（Phase 1〜）
- UI側のCSV/JSONエクスポート、進捗表示（SSE/WS）
- テストカバレッジ拡充（API/分析/スクレイピング）
- 新規LLMプロバイダー（Anthropic Claude）

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
