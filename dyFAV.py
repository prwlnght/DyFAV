# copyright @prwl_nght
# This file takes individual features files and creates a model file
# The cross validation part selects a 'test' instance and creates a model file without the test instance, then it repeats for all other instances

# DyFAV.py should be one of several classes of machine learning techniques that I compare against. For flow, this class
# will be implemented as a separate called class. However one major\
# todo cross_validate function and get true error scores
# # (.)todo: generalize this like other ML algoritms after trying some
# need to scrap everything specific to alphabet, rename it generically or obtain all names as init class
# need to figure out what a machine learning algorithm returns and return all of that specifically.
# However that is in hold until the way numpy or scipy coding standards is known.

# todo have system time prompts in various places
# todo use only the top 10 features and check how it affects accuracy
# todo in logger add incorrect.keys as in 't' was misidenfied 3 times as a, b, c etc.
# todo in logger in ---------------- mention the name of the file
# todo in logger report accuracy
# todo correct idenfificatoin scores vs incorrect identification scores
# todo correct identification score / average identification score in


import os
import pandas
import string
import numpy
import logging
import datetime
from collections import Counter
import copy

import itertools

sensors = ["EMG0", "EMG1", "EMG2", "EMG3", "EMG4", "EMG5", "EMG6", "EMG7", "Accl0", "Accl1",
           "Accl2", "Gyr0", "Gyr1", "Gyr2", "Orien0", "Orien1", "Orien2"]





number_of_classes = 26

features_to_extract = ["mean", "min", "max", "stdev", "energy"]

feature_column_names = []
to_cross_validate = True;
to_get_training_accurary = False;
# model_directory = ""
build_model = True
#fuzzy_thresholds = [0.0175, 0.019, 0.02, 0.0225, 0.03, 0.05, 0.1]
fuzzy_thresholds = [0.0175, 0.0225]
is_per_class_weight_normalizations = [True, False]

# taking quarter padding around the digits
padding_heuristics = 4

#todo remove heuristics for number of features
feature_cutoffs = [510]
feature_cutoff = 510
verbose = False
m_is_per_class_weight_normalization = True
fuzzy_threshold = 0

# def create_feature_column_names():
#     for feature in features_to_extract:
#         for sensor in sensors:
#             feature_column_names.append(sensor + "_" + feature)








def create_feature_column_names():
    for csvfile in find_csv_filenames(data_directory):
        file_frame = pandas.read_csv(data_directory + "\\" + csvfile);
        global feature_column_names
        feature_column_names = list(file_frame)
        break


def find_csv_filenames(path_to_dir, suffix=".csv"):
    filenames = os.listdir(path_to_dir)
    return [filename for filename in filenames if filename.endswith(suffix)]


def build_model(model_data, this_model_directory):
    # todo get dyFAV algorithm from git
    ## assumption: model_data is of the format first column is class label and all other columns are features.
    # headers are included
    for m_alphabet in list(string.ascii_lowercase):
        model = pandas.DataFrame(
            columns=["Features", "Range_Lower", "Range_Upper", "Threshold_Lower", "Threshold_Upper", "Weight"])
        for m_feature in feature_column_names:
            if (m_feature == 'Class'):
                continue
            this_sorted_model_byfeature = model_data.sort_values([m_feature])
            this_sorted_model_byfeature.reset_index(drop=True, inplace=True)
            this_sorted_names = this_sorted_model_byfeature[feature_column_names[0]]
            this_sorted_values = this_sorted_model_byfeature[m_feature]

            # how many times is this alphabet repeated
            this_examples = this_sorted_names.value_counts()[m_alphabet]
            total_range = this_sorted_names.count()
            # todo find the upper and lower ranges
            this_lower_range = this_sorted_names[this_sorted_names == m_alphabet].index[0]
            this_upper_range = this_sorted_names[this_sorted_names == m_alphabet].index[-1]

            #padding heuristics should be threshold upper - threshold lower / number of examples lower than lower and higher than higher
            padding_heuristics = abs((this_sorted_values[this_upper_range] - this_sorted_values[this_lower_range]) / this_examples)
            # todo find better heuristics to add padding > this assumes low variation and intensifies the observed variation
            threshold_lower = this_sorted_values[this_lower_range] - padding_heuristics
            threshold_upper = this_sorted_values[this_upper_range] + padding_heuristics
            # if (this_lower_range != 0):
            #     threshold_lower = this_sorted_values[this_lower_range] - padding_heuristics
            # else:
            #     threshold_lower = this_sorted_values[this_lower_range] - (this_sorted_values[this_lower_range + 1] -
            #                                                               this_sorted_values[
            #                                                                   this_lower_range]) / padding_heuristics
            # if (this_upper_range < (total_range - 1)):
            #     threshold_upper = this_sorted_values[this_upper_range] + (this_sorted_values[this_upper_range + 1] -
            #                                                               this_sorted_values[
            #                                                                   this_upper_range]) / padding_heuristics
            # else:
            #     threshold_upper = this_sorted_values[this_upper_range] - (this_sorted_values[this_upper_range] -
            #                                                               this_sorted_values[
            #                                                                   this_upper_range - 1]) / padding_heuristics
            if (total_range <= this_examples):
                print('not enough training examples')
                return
            weight = (total_range * this_examples / (this_upper_range - this_lower_range + 1) - this_examples) / (
                total_range - this_examples)
            # todo write in the model dataframe
            this_to_append = [m_feature, this_lower_range, this_upper_range, threshold_lower, threshold_upper, weight]
            this_to_append_series = pandas.Series(this_to_append, index=list(model))
            model = model.append(this_to_append_series, ignore_index=True)
        model_name = this_model_directory + "\\" + m_alphabet + ".csv"
        model.to_csv(model_name, index=False)

    return


