function GFilter = GaussianFilter(s, sigma, y, t)
% Function£ºone dimensional data Guassian filter
%            vthe length of signal (r/2),at start and end part will not be filted
% s     :Filter size, suggest odd number
% sigma :
% y     :the array which need to be filted
% t     :how many time need to filte

% generate 1D GaussFilter
GaussTemp = ones(1,s*2-1);
for i=1 : s*2-1
    GaussTemp(i) = exp(-(i-s)^2/(2*sigma^2))/(sigma*sqrt(2*pi));
end

% Filte
GFilter = y;
for j = 1:t
    for i = s : length(y)-s
        GFilter(i) = y(i-s+1 : i+s-1)*GaussTemp';
    end
    y = GFilter;
end
end

