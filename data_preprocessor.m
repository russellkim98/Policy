function [auctions] = data_preprocessor()

global data; 
global ad_group_id; 
global column_No; 

auctions = zeros([168 1]); 
for x = 1:168
    everyNthRow = data(97 + x:168:end,:);
    auctions(x) = mean(everyNthRow(:,8)); 
end 




% %Get the height of the array so that we can iterate through them
% global column_No; 
% column_No = size(data,1);
% % Keep track of the number of data points in each ad group
% number_of_data_Points = 0;  
% 
% % Keep track of all the data so it can be simulated
% number_of_auctions = 0; 
% cost_per_click = 0;
% number_of_clicks = 0; 
% value_of_clicks = 0; 
% 
% % Aggregate the sums of all the data points 
% for x = 1:(column_No)
%     if data(x,2) == ad_group_id 
%         number_of_data_Points = number_of_data_Points + 1;
%         number_of_auctions = number_of_auctions + data(x,5);
%         cost_per_click = cost_per_click + data(x, 17);
%         number_of_clicks = number_of_clicks + data(x,7); 
%         value_of_clicks = value_of_clicks + data(x,19);
%     end 
% %     if all(data(x,2) == ad_Number ,data(x,3) == year ,data(x,4) == month ,data(x,5) == day ,data(x,6) == day_of_week ,data(x,7) == hour_of_day)
% %         number_of_data_Points = number_of_data_Points + 1;
% %         number_of_auctions = number_of_auctions + data(x,5);
% %         cost_per_click = cost_per_click + data(x, 17);
% %         number_of_clicks = number_of_clicks + data(x,7); 
% %         value_of_clicks = value_of_clicks + data(x,19);
% %     end 
% end  
% 
% % Calculate the averages of the values 
% avg_num_auctions = number_of_auctions/number_of_data_Points;  
% avg_cpc = cost_per_click/number_of_data_Points;
% avg_num_clicks = number_of_clicks/number_of_data_Points; 
% avg_value_clicks = value_of_clicks/number_of_data_Points; 
% 
% 
% % Simulate the number of auctions 
% sim_Auctions = simAuctions(avg_num_auctions)
% % Simulate the number of impressions
% sim_Impressions = simImpressions(sim_Auctions)
% % Simulate the number of clicks
% sim_Clicks = simClicks(sim_Auctions)
% % Simulate the number of conversions
% sim_Conversions = simConversions(sim_Clicks)
% % Simulate the total cost
% sim_total_Cost = totalCost(avg_num_clicks,avg_cpc)
% % Simulate the total revenue 
% sim_total_Revenue = totalRevenue(avg_value_clicks,avg_num_clicks)