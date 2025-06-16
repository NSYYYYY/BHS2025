# BHS Project:
# Predicting general cognition from resting-state functional brain connectivity


Permission has been granted for data use of the National Institute of Mental Health (NIMH) Data Archive.
The files utilise in this project were obtained from ABCD-HCP fMRI pipeline v0.0.2 by the DCANS lab team (Sturgeon et al., 2019) . Inclusion criteria included images that were not rejected due to incidental radiological findings, passing satisfactory protocol compliance, and passing FreeSurfer Quality Control. More details about the preprocessing process are detailed in prior work (Hagler et al., 2019).

The rsfMRI data was used to construct a matrix consisting of 119 x 119 nodes, based on parcellated cortical nodes from the schaefer 100 parcel, 17 network atlas (Schaefer et al., 2018; Thomas Yeo et al., 2011), with an addition of 19 subcortical nodes, including the cerebellum from the FreeSurfer Aseg Atlas, resulting in 7,021 unique connections.

# Steps for running the entire analysis to visualization.

# Step 1: Data consolidation and cleaning
Open the data_cleaning_CogComp_T1.Rmd (in RStudio). The top of the Markdown file indicates the necessary files to consolidate and clean the data. 
Ensure that all the files that is required has been retrieved.
Once the Markdown file has been ran, files will be generated for the next step

# Step 2: Subsampling of the data
Use the subsampling.ipynb to subsample the data into the preferred subsample size.
In this stage, the remaining sample will be saved as a different CSV file for potential future use.

# Step 3: Training the model
Next, use the subsample_ml_v5.ipynb to train, test and visualize the model.
The labels for the model can be found in 7021Labels.csv.
The output will be saved as both .joblib files and .csv files for future use.

# Step 4: Connectogram creation
This step uses the CSV files that were obtained from step 3 to create a connectogram in RStudio.
Use the Connectogram_Script_Rstudio_...v2.R to create th connectograms. (There are three different, one for each model)
This step requires an additional labelsFC_schaefer119.csv file (that I am not too sure if I am allowed to share, hence not available)
