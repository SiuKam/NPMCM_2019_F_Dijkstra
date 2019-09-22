clear;
% 计时
tic;

% 参数设置
alpha_1 = 20;
alpha_2 = 10;
beta_1 = 15;
beta_2 = 20;
theta = 20;
delta = 1e-3;
minimum_radius = 200;
data_file = 'data_set_2.xlsx';

% 数据读取
data_set=xlsread(data_file);
point_v_flag = data_set(:,5);
distance_matrix=zeros(length(data_set),length(data_set));
for i = 1 : length(data_set)
    for j = 1 : length(data_set)
        vertical_distance_matrix(i,j)=abs(data_set(i,4)-data_set(j,4));
        horizontal_distance_matrix(i,j)=sqrt((data_set(i,2)-data_set(j,2))^2+(data_set(i,3)-data_set(j,3))^2);
        distance_matrix(i,j)=sqrt((vertical_distance_matrix(i,j))^2+(horizontal_distance_matrix(i,j))^2);
    end
end

% 初始化各类变量
S_matrix = [1,0,0,0];
U_matrix = [];
cut_out_point = [data_set(1,2),data_set(1,3),data_set(1,4)];
circle_center_point = [0,0,0];
for i = 2:length(data_set)
    U_matrix = [U_matrix;i,Inf,Inf,Inf];
    cut_out_point = [cut_out_point;Inf,Inf,Inf];
    circle_center_point = [circle_center_point;Inf,Inf,Inf];
end

path_matrix = zeros(length(data_set),1);
is_searched = zeros(length(data_set),1);

previous_delta_v = 0;
previous_delta_h = 0;
current_delta_h = 0;
current_delta_v = 0;

% 对起始点
i = 1;
is_searched(i)=1;
for j = U_matrix(:,1).'
    new_delta=distance_matrix(j,i)*delta;
    id_to_S = find(S_matrix == i);
    current_delta_h = S_matrix(id_to_S,4) + new_delta;
    current_delta_v = S_matrix(id_to_S,3) + new_delta;
    if (current_delta_h < alpha_2) && (current_delta_v < alpha_1) && point_v_flag(j) == 1 && j ~= length(data_set)
        current_delta_v = 0;
    elseif (current_delta_h < beta_2) && (current_delta_v < beta_1) && point_v_flag(j) == 0 && j ~= length(data_set)
        current_delta_h = 0;
    elseif j == length(data_set) && (current_delta_h < theta) && (current_delta_v < theta)
        current_delta_h = 0;
        current_delta_v = 0;
    else
        continue;
    end
    id_to_U = find(U_matrix(:,1) == j);
    if distance_matrix(j,i) + S_matrix(id_to_S,2) < U_matrix(id_to_U,2)
        U_matrix(id_to_U,2) = distance_matrix(j,i) + S_matrix(id_to_S,2);
        U_matrix(id_to_U,3) = current_delta_v;
        U_matrix(id_to_U,4) = current_delta_h;
        path_matrix(j)=i;
        cut_out_point(j,:) = [data_set(1,2),data_set(1,3),data_set(1,4)];
    end
end
for k = U_matrix(:,1).'
    id_to_U = find(U_matrix == k);
    if U_matrix(id_to_U,2) < Inf
        S_matrix = [S_matrix; U_matrix(id_to_U,:)];
        U_matrix(id_to_U,:) = [];
    end
end
% 对初始点搜索完成

% 对其余点
while U_matrix(end,1) == length(data_set)
    % U_matrix = sortrows(U_matrix,2);

    to_do_list = [];
    for i = S_matrix(:,1).'
        if is_searched(i) == 0
            to_do_list = [to_do_list,i];
        end
    end

    for i = to_do_list
        is_searched(i)=1;
        i_previous_point = cut_out_point(i,:);
        i_point = [data_set(i,2),data_set(i,3),data_set(i,4)];
        v1 = i_point - i_previous_point;
        e1 = v1 / norm(v1);
        i_out_most_point = i_point + 200 * e1;
        for j = U_matrix(:,1).'            
            j_point = [data_set(j,2),data_set(j,3),data_set(j,4)];
            judge_vector = j_point - i_out_most_point;
            if dot(e1,judge_vector) < 0
                continue;
            end
            [arc_length,O,i_prime] = mycircle(i_previous_point,i_point,j_point);
            new_distance = arc_length + norm(j_point - i_prime);
            new_delta = new_distance * delta;
            id_to_S = find(S_matrix == i);
            current_delta_h = S_matrix(id_to_S,4) + new_delta;
            current_delta_v = S_matrix(id_to_S,3) + new_delta;
            if (current_delta_h < alpha_2) && (current_delta_v < alpha_1) && point_v_flag(j) == 1 && j ~= length(data_set)
                current_delta_v = 0;
            elseif (current_delta_h < beta_2) && (current_delta_v < beta_1) && point_v_flag(j) == 0 && j ~= length(data_set)
                current_delta_h = 0;
            elseif j == length(data_set) && (current_delta_h < theta) && (current_delta_v < theta)
                current_delta_h = 0;
                current_delta_v = 0;
            else
                continue;
            end
            id_to_U = find(U_matrix(:,1) == j);
            if new_distance + S_matrix(id_to_S,2) < U_matrix(id_to_U,2)
                U_matrix(id_to_U,2) = new_distance + S_matrix(id_to_S,2);
                U_matrix(id_to_U,3) = current_delta_v;
                U_matrix(id_to_U,4) = current_delta_h;
                path_matrix(j) = i;
                cut_out_point(j,:) = i_prime;
                circle_center_point(j,:) = O;
            end
        end
    end
    for k = U_matrix(:,1).'
        id_to_U = find(U_matrix == k);
        if U_matrix(id_to_U,2) < Inf
            S_matrix = [S_matrix; U_matrix(id_to_U,:)];
            U_matrix(id_to_U,:) = [];
        end
    end
