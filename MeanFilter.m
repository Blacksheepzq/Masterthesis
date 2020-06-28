function Mean = MeanFilter(s, y, t)
% Function£ºone dimensional data middile value filter
%            vthe length of signal (r/2),at start and end part will not be filted
% s     :Filter size, suggest odd number
% sigma :
% y     :the array which need to be filted
% t     :how many time need to filte
mean = ones(1,s)./s;
backup = y;
fLen = fix(s/2);
for i = 1:t
    Mean = conv(y,mean,'valid');
    y = [backup(1:fLen),Mean,backup(end - fLen + 1:end)];
end
Mean = y;
end

