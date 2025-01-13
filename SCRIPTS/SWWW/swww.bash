
# Путь к папке с обоями
WALLPAPER_DIR="/home/rais/MACO-CONF/WALLPAPERS"

# Проверяем наличие swww
if ! command -v swww &>/dev/null; then
  echo "swww не установлен. Установите его с помощью 'paru -S swww'."
  exit 1
fi

# Ищем изображения и видео
FILES=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.mp4" \))

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

# Меняем обои в зависимости от формата
if [[ "$SELECTED" =~ \.mp4$ ]]; then
  # Для видео
  swww vid "$SELECTED" --transition-type grow --transition-duration 2
else
  # Для изображений
  swww img "$SELECTED" --transition-type grow --transition-duration 2
fi

# Дополнительная анимация (blend)
# if [[ "$SELECTED" =~ \.mp4$ ]]; then
#   swww vid "$SELECTED" --transition-type fade --transition-duration 2 --transition-fps 60
# else
#   swww img "$SELECTED" --transition-type fade --transition-duration 2 --transition-fps 60
# fi