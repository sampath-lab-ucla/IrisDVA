classdef validFiles < iris.infra.StoredPrefs
  
  properties
    Supported
  end
  
  methods
    
    % Supported
    function s = get.Supported(obj)
      % force Iris to always support symphony and iris sessions
      supMap = containers.Map();
      supMap('symphony') = struct( ...
        'label', 'Symphony Data File', ...
        'exts', {{'h5'}}, ...
        'reader', 'readSymphonyFile' ...
        );
      supMap('session') = struct( ...
        'label', 'Iris Session File', ...
        'exts', {{'isf'}}, ...
        'reader', 'sessionReader' ...
        );
      s = obj.get('Supported', supMap);
    end
    
    function set.Supported(obj,s)
      if ~isstruct(s), error('Supported must be a struct'); end
      fn = fieldnames(s);
      if ~all(ismember(fn,{'name','label','exts','reader'}))
        error('Supported must have fields: "name", "label", "exts", "reader".');
      end
      
      % force Iris to always support symphony and iris sessions
      supMap = containers.Map();
      supMap('symphony') = struct( ...
        'label', 'Symphony Data File', ...
        'exts', {{'h5'}}, ...
        'reader', 'readSymphonyFile' ...
        );
      supMap('session') = struct( ...
        'label', 'Iris Session File', ...
        'exts', {{'isf'}}, ...
        'reader', 'sessionReader' ...
        );
      dropFields = fn(~ismember(fn,{'label','exts','reader'}));
      % loop if struct is array
      for I = 1:numel(s)
        supMap(s(I).name) = fastrmField(s(I),dropFields);
      end
      % store
      obj.put('Supported', supMap);
    end
        
  end
  
  methods (Static)
    
    function d = getDefault()
      persistent default;
      if isempty(default) || ~isvalid(default)
        default = iris.pref.validFiles();
      end
      d = default;
    end
    
  end
  
end