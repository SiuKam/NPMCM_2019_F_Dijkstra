function [arc_length,O,B_prime] = mycircle(a,b,c)
    global A;
    global B;
    global C;
    global O;
    global n1;    
    A=a;
    B=b;
    C=c;
    v1 = B - A;
    v2 = C - B;
    n1 = cross(v1,v2);
    n2 = cross(v1,n1);
    if dot(n2,v2) < 0
        n2 = -n2;
    end
    e3 = n2 / norm(n2);
    v3 = 200 * e3;
    O = B + v3;
    B_prime = fsolve('fun',B,optimset('Display','off'));
    theta_1 = acos(dot((O - B),(O - B_prime)) / norm(O - B) / norm(O - B_prime));
    arc_length = theta_1 * 200;
end
