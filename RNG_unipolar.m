function result = RNG_unipolar(prob, package_size)
%UNIPOLAR
s1 = false(1,(package_size)) ;
s1(1:prob) = true ;
result = s1(randperm(numel(s1)));
end