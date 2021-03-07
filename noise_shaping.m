function noisy_input = noise_shaping(input, trimmed_size, mean, variance, isIdenticalNoise, mean2, variance2)

if isIdenticalNoise == 1
%size of input data
[in_row, in_column] = size(input);

%create a class 1 and class 2 related input-size data with normal distribution
%random distributed matrix to use it for noise adding
input_sized_normal_random_dist_1 = randn(size(input));

noisy_input = input + sqrt(variance)*input_sized_normal_random_dist_1 + mean;

end

if isIdenticalNoise ~= 1

input_first_class = input(1:trimmed_size, :);
input_second_class = input(trimmed_size+1 : trimmed_size*2, :);

%create a class 1 related input-size data with normal distribution
%random distributed matrix to use it for noise adding
input_sized_normal_random_dist_1_first_class = randn(size(input_first_class));

%create a class 1 related input-size data with normal distribution
%random distributed matrix to use it for noise adding
input_sized_normal_random_dist_1_second_class = randn(size(input_second_class));

noisy_input_first_class = input_first_class + sqrt(variance)*input_sized_normal_random_dist_1_first_class + mean;
noisy_input_second_class = input_second_class + sqrt(variance2)*input_sized_normal_random_dist_1_second_class + mean2;

noisy_input = [noisy_input_first_class; noisy_input_second_class];

end


%PLOTTING, UNCOMMENT FOR SINGLE FUNCTION USAGE ALONE
% figure
% plot(noisy_input(:,1),noisy_input(:,2),'*')
    
end %end of noise shaping function   