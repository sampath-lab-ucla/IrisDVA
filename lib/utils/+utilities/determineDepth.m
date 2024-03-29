function lvl = determineDepth(s)
% DETERMINEDEPTH Determines nested structure depth with 0 being no nested structs
lvl = 0;
nStructs = length(s);
counts = zeros(nStructs,1);
for i = 1:nStructs
  vals = struct2cell(s(i));
  structLoc = cellfun(@isstruct,vals,'UniformOutput',true);
  if any(structLoc)
    counts(i) = counts(i)+1;% for this level
    depths = cellfun(@utilities.determineDepth, vals(structLoc), 'unif', 1);
    counts(i) = counts(i) + max(depths); % for subsequent levels
  end
end

lvl = lvl + max(counts);


end
