clear all
close all
load('decoy_233_participants.mat');

Dcost = data.Dcost;
Drate = data.Drate;
costbin = data.costbin;
ratebin = data.ratebin;

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

% Calculate quantiles for each participant
quantileCost = zeros(size(Dcost));  % Initialize matrix for quantile values
quantileRate = zeros(size(Drate));

for i = 1:size(Dcost, 1)  % Iterate over each participant
    for j = 1:size(Dcost, 2)  % Iterate over each measurement
        quantileCost(i, j) = findQuantileCost(Dcost(i, j), costbin(i, :));
        quantileRate(i, j) = findQuantileRate(Drate(i, j), ratebin(i, :));
    end
end


csvwrite('qcost.csv', quantileCost);
csvwrite('qrate.csv', quantileRate);