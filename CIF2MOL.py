import os
from openbabel import pybel

# ======= 设置输入输出文件夹 =======
cif_folder = "/home/dell/GaoZheng/COF/COF-mepo-charge"     # CIF 文件目录
mol_folder = "/home/dell/GaoZheng/COF/cifs_cellopt_july22_mol_mepo"     # 输出 MOL 存放目录
os.makedirs(mol_folder, exist_ok=True)

# ======= 遍历所有 CIF 文件 =======
files = [f for f in os.listdir(cif_folder) if f.lower().endswith(".cif")]

for idx, file in enumerate(files, 1):
    cif_path = os.path.join(cif_folder, file)
    mol_path = os.path.join(mol_folder, file.replace(".cif", ".mol"))

    print(f"[{idx}/{len(files)}] Converting: {file} → {mol_path}")

    try:
        mol = next(pybel.readfile("cif", cif_path))

        # 生成 partial charges (EQeq)
        mol.OBMol.SetPartialChargesPerceived()

        with open(mol_path, "w") as out:
            out.write(f" Molecule_name: {file.replace('.cif','')}\n\n")
            out.write(" Coord_Info: Listed Cartesian None\n")
            out.write(f" {mol.OBMol.NumAtoms()}\n")

            for i, atom in enumerate(mol.atoms):
                x, y, z = atom.coords
                element = pybel.ob.GetSymbol(atom.atomicnum)  # 得到纯元素符号
                charge = atom.partialcharge

                out.write(
                    f"{i+1:5d}  {x:10.5f}  {y:10.5f}  {z:10.5f}  {element:2s}  {charge:10.6f}  0  0\n"
                )

        print(f"✓ Success: {file}")

    except Exception as e:
        print(f"✗ Failed: {file} → Error: {e}")

print("\n🎉 Batch CIF → MOL conversion completed!")
