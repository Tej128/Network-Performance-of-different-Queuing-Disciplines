clc
clear
close all

% Define the parameters
num_links = 5; % Number of links
lambda = [5, 7,9, 10, 12]; % Arrival rate for each link
mu = 10; % Service rate for each link
endtime = 100;
tstep = 1;
buffer_capacity = 20;

% Initialize arrays and variables
t = 0;
currcustomers = zeros(1, num_links);
event = zeros(3, num_links);

% Initialize performance metrics arrays
nbrmeasurements = zeros(1, num_links);
nbrdeparted = zeros(1, num_links);
nbrarrived = zeros(1, num_links);

% Initialize packet loss variables
packet_loss = zeros(1, num_links);
expected_num_packets = zeros(1, num_links);

% Initialize arrays for arrivals and sojourn times for each link
arrivedtime = cell(1, num_links);
T = cell(1, num_links);

for link = 1:num_links
    arrivedtime{link} = zeros(1, endtime * lambda(link));
    T{link} = zeros(1, endtime * lambda(link));
end

% Initialize a cell array for sojourn times
sojourn_times = cell(1, num_links);

while t < endtime
    for link = 1:num_links
        [~, current_link] = min(currcustomers);
        
        if link == current_link
            [t, nextevent] = min(event(:, link));

            if nextevent == 1
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
                currcustomers(link) = currcustomers(link) - 1;
                timeinsystem = t - event(1, link);
                nbrdeparted(link) = nbrdeparted(link) + 1;

                % Assign the sojourn time to the cell array T
                T{link}(nbrdeparted(link)) = timeinsystem;

                % Schedule the next service event for this link if there are still customers
                if currcustomers(link) > 0
                    event(2, link) = exprnd(1/mu) + t;
                else
                    event(2, link) = inf;
                end
                
                % Update the sojourn times for this link
                sojourn_times{link} = T{link}(1:nbrdeparted(link));
            else
                nbrmeasurements(link) = nbrmeasurements(link) + 1;
                event(3, link) = event(3, link) + exprnd(tstep);
            end
        end
    end
end

% Calculate packet loss probability and packet delay for each link
packet_loss_probability = packet_loss ./ nbrarrived;
packet_delay = expected_num_packets ./ (lambda .* (1 - packet_loss_probability));

% Plot arrivals and sojourn times for each link
for link = 1:num_links
    fprintf('Link %d:\n', link);
    fprintf('Packet Loss Probability: %.4f\n', packet_loss_probability(link));
    fprintf('Packet Delay: %.4f\n', packet_delay(link));
 

%subplot(2, num_links, link);
  %  plot(arrivedtime{link}(1:nbrarrived(link)), 1:nbrarrived(link), 'b');
   % title(['Link ' num2str(link) ' Arrivals']);
    %xlabel('Time');
    %ylabel('Number of Arrivals');

    %subplot(2, num_links, link + num_links);
    %plot(-sojourn_times{link}, 'r');
    %title(['Link ' num2str(link) ' Sojourn Time']);
    %xlabel('Sojourn Time');
    %ylabel('Customer Number');
end
%%
clc
clear
close all

% Define the parameters
num_links = 5; % Number of links
lambda = [5, 7, 9, 10, 12]; % Arrival rate for each link
mu = 15; % Service rate for each link
endtime = 100;
tstep = 1;
buffer_capacity = 100;

% Initialize arrays and variables
t = 0;
buffer=0;
currcustomers = zeros(1, num_links);
event = zeros(3, num_links);

% Initialize performance metrics arrays
nbrmeasurements = zeros(1, num_links);
nbrdeparted = zeros(1, num_links);
nbrarrived = zeros(1, num_links);

% Initialize packet loss variables
packet_loss = zeros(1, num_links);
expected_num_packets = zeros(1, num_links);

% Initialize arrays for arrivals and sojourn times for each link
arrivedtime = cell(1, num_links);
T = cell(1, num_links);

for link = 1:num_links
    arrivedtime{link} = zeros(1, endtime * lambda(link));
    T{link} = zeros(1, endtime * lambda(link));
end

% Initialize a cell array for sojourn times
sojourn_times = cell(1, num_links);

% Variable to track packet loss due to buffer overflow
buffer_overflow = 0;

while t < endtime
    for link = 1:num_links
        [~, current_link] = min(currcustomers);

        if link == current_link
            [t, nextevent] = min(event(:, link));

            if nextevent == 1
                % Check for buffer overflow at the shared buffer
                if buffer < buffer_capacity
                    % Add the packet to the shared buffer
                    event(1, link) = exprnd(1/lambda(link)) + t;
                    currcustomers(link) = currcustomers(link) + 1;
                    buffer=buffer+1;
                    nbrarrived(link) = nbrarrived(link) + 1;

                    % Calculate and update the expected number of packets in the system
                    expected_num_packets(link) = expected_num_packets(link) + buffer;%currcustomers(link);

                    % Schedule the next service event for this link
                    if buffer == 1
                        event(2, link) = exprnd(1/mu) + t;
                    end

                    % Update the arrival time for this link
                    arrivedtime{link}(nbrarrived(link)) = t;
                else
                    % Packet loss due to buffer overflow
                    packet_loss(link) = packet_loss(link) + 1;
                    buffer_overflow = buffer_overflow + 1;
                end
            elseif nextevent == 2
                buffer = buffer - 1;   
                currcustomers(link) = currcustomers(link) - 1;
                timeinsystem = t - event(1, link);
                nbrdeparted(link) = nbrdeparted(link) + 1;

                % Assign the sojourn time to the cell array T
                T{link}(nbrdeparted(link)) = timeinsystem;

                % Schedule the next service event for this link if there are still customers
                if buffer > 0
                    event(2, link) = exprnd(1/mu) + t;

                else
                    event(2, link) = inf;
                end

                % Update the sojourn times for this link
                sojourn_times{link} = T{link}(1:nbrdeparted(link));
            else
                nbrmeasurements(link) = nbrmeasurements(link) + 1;
                event(3, link) = event(3, link) + exprnd(tstep);
            end
        end
    end
end

% Calculate packet loss probability and packet delay for each link
packet_loss_probability = packet_loss ./ nbrarrived;
packet_delay = expected_num_packets ./ (lambda .* (1 - packet_loss_probability));

% Plot arrivals and sojourn times for each link
for link = 1:num_links
    fprintf('Link %d:\n', link);
    fprintf('Packet Loss Probability: %.4f\n', packet_loss_probability(link));
    fprintf('Packet Delay: %.4f\n', packet_delay(link));
    
    subplot(2, num_links, link);
    plot(arrivedtime{link}(1:nbrarrived(link)), 1:nbrarrived(link), 'b');
    title(['Link ' num2str(link) ' Arrivals']);
    xlabel('Time');
    ylabel('Number of Arrivals');

    subplot(2, num_links, link + num_links);
    plot(-sojourn_times{link}, 'r');
    title(['Link ' num2str(link) ' Sojourn Time']);
    xlabel('Sojourn Time');
    ylabel('Customer Number');
end

fprintf('Total Packet Loss: %d\n', buffer_overflow);
