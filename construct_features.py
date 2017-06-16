
import os
import pandas
import string
import numpy
import logging
import datetime
from collections import Counter


data_directory = "C:\\Users\\ppaudyal\\workspace\\DyFAV\\Data\\features\\raw_features\\"
features_directory = "C:\\Users\\ppaudyal\\workspace\\DyFAV\\Data\\features\\features_510\\"

def find_csv_filenames(path_to_dir, suffix=".csv"):
    filenames = os.listdir(path_to_dir)
    return [filename for filename in filenames if filename.endswith(suffix)]

for csvfile in find_csv_filenames(data_directory):
    file_frame = pandas.read_csv(data_directory + csvfile);
    #dropping first column
    file_frame = file_frame.drop(list(file_frame)[0], axis=1)
    #file_frame["Class"] = list(map(lambda x:x.split("_")[1], file_frame["Name"]))
    file_frame.insert(0, "Class", list(map(lambda x: x.split("_")[1], file_frame["Name"])))
    file_frame = file_frame.drop("Name", axis = 1)
    file_frame.to_csv(features_directory+csvfile, index=False)
    #replace second column by number