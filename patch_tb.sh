#!/bin/bash

# 1. TensorBoard 설치 경로 확인
TB_PATH=$(python3 -c "import tensorboard, os; print(os.path.dirname(tensorboard.__file__))" 2>/dev/null)

if [ -z "$TB_PATH" ]; then
    echo "❌ Error: TensorBoard 패키지를 찾을 수 없습니다."
    exit 1
fi

ZIP_PATH="$TB_PATH/webfiles.zip"
BACKUP_PATH="$ZIP_PATH.bak"
TEMP_DIR="tb_patch_temp"
TARGET_FILE="index.js"

echo "[*] TensorBoard 경로: $TB_PATH"

# 2. 백업 생성 (최초 1회)
if [ ! -f "$BACKUP_PATH" ]; then
    echo "[*] 원본 백업 생성: $BACKUP_PATH"
    cp "$ZIP_PATH" "$BACKUP_PATH"
fi

# 3. 압축 해제
rm -rf "$TEMP_DIR" && mkdir "$TEMP_DIR"
echo "[*] webfiles.zip 압축 해제 중..."
unzip -q "$ZIP_PATH" -d "$TEMP_DIR"

# 4. index.js 수정 (색상 30개 추가)
# 찾으신 패턴 뒤에 쉼표(,)와 함께 새로운 색상 객체들을 삽입합니다.
EXTRA_COLORS=',{name:"Deep Blue",lightHex:"#1a73e8",darkHex:"#4285f4"},{name:"Emerald",lightHex:"#0f9d58",darkHex:"#34a853"},{name:"Deep Purple",lightHex:"#673ab7",darkHex:"#9575cd"},{name:"Rose",lightHex:"#ff4081",darkHex:"#ff80ab"},{name:"Lime",lightHex:"#c0ca33",darkHex:"#dce775"},{name:"Indigo",lightHex:"#3f51b5",darkHex:"#7986cb"},{name:"Amber",lightHex:"#ffc107",darkHex:"#ffd54f"},{name:"Teal",lightHex:"#009688",darkHex:"#4db6ac"},{name:"Brown",lightHex:"#795548",darkHex:"#a1887f"},{name:"Crimson",lightHex:"#dc143c",darkHex:"#ff5252"},{name:"Navy",lightHex:"#000080",darkHex:"#3f51b5"},{name:"Olive",lightHex:"#808000",darkHex:"#afb42b"},{name:"Coral",lightHex:"#ff7f50",darkHex:"#ff8a65"},{name:"Steel Blue",lightHex:"#4682b4",darkHex:"#64b5f6"},{name:"Gold",lightHex:"#ffd700",darkHex:"#fff176"},{name:"Slate Blue",lightHex:"#6a5acd",darkHex:"#9fa8da"},{name:"Spring Green",lightHex:"#00ff7f",darkHex:"#69f0ae"},{name:"Maroon",lightHex:"#800000",darkHex:"#d32f2f"},{name:"Violet",lightHex:"#ee82ee",darkHex:"#f06292"},{name:"Sky Blue",lightHex:"#87ceeb",darkHex:"#4fc3f7"},{name:"Sienna",lightHex:"#a0522d",darkHex:"#bcaaa4"},{name:"Medium Orchid",lightHex:"#ba55d3",darkHex:"#ce93d8"},{name:"Dark Turquoise",lightHex:"#00ced1",darkHex:"#4dd0e1"},{name:"Khaki",lightHex:"#f0e68c",darkHex:"#fff59d"},{name:"Chocolate",lightHex:"#d2691e",darkHex:"#ffccbc"},{name:"Medium Sea Green",lightHex:"#3cb371",darkHex:"#81c784"},{name:"Royal Blue",lightHex:"#4169e1",darkHex:"#82b1ff"},{name:"Hot Pink",lightHex:"#ff69b4",darkHex:"#f48fb1"},{name:"Cadet Blue",lightHex:"#5f9ea0",darkHex:"#80cbc4"},{name:"Orange Red",lightHex:"#ff4500",darkHex:"#ffab91"}'

TARGET_PATTERN='{name:"Orange",lightHex:"#e8710a",darkHex:"#e8710a"}'

# index.js 파일 위치 확인 후 수정
INDEX_PATH=$(find "$TEMP_DIR" -name "$TARGET_FILE" | head -n 1)

if [ -f "$INDEX_PATH" ]; then
    echo "[!] 패치 대상 발견: $INDEX_PATH"
    # GNU sed와 BSD(macOS) sed 호환성을 위해 리터럴 치환 수행
    sed -i "s|$TARGET_PATTERN|&$EXTRA_COLORS|g" "$INDEX_PATH"
    echo "[*] 색상 팔레트 주입 완료."
else
    echo "❌ Error: index.js 파일을 찾을 수 없습니다."
    rm -rf "$TEMP_DIR"
    exit 1
fi

# 5. 재압축 및 원본 교체
echo "[*] webfiles.zip 재빌드 중..."
cd "$TEMP_DIR" || exit
zip -qr "../webfiles_new.zip" .
cd ..
mv "webfiles_new.zip" "$ZIP_PATH"

# 6. 정리
rm -rf "$TEMP_DIR"

echo -e "\n✅ [패치 성공!] 이제 37개까지 실험 색상이 중복되지 않습니다."
echo "👉 TensorBoard 재시작 + 브라우저 'Ctrl + Shift + R' 필수!"
