# Permutated GLMM Model with sample of sparrow data

### Overview:
This is a permutated Generlized Linear Mixed Model (GLMM) to find the effect that sex, weight and status relative to a given task (demonstrating individuals vs. naive individuals) have on House Sparrow interactions.
(e.g: Does the sex of an individual effects the number of interactions it has within the group?)
This model is part of an of the analysis stage of an ongoing research project I'm participating in, conducted by Lab Lotem group at TLV University, Israel.

### Data:
- sample_df.xlsx - a sample of the whole dataframe used for this analysis, contains both dependant and independant factors for the model.

### GLMM:
The data that was collected is the number of interactions between 2 individuals. Since social network data is inherently non independant (each indevidual is dependant on the other one for an interaction) the model is permutated.

#### Independant factors: 
  1. sex (M/F)
  2. mean weight (individuals were weighted several time during the experiment, here each individual's mean weight is used)
  3. status (Demonstrator/Naive. The interactions were measured in the context of a broader experiment where sparrows were given a food related task. Some individuals were pre trained and somw were not. pre trained were demonstrators and others were naive)

#### Dependant factor:
Number of interactions - The interactions were recorded around a feeding tray for 5 hours of each group. 

#### Random factor: 
Individual's ID nested within the group they are part of is a random factor in the model. 

### Example graph:
Mass Coef value. The dist' of permutations and the red line is the value of the non permutated model. 
![Rplot02](https://github.com/user-attachments/assets/a0e5cf56-0eef-47d4-8726-ee8c2145bd44)
