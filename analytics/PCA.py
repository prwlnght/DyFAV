'''This file runs analytics, specially PCA on the dataset
copyright @prwl_nght

The purpose of this to visualize some of this data and do some analyses
input: data> user_folders > features.py
output: figures > PCA > per_user_PCA file (2d)
'''

import resources_windows as resources
import os

import matplotlib.pyplot as plt
import pandas as pd
from sklearn.decomposition import PCA
from sklearn.preprocessing import StandardScaler
import itertools

workspace_dir = resources.workspace_dir
data_dir = os.path.join(workspace_dir, 'data', 'Features')
output_dir = os.path.join(workspace_dir, 'figures', 'pca')
temp_dir = os.path.join(workspace_dir, 'tmp')

counter = 0
for m_dir in os.listdir(data_dir):
    if not (m_dir.startswith('.') or m_dir.startswith('desktop')):
        counter += 1
        print(m_dir)
        m_file = os.path.join(data_dir, m_dir, 'features.csv')  # assumign this
        df2 = pd.read_csv(m_file)

        features = list(df2)[2:]
        # filter by mean only
        features = list(itertools.compress(features, ['mean' in x for x in features]))
        # filter by signal
        # features = list(itertools.compress(features, ['ORN' in x or 'GYR' in x for x in features]))

        x = df2.loc[:, features].values

        y = df2.loc[:, ['Name']].values

        x = StandardScaler().fit_transform(x)

        pca_df = pd.DataFrame(data=x, columns=features).head()

        pca = PCA(n_components=2)

        principalComponents = pca.fit_transform(x)
        pca_to_show = pd.DataFrame(pca.components_, columns=features, index=['PC-1', 'PC-2'])

        principalDf = pd.DataFrame(data=principalComponents
                                   , columns=['principal component 1', 'principal component 2'])

        finalDf = pd.concat([principalDf, df2[['Name']]], axis=1)
        finalDf.head(5)
        explained_variance = pca.explained_variance_ratio_
        fig = plt.figure(figsize=(8, 8))
        ax = fig.add_subplot(1, 1, 1)

        ax.set_xlabel('Principal Component 1: {0:.2f}'.format(explained_variance[0]), fontsize=15)
        ax.set_ylabel('Principal Component 2: {0:.2f}'.format(explained_variance[1]), fontsize=15)
        ax.set_title('2 Comp. PCA for user_' + m_dir, fontsize=20)

        # targets = ['alphabet_b', 'alphabet_h', 'alphabet_j', 'alphabet_m', 'alphabet_n', 'alphabet_q']
        targets = ['alphabet_j', 'alphabet_m', 'alphabet_q', 'alphabet_z']
        colors = ['r', 'g', 'b', 'y', 'k', 'c', 'm']
        for target, color in zip(targets, colors):
            indicesToKeep = finalDf['Name'] == target
            ax.scatter(
                finalDf.loc[indicesToKeep, 'principal component 1']
                , finalDf.loc[indicesToKeep, 'principal component 2']
                , c=color
                , s=50)
        ax.legend(targets)
        ax.grid()
        filename = 'TwoCompPCA_features_User_' + m_dir
        filename = os.path.join(output_dir, filename)
        plt.savefig(filename)

        # pca_to_show.to_csv(os.path.join(temp_dir, 'TwoCompPCA_features_User_' + str(counter) + '.csv'))
