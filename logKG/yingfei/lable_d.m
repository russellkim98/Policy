function y=lable_d(wStar,x,N)
temp=rand(N,1);
y= (temp<=sigmoid(sum(x.*wStar)))*2-1;

end