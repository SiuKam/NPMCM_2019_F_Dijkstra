function [O,B_prime] = mycircle(A,B,C)
    v1 = B - A;
    v2 = C - B;
    n1 = cross(v1,v2);
    n2 = cross(v1,n1);
    if dot(n2,v2) < 0
        n2 = -n2;
    end
    e3 = norm(n2);
    v3 = 200 * e3;
    O = B + v3;
    
end
