clc
clear all
close all

% Define the parameters
num_links = 5; % Number of links
lambda_max = [5, 7, 9, 10, 12]; % Maximum arrival rate for each link
mu = 10; % Service rate for each link
endtime = 100;
tstep = 1;
buffer_capacity = 20;
utilization_threshold = 0.9; % Utilization threshold for adaptation

% Initialize arrays and variables
t = 0;
currcustomers = zeros(1, num_links);
event = zeros(3, num_links);
packet_loss = zeros(1, num_links);
expected_num_packets = zeros(1, num_links);

% Initialize performance metrics arrays
nbrmeasurements = zeros(1, num_links);
nbrdeparted = zeros(1, num_links);
nbrarrived = zeros(1, num_links);

% Initialize arrays for arrivals and sojourn times for each link
arrivedtime = cell(1, num_links);
T = cell(1, num_links);



for link = 1:num_links
    arrivedtime{link} = zeros(1, endtime * lambda_max(link));
    T{link} = zeros(1, endtime * lambda_max(link));
end

while t < endtime
    for link = 1:num_links
        % Calculate utilization factor for each link
        utilization_factor = lambda_max(link) / mu;

        % Update arrival rate based on utilization factor
        if utilization_factor > utilization_threshold
            lambda(link) = lambda_max(link) * utilization_threshold;
        else
            lambda(link) = lambda_max(link);
        end

        % Determine which link to use for arrival based on the shortest queue
        [~, current_link] = min(currcustomers);

        if link == current_link
            [t, nextevent] = min(event(:, link));

            if nextevent == 1
                % Handle arrival for the chosen link
                event(1, link) = exprnd(1/lambda(link)) + t;
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

for link = 1:num_links
    subplot(2, num_links, link);
    plot(arrivedtime{link}(1:nbrarrived(link)), 1:nbrarrived(link), 'b');
    title(['Link ' num2str(link) ' Arrivals']);
    xlabel('Time');
    ylabel('Number of Arrivals');

    subplot(2, num_links, link + num_links);
    plot(T{link}(1:nbrdeparted(link)), 1:nbrdeparted(link), 'r');
    title(['Link ' num2str(link) ' Sojourn Time']);
    xlabel('Time');
    ylabel('Sojourn Time');
    legend_labels{link} = ['Link ' num2str(link)];
end

legend(legend_labels);
%%
clc
clear all
close all

% Define the parameters
num_links = 5; % Number of links
lambda_max = [5, 7, 9, 10, 12]; % Maximum arrival rate for each link
mu = 10; % Service rate for each link
endtime = 100;
tstep = 1;
buffer_capacity = 100;
utilization_threshold = 0.9; % Utilization threshold for adaptation

% Initialize arrays and variables
t = 0;
currcustomers = zeros(1, num_links);
buffer=0;
event = zeros(3, num_links);
packet_loss = zeros(1, num_links);
expected_num_packets = zeros(1, num_links);

% Initialize performance metrics arrays
nbrmeasurements = zeros(1, num_links);
nbrdeparted = zeros(1, num_links);
nbrarrived = zeros(1, num_links);

% Initialize arrays for arrivals and sojourn times for each link
arrivedtime = cell(1, num_links);
T = cell(1, num_links);

figure;
hold on;

for link = 1:num_links
    arrivedtime{link} = zeros(1, endtime * lambda_max(link));
    T{link} = zeros(1, endtime * lambda_max(link));
end

while t < endtime
    for link = 1:num_links
        % Calculate utilization factor for each link
        utilization_factor = lambda_max(link) / mu;

        % Update arrival rate based on utilization factor
        if utilization_factor > utilization_threshold
            lambda(link) = lambda_max(link) * utilization_threshold;
        else
            lambda(link) = lambda_max(link);
        end

        % Determine which link to use for arrival based on the shortest queue
        [~, current_link] = min(currcustomers);

        if link == current_link
            [t, nextevent] = min(event(:, link));

            if nextevent == 1
                % Handle arrival for the chosen link
                event(1, link) = exprnd(1/lambda(link)) + t;
                buffer=buffer+1;
                currcustomers(link) = currcustomers(link) + 1;
                nbrarrived(link) = nbrarrived(link) + 1;

                % Calculate and update the expected number of packets in the system
                expected_num_packets(link) = expected_num_packets(link) + buffer;

                % Check for packet loss
                if buffer > buffer_capacity
                    packet_loss(link) = packet_loss(link) + 1;
                end

                % Schedule the next service event for this link
                if buffer == 1
                    event(2, link) = exprnd(1/mu) + t;
                end

                % Update the arrival time for this link
                arrivedtime{link}(nbrarrived(link)) = t;
            elseif nextevent == 2
                % Handle departure for the chosen link
                currcustomers(link) = currcustomers(link) - 1;
                buffer=buffer-1;
                timeinsystem = t - event(1, link);
                nbrdeparted(link) = nbrdeparted(link) + 1;

                % Schedule the next service event for this link if there are still customers
                if buffer > 0
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

for link = 1:num_links
    subplot(2, num_links, link);
    plot(arrivedtime{link}(1:nbrarrived(link)), 1:nbrarrived(link), 'b');
    title(['Link ' num2str(link) ' Arrivals']);
    xlabel('Time');
    ylabel('Number of Arrivals');

    subplot(2, num_links, link + num_links);
    plot( 1:nbrdeparted(link),-T{link}(1:nbrdeparted(link)), 'r');
    title(['Link ' num2str(link) ' Sojourn Time']);
    xlabel('Time');
    ylabel('Sojourn Time');
    legend_labels{link} = ['Link ' num2str(link)];
end

legend(legend_labels);


