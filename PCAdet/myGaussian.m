function h = myGaussian(mu, theta, xx)

h = 1/sqrt(2*pi)/theta*exp(-(xx'-mu).^2/2/theta^2);