function [V, A, hFig] = generateVelocityProfile(t, tau, varargin)
%generateVelocityProfile Generate exponential velocity and acceleration profiles.
%   [V, A, hFig] = generateVelocityProfile(t, tau) returns velocity (m/s)
%   and acceleration (m/s^2) matrices for an exponential rise to 60 mph,
%   one column per time constant in tau.

% Copyright 2026 The MathWorks, Inc.

    % ---- Parse inputs ----
    ip = inputParser;
    ip.addRequired('t',   @(x) isnumeric(x) && isvector(x) && ~isempty(x));
    ip.addRequired('tau', @(x) isnumeric(x) && isvector(x) && ~isempty(x));
    ip.addParameter('Plot',      true,  @(x) islogical(x) && isscalar(x));
    ip.addParameter('TitleTag',  '',    @(x) isstring(x) || ischar(x));
    ip.addParameter('LineWidth', 1.8,   @(x) isscalar(x) && isnumeric(x) && x > 0);
    ip.parse(t, tau, varargin{:});

    doPlot    = ip.Results.Plot;
    titleTag  = string(ip.Results.TitleTag);
    lineWidth = ip.Results.LineWidth;

    % ---- Validate tau values ----
    tau = double(tau(:));                 % column vector
    if any(~isfinite(tau)) || any(tau <= 0)
        error('tau must contain positive, finite real values.');
    end

    % ---- Constants ----
    mph2mps = 0.44704;                    % 1 mph = 0.44704 m/s
    Vf_mps  = 60 * mph2mps;               % Final speed: 60 mph in m/s

    % ---- Vectorize t & tau for implicit expansion ----
    t = double(t(:));                     % column vector of time
    tauRow = tau.';                       % row vector of taus

    % ---- Compute (implicit expansion) ----
    % expTerm(i,j) = exp( - t(i) / tau(j) )
    expTerm = exp(-t ./ tauRow);
    V = Vf_mps .* (1 - expTerm);          % [numel(t) x numel(tau)]
    A = (Vf_mps ./ tauRow) .* expTerm;    % [numel(t) x numel(tau)]

    % ---- Plot (optional) ----
    hFig = [];
    if doPlot
        hFig = figure('Color', 'w');
        tl = tiledlayout(2,1, 'TileSpacing', 'compact', 'Padding', 'compact');

        % Velocity
        ax1 = nexttile(tl, 1);
        hold(ax1, 'on'); grid(ax1, 'on');
        for j = 1:numel(tau)
            plot(ax1, t, V(:,j)/0.44704, 'LineWidth', lineWidth);
        end
        ylabel(ax1, 'Velocity (mph)');
        legend(ax1, arrayfun(@(x) sprintf('\\tau = %.3g s', x), tau, 'UniformOutput', false), ...
               'Location', 'southeast');
        title(ax1, sprintf('Exponential rise to 60 mph%s', iifStr(titleTag)));

        % Acceleration
        ax2 = nexttile(tl, 2);
        hold(ax2, 'on'); grid(ax2, 'on');
        for j = 1:numel(tau)
            plot(ax2, t, A(:,j), 'LineWidth', lineWidth);
        end
        xlabel(ax2, 'Time (s)');
        ylabel(ax2, 'Acceleration (m/s^2)');
        legend(ax2, arrayfun(@(x) sprintf('\\tau = %.3g s', x), tau, 'UniformOutput', false), ...
               'Location', 'northeast');
        hold (ax1,"off");
        hold (ax2,"off");
    end
    
end

% --- local helper to optionally append " - <TitleTag>" in title ---
function s = iifStr(tag)
    if strlength(tag) > 0
        s = " - " + tag;
    else
        s = "";
    end
end
