function [mags,freqs] = windowedPSD(Y,fs,windowParams,fftParams)

arguments
  Y (:,1) double
  fs (1,1) double
  windowParams.windowDuration (1,1) double = fix(length(Y)/5)/fs;
  windowParams.windowOverlap (1,1) double  = fix(length(Y)/5)/fs / 3;
  windowParams.windowFx (1,1) string {isValidWindow(windowParams.windowFx)} = "hann"
  fftParams.NFFT = 2^nextpow2(length(Y))
end

if windowParams.windowOverlap >= windowParams.windowDuration
  error("Overlap duration must be shorter than the window duration.");
end

% K = (N-ovl) / (L-ovl)

N = length(Y);
L = fix(windowParams.windowDuration * fs);
overlap = fix(windowParams.windowOverlap * fs);
K = (N-overlap) /  (L-overlap);

if rem(K,floor(K))
  % update the overall length by padding with zeros
  K = floor(K)+1;
  newLength = K*L - K*overlap + overlap;
  nAppend = newLength - N;
  Y(end+(1:nAppend)) = 0;
  N = newLength;
end

columnInds = (0:(K-1))*(L-overlap);
rowInds = (1:L)';


% window
wFx = str2func(windowParams.windowFx);
h = wFx(L);
if ~iscolumn(h)
  h = h(:);
end


% fourier parameters
if ~fftParams.NFFT
  fftParams.NFFT = 2^nextpow2(N);
end

Y = hilbert(Y); %analytical signal.

dT = 1/fs;
nyquistFreq = fs/2;
nFreqs = fix(fftParams.NFFT/2) + 1;
freqs = linspace(0,1,nFreqs)' * nyquistFreq;
factor = dT/L; % for psd

x = ((1:L)' - 1) / fs;

mags = nan(fftParams.NFFT,K);
parfor k = 1:K
  ix = rowInds + columnInds(k);
  sig = Y(ix);
  % remove linear
  cfs = polyfit(x,sig,1);
  sig = sig - polyval(cfs,x);
  sig = sig .* h;
  % center the signal and compute nfft size fourier
  mags(:,k) = factor .* abs(fft(sig-mean(sig),fftParams.NFFT)) .^ 2; %#ok<*PFBNS>
end

% average and correct for windowing
%mags = sum(mags,2)/trapz(freqs([1:end,(end-1):-1:2]),sum(mags,2));
mags = mean(mags,2);
mags = mags(1:nFreqs);
end



function isValidWindow(fxName)

h = str2func(fxName);
try
  out = h(2);
catch me
  error("Window function mast take a scalar length arg.");
end

if numel(out) ~= 2
  error("Window function mast take a scalar length arg.");
end

end