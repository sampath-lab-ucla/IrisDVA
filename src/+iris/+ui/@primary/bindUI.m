function bindUI(obj)
  import iris.ui.*;
  import iris.app.*;
  import iris.infra.*;
  %% Menus
  obj.DataMenu.MenuSelectedFcn = ...
  @(s, e)notify(obj, 'LoadData', eventData(s.Tag));

  obj.SessionMenu.MenuSelectedFcn = ...
    @(s, e)notify(obj, 'LoadSession', eventData(s.Tag));

  obj.FromDataMenuD.MenuSelectedFcn = ...
    @(s, e)notify(obj, 'ImportData', eventData(s.Tag));

  obj.FromSessionMenuD.MenuSelectedFcn = ...
    @(s, e)notify(obj, 'ImportSession', eventData(s.Tag));

  obj.SaveMenuD.MenuSelectedFcn = ...
    @(s, e)notify(obj, 'SaveSession');

  obj.QuitMenu.MenuSelectedFcn = ...
    @(s, e)notify(obj, 'Close');

  obj.FileInfoMenuD.MenuSelectedFcn = ...
    @(s, e)notify(obj, 'MenuCalled', eventData('FileInfo'));

  obj.NotesMenuD.MenuSelectedFcn = ...
    @(s, e)notify(obj, 'MenuCalled', eventData('Notes'));

  obj.ProtocolsMenuD.MenuSelectedFcn = ...
    @(s, e)notify(obj, 'MenuCalled', eventData('Protocols'));

  obj.OverviewMenuD.MenuSelectedFcn = ...
    @(s, e)notify(obj, 'MenuCalled', eventData('DataOverview'));

  obj.PreferencesMenu.MenuSelectedFcn = ...
    @(s, e)notify(obj, 'MenuCalled', eventData('Preferences'));

  obj.AnalyzeMenuD.MenuSelectedFcn = ...
    @(s, e)notify(obj, 'MenuCalled', eventData('Analysis'));

  obj.ImportAnalysisMenu.MenuSelectedFcn = ...
    @(s, e)notify(obj, 'ImportAnalysis');

  obj.CreateNewMenu.MenuSelectedFcn = ...
    @(s, e)notify(obj, 'MenuCalled', eventData('NewAnalysis'));

  obj.ExportFigureMenuD.MenuSelectedFcn = ...
    @(s, e)notify(obj, 'ExportDataView');

  obj.SendtoCmdMenuD.MenuSelectedFcn = ...
    @(s, e)notify(obj, 'SendToCmd');

  obj.ModulesRefresh.MenuSelectedFcn = ...
    @(s, e)obj.populateModules();

  obj.AboutMenu.MenuSelectedFcn = ...
    @(s, e)notify(obj, 'MenuCalled', eventData('About'));

  obj.DocumentationMenu.MenuSelectedFcn = ...
    @(s, e)notify(obj, 'MenuCalled', eventData('Help'));

  obj.FixLayoutMenu.MenuSelectedFcn = @obj.resetContainerView;

  obj.SessionConverterMenu.MenuSelectedFcn = ...
    @(s, e)notify(obj, 'SessionConversionCalled');

  obj.InstallHelpersMenu.MenuSelectedFcn = ...
    @(s, e)notify(obj, 'InstallHelpersRequest');

  %% UI ELements

  % Display panel
  obj.DevicesSelection.ValueChangedFcn = @(s, e)notify(obj, 'DeviceViewChanged', eventData(e));

  % Navigation panel
  obj.OverlapTicker.ValueChangedFcn = @(s, e)obj.ValidateTicker(s.Tag, e);

  obj.CurrentDataTicker.ValueChangedFcn = @(s, e)obj.ValidateTicker(s.Tag, e);

  obj.SelectionNavigatorSlider.ValueChangedFcn = @(s, e)obj.ValidateTicker(s.Tag, e);
  obj.SelectionNavigatorSlider.ValueChangingFcn = @obj.SliderChanging;

  obj.CurrentDatumDecSmall.ButtonPushedFcn = @(s, e) ...
    notify(obj, 'NavigateData', ...
    eventData( ...
    struct('Direction', 'Decrement', 'Amount', 'Small', 'Type', 'Data') ...
  ) ...
  );
  obj.CurrentDatumIncSmall.ButtonPushedFcn = @(s, e) ...
    notify(obj, 'NavigateData', ...
    eventData( ...
    struct('Direction', 'Increment', 'Amount', 'Small', 'Type', 'Data') ...
  ) ...
  );
  obj.OverlapInc.ButtonPushedFcn = @(s, e) ...
    notify(obj, 'NavigateData', ...
    eventData( ...
    struct('Direction', 'Increment', 'Amount', 'Small', 'Type', 'Overlay') ...
  ) ...
  );
  obj.OverlapDec.ButtonPushedFcn = @(s, e) ...
    notify(obj, 'NavigateData', ...
    eventData( ...
    struct('Direction', 'Decrement', 'Amount', 'Small', 'Type', 'Overlay') ...
  ) ...
  );
  obj.CurrentDatumIncBig.ButtonPushedFcn = @(s, e) ...
    notify(obj, 'NavigateData', ...
    eventData( ...
    struct('Direction', 'Increment', 'Amount', 'Big', 'Type', 'Data') ...
  ) ...
  );
  obj.CurrentDatumDecBig.ButtonPushedFcn = @(s, e) ...
    notify(obj, 'NavigateData', ...
    eventData( ...
    struct('Direction', 'Decrement', 'Amount', 'Big', 'Type', 'Data') ...
  ) ...
  );

  % Switch panel
  obj.StatsSwitch.ValueChangedFcn = @obj.SwitchFlipped; %@obj.SwitchDisabled;
  obj.ScaleSwitch.ValueChangedFcn = @obj.SwitchFlipped;
  obj.BaselineSwitch.ValueChangedFcn = @obj.SwitchFlipped;
  obj.FilterSwitch.ValueChangedFcn = @obj.SwitchFlipped;
  obj.DatumSwitch.ValueChangedFcn = @obj.SwitchFlipped;

  % Axes object
  obj.addListener(obj.Axes, 'DataSelected', @obj.onAxesDataSelected);
  obj.addListener(obj.Axes, 'PlotUpdated', @obj.onPlotUpdated);

  % Internal listeners
  obj.addListener(obj, 'selection', 'PreSet', @obj.onSelectionWillUpdate);
  obj.addListener(obj, 'selection', 'PostSet', @obj.onSelectionDidUpdate);

end
