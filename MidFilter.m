function Mid = MidFilter(s, y, t)
% Function£ºone dimensional data middile value filter
%            vthe length of signal (r/2),at start and end part will not be filted
% s     :Filter size, suggest odd number
% sigma :
% y     :the array which need to be filted
% t     :how many time need to filte
a = y;
for i = 1:t
    Mid = medfilt1(a,s);
    a = Mid;
end

end