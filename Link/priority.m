clc
clear
close all

xx = 3;
yy = 2;
rng(1);

num_links = 5; % Example: Three links
lambda = [5, 7, 9, 10, 12]; % Arrival rate for each link
mu = 10; % Service rate for each link
endtime = 100;
t = 0;
tstep = 1;
buffer_capacity = 20;

% Assign priorities to links (higher number means higher priority)
priorities = [5, 4, 3, 2, 1];

% Initialize arrays for each link
currcustomers = zeros(1, num_links);
buffer=0;
event = zeros(3, num_links);
priority = zeros(1, num_links); % Initialize priority for each link

% Initialize performance metrics arrays
nbrmeasurements = zeros(1, num_links);
nbrdeparted = zeros(1, num_links);
nbrarrived = zeros(1, num_links);

% Initialize packet loss variables for all links
packet_loss = zeros(1, num_links);
expected_num_packets = zeros(1, num_links);

% Initialize arrays for arrivals and sojourn time
arrivedtime = cell(1, num_links);
T = cell(1, num_links);

for link = 1:num_links
    arrivedtime{link} = zeros(1, endtime * lambda(link));
    T{link} = zeros(1, endtime * lambda(link));
end

while t < endtime
    for link = 1:num_links
        [t, nextevent] = min(event(:, link));

        if nextevent == 1
            % Handle arrival for the chosen link
            event(1, link) = exprnd(1/lambda(link)) + t;
            %buffer=buffer+1;
            currcustomers(link) = currcustomers(link) + 1;
            nbrarrived(link) = nbrarrived(link) + 1;

            % Set the priority of the arriving packet
            priority(link) = priorities(link);

            % Calculate and update the expected number of packets in the system
            expected_num_packets(link) = expected_num_packets(link) + currcustomers(link);%buffer;

            % Check for packet loss for the current link
            if currcustomers(link) > buffer_capacity
                packet_loss(link) = packet_loss(link) + 1;
            end

            % Schedule the next service event for this link
            if currcustomers(link) == 1
                event(2, link) = exprnd(1/mu) + t;
            end

            % Record the arrival time
            arrivedtime{link}(nbrarrived(link)) = t;
        elseif nextevent == 2
            % Handle departure for the chosen link
            currcustomers(link) = currcustomers(link) - 1;
            buffer=buffer-1;
            timeinsystem = t - event(1, link);
            nbrdeparted(link) = nbrdeparted(link) + 1;

            % Schedule the next service event for this link if there are still customers
            if currcustomers(link) > 0
                event(2, link) = exprnd(1/mu) + t;
            else
                event(2, link) = inf;
            end

            % Record the sojourn time
            T{link}(nbrdeparted(link)) = timeinsystem;
        else
            % Handle measurement event for the chosen link
            nbrmeasurements(link) = nbrmeasurements(link) + 1;
            N(link, nbrmeasurements(link)) = currcustomers(link);
            event(3, link) = event(3, link) + exprnd(tstep);
        end
    end

    % Sort links by priority before scheduling
    [~, link_order] = sort(priority, 'descend');
    event = event(:, link_order);
    currcustomers = currcustomers(link_order);
    priority = priority(link_order);
    t = min(event(:));

    % Plot arrivals and sojourn times for each link
 
   
end
% Plot arrivals and sojourn times for each link


% Calculate packet loss probability and packet delay for all links
packet_loss_probability = packet_loss ./ nbrarrived;
packet_delay = expected_num_packets ./ (lambda .* (1 - packet_loss_probability));

% Display the results for all links
for link = 1:num_links
    fprintf('Link %d:\n', link);
    fprintf('Packet Loss Probability: %.4f\n', packet_loss_probability(link));
    fprintf('Packet Delay: %.4f\n', packet_delay(link));
end
