import os
import opendatasets as od

# Assign the Kaggle data set URL into variable
dataset = 'https://www.kaggle.com/rohanrao/formula-1-world-championship-1950-2020'
# Using opendatasets to download the data sets
od.download(dataset)

print("All files downloaded successfully!")
