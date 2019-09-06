classdef dataOverview < iris.ui.UIContainer
  %DATAOVERVIEW Manage currently open data.
  % Properties that correspond to app components
  properties (Access = public)
    FileTree            matlab.ui.container.Tree
    FileNodes
    PropNodes
    PropTable           matlab.ui.control.Table
    SelectSubsetPanel   matlab.ui.container.Panel
    SelectSubsetLabel   matlab.ui.control.Label
    DatumList           matlab.ui.control.ListBox
    Actions             matlab.ui.control.DropDown
    Apply               matlab.ui.control.Button
    Handler
  end
  
  properties (Hidden)
    InclusionIcon = fullfile(iris.app.Info.getResourcePath,'icn','Epoch_Iconincl.png')
    ExclusionIcon = fullfile(iris.app.Info.getResourcePath,'icn','Epoch_Iconexcl.png')
    handlerListeners = {}
  end
    
  
  %% Public methods
  methods
    
    function buildUI(obj,handler)
      if nargin < 2
        handler = obj.Handler;
      end
      if obj.isClosed
        obj.rebuild();
      end
      % determine if we are simply unhiding the window or need to reconstruct it
      newHandler = ~isequal(handler,obj.Handler);
      obj.show();
      if obj.isBound && ~newHandler
        return
      end      
      % if a new handler was provided we need to destroy previous handler listeners
      % and then reassign our handler handle
      
      if newHandler
        obj.destroyListeners();
        obj.Handler = handler;
      end
      
      obj.clearView();
      
      obj.FileNodes = cell(handler.nFiles,1);
      obj.PropNodes = {};
      obj.SelectSubsetLabel.Text = ...
        { ...
          'Loading...'; ...
          'Selected epochs will show when completed.' ...
        };
      
      obj.recurseNodes();
      
      obj.SelectSubsetLabel.Text = 'Select File Subset';
      
      % set selected from handler
      obj.setSelectionFromHandler();
      
      if newHandler
        % set and enable listener
        obj.handlerListeners{end+1} = addlistener( ...
          handler, ...
          'onSelectionUpdated', @(s,e)obj.onHandlerUpdate(e) ...
          );
        obj.handlerListeners{end+1} = addlistener( ...
          handler, ...
          'onCompletedLoad', @(s,e)obj.onHandlerUpdate(e) ...
          );
      end
      if ~event.hasListener(obj,'Close')
        addlistener(obj, 'Close', @(s,e)obj.selfDestruct());
      end
      obj.isBound = true;
    end
    
    function recurseNodes(obj)
      hd = obj.Handler;
      % Create parent Node for each file
      for p = 1:hd.nFiles
        mbr = hd.membership{p};
        dataInds = mbr.data;
        inclStatus = hd.Tracker.getStatus.inclusions(dataInds);
        d = hd(dataInds);
        [~,fn,ex] = fileparts(hd.fileList{p});
        thisNode = uitreenode(obj.FileTree, ...
          'Text', [fn,ex] );
        thisNode.Icon = fullfile( ...
          iris.app.Info.getResourcePath,...
          'icn', ...
          'File_Icon.png' ...
          );
        
        %obj.drawnow();
        
        thisNode.NodeData = [];
        % create childNode for each datum
        for i = 1:length(d)
          thisChildNode = uitreenode(thisNode, ...
            'Text', d(i).id );
          thisChildNode.NodeData = d(i).getPropsAsCell;
          if inclStatus(i)
            icn = obj.InclusionIcon;
          else
            icn = obj.ExclusionIcon;
          end
          thisChildNode.Icon = icn;
          if i == 1
            thisNode.expand;
          end
          
          %TODO: recurse structs in d.<type>Configurations
          
          %drawnow('limitrate');
          
          obj.PropNodes{end+1} = thisChildNode;
        end
        
        obj.FileNodes{p} = thisNode;
      end
    end
    
    function selfDestruct(obj)
      % required for integration with menuservices
      % detect handler condition and the
      %delete(obj.selectionListener);
      if obj.Handler.isready
        % just hide rather than kill
        obj.update();
        obj.hide();
      else
        obj.clearView();
        obj.destroyListeners();
        obj.shutdown();
      end
    end
    
  end
  %% Startup Methods
  methods (Access = protected)
    
    % Startup
    function startupFcn(obj,handler)
      obj.container.SizeChangedFcn = @obj.containerResized;
      if nargin < 2, return; end
      obj.buildUI(handler);
    end    
    
    %handler selection was updated
    function onHandlerUpdate(obj,event)
      % if the window is open, we need to update the view. Otherwise we will let the
      % buildUI() method handle the update.
      if ~obj.isVisible, return; end
      
      if endsWith(event.EventName,'Updated')
        % selection update triggered
        obj.setSelectionFromHandler();
      elseif endsWith(event.EventName,'Load')
        % new files were loaded, rebuild the ui
        obj.isBound = false;
        obj.buildUI();
      else
        % future.
      end
    end
    
    % Set Table Data
    function setData(obj,d)
      % flatten table to unique first column
      keyNames = unique(d(:,1),'stable');
      keyData = cellfun( ...
        @(x)d(ismember(d(:,1),x),2), ...
        keyNames, ...
        'UniformOutput', false ...
        );
      if length(keyNames) == size(d,1)
        tableDat = d;
      else
        tableDat = [ ...
          keyNames(:), ...
          keyData(:) ...
          ];
      end
      % set all values column to strings
      tableDat(:,2) = arrayfun(@unknownCell2Str,tableDat(:,2),'unif',0);
      %set
      obj.PropTable.Data = tableDat;
      lens = cellfun(@length,tableDat(:,2),'UniformOutput',true);
      obj.PropTable.ColumnWidth = {120, max(lens)*6.55};
    end
    
     % Construct view
    function createUI(obj)
      import iris.app.*;
      
      pos = obj.position;
      if isempty(pos)
        initW = 816;
        initH = 366;
        pos = centerFigPos(initW,initH);
      end
      obj.position = pos; %sets container too
      
      % Create container
      obj.container.Name = 'Data Overview';
      obj.container.Resize = 'on';
      

      % Create FileTree
      obj.FileTree = uitree(obj.container);
      obj.FileTree.FontName = 'Times New Roman';
      obj.FileTree.FontSize = 16;
      obj.FileTree.Position = [15 52 230 304];
      obj.FileTree.Multiselect = 'on';
      obj.FileTree.SelectionChangedFcn = @obj.nodeChanged;

      % Create PropTable
      obj.PropTable = uitable(obj.container);
      obj.PropTable.ColumnName = {'Property '; 'Value'};
      obj.PropTable.ColumnWidth = {125, 'auto'};
      obj.PropTable.RowName = {};
      obj.PropTable.FontName = 'Times New Roman';
      obj.PropTable.Position = [255 15 546 341];
      obj.PropTable.Visible = 'off';
      
      % Create SelectSubsetPanel
      obj.SelectSubsetPanel = uipanel(obj.container);
      obj.SelectSubsetPanel.AutoResizeChildren = 'off';
      obj.SelectSubsetPanel.BackgroundColor = [1 1 1];
      obj.SelectSubsetPanel.FontName = iris.app.Aes.uiFontName;
      obj.SelectSubsetPanel.Position = [255 15 546 341];

      % Create SelectSubsetLabel
      obj.SelectSubsetLabel = uilabel(obj.SelectSubsetPanel);
      obj.SelectSubsetLabel.HorizontalAlignment = 'center';
      obj.SelectSubsetLabel.FontName = iris.app.Aes.uiFontName;
      obj.SelectSubsetLabel.FontSize = 20;
      obj.SelectSubsetLabel.Position = [ ...
        546/2 - 546*0.8/2, ...
        341/2 - 341*0.9/2, ...
        546*0.8, ...
        341*0.9 ...
        ];
      %(546-174)/2 158 174 25];
      obj.SelectSubsetLabel.Text = 'Select File Subset';

      % Create Actions
      obj.Actions = uidropdown(obj.container);
      obj.Actions.Items = {'Actions', 'Exclude Selected', 'Include Selected', 'Delete Selected', 'Delete Unselected', 'Export Selected'};
      obj.Actions.FontName = 'Times New Roman';
      obj.Actions.FontSize = 14;
      obj.Actions.Position = [15 15 156 22];
      obj.Actions.Value = 'Actions';
      obj.Actions.ValueChangedFcn = @obj.SelectActions;

      % Create Apply
      obj.Apply = uibutton(obj.container, 'push');
      obj.Apply.FontName = 'Times New Roman';
      obj.Apply.Position = [182 15 63 23];
      obj.Apply.Text = 'Apply';
      obj.Apply.Enable = 'off';
      obj.Apply.ButtonPushedFcn = @obj.ApplyAction;
    end
    
  end
  
  %% Callback
  methods (Access = private)
    % Selected Action changed
    function SelectActions(obj,~,evt)
      if strcmp(evt.Value, 'Actions')
        obj.Apply.Enable = 'off';
      else
        obj.Apply.Enable = 'on';
      end
    end
    % set Selection based on handler.currentSelection
    function setSelectionFromHandler(obj)
      obj.FileTree.SelectedNodes = [obj.PropNodes{obj.Handler.currentSelection.selected}];
      obj.getSelectedInfo();
      obj.PropTable.Visible = 'on';
      obj.SelectSubsetPanel.Visible = 'off';
    end
    % Apply action button pressed
    function ApplyAction(obj,~,~)
      try
        [~,inds] = obj.getSelectedInfo();
      catch x
        %log
        warndlg('Cannot process this selection.','Processing Failure');
        return;
      end
      switch obj.Actions.Value
        case 'Exclude Selected'
          arrayfun( ...
            @(n)set(n,'Icon',obj.ExclusionIcon), ...
            obj.FileTree.SelectedNodes, ...
            'unif', 0 ...
            );
          obj.Handler.setInclusion(inds,false);
        case 'Include Selected'
          arrayfun( ...
            @(n)set(n,'Icon',obj.InclusionIcon), ...
            obj.FileTree.SelectedNodes, ...
            'unif', 0 ...
            );
          obj.Handler.setInclusion(inds,true);
        case {'Delete Selected','Delete Unselected'}
          deleteType = subsref( ...
            strsplit(obj.Actions.Value,' '), ...\
            struct('type', '{}', 'subs', {{2}}) ...
            );
          if strcmp(deleteType,'Selected')
            keepInds = ~ismember(1:length(obj.PropNodes),inds);
          else
            keepInds = ismember(1:length(obj.PropNodes),inds);
          end
          obj.Handler.subset(find(keepInds));%#ok
          obj.buildUI;
          obj.FileTree.SelectedNodes = obj.PropNodes{1};
          obj.getSelectedInfo();
        case 'Export Selected'
          warndlg('Functionality coming soon.', 'Future feature');
        otherwise
          return
      end
    end
    % Selection Node changed.
    function nodeChanged(obj,~,evt)
      if ~isempty(evt.SelectedNodes)
        selectedNames = {evt.SelectedNodes.Text};
        if any( ...
            ismember( ...
              selectedNames, ...
              cellfun(@(x)x.Text,obj.FileNodes,'unif',0) ...
            ) ...
            )
          obj.togglePropTable('off');
          return
        end
        obj.getSelectedInfo();
        obj.togglePropTable('on');
      else
        obj.togglePropTable('off');
      end
    end
    
    % get the info from the selected ID
    function [infos,selectedIndex] = getSelectedInfo(obj)
      % sort by Node Text?
      sNodes = obj.FileTree.SelectedNodes;
      if isempty(sNodes)
        error('No nodes selected');
      end
      nodeNames = arrayfun(@(x)x.Text,sNodes,'UniformOutput',false);
      [~,sortInd] = sort(nodeNames);
      
      infos = arrayfun( ...
        @(x)x.NodeData, ...
        obj.FileTree.SelectedNodes(sortInd), ....
        'UniformOutput', false ...
        );
      selectedIndex = cellfun( ...
        @(v) str2double(v{ismember(v(:,1),'index'),2}), ...
        infos, ...
        'UniformOutput', true ...
        );
      
      if ~nargout
        if ~isequal(obj.Handler.currentSelection.selected, selectedIndex)
          obj.Handler.currentSelection = selectedIndex;
        end
        obj.setData(cat(1,infos{:}));
        pause(0.01);
        %drawnow('limitrate');
      end
    end
    
    function togglePropTable(obj,newStatus)
      if nargin < 2
        if strcmp(obj.PropTable.Visible, 'on')
          newStatus = 'off';
        else
          newStatus = 'on';
        end
      end
      obj.PropTable.Visible = newStatus;
      if strcmp(newStatus,'on')
        obj.SelectSubsetPanel.Visible = 'off';
      else
        obj.SelectSubsetPanel.Visible = 'on';
      end
    end
    
    function containerResized(obj,src,~)
      
      obj.position = src.Position;%set ui
      
      obj.FileTree.Position(4) = obj.position(4) - 62;
      pW = obj.position(3) - 265;
      pH = obj.position(4) - 25;
      obj.PropTable.Position(3:4) = [pW,pH];
      obj.SelectSubsetPanel.Position(3:4) = [pW,pH];
      obj.SelectSubsetLabel.Position = [...
        0.2*pW/2, ...
        0.1*pH/2, ...
        pW*0.8, ...
        pH*0.9 ...
        ];
      
    end
    
    function clearView(obj)
      obj.togglePropTable('off');
      obj.isBound = false;
      if isempty(obj.PropNodes), return; end
      cellfun(@delete,obj.PropNodes,'UniformOutput',false);
      cellfun(@delete,obj.FileNodes,'UniformOutput',false);
    end
    
    function destroyListeners(obj)
      for i = 1:length(obj.handlerListeners)
        delete(obj.handlerListeners{i});
      end
      obj.handlerListeners = {};
    end
    
  end
  %% Preferences
  methods (Access = protected)

    function setContainerPrefs(obj)
      setContainerPrefs@iris.ui.UIContainer(obj);
    end
    
    function getContainerPrefs(obj)
      getContainerPrefs@iris.ui.UIContainer(obj);
    end
    
  end
end