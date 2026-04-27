---
name: adversarial-design-review
description: MUST invoke for non-trivial design requests (architecture, directory structure, DB schema, retry/error handling, API design, migration strategy) where multiple valid approaches exist with subtle tradeoffs. Invoke BEFORE writing any single-pass design document, and when tempted to self-review your own proposal.
---

# 敵対的設計レビュー

## 即トリガー症状（これらに当てはまったら STOP してこのスキルを発火）

- 「〜の設計を提案してください」「〜のアーキテクチャを考えてください」と要求された
- 単一の設計書を1ショットで書き始めようとしている
- 自分が出した設計を自分で「代替案と却下理由」で正当化している
- 「複数の方針があるがこれが良いと思う」と結論から書いている
- リファクタ提案で「こう変えましょう」とだけ書いている

## 概要

設計系タスクは単一エージェントだと盲点が残る。**researcher（現状把握、Sonnet）→ designer（設計、Opus）⇄ skeptical reviewer（懐疑的レビュー、Opus）**の3段構えで、コンテキスト分離と役割分担によって盲点を構造的に潰す。

**核心**:

1. 同じ脳で出した案を同じ脳で review すると、自分の判断を守る方向にバイアスがかかる。別エージェント（独立コンテキスト）で、懐疑的スタンスを**明示**して起動することで批評が機能する。
2. designer が現状把握と設計を兼任すると、設計の都合で現状認識が歪む（「この部分は触りたくない」と無意識に現状認識をねじ曲げる）。**現状把握を独立エージェント（Sonnet で十分）に切り出す**ことで、事実ベースの入力を designer に渡せる。コード読解・grep・ファイル探索は Sonnet で十分高精度で、Opus の判断力は不要。コスト・速度面でも合理的。

## When to Use / When NOT to Use

**Use**:

- アーキテクチャ / ディレクトリ構成 / DBスキーマ / API設計 / リトライ・エラー処理 / **migration / refactor 戦略**など「複数の妥当解があり、裏目のコストが高い」タスク
- 既存設計の大きなリファクタ提案

**NOT use**:

- サクッと決めたい小粒タスク（オーバーキル）
- ブレインストーミング（発散フェーズ）→ `brainstorming` スキルを使う
- 正解が1つしかない実装タスク

## 環境チェック（実行パターンの選択）

開始前に必ず判定：

1. **Agent ツール（subagent spawn）が使えるか？** 具体的な判定手順:
   - ツール一覧を確認する（システムプロンプトや ToolSearch で検出可）。`Agent` という名前のツールが**明示的に存在する**ことを確認
   - 見つからない場合は即 workfile パターン（フォールバック）。「多分あるはず」で spawn を試みない
   - 自分自身が別エージェントから spawn された subagent の場合、`Agent` ツールがさらに入れ子で使える保証はない。あれば使う、なければ workfile
2. **使える → 第一選択**（subagent spawn パターン、後述）
3. **使えない → 第二選択（workfile パターン）**。加えて、researcher / reviewer ロール開始時に冒頭で以下を自己宣言してから書き始める：
   > （researcher）私は researcher として、現状把握に徹する。設計判断・評価・提案はしない。事実のみをファイルパス・行番号・外部仕様とともに列挙する。
   > （reviewer）私は reviewer として designer-v1.md と researcher.md を独立コンテキストで読む。designer の判断を守るバイアスを持ち込まない。忖度なしで実証検証する。
   自己宣言は同一 Claude 内の role 切替バイアスを軽減する最低限の gate。スキップ禁止。

## 現状把握フェーズ（researcher）の要否判定

**researcher を入れるべきケース**:

- 既存コード・既存システム・既存データに手を入れる設計（リファクタ、migration、新機能の既存影響調査）
- 外部 API の仕様・ライブラリ版・ランタイム制限など、**誤って認識していると設計が崩れる制約**がある
- ユーザーが現状を口頭/ざっくりでしか伝えていない

**省略可なケース**:

