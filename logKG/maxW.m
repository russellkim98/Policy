function w = maxW(x,q,m,y)
%1/p=1+C1exp(C2p)

C1=exp(y*sum(m.*x));
C2=y*y*sum(x.*x./q);

theta=1e-10;
b=1;
a=0.1;
while 1/a<1+C1*exp(C2*a)
    a=a/2;
end

while b-a>theta
    c=(a+b)/2;
    if 1/c<1+C1*exp(C2*c)
        b=c;
    else
        a=c;
    end
end

p=(a+b)/2;
w=m+y*p.*x./q;

end