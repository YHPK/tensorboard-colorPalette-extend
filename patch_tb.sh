#!/bin/bash

# 1. TensorBoard 설치 경로 및 webfiles.zip 위치 찾기
TB_PATH=$(python3 -c "import tensorboard, os; print(os.path.dirname(tensorboard.__file__))" 2>/dev/null)

if [ -z "$TB_PATH" ]; then
    echo "❌ Error: TensorBoard를 찾을 수 없습니다."
    exit 1
fi

ZIP_PATH="$TB_PATH/webfiles.zip"
BACKUP_PATH="$ZIP_PATH.bak"
TEMP_DIR="tb_patch_temp"

echo "[*] TensorBoard 경로: $TB_PATH"

# 2. 백업 생성
if [ ! -f "$BACKUP_PATH" ]; then
    echo "[*] 원본 백업 생성 중: $BACKUP_PATH"
    cp "$ZIP_PATH" "$BACKUP_PATH"
fi

# 3. 작업용 임시 디렉토리 생성 및 압축 해제
rm -rf "$TEMP_DIR" && mkdir "$TEMP_DIR"
echo "[*] 압축 해제 중..."
unzip -q "$ZIP_PATH" -d "$TEMP_DIR"

# 4. 색상 데이터 정의 (30개 확장 팔레트)
EXTRA_COLORS=',{name:"Deep Blue",lightHex:"#1a73e8",darkHex:"#4285f4"},{name:"Emerald",lightHex:"#0f9d58",darkHex:"#34a853"},{name:"Deep Purple",lightHex:"#673ab7",darkHex:"#9575cd"},{name:"Rose",lightHex:"#ff4081",darkHex:"#ff80ab"},{name:"Lime",lightHex:"#c0ca33",darkHex:"#dce775"},{name:"Indigo",lightHex:"#3f51b5",darkHex:"#7986cb"},{name:"Amber",lightHex:"#ffc107",darkHex:"#ffd54f"},{name:"Teal",lightHex:"#009688",darkHex:"#4db6ac"},{name:"Brown",lightHex:"#795548",darkHex:"#a1887f"},{name:"Crimson",lightHex:"#dc143c",darkHex:"#ff5252"},{name:"Navy",lightHex:"#000080",darkHex:"#3f51b5"},{name:"Olive",lightHex:"#808000",darkHex:"#afb42b"},{name:"Coral",lightHex:"#ff7f50",darkHex:"#ff8a65"},{name:"Steel Blue",lightHex:"#4682b4",darkHex:"#64b5f6"},{name:"Gold",lightHex:"#ffd700",darkHex:"#fff176"},{name:"Slate Blue",lightHex:"#6a5acd",darkHex:"#9fa8da"},{name:"Spring Green",lightHex:"#00ff7f",darkHex:"#69f0ae"},{name:"Maroon",lightHex:"#800000",darkHex:"#d32f2f"},{name:"Violet",lightHex:"#ee82ee",darkHex:"#f06292"},{name:"Sky Blue",lightHex:"#87ceeb",darkHex:"#4fc3f7"},{name:"Sienna",lightHex:"#a0522d",darkHex:"#bcaaa4"},{name:"Medium Orchid",lightHex:"#ba55d3",darkHex:"#ce93d8"},{name:"Dark Turquoise",lightHex:"#00ced1",darkHex:"#4dd0e1"},{name:"Khaki",lightHex:"#f0e68c",darkHex:"#fff59d"},{name:"Chocolate",lightHex:"#d2691e",darkHex:"#ffccbc"},{name:"Medium Sea Green",lightHex:"#3cb371",darkHex:"#81c784"},{name:"Royal Blue",lightHex:"#4169e1",darkHex:"#82b1ff"},{name:"Hot Pink",lightHex:"#ff69b4",darkHex:"#f48fb1"},{name:"Cadet Blue",lightHex:"#5f9ea0",darkHex:"#80cbc4"},{name:"Orange Red",lightHex:"#ff4500",darkHex:"#ffab91"}'

# 5. 핵심 JS 파일 찾아 패턴 치환 (sed 활용)
TARGET_PATTERN='{name:"Orange",lightHex:"#e8710a",darkHex:"#e8710a"}'
FOUND=false

echo "[*] 색상 팔레트 패치 중..."
find "$TEMP_DIR" -name "*.js" | while read -r js_file; do
    if grep -qF "$TARGET_PATTERN" "$js_file"; then
        # sed를 사용하여 패턴 뒤에 EXTRA_COLORS 삽입
        sed -i "s|$TARGET_PATTERN|&$EXTRA_COLORS|g" "$js_file"
        echo "[!] 패치 완료: $(basename "$js_file")"
        FOUND=true
    fi
done

# 6. 재압축 및 정리
echo "[*] 재압축 중..."
cd "$TEMP_DIR" || exit
zip -qr "../webfiles_patched.zip" .
cd ..
mv "webfiles_patched.zip" "$ZIP_PATH"

rm -rf "$TEMP_DIR"

echo -e "\n✅ [성공] TensorBoard 색상 확장 패치가 완료되었습니다."
echo "👉 TensorBoard 재시작 후 브라우저에서 'Ctrl + Shift + R'을 눌러주세요."

