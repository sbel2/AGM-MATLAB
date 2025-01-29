clear all
close all
load('decoy_233_participants.mat');

% Extract relevant data
Arate = data.Arate;
Acost = data.Acost;
Brate = data.Brate;
Bcost = data.Bcost;
Dcost = data.Dcost;
Drate = data.Drate;
costbin = data.costbin;
ratebin = data.ratebin;

% Function to find quantile based on cost
function quantile = findQuantileCost(att_val, bin)
    numBins = length(bin) - 1;  % Number of bins is one less than number of edges
    interval = 0;  % Initialize interval to zero, indicating not found
    for i = 2:length(bin)  % Start loop from 2 since MATLAB is 1-indexed
        if att_val <= bin(i-1) && att_val >= bin(i)
            interval = i - 1;  % Correct for MATLAB's 1-based indexing
            break;
        end
        if att_val < bin(end)  % Check if value is below the lowest bin
            interval = numBins;
            break;
        end
    end
    if interval == 0
        quantile = NaN;  % Use NaN to indicate an error/unclassified
    else
        quantile = interval / numBins;  % Convert interval index to decimal quantile
    end
end

% Function to find quantile based on rate
function quantile = findQuantileRate(att_val, bin)
    numBins = length(bin) - 1;  % Number of bins is one less than number of edges
    interval = 0;  % Initialize interval to zero
    for i = 2:length(bin)  % Start loop from 2 in MATLAB
        if att_val >= bin(i-1) && att_val <= bin(i)
            interval = i - 1;  % MATLAB index correction
            break;
        end
        if att_val > bin(end)  % Check if value exceeds the highest bin
            interval = numBins;
            break;
        end
    end
    if interval == 0
        quantile = NaN;  % Use NaN for error indication
    else
        quantile = interval / numBins;  % Convert to decimal quantile
    end
end

% Initialize matrices for quantiles
quantileCostA = zeros(size(Acost));
quantileRateA = zeros(size(Arate));
quantileCostB = zeros(size(Bcost));
quantileRateB = zeros(size(Brate));
quantileCostD = zeros(size(Dcost));
quantileRateD = zeros(size(Drate));

% Calculate quantiles for each option (A, B, D)
for i = 1:size(Dcost, 1)  % Iterate over each participant
    for j = 1:size(Dcost, 2)  % Iterate over each measurement
        % Option A
        quantileCostA(i, j) = findQuantileCost(Acost(i, j), costbin(i, :));
        quantileRateA(i, j) = findQuantileRate(Arate(i, j), ratebin(i, :));
        
        % Option B
        quantileCostB(i, j) = findQuantileCost(Bcost(i, j), costbin(i, :));
        quantileRateB(i, j) = findQuantileRate(Brate(i, j), ratebin(i, :));
        
        % Option D
        quantileCostD(i, j) = findQuantileCost(Dcost(i, j), costbin(i, :));
        quantileRateD(i, j) = findQuantileRate(Drate(i, j), ratebin(i, :));
    end
end

% Save results as .mat files
save('quantileCostA.mat', 'quantileCostA');
save('quantileRateA.mat', 'quantileRateA');
save('quantileCostB.mat', 'quantileCostB');
save('quantileRateB.mat', 'quantileRateB');
save('quantileCostD.mat', 'quantileCostD');
save('quantileRateD.mat', 'quantileRateD');