incorrects = {}


def cross_validate():
    global feature_cutoff
    for m in feature_cutoffs:
        global feature_cutoff
        feature_cutoff= m
        dyfav_logger.debug("Feature Cutoff at {}".format(m))
        overall_test_accuracy = 0
        for csvfile in find_csv_filenames(data_directory):
            average_crossvalidation_accuracy = 0
            sum = 0
            # build a model for cross-validation
            file_frame = pandas.read_csv(csvfile)
            number_of_test_cases = file_frame.__len__() - number_of_classes
            for index in range(0, file_frame.__len__()):
                cross_validate_frame = file_frame[~file_frame.index.isin([index])]
                cross_validate_frame.reset_index(drop=True, inplace=True)
                this_model_directory = data_directory + "\\" + csvfile.split("_", 1)[
                    0] + "_TEMP\\" + "cross_validate" + str(
                    index)
                if not os.path.exists(this_model_directory):
                    os.makedirs(this_model_directory)
                    if build_model:
                        build_model(cross_validate_frame, this_model_directory)
                if verbose:
                    print("Model has been built and stored to %s", this_model_directory)
                class_label, recognized_label, score_list, margin, feature_contributions_list = recognize(file_frame.iloc[index], this_model_directory)
                if verbose:
                    print("The class label {} was recognized as {} with a score of {}".format(class_label, recognized_label,
                                                                                          score_list[recognized_label]))
                sum += int(class_label == recognized_label)
                if (class_label != recognized_label):
                    dyfav_logger.debug(
                        "The class label {} was incorrectly recognized as {} with a score of {}, a margin {}, highest scores {} and top  feature_contributions was {}".format(
                            class_label,
                            recognized_label,
                            score_list[
                                recognized_label], margin, Counter(score_list).most_common(5), Counter(feature_contributions_list).most_common(5)))

                    if class_label in incorrects:
                        details = incorrects[class_label]
                        details["_totals"] += 1
                        if recognized_label in details:
                            details[recognized_label].append(score_list[recognized_label])

                        else:
                            confusion_list = []
                            confusion_list.append(score_list[recognized_label])
                            details[recognized_label] = confusion_list
                    else:
                        details = {}
                        confusion_list = []
                        confusion_list.append(score_list[recognized_label])
                        details[recognized_label] = confusion_list
                        details["_totals"] = 1
                        incorrects[class_label] = details


            accuracy = sum / number_of_test_cases
            overall_test_accuracy = overall_test_accuracy + accuracy
            print("The cross validation accuracy for {} was  {}".format(csvfile, accuracy))
            dyfav_logger.debug("The cross validation accuracy for {} was  {}".format(csvfile, accuracy))
            # dyfav_logger.debug("The overall accuracy for cross validation {} was  {}".format(csvfile, accuracy))
            # dyfav_logger.debug(datetime.datetime.now())
            # dyfav_logger.debug("-------------------------------------------------------------")
            # for k in incorrects:
            #     dyfav_logger.debug(
            #         "{} was misidentified {} times as {}".format(k, incorrects[k]["_totals"], incorrects[k].keys()))
            # dyfav_logger.debug(incorrects)
            # dyfav_logger.debug("-------------------------------------------------------------")
        print("The overall cross validation accuracy across all users was  {}".format(overall_test_accuracy/find_csv_filenames(".").__len__()))
        dyfav_logger.debug("The overall cross validation accuracy across all users was  {}".format(
            overall_test_accuracy / find_csv_filenames(".").__len__()))
    return


