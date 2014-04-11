% loaddata

% Copyright 2013,2014 Marko Dimjašević, Simone Atzeni, Ivo Ugrina, Zvonimir Rakamarić
%
% This file is part of maline.
%
% maline is free software: you can redistribute it and/or modify it
% under the terms of the GNU Affero General Public License as
% published by the Free Software Foundation, either version 3 of the
% License, or (at your option) any later version.
%
% maline is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU Affero General Public License for more details.
%
% You should have received a copy of the GNU Affero General Public License
% along with maline.  If not, see <http://www.gnu.org/licenses/>.


function loaddata()
  % Reading Input Files 
  [gN gDataWeight gDataCount] = readFiles(sprintf('%s%s', getenv('MALINE'), '/data/goodware'));
  [mN mDataWeight mDataCount] = readFiles(sprintf('%s%s', getenv('MALINE'), '/data/malware'));
  printf('Creating Labels...\n');
  dataWeightLabels = zeros(length(gDataWeight(:, 1)), 1);
  dataCountLabels = zeros(length(gDataCount(:, 1)), 1);
  dataWeightLabels = [dataWeightLabels; ones(length(mDataWeight(:, 1)), 1)];
  dataCountLabels = [dataCountLabels; ones(length(mDataCount(:, 1)), 1)];
  printf('Creating Data Matrix...\n');
  dataWeight = [gDataWeight; mDataWeight];
  dataCount = [gDataCount; mDataCount];

  printf('Creating Final...\n');
  dataWeightFinal = [dataWeight dataWeightLabels];
  dataCountFinal = [dataCount dataCountLabels];
  dim = size(dataWeightFinal);
  printf('Creating Last Matrix\n...');
  data = [dataWeightFinal; dataCountFinal];

  printf('Creating data file...\n');
  fid = fopen(sprintf('%s%s', getenv('MALINE'), '/data/features_data.dat'), 'w+');
  fprintf(fid, '%d ', dim);
  fprintf(fid, '90 ');
  fprintf(fid, '1');
  fprintf(fid, '\n');
  printf("Writing data...");
  for i = 1:size(data(:,1))
     fprintf(fid, '%f ', data(i, :));
     fprintf(fid, '\n');
  end
  fclose(fid);
end

function [N dataWeight dataCount] = readFiles(foldername)
  N = 0;
  dataWeight = [];
  dataCount = [];
  filelist = readdir(foldername);
  for ii = 1:numel(filelist)
    ## skip special files . and ..
    if (regexp (filelist{ii}, "^\\.\\.?$"))
      continue;
    endif
    ## load your file
    printf('Filename: %s\n', filelist{ii});
    path = sprintf('%s/%s', foldername, filelist{ii});
    [localN, localDataWeight localDataCount] = readDataFile(path);
    dataWeight = [dataWeight; localDataWeight];
    dataCount = [dataCount; localDataCount];
    N = N = localN;
  endfor
  printf('All files Done!\n');
end

function [N, dataWeight dataCount] = readDataFile(filename)
  printf('Analyzing file %s\n', filename);
  file = fopen(filename);
  dim = fscanf(file, '%d', [1 1]);
  dataWeight = fscanf(file, '%f ', [dim dim]);
  fscanf(file, '%d', [1 1]);
  dataCount = fscanf(file, '%f ', [dim dim]);
  dataWeight = dataWeight(:)';
  dataCount = dataCount(:)';
  N = dim * dim;
  fclose(file);
  printf('Done!\n');
end

%%% Local Variables: ***
%%% mode:octave ***
%%% comment-start: "%"  ***
%%%  End: ***