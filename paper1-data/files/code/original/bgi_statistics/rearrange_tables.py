from glob import glob

import pandas as pd

files = glob('data/*')

files_branches = list(filter(lambda x: '_branches' in x, files))
files_cores = list(filter(lambda x: '_cores' in x, files))
files_corridors = list(filter(lambda x: '_corridors' in x, files))


def rearrange_tables(files_paths, file_name) -> pd.DataFrame:
    tables = []
    for file_path in files_paths:
        region = file_path.split('/')[1].split('_')[0]
        df = pd.read_csv(file_path)
        df['region'] = region
        tables.append(df)
    result = pd.concat(tables)
    result.to_csv(file_name, index=False)
    return result


df_branches = rearrange_tables(files_branches, 'branches.csv')
df_cores = rearrange_tables(files_cores, 'cores.csv')
df_corridors = rearrange_tables(files_corridors, 'corridors.csv')

df_branches.rename(columns={'area': 'area_branches'}, inplace=True)

df_branches_cores = df_branches.merge(df_cores[['fid', 'class', 'region', 'area']], on=['fid', 'region', 'class'], how='outer')
df_branches_cores.rename(columns={'area': 'area_cores'}, inplace=True)

df_branches_cores_corridors = df_branches_cores.merge(df_corridors[['fid', 'class', 'region', 'area']], on=['fid', 'region', 'class'], how='outer')
df_branches_cores_corridors.rename(columns={'area': 'area_corridors'}, inplace=True)
df_branches_cores_corridors.to_csv('branches_cores_corridors.csv', index=False)
