clc
close all
clear all; % Empty memory
rng(1); % Set random seed

% Parameters
lambda1 = 5; % Initial arrival rate for link 1
lambda2 = 15; % Initial arrival rate for link 2
mu = 5; % Service rate for the buffer
endtime = 100; % Simulation length
buffer_capacity = 1000; % Buffer capacity

t = 0; % Current time
tstep = 1; % Average time between consecutive measurement events
buffer = zeros(1, buffer_capacity); % Initialize buffer
buffer_count = 0; % Current number of packets in the buffer
event = zeros(1, 4); % Constructs vector to keep time for next arrivals (pos 1 and 2), next buffer service (pos 3), and next measurement event (pos 4)
event(1) = exprnd(1/lambda1); % Time for the next arrival for link 1
event(2) = exprnd(1/lambda2); % Time for the next arrival for link 2

nbrarrived1 = 0; % Number of packets arrived from link 1
nbrarrived2 = 0; % Number of packets arrived from link 2
pl = zeros(1, 2);
packet_loss = 0; % Number of packets lost
packet_delays = zeros(1, buffer_capacity); % To calculate packet delays
packet_sources = zeros(1, buffer_capacity); % To track packet sources (1 for Link 1, 2 for Link 2)

nbrdeparted = 0; % Number of departed packets

adaptive = false; % Indicator for adaptive queuing

pause;

while t < endtime
    [t, nextevent] = min(event);
    
    if adaptive && (buffer_count / buffer_capacity > 0.8)
        % If buffer load exceeds 80%, reduce the arrival rate to lower the load
        lambda1 = 0.4 * mu;
        lambda2 = 0.6 * mu;
        adaptive = false;
    else
        % If buffer load is below 80%, revert to initial arrival rates
        lambda1 = 5;
        lambda2 = 15;
        adaptive = true;
    end

    if nextevent == 1 % Arrival from Link 1
        event(1) = exprnd(1/lambda1) + t;
        nbrarrived1 = nbrarrived1 + 1;
        if buffer_count < buffer_capacity
            buffer_count = buffer_count + 1;
            buffer(buffer_count) = t;
            packet_sources(buffer_count) = 1; % Source: Link 1
        else
            packet_loss = packet_loss + 1;
            pl(1) = pl(1) + 1;
        end
    elseif nextevent == 2 % Arrival from Link 2
        event(2) = exprnd(1/lambda2) + t;
        nbrarrived2 = nbrarrived2 + 1;
        if buffer_count < buffer_capacity
            buffer_count = buffer_count + 1;
            buffer(buffer_count) = t;
            packet_sources(buffer_count) = 2; % Source: Link 2
        else
            packet_loss = packet_loss + 1;
            pl(2) = pl(2) + 1;
        end
    elseif nextevent == 3 % Buffer service (Priority-based)
        if buffer_count > 0
            % Find the highest priority packet
            [priority, index] = min(packet_sources(1:buffer_count));
            % Packet departure
            nbrdeparted = nbrdeparted + 1;
            packet_delays(nbrdeparted) = t - buffer(index);
            % Remove the packet from the buffer
            buffer(index:buffer_count-1) = buffer(index+1:buffer_count);
            packet_sources(index:buffer_count-1) = packet_sources(index+1:buffer_count);
            buffer_count = buffer_count - 1;
        end
        event(3) = inf;
    else % Measurement event
        event(4) = t + exprnd(tstep);
        
        if buffer_count > 0
            event(3) = t;
        else
            event(3) = inf;
        end
    end
end

% Calculate average packet delay if at least one packet has departed
if nbrdeparted > 0
    valid_delays = packet_delays(1:nbrdeparted);
    average_packet_delay = mean(valid_delays(~isnan(valid_delays)));
else
    average_packet_delay = 0; % No packets departed
end

fprintf('Packet Loss: %d\n', packet_loss);
fprintf('Packet Loss link1: %d\n', pl(1));
fprintf('Packet Loss link2: %d\n', pl(2));
fprintf('Average Packet Delay: %f\n', average_packet_delay);