- 完全に新規で、リポジトリ構造すら確定していない green field 設計（ヒアリングで代替可）
- ユーザーが関連ファイル・制約を**明示的に全列挙**して渡してくれている
- 設計範囲が極小で、designer が数分で現状把握できる

**迷ったら入れる**。researcher のコスト（Sonnet 1回 spawn）より設計の裏目コストのほうがはるかに高い。省略した場合は reviewer 側で「設計の前提となる現状認識を実証検証せよ」と明示指示すること。

## researcher の並列化パターン

広い調査範囲や「互いに独立した情報ソース」がある場合、**researcher を複数並列で spawn** するとレイテンシと見落としの両方を下げられる（Sonnet なのでコスト面も許容しやすい）。

### 並列化すべきサイン

- 調査対象が**性質の違う情報ソース**にまたがる（例: 内部コード / 外部 API 仕様 / ランタイム・quota 制約 / 過去の類似実装・ADR）
- 1 researcher に全部やらせると**コンテキストが肥大化**して網羅性が落ちる（あるいはタイムアウトする）
- 調査範囲同士が**依存関係を持たない**（片方の結果を待たないと次を調べられない、という構造ではない）
- **同じ情報を別角度から二重チェック**したい（例: 実装側と仕様書側で整合確認）

### 並列化しないほうが良いサイン

- 範囲が狭く、1 researcher で十分（並列コスト < 統合コスト）
- 調査タスク間に**依存がある**（researcher A の結果を見ないと B のクエリが決まらない → 直列で走らせるか、初回 researcher の出力を見て追加 spawn を検討）
- researcher 間で**大幅に重複**する範囲（重複させるなら観点を変える。「同じコードを両方が読む」は無意味）

### 分担設計の原則

- **互いに排他的な担当範囲**を各 researcher のプロンプトに明示（「あなたはXのみ調査。Y/Zは別 researcher の担当なので触らない」）。重複は明示的に許容する場合のみ（二重チェック目的など）
- **他担当範囲のファイル・ドキュメントは Read しない**ことも明示する。境界が滲むと分担が崩れ、同じ箇所を別 researcher が読み直す無駄や、判断のニアミスが起きる
- **各 prompt は self-contained に作る**: 親会話の文脈を引き継がせず、対象範囲・前提・参照すべきファイル/URL・出力フォーマット・禁止事項を全て prompt 内に同梱する（researcher は session context を持たない前提で構築する）
- **出力フォーマットを全員同じ**にする（「ファクト / 外部制約 / 既存実装 / 不明点」）。designer 側で統合しやすくなる
- **粒度を揃える**: 「コード全体」と「1ファイルの1関数」を並列に走らせない（designer がどちらを重視すべきか迷う）
- **5 並列を目安の上限**。これを超えるなら調査設計自体を見直す（分解しすぎでは？）

### 並列 spawn の実装（Claude Code）

**single message で multiple Agent tool use** を発行する。逐次 spawn（1 call → 待つ → 次 call）にすると並列化の意味が薄れる。例:

```
同一メッセージ内で：
  Agent(name="researcher-code", model="sonnet", prompt="内部コード側の現状把握: ...")
  Agent(name="researcher-api", model="sonnet", prompt="外部 API X 仕様の制約抽出: ...")
  Agent(name="researcher-ops", model="sonnet", prompt="ランタイム/quota/SLA 制約の抽出: ...")
```

全員 Sonnet で構わない。Opus にする必要があるのは「判断」を含むときだけ。

### workfile パターンでの並列化（subagent 不可のとき）

subagent が spawn できない環境でも並列化の思想は再現できる。同一メッセージで複数 Write を発行し、**researcher-code.md / researcher-api.md / researcher-ops.md** のように**担当範囲ごとにファイルを分ける**。

- **ファイル分割 = コンテキスト分割**。1 ファイルに全部書くと「兼任」と同じになる
- 各 researcher ファイル冒頭で役割限定を自己宣言（後述「workfile でのロール演じ分け」）
- designer は全 researcher ファイルを**順に Read で開き直してから**統合
- 注意: Claude 1 回の推論内では実質逐次思考なので、subagent 並列ほどの時短効果は無い。それでも**分担による網羅性向上と、designer への入力整理**という効果は残る