def recognize(test_features, this_model_directory):
    # note: class_name should be the same as the name of the model file without the "_model"
    # todo if model is not built return unavailable
    # todo check for number of features vs. the number of features in model
    # psedo-code: for every possible trained class
    class_label = test_features[0]
    # os.chdir(model_directory)
    score_list = {}
    feature_contributions_list = {}
    for model_file in find_csv_filenames(this_model_directory):
        model_frame = pandas.read_csv((this_model_directory + "\\" + model_file))
        # todo alphabet_A_working . copy here
        feature_contributions = 0
        # sort the model by weight and reset index
        this_alphabet_total = 0
        this_sorted_model = model_frame.sort_values(["Weight"], ascending=False)
        this_sorted_model.reset_index(drop=True, inplace=True)

        this_sorted_model_cropped = this_sorted_model[this_sorted_model.index.isin(set(range(feature_cutoff)))]
        this_sorted_model_cropped.reset_index(drop=True, inplace=True)

        for index in range(0, this_sorted_model_cropped.__len__()):
            this_feature_line_in_model = this_sorted_model_cropped.iloc[index]
            if (this_feature_line_in_model['Threshold_Lower'] - fuzzy_threshold* abs(this_feature_line_in_model['Threshold_Lower'])) <= test_features[this_feature_line_in_model['Features']] <= \
                    this_feature_line_in_model['Threshold_Upper'] + fuzzy_threshold*abs(this_feature_line_in_model['Threshold_Lower']):
                if(is_per_class_weight_normalization):
                    this_alphabet_total += this_feature_line_in_model['Weight'] / sum(this_sorted_model_cropped['Weight'])
                else:
                    this_alphabet_total += this_feature_line_in_model['Weight']
                feature_contributions += 1
        # todo implement this as dictionary
        score_list[model_file.split(".", 1)[0]] = this_alphabet_total
        feature_contributions_list[model_file.split(".", 1)[0]] = feature_contributions
        # make this into a dictionary with class_names
    # class label = max (score list values)
    # todo for each model
    # todo parallelize
    d = Counter(score_list)
    recognized_label = d.most_common(2)[0][0]
    next_in_line = d.most_common(2)[1][0]
    margin = d.most_common(2)[0][1] - d.most_common(2)[1][1]

    return [class_label, recognized_label, score_list, margin, feature_contributions_list]


def get_training_accuracy():
    overall_accuracy_training = 0
    for csvfile in find_csv_filenames("."):
        # build a model
        file_frame = pandas.read_csv(csvfile)
        this_model_directory = data_directory + "\\" + csvfile.split("_", 1)[0] + "_model"
        if not os.path.exists(this_model_directory):
            os.makedirs(this_model_directory)
            if build_model:
                build_model(file_frame, this_model_directory)
        if verbose:
            print("Model has been built and stored to %s", this_model_directory)
        average_training_accurary = 0
        sum = 0
        for index in range(0, file_frame.__len__()):
            class_label, recognized_label, score_list, margin, feature_contributions_list = recognize(file_frame.iloc[index], this_model_directory)
            if verbose:
                print("The class label {} was recognized as {} with a score of {}".format(class_label, recognized_label,
                                                                                      score_list[recognized_label]))
            sum += int(class_label == recognized_label)
            if class_label != recognized_label:
                print("The class label {} was incorrectly recognized as {} with a score of {}, a margin {} and  the feature_contributions was {}".format(class_label,
                                                                                              recognized_label,
                                                                                              score_list[
                                                                                                  recognized_label], margin, feature_contributions_list))
                dyfav_logger.debug(
                    "The class label {} was incorrectly recognized as {} with a score of {}, a margin {} and  the feature_contributions was {}".format(
                        class_label,
                        recognized_label,
                        score_list[
                            recognized_label], margin, feature_contributions_list))
                #recognize(file_frame.iloc[index], this_model_directory)
        accuracy = sum / (file_frame.__len__())
        overall_accuracy_training = overall_accuracy_training + accuracy
        print("The accuracy for training {} was  {}".format(csvfile, accuracy))
        dyfav_logger.debug("The accuracy for training {} was  {}".format(csvfile, accuracy))
    print("The overall training accuracy {}".format(overall_accuracy_training/find_csv_filenames(".").__len__()))
    dyfav_logger.debug("The overall training accuracy {}".format(overall_accuracy_training / find_csv_filenames(".").__len__()))
        # test this modelscore


# BEGIN_Control_Flow

# this should be set manually here or obtained as an argument (key, value pair?)
# todo define a mechanism to obtain path or dataframe as argument (how to make a constructor in python)

# setup logger

logging_directory = "C:\\Users\\ppaudyal\\Google Drive\\School\\"  # todo use this
log_filename = logging_directory + "dyfav_0615.log"
logging.basicConfig(filename=log_filename, level=logging.DEBUG)

dyfav_logger = logging.getLogger("DyFAVlogs")
dyfav_logger.setLevel(logging.DEBUG)
# handler = logging.handlers.RotatingFileHandler(log_filename, maxBytes=200, backupCount=10)
# dyfav_logger.addHandler(handler)

data_directory = "C:\\Users\\ppaudyal\\workspace\\DyFAV\\Data\\features_accl_emg_gyr"
create_feature_column_names()
os.chdir(data_directory)

for m_is_per_class_weight_normalization in is_per_class_weight_normalizations:
    for m_fuzzy_threshold in fuzzy_thresholds:
        fuzzy_threshold = m_fuzzy_threshold
        is_per_class_weight_normalization = m_is_per_class_weight_normalization
        print("Fuzzy threshold is {}".format(fuzzy_threshold))
        dyfav_logger.debug("Fuzzy threshold is {}".format(fuzzy_threshold))
        print("0-1 per class weight normalization is {}".format(is_per_class_weight_normalization) )
        dyfav_logger.debug("0-1 per class weight normalization is {}".format(is_per_class_weight_normalization))

        if to_get_training_accurary:
            print(get_training_accuracy())

        if to_cross_validate:
            cross_validate();

# END_Control_Flow
