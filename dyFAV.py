#DyFAV is a machine learning algorithm that dynamically selects features based on classes and saves the selecteed
#features with appropriate weights for


#The purpose of this project is to compare DyFAV with other feature selection, dimensionality reduction and comparision techniques


#Related work:
#### Feature selection: PCA, LDA
#### Machine Learning: Decision Trees,

#Focus of the paper: With limited training instances and data
#Collaborate with Shayok talk during office hours

#todo put classname at the end (get class name from splitting it and insert at the end
#todo put filename without csv as index 
#todo training data and test data split

import os
import pandas
import csv
import itertools
from os import listdir
import numpy as np

do_preprocess = True
do_normalize = False
do_modeling = False

data_directory = "C:\\Users\\ppaudyal\\Google Drive\\School\\Research\\Projects\\Hand\\Data\\Alphabet\hold"



#define constants
sensors = ["EMG0", "EMG1", "EMG2", "EMG3", "EMG4", "EMG5", "EMG6", "EMG7", "Accl0", "Accl1",
             "Accl2", "Gyr0", "Gyr1", "Gyr2", "Orien0", "Orien1", "Orien2"]

features_to_extract = ["mean", "min", "max", "stdev", "energy"]

feature_column_names = []

def compute_energy(df):
    m_sum = 0
    for m_value in df:
        m_sum = m_sum + m_value**2
    return m_sum


def find_csv_filenames(path_to_dir,suffix=".csv"):
    filenames = listdir(path_to_dir)
    return [filename for filename in filenames if filename.endswith(suffix)]


def normalize(df):
    result = df.copy()
    for feature_name in df.columns:
        max_value = df[feature_name].max()
        min_value = df[feature_name].min()
        if max_value != min_value:
            result[feature_name] = (df[feature_name] - min_value) / (max_value - min_value)
        else:
            result[feature_name] = 1
    return result



def preprocess():
    os.chdir(data_directory)
    for file in os.listdir("."):
        os.chdir(file)
        features_dataframe = pandas.DataFrame(columns=feature_column_names)


        #loop through all files and populate the features_datafram
        for csvfile in find_csv_filenames("."):
            print(csvfile)
            #pass header = None if data file contains no column names, otherwise remove
            file_frame = pandas.read_csv(csvfile, header=None)
            file_frame.columns = sensors
            if do_normalize:
                file_frame = normalize(file_frame)
            this_means = file_frame.mean(axis=0)
            this_min = file_frame.min(axis=0)
            this_max = file_frame.max(axis=0)
            this_stdev = file_frame.std(axis=0)
            this_energy = file_frame.apply(compute_energy, axis=0)
            this_to_append = list(itertools.chain(this_means, this_min, this_max, this_stdev, this_energy))
            this_to_append_series = pandas.Series(this_to_append, index = feature_column_names)
            features_dataframe = features_dataframe.append(this_to_append_series, ignore_index= True)
            print(features_dataframe)


        #write this dataframe to an appropriate file
        features_file_path = data_directory + '\\' + file + '\\features\\' + 'features2.csv';
        features_dataframe.to_csv(features_file_path, index= False)
        break

def create_model():
    os.chdir(model_directory)


def create_feature_column_names():
    for feature in features_to_extract:
        for sensor in sensors:
            feature_column_names.append(sensor + "_" + feature)


#control flow begin

create_feature_column_names()

if do_preprocess:
    preprocess()

if do_modeling:
    create_model()