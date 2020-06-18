function [average_criterion, param] = HPZ_BI_Criterion(param, endowments, observations, treatment, function_flag, pref_class, numeric_flag, BI_threshold, debugger_mode)

% The function calculates and returns the BI criterion per subject. Given a
% specific functional form and prices, we check whether the choice of the
% subject was optimal (criterion = 0) or not (criterion = 1), then we
% aggragate all these per-observation criteria by averaging.

% as for the way the function does that - there might be a better approach, 
% but currently the function calculates the MMI criterion per observation;
% if that criterion is 0 or close enough to 0 - the choice would be deem
% optimal and the BI criterion for it will be set to 0, otherwise it will
% be set to 1.

% "param" is returned because it may change (be rounded) during the
% calculations.

% for detailed explanations about input/output variables that possess
% the same name and meaning in multiple functions (e.g. data, action_flag, 
% pref_class, etc.) see: HPZ_Variables_Documentation in the "Others" sub-folder 


% number of observations
[obs_num,~] = size(observations);


if numeric_flag == HPZ_Constants.analytic || numeric_flag == HPZ_Constants.numeric

    % in analytic and numeric approach, we first calculate the MMI
    % criterions per observation, and only then inspect which of them is 0
    % (with threshold) and which is not
    
    [criterions, param] = HPZ_MMI_Criterion_Per_Observation(param, endowments, observations, treatment, function_flag, pref_class, numeric_flag, debugger_mode);

    % an array where indices of observations where the subject's choice was
    % optimal are set to 1, and the rest are set to 0
    indices_of_optimal_choice = (criterions < BI_threshold);

    % averaging, and inversing (cause we count those that are 0, and we want to
    % count those that are not 0)
    average_criterion = 1 - ((sum(indices_of_optimal_choice(:))) / obs_num) ;
    
elseif numeric_flag == HPZ_Constants.semi_numeric
    
    % in semi-numeric approach, we don't calculate the MMI
    % criterions per observation; we only check of each observation if 
    % the MMI criterion is bigger than 1-HPZ_Constants.BI_threshold or not
    
    [criterions, param] = HPZ_BI_Semi_Numeric(param, observations, function_flag, pref_class, BI_threshold, debugger_mode);
    
    average_criterion = mean(criterions);
    
end

end


