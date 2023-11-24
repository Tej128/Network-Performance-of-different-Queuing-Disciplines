clc
clear
close all

% Define the parameters
num_links = 5; % Number of links
lambda_max = [5, 7, 9, 10, 12]; % Maximum arrival rate for each link
mu = 10; % Service rate for each link
endtime = 100;
tstep = 1;
buffer_capacity = 20;

% Initialize arrays and variables
t = 0;
currcustomers = zeros(1, num_links);
%buffer=0;
event = zeros(3, num_links);
expected_num_packets = zeros(1, num_links);

% Initialize performance metrics arrays
nbrmeasurements = zeros(1, num_links);
nbrdeparted = zeros(1, num_links);
nbrarrived = zeros(1, num_links);
packet_loss = zeros(1, num_links);

% Initialize arrays for arrivals and sojourn times for each link
arrivedtime = cell(1, num_links);
T = cell(1, num_links);

for link = 1:num_links
    arrivedtime{link} = zeros(1, endtime * lambda_max(link));
    T{link} = zeros(1, endtime * lambda_max(link));
end

% Adaptive queuing parameters
utilization_threshold = 0.9;

while t < endtime
    for link = 1:num_links
        % Calculate utilization factor for each link
        utilization_factor = currcustomers(link) * lambda_max(link) / mu;

        % Update arrival rate based on utilization factor
        if utilization_factor > utilization_threshold
            lambda = lambda_max(link) * utilization_threshold;
        else
            lambda = lambda_max(link);
        end

        % Determine which link to use for arrival based on LIFO scheduling
        max_customers = max(currcustomers);
        links_with_max_customers = find(currcustomers == max_customers);

        % If there are multiple links with the same maximum customers, select one randomly
        if numel(links_with_max_customers) > 1
            link = links_with_max_customers(randi([1, numel(links_with_max_customers)]));
        else
            link = links_with_max_customers;
        end

        [t, nextevent] = min(event(:, link));

        if nextevent == 1
            % Handle arrival for the chosen link
            event(1, link) = exprnd(1/lambda) + t;
            %buffer=buffer+1;
            currcustomers(link) = currcustomers(link) + 1;
            nbrarrived(link) = nbrarrived(link) + 1;

            % Calculate and update the expected number of packets in the system
            expected_num_packets(link) = expected_num_packets(link) + currcustomers(link);

            % Check for packet loss
            if currcustomers(link) > buffer_capacity
                packet_loss(link) = packet_loss(link) + 1;
            end

            % Schedule the next service event for this link
            if currcustomers(link) == 1
                event(2, link) = exprnd(1/mu) + t;
            end
            
            % Update the arrival time for this link
            arrivedtime{link}(nbrarrived(link)) = t;
        elseif nextevent == 2
            % Handle departure for the chosen link
            currcustomers(link) = currcustomers(link) - 1;
            %buffer=buffer-1;
            timeinsystem = t - event(1, link);
            nbrdeparted(link) = nbrdeparted(link) + 1;

            % Schedule the next service event for this link if there are still customers
            if currcustomers(link) > 0
                event(2, link) = exprnd(1/mu) + t;
            else
                event(2, link) = inf;
            end
            
            % Update the sojourn time for this link
            T{link}(nbrdeparted(link)) = timeinsystem;
        else
            % Handle measurement event for the chosen link
            nbrmeasurements(link) = nbrmeasurements(link) + 1;
            event(3, link) = event(3, link) + exprnd(tstep);
        end
    end
end

% Calculate packet loss probability and packet delay for each link
packet_loss_probability = packet_loss ./ nbrarrived;
packet_delay = expected_num_packets ./ (lambda_max .* (1 - packet_loss_probability));

% Display the results
for link = 1:num_links
    fprintf('Link %d:\n', link);
    fprintf('Packet Loss Probability: %.4f\n', packet_loss_probability(link));
    fprintf('Packet Delay: %.4f\n', packet_delay(link));
end

% Plot arrivals and sojourn times for each link
legend_labels = cell(1, num_links);
%%
for link = 1:num_links
    subplot(2, num_links, link);
    plot(arrivedtime{link}(1:nbrarrived(link)), 1:nbrarrived(link), 'b');
    title(['Link ' num2str(link) ' Arrivals']);
    xlabel('Time');
    ylabel('Number of Arrivals');

    subplot(2, num_links, link + num_links);
    plot(1:nbrdeparted(link),-T{link}(1:nbrdeparted(link)),  'r');
    title(['Link ' num2str(link) ' Sojourn Time']);
    xlabel('Time');
    ylabel('Sojourn Time');
    legend_labels{link} = ['Link ' num2str(link)];
end

legend(legend_labels);
