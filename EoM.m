clear
clc

% fuel consumption
alpha_m_dot = 1;

% gravity vector in I
g = sym('g',[3,1]);
% vector from CoM to thrust
r_T_B = sym('r_T_B',[3,1]);
% inertia
J_B = diag(sym('J_B',[3,1]));
% time dilation
sigma_hat = sym('sigma_hat');
% delta T
T = sym('T');

% state variables
u = sym('u',[3,1]);
m = sym('m');
r = sym('r',[3,1]);
v = sym('v',[3,1]);
q = sym('q',[4,1]);
% rotation matrix from I to B
C_I_B = quat2rotmsym(q);
w = sym('w',[3,1]);
m_dot = -alpha_m_dot * norm(u);
r_dot = v;
v_dot = 1/m * C_I_B * u + g;
q_dot = 1/2 * omega(w) * q;
w_dot = J_B \ (skew(r_T_B) * u - skew(w) * J_B * w);

x = [m; r; v; q; w];
x_dot = [m_dot; r_dot; v_dot; q_dot; w_dot];

% linearized system
A = jacobian(x_dot,x)
B = jacobian(x_dot,u)
Sigma = x_dot;


% discretized system

function a = alpha_k(tk,t,tk_)
    a = (tk_-t)/(tk_-tk);
end
function b = beta_k(tk,t,tk_)
    b = (t-tk)/(tk_-tk);
end

function O = omega(v)
    O = [0 -v(1) -v(2) -v(3);
        v(1) 0 v(3) -v(2);
        v(2) -v(3) 0 v(1);
        v(3) v(2) -v(1) 0];
end

function C = quat2rotmsym(q)
    C = [1-2*(q(3)^2+q(4)^2) 2*(q(2)*q(3)+q(1)*q(4)) 2*(q(2)*q(4)-q(1)*q(3));
    2*(q(2)*q(3)-q(1)*q(4)) 1-2*(q(2)^2+q(4)^2) 2*(q(3)*q(4)+q(1)*q(2));
    2*(q(2)*q(4)+q(1)*q(3)) 2*(q(3)*q(4)-q(1)*q(2)) 1-2*(q(2)^2+q(3)^2)];
end

function S = skew(v)
    S = [0 -v(3) v(2); v(3) 0 -v(1); -v(2) v(1) 0];
end