### researcher 間矛盾の**チェックタイミング**

- **原則: designer 起動の直前に予備チェック**する（designer が気づかずに矛盾を片方だけ採用する事故を防ぐ）
- チェック方法: 各 researcher 出力の「ファクト」節だけを並べて比較。同じ対象（同じファイル・同じ外部仕様項目）を扱っているのに内容が違えば矛盾候補
- 矛盾なしなら designer にそのまま渡す。矛盾ありなら下記「統合とエスカレーション」

### 統合とエスカレーション

- designer には**全 researcher の出力を全文渡す**（「researcher-code.md」「researcher-api.md」のように節ごとに分けて prompt に埋め込む）
- **researcher 間で矛盾があった場合**:
  - 軽微（表現ゆらぎ、粒度差）→ designer が調整
  - 実質的な矛盾（仕様解釈が食い違う、同じファイルに対する記述が割れる）→ reviewer プロンプトに「researcher 間の矛盾点X, Y を実証検証せよ」と明示して投げる
  - 深刻（どの事実を前提にすべきか設計判断できない）→ **統合用の追加 researcher** を立てる（「researcher-code と researcher-api の矛盾点Zを仕様書の一次ソースで確定させる」）
- 並列 researcher の出力は肥大化しがち。**designer に渡す前に要点だけ抜き出す中間工程を挟まない**（事実の間引きが設計バイアスを作る）。長くなっても全文を渡す

### アンチパターン

- **無理やり分解して並列化**: 分解できない設計範囲を強引に分けると、researcher 間で同じコードを互いに読む羽目になって統合コストだけ増える
- **判断系を researcher に混ぜる**: 「A 案と B 案どちらが良いか調べて」は researcher の仕事ではない（designer or brainstorming スキルの領分）
- **並列 researcher の 1 つが失敗したら全部やり直す**: 失敗した範囲だけ追加 spawn で足す

## Red Flags — STOP していたら適用

- 「一人で考えてから自己レビュー」 → バイアスで自分の判断を守るだけ
- 「1ラウンドで十分」 → reviewer の初回指摘しか拾えていない
- 「reviewer は文面だけ読めば良い」 → grep / 算数せずは空論
- 「designer は全指摘を受け入れるのが丁寧」 → イエスマン化は品質を下げる
- 「Agent ツールあるの知ってたけど使わなかった」 → ツールは自動で起動しない。**明示的に呼ぶ**
- 「designer が現状把握もついでにやる」 → 設計の都合で現状認識が歪む。researcher を分離する
- 「researcher に Opus 使う」 → オーバースペック。Sonnet で十分。コスト・速度を捨てる理由がない
- 「researcher が『〜すべき』と書いている」 → ロール逸脱。プロンプトで判断禁止を明示する
- 「調査範囲広いけど 1 researcher に全部投げる」 → 並列化を検討。性質の違う情報ソース（内部コード / 外部仕様 / 運用制約）は別 researcher に分担
- 「並列 researcher を逐次 spawn する」 → single message で multiple Agent tool use にしないと並列化の意味が薄い

## The Loop

```
ユーザー → researcher 起動（Sonnet、現状把握 / 省略可な場合は skip）
       → designer 起動（Opus、researcher 出力を入力に設計）
       → reviewer 起動（Opus、懐疑的指示、researcher 出力も検証対象）
  → 判定 → [差し戻し] → designer 修正（必要なら researcherN 追加調査）
                    → reviewer 再起動
         → [承認 / 条件付き承認(nitのみ)] → ユーザーに報告
```

- researcher は原則1回。designer が「設計を詰めるのに追加の事実が必要」と判断したら、**追加 researcher を spawn**（prompt は初回と同じく「現状把握に徹する / 判断しない」）。designer が自分で grep しに行くのは避ける（設計の都合で見たいものだけ見るバイアスが戻る）
- 設計ラウンド（designer ⇄ reviewer）は最大3ラウンドが目安。4ラウンドで収束しないなら**設計課題の定義そのものが曖昧**なのでユーザーに相談

