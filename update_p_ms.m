function p_new = update_p_ms(x,nA,nC,theta,p)

[~,K] = size(theta);
p_new = zeros(1,K);

for k=1:K
    t = theta(:,k);
    p_new(k) = nchoosek(nA,nC)*phi(x*t)^nC*(1-phi(x*t))^(nA-nC)*p(k);
end
denom = sum(p_new);
p_new = p_new./denom;

end