end

path_result=[length(data_set)];
previous_point = length(data_set);
cut_out_point_result = [];
circle_center_result = [];
while previous_point ~= 1
    cut_out_point_result = [cut_out_point(previous_point,:);cut_out_point_result];
    circle_center_result = [circle_center_point(previous_point,:);circle_center_result];
    previous_point = path_matrix(previous_point);
    path_result = [previous_point , path_result];
end

time_to_complete = toc;

% 用于验证path_result的正确性
previous_delta_v = 0;
previous_delta_h = 0;
current_delta_h = 0;
current_delta_v = 0;
total_distance = 0;
flag_correct = false;

i = 1;
total_distance = distance_matrix(path_result(i),path_result(i+1));
new_delta=distance_matrix(path_result(i),path_result(i+1))*delta;
current_delta_h = previous_delta_h + new_delta;
current_delta_v = previous_delta_v + new_delta;
total_distance = total_distance + distance_matrix(path_result(i),path_result(i+1));
if (current_delta_h < alpha_2) && (current_delta_v < alpha_1) && point_v_flag(path_result(i+1)) == 1 && path_result(i+1) ~= length(data_set)
    current_delta_v = 0;
elseif (current_delta_h < beta_2) && (current_delta_v < beta_1) && point_v_flag(path_result(i+1)) == 0 && path_result(i+1) ~= length(data_set)
    current_delta_h = 0;
elseif path_result(i+1) == length(data_set) && (current_delta_h < theta) && (current_delta_v < theta)
    current_delta_h = 0;
    current_delta_v = 0;
else
    fprintf('Result verification NOT passed.\n');   
    exit;
end

for i = 2:length(path_result)
    if i == length(path_result)
        flag_correct = true;
        fprintf('Running time: %d', time_to_complete);
        fprintf('Result verification passed.\n');
        fprintf('Total hoping is %d.\n',length(path_result)-2);
        fprintf('Total distance is %.f.\n',total_distance);
        break;
    end
    O_point = circle_center_point(path_result(i+1));
    i_point = [data_set(path_result(i),2),data_set(path_result(i),3),data_set(path_result(i),4)];
    j_point = [data_set(path_result(i+1),2),data_set(path_result(i+1),3),data_set(path_result(i+1),4)];
    turn_theta = acos(dot((O_point - [data_set(path_result(i),2:4)]),(O_point - cut_out_point_result(i,:))) / norm(O_point - [data_set(path_result(i),2:4)]) / norm(O_point - cut_out_point_result(i,:)));
    arc_length = turn_theta * minimum_radius;
    new_delta = (arc_length + norm([data_set(path_result(i+1),2:4)]-cut_out_point_result(i,:)))*delta;
    current_delta_h = previous_delta_h + new_delta;
    current_delta_v = previous_delta_v + new_delta;
    total_distance = total_distance + new_delta / delta;
    if (current_delta_h < alpha_2) && (current_delta_v < alpha_1) && point_v_flag(path_result(i+1)) == 1 && path_result(i+1) ~= length(data_set)
        current_delta_v = 0;
    elseif (current_delta_h < beta_2) && (current_delta_v < beta_1) && point_v_flag(path_result(i+1)) == 0 && path_result(i+1) ~= length(data_set)
        current_delta_h = 0;
    elseif path_result(i+1) == length(data_set) && (current_delta_h < theta) && (current_delta_v < theta)
        current_delta_h = 0;
        current_delta_v = 0;
    else
        fprintf('Result verification NOT passed.\n');   
        exit;
    end
end

% 绘图

j = 1;
k = 1;
for i = path_result
    x_result(j) = data_set(i,2);
    y_result(j) = data_set(i,3);
    z_result(j) = data_set(i,4);
    if k == length(path_result)
        break;
    end
    x_result(j + 1) = cut_out_point_result(k,1);
    y_result(j + 1) = cut_out_point_result(k,2);
    z_result(j + 1) = cut_out_point_result(k,3);
    j = j + 2;
    k = k + 1;
end

v_point_x = [];
v_point_y = [];
v_point_z = [];
h_point_x = [];
h_point_y = [];
h_point_z = [];
for i = 1:length(data_set)
    if point_v_flag(i) == 1;
        v_point_x = [v_point_x,data_set(i,2)];
        v_point_y = [v_point_y,data_set(i,3)];
        v_point_z = [v_point_z,data_set(i,4)];
    elseif point_v_flag(i) == 0;
        h_point_x = [h_point_x,data_set(i,2)];
        h_point_y = [h_point_y,data_set(i,3)];
        h_point_z = [h_point_z,data_set(i,4)];
    end
end

plot3(v_point_x,v_point_y,v_point_z,'g.',h_point_x,h_point_y,h_point_z,'b.')
hold on
for i = 1 : (length(path_result) * 2 - 4)
    if mod(i,2)
        plot3([x_result(i),x_result(i+1)],[y_result(i),y_result(i+1)],[z_result(i),z_result(i+1)],'*-r')
    else
        plot3([x_result(i),x_result(i+1)],[y_result(i),y_result(i+1)],[z_result(i),z_result(i+1)],'*-k')
    end
end
axis equal