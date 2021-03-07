function [epoch_based_accuracy_det, epoch_based_accuracy_stoch, accuracy_stoch, weights_control_1, weights_control_2, weights_control_3] = stochastic_dataClassification_tanh_bipolar_v1(learning_rate, learning_iteration, package_size, line_point_1_y_, line_point_2_x_, second_line_scaling, random_number_amount, plotRange_from, plotRange_to, mean, variance, isIdenticalNoise, mean2, variance2, isSingleDataGen, testPassedSingleTimeData, testPassedExpectedOutput, testPassedTrimmedSize)
% %*******A first single layer single neuron for DATA CLASSIFICATION ********
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
%in stochastic case, + => 2-to-1 MUX , * => XNOR (for bipolarity)----------

[input, expected_output, trimmed_size, epoch_based_accuracy_det] = deterministic_dataClassification_tanh_bipolar_v1 (learning_rate, learning_iteration, line_point_1_y_, line_point_2_x_, second_line_scaling, random_number_amount, plotRange_from, plotRange_to, mean, variance, isIdenticalNoise, mean2, variance2, isSingleDataGen, testPassedSingleTimeData, testPassedExpectedOutput, testPassedTrimmedSize);

epoch_based_accuracy_counter = 0;

%initial weights
weights = [1;-1;-2];

%this is actually the doubled size of trimmed_size for two class
number_of_possible_in = length(input(:,1));

%selection bits of adder (i.e. mux) with the s=1/2 prob. all the time
input_stream_selection = RNG_unipolar(package_size/2, package_size);

%Do-it-all in the loop, in an amount of learning iteration
for i = 1:learning_iteration
   for j = 1:number_of_possible_in %possible input trials
      
      % single layer multiply and sum ----> is STOCHASTIC
      % x1*w1 + x2*w2 + b*w3         
      % layer1_temp = input(j,1)*weights(1,1) + input(j,2)*weights(2,1) + bias*weights(3,1)
      % bias = 1    
      % ---> was like in conventional code
      
      rng_1 = RNG_bipolar(input(j,1), package_size);
      %sum_rng_1 = sum(rng_1);
      %stn_rng_1 = STN_bipolar(rng_1, package_size);
      
      rng_2 = RNG_bipolar((weights(1,1)), package_size);
      %sum_rng_2 = sum(rng_2);
      %stn_rng_2 = STN_bipolar(rng_2, package_size);
      
      and_1 = ANDing(rng_1, rng_2);
      %sum_and_1 = sum(and_1);    
      %stn_and_1 = STN_bipolar(and_1, package_size);
      
      rng_3 = RNG_bipolar(input(j,2), package_size);
      %sum_rng_3 = sum(rng_3);
      %stn_rng_3 = STN_bipolar(rng_3, package_size);
      
      rng_4 = RNG_bipolar((weights(2,1)), package_size);
      %sum_rng_4 = sum(rng_4);
      %stn_rng_4 = STN_bipolar(rng_4, package_size);
      
      and_2 = ANDing(rng_3, rng_4);
      %sum_and_2 = sum(and_2);  
      %stn_and_2 = STN_bipolar(and_2, package_size);
      
      rng_5 = RNG_bipolar((weights(3,1)), package_size);
      %sum_rng_4 = sum(rng_4);
      %stn_rng_5 = STN_bipolar(rng_5, package_size);
      
      rng_6 = RNG_bipolar(1, package_size);
      %sum_rng_6 = sum(rng_6);
      %stn_rng_6 = STN_bipolar(rng_6, package_size);
      
      and_3 = ANDing(rng_5, rng_6);
      %sum_and_3 = sum(and_3);  
      %stn_and_3 = STN_bipolar(and_3, package_size);
      
      layer1_stream = mux2_to_1_adder(input_stream_selection, and_1, and_2);
      layer1_stream = mux2_to_1_adder(input_stream_selection, layer1_stream, and_3);
      
      layer1_temp = STN_bipolar(layer1_stream, package_size);
      actual_output(j) = tanh(layer1_temp);
      
      %Deviation from the expected value
      actual_minus_expected(j) = (expected_output(j)-actual_output(j));

      %updating the weights
                                    %Delta is here:
      weights(1,1) = weights(1,1) + learning_rate*input(j,1)*actual_minus_expected(j)*(1-((tanh(layer1_temp))*(tanh(layer1_temp))));
      weights(2,1) = weights(2,1) + learning_rate*input(j,2)*actual_minus_expected(j)*(1-((tanh(layer1_temp))*(tanh(layer1_temp))));      
      weights(3,1) = weights(3,1) + learning_rate*      1   *actual_minus_expected(j)*(1-((tanh(layer1_temp))*(tanh(layer1_temp))));           
    
      
      weights_control_1(j, i) = weights(1,1);
      weights_control_2(j, i) = weights(2,1);
      weights_control_3(j, i) = weights(3,1);
      
   
   end %end of the one epoch
   
   % Deterministic test
   for j=1:number_of_possible_in
       accuracy_stoch(j, i) = sign(tanh(input(j,1)*weights(1,1) + input(j,2)*weights(2,1) + 1*weights(3,1)));
       if accuracy_stoch(j, i) == expected_output(j)
           epoch_based_accuracy_counter = epoch_based_accuracy_counter + 1;
       end
   end
   
   epoch_based_accuracy_stoch(i) = epoch_based_accuracy_counter;
   epoch_based_accuracy_counter = 0;
   
   %plot in each epoch
