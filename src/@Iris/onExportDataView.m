function onExportDataView(app, ~, ~)

doSave = iris.ui.questionBox( ...
  'Prompt', 'Export data from the current view or entire session?', ...
  'Title', 'Export Data', ...
  'Options', {'Current','Session','Cancel'}, ...
  'Default', 'Cancel' ...
  );

switch doSave.response
  case 'Current'
    iData = app.handler.exportCurrent();
  case 'Session'
    iData = app.handler.export();
  otherwise
    fprintf('Data not exported!\n');
    return;
end

% create a generic save name with filter
fn = fullfile( ...
  app.options.LastSavedDirectory, ...
  [datestr(app.sessionInfo.sessionStart,'YYYY-mmm-DD'),'.idata'] ...
  );

% prompt user for final save location
userFile = iris.app.Info.putFile( ...
  'Save IrisData File', ...
  {'*.idata','IrisData File'}, ...
  fn ...
  );

if isempty(userFile)
  app.ui.focus();
  return;
end

% set the desired file name into the iData object
iData = iData.UpdateFileList(userFile);

% update the progress dialog
app.loadShow.updatePercent('Saving Session...');

try
  save(userFile,'iData','-mat','-v7.3');
catch e
  app.loadShow.updatePercent('Error!');
  pause(1.5);
  app.loadShow.shutdown();
  app.ui.focus();
  iris.app.Info.throwError(e.message);
  
end
app.loadShow.updatePercent('Saved!');
pause(1.5);
fprintf('IrisData saved to:\n"%s"\n',userFile);
fprintf('To load the data use:\n    load("%s",''-mat'');\n',userFile);

fprintf('Be sure to add the location for the IrisData class definition to your path.\n');
fprintf('It is currently located at:\n  "%s"\n', ...
  fullfile(iris.app.Info.getAppPath(), 'lib', 'IrisData.m') ...
  );

app.ui.focus();
app.loadShow.shutdown();
app.options.LastSavedDirectory = fileparts(userFile);

return %explicit?
end

