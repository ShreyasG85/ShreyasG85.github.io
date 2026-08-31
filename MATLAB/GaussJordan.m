function x = GaussJordan(A, b)

    [~, n] = size(A); 
    % Even if user enters row vector for [b]
    AugmentedMatrix = [A b(:)];

    for i = 1:n
        % Switching pivot row with max(abs(pivot element))
        [~, pivot] = max(abs(AugmentedMatrix(i:end, i)));
        pivot = pivot + i - 1;
        AugmentedMatrix([i, pivot], :) = AugmentedMatrix([pivot, i], :);

        % divide
        AugmentedMatrix(i, :) = AugmentedMatrix(i, :) / AugmentedMatrix(i, i);

        % Eliminate
        for j = 1:n
            if j ~= i
                AugmentedMatrix(j, :) = AugmentedMatrix(j, :) - AugmentedMatrix(j, i) * AugmentedMatrix(i, :);
            end
        end
    end

    x = AugmentedMatrix(:, end);
end
