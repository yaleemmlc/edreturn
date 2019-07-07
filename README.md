# Predicting 72-Hour and 9-Day Return to the Emergency Department Using Machine Learning
#### Woo Suk Hong, Adrian Haimovich, R. Andrew Taylor

We provide the R scripts for the paper "Predicting 72-Hour and 9-Day Return to the Emergency Department Using Machine Learning", published in July 2019 in JAMIA Open (https://doi.org/10.1093/jamiaopen/ooz019). All processing scripts in the */Scripts* subdirectory take as input *.csv* files extracted from the enterprise data warehouse using SQL queries and the original master dataframe used in our prior study of predicting hospital admission at triage. The analysis scripts in the main directory take as input the output of **master_revisit.R**.

##### Pipeline and Analysis Scripts

* **master_revisit.R**: The main processing pipeline that combines data from multiple *.csv* files into one R dataframe, where each row is a patient visit. The pipeline calls on the scripts 1-8 in the */Scripts* folder. While the data files cannot be uploaded due to protected health information, we encourage those interested to take a look into the processing scripts. 

* **build_model_revisit.R**: Trains and outputs the average AUC on the training and validation sets for an XGBoost model (9-day return, full dataset), given a set of hyperparameters. Outputs the design matrix used by subsequent scripts.

* **build_model_revisit_3day.R**: Trains and outputs the average AUC on the training and validation sets for an XGBoost model for predicting (72-hour return, full dataset), given a set of hyperparameters. Outputs the design matrix used by subsequent scripts.

* **build_model_revisit_final.R**: Trains an XGBoost model (9-day return, full dataset) using the optimized set of hyperparameters on all samples excluding the test set then outputs a test AUC with 95% CIs.

* **build_model_revisit_3day_final.R**: Trains an XGBoost model (72-hour return, full dataset) using the optimized set of hyperparameters on all samples excluding the test set then outputs a test AUC with 95% CIs.

* **build_model_revisit_triage.R**, **build_model_revisit_triage_3day.R**, **build_model_revisit_final_triage.R**, **build_model_revisit_final_triage_3day.R**: Repeats the training and testing stpes for XGBoost models using only the variables available by triage.

* **build_model_revisit_baseline.R**, **build_model_revisit_baseline_3day.R**, **build_model_revisit_final_baseline.R**, **build_model_revisit_final_baseline_3day.R**: Repeats the training and testing steps for XGBoost models using only administrative variables (demographics, hospital usage statistics, comorbidities).

* **build_model_revisit_lr.R**, **build_model_revisit_lr_3day.R**: Trains logistic regression models using only administrative variables on all samples excluding the test set and outputs the test AUC with 95% CIs. (Implemented using *keras*)

* **build_importance_ci_revisit.R**, **build_importance_ci_revisit_3day.R**: Trains the XGBoost model built on the full dataset 100 times to get the average information gain for each variable.

* **build_model_revisit_top20.R**, **build_model_revisit_top20_3day.R**, **build_model_revisit_final_top20.R**, **build_model_revisit_final_top20_3day.R**: Repeats the training and testing steps for XGBoost models using the top 20 variables by information gain, including *n_edvisits*, *n_admissions*, *cxr_count*, *ekg_count*, *alcoholrelateddisorders* ... etc.


##### Files in */Scripts*
###### All processing descriptions apply to each patient visit (i.e. by row) unless specified otherwise.

* **1_makerevisitdf.R**: Creates a response vector from the master dataframe that encodes ED return into three categories - revisit within 3 days, revisit between 3 to 9 days, and revisit beyond 9 days or no return.

* **2_currentdiagnoses.R**: Extracts the discharge diagnosis from the current ED visit

* **3_edmeds.R**: Extracts all medications administered during the current ED visit. Only the first word of each string was kept, thus ignoring dosing or route of administration. The 100 most frequently administered medications were kept and all others binned to 'othermeds'. 

* **4_cleanlabs.R**: Cleans the labs csv file to return a list of dataframes with the 150 most frequently drawn labs. List contains two dataframes; one for numeric labs and another for urinalysis plus culture labs. 

* **5_procedures.R**: Bins all imaging orders into 8 main categories then returns a wide dataframe of 40 most frequently ordered procedures.

* **6_edvitalsclean.R**: Cleans the vitals (removes outliers) and filters it based on the time the patient was roomed such that only the vitals taken after triage are kept

* **7_currentvitals.R**: Outputs the mean, min and max values of vitals taken after triage for each encounter.

* **8_cleanpcp.R**: Extracts a boolean flag for whether the patient in the encounter has a primary care provider listed in the EHR.


###### The following scripts process the merged dataframe created by **master_revisit.R** into a numeric matrix for input to the analysis scripts

* **cleanmerged_revisit.R**: Filters visits for inclusion criteria (age >=18, within study period) and cleans the variables in the merged dataframe by reassigning levels for categorical variables with high number of levels, replacing missing values with 0s for count and binary variables such as PMH, and correcting duplicate columns.

* **makematrix_revisit.R**: Converts the cleaned dataframe into a numeric matrix and a response vector. The type of response vector (9-day return vs 72-hour return) is specified by the "nineday" argument.

* **splitdataindex_revisit.R**: Returns a list of random splits (seeded for reproducibility), with a held out test set of 33,000 (10%), a validation set of 33,000 (10%) and a training set of 264,631 (80%).

* **baseline_df.R**: A filtering function called by models only using administrative data.

* **top20_df.R**,  **top20_df_3day.R**,: A filtering function called by models only using the top 20 variables by information gain
