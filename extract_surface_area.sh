#!/bin/bash

# 指定父目录（可修改为你的路径）
TARGET_DIR="/home/dell/GaoZheng/COF/Pore+/test"   # ← 自己改这里

OUTPUT_CSV="surface_area_results.csv"

echo "name,area_A2,area_m2_cm3,area_m2_g" > $OUTPUT_CSV

# 遍历指定路径下的所有子目录
for dir in "$TARGET_DIR"/*/ ; do
    if [ -d "$dir" ]; then
        file=$(ls "${dir}"OUTPUT_* 2>/dev/null | head -n 1)

        if [ -f "$file" ]; then
            name=$(basename "$dir")

            area_A2=$(grep "Total surface area in Angstroms^2" "$file" | awk '{print $6}')
            area_m2_cm3=$(grep "Total surface area per volume in m^2/cm^3" "$file" | awk '{print $8}')
            area_m2_g=$(grep "Total surface area per volume in m^2/g" "$file" | awk '{print $8}')

            echo "$name,$area_A2,$area_m2_cm3,$area_m2_g" >> $OUTPUT_CSV
        fi
    fi
done

echo "Done! Results saved in $OUTPUT_CSV"
