#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
デッキ自己検証スクリプト。
CareCard/Resources/deck/*.json を検証する:
  - id重複ゼロ（デッキ内・デッキ間とも）
  - choicesが3件（かつ重複なし・空文字なし・answerを含まない）
  - hintImage.template が既存15種のいずれか（正式名・別名どちらも許容）
  - 必須フィールドが空でないこと
  - 総数が340±10%（306〜374）
Usage: python3 production/validate_deck.py
"""
import json
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DECK_DIR = os.path.join(ROOT, "CareCard", "Resources", "deck")

DECK_FILES = ["deck-shien.json", "deck-hoken.json", "deck-fukushi.json"]

TARGET_TOTAL = 340
TOLERANCE = 0.10

# HintTemplateKind(deckValue:) が受理する文字列（正式名＋CareCard/HintTemplates/HintImageView.swiftの別名）
VALID_TEMPLATES = {
    # 正式名（rawValue）
    "thermometer", "drum", "sign_board", "beaker", "fire_compare", "tank",
    "hazard_badge", "safety_ruler", "cross_section", "color_swatch",
    "vapor_weight", "static_electricity", "mixed_table", "deadline_calendar", "staffing",
    # 別名（deckValue init内のswitch）
    "signboard", "distance", "structure", "colorChip", "vapor", "static",
    "mixLoad", "calendar", "personnel", "gradeBadge", "extinguish",
}

REQUIRED_STRING_FIELDS = ["id", "topic", "question", "answer", "goro", "goroNote", "source"]


def fail(msg):
    print(f"NG: {msg}")
    return False


def main():
    ok = True
    all_ids = {}
    total_cards = 0
    used_templates = set()

    for filename in DECK_FILES:
        path = os.path.join(DECK_DIR, filename)
        if not os.path.isfile(path):
            ok = fail(f"{filename} が見つかりません ({path})")
            continue

        with open(path, encoding="utf-8") as f:
            try:
                data = json.load(f)
            except json.JSONDecodeError as e:
                ok = fail(f"{filename}: JSONパースエラー: {e}")
                continue

        cards = data.get("cards")
        if not isinstance(cards, list) or not cards:
            ok = fail(f"{filename}: cards配列が空、または存在しません")
            continue

        file_ids = set()
        for card in cards:
            cid = card.get("id", "<no id>")

            # 必須フィールドの空チェック
            for field in REQUIRED_STRING_FIELDS:
                value = card.get(field)
                if not isinstance(value, str) or not value.strip():
                    ok = fail(f"{filename} [{cid}]: 必須フィールド '{field}' が空または欠落")

            # id重複（ファイル内）
            if cid in file_ids:
                ok = fail(f"{filename} [{cid}]: ファイル内でid重複")
            file_ids.add(cid)

            # id重複（デッキ全体）
            if cid in all_ids:
                ok = fail(f"{filename} [{cid}]: {all_ids[cid]} と id重複")
            else:
                all_ids[cid] = filename

            # choices検証
            choices = card.get("choices")
            if not isinstance(choices, list) or len(choices) != 3:
                ok = fail(f"{filename} [{cid}]: choicesが3件でない（実際: {len(choices) if isinstance(choices, list) else 'なし'}）")
            else:
                trimmed = [str(c).strip() for c in choices]
                if any(not c for c in trimmed):
                    ok = fail(f"{filename} [{cid}]: choicesに空文字がある")
                if len(set(trimmed)) != len(trimmed):
                    ok = fail(f"{filename} [{cid}]: choicesに重複がある")
                answer = str(card.get("answer", "")).strip()
                if answer in trimmed:
                    ok = fail(f"{filename} [{cid}]: choicesにanswerと同じ値が含まれている")

            # hintImage.template検証
            hint_image = card.get("hintImage")
            if not isinstance(hint_image, dict) or "template" not in hint_image:
                ok = fail(f"{filename} [{cid}]: hintImage.templateが欠落")
            else:
                template = hint_image.get("template")
                if template not in VALID_TEMPLATES:
                    ok = fail(f"{filename} [{cid}]: 未知のhintImage.template '{template}'")
                else:
                    used_templates.add(template)
                if not isinstance(hint_image.get("params"), dict):
                    ok = fail(f"{filename} [{cid}]: hintImage.paramsが辞書でない")

        total_cards += len(cards)
        print(f"OK: {filename}: {len(cards)}枚（id重複なし・スキーマ検証パス）")

    # 総数チェック（340 ± 10%）
    lower = TARGET_TOTAL * (1 - TOLERANCE)
    upper = TARGET_TOTAL * (1 + TOLERANCE)
    if lower <= total_cards <= upper:
        print(f"OK: 総数 {total_cards}枚（目標{TARGET_TOTAL}枚の±10%以内: {lower:.0f}〜{upper:.0f}枚）")
    else:
        ok = fail(f"総数 {total_cards}枚が目標{TARGET_TOTAL}枚の±10%（{lower:.0f}〜{upper:.0f}枚）を外れています")

    print(f"使用テンプレート: {sorted(used_templates)}")

    if ok:
        print("\n=== 全項目OK ===")
        return 0
    else:
        print("\n=== NG項目あり ===")
        return 1


if __name__ == "__main__":
    sys.exit(main())