## エージェント契約

### researcher

- **Sonnet で起動**（コード読解・grep・ファイル探索は Sonnet で十分高精度、Opus の判断力は不要。コスト・速度面でも合理的）
- 現状把握に徹する。**提案・評価・設計判断をしない**（「こうすべき」「これは良くない」「望ましくは〜」禁止。プロンプトで明示）
- 出力は事実ベースのみ:
  - 関連ファイルパス（行番号付きで引用）
  - 現状の依存関係・データフロー・呼び出し関係
  - 外部制約（API 仕様、ライブラリ版、ランタイム制限、既存 migration 履歴、quota、SLA 等）
  - 既存のエラーハンドリング・リトライ・ログ・監視の方針
- **不明点・調査困難点をリスト化して返す**（designer が追加調査の要否を判断できるように）
- 出力フォーマット: Markdown。節構成は「ファクト / 外部制約 / 既存実装パターン / 不明点・未検証事項」
- 量より正確性。推測は「推測」と明示し、ファクトと混ぜない

### designer

- 結論ファーストで設計案を出す
- **researcher の出力を入力として受け取り、設計判断の根拠として引用する**（「researcher.md のファクトN による」）
- 代替案と却下理由を明示
- 残課題を分離して記載
- **reviewer の指摘ごとに「採用 / 修正 / 反論」を明記して返す**（イエスマン禁止。反論には根拠）
- researcher の出力で不足と感じたら**追加 researcher の起動を要請**する（自分で grep に行かない）

### reviewer

- プロンプトで**「懐疑的スタンス」「忖度なし」「あら探しのためのあら探し禁止（実害ベース）」を必ず指示**
- 以下を**実証で検証する義務**（プロンプトで強制すること）:
  - **researcher の出力のファクト確認**（主要なファイルパス・行番号を抜き打ちで Read で再確認、外部仕様の引用元URL確認）
  - **researcher が見落とした制約・依存・先行事例の洗い出し**
  - 設計が触れると主張するファイルの実在確認（Read/ls）
  - 数値主張の算数検算（タイムアウト合計、バッファサイズ、スループット見積もり）
  - 「grep で全参照確認した」系の主張を再 grep
  - スケール前提の妥当性（「秒間数百rpsで〜」等）
- 判定を先に出す: **承認 / 条件付き承認（nitのみ） / 差し戻し**
- 納得できない箇所は明記、継続審議を要求
- researcher が省略されたフローの場合、「設計の前提となる現状認識」自体を実証検証する役割を兼任

## 収束条件

| 判定         | 意味                  | 次アクション                                     |
| ------------ | --------------------- | ------------------------------------------------ |
| 承認         | 残論点ゼロ            | ユーザーに報告                                   |
| 条件付き承認 | 残るのは Low/nit のみ | **ラウンド追加せず final に nit を反映して終了** |
| 差し戻し     | 実害のある指摘残り    | designer に修正依頼（次ラウンド）                |

**「条件付き承認でラウンド追加すべきか」の明確な基準**:

- 残指摘が **Low / nit のみ** → **追加しない**。final に反映して終了
- 残指摘に **Medium-設計矛盾型** が1件でも → **追加ラウンド実施**（差し戻し扱い）
- 残指摘が **Medium-精度型** のみ → **条件付き承認可**。ただし final に「リスク節」を設けて残課題として明記
- High が残って「条件付き承認」になっているのは reviewer の判定ミス。差し戻しに修正する

**reviewer 側の判定基準（プロンプトに含める）**:

- **High**: 実害あり（算数矛盾、セキュリティ、二重課金、データ破壊、SLA 違反等）→ 差し戻し
- **Medium-設計矛盾型**: 設計の前提・ロジックに矛盾があり、放置すると挙動が壊れる（例: SES rate limit と通知必要数の矛盾、DynamoDB TTL 仕様と頻度制限ロジックの不整合）→ **差し戻し**
- **Medium-精度型**: 設計は成立しているが、パラメータの見積もり精度・検証の網羅性が足りない（例: quota 段階の刻み、dedup 前提の検証範囲）→ **条件付き承認 + リスク節で吸収可**
- **Low / nit**: 文面・typo・用語統一 → 条件付き承認

