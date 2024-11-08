function varargout = plugin_ImageComparison(fcn,varargin)
%-------------------------------------------------
%Demo code to produce own plug-ins to segment. Use this code as a template
%to write own functions.

%Einar Heiberg

if nargin==0
  myfailed('Expects at least one input argument.');
  return;
end;

switch fcn
  case 'getname'
    varargout = cell(1,1);
    
		%Segment with versions >1.636 calls with two input arguments where
		%the second input argument is the handle to the menu item.
    
		%Register submenus. You need to change label and callback here!!!
		uimenu(varargin{1},'Label','Subtract','Callback','plugin_ImageComparison(''funSubtract_Callback'')');
		uimenu(varargin{1},'Label','Divide','Callback','plugin_ImageComparison(''funDivide_Callback'')');
    
    %Here write your own title that will be shown on menu.
    varargout{1} = 'ImageComparison tools'; 
    
    %The above code is an example of a plug-in with subfunctions. To create
    %a simple function comment the above code and uncomment the code below.
    
    %set(varargin{1},'Label','Demo plugin','Callback','plugin_template(''funa'')');
    %varargout{1} = 'Plug-in template';     
    set(varargin{1},'Callback',''); 
  case 'getdependencies'
    %Here: List all depending files. This is required if your plugin should
    %be possible to compile to the stand-alone version of Segment.
    varargout = cell(1,4);
    
    %M-files, list as {'hello.m' ...};
    varargout{1} = {};

    %Fig-files, list as {'hello.fig' ... };
    varargout{2} = {};
    
    %Mat-files, list as {'hello.mat' ... };
    varargout{3} = {};
    
    %Mex-files, list as {'hello' ...}; %Note i.e no extension!!!
    varargout{4} = {};
    
  otherwise
    macro_helper(fcn,varargin{:}); %Future use to record macros
		[varargout{1:nargout}] = feval(fcn,varargin{:}); % FEVAL switchyard    
end;
end

%---------------------
function funSubtract_Callback %#ok<DEFNU>
%---------------------
%Here your write all your code, you may use sub-functions.
%
%The global variables are:
%-DATA contains GUI information and edgedetected images
%-NO   current image stack, this is a scalar
%-SET  contains each image set info such as
%      IM (image data)
%      XSize (size in x etc)
%      ..
%      TIncr (time increment)
%      Resolution (in mm)
%      SliceThickness (in mm)
%      ...
%      EndoX (x-points of segmentation endocardie)

global DATA SET NO

%Usually good to check!
if not(DATA.DataLoaded)
  myfailed('No data loaded.');
  return;
end;

%mymsgbox(dprintf('You have %d image stacks loaded.',length(SET)));

sdesc = {};
for sloop = 1:length(SET)
  sdesc{sloop} = sprintf('%i: %s', sloop, SET(sloop).SeriesDescription); %#ok<AGROW>
end


no1 = mymenu('C = A - B, select A', sdesc);
no2 = mymenu('C = A - B, select B', sdesc);

% Check if dimensions are compatible
sz1 = size(SET(no1).IM);
sz2 = size(SET(no2).IM);

if ~all(sz1 == sz2)
  myfailed('Images are not the same size!');
end

% Create new image
newNO = length(SET)+1;

SET(newNO) = SET(no1);
SET(newNO).IM = SET(no1).IM - SET(no2).IM;

Im1 = SET(no1).IM(:,:,:,5:end);
Im2 = SET(no2).IM(:,:,:,5:end);

RMSD = sqrt(sum( (Im1(:) - Im2(:)   ).^2 ));

disp(['RMSD volume(', num2str(no1),' , ', num2str(no2),') = ', num2str(RMSD) ])

SET(newNO).SeriesDescription = ...
  sprintf('Subtraction: %s - %s', SET(no1).SeriesDescription, SET(no2).SeriesDescription);

% Update links etc
SET(newNO).Linked = newNO;
SET(newNO).Children = [];
SET(newNO).Parent = [];
SET(newNO).Flow = [];

% Update GUI
%viewfunctions('setview')

end

%---------------------
function funDivide_Callback %#ok<DEFNU>
%---------------------
% Here your write all your code, you may use sub-functions.
%
%The global variables are:
%-DATA contains GUI information and edgedetected images
%-NO   current image stack, this is a scalar
%-SET  contains each image set info such as
%      IM (image data)
%      XSize (size in x etc)
%      ..
%      TIncr (time increment)
%      Resolution (in mm)
%      SliceThickness (in mm)
%      ...
%      EndoX (x-points of segmentation endocardie)

global DATA SET NO

%Usually good to check!
if not(DATA.DataLoaded)
  myfailed('No data loaded.');
  return;
end;

%mymsgbox(dprintf('You have %d image stacks loaded.',length(SET)));

sdesc = {};
for sloop = 1:length(SET)
  sdesc{sloop} = sprintf('%i: %s', sloop, SET(sloop).SeriesDescription); %#ok<AGROW>
end


no1 = mymenu('C = A / B, select A', sdesc);
no2 = mymenu('C = A / B, select B', sdesc);

% Check if dimensions are compatible
sz1 = size(SET(no1).IM); disp(sz1)
sz2 = size(SET(no2).IM);

if ~all(sz1 == sz2)
  myfailed('Images are not the same size!');
end

% Create new image
newNO = length(SET)+1;

SET(newNO) = SET(no1);
SET(newNO).IM = SET(no1).IM ./ SET(no2).IM;

Im1 = SET(no1).IM(:,:,:,5:end);
Im2 = SET(no2).IM(:,:,:,5:end);

RMSD = sqrt(sum( (Im1(:) - Im2(:)   ).^2 ));

disp('RMSD volume(', no1, ',', no2,') = ', RMSD)

SET(newNO).SeriesDescription = ...
  sprintf('Divison: %s / %s', SET(no1).SeriesDescription, SET(no2).SeriesDescription);

% Update links etc
SET(newNO).Linked = newNO;
SET(newNO).Children = [];
SET(newNO).Parent = [];
SET(newNO).Flow = [];

% Update GUI
%viewfunctions('setview')

end
