# 外部同期テストガイド

このドキュメントでは、異なるネットワーク環境での Syncthing 同期をテストする手順を説明します。

---

## 前提条件

### 現在の設定状態（確認済み ✅）

以下の設定が既に有効化されています:

1. **グローバルディスカバリ**: 有効
   - IPv4/IPv6 ローカルディスカバリ
   - グローバルディスカバリサーバー（discovery-announce/lookup.syncthing.net）

2. **リレーサーバー**: 有効
   - 動的リレー選択（relays.syncthing.net）
   - 現在接続中のリレー: `relay://122.249.92.87:22067`

3. **接続方法**:
   - QUIC（UDP 22000ポート）
   - TCP（22000ポート）
   - リレー経由接続

---

## テストシナリオ

### シナリオ 1: 同一ネットワーク（ホーム WiFi）

**状態**: ✅ 成功（既に確認済み）

```bash
# Mac で接続状態確認
syncthing cli show connections

# 期待される結果:
# - Windows デバイス (ULTRA2025) が "connected": true
# - 接続タイプ: "tcp-client" または "quic-client"
# - アドレス: ローカルIPアドレス（例: 192.168.1.5）
```

---

### シナリオ 2: 異なるネットワーク（外出先 WiFi）

**目的**: グローバルディスカバリとリレーサーバーの動作確認

#### ステップ 1: 環境準備

1. Mac を外出先の WiFi に接続（例: カフェ、オフィス）
2. Windows は自宅ネットワークに接続したまま
3. 両方のデバイスで Syncthing が起動していることを確認

#### ステップ 2: 接続確認（Mac）

```bash
# 1. デバイス接続状態を確認
syncthing cli show connections

# 2. 期待される結果:
# - Windows デバイスが "connected": true
# - 接続タイプ: "relay-client" の可能性が高い
# - アドレス: relay://... で始まるアドレス

# 3. 接続エラーがある場合
syncthing cli show system | jq '.lastDialStatus'
```

#### ステップ 3: 同期テスト

1. Mac で新しいファイルを作成:
   ```bash
   cd /Users/s30519/work/dotfiles_nico
   echo "# Remote Sync Test - $(date)" > remote-sync-test.txt
   git add remote-sync-test.txt
   git commit -m "test: remote sync test from external network"
   ```

2. Syncthing の同期状態を確認:
   ```bash
   # Mac で同期完了を確認
   syncthing cli show folders | grep -A 10 "dotfiles_nico"
   ```

3. Windows でファイルを確認:
   ```powershell
   # Windows で確認
   Get-Content C:\Users\ogosh\work\dotfiles_nico\remote-sync-test.txt
   ```

#### ステップ 4: 双方向同期テスト

1. Windows でファイルを編集:
   ```powershell
   Add-Content C:\Users\ogosh\work\dotfiles_nico\remote-sync-test.txt "`nEdited from Windows - $(Get-Date)"
   ```

2. Mac で変更を確認:
   ```bash
   cat /Users/s30519/work/dotfiles_nico/remote-sync-test.txt
   # "Edited from Windows" の行が表示されれば成功
   ```

---

### シナリオ 3: モバイルホットスポット経由

**目的**: NAT トラバーサルとリレーサーバーの動作確認

#### ステップ 1: 環境準備

1. Mac をスマートフォンのホットスポットに接続
2. Windows は自宅ネットワークに接続したまま

#### ステップ 2: 接続確認

```bash
# Mac で接続確認
syncthing cli show connections

# 期待される結果:
# - リレーサーバー経由で接続
# - "type": "relay-client"
```

#### ステップ 3: 同期速度測定

```bash
# 大きめのファイルを作成して転送速度を確認
dd if=/dev/urandom of=/Users/s30519/work/dotfiles_nico/test-large-file.bin bs=1m count=10

# 同期完了までの時間を計測
time until syncthing cli show folders | grep -q "100%"; do sleep 1; done

