#DyFAV is a machine learning algorithm that dynamically selects features based on classes and saves the selecteed
#features with appropriate weights for


#The purpose of this project is to compare DyFAV with other feature selection, dimensionality reduction and comparision techniques


#Related work:
#### Feature selection: PCA, LDA
#### Machine Learning: Decision Trees,

#Focus of the paper: With limited training instances and data
#Collaborate with Shayok talk during office hours

# put classname at the end (get class name from splitting it and insert at the end
# put filename without csv as index
#todo training data and test data split

import os
import pandas
import csv
import itertools
from os import listdir
import numpy as np
import copy

do_preprocess = True
do_normalize = False
do_modeling = False
number_of_partitions = 5
data_directory = "C:\\Users\\ppaudyal\\workspace\\DyFAV\\Data\\alphabet_data"



#define constants
sensors = ["EMG0", "EMG1", "EMG2", "EMG3", "EMG4", "EMG5", "EMG6", "EMG7", "Accl0", "Accl1",
            "Accl2", "Gyr0", "Gyr1", "Gyr2", "Orien0", "Orien1", "Orien2"]

sensor_devices = ['accl', 'emg', 'gyr', 'orn']

def combinations(sensor_devices_combinations, sensor_devices):
    global  this_list_of_combinations
    for i in range(len(sensor_devices)):
        new_target = copy.copy(sensor_devices_combinations)
        new_data = copy.copy(sensor_devices)
        new_target.append(sensor_devices[i])
        new_data = sensor_devices[i+1:]
        print(new_target)
        this_list_of_combinations.append(new_target)
        combinations(new_target, new_data)

this_list_of_combinations = []
sensor_devices_combinations = []
combinations(sensor_devices_combinations, sensor_devices)




features_to_extract = ["mean", "min", "max", "stdev", "energy"]

feature_column_names = ["Class"]

number_of_base_features = len(sensors) * len(features_to_extract)

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



#todo write the classfile in the first column
def preprocess():

    global sensors


    for sensor_array in this_list_of_combinations:
        sensor_selector = [False, False, False, False, False, False, False, False, False, False, False, False, False,
                           False, False,
                           False, False]
        os.chdir(data_directory)
        folder_name = "features"
        if 'accl' in sensor_array:
            sensor_selector[8:11] = [True, True, True]
            folder_name = folder_name + "_accl"
        if 'emg' in sensor_array:
            sensor_selector[0:8] = [True, True, True, True, True, True, True, True]
            folder_name = folder_name + "_emg"
        if 'gyr' in sensor_array:
            sensor_selector[11:14] = [True, True, True]
            folder_name = folder_name + "_gyr"
        if 'orn' in sensor_array:
            sensor_selector[14:17] = [True, True, True]
            folder_name = folder_name + "_orn"
        #if folder_name != 'features_accl_emg_gyr':
            #continue
        folder_name = folder_name + "\\"

        if len(os.listdir("C:\\Users\\ppaudyal\\workspace\\DyFAV\\Data\\" + folder_name )) > 15:
            continue
            #pass
        #reset sensors
        sensors = ["EMG0", "EMG1", "EMG2", "EMG3", "EMG4", "EMG5", "EMG6", "EMG7", "Accl0", "Accl1",
                   "Accl2", "Gyr0", "Gyr1", "Gyr2", "Orien0", "Orien1", "Orien2"]
        sensors = list(itertools.compress(sensors, sensor_selector))
        create_feature_column_names()
        #if 'accl' in sensor_array:
            #sensor_selector.
        #todo complete formation of sensor selector and use that to choose folder name.
        for file in os.listdir("."):
            os.chdir(data_directory+ "\\" + file)
            features_dataframe = pandas.DataFrame(columns=feature_column_names)
            this_to_append = []
            #loop through all files and populate the features_datafram
            for csvfile in find_csv_filenames("."):
                #print(csvfile)
                #class_name = csvfile.split("_", 1)[1].split("_")[1]
                class_name = csvfile.split("_", 3)[1].lower()
                #pass header = None if data file contains no column names, otherwise remove
                file_frame = pandas.read_csv(csvfile, header=None)
                file_frame = file_frame.loc[:, np.array(sensor_selector, dtype = bool)]
                file_frame.columns = sensors
                if do_normalize:
                    file_frame = normalize(file_frame)
                this_means = file_frame.mean(axis=0)
                this_min = file_frame.min(axis=0)
                this_max = file_frame.max(axis=0)
                this_stdev = file_frame.std(axis=0)
                this_energy = file_frame.apply(compute_energy, axis=0)
                this_to_append = list(itertools.chain(class_name, this_means, this_min, this_max, this_stdev, this_energy))
                appended_to = number_of_base_features+1
                #this_to_append_series = pandas.Series(this_to_append)
                #features_dataframe = features_dataframe.append(this_to_append_series, ignore_index= True)
                lower_range = int(0)
                upper_range = int(len(file_frame)/number_of_partitions -1)
                #do the same for the next 4
                for i in range(0, number_of_partitions):
                    this_file_frame = file_frame[lower_range:upper_range]
                    lower_range = upper_range
                    upper_range = upper_range + int(len(file_frame)/number_of_partitions)
                    this_means = this_file_frame.mean(axis=0)
                    this_min = this_file_frame.min(axis=0)
                    this_max = this_file_frame.max(axis=0)
                    this_stdev = this_file_frame.std(axis=0)
                    this_energy = this_file_frame.apply(compute_energy, axis=0)
                    this_to_append = list(itertools.chain(this_to_append, this_means, this_min, this_max, this_stdev, this_energy))

                    append_to_upper_limit = appended_to + number_of_base_features
                    #this_to_append_series.append(this_to_append, index=feature_column_names[appended_to:append_to_upper_limit])

                this_to_append_series = pandas.Series(this_to_append, index = feature_column_names)
                features_dataframe = features_dataframe.append(this_to_append_series, ignore_index=True)


            #print(features_dataframe)


            #USE_THIS to write this dataframe to an appropriate file within the training set
            #features_file_path = data_directory + '\\' + file + '\\features\\' + 'features2.csv';
            #USE_THIS to write this dataframe to a unified folder outside
            features_file_path = "C:\\Users\\ppaudyal\\workspace\\DyFAV\\Data\\" + folder_name + file + '_features.csv'
            features_dataframe.to_csv(features_file_path, index= False)



#This function takes a created features file and creates a model for
def create_model():
    return 0


def create_feature_column_names():
    global feature_column_names
    feature_column_names = ["Class"]
    for i in range(0, 6):
        for feature in features_to_extract:
            for sensor in sensors:
                feature_column_names.append(sensor + "_" + feature + "_" + str(i))


#control flow begin



if do_preprocess:
    preprocess()

if do_modeling:
    create_model()