**continue vs stop の判定方法**:

- reviewer は Medium 指摘を出すとき **「設計矛盾型」か「精度型」かラベルを付ける**こと
- 精度型のみ残で条件付き承認にする場合、designer / reviewer いずれかが「final にリスク節を追加して吸収」と明記し、final でそのセクションを実際に書く
- ラベル不明な Medium は**デフォルト設計矛盾型として差し戻し**（安全側）

## designer 反論の許容基準

reviewer の指摘に対する designer の反論は許容するが、以下を満たすこと:

- **事実ベースの根拠を添える**: 仕様書引用、実装ドキュメントの URL、算数再検算の式、過去実績データ等
- **「感覚的にそう思う」は不可**: 根拠なしの反論は reviewer 側で採用ミスとして却下
- **反論で却下した場合は根拠を v2 の冒頭に明記**（次ラウンドの reviewer が追検証できるように）

## 実行パターン（Claude Code、優先順）

### 第一選択: subagent を spawn できるとき

```
0. researcher 要否判定（上記「現状把握フェーズの要否判定」に従う）

[researcher フェーズ — 必要な場合]
1. Agent(subagent_type="general-purpose", name="researcher", model="sonnet",
        prompt="[現状把握指示 + 対象範囲 + 出力フォーマット（ファクト/外部制約/既存実装/不明点）
                + 『設計判断・提案・評価は一切しない』の明示]")
2. researcher 出力を確認

[設計ラウンド]
3. Agent(subagent_type="general-purpose", name="designer", model="opus",
        prompt="[設計課題 + 観点 + 制約 + 提出フォーマット + researcher の出力全文]")
4. designer 出力を確認
5. Agent(subagent_type="general-purpose", name="reviewer", model="opus",
        prompt="[designer の出力全文 + researcher の出力全文 + 懐疑的スタンス明示
                + 検証義務（researcher ファクトの抜き打ち再確認含む）+ 判定フォーマット]")
6. reviewer の判定を確認
7. 差し戻しなら新規 designerN を起動（SendMessage で resume より fresh agent の方が堅い）
   - 追加調査が要るなら researcherN を Sonnet で追加 spawn
8. 収束したらユーザーに報告（指摘対応履歴を含める）
```

**並列化**: 複数の独立した調査範囲がある場合は上記「researcher の並列化パターン」の節に従う。判断基準・分担設計・統合方法・アンチパターンを参照。

### フォールバック: subagent spawn できないとき（自身がサブエージェントの場合など）

同一 Claude 内で役割を切り替えても**コンテキスト分離**を担保すれば効果が出る。ただし model 切替はできないので、ロール間の思考モード切替を self-gate で担保する:

1. `tmp/<task>/researcher.md`（並列化時は `researcher-code.md` / `researcher-api.md` / `researcher-ops.md` 等）に researcher ロールで現状把握（冒頭の自己宣言を忘れない / 設計判断を書かない）
2. `tmp/<task>/designer-v1.md` に designer ロールで設計。**researcher ファイルを Read で必ず再読してから** designer 節に入る（前ロールの思考を流用しないための re-prime）
3. reviewer ロールに切り替え、`tmp/<task>/reviewer-v1.md` に懐疑的レビューを書く。**designer-v1.md と researcher.md を Read で必ず再読してから** reviewer 節に入る（designer の結論を守るバイアスを持ち込まないための re-prime。自己宣言を冒頭に書く）
4. reviewer で差し戻しなら designer-v2.md を新規作成（v1 は触らない）
5. 収束したら final.md に統合
6. **後片付け（必須）**: タスク完了報告と同時に中間ファイル（researcher*.md / designer-v*.md / reviewer-v*.md）を削除する。`final.md` だけ残すか、ユーザーが結果を受け取ったら `tmp/<task>/` ディレクトリ自体を `rm -rf` する
   - デバッグ・追跡のためにどうしても残したい場合は、ユーザーに「中間ファイルを残してよいか」を明示確認する
   - **評価・検証目的で実行している場合は自動で残して可**（empirical-prompt-tuning などのメタ作業時）。その旨レポートに明記する
   - 放置すると tmp/ が scenario ごとに 5ファイル × 繰り返し回数で爆発する

