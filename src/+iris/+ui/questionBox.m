classdef questionBox < iris.ui.JContainer
  
  properties
    response    
    title
    buttonOptions
    question
    default
  end
  
  properties (Hidden = true, Access = protected)
    prompt
    buttons
  end
  
  methods (Access = protected)
    
    function startupFcn(obj,varargin)
      
      addlistener(obj,'Close', @obj.onCloseRequest);
      
      obj.show();
      
      defaultMember = ismember( ...
        cellfun(@(x)x.String, ...
          obj.buttons, ...
          'UniformOutput',0 ...
        ), ...
        obj.default ...
        );
      pause(0.01);
      uicontrol(obj.buttons{defaultMember});
      
      obj.wait();
    end
    
    function createUI(obj,varargin)
      import iris.app.Info;
      import iris.infra.*;
      
      ip = inputParser;
      ip.addParameter('Title', 'Question Box', @ischar);
      ip.addParameter('Options', {'Yes', 'No'}, ...
        @(x)validateattributes(x, ...
          {'cell','char'}, ...
          {'nonempty'} ...
          ) ...
        );
      ip.addParameter('Prompt', 'Question box prompt.', ...
        @(x)validateattributes(x, ...
          {'char', 'cell'}, ...
          {'nonempty'} ...
          ) ...
        );
      ip.addParameter('Default', '', @ischar);
      
      ip.parse(varargin{:});
      
      opts = unique(ip.Results.Options,'stable');
      nButtons = length(opts);
      %{
      if (nButtons < 2) || (nButtons > 5)
        error('Prompt must have between 2 and 5 buttons.');
      end
      %}
      obj.response = ip.Results.Default;
      
      [spaces,tmp] = deal(regexp(ip.Results.Prompt, '\s'));
      promptLength = length(ip.Results.Prompt);
      
      splits = [];
      
      while any(spaces <= 42 & spaces >= 30)
        splitIndex = find(spaces <= 42 & spaces > 0, 1, 'last'); 
        splits(end+1) = tmp(splitIndex); %#ok<AGROW>
        spaces = spaces - splits(end);
      end
      
      nLines = length(splits)+1;           
      startInds = [0,splits,promptLength];
      difInds = diff(startInds);
      nChars = max(difInds);
      
      if mod(nChars,2)
        %make odd length
        nChars = nChars+1;
      end
      
      splitText = cell(1,nLines);
      for c = 1:nLines
        splitText{c} = regexprep( ...
          ip.Results.Prompt((startInds(c)+1):startInds(c+1)), ...
          '^\s* | \s*$', ...
          '' ...
          );
      end
      
      
      formattedPrompt = pad(splitText,nChars,'both');
      % window init size
      w = 265;
      h = 115;
      
      % alter height:
      promptHeight = 15*nLines;
      promptY = max([2*h/3-7-7*(nLines-1), 2*h/3-15]);
      
      if nLines > 2
        h = h+(nLines-2)*15;
      end
      
      % calculate buttons
      
      if w < (nButtons*73+30)
        w = nButtons*73+30+2;
      end
      
      
      obj.buttons = cell(nButtons,1);
      buttonBounds = (0:nButtons).* (w-30)/nButtons + 15;
      buttonSpace = min(diff(buttonBounds));
      buttonCenters = diff(buttonBounds)./2 + buttonBounds(1:end-1);
      buttonWidth = 0.9*buttonSpace;
      buttonStarts = buttonCenters - buttonWidth/2;
      
      
      % always init with the same size
      
      pos = utilities.centerFigPos(w,h);
      obj.position = pos;
      
      set(obj.container, ...
        'Name', ip.Results.Title, ...
        'Units', 'pixels', ...
        'resize', 'off' ...
        );
      
      obj.prompt = uicontrol(obj.container, ...
        'Style', 'text', ...
        'Units', 'pixels', ...
        'Position', [15,promptY,(w-30),promptHeight], ...
        'String', formattedPrompt,  ...
        'FontSize', 10, ...
        'BackgroundColor', [1 1 1] ...
        );
      
      
      for b = 1:nButtons
        button = uicontrol(obj.container, ...
          'Style', 'pushbutton', ...
          'Units', 'pixels', ...
          'Position', [buttonStarts(b), 15, buttonWidth, 20], ...
          'String', opts{b}, ...
          'Callback', ...
          @(s,e)obj.onSelectedOption(s,eventData(opts{b})) ...
          );
        obj.buttons{b} = button;
      end
      
      obj.title = ip.Results.Title;
      obj.buttonOptions = opts;
      obj.question = ip.Results.Prompt;
      obj.default = ip.Results.Default;
    end
    
    function onSelectedOption(obj,~,evt)
      obj.response = evt.Data;
      obj.onCloseRequest([],[]);
    end
    
    function onCloseRequest(obj,~,~)
      if isempty(obj.response)
        obj.response = false;
      end
      obj.setWindowStyle('normal');
      obj.reset;
      obj.shutdown;
    end
    
  end
  methods
    
    function selfDestruct(obj)
      % required for integration with menuservices
      obj.onCloseRequest([],[]);
    end
  
  end
end