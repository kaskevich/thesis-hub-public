import pandas as pd
import matplotlib.pyplot as plt

df = pd.read_csv('landscape_statistics.csv')

# calculating percentages
# df['branches_area_percentage'] = df['branches_area_ha'] / df['bgi_area_ha']
# df['cores_area_percentage'] = df['cores_area_ha'] / df['bgi_area_ha']
# df['corridors_area_percentage'] = df['corridors_area_ha'] / df['bgi_area_ha']

# Fig 1

# ax = df[['region',
#          'total_region_area_ha',
#          'bgi_area_ha',
#          'branches_area_ha',
#          'cores_area_ha',
#          'corridors_area_ha']].plot.bar(x='region', stacked=False, logy=True)
#
# # show values above
# # for p in ax.patches:
# #     ax.annotate(str(p.get_height()), (p.get_x() * 1.005, p.get_height() * 1.005))
#
# ax.set_ylabel('Area [ha]')
# ax.set_xlabel('Region')
# ax.set_title('Landscape Statistics')
# ax.legend([
#     'Total region area',
#     'BGI area',
#     'Branches area',
#     'Cores area',
#     'Corridors area'
# ])
#
# # increase plot margins
# # plt.subplots_adjust(left=0.2, right=0.9, top=0.8, bottom=0.3)
# plt.subplots_adjust(left=0.135, bottom=0.23)
#
# # plt.show()
# plt.savefig('landscape_statistics_not_stacked_log.png', dpi=300)


# Fig 2

ax = df[[
    'region',
    'patch_index'
]].plot.bar(x='region', stacked=False, logy=False)

# show values above
# for p in ax.patches:
#     ax.annotate(str(p.get_height()), (p.get_x() * 1.005, p.get_height() * 1.005))

ax.set_ylabel('Area [ha]')
ax.set_xlabel('Region')
ax.set_title('Landscape Statistics')
ax.legend([
    'LPI'
])

# increase plot margins
# plt.subplots_adjust(left=0.2, right=0.9, top=0.8, bottom=0.3)
plt.subplots_adjust(left=0.135, bottom=0.23)

# plt.show()
plt.savefig('landscape_statistics_lpi.png', dpi=300)
