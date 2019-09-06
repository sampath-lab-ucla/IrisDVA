function PageActivation(obj,~,~)
obj.setContainerPrefs;
selectedNodes = obj.PreferencesTree.SelectedNodes;
panels = properties(obj);
panels = panels(contains(panels,'Panel'));
if isempty(selectedNodes)
  selectedNodes = struct('Text','');
end
switch selectedNodes.Text
    case 'Keyboard'
        obj.KeyboardPanel.Visible = 'on';
        cellfun( ...
            @(p)set(obj.(p),'Visible','off'), ...
            panels(~contains(panels,'KeyboardPanel')), ...
            'UniformOutput',0 ...
            );
    case 'Control'
        obj.ControlPanel.Visible = 'on';
        cellfun( ...
            @(p)set(obj.(p),'Visible','off'), ...
            panels(~contains(panels,'ControlPanel')), ...
            'UniformOutput',0 ...
            );
    case 'Variables'
        obj.WorkspacePanel.Visible = 'on';
        cellfun( ...
            @(p)set(obj.(p),'Visible','off'), ...
            panels(~contains(panels,'WorkspacePanel')), ...
            'UniformOutput',0 ...
            );
    case 'Filter'
        obj.FilterPanel.Visible = 'on';
        cellfun( ...
            @(p)set(obj.(p),'Visible','off'), ...
            panels(~contains(panels,'FilterPanel')), ...
            'UniformOutput',0 ...
            );
    case 'Statistics'
        obj.StatisticsPanel.Visible = 'on';
        cellfun( ...
            @(p)set(obj.(p),'Visible','off'), ...
            panels(~contains(panels,'StatisticsPanel')), ...
            'UniformOutput',0 ...
            );
    case 'Scaling'
        obj.ScalingPanel.Visible = 'on';
        cellfun( ...
            @(p)set(obj.(p),'Visible','off'), ...
            panels(~contains(panels,'ScalingPanel')), ...
            'UniformOutput',0 ...
            );
    case 'Display'
        obj.DisplayPanel.Visible = 'on';
        cellfun( ...
            @(p)set(obj.(p),'Visible','off'), ...
            panels(~contains(panels,'DisplayPanel')), ...
            'UniformOutput',0 ...
            );
  otherwise
    obj.SelectSubsetPanel.Visible = 'on';
    cellfun(...
      @(p) set(obj.(p),'Visible','off'), ...
      panels(~contains(panels,'SelectSubset')),...
      'UniformOutput',0 ...
      );
    
end
%drawnow();
end