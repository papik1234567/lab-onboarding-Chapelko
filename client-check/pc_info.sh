#!/bin/bash

# Практическая работа: Диагностика клиентского компьютера
# Фамилия: Chapelko
# Дата: 30.10.2026

# Определяем расположение отчёта.
REPORT="$(cd "$(dirname "$0")" && pwd)/pc_report.txt"

# Собираем информацию и сохраняем её в файл.
{
    echo "========================================"
    echo "       ДИАГНОСТИКА КОМПЬЮТЕРА"
    echo "========================================"
    echo
    echo "Дата проверки: $(date '+%d.%m.%Y %H:%M:%S')"
    echo

    # 1. Операционная система.
    echo "----------------------------------------"
    echo "ОПЕРАЦИОННАЯ СИСТЕМА"
    echo "----------------------------------------"

    sw_vers

    echo

    # 2. Процессор.
    echo "----------------------------------------"
    echo "ПРОЦЕССОР"
    echo "----------------------------------------"

    system_profiler SPHardwareDataType 2>/dev/null |
        grep -E 'Chip:|Processor Name:|Total Number of Cores:'

    echo

    # 3. Оперативная память.
    echo "----------------------------------------"
    echo "ОПЕРАТИВНАЯ ПАМЯТЬ"
    echo "----------------------------------------"

    TOTAL_BYTES=$(sysctl -n hw.memsize)
    TOTAL_GB=$((TOTAL_BYTES / 1073741824))

    echo "Всего памяти: ${TOTAL_GB} ГБ"

    VM_DATA=$(vm_stat 2>/dev/null)

    PAGE_SIZE=$(printf '%s\n' "$VM_DATA" |
        sed -n 's/.*page size of \([0-9]*\) bytes.*/\1/p')

    FREE_PAGES=$(printf '%s\n' "$VM_DATA" |
        awk '/Pages free:/ {
            gsub(/\./, "", $3)
            print $3
            exit
        }')

    INACTIVE_PAGES=$(printf '%s\n' "$VM_DATA" |
        awk '/Pages inactive:/ {
            gsub(/\./, "", $3)
            print $3
            exit
        }')

    if [[ "$PAGE_SIZE" =~ ^[0-9]+$ ]] &&
       [[ "$FREE_PAGES" =~ ^[0-9]+$ ]] &&
       [[ "$INACTIVE_PAGES" =~ ^[0-9]+$ ]]; then

        AVAILABLE_BYTES=$(((FREE_PAGES + INACTIVE_PAGES) * PAGE_SIZE))
        AVAILABLE_GB=$((AVAILABLE_BYTES / 1073741824))

        echo "Свободная и неактивная память: около ${AVAILABLE_GB} ГБ"
        echo "Примечание: значение приблизительное."
    else
        echo "Не удалось определить свободную память."
    fi

    echo

    # 4. Системный диск.
    echo "----------------------------------------"
    echo "СИСТЕМНЫЙ ДИСК"
    echo "----------------------------------------"

    df -h / | awk 'NR == 1 || NR == 2 {print}'

    echo

    # 5. Установленные приложения.
    echo "----------------------------------------"
    echo "УСТАНОВЛЕННЫЕ ПРОГРАММЫ"
    echo "----------------------------------------"

    find /Applications "$HOME/Applications" \
        -maxdepth 4 -type d -name '*.app' -prune \
        -print 2>/dev/null |
        sed 's|.*/||; s/\.app$//' |
        sort -fu

    echo

    echo "========================================"
    echo "Отчёт сохранён: pc_report.txt"
    echo "========================================"

} 2>&1 | tee "$REPORT"

echo
read -r -p "Нажми Enter для завершения программы..."

