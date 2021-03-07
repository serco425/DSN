%function [PERCENTAGE_epoch_based_accuracy_det, PERCENTAGE_epoch_based_accuracy_stoch] = TEST_ALL(eta_, epoch_, pack_)

warning('off','all')
clear all
                                                                                                                                   %(line param1, line param2, second line coeff, from plot, to plot)
[testPassedTrimmedSize, upper_x, upper_y, lower_x, lower_y, testPassedExpectedOutput, testPassedSingleTimeData] = synthetic_data_GEN(-10, 20, 0.1, 1000, -100, 100);
testPassedSingleTimeData_noisy = noise_shaping(testPassedSingleTimeData, testPassedTrimmedSize, 0, 0, 1, 0, 0); % -> parameters ==> (input, trimmed_size, mean, variance, isIdenticalNoise, mean2, variance2)

%plot non-noisy data
figure
plot(testPassedSingleTimeData(1:(testPassedTrimmedSize),1),testPassedSingleTimeData(1:testPassedTrimmedSize,2),'*');
hold on
plot(testPassedSingleTimeData((testPassedTrimmedSize)+1:end,1),testPassedSingleTimeData((testPassedTrimmedSize)+1:end,2),'o');

testPassedSingleTimeData_noisy(:,:) = bsxfun(@plus, testPassedSingleTimeData_noisy(:,:) , 0);

%plot noisy data
figure
plot(testPassedSingleTimeData_noisy(1:(testPassedTrimmedSize),1),testPassedSingleTimeData_noisy(1:testPassedTrimmedSize,2),'*');
hold on
plot(testPassedSingleTimeData_noisy((testPassedTrimmedSize)+1:end,1),testPassedSingleTimeData_noisy((testPassedTrimmedSize)+1:end,2),'o');

%define 3 important parameters will be used in the 
eta_ = 0.1;
epoch_ = 10;
pack = 32;

%All counters initialized
overflow = 0; %overflow counter
indice = 1; %indice counter for plot
test_iteration = 1; %the number of test to be considered

%two for for different eta-epoch pairs like 0.01-1, 0.01-2, 0.01-3, ...
for eta = 0.01:0.01:eta_
    for epoch = 1:1:epoch_
        
        %resetting the temp D:Deterministic, S:Stochastic results
        AD = 0;
        AS = 0;
        
        for i=1:1:test_iteration
            
            try %checking the overflow with try-catch                                                                                                                                           (eta, epoch, package size, second line coeff, from plot, to plot, mean, std. dev., isSingle noise, mean, std. dev., single time data check, testPassedSingleTimeData, testPassedExpectedOutput, testPassedTrimmedSize) 
                [epoch_based_accuracy_det, epoch_based_accuracy_stoch, accuracy_stoch, weights_control_1, weights_control_2, weights_control_3] = stochastic_dataClassification_tanh_bipolar_v1 (eta, epoch, pack, -10, 20, 0.1, 1000, -200, 200, 0, 0, 1, 20, 20, 1, testPassedSingleTimeData_noisy, testPassedExpectedOutput, testPassedTrimmedSize);
                epoch_based_accuracy_det_(1,1:epoch) = epoch_based_accuracy_det(1,1:epoch);
                epoch_based_accuracy_stoch_(1,1:epoch) = epoch_based_accuracy_stoch(1,1:epoch);
            catch
                overflow = overflow + 1;
                continue;
                % Jump to next iteration if overflow occurs
            end
            
            %calculating the percentage
            PERCENTAGE_epoch_based_accuracy_det = (epoch_based_accuracy_det_ * 100)/(2*testPassedTrimmedSize);
            PERCENTAGE_epoch_based_accuracy_stoch = (epoch_based_accuracy_stoch_ * 100)/(2*testPassedTrimmedSize);
            
            AD = AD + PERCENTAGE_epoch_based_accuracy_det;
            AS = AS + PERCENTAGE_epoch_based_accuracy_stoch;
            
            %clearing all in each iteration
            clear epoch_based_accuracy_det_;
            clear epoch_based_accuracy_stoch_;
            clear epoch_based_accuracy_det;
            clear epoch_based_accuracy_stoch;
            clear PERCENTAGE_epoch_based_accuracy_det;
            clear PERCENTAGE_epoch_based_accuracy_stoch;
            
        end % end of iteration
        
        %calculating the average percentage
        AD = AD/test_iteration;
        AS = AS/test_iteration;
        
        %creating a structure to fill the lower-half as triangle
        AD_struct{indice} = AD;
        AS_struct{indice} = AS;
        
        %current eta and epoch into the plot-related parameter 
        %via the indice points the place 
        eta_plot(indice) = eta;
        epoch_plot(indice) = epoch;
        indice = indice + 1; %increment the indice for next position
        
        %in case of anything; AD and AS temporary parameters are cleared :) 
        clear AD;
        clear AS;
        
        
    end % end of epoch
    
