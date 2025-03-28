# Путь к папке с обоями
WALLPAPER_DIR="/home/rais/MACO-CONF/WALLPAPERS"

# Проверяем наличие swww
if ! command -v swww &>/dev/null; then
  echo "swww не установлен. Установите его с помощью 'paru -S swww'."
  exit 1
fi

# Ищем изображения и GIF
FILES=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.gif" \))

# Проверяем, есть ли файлы
if [ -z "$FILES" ]; then
  echo "Обои не найдены в $WALLPAPER_DIR."
  exit 1
fi

# Формируем список только с именами файлов
FILE_NAMES=$(echo "$FILES" | xargs -d '\n' -n 1 basename)

# Выводим список в rofi
SELECTED_NAME=$(echo "$FILE_NAMES" | rofi -dmenu -i -p "Выберите обои")

# Проверяем выбор
if [ -z "$SELECTED_NAME" ]; then
  echo "Ничего не выбрано."
  exit 0
fi

# Находим полный путь к выбранному файлу
SELECTED=$(echo "$FILES" | grep -F -- "$SELECTED_NAME")

# Определяем расширение выбранного файла
EXTENSION="${SELECTED##*.}"

# Функция для предварительного изменения размера GIF
resize_gif() {
  local gif_file="$1"
  local temp_file="${gif_file%.gif}_resized.gif"
  gifsicle --resize-width 1920 --resize-height 1080 "$gif_file" > "$temp_file"
  echo "$temp_file"
}

# Устанавливаем обои в зависимости от типа файла
case "$EXTENSION" in
  jpg|png)
    swww img "$SELECTED"
    ;;
  gif)
    # Проверяем размер GIF и при необходимости изменяем его
    GIF_SIZE=$(stat -c %s "$SELECTED")
    if [ "$GIF_SIZE" -gt 5000000 ]; then
      echo "GIF слишком большой, изменяем размер..."
      RESIZED_GIF=$(resize_gif "$SELECTED")
      swww img "$RESIZED_GIF"
      rm "$RESIZED_GIF"  # Удаляем временный файл после использования
    else
      swww img "$SELECTED"
    fi
    ;;
  *)
    echo "Неизвестный формат файла: $EXTENSION"
    exit 1
    ;;
esac
