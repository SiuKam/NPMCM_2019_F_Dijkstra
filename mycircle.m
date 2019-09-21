function [O,B_prime] = mycircle(A,B,C)
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
    theta_1 = asin(200 / norm(C-O));
    v3_1 = - vector_rotate((C-O), theta_1) / norm(C-O) * sqrt((norm(C-O))^2 + 200^2);
    v3_2 = - vector_rotate((C-O), theta_1) / norm(C-O) * sqrt((norm(C-O))^2 + 200^2);
    B_prime_1 = C - v3_1;
    B_prime_1 = C - v3_2;

    plot3(A,B,C);

end

function v_prime = vector_rotate(v,alpha)
    T = [cos(alpha), sin(alpha); -sin(alpha), cos(alpha)];
    v_prime = T * v';
end
