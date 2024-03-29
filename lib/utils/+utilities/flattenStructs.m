function flat = flattenStructs(S,opts)
  % FLATTENSTRUCT Flattens a struct array.
  arguments (Repeating)
    S struct
  end
  arguments
    opts.stringify (1,1) logical = false
    opts.uniquify (1,1) logical = false
  end

  
  %extract structs
%   structInds = cellfun(@isstruct,varargin,'unif',1);
% 
%   S = varargin(structInds);
%   varargin(structInds) = [];
% 
%   p = inputParser();
%   p.StructExpand = false;
%   p.KeepUnmatched = true;
% 
%   p.addParameter('stringify', false, @islogical);
%   p.parse(varargin{:});


  [fields,values] = deal(cell(length(S),1));
  for i = 1:length(S)
    fields{i} = fieldnames(S{i});
    values{i} = squeeze(struct2cell(S{i}));
  end
  fields = cat(1,fields{:});
  values = cat(1,values{:});

  flatCell = utilities.collapseUnique([fields,values],1,opts.stringify,opts.uniquify);

  flatCell(:,1) = matlab.lang.makeValidName(flatCell(:,1));

  flat = struct();
  for n = 1:size(flatCell,1)
    flat.(flatCell{n,1}) = flatCell{n,2};
  end
end
