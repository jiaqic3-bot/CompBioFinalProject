%% ============================================================ 
%  FULL PARAMETER SIMULATION SCRIPT (MAPPED TO REAL DATA)
%  Based on "Composition of the sample.csv" structure
%  Parameters based on Table 3 (means & SDs)
% =============================================================

rng(42);  % Set seed for reproducibility

%% --------------------------
% 1. Load the Template Data
% --------------------------
% Read the CSV to get the actual IDs and Group assignments
filename = 'Composition of the sample.csv';

% Check if file exists to avoid errors
if exist(filename, 'file') ~= 2
    error('File "Composition of the sample.csv" not found in current folder.');
end

% Load only ID and Group columns to serve as the skeleton
RawData = readtable(filename);
IDs = RawData.ID;       % Keep original IDs (e.g., P01, P05...)
Groups = RawData.Group; % Keep original Groups

% Count subjects based on the file content
nTotal = height(RawData);

% Create logical masks for indexing
% (Assumes the string is 'Patient' or 'Control' inside the CSV)
isPatient = strcmpi(Groups, 'Patient'); 
isControl = strcmpi(Groups, 'Control');

nPain = sum(isPatient);
nCtrl = sum(isControl);

fprintf('Detected from file: %d Patients, %d Controls (Total: %d)\n', ...
    nPain, nCtrl, nTotal);

%% --------------------------
% 2. Parameter distributions (Table 3 mean ± SD)
% --------------------------
% Patients Stats
mu_R_pain = 12.750;  sd_R_pain = 5.911;
mu_P_pain =  9.953;  sd_P_pain = 2.577;
mu_a_pain =  0.585;  sd_a_pain = 0.300;
mu_d_pain =  0.106;  sd_d_pain = 0.100;
mu_l_pain =  0.105;  sd_l_pain = 0.043;

% Controls Stats
mu_R_ctrl =  9.417;  sd_R_ctrl = 5.031;
mu_P_ctrl =  5.778;  sd_P_ctrl = 3.715;
mu_a_ctrl =  0.569;  sd_a_ctrl = 0.178;
mu_d_ctrl =  0.016;  sd_d_ctrl = 0.018;
mu_l_ctrl =  0.026;  sd_l_ctrl = 0.003;

%% --------------------------
% 3. Initialize & Populate Parameter Vectors
% --------------------------
% Pre-allocate arrays with zeros
betaR = zeros(nTotal, 1);
betaP = zeros(nTotal, 1);
alpha = zeros(nTotal, 1);
decay = zeros(nTotal, 1);
lapse = zeros(nTotal, 1);

% --- A. Generate for PATIENTS (fill only rows where Group == Patient) ---
betaR(isPatient) = normrnd(mu_R_pain, sd_R_pain, nPain, 1);
betaP(isPatient) = normrnd(mu_P_pain, sd_P_pain, nPain, 1);
alpha(isPatient) = normrnd(mu_a_pain, sd_a_pain, nPain, 1);
decay(isPatient) = normrnd(mu_d_pain, sd_d_pain, nPain, 1);
lapse(isPatient) = normrnd(mu_l_pain, sd_l_pain, nPain, 1);

% --- B. Generate for CONTROLS (fill only rows where Group == Control) ---
betaR(isControl) = normrnd(mu_R_ctrl, sd_R_ctrl, nCtrl, 1);
betaP(isControl) = normrnd(mu_P_ctrl, sd_P_ctrl, nCtrl, 1);
alpha(isControl) = normrnd(mu_a_ctrl, sd_a_ctrl, nCtrl, 1);
decay(isControl) = normrnd(mu_d_ctrl, sd_d_ctrl, nCtrl, 1);
lapse(isControl) = normrnd(mu_l_ctrl, sd_l_ctrl, nCtrl, 1);

%% --------------------------
% 4. Create Output Table
% --------------------------
% Combine the ORIGINAL IDs/Groups with the NEW simulated parameters
SimData = table(IDs, Groups, betaR, betaP, alpha, decay, lapse);

% Optional: Rename columns to match preferred style if needed
SimData.Properties.VariableNames{'IDs'} = 'ID';
SimData.Properties.VariableNames{'Groups'} = 'Group';

% Preview first few rows to verify ID continuity is preserved (e.g. P01, P02...)
disp('Preview of generated data:');
disp(head(SimData));

%% --------------------------
% 5. Save output
% --------------------------
outputFilename = "sim_parameters_mapped_to_real_IDs.csv";
writetable(SimData, outputFilename);

fprintf("Done! File saved: %s\n", outputFilename);