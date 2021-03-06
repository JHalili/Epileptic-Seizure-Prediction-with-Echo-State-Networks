%% EEG EPILEPY PREDICTION ESN
% load input files into a vector with indices.
files = folderFilteredExplore('Datach_filtered/seizure_predictor');
size(files)
helper= load('correlationMatrix.mat');
Channel_corr = helper.m.channel_correlation;
%% Data properties
frequency_bands = 5;
nr_channels = 18;
inputSize = frequency_bands * nr_channels;
teacherSize = 1;
rand('seed', 58);

%% Reservoir input/output size
trainLen = 20;%length(files);

%% Adjustable parameters
resSize = 500;
initLen = 2;           % in number of files
bias = 0.1;            % bias so that 0 does not lead to 0
alpha = 0.4;           % small alpha -> more input driven (leak rate)

% Scaling parameters
w_scale = 1;
w_back_scale = 1;
w_in_scale = 1;
bias_scale = 1;
reg = 1e-8;
%% Matrix generation

W_0 = rand(resSize, resSize) - 0.5;
maxEig = max(abs(eigs(W_0)));
W = W_0 * ((1.00 / maxEig) * w_scale);

X = rand(nr_channels, resSize*frequency_bands);
L = chol(Channel_corr, 'lower');
Y = L * X;
W_in_t = zeros(inputSize, resSize);
current_index = 0;
for i=1:nr_channels
    for j=1:frequency_bands
        current_index = current_index+1;
        W_in_t(current_index, : )=Y(i, (j-1)*resSize+1:j*resSize);
    end;
end;
W_in = W_in_t';
W_back = rand(resSize, teacherSize);

%% Teacher output, initial res and data assignement
% X (DR) is initialized with 0
X = zeros([resSize, 1]);
opt = 0;

% temporary variables
% ld = length(fileDirs)
% lf =ch_file_nr
data_length_size = 0;
lf = 1;
ld = 1;
for i=1:initLen-1
    for fid = 1:length(files)
        files(fid).patient
        S = FilteredFileContent(files(fid).patient, files(fid).file_name);
        for ii=1:size(S.data, 2)
            X = tanh(W_in * S.data(:,ii) + W*X + bias);
            otp = S.teacher(ii);
        end;
    end;
end;

disp 'Init part is done';
% need to set asside testing data

% data for cross-validation
nr_files = length(files) - initLen;% getting indices for cross-validation

kfold = 1;
partition = cvpartition(nr_files, 'KFold', kfold);
% tune the length of cross-validation
% max length is size(U, 1) which takes some time to compute
cvLen = size(reg, 2);

% vectors to collect MSE for training and testing during cross-validation
cvTestMSE = zeros(cvLen, 1);
cvTrainMSE = zeros(cvLen, 1);

minTestMSE = Inf;
rightReg = reg(1);

opt_old = opt;
chid_train_start = current_chid;
fid_train_start = current_file;
trainMSEValues = [];
testMSEValues = [];
for i = 1: cvLen
    regularization = reg(i);
    
    totalTestMSE = 0;
    totalTrainMSE = 0;
    
    for k=1:kfold
        current_file = fid_train_start;
        M = zeros( resSize + nr_channels*5 + 1, resSize + nr_channels*5 + 1);
        T = zeros(1,resSize + nr_channels*5 + 1);
        idxTrain = partition.training(k);
        for fid = 1:length(files)
                S = FilteredFileContent(files(fid).patient, files(fid).file_name);
                % split our current training set according to the indexes
                % only the training set is used
                if idxTrain(current_file) == 1
                    for jj = 1 : size(S.s.data, 2)
                        X = tanh(W_in * S.s.data(:, jj) + W*X  + bias);
                        vect = vertcat(S.s.data(:, jj), X);
                        M = M + vect * vect';       % collecting X data into M
                        T = T + vect * opt;          % collecting output data into T
                        otp = S.s.teacher(jj);
                    end;
                end;
                
            end;
        end;
        disp 'done with M AND T';
        %% computing the w_out
        W_out = (inv(M + regularization .* eye(resSize + nr_channels*frequency_bands + 1))*T)';
        
        %reset file name and dir name positions
        current_chid = chid_train_start;
        current_file = fid_train_start;
        opt = opt_old;
        generated_output = zeros(1, data_length_size);
        for fid = 1:length(files)
                S = FilteredFileContent(files(fid).patient, files(fid).file_name);
                % compute error training
                if idxTrain(current_file) == 1
                    for jj = 1 : size(S.s.data, 2)
                        X_old = X;
                        X = tanh(W_in * S.s.data(:, jj) + W*X + bias);
                        vect = vertcat(1, X_old, S.s.data(:, jj));
                        
                        generated_output(jj) = W_out*vect;
                        opt = generated_output(jj);
                    end;
                    totalTrainMSE = totalTrainMSE + immse(generated_output, S.teacher);
                % compute error testing
                else
                    for jj = 1 : size(S.s.data, 2)
                        X_old = X;
                        X = tanh(W_in * S.s.data(:, jj) + W*X + bias);
                        vect = vertcat(1, X_old, S.s.data(:, jj));
                        
                        generated_output(jj) = W_out*vect;
                        opt = generated_output(jj);
                    end;
                    totalTestMSE = totalTestMSE + immse(generated_output, S.teacher);
                end;
                
            end;
    % find best model
    averageTrainMSE = totalTrainMSE / kfold;
    averageTestMSE = totalTestMSE / kfold;
    
    trainMSEValues(end+1) = averageTrainMSE;
    averageTrainMSE
    testMSEValues(end+1) = averageTestMSE;
    averageTestMSE
    if(averageTestMSE < minTestMSE)
        minTestMSE = averageTestMSE;
        rightReg = i;
    end;
    
end;

pt = 1:1:length(reg);
figure(1);
plot(trainMSEValues);
figure(2);
plot(testMSEValues);

% compute using the desired parameters again


