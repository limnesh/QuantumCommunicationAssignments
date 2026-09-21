function interactive_path_loss()
    % Main figure setup
    f = figure('Position', [100, 100, 1000, 500], 'Name', 'Interactive Path Loss & Coverage', 'NumberTitle', 'off');

    % --- STATIC PARAMETERS ---
    f_c = 2.4e9;            % 2.4 GHz
    c = 3e8;
    d0 = 1;
    d_max = 1000;
    Rx_sens_dBm = -85;      % Sensitivity threshold

    % Pre-calculate grid to save time during slider dragging
    grid_size = 40;         % Lower resolution so sliders don't lag
    x_vec = -d_max:grid_size:d_max;
    [X, Y] = meshgrid(x_vec, x_vec);
    d_grid = sqrt(X.^2 + Y.^2);
    d_grid(d_grid < d0) = d0;

    % Base Free Space Path loss at 1m
    PL_d0 = 20*log10(4*pi*f_c/c);

    % Generate a static random noise grid so the "shadowing" shape stays consistent
    % while you change its intensity, making it easier to see the effect.
    random_shadow_1D = randn(1, d_max);
    random_shadow_2D = randn(size(d_grid));

    % --- UI CONTROLS (SLIDERS) ---
    % 1. Transmit Power Slider (10 to 40 dBm)
    uicontrol('Style', 'text', 'Position', [50, 25, 120, 15], 'String', 'Tx Power (dBm):');
    slider_pt = uicontrol('Style', 'slider', 'Min', 10, 'Max', 40, 'Value', 20, ...
                          'Position', [170, 20, 120, 20], 'Callback', @update_plots);
    txt_pt = uicontrol('Style', 'text', 'Position', [300, 25, 40, 15], 'String', '20');

    % 2. Path Loss Exponent Slider (n = 2.0 to 5.0)
    uicontrol('Style', 'text', 'Position', [380, 25, 120, 15], 'String', 'Environment (n):');
    slider_n = uicontrol('Style', 'slider', 'Min', 2, 'Max', 5, 'Value', 3.5, ...
                         'Position', [500, 20, 120, 20], 'Callback', @update_plots);
    txt_n = uicontrol('Style', 'text', 'Position', [630, 25, 40, 15], 'String', '3.5');

    % 3. Shadowing Variance Slider (sigma = 0 to 15 dB)
    uicontrol('Style', 'text', 'Position', [700, 25, 120, 15], 'String', 'Shadowing (\sigma dB):');
    slider_sig = uicontrol('Style', 'slider', 'Min', 0, 'Max', 15, 'Value', 6, ...
                           'Position', [820, 20, 120, 20], 'Callback', @update_plots);
    txt_sig = uicontrol('Style', 'text', 'Position', [950, 25, 40, 15], 'String', '6');

    % Create Axes
    ax1 = subplot(1, 2, 1);
    ax2 = subplot(1, 2, 2);

    % Run once to initialize plots
    update_plots();

    % --- CALLBACK FUNCTION ---
    % This runs automatically every time you move a slider
    function update_plots(~, ~)
        % Get current slider values
        Pt = get(slider_pt, 'Value');
        n = get(slider_n, 'Value');
        sigma = get(slider_sig, 'Value');

        % Update text labels
        set(txt_pt, 'String', sprintf('%.1f', Pt));
        set(txt_n, 'String', sprintf('%.1f', n));
        set(txt_sig, 'String', sprintf('%.1f', sigma));

        %% 1D Calculations
        d = 1:d_max;
        PL_fspl = PL_d0 + 10 * 2.0 * log10(d/d0);
        PL_env  = PL_d0 + 10 * n * log10(d/d0) + (sigma * random_shadow_1D);

        %% 2D Calculations
        PL_grid = PL_d0 + 10 * n * log10(d_grid/d0) + (sigma * random_shadow_2D);
        Pr_grid = Pt - PL_grid; % Received Power = Tx Power - Path Loss

        %% Update 1D Plot
        cla(ax1);
        plot(ax1, d, PL_fspl, 'g', 'LineWidth', 2); hold(ax1, 'on');
        plot(ax1, d, PL_env, 'b.', 'MarkerSize', 4);
        grid(ax1, 'on');
        title(ax1, '1D Path Loss Profile');
        xlabel(ax1, 'Distance (m)'); ylabel(ax1, 'Path Loss (dB)');
        legend(ax1, 'Ideal Free Space (n=2)', sprintf('Actual Environment (n=%.1f)', n), 'Location', 'northwest');

        %% Update 2D Plot
        cla(ax2);
        imagesc(ax2, x_vec, x_vec, Pr_grid);
        set(ax2, 'YDir', 'normal');
        caxis(ax2, [-120, -40]);
        colormap(ax2, 'jet');
        hold(ax2, 'on');

        % Draw Base Station
        plot(ax2, 0, 0, 'k^', 'MarkerFaceColor', 'w', 'MarkerSize', 8);

        % Draw Coverage Boundary
        contour(ax2, X, Y, Pr_grid, [Rx_sens_dBm Rx_sens_dBm], 'k-', 'LineWidth', 2);

        title(ax2, sprintf('2D Coverage (Boundary at %d dBm)', Rx_sens_dBm));
        xlabel(ax2, 'X (m)'); ylabel(ax2, 'Y (m)');
        axis(ax2, 'equal'); axis(ax2, 'tight');
    end
end
