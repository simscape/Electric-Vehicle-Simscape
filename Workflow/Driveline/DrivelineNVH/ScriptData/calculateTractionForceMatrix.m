function Ftrac = calculateTractionForceMatrix(A, V, m, Crr, Cd, Af, t, tau, varargin)
%calculateTractionForceMatrix Compute traction force matrix for flat road.
%   Ftrac = calculateTractionForceMatrix(A, V, m, Crr, Cd, Af, t, tau)
%   returns the total traction force (inertia + rolling resistance +
%   aerodynamic drag) needed to follow the given acceleration and velocity
%   profiles, and plots the result.

% Copyright 2026 The MathWorks, Inc.

    % ---- Parse optional arguments ----
    p = inputParser;
    p.addParameter('AirDensity', 1.225,   @(x) isscalar(x) && isnumeric(x) && isfinite(x) && x > 0);
    p.addParameter('Gravity',    9.80665, @(x) isscalar(x) && isnumeric(x) && isfinite(x) && x > 0);
    p.parse(varargin{:});

    rho = p.Results.AirDensity;
    g   = p.Results.Gravity;

    % ---- Basic input checks ----
    if ~isnumeric(A) || ~isnumeric(V) || ~isequal(size(A), size(V))
        error('A and V must be numeric matrices of the same size.');
    end
    if ~isscalar(m)  || ~isfinite(m)  || m  <= 0,  error('m must be a positive finite scalar (kg).');  end
    if ~isscalar(Crr)|| ~isfinite(Crr)|| Crr < 0,  error('Crr must be a non-negative finite scalar.'); end
    if ~isscalar(Cd) || ~isfinite(Cd) || Cd  < 0,  error('Cd must be a non-negative finite scalar.');  end
    if ~isscalar(Af) || ~isfinite(Af) || Af <= 0,  error('Af must be a positive finite scalar (m^2).'); end

    % ---- Compute component forces (fully vectorized) ----
    % Inertial force
    F_inertia = m .* A;                     % N

    % Rolling resistance (constant per time sample; broadcast to matrix)
    F_roll = (Crr * m * g);                 % N
    F_roll = F_roll .* ones(size(A));       % expand to matrix size

    % Aerodynamic drag (depends on velocity per element)
    F_aero = 0.5 * rho * Cd * Af .* (V .^ 2);  % N

    % ---- Total traction force (flat road) ----
    Ftrac = F_inertia + F_roll + F_aero;

    % ---- Plot ----
    figure;
    plot(t(:), Ftrac, 'LineWidth', 1.6);
    legend(arrayfun(@(x) sprintf('\\tau = %.3g s', x), tau(:)', 'UniformOutput', false), ...
           'Location', 'best');
    title('Required Traction Force (N) for Velocity Time Constants');
    xlabel('Time (s)');
    ylabel('Force (N)');
    grid on;
end
