function result = RNG_bipolar(prob, package_size)
%BIPOLAR
s_1s = ((prob*2)+package_size)/2;
s1 = false(1,(package_size)) ;
s1(1:s_1s) = true ;
result = s1(randperm(numel(s1)));
end