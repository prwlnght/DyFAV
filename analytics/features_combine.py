'''
copyright @prwlnght

This file take all the feature files from all the users and converts them into a single .csv for processing

'''

import resources_windows as resources
import os
import pandas as pd

workspace_dir = resources.workspace_dir
data_dir = os.path.join(workspace_dir, 'data', 'Features')
output_dir = os.path.join(workspace_dir, 'data', 'Features', 'All')
temp_dir = os.path.join(workspace_dir, 'tmp')

counter = 0

if not os.path.exists(output_dir):
    os.mkdir(output_dir)

list_ = []
frame_ = pd.DataFrame()

for m_dir in os.listdir(data_dir):
    if not (m_dir.startswith('.') or m_dir.startswith('desktop') or m_dir.startswith('All')):
        counter += 1
        print(m_dir)

        m_file = os.path.join(data_dir, m_dir, 'features.csv')  # assumign this
        df = pd.read_csv(m_file, index_col=None, header=0)
        list_.append(df)

frame_ = pd.concat(list_)
file_name = 'features.csv'

frame_.to_csv(os.path.join(output_dir, file_name))

