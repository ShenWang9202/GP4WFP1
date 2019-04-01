% problem constants
alpha = 0.5; beta = 2; gamma = 0.5; delta = 2;

% varying parameters for an optimal trade-off curve
N = 10;
Afloor = logspace(1,3,N);
Awall  = [100 1000 10000];
opt_volumes = zeros(length(Awall),N);

disp('Computing optimal box volume for:')

% setup various GP problems with varying parameters
for k = 1:length(Awall)
  Awall_k = Awall(k);
  fprintf( 'Awall = %d:\n', Awall(k) );
  for n = 1:N
    % resolve the problem with varying parameters
    Afloor_n = Afloor(n);
    fprintf( '    Afloor = %7.2f: ', Afloor(n) );
    cvx_begin gp quiet
      variables h w d
      % objective function is the box volume
      maximize( h*w*d )
      subject to
        2*(h*w + h*d) <= Awall_k;
        w*d <= Afloor_n;
        alpha <= h/w <= beta;
        gamma <= d/w <= delta;
    cvx_end
    fprintf( 'max_volume = %3.2f\n', cvx_optval );
    opt_volumes(k,n) = cvx_optval;
  end
end

% plot the tradeoff curve
figure, clf
loglog(Afloor,opt_volumes(1,:), Afloor,opt_volumes(2,:), Afloor,opt_volumes(3,:));
xlabel('Afloor'); ylabel('V');