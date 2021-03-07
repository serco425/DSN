function [result] = XNORing(x1, x2) % bitwise XNOR

result = xor(x1,x2);
result = ~result;

% package_size = size(x1);
% for i=1:package_size
%     result(i) = x1(i) & x2(i);
% end

end

