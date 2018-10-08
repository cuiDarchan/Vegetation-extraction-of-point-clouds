function buildpoints=Buildingpoints_classification(ave,B,threshold)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%buildpoints   获取的建筑物点云
%ave:          ave为缩放比例，一般取3  
%B:            B为输入的点云矩阵，txt下一般为n*4格式
%threshold     比例阈值，经验上取0.9
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 第一步骤统一基本操作
tall=25;
low=3;
[netcell,I,count]=Baseprocessing(ave,B,tall,low); 
%% 重新遍历，去除建筑物顶
M=max(I(:,5));
N=max(I(:,6));
buildpoints=cell(M,N);
zmin=min(I(:,3));
zmax=max(I(:,3));
SY=zeros(M,N);
for o=1:M
    for q=1:N
        if isempty(netcell{o,q})~=1
            zmax=mean(netcell{o,q}(:,3));                  %zmax贴近房顶层的高程
            %[k,~]=size(netcell{o,q});                     %k求元胞内点行数，即点的个数
            A=netcell{o,q}(:,3);
            j=length(find(A>zmin+3&A>zmax-0.6));           %j为zmax 浮动1m以内的点个数，超过0.7，再加以判断逐点删除
            c=j/count(o,q);                                %count(o,q)=k,为单位二维格网内点的个数
            SY(o,q)=c;
        end                                                      
    end
end

%带上边界，当周围格网比例为1时，找到边界并标记为2
for o=2:M-1
    for q=2:N-1
        if isempty(netcell{o,q})~=1
            if  SY(o-1,q-1)==1||SY(o,q-1)==1||SY(o+1,q-1)==1||SY(o,q-1)==1||SY(o,q+1)==1||SY(o-1,q+1)==1||SY(o,q+1)==1||SY(o+1,q+1)==1                                      
                  SY(o,q)=2;                               % 2是任意起的作为标记使用             
            end
        end
    end
end

%将标记改为1，去掉高比例的顶部
for o=2:M-1
    for q=2:N-1
        if isempty(netcell{o,q})~=1
            if SY(o,q)==2
               SY(o,q)=1;
            end
            b=1;                                            %不为空的话，从第一个开始写
            zmax=mean(netcell{o,q}(:,3));                   %zmax贴近房顶层的高程
            if SY(o,q)>threshold
              for x=1:count(o,q)                            %比例在0.9以上的 逐点判断
              a=netcell{o,q}(x,3);
               if a>zmax-2&&a>zmin+2
                buildpoints{o,q}(b,:)=netcell{o,q}(x,:); 
                %count(o,q)=count(o,q)-1;
                b=b+1;
               end              
              end                                     
            end               
        end
    end
end
end