#### workfile でのロール演じ分け（単一モデルで Sonnet/Opus 相当を切り分ける）

workfile パターンは model 切替不可。そのため **self-discipline で** researcher / designer / reviewer の各ロールを分ける。それぞれ **事前 gate（書く前）** と **事後 gate（書き終わり）** の2段構えで自己検証する。

##### researcher の self-gate

**事前 gate — ファイル冒頭の「self-gate（researcher）」節にチェックリストを書いてから本文に入る**:

- [ ] 「〜すべき」「〜が望ましい」「〜を採用する」などの**設計判断語**を本文では使わない
- [ ] 節構成は「ファクト / 外部制約 / 既存実装パターン / 不明点・未検証事項」に厳密に従う
- [ ] 確認した具体物（ファイルパス + 行番号、URL、コマンド出力）を**必ず引用**する。引用無しの記述は推測タグを付ける
- [ ] 推測と確認済みファクトを**同じ節に混ぜない**（不明点節に寄せる）
- [ ] 設計案・アーキテクチャ選択肢・比較表を書かない（これらは designer の仕事）

**判断語の境界例**:

- **OK（外部仕様記述）**: 「Stripe 仕様上、Idempotency-Key ヘッダ送信が必要（Stripe 公式 Docs 参照）」のように**外部の仕様書に書いてある "要件" を転写**するのは事実。原文が "must" でも事実。
- **OK（不明点節内の TODO）**: 「不明点: `auth/middleware.ts` の認可ロジックを追加調査する必要あり」のように**不明点節にまとめる**分には判断語に該当しない（= 調査計画）
- **NG（設計選好）**: 「この設計では Idempotency-Key を採用すべき」「X より Y が望ましい」のように**本 skill 内で設計上の優劣を述べる**のは researcher 逸脱

**事後 gate — 書き終わった直後、本文末尾に「self-gate（事後）」節を設けて上記 5 項目を再チェック**:

- 全項目 ○ なら designer フェーズに進める
- 1 項目でも × があれば researcher ファイルを**上書き修正**する（履歴は不要、final.md だけが最終成果物）。designer にバージョン違いを見せる価値は無い

##### designer の self-gate

**事前 gate — ファイル冒頭の「self-gate（designer）」節**:

- [ ] researcher ファイル（並列なら全ファイル）を Read で再読してから書き始める
- [ ] 代替案を最低 2 案挙げ、各案に**却下理由**を付ける（単独案で押し切らない）
- [ ] 残課題を本文と**分離**して「残課題」節に列挙する
- [ ] reviewer の指摘への応答（v2 以降）は「採用 / 修正 / 反論」を**項目ごとに明記**する
- [ ] researcher の出力を根拠引用する（「researcher.md のファクトN より」）

**事後 gate**: 書き終わった直後、末尾の「self-gate（事後）」節で上記 5 項目を再チェック。違反があれば上書き修正。

##### reviewer の self-gate

**事前 gate — ファイル冒頭の「self-gate（reviewer）」節**:

- [ ] designer の出力と researcher ファイル（並列なら全ファイル）を Read で再読してから書き始める
- [ ] 判定ラベル（承認 / 条件付き承認 / 差し戻し）を本文の**先頭に**明記する
- [ ] 懐疑的スタンス: 「designer の結論を守るバイアスを持ち込まない」と自己宣言する
- [ ] 指摘は実害ベース（あら探しのためのあら探しはしない）。Medium は「設計矛盾型 / 精度型」ラベル必須
- [ ] researcher 出力のファクトを**抜き打ちで 1 件以上 Read で再確認**する（ファクト盲信の防止）

**事後 gate**: 末尾で 5 項目を再チェック。違反があれば上書き修正。

