function [netcell,I,count]=Baseprocessing(ave,B,tall,low)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%netcell:   将B点云数据写入元胞内，并进行了去除极高点和极低点的操作
%I          原点云数据矩阵基础上，建立索引坐标的矩阵，如坐标值{I(2,5),I(2,6)}
%count      点云元胞内点个数的矩阵
%ave:       ave为缩放比例，一般取3  
%B:         B为输入的点云矩阵，txt下一般为n*4格式
%tall       极高点与地面点的距离，经验上取25m
%low        极低点与地面点的距离，经验上取3m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 加载数据 变为正常n*4格式,分别为x,y,z,以及强度
len=length(B);
I=zeros(len,6);
for i=1:len
    I(i,1)=B(i,1);
    I(i,2)=B(i,2);
    I(i,3)=B(i,3);
end
% 找到x,y,z最大值最小值
xmin=min(I(:,1));
xmax=max(I(:,1));
ymin=min(I(:,2));
ymax=max(I(:,2));
zmi=max(I(:,3));
zmin=min(I(:,3));
%% 建立二维格网,ave为缩放比例，一般取3
for t=1:len
    I(t,5)=fix((I(t,1)-xmin)/ave)+1;
    I(t,6)=fix((I(t,2)-ymin)/ave)+1;
end
%% 将各个格网内部点封装到相应格网元胞内，方便索引
netcell=cell(max(I(:,5)),max(I(:,6)));            %长,宽，二维格网尺度确定
count=zeros(max(I(:,5)),max(I(:,6)));               
for i=1:len                                       %开始时K(1,1)是0,随着i增加,每个胞元内数据逐渐增大
    [p,~]=size(netcell{I(i,5),I(i,6)});           %将长宽高数据写入胞元内
    netcell{I(i,5),I(i,6)}(p+1,1)=I(i,1);         %langcell{}是指引用胞元内元素,与()有区别
    netcell{I(i,5),I(i,6)}(p+1,2)=I(i,2);
    netcell{I(i,5),I(i,6)}(p+1,3)=I(i,3);
    count(I(i,5),I(i,6))=count(I(i,5),I(i,6))+1;
end
%% 遍历二维格网，去除极高点和极低点
M=max(I(:,5));
N=max(I(:,6));
for m=1:M
    for n=1:N
       if isempty(netcell{m,n})~=1
         if zmi>min(netcell{m,n}(:,3))                                        %zmi逐次的最小值（未去低点前）
          zmi=min(netcell{m,n}(:,3));
        end
           are=mean(netcell{m,n}(:,3));                                       %are为均值
        while  (max(netcell{m,n}(:,3))-zmi>tall)                                %最大值与最小值之差超过20m，去掉高点
            [h,~]=find(netcell{m,n}(:,3)==max(netcell{m,n}(:,3)));            %找到最大值所在行，并删除一个点
            netcell{m,n}(h,:)=[];
            count(m,n)=count(m,n)-length(h);
        end         
         while  (are-min(netcell{m,n}(:,3))>low)
           [g,~]=find(netcell{m,n}(:,3)==min(netcell{m,n}(:,3)));             %找到最小值所在行，并删除一个点或者多个点（可能存在多个相同最小值）
           netcell{m,n}(g,:)=[]; 
           count(m,n)=count(m,n)-length(g);
         end
        if zmin>min(netcell{m,n}(:,3))                                        %求去掉低点后的整个地面格网内最低点zmin
          zmin=min(netcell{m,n}(:,3));
        end
       end
    end
end
end

