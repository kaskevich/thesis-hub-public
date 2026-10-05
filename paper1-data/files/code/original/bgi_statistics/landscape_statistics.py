import pandas as pd

df = pd.read_csv('branches_cores_corridors.csv')

computed_df = pd.DataFrame()

for (region, table) in df.groupby('region'):
    branches_area = table['area_branches'].sum()
    branches_area_ha = branches_area / 10000
    cores_area = table['area_cores'].sum()
    cores_area_ha = cores_area / 10000
    corridors_area = table['area_corridors'].sum()
    corridors_area_ha = corridors_area / 10000
    bgi_area_ha = branches_area_ha + cores_area_ha + corridors_area_ha
    print(f'{region}: '
          f'total (ha) = {bgi_area_ha}, '
          f'branches (ha) = {branches_area_ha}, '
          f'cores (ha) = {cores_area_ha}, '
          f'corridors (ha) = {corridors_area_ha}')

    computed_df = computed_df.append({
        'region': region,
        'bgi_area_ha': bgi_area_ha,
        'branches_area_ha': branches_area_ha,
        'cores_area_ha': cores_area_ha,
        'corridors_area_ha': corridors_area_ha
    }, ignore_index=True)

largest_patch = pd.DataFrame([
    {'largest_patch_ha': 3126.76, 'region': 'Laane'},
    {'largest_patch_ha': 2322.16, 'region': 'Harju'},
    {'largest_patch_ha': 2540.24, 'region': 'Laane-Viru'},
    {'largest_patch_ha': 1473.96, 'region': 'Parnu'},
    {'largest_patch_ha': 2203.00, 'region': 'Saare'},
    {'largest_patch_ha': 8705.64, 'region': 'Hiiu'},
    {'largest_patch_ha': 711.20, 'region': 'Ida-Viru'},
])
computed_df = computed_df.merge(largest_patch, on='region', how='outer')

mean_patch = pd.DataFrame([
    {'mean_patch_ha': 188, 'region': 'Laane'},
    {'mean_patch_ha': 194, 'region': 'Harju'},
    {'mean_patch_ha': 359, 'region': 'Laane-Viru'},
    {'mean_patch_ha': 152, 'region': 'Parnu'},
    {'mean_patch_ha': 154, 'region': 'Saare'},
    {'mean_patch_ha': 241, 'region': 'Hiiu'},
    {'mean_patch_ha': 90, 'region': 'Ida-Viru'},
])
computed_df = computed_df.merge(mean_patch, on='region', how='outer')

patch_density = pd.DataFrame([
    {'patch_density_per_sq_km': 0.532, 'region': 'Laane'},
    {'patch_density_per_sq_km': 0.517, 'region': 'Harju'},
    {'patch_density_per_sq_km': 0.278, 'region': 'Laane-Viru'},
    {'patch_density_per_sq_km': 0.658, 'region': 'Parnu'},
    {'patch_density_per_sq_km': 0.651, 'region': 'Saare'},
    {'patch_density_per_sq_km': 0.415, 'region': 'Hiiu'},
    {'patch_density_per_sq_km': 1.11, 'region': 'Ida-Viru'},
])
computed_df = computed_df.merge(patch_density, on='region', how='outer')

shape_index = pd.DataFrame([
    {'shape_index': 14.2, 'region': 'Laane'},
    {'shape_index': 15.7, 'region': 'Harju'},
    {'shape_index': 9.48, 'region': 'Laane-Viru'},
    {'shape_index': 15.2, 'region': 'Parnu'},
    {'shape_index': 23.8, 'region': 'Saare'},
    {'shape_index': 14.6, 'region': 'Hiiu'},
    {'shape_index': 6.88, 'region': 'Ida-Viru'},
])
computed_df = computed_df.merge(shape_index, on='region', how='outer')

patch_index = pd.DataFrame([
    {'patch_index': 16.3, 'region': 'Laane'},
    {'patch_index': 9.76, 'region': 'Harju'},
    {'patch_index': 20.2, 'region': 'Laane-Viru'},
    {'patch_index': 7.70, 'region': 'Parnu'},
    {'patch_index': 4.60, 'region': 'Saare'},
    {'patch_index': 35.1, 'region': 'Hiiu'},
    {'patch_index': 27.2, 'region': 'Ida-Viru'},
])
computed_df = computed_df.merge(patch_index, on='region', how='outer')

total_region_area = pd.DataFrame([
    {'total_region_area_ha': 181580.9, 'region': 'Laane'},
    {'total_region_area_ha': 432672.3, 'region': 'Harju'},
    {'total_region_area_ha': 369574.5, 'region': 'Laane-Viru'},
    {'total_region_area_ha': 541938.7, 'region': 'Parnu'},
    {'total_region_area_ha': 293799.1, 'region': 'Saare'},
    {'total_region_area_ha': 103257.7, 'region': 'Hiiu'},
    {'total_region_area_ha': 297171.5, 'region': 'Ida-Viru'},
])
computed_df = computed_df.merge(total_region_area, on='region', how='outer')

computed_df.to_csv('landscape_statistics.csv', index=False)
