function q=fun(p)
    B_p=p;
    global A;
    global C;
    global O;
    global n1;
    q(1)=norm(B_p - O)-200;
    q(2)=dot((B_p - O),(C - B_p)) ;
    q(3)=dot(n1,(B_p - A));   
end