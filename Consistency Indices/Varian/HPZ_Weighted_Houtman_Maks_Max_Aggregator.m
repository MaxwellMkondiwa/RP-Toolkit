function [w_HM, w_HM_raw, w_HM_weight_per_observation] = HPZ_Weighted_Houtman_Maks_Max_Aggregator (obs_cycle_mat, weights, varargin)


% This function implements the same algorithm that is implemented in 
% "HPZ_Houtman_Maks_Cycles_Approach", but with some modifications, since
% this function can handle the case that dropping observation i has a
% weight of w_i, instead of being equal and constant (weight of 1) for all
% observations. 
% Since the weights are different, there is meaning in using different
% aggregates, so here we also check 3 different aggregates:
% maximum, average, and average sum of squares (AVGSSQ).
%
% The purpose of this function is currently solely as a mean to calculate
% the Varian Efficiency Index; we proved that any problem of calculating
% the Varian index can be translated to a problem of calculating the HM
% index with weights, just like this function does.



% number of observations and of cycles
[obs_num , cycles_num] = size(obs_cycle_mat);



% if there are no observations, we don't need to perform many calculations
if obs_num == 0
    w_HM_raw = 0;
    w_HM = w_HM_raw;
    w_HM_weight_per_observation = w_HM_raw;
    return
% if there is only 1 observation, we don't need to perform many calculations
elseif obs_num == 1
    if any(obs_cycle_mat(1,:)) % sum(obs_cycle_mat(1,:)) > 0
        % we need to choose/drop this observation in order to take care of
        % the remaining cycle/s
        w_HM_raw = weights(1);
        w_HM = w_HM_raw;
        w_HM_weight_per_observation = weights(1);
    else
        % we don't need to choose/drop this observation
        w_HM_raw = 0;
        w_HM = w_HM_raw;
        w_HM_weight_per_observation = w_HM_raw;
    end
    return
end





% initializations of outputs (just in case)
w_HM = nan; %#ok<NASGU>
w_HM_raw = nan;
w_HM_weight_per_observation = zeros(obs_num, 1);   % we need here zeros and not nan, since there are observations that are not part of any minimal cycle, and we want them to have zero and not nan

if isempty(varargin)
    % we always start with approach 1
    approach = 1;
else
    % approach was passed through varargin in a recursive call
    approach = varargin{1};
end

% in the last part of this function, there is a case where we "split up"
% and check 2 different scenarios. it could be that we got a raw index of
% say 0.07 in the first, so in the second we know that there is no point in
% having more than 0.07, and this is what this variable is for.
if length(varargin) < 2
    upper_bound = inf;
else
    upper_bound = varargin{2};
end



% sums the matrix per column
% for each cycle, it finds how many observations (from those remaining) are
% involved / part of this cycle
obs_involved_per_cycle = sum(obs_cycle_mat);

% we want to find all cycles that have only 1 observation
% we MUST take these observations in order to "cover" these cycles 
cycles_with_one_obs = find(obs_involved_per_cycle == 1);

if ~isempty(cycles_with_one_obs)

    % we need to find the observations that belong to these cycles
    obs_that_must_be_chosen = zeros(length(cycles_with_one_obs), 1);
    for k=1:length(cycles_with_one_obs)
        obs_that_must_be_chosen(k) = find(obs_cycle_mat(:, cycles_with_one_obs(k)));
    end
    % delete duplicates
    obs_that_must_be_chosen = unique(obs_that_must_be_chosen);

    % increase the HM_raw, since we "choose" (=drop) these observations
    current_weight = weights(obs_that_must_be_chosen);
    w_HM_raw = max(w_HM_raw , max(current_weight));
    if upper_bound <= w_HM_raw   % all(upper_bound <= w_HM_raw)
        % no need to keep going any further
        w_HM_raw = inf;
        w_HM = w_HM_raw;
        w_HM_weight_per_observation = inf(obs_num,1);
        return
    else
        % update the upper bounds; we will pass this new upper bound to the
        % recursive call ahead 
        if upper_bound <= w_HM_raw
            upper_bound = -inf;
        end
    end
    
    % initialization
    cycles_involved = [];
    for i=1:length(obs_that_must_be_chosen)
        % for each of these observations, we need to delete the cycles that 
        % it is involved with
        obs_cycles = find(obs_cycle_mat(obs_that_must_be_chosen(i), :));
        cycles_involved = unique([cycles_involved , obs_cycles]);
    end

    % finally, we can delete these observations and these cycles from the 
    % obs_cycle_mat matrix
    cycles_to_delete = zeros(cycles_num, 1);
    cycles_to_delete(cycles_involved) = 1;
    cycles_to_remain = (cycles_to_delete == 0);
    obs_to_delete = zeros(obs_num, 1);
    obs_to_delete(obs_that_must_be_chosen) = 1;
    obs_to_delete = (obs_to_delete ~= 0);
    obs_to_remain = (obs_to_delete == 0);
    
    % update residuals
    current_weight = weights(obs_to_delete);
    w_HM_weight_per_observation(obs_to_delete, 1) = current_weight';
    
    % update matrices and vectors by deleting what should be deleted
    obs_cycle_mat = obs_cycle_mat(obs_to_remain , cycles_to_remain);
    weights = weights(obs_to_remain);
    
    
    if isempty(obs_cycle_mat)
        % then we finished
    else
        % we need to use another recursive call
        [~, remaining_HM_raw, remaining_HM_weight_per_observation] = HPZ_Weighted_Houtman_Maks_Max_Aggregator (obs_cycle_mat, weights, 1, upper_bound);
        w_HM_raw = max(w_HM_raw , remaining_HM_raw);
        w_HM_weight_per_observation(obs_to_remain, :) = remaining_HM_weight_per_observation;
    end
    
