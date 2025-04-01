function class = apneaDetection(data)
   % Accessing individual signals from the data struct
    flow_signal = data.Flow;
    abdo_signal = data.Abdo;
    thor_signal = data.Thor;
    spo2_signal = data.SpO2;


    % Filter the signals using the filter_signals function(below)
    [flow_filtered, abdo_filtered, thor_filtered] = filter_signals(flow_signal, abdo_signal, thor_signal);
    
    % Find apnea event indexes using get_apnea_indexes function(below)

    % If the function detects a decrease in the flow signal about
    % 91 percent, it will return the indexes, otherwise return an empty list
    [apnea_indexes] = get_apnea_indexes(flow_filtered, 0.07, 32);

    % Check for Apnea events
    if isempty(apnea_indexes)
        % No Apnea events found, check for Hypopnea events

        % Find hypopnea event indexes using get_apnea_indexes function with
        % decrease of airflow about 60 percent
        [hypopnea_indexes] = get_apnea_indexes(flow_filtered, 0.43, 32);

        % Check for SpO2 Desaturation using detekce_poklesu function
        pokles_saturace = detekce_poklesu(spo2_signal, 0.97);

        % Classify Apnea type based on Hypopnea and Desaturation presence
        if ~isempty(hypopnea_indexes) || pokles_saturace == true
            apnoe_type = 3;  % Hypopnea with Desaturation
        elseif pokles_saturace == false && isempty(hypopnea_indexes)
            apnoe_type = 4;  % None (no Apnea or Hypopnea without Desaturation)
        end
    else
        % Apnea events found, classify Apnea type using apnoe_detection
        % function (below)
        apnoe_type = apnoe_detection(abdo_filtered, thor_filtered, apnea_indexes, spo2_signal);
    end

    class = apnoe_type;


    % Nested function for filtering signals (high-pass and band-pass filtering)
    function [flow_filtered, abdo_filtered, thor_filtered] = filter_signals(flow, abdo, thor)
        fvz1 =32;
        % High-pass filter to remove DC component
        r = 0.9;
        a = [1, -r];
        b = [1, -1];
        z = -1;
        Hm = abs((z - 1) / (z - r));
        K = 1 / Hm;
        b = b * K;
      
        flow_filtered = filtfilt(b, a, flow);
        abdo_filtered = filtfilt(b, a, abdo);
        thor_filtered = filtfilt(b, a, thor);


        % Low-pass filter to isolate relevant frequency
        
        Fmax = 1;
        [b, a] = butter(6, Fmax/(fvz1/2), 'low');

        flow_filtered = filtfilt(b, a, flow_filtered);
        abdo_filtered = filtfilt(b, a, abdo_filtered);
        thor_filtered = filtfilt(b, a, thor_filtered);

    end


    % Nested function to find Apnea/Hypopnea event indexes based on flow signal drops
    function [apnea_indexes] = get_apnea_indexes(flow, threshold, fvz)
      
        flow_signal = flow;

        % Calculate threshold based on signal maximum
        prah = max(flow_signal) * threshold;

        % Create binary signal for flow drops
        flow_binary = zeros(size(flow_signal));
        flow_binary(abs(flow_signal) <= prah) = 1;

        % Find start and stop indexes of potential apnea events
        starts = find(diff(flow_binary) == 1);
        stops = find(diff(flow_binary) == -1);

        % Handle edge cases (unequal starts and stops)
        if length(starts) > length(stops)
            stops = vertcat(stops, length(flow_signal));
        elseif length(starts) < length(stops)
            starts = vertcat(1, starts);
        elseif length(starts) == length(stops) && stops(1) - starts(1) < 0
            stops = vertcat(stops, length(flow_signal));
            starts = vertcat(1, starts);
        end

        % Find events longer than 10 seconds
        long_durations = [];
        for j = 1:length(stops)
            if stops(j) - starts(j) >= fvz*10
                long_durations = [long_durations, starts(j), stops(j)];
            end
        end
        % Add event indexes to apnea_indexes
        apnea_indexes = long_durations;
    end



    % Classify first and second Apnea types
    function apnoe_type = apnoe_detection(abdomen_signal, chest_signal, detection_indices, spo2)
        % Based on statistical data, the average saturation for the
        % first(central apnea) is less than 90, which is why the threshold
        % is very high
        if mean(spo2)<90
            threshold1 = 40/1000;
            threshold2 = 30/1000;
        else
            % Most likely this is the second type apnea,
            % for better detection we lower the threshold 
            threshold1 = 1/1000;
            threshold2 = 1/100;
        end

      
        % Get a signal segment
        abdomen_segment = (abdomen_signal(detection_indices(1)+32:detection_indices(2)-32));
        chest_segment = (chest_signal(detection_indices(1)+32:detection_indices(2)-32));

        % Apply median filtering to the signal segments
        xFilt = medfilt1(abdomen_segment, 3); yFilt = medfilt1(chest_segment, 3);
        abdoProDetekci = xFilt.^2; thorProDetekci = yFilt.^2;

        % Find peaks in the signal segments
        [~,abdomen_peaks] = findpeaks(abdoProDetekci,"NPeaks", 2,  "MinPeakHeight", threshold1);
        [~,chest_peaks] = findpeaks(thorProDetekci,"NPeaks", 2, "MinPeakHeight", threshold2);


        % Determine the type of apnea
        if isempty(abdomen_peaks) && isempty(chest_peaks)
            apnoe_type = 1; % Central apnea
        else
            apnoe_type = 2; % Obstructive apnea
        end
    end


    % Function to detect drops in saturation
    function pokles_saturace = detekce_poklesu(signal, prah_poklesu)
        N = length(signal);
        
        % Calculate the threshold for saturation drop
        mez_hodnota = max(signal) * prah_poklesu;
        
        % Initialize a variable to store the count of samples below the threshold
        pocet_vzorku = 0;
       
        for ii = 1:N
            % Check if the current value falls below the threshold
            if signal(ii) < (mez_hodnota)
                pocet_vzorku = pocet_vzorku + 1;
            else
                continue
            end
        end
        
        % Evaluate whether there has been a drop in saturation
        if pocet_vzorku>=18 
            pokles_saturace = true; 
        else
            pokles_saturace = false;
        end
    end
end



    
    

