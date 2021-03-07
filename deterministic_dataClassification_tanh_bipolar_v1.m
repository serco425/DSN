%deterministic_dataClassification_tanh_bipolar_v1 (0.01, 10, 10, 20, 3, 1000, -100, 100, 3, 10, 1, 0, 0)
%DURING THE TESTS THE FOLLOWING PARAMETERS CAN BE PASSED (OR THEIR POWERS IN RATIONALS)
%LIKE:
%deterministic_dataClassification_tanh_bipolar_v1 (0.01, 10, 10, 20, 3*(1/2), 1000, -100, 100, 3, 10, 1, 0, 0)

function [input, expected_output, trimmed_size_, epoch_based_accuracy_det] = deterministic_dataClassification_tanh_bipolar_v1 (learning_rate_, learning_iteration_, line_point_1_y_, line_point_2_x_, second_line_scaling, random_number_amount, plotRange_from, plotRange_to, mean, variance, isIdenticalNoise, mean2, variance2, isSingleDataGen, testPassedSingleTimeData, testPassedExpectedOutput, testPassedTrimmedSize)
%*******A first single layer single neuron for DATA CLASSIFICATION ********
%2-input & 1-output
%                 _
%    x1---w1---->| |
%    b----w3---->| |-------->out
%    x2---w2---->| |
%                 -
%            single layer
%
%The code implemented by Sercan AYGÜN (ayguns@itu.edu.tr)
%during the research on ICTEAM, UCLouvain
%--------------tanh as activation function, bipolar encoding scheme,
%This is the deterministic, i.e. conventional neuron model 

%each iteration in the test, no new data will be used, the passed
%parameters will be updated
if isSingleDataGen == 1
    [trimmed_size, upper_x, upper_y, lower_x, lower_y, expected_output, input_first_to_noise] = synthetic_data_GEN(line_point_1_y_, line_point_2_x_, second_line_scaling, random_number_amount, plotRange_from, plotRange_to);
    
    %update them even though they have been created again
    input_first_to_noise = testPassedSingleTimeData;
    expected_output = testPassedExpectedOutput;
    trimmed_size = testPassedTrimmedSize
end

%each iteration in the test, a new data will be created
if isSingleDataGen ~= 1
%First generating synthetic data for 2 classes
%synthetic_data_GEN is the other .m file that creates 2 groups of data with a margin in them
[trimmed_size, upper_x, upper_y, lower_x, lower_y, expected_output, input_first_to_noise] = synthetic_data_GEN(line_point_1_y_, line_point_2_x_, second_line_scaling, random_number_amount, plotRange_from, plotRange_to);
end

input = noise_shaping(input_first_to_noise, trimmed_size, mean, variance, isIdenticalNoise, mean2, variance2);

trimmed_size_ = trimmed_size; %to pass into the stochastic function

%learning rate
learning_rate = learning_rate_;
%learning iterations
learning_iteration = learning_iteration_;
%initial weights
weights = [1;-1;-2];

%for accuracy check
epoch_based_accuracy_counter = 0;

%this is actually the doubled size of trimmed_size for two class
number_of_possible_in = length(input(:,1));

%any empty data structure for the calculated outputs
actual_output = zeros(number_of_possible_in,1);

%Do-it-all in the loop, in an amount of learning iteration
for i = 1:learning_iteration
   for j = 1:number_of_possible_in %possible input trials
      
      % single layer multiply and sum ----> to be STOCHASTIC in
      % stochastic_dataClassification_tanh_bipolar_v1.m file
      % x1*w1 + x2*w2 + bias*w3         
      layer1_temp = input(j,1)*weights(1,1) + input(j,2)*weights(2,1) + 1*weights(3,1);
      actual_output(j) = tanh(layer1_temp);
            
      %Deviation from the expected value
      actual_minus_expected = (expected_output(j)-actual_output(j));

      %updating the weights
                                    %Delta is here:  
      weights(1,1) = weights(1,1) + learning_rate*input(j,1)*actual_minus_expected*(1-((tanh(layer1_temp))*(tanh(layer1_temp))));
      weights(2,1) = weights(2,1) + learning_rate*input(j,2)*actual_minus_expected*(1-((tanh(layer1_temp))*(tanh(layer1_temp))));      
      weights(3,1) = weights(3,1) + learning_rate* 1        *actual_minus_expected*(1-((tanh(layer1_temp))*(tanh(layer1_temp))));
     
      
   end %end of the one epoch
   
   % Test
   for j=1:number_of_possible_in
       accuracy_det(j, i) = sign(tanh(input(j,1)*weights(1,1) + input(j,2)*weights(2,1) + 1*weights(3,1)));
       if accuracy_det(j, i) == expected_output(j)
           epoch_based_accuracy_counter = epoch_based_accuracy_counter + 1;
       end
   end
   
   epoch_based_accuracy_det(i) = epoch_based_accuracy_counter;
   epoch_based_accuracy_counter = 0;
   
   %plot in each epoch
%    figure
%    y = @(x) (-(weights(3,1) / weights(2,1)) / (weights(3,1) / weights(1,1)))*x + (-weights(3,1) / weights(2,1));
%    % y = @(x) (weights(1,1)*x + weights(2,1)*x + weights(3,1));
%    ezplot(y, [-150, 150,-150, 150])
%    title({['Conventional one layer-one neuron linear classifier ' num2str(i) '. epoch result'], ['learning rate=' num2str(learning_rate)]});
%    xlabel('feature_1')
%    ylabel('feature_2')
%     
%    hold on
%    plot(input(1:(trimmed_size),1),input(1:trimmed_size,2),'*')
%    hold on
%    plot(input((trimmed_size)+1:end,1),input((trimmed_size)+1:end,2),'o')
       
end %end of the all epochs

%DECISION BOUNDARY
   
%final discriminator line plot
%COMMENT OUT FOR VISIBLE FIGURE
%figure

% figure('visible','off'); %JUST FOR SAVING IMAGE PURPOSE
% y = @(x) (-(weights(3,1) / weights(2,1)) / (weights(3,1) / weights(1,1)))*x + (-weights(3,1) / weights(2,1));
% % y = @(x) (weights(1,1)*x + weights(2,1)*x + weights(3,1));
% ezplot(y, [-400, 400])
% title('Conventional one layer-one neuron linear classifier');
% xlabel('feature_1')
% ylabel('feature_2')
% 
% hold on
% plot(input(1:(trimmed_size),1),input(1:trimmed_size,2),'*');
% hold on
% plot(input((trimmed_size)+1:end,1),input((trimmed_size)+1:end,2),'o');
% 
% 
% %parametric file naming for each figure
% filename = ['det_epoch_' num2str(learning_iteration) '_eta_' num2str(learning_rate) '.tiff'];
% 
% print(filename,'-dpng','-r0'); %saving, r is for the resolution


end %end of deterministic binary data classifier neuron
