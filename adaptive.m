%% FIFO Arrival Rate Adaptation
clc
clear
close all

rng(1);

num_links = 3; % Example: Three links
mu = 10; % Service rate for each link
endtime = 1000;
t = 0;
tstep = 1;
utilization_threshold = 0.9; % Utilization factor threshold

% Initialize variables
lambda_max = [9, 10, 12]; % Maximum arrival rate for each link
lambda = lambda_max; % Initial arrival rate for each link
currcustomers = zeros(1, num_links);
utilization_factor = zeros(1, num_links);
utilization_factor_history = cell(1, num_links);

% Initialize performance metrics arrays
nbrmeasurements = zeros(1, num_links);
nbrdeparted = zeros(1, num_links);
nbrarrived = zeros(1, num_links);

while t < endtime
    for link = 1:num_links
        % Calculate the utilization factor for each link
        utilization_factor(link) = lambda(link) / mu;

        % Update utilization factor history for each link
        utilization_factor_history{link} = [utilization_factor_history{link}, utilization_factor(link)];

        % Adjust the arrival rate based on utilization factor for each link
        if utilization_factor(link) > utilization_threshold
            % Reduce arrival rate
            lambda(link) = lambda(link) * 0.9; % You can adjust the reduction factor as needed
        else
            % Increase arrival rate
            lambda(link) = min(lambda(link) * 1.1, lambda_max(link)); % Increase up to the maximum

        end

        % Process events or update the system as needed for each link
        % In this example, we're just tracking the utilization factor

        % Update time
        t = t + tstep;
    end
end

% Plot the utilization factor over time for each link
for link = 1:num_links
    figure;
    plot(1:length(utilization_factor_history{link}), utilization_factor_history{link});
    xlabel('Time');
    ylabel('Utilization Factor');
    title(['Utilization Factor Over Time (Link ' num2str(link) ')']);
end
%% FIFO dynamic buffer size

clc
clear
close all

rng(1);

num_links = 3; % Example: Three links
mu = 10; % Service rate for each link
endtime = 1000;
t = 0;
tstep = 1;
utilization_threshold = 1.0; % Utilization factor threshold for adaptation
initial_buffer_size = 20; % Initial buffer size
max_buffer_size = 30; % Maximum buffer size

% Initialize variables
lambda_max = [9, 10, 12]; % Maximum arrival rate for each link
lambda = lambda_max; % Initial arrival rate for each link
currcustomers = zeros(1, num_links);
buffer_size = initial_buffer_size; % Initial buffer size
utilization_factor = zeros(1, num_links);
utilization_factor_history = cell(1, num_links);
buffer_size_history = [];

% Initialize performance metrics arrays
nbrmeasurements = zeros(1, num_links);
nbrdeparted = zeros(1, num_links);
nbrarrived = zeros(1, num_links);

while t < endtime
    for link = 1:num_links
        % Calculate the utilization factor for each link
        utilization_factor(link) = lambda(link) / (mu * buffer_size);

        % Update utilization factor history for each link
        utilization_factor_history{link} = [utilization_factor_history{link}, utilization_factor(link)];

        % Adapt the buffer size based on utilization factor
        if utilization_factor(link) > utilization_threshold && buffer_size > 1
            % Reduce buffer size
            buffer_size = buffer_size - 1; % Decrease the buffer size
        elseif utilization_factor(link) < utilization_threshold
            % Increase buffer size
            buffer_size = buffer_size + 1; % Increase the buffer size
        end

        % Process arrivals and departures based on the dynamic buffer size
        arrivals = min(buffer_size - currcustomers(link), poissrnd(lambda(link) * tstep));
        currcustomers(link) = currcustomers(link) + arrivals;
        nbrarrived(link) = nbrarrived(link) + arrivals;

        departures = min(currcustomers(link), poissrnd(mu * tstep));
        currcustomers(link) = currcustomers(link) - departures;
        nbrdeparted(link) = nbrdeparted(link) + departures;

        % Update time
        t = t + tstep;
    end
    
    % Record buffer size
    buffer_size_history = [buffer_size_history, buffer_size];
end

% Plot the utilization factor and buffer size over time for each link
for link = 1:num_links
    figure;
    subplot(2, 1, 1);
    plot(1:length(utilization_factor_history{link}), utilization_factor_history{link});
    xlabel('Time');
    ylabel('Utilization Factor');
    title(['Utilization Factor Over Time (Link ' num2str(link) ')']);

    subplot(2, 1, 2);
    plot(1:length(buffer_size_history), buffer_size_history);
    xlabel('Time');
    ylabel('Buffer Size');
    title(['Buffer Size Over Time (Link ' num2str(link) ')']);
end
