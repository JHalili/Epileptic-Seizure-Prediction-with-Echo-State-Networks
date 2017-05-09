%% EEG EPILEPY PREDICTION ESN
% load input files into a vector with indices.
files = folderFilteredExplore('Datach_filtered/test');
files = [files(1), files(2),files(3), files(4), files(11), files(12), files(13)]
helper= load('correlationMatrix.mat');
Channel_corr = helper.m.channel_correlation;
%% Data properties
frequency_bands = 5;
nr_channels = 18;
inputSize = frequency_bands * nr_channels;
teacherSize = 1;
rand('seed', 58);


%% Adjustable parameters
resSize = 500;
initLen = 2;           % in number of files
bias = 0;            % bias so that 0 does not lead to 0
alpha = 0.4;           % small alpha -> more input driven (leak rate)

% Scaling parameters
w_scale = 1;
w_back_scale = 1;
w_in_scale = 1;
bias_scale = 1;
reg = [1e-1, 2*1e-1] ;
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
opt = 1;

% temporary variables
% ld = length(fileDirs)
% lf =ch_file_nr

lf = 1;
ld = 1;
for fid = 1: initLen-1
    S = FilteredFileContent(files(fid).patient, files(fid).file_name);
    for ii=1:size(S.data, 2)
        X = tanh(W_in * S.data(:,ii) + W*X + bias);
        opt = S.teacher(ii);
    end;
end;

disp 'Init part is done';
% need to set asside testing data

% data for cross-validation
% nr_files = length(files) - initLen + 1;% getting indices for cross-validation

nr_files = length(files); 
kfold = 3;
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

count = 1;
h = waitbar(count/kfold,'Please Wait for cross-validation') ;
state_collect = [2,10,4,36,200,150];
trainMSEValues = [];
testMSEValues = [];
for i = 1: cvLen
    regularization = reg(i);
    
    totalTestMSE = [];
    totalTrainMSE = [];
    
    for k=1:kfold
        M = zeros( resSize + nr_channels*5 , resSize + nr_channels*5 );
        T = zeros(1,resSize + nr_channels*5 );
        idxTrain = partition.training(k);
        
        %counter_fid = 1;
        %h1 = waitbar( counter_fid/(nr_files), 'Please wait for W_out');
        for fid = initLen:length(files)
            S = FilteredFileContent(files(fid).patient, files(fid).file_name);
            % split our current training set according to the indexes
            % only the training set is used
            if idxTrain(fid - initLen + 1) == 1
                for jj = 1 : size(S.data, 2)
                    X = (1-alpha)*X + alpha * tanh(W_in * S.data(:, jj) + W*X  + bias);
                    vect = vertcat( X, S.data(:, jj));
                    M = M + vect * vect';         % collecting X data into M
                    T = T + vect' * opt;          % collecting output data into T                                     
                    opt = S.teacher(jj);
                end;
            end;
            %counter_fid = counter_fid + 1;
            %waitbar(counter_fid/nr_files, h1, 'Please wait for Wout'); 
        end;
        
        disp ('done with M AND T ');
        disp( k);
        %% computing the w_out
        W_out = (inv(M + regularization .* eye(resSize + nr_channels*frequency_bands))*T')';
        
        %reset file name and dir name positions
        opt = opt_old;
        count_training = 0;
        count_testing = 0;
        totalTrainMSE1 = 0;
        totalTestMSE1 = 0;
        for fid = initLen:length(files)
            S = FilteredFileContent(files(fid).patient, files(fid).file_name);
            generated_output = zeros(1, size(S.teacher, 2));
            % compute error training
            states = zeros(length(state_collect), size(S.data, 2));
            if idxTrain(fid - initLen + 1) == 1
                for jj = 1 : size(S.data, 2)
                    X = (1-alpha)*X + alpha*tanh(W_in * S.data(:, jj) + W*X + bias);
                    vect = vertcat( X, S.data(:, jj));
                   
                    for s  = 1:length(state_collect)
                        states(s, jj) = X(state_collect(s)); 
                    end;
                    generated_output(jj) = W_out*vect;
                    opt = generated_output(jj);
                end;
                figure;
                hold on;
                for s = 1:length(state_collect)
                    plot(states(s, :));
                end;
                hold off;
                figure;
                plot(W_out);
                
                figure;
                plot(1:size(S.teacher, 2), generated_output, 1:size(S.teacher, 2), S.teacher);
                nm = sprintf('generated_train%d', fid);
                legend(nm,'teacher');
                totalTrainMSE1 = totalTrainMSE1 + immse(generated_output, S.teacher);
                count_training = count_training + 1;
                % compute error testing
            else
                for jj = 1 : size(S.data, 2)
                    X = (1-alpha)*X + alpha*tanh(W_in * S.data(:, jj) + W*X + bias);
                    vect = vertcat(X, S.data(:, jj));
                    
                    generated_output(jj) = W_out*vect;
                    opt = generated_output(jj);
                end;
%                 figure;
%                 plot(1:size(S.teacher, 2), generated_output, 1:size(S.teacher, 2), S.teacher);
%                 nm = sprintf('generated_test%d', fid);
%                 legend(nm, 'teacher');
                totalTestMSE1 = totalTestMSE1 + immse(generated_output, S.teacher);
                count_testing = count_testing + 1;
            end;
            totalTrainMSE(end+1) =totalTrainMSE1 ;
            totalTestMSE(end + 1) = totalTestMSE1 ;
            
        end;
        count = k;
        waitbar(count/kfold, h); 
        totalTrainMSE = totalTrainMSE/count_training;
        totalTestMSE = totalTestMSE/ count_testing;
    end;
    % find best model
    trainMSEValues(end+1) = sum(totalTrainMSE) / kfold;
    testMSEValues(end+1) = sum(totalTestMSE) / kfold;
    
    if(sum(totalTestMSE) / kfold < minTestMSE)
        minTestMSE = sum(totalTestMSE) / kfold;
        rightReg = i;
    end;
end;
%%
figure;
plot(1:size(S.teacher, 2), S.teacher, 1:size(S.teacher, 2), generated_output);
%%
%% compute using the desired parameters again
figure;
plot(1:size(reg, 2), trainMSEValues, 1:size(reg, 2), testMSEValues);
legend('train error', 'test error');

%% gen output