else
    % if isempty(cycles_with_one_obs),
    % if we can't tell about any observation that we "must" choose it,
    % then we need to take an observation (e.g. the observation with the
    % biggest number of cycles, or some aggregate of cycles), and check
    % both options: the option of choosing (dropping) it, and the option
    % of not choosing it.
    
    % we apply 1 of 2 algorithms here:
    % Algorithm 1 : delete every observation i such that there is another
    % observation j such that the set of cycles of i is a subset of the set
    % of cycles of j. if the sets are equal, we will arbitrarily delete
    % only one of them. we only want to find some minimal set of
    % observations to drop, not every set, therefore we can always assume
    % that it would be better to drop the observation that is involved with
    % the same cycles and possibly with other cycles.
    % Algorithm 2 : choose an observation, then check 2 options: either to
    % take (drop) this observation or not (each option is checked by a
    % recursive call), then we determine which of the 2 options is better
    % (has lower Houtman-Maks raw index).
    
    if approach == 1
        
        % --- Algorithm 1 ---
        % to improve time complexity, we first create a cell array, in the i'th
        % place it contains a vector with all the indices of cycles that
        % observation i is involved with
        cycles_of_each_obs = cell(obs_num, 1);
        for i=1:obs_num
            cycles_of_each_obs{i} = find(obs_cycle_mat(i,:));
        end
        
        % to improve time complexity, during the process we keep track over 
        % observations that we already decided to drop 
        % (NOTE: "drop" here means that we DON'T choose to drop this
        % observation, it means that we just "drop" it from our matrix)
        was_dropped = zeros(obs_num, 1);
        
        % we "drop" observations that are now involved with 0 cycles.
        % we need this in addition to the code ahead, because we want to
        % drop this observation even if its weight is the smallest of all.
        for i=1:obs_num
            if isempty(cycles_of_each_obs{i})
                was_dropped(i) = 1;
            end
        end
        
        % for each couple of observations, we check if one is a subset of the other 
        % (meaning, the set of cycles it is involved with is a subset of the set of 
        % cycles the other is involved with) 
        for i=1:(obs_num-1) 
            for t=(i+1):obs_num
                % if we already dropped one of them, we don't need to check
                if was_dropped(i) || was_dropped(t)
                    continue
                end
                cycles_i = cycles_of_each_obs{i};
                cycles_t = cycles_of_each_obs{t};
                i_not_subset = false;
                t_not_subset = false;
                l_cycle_i = length(cycles_i);
                l_cycle_t = length(cycles_t);
                if l_cycle_i > l_cycle_t
                    i_not_subset = true;
                    difference = l_cycle_i - l_cycle_t;
                    ai = 1;
                    for at=1:l_cycle_t
                        while ai <= l_cycle_i && cycles_t(at) ~= cycles_i(ai)
                            ai = ai + 1;
                        end
                        if ai-at > difference
                            t_not_subset = true;
                            break
                        end
                    end
                elseif l_cycle_i < l_cycle_t
                    t_not_subset = true;
                    difference = l_cycle_t - l_cycle_i;
                    at = 1;
                    for ai=1:l_cycle_i
                        while at <= l_cycle_t && cycles_t(at) ~= cycles_i(ai)
                            at = at + 1;
                        end
                        if at-ai > difference
                            i_not_subset = true;
                            break
                        end
                    end
                else
                    for a=1:l_cycle_i
                        if cycles_t(a) ~= cycles_i(a)
                            i_not_subset = true;
                            t_not_subset = true;
                            break
                        end
                    end
                end

                % if one of them is a subset - we delete it,
                % but only if its weight is not-smaller than that of the other 
                % (it must be "if... elseif..." and not "if... if...", so we will never delete both) 
                if ~i_not_subset && weights(i) >= weights(t)
                    was_dropped(i) = 1;
                    w_HM_weight_per_observation(i) = 0;   % set its weight to 0
                elseif ~t_not_subset && weights(t) >= weights(i)
                    was_dropped(t) = 1;
                    w_HM_weight_per_observation(t) = 0;   % set its weight to 0
                end
            end
        end

        if ~any(was_dropped)   % sum(was_dropped) == 0
            % we couldn't "drop" any observation
            % we make a recursive call to the 2nd approach (Algorithm 2)
            if ~isempty(obs_cycle_mat)
                [~, w_HM_raw, w_HM_weight_per_observation] = HPZ_Weighted_Houtman_Maks_Max_Aggregator (obs_cycle_mat, weights, 2, upper_bound);
            end
        else
            remaining_obs = find(~was_dropped);   % find(was_dropped == 0);
            if ~isempty(obs_cycle_mat) && ~isempty(remaining_obs)
                % we need to use another recursive call to this approach (1st approach) 
                [~, remaining_HM_raw, remaining_HM_weight_per_observation] = HPZ_Weighted_Houtman_Maks_Max_Aggregator (obs_cycle_mat(remaining_obs, :), weights(remaining_obs), 1, upper_bound);
                w_HM_raw = max(w_HM_raw , remaining_HM_raw);
                w_HM_weight_per_observation(remaining_obs, :) = remaining_HM_weight_per_observation;
            end
        end
        
    elseif approach == 2
        
        % initializations
        assigned_obs = false(1, length(weights));
        obs_subsets = cell(0,0);
        
        while ~all(assigned_obs)
            
            [~, current_obs] = max(~assigned_obs);
            
            % initialization of independent subset of obs
            obs_current_subset = false(1, length(weights));
            previous_obs_current_subset = obs_current_subset;
            obs_current_subset(current_obs) = true;
            
            while any(obs_current_subset & ~previous_obs_current_subset)   % any(obs_to_assign)   % sum(obs_to_assign) > 0
                
                previous_obs_current_subset = obs_current_subset;
                
                % all cycles (columns) that are involved with the obs of 
                % the current version of independent subset of obs 
                cycles_involved = any(obs_cycle_mat(obs_current_subset, :), 1);
                
                % updating the independent subset of obs
                obs_current_subset = any(obs_cycle_mat(: , cycles_involved), 2)';
            end
            
            obs_subsets{end+1} = obs_current_subset; %#ok<AGROW>
            
            % update those who were assigned
            assigned_obs = assigned_obs | obs_current_subset;
        end
        
        % for each subset - calculate independently
        for subset_num = 1:length(obs_subsets)
            
            obs_of_this_subset = obs_subsets{subset_num};
            cycles_of_this_subset = any(obs_cycle_mat(obs_of_this_subset, :), 1);
            
            [~, subset_w_HM_raw, subset_w_HM_weight_per_observation] = HPZ_Weighted_Houtman_Maks_Max_Aggregator (obs_cycle_mat(obs_of_this_subset, cycles_of_this_subset), weights(obs_of_this_subset), 3, upper_bound);
            
            w_HM_raw = max(w_HM_raw , subset_w_HM_raw);
            w_HM_weight_per_observation(obs_of_this_subset, :) = subset_w_HM_weight_per_observation;
            
            % update upper bound
            % we do not update upper_bound because here (unlike approach 3) 
            % we don't compare alternatives, but we just calculate
            % separately for different subsets.
            if upper_bound <= 0 % all(upper_bound <= 0)
               % no need to keep going any further
                w_HM_raw = inf;
                w_HM = w_HM_raw;
                w_HM_weight_per_observation = inf(obs_num,1);
                return
            end
        end  
        
    else % approach == 3
        
        % --- Algorithm 3 ---
        % we prefer to take the observation that is involved with the biggest
        % amonut of cycles, but involvment in a small cycle is of more "value"
        % than involvement in a big cycle, so we give each cycle a weight that
        % equals to 1 / (cycle length)
        cycles_values = 1 ./ obs_involved_per_cycle;
        observations_values = zeros(obs_num, 1);
        for i=1:obs_num
            observations_values(i) = sum(obs_cycle_mat(i, :) .* cycles_values);   % / weights(i);   % in theory, I expected this addition (/weight) to help, but it does the opposite :|
        end
        [~, obs_to_take] = max(observations_values);


        % option I - choose (drop) this observation
        current_weight = weights(obs_to_take);
        w_HM_raw_1 = max(w_HM_raw , max(current_weight));
        
        % update the upper bounds; we will pass this new upper bound to the
        % recursive call ahead
        upper_bound_1 = upper_bound; % (THIS LINE WAS MISSING, FIXED IN 19.03.2019)  
        if upper_bound <= w_HM_raw_1
            upper_bound_1 = -inf;
        end
        if upper_bound_1 <= 0   % all(upper_bound_1 <= 0)   % all(upper_bound_1 <= w_HM_raw_1)
            % no need to keep any further in this direction
            w_HM_raw_1 = inf;
            remaining_w_HM_weight_per_observation_1 = inf(obs_num-1,1);
            obs_to_remain_1 = [];
            obs_cycle_mat_1 = [];
        else
            cycles_to_remain_1 = (obs_cycle_mat(obs_to_take, :) == 0);
            obs_to_remain_1 = [1:(obs_to_take-1) , (obs_to_take+1):obs_num];
            obs_cycle_mat_1 = obs_cycle_mat(obs_to_remain_1 , cycles_to_remain_1);
            weights_1 = weights(obs_to_remain_1);
            if ~isempty(obs_cycle_mat_1)
                % we need to use another recursive call
                [~, remaining_w_HM_raw_1, remaining_w_HM_weight_per_observation_1] = HPZ_Weighted_Houtman_Maks_Max_Aggregator (obs_cycle_mat_1, weights_1, 1, upper_bound_1);
                w_HM_raw_1 = max(w_HM_raw_1 , remaining_w_HM_raw_1);
            end
        end


        % option II - don't choose (don't drop) this observation
        w_HM_raw_2 = w_HM_raw;   % = 0;
        % update the upper bounds in response to the results of the
        % first recursive call; we will pass this new upper bound to 
        % the second recursive call ahead
        upper_bound_2 = min(w_HM_raw_1 , upper_bound);
        if upper_bound_2 <= 0   % all(upper_bound_2 <= w_HM_raw_2)
            % no need to keep any further
            w_HM_raw_2 = inf;
            remaining_w_HM_weight_per_observation_2 = inf(obs_num-1,1);
            obs_to_remain_2 = [];
            obs_cycle_mat_2 = [];
        else
            obs_to_remain_2 = [1:(obs_to_take-1) , (obs_to_take+1):obs_num];
            obs_cycle_mat_2 = obs_cycle_mat(obs_to_remain_2 , :);
            weights_2 = weights(obs_to_remain_2);
            if ~isempty(obs_cycle_mat_2)
                % we need to use another recursive call
                [~, remaining_w_HM_raw_2, remaining_w_HM_weight_per_observation_2] = HPZ_Weighted_Houtman_Maks_Max_Aggregator (obs_cycle_mat_2, weights_2, 1, upper_bound_2);
                w_HM_raw_2 = max(w_HM_raw_2 , remaining_w_HM_raw_2);
            end
        end
        
        % AGGREGATE MAX
        if w_HM_raw_1 < w_HM_raw_2
            % I (choose / drop) is better
            w_HM_raw = w_HM_raw_1;
            w_HM_weight_per_observation(obs_to_take, 1) = weights(obs_to_take)';
            if ~isempty(obs_cycle_mat_1)
                w_HM_weight_per_observation(obs_to_remain_1, 1) = remaining_w_HM_weight_per_observation_1(:,1);
            end
        else   % if w_HM_raw_1(1) > w_HM_raw_2(1)
            % II (don't choose / don't drop) is better
            w_HM_raw = w_HM_raw_2;
            w_HM_weight_per_observation(obs_to_take, 1) = 0;   % we don't need to drop this obs 
            if ~isempty(obs_cycle_mat_2)
                w_HM_weight_per_observation(obs_to_remain_2, 1) = remaining_w_HM_weight_per_observation_2(:,1);
            end
        end
        
    end
    
end



% calculate the final HM index by dividing by the number of observations (if needed; not needed here) 
w_HM = w_HM_raw;



end