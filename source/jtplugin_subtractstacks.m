function plugin_subtractstacks
% Subtract two stacks and create a new one with the difference
% written by Johannes Toeger, med lund Nov 2020

global SET

if nargin==0
  myfailed('Expects at least one input argument.');
  return;
end;

sdesc = {};
for sloop = 1:length(SET)
  sdesc{sloop} = sprintf('%i: %s', sloop, SET(sloop).SeriesDescription); %#ok<AGROW>
end

no1 = mymenu('C = A - B, select A', sdesc);
no2 = m                                                                                         ymenu('C = A - B, select B', sdesc);

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

SET(newNO).SeriesDescription = ...
  sprintf('Subtraction: %s - %s', SET(no1).SeriesDescription, SET(no2).SeriesDescription);

% Update links etc
SET(newNO).Linked = newNO;
SET(newNO).Children = [];
SET(newNO).Parent = [];
SET(newNO).Flow = [];

% Update GUI
viewfunctions('setview')

end