##### Read 再読 re-prime の扱い

researcher 省略フロー（designer → reviewer のみの 2 段）では、reviewer は **designer-v1.md を Read で再読** するのみで re-prime は成立する（researcher ファイルが無いので）。

「自己宣言（冒頭の self-gate 節）」と「Read 再読」は**両方必須**。自己宣言だけだと前ロールの記憶に引きずられる、Read 再読だけだと批判スタンスが立たない。両方やって初めて role 切替の gate になる。

##### researcher 間の矛盾チェックの証跡

「矛盾なし」のときは、designer ファイル冒頭に **`matrix.md` を 1 行で添付**するだけで可（`researcher-code.md` / `researcher-api.md` / `researcher-ops.md` が同じ対象について矛盾無しを確認、程度）。対象マトリクス表を作って埋めるのは任意。矛盾ありのときは「統合とエスカレーション」節の分岐に従う。

**注意**:

- researcher / designer / reviewer は**必ずコンテキスト分離**する。subagent が第一選択、workfile が第二選択
- reviewer プロンプト（or workfile 冒頭）には **designer / researcher の出力を全文貼る or Read で開く**（「designer の結果を参照して」では読まないことがある）
- SendMessage で resume するより新規 Agent を spawn する方が堅い（過去の resume では無応答になったケースあり）

## サブエージェント側で本スキルを使ってもらうとき

本スキルは description 一致だけではサブエージェントが自動発火しないことがある。タスクをサブエージェントに投げる場合、プロンプト冒頭に以下を入れる:

> タスクに取りかかる前に、あなたが使えるスキル一覧を確認し、このタスクに適用できるスキルがあるか判断してください。適用できるスキルがあればそれに従ってください。

これで発火率が大幅に上がることを実測済み（RED: 0 tool uses → GREEN-2: 12 tool uses、2ラウンド反復で算数ミス4件検出）。

## Common Mistakes

| やりがち                               | 正しい                                                      |
| -------------------------------------- | ----------------------------------------------------------- |
| designer に reviewer も兼任            | 必ず別 agent                                                |
| designer が現状把握もやる              | researcher を分離し、事実ベースの入力を渡す                 |
| researcher を Opus で起動              | Sonnet で十分。Opus はコスト/速度でオーバースペック         |
| researcher に判断させる                | 「設計判断・提案・評価は禁止」をプロンプトで明示する        |
| designer が自分で grep しに行く        | researcher を追加 spawn する（バイアスを戻さない）          |
| 広い調査を 1 researcher に丸投げ       | 情報ソース別に並列 researcher を分担（single message で同時 spawn） |
| 並列 researcher 同士を依存させる       | 依存がある設計になってるなら直列。並列は独立範囲だけ        |
| reviewer に「普通にレビューして」      | 「懐疑的に」「grep/算数で実証」「納得いかないと明記」と書く |
| reviewer が researcher 出力を検証しない | ファクト抜き打ち再確認・見落とし制約の洗い出しも義務        |
| 1ラウンドで終わる                      | High 指摘が残るなら続行                                     |
| designer が全指摘を受け入れる          | 反論可。根拠を示す                                          |
| nit で無限ループ                       | 3ラウンドで潰せないなら課題定義を疑う                       |
| 別 agent を spawn するコストが重い     | 意思決定の裏目コストより安い。非自明な設計でケチらない      |

## Real-World Impact

RED フェーズ（本スキルなし）で決済リトライ設計を単一 agent に任せた結果、以下の blind spot が残った：

- `MaxAttempts=4 × 個別timeout 10s = 40s` が `OverallTimeout=30s` を超過（算数矛盾）
- Full Jitter の実効 backoff が MaxDelay に到達しない（`min(cap, base*2^attempt)` で attempt 小で cap に届かない）
- CB threshold `20req中50%失敗` が秒間数百rps環境だと約100msの窓
- `idempotency_key` ログ平文出力（取引相関解析リスク）

すべて reviewer に「数値検算せよ」「スケール前提を確認せよ」と明示指示すれば拾える類。
