function in_sample_difference_residuals = HPZ_Consistency_Indices_In_Sample_Difference_Residuals_Calc (per_observation_index, aggregation_method)

% Input :
% per_observation_index - a vector of all the per-observation indices
% aggregation_method - a matlab function that is used to aggregate numbers
%   to a single index. e.g:
%   Avergae : @mean
%   Maximum : @max
%   AVGSSQ  : @(x) sqrt(meansqr(x))
% Output :
% in_sample_residuals - the in-sample Difference residual for each of the
% observations, based on the specified aggregation method.

% This function is currently used only for the VARIAN index, which
% currently have 3 aggregators: Average, Minimum and AVGSSQ.



% the full index with all observations
full_index = aggregation_method(per_observation_index);

% initialization of residuals vector
in_sample_difference_residuals = per_observation_index;
% calculation of residuals
num_of_obs = length(per_observation_index);
if num_of_obs == 1
    % this occurs when we calculate out-of-sample, and the recursive calls
    % somtimes lead to num_of_obs == 1
    in_sample_difference_residuals(1) = full_index;
else
    % calculate the in_sample residual
    for t=1:num_of_obs
        in_sample_difference_residuals(t) = full_index - aggregation_method(per_observation_index([1:(t-1),(t+1):num_of_obs]));
    end
end

end