
clear;


% material parameters

Ea = 25e9;   % young's modulus
Em = 19.4e9; % unit Pa

k = 6.8e6; 
SNL = 0.04; % transformation strain
ds0 = k * SNL; % unit Pa/K

% transformation temperature 
Mf = 258; Ms = 259.5; As = 273; Af = 276;
du0 = (Ms + Mf + As + Af) / 4 * ds0;
w = (Ms - Mf + Af - As) / 4 * ds0;
c = 3.2e6; % heat capacity (Pa/K)
alpha = 11e-6; % expansion coefficient (/K)


mu = 1.0e3; 




N = 1; 

dt = 0.000001;
t = 0 : dt : 2 * N;


% maximum stress
SS0 = 520e6;  
SS = SS0 / 2 * (1 - cos(pi * t));




len = length(SS);

% xi is the martensite phase fraction
xi = zeros(1, len); 
ximin = xi(1); ximax = xi(1);

% T0 is the initial temperature of the sample
T0 = 298; 
T = ones(1, len) * T0;

% SS is stress
SN = zeros(1, len); 

% beta is the controllable driving force
beta = ones(1, 1) * (SS(1) * SNL - T(1) * ds0); 



for i = 1:length(SS) - 1

    % (1) Assume elastic deformation no phase transition

    xi(i + 1) = xi(i);

   
    T(i + 1) = -alpha / c * T(i) * (SS(i + 1) - SS(i)) - mu * (T(i) - T0) * dt + T(i);

    
    beta(i + 1) = SS(i + 1) * SNL - T(i + 1) * ds0;

    if beta(i + 1) > beta(i)

        if beta(i + 1) > ximin * (Ms - Mf) * ds0 - Ms * ds0 && beta(i) <- Mf * ds0

            T(i + 1) = (-alpha / c * T(i) * (SS(i + 1) - SS(i)) + (SS(i + 1) * SNL + du0 - w * (2 * xi(i + 1) - 1)) / c / (Ms - Mf) / ds0 * (SS(i + 1) - SS(i)) * SNL - mu * (T(i) - T0) * dt) / (1 + (SS(i + 1) ...
                * SNL + du0 - w * (2 * xi(i + 1) - 1)) / c / (Ms - Mf)) + T(i);

            xi(i + 1) = ((SS(i + 1) - SS(i)) * SNL - (T(i + 1) - T(i)) * ds0) / (Ms - Mf) / ds0 + xi(i);

            beta(i + 1) = SS(i + 1) * SNL - T(i + 1) * ds0; ximax = xi(i + 1);

        end

    else

        if beta(i) >- Af * ds0 && beta(i) < ximax * (Af - As) * ds0 - Af * ds0

            T(i + 1) = (-alpha / c * T(i) * (SS(i + 1) - SS(i)) + (SS(i + 1) * SNL + du0 - w * (2 * xi(i + 1) - 1)) / c / (Af - As) / ds0 * (SS(i + 1) - SS(i)) * SNL - mu * (T(i) - T0) * dt) / (1 + (SS(i + 1) ...
                * SNL + du0 - w * (2 * xi(i + 1) - 1)) / c / (Af - As)) + T(i);

            xi(i + 1) = ((SS(i + 1) - SS(i)) * SNL - (T(i + 1) - T(i)) * ds0) / (Af - As) / ds0 + xi(i);

            beta(i + 1) = SS(i + 1) * SNL - T(i + 1) * ds0; ximin = xi(i + 1);

        end

    end

    SN(i + 1) = (xi(i + 1) / Em + (1 - xi(i + 1)) / Ea) * SS(i + 1) + xi(i + 1) * SNL + alpha * (T(i + 1) - T0);

end


% plot

%%
figure
hold on
plot(SN, SS, '-', 'LineWidth', 2)
title('Shape memory effect')
xlabel('Strain')
ylabel('Stress')