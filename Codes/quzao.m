function I = quzao(I,xmin,ymin,zmin,len,ave)
%% 建立三维格网
for t=1:len
    I(t,5)=fix((I(t,1)-xmin)/ave)+1;
    I(t,6)=fix((I(t,2)-ymin)/ave)+1;
    I(t,7)=fix((I(t,3)-zmin)/ave)+1;
end
%% 将各个格网内部点封装到相应格网元胞内，方便索引
landcell=cell(max(I(:,5)),max(I(:,6)),max(I(:,7)));    %长,宽，高，三维格网尺度确定
count=zeros(max(I(:,5)),max(I(:,6)),max(I(:,7)));               
for i=1:length(I)                                      %开始时K(1,1)是0,随着i增加,每个胞元内数据逐渐增大
    [p,~]=size(landcell{I(i,5),I(i,6),I(i,7)});        %将长宽高数据写入胞元内,p初始为0
    landcell{I(i,5),I(i,6),I(i,7)}(p+1,1)=I(i,1);            %landcell{}是指引用胞元内元素,与()有区别
    landcell{I(i,5),I(i,6),I(i,7)}(p+1,2)=I(i,2);
    landcell{I(i,5),I(i,6),I(i,7)}(p+1,3)=I(i,3);
    count(I(i,5),I(i,6),I(i,7))=count(I(i,5),I(i,6),I(i,7))+1;
end
%遍历每个胞元，去除噪点
for i=1:max(I(:,5))
    for j=1:max(I(:,6))
        for k=1:max(I(:,7))
        if count(i,j,k)<=3
          landcell{i,j,k}=[];       
        end
        end
    end
end
% 重新写入I矩阵
u=1;
C=zeros(9917096,3);
for i=1:max(I(:,5))
    for j=1:max(I(:,6))
        for k=1:max(I(:,7))
        if isempty(landcell{i,j,k})~=1
          W=size(landcell{i,j,k});
        for w=1:W(1,1)
            C(u,1)=landcell{i,j,k}(w,1);
            C(u,2)=landcell{i,j,k}(w,2);
            C(u,3)=landcell{i,j,k}(w,3);
            u=u+1;        
        end
        end
        end
    end
end
%去除零行
C(u:9917096,:)=[];
I=C;
end