end % end of learning rate

%PLOT
% figure
% scatter3(epoch_plot, eta_plot, AS{1},50,'filled')
% view(-30, 30)
% % colorbar
% % cb_title=colorbar;
% % title(cb_title,'Overflow Percentage (%)');
% 
% %title and axis labels
% title('Package Size = 512 bits');
% xlabel('Epoch');
% ylabel('Learning Rate');
% zlabel('Accuracy (%)');

%end

%bar3(AD_struct{2}(:,:))























for epoch_plot = 0:10:90
%PLOT for n=X.XX eta and 1 2 3 4 5 6 7 8 9 10 or 
%10 11 12 13 14 15 16 17 18 19 20
%
%1-5 epoch
figure
%streching as the screen size
set(gcf, 'Position', get(0, 'Screensize'));

subplot(5,2,1)
bar(AD_struct{1+epoch_plot}(:,:), 'm', 'BarWidth',0.1);
% ref.: https://www.mathworks.com/matlabcentral/answers/351875-how-to-plot-numbers-on-top-of-bar-graphs
text(1:length(AD_struct{1+epoch_plot}(:,:)),AD_struct{1+epoch_plot}(:,:),num2str((round(AD_struct{1+epoch_plot}(:,:)*100)/100)'),'vert','bottom','horiz','center'); 
box off

subplot(5,2,2)
bar(AS_struct{1+epoch_plot}(:,:), 'c', 'BarWidth', 0.1);
text(1:length(AS_struct{1+epoch_plot}(:,:)),AS_struct{1+epoch_plot}(:,:),num2str((round(AS_struct{1+epoch_plot}(:,:)*100)/100)'),'vert','bottom','horiz','center'); 
box off

subplot(5,2,3)
bar(AD_struct{2+epoch_plot}(:,:), 'm', 'BarWidth', 0.15);
text(1:length(AD_struct{2+epoch_plot}(:,:)),AD_struct{2+epoch_plot}(:,:),num2str((round(AD_struct{2+epoch_plot}(:,:)*100)/100)'),'vert','bottom','horiz','center'); 
box off

subplot(5,2,4)
bar(AS_struct{2+epoch_plot}(:,:), 'c', 'BarWidth', 0.15);
text(1:length(AS_struct{2+epoch_plot}(:,:)),AS_struct{2+epoch_plot}(:,:),num2str((round(AS_struct{2+epoch_plot}(:,:)*100)/100)'),'vert','bottom','horiz','center'); 
box off

subplot(5,2,5)
bar(AD_struct{3+epoch_plot}(:,:), 'm', 'BarWidth', 0.3);
ylabel('Accuracy (%)')
text(1:length(AD_struct{3+epoch_plot}(:,:)),AD_struct{3+epoch_plot}(:,:),num2str((round(AD_struct{3+epoch_plot}(:,:)*100)/100)'),'vert','bottom','horiz','center'); 
box off

subplot(5,2,6)
bar(AS_struct{3+epoch_plot}(:,:), 'c', 'BarWidth', 0.3);
ylabel('Accuracy (%)')
text(1:length(AS_struct{3+epoch_plot}(:,:)),AS_struct{3+epoch_plot}(:,:),num2str((round(AS_struct{3+epoch_plot}(:,:)*100)/100)'),'vert','bottom','horiz','center'); 
box off

subplot(5,2,7)
bar(AD_struct{4+epoch_plot}(:,:), 'm', 'BarWidth', 0.4);
text(1:length(AD_struct{4+epoch_plot}(:,:)),AD_struct{4+epoch_plot}(:,:),num2str((round(AD_struct{4+epoch_plot}(:,:)*100)/100)'),'vert','bottom','horiz','center'); 
box off

subplot(5,2,8)
bar(AS_struct{4+epoch_plot}(:,:), 'c', 'BarWidth', 0.4);
text(1:length(AS_struct{4+epoch_plot}(:,:)),AS_struct{4+epoch_plot}(:,:),num2str((round(AS_struct{4+epoch_plot}(:,:)*100)/100)'),'vert','bottom','horiz','center'); 
box off

subplot(5,2,9)
bar(AD_struct{5+epoch_plot}(:,:), 'm', 'BarWidth', 0.5);
xlabel('nth epoch in the deterministic computation');
text(1:length(AD_struct{5+epoch_plot}(:,:)),AD_struct{5+epoch_plot}(:,:),num2str((round(AD_struct{5+epoch_plot}(:,:)*100)/100)'),'vert','bottom','horiz','center'); 
box off

subplot(5,2,10)
bar(AS_struct{5+epoch_plot}(:,:), 'c', 'BarWidth', 0.5);
xlabel('nth epoch in the stochastic computation');
text(1:length(AS_struct{5+epoch_plot}(:,:)),AS_struct{5+epoch_plot}(:,:),num2str((round(AS_struct{5+epoch_plot}(:,:)*100)/100)'),'vert','bottom','horiz','center'); 
box off

%parametric file naming for each figure between epoch 1-5
filename = ['10_dataset_test_bar_1_5_' num2str((epoch_plot*0.1)+1) '.tiff'];

figure_1 = gcf;
figure_1.PaperPositionMode = 'auto';
print(filename,'-dpng','-r0');


%6-10 epoch
figure
%streching as the screen size
set(gcf, 'Position', get(0, 'Screensize'));

subplot(5,2,1)
bar(AD_struct{6+epoch_plot}(:,:), 'm', 'BarWidth',0.1);
text(1:length(AD_struct{6+epoch_plot}(:,:)),AD_struct{6+epoch_plot}(:,:),num2str((round(AD_struct{6+epoch_plot}(:,:)*100)/100)'),'vert','bottom','horiz','center'); 
box off

subplot(5,2,2)
bar(AS_struct{6+epoch_plot}(:,:), 'c', 'BarWidth', 0.1);
text(1:length(AS_struct{6+epoch_plot}(:,:)),AS_struct{6+epoch_plot}(:,:),num2str((round(AS_struct{6+epoch_plot}(:,:)*100)/100)'),'vert','bottom','horiz','center'); 
box off

subplot(5,2,3)
bar(AD_struct{7+epoch_plot}(:,:), 'm', 'BarWidth', 0.15);
text(1:length(AD_struct{7+epoch_plot}(:,:)),AD_struct{7+epoch_plot}(:,:),num2str((round(AD_struct{7+epoch_plot}(:,:)*100)/100)'),'vert','bottom','horiz','center'); 
box off

subplot(5,2,4)
bar(AS_struct{7+epoch_plot}(:,:), 'c', 'BarWidth', 0.15);
text(1:length(AS_struct{7+epoch_plot}(:,:)),AS_struct{7+epoch_plot}(:,:),num2str((round(AS_struct{7+epoch_plot}(:,:)*100)/100)'),'vert','bottom','horiz','center'); 
box off

subplot(5,2,5)
bar(AD_struct{8+epoch_plot}(:,:), 'm', 'BarWidth', 0.3);
ylabel('Accuracy (%)')
text(1:length(AD_struct{8+epoch_plot}(:,:)),AD_struct{8+epoch_plot}(:,:),num2str((round(AD_struct{8+epoch_plot}(:,:)*100)/100)'),'vert','bottom','horiz','center'); 
box off

subplot(5,2,6)
bar(AS_struct{8+epoch_plot}(:,:), 'c', 'BarWidth', 0.3);
ylabel('Accuracy (%)')
text(1:length(AS_struct{8+epoch_plot}(:,:)),AS_struct{8+epoch_plot}(:,:),num2str((round(AS_struct{8+epoch_plot}(:,:)*100)/100)'),'vert','bottom','horiz','center'); 
box off

subplot(5,2,7)
bar(AD_struct{9+epoch_plot}(:,:), 'm', 'BarWidth', 0.4);
text(1:length(AD_struct{9+epoch_plot}(:,:)),AD_struct{9+epoch_plot}(:,:),num2str((round(AD_struct{9+epoch_plot}(:,:)*100)/100)'),'vert','bottom','horiz','center'); 
box off


subplot(5,2,8)
bar(AS_struct{9+epoch_plot}(:,:), 'c', 'BarWidth', 0.4);
text(1:length(AS_struct{9+epoch_plot}(:,:)),AS_struct{9+epoch_plot}(:,:),num2str((round(AS_struct{9+epoch_plot}(:,:)*100)/100)'),'vert','bottom','horiz','center'); 
box off

subplot(5,2,9)
bar(AD_struct{10+epoch_plot}(:,:), 'm', 'BarWidth', 0.5);
xlabel('nth epoch in the deterministic computation');
text(1:length(AD_struct{10+epoch_plot}(:,:)),AD_struct{10+epoch_plot}(:,:),num2str((round(AD_struct{10+epoch_plot}(:,:)*100)/100)'),'vert','bottom','horiz','center'); 
box off

subplot(5,2,10)
bar(AS_struct{10+epoch_plot}(:,:), 'c', 'BarWidth', 0.5);
xlabel('nth epoch in the stochastic computation');
text(1:length(AS_struct{10+epoch_plot}(:,:)),AS_struct{10+epoch_plot}(:,:),num2str((round(AS_struct{10+epoch_plot}(:,:)*100)/100)'),'vert','bottom','horiz','center'); 
box off

%parametric file naming for each figure between epoch 6-10
filename = ['10_dataset_test_bar_6_10_' num2str((epoch_plot*0.1)+1) '.tiff'];

figure_2 = gcf;
figure_2.PaperPositionMode = 'auto';
print(filename,'-dpng','-r0');

end