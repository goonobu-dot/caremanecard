# ケアマネ暗記カード - 介護支援専門員試験

介護支援専門員（ケアマネジャー）実務研修受講試験の学習向け、段階ヒント＋間隔反復の暗記カードアプリ。
`~/Projects/otsu4-card`（乙4暗記カード）のエンジンを複製して制作。

## 概要

- **エンジン**: SwiftUI / SwiftData / StoreKit2 / iOS 17+ / xcodegen
- **学習方式**: 段階ヒント（図解 → 語呂 → 3択）＋想起練習＋間隔反復（簡易FSRS）
- **カード数**: 341枚（科目別に3ファイル）
- **課金**: 無料DL＋買い切り ¥1,800（`com.goonobu.caremanecard.unlock`）。月額プランはなし
- **無料枠**: 介護支援分野の最初のトピック（介護保険制度のしくみ、約40枚）＋1日20枚まで
- **動作**: 完全オフライン・アカウント不要・広告なし・データ収集なし
- **対象OS**: iOS 17.0+ / iPhoneのみ

## デッキ構成

| ファイル | 科目 | 枚数 | 主なトピック |
|---|---|---|---|
| `CareCard/Resources/deck/deck-shien.json` | 介護支援分野 | 141 | 介護保険制度のしくみ、保険者と被保険者、要介護認定、ケアマネジメント、地域支援事業 |
| `CareCard/Resources/deck/deck-hoken.json` | 保健医療サービス分野 | 100 | 高齢者に多い疾患、バイタル、認知症、リハビリ、終末期ケア、医療系サービス |
| `CareCard/Resources/deck/deck-fukushi.json` | 福祉サービス分野 | 100 | 相談援助、訪問介護、通所介護、施設サービス、成年後見、高齢者虐待防止 |

合計341枚（仕様目安340枚の±10%以内）。

### カード作成方針

- 制度の**しくみ・原則・用語の定義・手続きの流れ**を中心に構成し、3年ごとの介護保険制度改正で変わりやすい数値
  （区分支給限度基準額の単位数、介護報酬、自己負担割合の細かい所得区分等）は記載していない。
- `source`には根拠（介護保険法の条項・高齢者虐待防止法の条項、または一般的な学術知識である旨）を明記。
- `choices`の誤答3つは明確に誤りとなるよう作成し、「実は正しい」選択肢を混在させていない。
- 認知症・高齢者に関する記述は、断定的・差別的な表現を避けている。

## HintTemplates（図解ヒント）

既存15種のテンプレートのうち、ケアマネジャー試験の内容に合う以下5種のみを使用（新規テンプレートは追加していない）。

- `signboard`（制度名・用語の掲示）
- `gradeBadge`（要介護度・区分等のバッジ）
- `personnel`（人・体制・専門職）
- `calendar`（期間・更新・年数）
- `structure`（しくみ・分類の図解）

## 検証

### デッキ自己検証

```bash
python3 production/validate_deck.py
```

id重複ゼロ・choices3件（重複なし・空文字なし・answerと不一致）・`hintImage.template`が既存15種のいずれか・
総数340±10%以内、をすべて検証する。

### ビルド確認

```bash
xcodegen generate
xcodebuild build -scheme CareCard -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO
```

## 複製元との差分（乙4暗記カードから）

- まんが機能（`Manga/`・`Features/Manga/`・`Resources/manga*`・関連テスト）を全削除し、タブを
  「きょうの学習・進捗・設定」の3つに戻した。
- `Subject`（科目）列挙型を `shien` / `hoken` / `fukushi` の3科目に再定義。
- 課金を買い切り（`unlock`）のみに簡素化し、月額プランのコードを削除。
- BundleID・アプリ名・画面文言（「乙4」「危険物」等）をケアマネ向けに置き換え。

## 既知の未対応事項（今回のスコープ外）

- アプリアイコン（`CareCard/Resources/Assets.xcassets/AppIcon.appiconset/icon1024.png`）は複製元のプレース
  ホルダーのまま。本番申請前に差し替えが必要。
- App Store Connectへの登録・アップロード・審査申請は本タスクの対象外（未実施）。
- シミュレータでのUIテスト・実機確認は本タスクの対象外（未実施）。ビルド確認は
  `xcodebuild build -destination 'generic/platform=iOS'` までにとどめている。