# テスト完了後、ファイル削除
rm /Users/s30519/work/dotfiles_nico/test-large-file.bin
```

---

## トラブルシューティング

### 問題 1: 外部ネットワークで接続できない

**症状**:
```bash
syncthing cli show connections
# "connected": false
```

**確認事項**:

1. グローバルディスカバリが有効か確認:
   ```bash
   syncthing cli show system | jq '.discoveryEnabled'
   # 出力: true
   ```

2. リレーサーバーが有効か確認:
   ```bash
   syncthing cli show system | jq '.connectionServiceStatus."dynamic+https://relays.syncthing.net/endpoint"'
   ```

3. ファイアウォール設定確認（Windows）:
   ```powershell
   # Windows Defender ファイアウォールで Syncthing を許可
   Get-NetFirewallRule -DisplayName "*Syncthing*"
   ```

**解決方法**:

1. Syncthing Web UI を開く:
   ```bash
   open http://127.0.0.1:8384
   ```

2. 設定 → 接続 → グローバルディスカバリとリレーを確認
   - ✅ グローバルディスカバリを有効にする
   - ✅ デフォルトのリレーサーバーを使用する

---

### 問題 2: リレー経由で接続が遅い

**症状**: ファイル同期が非常に遅い（1MB/s 以下）

**原因**: リレーサーバーは暗号化・中継のオーバーヘッドがあるため

**解決方法**:

1. **ポートフォワーディング設定**（高度）:
   - ルーターで TCP/UDP 22000 ポートを開放
   - Syncthing の外部アドレスを手動設定

2. **直接接続の確認**:
   ```bash
   syncthing cli show connections | jq '.connections[].type'
   # "tcp-client" または "quic-client" が望ましい
   # "relay-client" は遅い可能性
   ```

3. **リレー優先度を下げる**（Web UI）:
   - 設定 → 接続 → リレー優先度: "常に最後の手段として使用"

---

### 問題 3: 同期コンフリクトが頻発する

**症状**: `*.sync-conflict-*` ファイルが大量に生成される

**原因**: Mac と Windows で同じファイルを同時編集

**解決方法**:

1. **Git + Syncthing ワークフローの徹底**:
   - 編集前に必ず `git pull`
   - 編集後すぐに `git commit && git push`
   - Syncthing は Git の補完として使用

2. **コンフリクトファイルの自動削除**（既に設定済み）:
   ```bash
   # .stignore に既に追加済み
   *.sync-conflict-*
   ```

3. **手動でコンフリクト解決**:
   ```bash
   # コンフリクトファイルを確認
   find . -name "*.sync-conflict-*" -type f

   # 差分確認
   diff original.md original.sync-conflict-TIMESTAMP.md

   # 不要な方を削除
   rm *.sync-conflict-*
   ```

---

## 接続方法の優先順位

Syncthing は以下の順序で接続を試みます:

1. **ローカルディスカバリ**（最速）
   - 同じ LAN 内のデバイスを UDP ブロードキャストで検出
   - 接続: TCP/QUIC で直接通信
   - 速度: 数十〜数百 Mbps

2. **グローバルディスカバリ**（高速）
   - インターネット経由でデバイスの IP アドレスを取得
   - 接続: 直接 TCP/QUIC 接続を試行
   - 速度: 数 Mbps〜数十 Mbps

3. **リレーサーバー経由**（遅い、確実）
   - ファイアウォール/NAT で直接接続できない場合
   - 接続: リレーサーバー経由で暗号化通信
   - 速度: 1〜10 Mbps（サーバー負荷による）

---

## 成功基準

外部同期が成功したと判断する基準:

- [ ] 異なるネットワークでデバイスが "connected": true
- [ ] ファイル変更が 30 秒以内に同期される
- [ ] 双方向同期が正常に動作する
- [ ] コンフリクトファイルが `.stignore` で除外される
- [ ] リレーサーバー経由でも接続可能

---

## 次のステップ

1. **実際の外出先でテスト**
   - カフェ、オフィス、モバイルホットスポットで確認

2. **同期速度の最適化**
   - 必要に応じてポートフォワーディング設定

3. **Git + Syncthing ワークフローの習熟**
   - コンフリクトを最小限に抑える運用

---

**Happy Syncing! 🌐**
