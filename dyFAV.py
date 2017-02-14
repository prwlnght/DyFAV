#copyright @prwl_nght
#This file takes individual features files and creates a model file
#The cross validation part selects a 'test' instance and creates a model file without the test instance, then it repeats for all other instances

#DyFAV.py should be one of several classes of machine learning techniques that I compare against. For flow, this class
#will be implemented as a separate called class. However one major\
# todo cross_validate function and get true error scores
# # (.)todo: generalize this like other ML algoritms after trying some
#need to scrap everything specific to alphabet, rename it generically or obtain all names as init class
#need to figure out what a machine learning algorithm returns and return all of that specifically.
#However that is in hold until the way numpy or scipy coding standards is known.

import os
import pandas
import string

import itertools


sensors = ["EMG0", "EMG1", "EMG2", "EMG3", "EMG4", "EMG5", "EMG6", "EMG7", "Accl0", "Accl1",
             "Accl2", "Gyr0", "Gyr1", "Gyr2", "Orien0", "Orien1", "Orien2"]

features_to_extract = ["mean", "min", "max", "stdev", "energy"]

feature_column_names = ["Class"]

#taking quarter padding around the digits
padding_heuristics = 4


def create_feature_column_names():
    for feature in features_to_extract:
        for sensor in sensors:
            feature_column_names.append(sensor + "_" + feature)



def find_csv_filenames(path_to_dir,suffix=".csv"):
    filenames = os.listdir(path_to_dir)
    return [filename for filename in filenames if filename.endswith(suffix)]

def build_model(model_data):
    #todo get dyFAV algorithm from git
    ## assumption: model_data is of the format first column is class label and all other columns are features.
    #headers are included
    for m_alphabet in list(string.ascii_lowercase):
        model = pandas.DataFrame(
            columns=["Features", "Range_Lower", "Range_Upper", "Threshold_Upper", "Threshold_Lower", "Weight"])
        for m_feature in feature_column_names:
            if (m_feature == 'Class'):
                continue
            this_sorted_model_byfeature = model_data.sort_values([m_feature])
            this_sorted_model_byfeature.reset_index(drop =True, inplace=True)
            this_sorted_names = this_sorted_model_byfeature[feature_column_names[0]]
            this_sorted_values = this_sorted_model_byfeature[m_feature]
            #how many times is this alphabet repeated
            this_examples = this_sorted_names.value_counts()[m_alphabet]
            total_range = this_sorted_names.count()
            #todo find the upper and lower ranges
            this_lower_range = this_sorted_names[this_sorted_names == m_alphabet].index[0]
            this_upper_range = this_sorted_names[this_sorted_names == m_alphabet].index[-1]
            #todo find better heuristics to add padding
            if (this_lower_range != 0):
                threshold_lower  = this_sorted_values[this_lower_range] - (this_sorted_values[this_lower_range] - this_sorted_values[this_lower_range-1])/padding_heuristics
            else:
                threshold_lower = this_sorted_values[this_lower_range] - (this_sorted_values[this_lower_range+1] - this_sorted_values[this_lower_range])/padding_heuristics
            if(this_upper_range < (total_range-1)):
                threshold_upper = this_sorted_values[this_upper_range] + (this_sorted_values[this_upper_range+1] - this_sorted_values[this_upper_range])/padding_heuristics
            else:
                threshold_upper = this_sorted_values[this_upper_range] - (this_sorted_values[this_upper_range] - this_sorted_values[this_upper_range-1])/padding_heuristics
            if (total_range <= this_examples):
                print('not enough training examples')
                return
            weight = (total_range * this_examples/(this_upper_range - this_lower_range+1) - this_examples) / (total_range - this_examples)
            #todo write in the model dataframe
            this_to_append = [m_feature, this_lower_range, this_upper_range, threshold_lower, threshold_upper, weight]
            this_to_append_series = pandas.Series(this_to_append, index=list(model))
            model = model.append(this_to_append_series, ignore_index = True)
        model_name = model_directory + "\\" + m_alphabet + ".csv"
        model.to_csv(model_name, index=False)

    return


def cross_validate():
    return



def recognize(test_features):

    #note: class_name should be the same as the name of the model file without the "_model"
    #todo if model is not built return unavailable
    #todo check for number of features vs. the number of features in model

    #psedo-code: for every possible trained class
    class_label = "NA"
    os.chdir(model_directory)
    score_list = []
    for model_file in find_csv_filenames("."):
        model_frame = pandas.read_csv(model_file)
        #todo alphabet_A_working . copy here
        this_score = 5
        score_list.append(this_score)
        #make this into a dictionary with class_names

    #class label = max (score list values)
    #todo for each model
    #todo parallelize

    return [class_label, score_list]


# BEGIN_Control_Flow

#this should be set manually here or obtained as an argument (key, value pair?)
#todo define a mechanism to obtain path or dataframe as argument (how to make a constructor in python)
data_directory = "C:\\Users\\ppaudyal\\workspace\\DyFAV\Data\\features"
create_feature_column_names()
os.chdir(data_directory)
for csvfile in find_csv_filenames("."):
    file_frame = pandas.read_csv(csvfile)
    model_directory = data_directory + "\\" +  csvfile.split("_", 1)[0] + "_model"
    if not os.path.exists(model_directory):
        os.makedirs(model_directory)
    build_model(file_frame)

# END_Control_Flow






