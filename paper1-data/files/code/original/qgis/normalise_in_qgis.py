import pandas as pd


layer = iface.activeLayer()

# Convert the data to a Pandas DataFrame

field_names = [field.name() for field in layer.fields()]
data = ([feature[field] for field in field_names] for feature in layer.getFeatures())
df = pd.DataFrame(data, columns=field_names)

# Normalize values

df['for_c_norm'] = (df['for_count'] - df['for_count'].min()) / (df['for_count'].max() - df['for_count'].min())

# Set attribute values

layer.startEditing()

for feature in layer.getFeatures():
    feature_id = feature['id']
    if (df['id'] == feature_id).sum() > 0:
        feature['for_c_norm'] = df[df['id'] == feature['id']]['for_c_norm'].values[0]
        layer.updateFeature(feature)

layer.commitChanges()