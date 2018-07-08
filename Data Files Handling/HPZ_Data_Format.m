function [mat, success] = HPZ_Data_Format (file_path, locations)

% The function formats a data file to a matrix

% file_path is the path (including name file) to the data file to be turned to a matrix 
% locations is a 6-length vector:
%   1 - column number of Subject ID in the matrix
% 	2 - column number of observation number of the subject
% 	3 - column number of the quantity of good 1 chosen by the subject.
% 	4 - column number of the quantity of good 2 chosen by the subject.
% 	5 - column number of the max quantity of good 1 (=1/price).
% 	6 - column number of the max quantity of good 2 (=1/price).

% It returns a matrix of data corresponding to the required treatment.
% The matrix has six columns:
% The first column is the subject ID.
% The second column is the observation number - 50 observations per subject
% The third column is the quantity of good 1 chosen by the subject.
% The fourth column is the quantity of good 2 chosen by the subject.
% The fifth column is the price of good 1. 
% The sixth column is the price of good 2. 

try
	% reading the data file
    [data] = csvread(file_path);
    % formatting the matrix as desired
    mat = [data(:,locations(1)) data(:,locations(2)) data(:,locations(3)) data(:,locations(4)) 1./data(:,locations(5)) 1./data(:,locations(6))];
    success = true;
catch
    warning(char(strcat(HPZ_Constants.could_not_read_file_1, {' '}, file_path, HPZ_Constants.could_not_read_file_2)));
    mat = 0;
    success = false;
end
    

end


