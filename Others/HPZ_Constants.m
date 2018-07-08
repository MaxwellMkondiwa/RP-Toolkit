classdef HPZ_Constants
    
% this classdef defines the constants (including strings) in the program. 

% there are 2 sections of constants in this file:
%   Part 1 -
%       constants that affect the calculations, the estimations, and/or the 
%       printing style of the results, e.g: thresholds, significance level, etc. 
%   Part 2 -
%       constants that does not affect the results in any way. these include 
%       arbitrary constants, as well as strings and numeric values that
%       are used in the user interface (including waitbars and warnings). 

properties (Constant)
    
    % This variable defines whether we are in "debugger mode", which means
    % that we want very detailed warnings to be printed to the consol, or not. 
    % It is "false" by default, change it to "true" to activate the debugger mode. 
    debugger_mode = false;
    
    
    %% Part 1
    
    % * in this program, in the end we print the results to a CSV file.
    %   we discovered that the precision of the numbers stored in MATLAB is 
    %   64 times bigger than the precision of the numbers that can be stored
    %   in a CSV file.
    %   e.g. MATLAB can tell the difference between 1 and (1+eps),
    %   while in CSV it can only tell the difference between 1 and (1+64*eps). 
    % * therefore, whenever there is a parameter that has a special behaviour
    %   when it goes to +1 or -1 (such as beta in the DA-2 model), we limit
    %   it not to be more than 64*eps closer to -1 / +1, because otherwise
    %   the result file may contain beta=-1 while it is actually not really
    %   -1 (there are cases with beta->(-1) and rho->(inf) that represent a
    %   behaviour that is completely different than beta=(-1)).
    % * if you make advanced adaptations to the code:
    %   * if you don't print to a CSV file but rather immediately use the
    %     results in MATLAB in another function, you may set it to 0.
    %   * if you print the results to another type of file, please check
    %     how precise are the numbers that this file can hold, by printing
    %     from MATLAB this series of numbers: 1+eps, 1+2*eps, 1+4*eps, etc.
    %     and choose the smallest multiplier that printed a number that was
    %     different from 1.
    print_threshold = 64*eps;
    
    % an arbitrary threshold value for the BI method
    % if the criterion of the MMI is smaller than this threshold, then
    % the BI criterion (= the waste) will be considered 0, otherwise it
    % will be 1
    BI_threshold = 10^(-5);
    
    % * a threshold value for the calculation of inconsistency indices,
    %   used when comparing expenditures to determine DRP (directly revealed
    %   preference) and SDRP (strict directly revealed preference).
    %   it is needed for numeric reasons.
    % * in DRP this threshold is liberal: the bigger the threshold the more
    %   DRP relations there will be. 
    %   in SDRP this threshold is conservative: the bigger the threshold
    %   the less SDRP relations there will be. 
    % * we performed many tests in order to determine the "right" threshold
    %   to be used here. our results show that in order for the results to be
    %   "stable" when performing transformation on the quantities or prices
    %   (e.g. multiply all quantities by some k > 0), this threshold should
    %   be at least 3*eps. we also found out that normally, there is no
    %   difference in the results whether this threshold is 3*eps or
    %   10^(10)*eps. so this threshold can be 3*eps, 10*eps, 1000*eps and
    %   etc. we decided arbitrarily to have this threshold equal to 10*eps.
    index_threshold = 10*eps;
    % * a threshold value for the calculation of inconsistency indices,
    %   used when comparing quantities in different bundles in order to
    %   determine whether the quantities are the same, and the bundles are
    %   identical, a determining that is crucial for WARP and SARP. 
    %   it is needed for numeric reasons.
    % * basically, it is enough to set this threshold to 1*eps in irder for
    %   the results to be "stable", but just like the previous threshold,
    %   using a bigger threshold doesn't make any difference. we decided 
    %   arbitrarily to have this threshold equal to 10*eps.
    identical_choices_threshold = 10*eps;
    
    % threshold to determine whether to consider the MMI criterion to be
    % impossible. it basically must be in the range [0,1], but due to
    % calculation limitations, we allow it to be in the range:
    % [-threshold , 1+threshold]
    MMI_threshold = 10^(-5);
    
    % significance level (significance_level)   (a number in (0.000,0.500)) 
    % (for a one sided test/confidence interval; e.g., if this variable equals 0.05,
    %  than the actual significance level will be 0.10 for a two-sided
    %  confidence interval resulting from the bootstrap)
    significance_level = 0.05;
    
    % number of significant digits to be printed (print_precision)
    % the precision of numeric results that are printed to results files 
    % (except for residual results) - number of significant digits.
    % changes to the precision should be done from here. note that it must  
    % be a non-negative integer.
    % Due to Matlab's computational limitations, the highest meaningful
    % precision is approximately 10^(-18)
    % We intentionally define the precision to be bigger than the maximal
    % possible precision, in order to avoid rounding of the results that
    % will lead to misinterpretation. Examples:
    %   (1) in CRRA sometimes the first parameter (Beta) is estimated as
    %       ~(-0.9999999999), along with a high value of rho.
    %       Rounding it to -1 will result a completely wrong interpretation 
    %       of the subject's preferences.
    %   (2) in CARA sometimes the second parameter (A) is estimated as ~10^(-30).
    %       Rounding it to 0 will give a meaningless result.
    %   (2) in CES sometimes the first parameter (Alpha) is estimated as ~0.9999999999. 
    %       Rounding it to 1 will result a completely wrong interpretation 
    %       of the subject's preferences.
    % Therefore, we strongly recommend to keep this precision level as is, 
    % and if needed for purposes of presentation, to round the numbers 
    % *after* those are printed to the excel/csv files.
    print_precision = 20;

    % fix endowments error (fix_endowments_error)
    % (if endowment is more than (1+error) or less than 1/(1+error),
    %  a warning will be displayed)
    fix_endowments_error = 0.05;
    
    % max_starting_points : Default max number of initial points to check
    % through the optimization algorithm - for numeirc estimation and for analytic estimation. 
    % The Algorithm may stop before going through all the initial points, 
    % if it reaches the required number of convergence point or reaches the time limit.
    % Note that all initial points are being determined before the
    % estimation begins (in a 2 x max_starting_points matrice), therefore 
    % these numbers must not be inf and not extermely high (e.g. 10^6).
    max_starting_points_numeric = 30;
    max_starting_points_analytic = 100;
    
    % possible values for min_counter 
    % (possible values presented for the user to choose from)
    % defines number of convergence points that if reached then the
    % estimation for this subject is considered finished.
    min_counter_values = {'3','4','5','6','7','8','9','10','12','14','16','18','20','25','30'};
    
    % size of sample for bootstrap : default sizes of sample for bootstrap
    % for numeirc estimation and for analytic estimation
    bootstrap_sample_size_numeric = 100;
    bootstrap_sample_size_analytic = 1000;
    
    
    
    
    
    %% Part 2
    
    % general
    no = 0;
    yes = 1;
    
    % for some purposes, we will refer 1,000,000,000 as inf (regarding parameter values) 
    infinity = 1000000000;
    
    excel_alphabet = {'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z',...
            'AA','AB','AC','AD','AE','AF','AG','AH','AI','AJ','AK','AL','AM','AN','AO','AP','AQ','AR','AS','AT','AU','AV','AW','AX','AY','AZ',...
            'BA','BB','BC','BD','BE','BF','BG','BH','BI','BJ','BK','BL','BM','BN','BO','BP','BQ','BR','BS','BT','BU','BV','BW','BX','BY','BZ',...
            'CA','CB','CC','CD','CE','CF','CG','CH','CI','CJ','CK','CL','CM','CN','CO','CP','CQ','CR','CS','CT','CU','CV','CW','CX','CY','CZ',...
            'DA','DB','DC','DD','DE','DF','DG','DH','DI','DJ','DK','DL','DM','DN','DO','DP','DQ','DR','DS','DT','DU','DV','DW','DX','DY','DZ',...
            'EA','EB','EC','ED','EE','EF','EG','EH','EI','EJ','EK','EL','EM','EN','EO','EP','EQ','ER','ES','ET','EU','EV','EW','EX','EY','EZ',...
            'FA','FB','FC','FD','FE','FF','FG','FH','FI','FJ','FK','FL','FM','FN','FO','FP','FQ','FR','FS','FT','FU','FV','FW','FX','FY','FZ',...
            'GA','GB','GC','GD','GE','GF','GG','GH','GI','GJ','GK','GL','GM','GN','GO','GP','GQ','GR','GS','GT','GU','GV','GW','GX','GY','GZ',...
            'HA','HB','HC','HD','HE','HF','HG','HH','HI','HJ','HK','HL','HM','HN','HO','HP','HQ','HR','HS','HT','HU','HV','HW','HX','HY','HZ',...
            'IA','IB','IC','ID','IE','IF','IG','IH','II','IJ','IK','IL','IM','IN','IO','IP','IQ','IR','IS','IT','IU','IV','IW','IX','IY','IZ',...
            'JA','JB','JC','JD','JE','JF','JG','JH','JI','JJ','JK','JL','JM','JN','JO','JP','JQ','JR','JS','JT','JU','JV','JW','JX','JY','JZ'};

    
    % actions (action_flag)
    Consistency_action = 1;
    NLLS_action = 2;
    MMI_action = 3;
    BI_action = 4;
    
    % actions names
    % (these are the texts that will appear to the user in
    %  the user-interface screen)
    Consistency_action_name = 'Consistency Tests and Inconsistency Indices';
    NLLS_action_name        = 'Nonlinear Least Squares';
    MMI_action_name         = 'Money Metric Index Method';
    BI_action_name          = 'Binary Index Method';
    all_actions_names = {HPZ_Constants.Consistency_action_name,...
                        HPZ_Constants.NLLS_action_name,...
                        HPZ_Constants.MMI_action_name,...
                        HPZ_Constants.BI_action_name};
                    
    % actions file names
    % (these will be in the beginning of the results files names
    %  for each of these actions)
    Consistency_action_file_name = 'Consistency Indices';
    NLLS_action_file_name        = 'Nonlinear Least Squares';
    MMI_action_file_name         = 'Money Metric Index Method';
    BI_action_file_name          = 'Binary Index Method';
    
    
    
    % metrics and aggregators (metric_flag, aggregation_flag)
    % these are possible metrics for the NLLS method
    euclidean_metric = 1;
    CFGK_metric = 2;
    % these are possible aggregators for the MMI method
    MMI_Max = 1;
    MMI_Mean = 2;
    MMI_AVGSSQ = 3;

    % preferences classes (pref_class)
    risk_pref = 1;
    OR_pref = 2;

    % functional forms (function_flag)
    % risk functional forms
    CRRA_func = 1;
    CARA_func = 2;
    % other-regarding functional forms
    CES_func = 1;
    
    
    
    % whether to show a seperate waitbar for each subject (1), show a 
    % single waitbar for all subjects in each run (2) or not to show a 
    % waitbar at all (0) (waitbar_options)
    waitbar_none = 0;
    waitbar_per_subject = 1;
    waitbar_single = 2;
    
    % max user-interface screen size, in percentage of the computer screen size 
    max_height_percent = 0.7;
    
    % when defining listdlg height, it does not take into acount the
    % height of the buttons in the bottom, so we do it instead
    % (if there is also a "select all" button - take this * 2)
    listdlg_extra_height = 60;
    
    
    
    % waitbar constants (must be in ascending order, and all in [0,1]
    % (e.g. when AFRIAT will be finished, the bar in the
    %  waitbar will be set to be waitbar_finish_AFRIAT)
    waitbar_finish_GARP = 0.1;
    waitbar_finish_AFRIAT = 0.2;
    waitbar_finish_VARIAN = 0.6;
    waitbar_finish_HOUTMAN = 1.0;
    
    % waitbar strings
    % headers
    waitbar_name_calculation = 'Calculation is running...';                 % header for when calculating consistency indices
    waitbar_name_estimation = 'Estimation is running...';                   % header for when performing parameters estimation
    % messages
    waitbar_calculation = 'Calculating Subject';                           % 1st part for when any calculation is running
    waitbar_recovery = 'Recovering Subject';                               % 1st part for when any estimation is running
    waitbar_indices = 'Consistency Indices. Please wait...';               % 2nd part for when normal indices calculation is running
    waitbar_residuals_VARIAN = 'VARIAN residuals. Please wait...';         % 2nd part for when residuals VARIAN indices calculation is running
    waitbar_residuals_HOUTMAN = 'HOUTMAN-MAKS residuals. Please wait...';   % 2nd part for when residuals HOUTMAN-MAKS indices calculation is running
    waitbar_preferences = 'Preferences. Please wait...';                   % 2nd part for when normal parameter estimation is running
    waitbar_residuals = 'Residuals. Please wait...';                       % 2nd part for when residual estimation is running
    waitbar_bootstrap = 'Bootstrap. Please wait...';                       % 2nd part for when bootstrap estimation is running
    
    % width of waitbar (how much times wider than default)
    waitbar_width_multiplier = 2;
    
    % when calculating VARIAN or HOUTMAN-MAKS indices, we estimate how much
    % time it will take to finish, and print a message regarding that to
    % the Consol. But if the estimated time is less than the following
    % value (in seconds), we don't bother to print it
    estimated_time_to_print = 1;
    
    
    
    % this string will appear in the user interface screens' headers, in the following way: 
    % e.g. current run is 3 :
    % '(' , current_run_screen , 3 , ')'
    current_run_screen = 'Run Number .';
    
    % these strings will appear in the waitbar headers, in the following way: 
    % e.g. current run is 3 out of a total of 10 runs :
    % '(' , current_run_waitbar , 3 , total_runs_waitbar , 10 , ')'
    current_run_waitbar = 'Run Number .';
    total_runs_waitbar  = ' Out Of ';
    
    % warning message when csvread fails to read a data file
    could_not_read_file_1 = 'Failed to read data file:';
    could_not_read_file_2 = '. Make sure that: (1) the file exists in this path, (2) the file is formatted correctly (it must be a CSV file, and must contain only numeric values).';
    
    
    
    % sub-directory for results files (without the '/' in the beginning)
    results_files_dir = 'Results';
    
    % sub-directory for settings files (without the '/' in the beginning)
    settings_files_dir = 'Settings Files';
    
    % sub-directory of data files
    data_files_dir = 'Data Files';
    
    settings_file_name = 'User_Interface_Settings';   %.csv
    data_settings_file_name = 'User_Data_Settings';   %.csv
    
    % String Constants that are used as headers in the data settings file 
    data_name = 'Data_Name';
    file_name = 'File_Name';
    pref_class = 'Pref_Class';
    subject_index = 'Subject_Index';
    obs_index = 'Observation_Index';
    quantity1_index = 'Quantity1_Index';
    quantity2_index = 'Quantity2_Index';
    maxquantity1_index = 'MaxQuantity1_Index';
    maxquantity2_index = 'MaxQuantity2_Index';
    data_set = 'Data_Selected';
    data_settings_headers = {HPZ_Constants.data_name,...
                            HPZ_Constants.file_name,...
                            HPZ_Constants.pref_class,...
                            HPZ_Constants.subject_index,...
                            HPZ_Constants.obs_index,...
                            HPZ_Constants.quantity1_index,...
                            HPZ_Constants.quantity2_index,...
                            HPZ_Constants.maxquantity1_index,...
                            HPZ_Constants.maxquantity2_index,...
                            HPZ_Constants.data_set};
    
    % max number of datasets that can be saved (not implemented)
    max_datasets = 100;
    
end

end