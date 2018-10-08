function carpoints=Carpoints_classification(ave,B,hcar)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%carpoints  获取的车辆点云
%ave:       ave为缩放比例，一般取3  
%B:         B为输入的点云矩阵，txt下一般为n*4格式
%hcar       车辆比地面高出的一般高度，经验是2.5m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 第一步骤统一基本操作
tall=25;
low=3;
[netcell,I]=Baseprocessing(ave,B,tall,low);    
%% 获取车辆点云
M=max(I(:,5));
N=max(I(:,6));
dmin=min(I(:,3));
carpoints=cell(M,N);
for i=1:M
    for j=1:N
      if isempty(netcell{i,j})~=1
         car_mean=mean(netcell{i,j}(:,3));            %car_mean为二维元胞平均值
         if car_mean<dmin+hcar
             carpoints{i,j}=netcell{i,j}; 
         end
      end
    end
end
end

