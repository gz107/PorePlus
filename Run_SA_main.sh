#!/bin/bash
#$ -cwd -V
#$ -N csat2
#$ -l h_rt=72:00:00

ulimit -s unlimited
#====================================================================#
#                     文件配置
#====================================================================#
CSV_FILE=/home/dell/GaoZheng/COF/Pore+/cof_lattice_density.csv
SOURCE=/home/dell/GaoZheng/COF/cifs_cellopt_july22_mol_mepo
NUM_FILES=801

POC_DB=POCs.charges        # charge 数据库
ATOM_DB=CCDC.atoms         # LJ 参数数据库

# 读取 CSV 文件内容（跳过表头）
tail -n +2 $CSV_FILE | head -n $NUM_FILES | while IFS=, read -r filename a b c alpha beta gamma density
do
    echo "=============================="
    echo "Processing $filename"
    echo "=============================="

    # 创建子目录并进入
    mkdir -p $filename
    cd $filename

    # 拷贝 mol 文件
    cp ${SOURCE}/${filename}.mol ./

    # 创建空输出文件（不添加表头行）
    > POCs.charges
    > CCDC.atoms

# 提取唯一元素列表
elements=$(tail -n +5 ${filename}.mol | awk '{print $5}' | sed 's/[0-9]*//g' | sed 's/[^A-Za-z]//g' | sort -u)

for symbol in $elements; do
    # 从 POCs.charges 数据库匹配
    line1=$(grep -w "^$symbol" ../$POC_DB)

    # 从映射表得到全称
    fullname=$(grep -w "^$symbol" ../symbol2name.map | awk '{print $2}')

    # 从 CCDC.atoms 数据库匹配完整名称
    line2=$(grep -w "^$fullname" ../$ATOM_DB)

    if [ -z "$line1" ]; then
        echo "WARNING: Missing charge for element $symbol" >&2
    else
        echo "$line1" >> POCs.charges
    fi

    if [ -z "$line2" ]; then
        echo "WARNING: Missing LJ parameters for element $symbol ($fullname)" >&2
    else
        echo "$line2" >> CCDC.atoms
    fi
done

echo "EOF" >> POCs.charges
echo "! charge in electron" >> POCs.charges

echo "EOF" >> CCDC.atoms
echo "! sigma in A" >> CCDC.atoms

    # 构建 INPUT 文件
    cp ../INPUT INPUT_$filename
    sed -i "s/job_coords/${filename}.mol/g" INPUT_$filename
    sed -i "s/cell_a/${a}/g" INPUT_$filename
    sed -i "s/cell_b/${b}/g" INPUT_$filename
    sed -i "s/cell_c/${c}/g" INPUT_$filename
    sed -i "s/CELL_ALPHA/${alpha}/g" INPUT_$filename
    sed -i "s/CELL_BETA/${beta}/g" INPUT_$filename
    sed -i "s/CELL_GAMMA/${gamma}/g" INPUT_$filename
    sed -i "s/Cell_Density/${density}/g" INPUT_$filename

    echo "Running Pore-plus calculation..."
    /home/dell/GaoZheng/software/Pore-plus/src/nonorthoSA.exe < INPUT_$filename > OUTPUT_$filename
    # 返回主目录
    cd ..
done
