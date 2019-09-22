j=1;
for i = path_result
    x_result(j) = data_set(i,2);
    y_result(j) = data_set(i,3);
    z_result(j) = data_set(i,4);
    j = j + 1;
end
plot3(v_point_x,v_point_y,v_point_z,'g.',h_point_x,h_point_y,h_point_z,'b.')
hold on


j = 1;
k = 1;
for i = path_result
    x_result(j) = data_set(i,2);
    y_result(j) = data_set(i,3);
    z_result(j) = data_set(i,4);
    if k == length(path_result) || k == 1 
        j = j + 1;
        k = k + 1;
        continue;
    end
    x_result(j + 1) = cut_out_point_result(k-1,1);
    y_result(j + 1) = cut_out_point_result(k-1,2);
    z_result(j + 1) = cut_out_point_result(k-1,3);
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
plot3(x_result,y_result,z_result,'*k',cut_out_point_result(:,1),cut_out_point_result(:,2),cut_out_point_result(:,3),'*r')

for i = 1 : (length(path_result) * 2 - 2)
    if mod(i,2)
        plot3([x_result(i),x_result(i+1)],[y_result(i),y_result(i+1)],[z_result(i),z_result(i+1)],'-k')
        
    else
        plot3([x_result(i),x_result(i+1)],[y_result(i),y_result(i+1)],[z_result(i),z_result(i+1)],'-r')
        
    end
end


axis equal
set(gca,'color',[245,245,245]/255)
legend('��ֱУ����','ˮƽУ����','�滮·��-У����','�滮·��-Բ���г���','�滮·��-ֱ�߶�','�滮·��-Բ����')
