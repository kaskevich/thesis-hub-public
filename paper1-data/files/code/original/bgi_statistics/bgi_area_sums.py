import pandas as pd

df = pd.read_csv('branches_cores_corridors.csv')

classes = ['forest', 'perm', 'natura2000']
areas = ['area_branches', 'area_cores', 'area_corridors']

computed_df = pd.DataFrame()
for (region, table) in df.groupby('region'):
    for area_type in areas:
        for class_ in classes:
            computed_df = computed_df.append({
                'region': region,
                'class': class_,
                'infrastructure_type': area_type.split('_')[1],
                'area': table[table['class'] == class_][area_type].sum()
            }, ignore_index=True)

computed_df.to_csv('bgi_area_sums.csv', index=False)
