function [X,theta,p_new] = learner_KG_ms(X,theta,p,bid,y)
x = [1 bid];
p_new = update_p(x,y,theta,p);
end

