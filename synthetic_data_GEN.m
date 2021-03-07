%Creating handcrafted synthetic data 
function [trimmed_size, upper_x, upper_y, lower_x, lower_y, expected_output, input] = synthetic_data_GEN(line_point_1_y_, line_point_2_x_, second_line_scaling, random_number_amount, plotRange_from, plotRange_to)      

    %FIRST LINE
    %intended 2 points of line
    line_point_1_x = 0;
    line_point_1_y = line_point_1_y_;
    line_point_2_x = line_point_2_x_;
    line_point_2_y = 0;

    %SECOND LINE
    line2_point_1_x = 0;
    line2_point_1_y = line_point_1_y * second_line_scaling * (-1);
    line2_point_2_x = line_point_2_x * second_line_scaling * (-1);
    line2_point_2_y = 0;  
    
    %y = slope*x + line_bias
        
    %calculating the slope
    %there will be 2 parallel lines with same slope
    slope =  (line_point_2_y - line_point_1_y) / (line_point_2_x - line_point_1_x);
      
    %with no noise case margin plot
%     %LINE PLOT FOR MARGIN
%     %line1 equation
%     y = @(x) slope*x + line_point_1_y;
%     %line plot between a range of coordinates
%     ezplot(y, plotRange_from, plotRange_to)
%     hold on
%     %line2 equation
%     y2 = @(x) slope*x + line2_point_1_y;
%     %line plot between a range of coordinates
%     ezplot(y2, plotRange_from, plotRange_to)  
       
    %random numbers in the range of a , b
    a = plotRange_from;
    b = plotRange_to;
    r_x = round((b-a).*rand(random_number_amount,1) + a);
    r_y = round((b-a).*rand(random_number_amount,1) + a);
    
    upper_counter = 1;
    lower_counter = 1;
    %getting some synthetic points as the upper-side of line
    for i=1:random_number_amount
        d1=(r_x(i)-line_point_1_x)*(line_point_2_y-line_point_1_y)-(r_y(i)-line_point_1_y)*(line_point_2_x-line_point_1_x);
        d2=(r_x(i)-line2_point_1_x)*(line2_point_2_y-line2_point_1_y)-(r_y(i)-line2_point_1_y)*(line2_point_2_x-line2_point_1_x);        
        
            if (d2<0 && d1>0)
                upper_side_line_data_x(upper_counter) = r_x(i);
                upper_side_line_data_y(upper_counter) = r_y(i);
                upper_counter = upper_counter+1;
            end

            if (d1<0 && d2>0) 
                 lower_side_line_data_x(lower_counter) = r_x(i);
                 lower_side_line_data_y(lower_counter) = r_y(i);
                 lower_counter = lower_counter+1;
            end
    end
        
    %random numbers obeying the upper-lower half planes must be the same
    %size as trimmed_size
    trimmed_size = 0;
    
    %getting the size of synthetic points
    [m upper_size] = size(upper_side_line_data_x);
    [n lower_size] = size(lower_side_line_data_x);
    
    %trimming the data more crowded than the other into trimmed_size
    if upper_size<=lower_size
        trimmed_size = upper_size;
    end
    if  upper_size>lower_size
        trimmed_size = lower_size;
    end
        
    %for trimmed_size amount of the data, getting the exact coordinates and
    %plotting the data
    for i=1:trimmed_size
        upper_x(i) = upper_side_line_data_x(i);
        upper_y(i) = upper_side_line_data_y(i);
        lower_x(i) = lower_side_line_data_x(i);
        lower_y(i) = lower_side_line_data_y(i);
        
        %plotting points for two data set
        %UNCOMMENT IF either noise_shaping or deterministic_dataClassification_tanh_bipolar_v1
        %has not data plot for noisy data
        %this is for non-noisy data
%         hold on
%         plot(upper_x(i),upper_y(i), 'g*');
%         hold on
%         plot(lower_x(i),lower_y(i), 'b+');
        
        %concetaneting the inputs and preparing the output labels
        input(i,1) = upper_x(i);
        input(i,2) = upper_y(i);
        expected_output_(i) = 1;
    
        input((trimmed_size+i),1) = lower_x(i);    
        input((trimmed_size+i),2) = lower_y(i);
        expected_output_((trimmed_size+i)) = -1;% for tanh act. fcn. case

    end
    
    %to fit into the column
    expected_output = transpose(expected_output_);
    
end