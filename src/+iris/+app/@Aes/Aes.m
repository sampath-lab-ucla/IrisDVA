classdef Aes < handle
  
  methods (Static)
    
    %% Colors
    function cMat = appColor(n,colorName,form)
      % APPCOLOR A Collection of colors for Iris. For n>1 on single colors returns
      % array of multiple brightnesses for that color. (green,red,zaffre,pistachio).
      % Entering an array for n, e.g. [20,50] will return a 3d rgb matrix of the
      % specified size (first two values of n) and a 4d matrix if length(n) == 3,
      % where the 4th dimension will hold multiple shades of the specified color
      % matrix. For shadidifying a rgb triplet matrix, use Aes.shadifyColors.
      if nargin < 1, n = 1; end
      if nargin < 2, colorName = 'green'; end
      if nargin < 3, form = 'matrix'; end
      
      form = validatestring(form,{'matrix', 'cdata'});
      
      if length(n) < 2 && strcmp(form,'cdata')
        n = num2cell([rep(n,2,1,'dims',{1,2}), 3]);
      elseif strcmp(form,'cdata')
        n = num2cell([n(:)',3]);
      elseif strcmp(form,'matrix')
        n = {n(1),[]};
      end
      validColors = { ...
        'green','red', 'amber', ...
        'zaffre', 'pistachio', ...
        'greys', 'colorful', ...
        'contrast' ...
        };
      colorName = validatestring(colorName, validColors);
      switch colorName
        case 'green'
          col = [202,241,160]./255;
          if strcmp(form,'cdata')
            %make a patch
            cMat = rep(col, ...
              prod([n{~cellfun(@isempty,n(1:2))}]), 1, ...
              'dims', n);
          else
            cMat = iris.app.Aes.shadifyColors(col, n{1});
          end
        case 'red'
          col = [162,20,47]./255;
          if strcmp(form,'cdata')
            %make a patch
            cMat = rep(col, ...
              prod([n{~cellfun(@isempty,n(1:2))}]), 1, ...
              'dims', n);
          else
            cMat = iris.app.Aes.shadifyColors(col, n{1});
          end
        case 'amber'
          col = [255,191,0]./255;
          if strcmp(form,'cdata')
            %make a patch
            cMat = rep(col, ...
              prod([n{~cellfun(@isempty,n(1:2))}]), 1, ...
              'dims', n);
          else
            cMat = iris.app.Aes.shadifyColors(col, n{1});
          end
        case 'greys'
          if strcmp(form,'cdata'), error('Cannot get cData from this color.'); end
          cMat = interp1(1:2,...
            [0.3913,0.3913,0.3913;...
             0.6957,0.6957,0.6957],...
             linspace(1,2,n{1}), 'linear');
        case 'colorful'
          if strcmp(form,'cdata'), error('Cannot get cData from this color.'); end
          cMat = interp1(1:5,    ...
            [156, 47,  56;       ...
             88,  123, 127;      ...
             22,  50,  79;       ...
             211, 97,  53;       ...
             152, 138, 42]./255, ...
             linspace(1,5,n{1}), ...
             'pchip');
           cMat(cMat > 1) = 1; %correct interp
           cMat(cMat < 0) = 0; %correct interp
        case 'zaffre'
          % dark blue
          cMat = rep([0 20 168]./255, ...
            prod([n{~cellfun(@isempty,n(1:2))}]), 1, ...
            'dims', n);
        case 'pistachio'
          % lime green
          cMat = rep([147 197 114]./255, ...
            prod([n{~cellfun(@isempty,n(1:2))}]), 1, ...
            'dims', n);
        case 'contrast'
          cMat = interp1(1:12,    ...
            [21,62,86;       ...
             22,91,119;      ...
             24,119,152;       ...
             26,148,185;       ...
             92,166,146;       ...
             161,183,108;       ...
             234,199,70;       ...
             235,169,59;       ...
             239,138,48;       ...
             241,108,37;       ...
             216,79,36;       ...
             191,50,35       ...
             ]./255, ...
             linspace(1,12,n{1}), ...
             'pchip');
           cMat(cMat > 1) = 1; %correct interp
           cMat(cMat < 0) = 0; %correct interp
      end
    end
    
    function cMat = shadifyColors(rgbMat, nShades)
      % SHADIFYCOLORS Provide a Nx3 rgb triplet array and each color will be
      % shadified by nShades.
      
      if nShades < 2
        cMat = rgbMat;
        return;
      end
      % find a good color separation based on nShades
      dG = linspace(0.001,1,nShades+1)./nShades;
      dG = dG(dG >= 1/(nShades+2));
      dG = dG(1);
      gamma = ((-(nShades+1)/2):((nShades+1)/2)).*dG;
      %will be 2 longer than requested
      gamma([1,end]) = [];
      
      tol = sqrt(eps);
      for i = 1:length(gamma)
        % from matlab's brighten() fcn:
        if gamma(i) > 0
           gamma(i) = 1 - min(1-tol,gamma(i));
        else %<=0
           gamma(i) = 1/(1 + max(-1+tol,gamma(i)));
        end
      end
      nCols = size(rgbMat,1);
      cMat = zeros(nShades,3,nCols);
      for c = 1:nCols
        for n = 1:nShades
          cMat(n,:,c) = rgbMat(c,:).^gamma(n);
        end
      end
    end
    
    %% UIControl aspects
    function fnt = uiFontName()
      fnt = 'Times New Roman';
    end
    
    function fsz = uiFontSize(controlType,varargin)
      if nargin < 1, controlType = 'default'; end
      fsz = 12;
      switch controlType
        case 'label'
          attn = 4;
        case 'shrink'
          attn = -1;
        case 'edit'
          attn = 5;
        case 'custom'
          if isempty(varargin)
            attn = 15; 
          else
            attn = varargin{1};
          end
        otherwise
          attn = 0;
      end
      fsz = fsz + attn;
    end
    
    function props = screenProp(propNames)
      if ischar(propNames)
        propNames = {propNames};
      end
      s0 = get(groot);
      s0fields = fieldnames(s0);
      rmProps = propNames(~contains(s0fields,propNames,'IgnoreCase',1));
      
      props = fastrmField(s0,rmProps);
      
      if length(fieldnames(props)) == 1
        props = props.(propNames{1});
      end
    end
    
    %% Utils
    str = strLib( stringID )
    
  end
  
end

