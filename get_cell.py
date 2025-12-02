import os
import pandas as pd
from pymatgen.core import Structure

# CIF 文件夹路径
cif_dir = "/home/dell/GaoZheng/CIF/cifs_cellopt_july22"  # 替换为你的 CIF 文件夹路径

# 输出 CSV 文件
output_csv = "/home/dell/GaoZheng/COF/Pore+/cof_lattice_density.csv"

# 用于存储结果的列表
data_list = []

# 遍历 CIF 文件夹
for filename in os.listdir(cif_dir):
    if filename.endswith(".cif"):
        cif_path = os.path.join(cif_dir, filename)
        try:
            s = Structure.from_file(cif_path)
            a, b, c = s.lattice.abc
            alpha, beta, gamma = s.lattice.angles
            density = s.density

            data_list.append({
                "Filename": filename,
                "a": a,
                "b": b,
                "c": c,
                "alpha": alpha,
                "beta": beta,
                "gamma": gamma,
                "Density (g/cm3)": density
            })
        except Exception as e:
            print(f"Error processing {filename}: {e}")

# 保存到 CSV
df = pd.DataFrame(data_list)
df.to_csv(output_csv, index=False)
print(f"Results saved to {output_csv}")
