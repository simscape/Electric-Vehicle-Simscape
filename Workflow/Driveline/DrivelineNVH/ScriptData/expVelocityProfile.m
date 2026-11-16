function [v, a] = expVelocityProfile(t, tau)
%expVelocityProfile Compute exponential velocity and acceleration for a single time constant.
%   [v, a] = expVelocityProfile(t, tau) returns velocity (m/s) and
%   acceleration (m/s^2) for an exponential rise to 60 mph with time
%   constant tau, and plots the results.

% Copyright 2025-2026 The MathWorks, Inc.

% --- Input validation ---
if nargin < 2
    error('expVelocityProfile requires two inputs: t (s) and tau (s).');
end
if ~isscalar(tau) || ~isreal(tau) || tau <= 0
    error('tau must be a positive real scalar (seconds).');
end

% Final speed: 60 mph -> m/s
Vf_mps = 60 * 0.44704;   % 1 mph = 0.44704 m/s

% Ensure numeric type for vectorization
t = double(t);

% Velocity and acceleration
expTerm = exp(-t ./ tau);
v = Vf_mps .* (1 - expTerm);
a = (Vf_mps ./ tau) .* expTerm;
% ---- Convert velocity to mph for an additional overlay (optional) ----
v_mph = v / 0.44704;      % 1 mph = 0.44704 m/s
% Plot Velocity and acceleration
tiledlayout(2,1);  % two stacked plots
nexttile;
plot(t, v, 'LineWidth', 1.8, 'Color', [0 0.45 0.74]); hold on; grid on;
plot(t, v_mph, '--', 'LineWidth', 1.5, 'Color', [0.85 0.33 0.10]);  % optional mph overlay
ylabel('Velocity');
legend({'v (m/s)', 'v (mph)'}, 'Location', 'southeast');
title(sprintf('Exponential rise to 60 mph with \\tau = %.2f s', tau));

% Acceleration
nexttile;
plot(t, a, 'LineWidth', 1.8, 'Color', [0.47 0.67 0.19]); grid on;
xlabel('Time (s)');
ylabel('Acceleration (m/s^2)');
legend({'a (m/s^2)'}, 'Location', 'northeast');

end