%    figure
%    y = @(x) (-(weights(3,1) / weights(2,1)) / (weights(3,1) / weights(1,1)))*x + (-weights(3,1) / weights(2,1));
%    % y = @(x) (weights(1,1)*x + weights(2,1)*x + weights(3,1));
%    ezplot(y, [-150, 150,-150, 150])
%    title({['Stochastic one layer-one neuron linear classifier ' num2str(i) '. epoch result'], ['learning rate=' num2str(learning_rate)]});
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
%UNCOMMENT ONLY TO SEE THE FINAL EPOCH RESULT; OTHERWISE THE UPPERBLOCK IS
%RECOMMENDED TO SEE EACH EPOCH PERFORMANCE

%COMMENT OUT FOR VISIBLE FIGURE
%figure

% figure('visible','off'); %JUST FOR SAVING IMAGE PURPOSE
% y = @(x) (-(weights(3,1) / weights(2,1)) / (weights(3,1) / weights(1,1)))*x + (-weights(3,1) / weights(2,1));
% % y = @(x) (weights(1,1)*x + weights(2,1)*x + weights(3,1));
% ezplot(y, [-400, 400])
% title('Stochastic one layer-one neuron linear classifier');
% xlabel('feature_1')
% ylabel('feature_2')
% 
% hold on
% plot(input(1:(trimmed_size),1),input(1:trimmed_size,2),'*');
% hold on
% plot(input((trimmed_size)+1:end,1),input((trimmed_size)+1:end,2),'o');
% 
% %parametric file naming for each figure
% filename = ['stoch_epoch_' num2str(learning_iteration) '_eta_' num2str(learning_rate) '.tiff'];
% 
% print(filename,'-dpng','-r0'); %saving, r is for the resolution
% 
% 





% 
% 
% 
% 
% figure('visible','off'); %JUST FOR SAVING IMAGE PURPOSE
% y = @(x) (-(weights(1,1) / weights(2,1)))*x + (-weights(3,1) / weights(2,1));
% % y = @(x) (weights(1,1)*x + weights(2,1)*x + weights(3,1));
% ezplot(y, [-400, 400])
% title('Stochastic one layer-one neuron linear classifier');
% xlabel('feature_1')
% ylabel('feature_2')
% 
% hold on
% plot(input(1:(trimmed_size),1),input(1:trimmed_size,2),'*');
% hold on
% plot(input((trimmed_size)+1:end,1),input((trimmed_size)+1:end,2),'o');
% 
% %parametric file naming for each figure
% filename = ['stoch_epoch_' num2str(learning_iteration) '_eta_' num2str(learning_rate) '.tiff'];
% 
% print(filename,'-dpng','-r0'); %saving, r is for the resolution
% 
% 






















end %end of deterministic binary data classifier neuron

%0.006, 10, 1024, -10, 20, 5, 1000, -100, 100, 0, 0, 1, 1, 1