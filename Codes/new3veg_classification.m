function vegetation=new3veg_classification(ave,B)
%%加载数据 变为正常n*4格式,分别为x,y,z,以及强度
% B=load('pointCloud_terrain_000.txt');
%Bb=lasdata('B.las');
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
%% 第一步，执行去噪程序,数据最后写成txt形式矩阵I
 ave=3;
 I = quzao(I,xmin,ymin,zmin,len,ave);
 len2=length(I);
%% 建立二维格网,去除高点和低点，ave为缩放比例，一般取3
for t=1:len2
    I(t,5)=fix((I(t,1)-min(I(:,1)))/ave)+1;
    I(t,6)=fix((I(t,2)-min(I(:,2)))/ave)+1;
end
%% 将各个格网内部点封装到相应格网元胞内，方便索引
landcell=cell(max(I(:,5)),max(I(:,6)));    %长,宽，二维格网尺度确定
count=zeros(max(I(:,5)),max(I(:,6)));               
for i=1:len2                                      %开始时K(1,1)是0,随着i增加,每个胞元内数据逐渐增大
    [p,~]=size(landcell{I(i,5),I(i,6)});        %将长宽高数据写入胞元内
    landcell{I(i,5),I(i,6)}(p+1,1)=I(i,1);            %langcell{}是指引用胞元内元素,与()有区别
    landcell{I(i,5),I(i,6)}(p+1,2)=I(i,2);
    landcell{I(i,5),I(i,6)}(p+1,3)=I(i,3);
    count(I(i,5),I(i,6))=count(I(i,5),I(i,6))+1;
end
%% 遍历二维格网，去除高点和低点
for m=1:max(I(:,5))
    for n=1:max(I(:,6))
       if isempty(landcell{m,n})~=1
         if zmi>min(landcell{m,n}(:,3))                                        %zmi逐次的最小值（未去低点前）
          zmi=min(landcell{m,n}(:,3));
        end
           are=mean(landcell{m,n}(:,3));                                   %are为均值
        while  (max(landcell{m,n}(:,3))-zmi>25)                            %最大值与最小值之差超过20m，去掉高点
            [h,~]=find(landcell{m,n}(:,3)==max(landcell{m,n}(:,3)));       %找到最大值所在行，并删除一个点
            landcell{m,n}(h,:)=[];
            count(m,n)=count(m,n)-length(h);
        end         
         while  (are-min(landcell{m,n}(:,3))>3)
           [g,~]=find(landcell{m,n}(:,3)==min(landcell{m,n}(:,3)));        %找到最小值所在行，并删除一个点或者多个点（可能存在多个相同最小值）
           landcell{m,n}(g,:)=[]; 
           count(m,n)=count(m,n)-length(g);
         end
        if zmin>min(landcell{m,n}(:,3))                                        %求去掉低点后的整个地面格网内最低点zmin
          zmin=min(landcell{m,n}(:,3));
        end
       end
    end
end
%% 重新遍历，去除建筑物顶
SY=zeros(max(I(:,5)),max(I(:,6)));
for o=1:max(I(:,5))
    for q=1:max(I(:,6))
        if isempty(landcell{o,q})~=1
            zmax=mean(landcell{o,q}(:,3));               %zmax贴近房顶层的高程
            %[k,~]=size(landcell{o,q});                     %k求元胞内点行数，即点的个数
            A=landcell{o,q}(:,3);
            j=length(find(A>zmin+3&A>zmax-0.6));           %j为zmax 浮动1m以内的点个数，超过0.7，再加以判断逐点删除
            c=j/count(o,q);                                     %count(o,q)=k,为单位二维格网内点的个数
            SY(o,q)=c;
        end                                                      
    end
end

%带上边界，当周围格网比例为1时，找到边界并标记为2
for o=2:max(I(:,5))-1
    for q=2:max(I(:,6))-1
        if isempty(landcell{o,q})~=1
                if  SY(o-1,q-1)==1||SY(o,q-1)==1||SY(o+1,q-1)==1||SY(o,q-1)==1||SY(o,q+1)==1||SY(o-1,q+1)==1||SY(o,q+1)==1||SY(o+1,q+1)==1                                      
                  SY(o,q)=2;     % 2是任意起的作为标记使用             
                end
        end
    end
end
%将标记改为1，去掉高比例的顶部
for o=2:max(I(:,5))-1
    for q=2:max(I(:,6))-1
        if isempty(landcell{o,q})~=1
            if SY(o,q)==2
                SY(o,q)=1;
            end 
            zmax=mean(landcell{o,q}(:,3));               %zmax贴近房顶层的高程
            if SY(o,q)>0.9
              for x=1:count(o,q)                                     %比例在0.8以上的 逐点判断
              a=landcell{o,q}(x,3);
               if a>zmax-2&&a>zmin+2
                landcell{o,q}(x,:)=0; 
                count(o,q)=count(o,q)-1;
               end              
              end                          
              [l,~]=find(landcell{o,q}(:,1)==0); 
              landcell{o,q}(l,:)=[];              
            end               
        end
    end
end
%% 利用均方差去除地面
% OO=zeros(max(I(:,5)),max(I(:,6)));
for e=1:max(I(:,5))
    for w=1:max(I(:,6))
        if isempty(landcell{e,w})~=1
           D=landcell{e,w}(:,3);
           Zm=min(D);           %Zm为单位块内高程最小值
            if Zm<zmin+3
             [s,~]=find(D<Zm+2);                    
             V=zeros(1,length(s));                        %V为高程满足 Zm+2的所有z值集合
             for z=1:length(s)
               V(1,z)=landcell{e,w}(s(z,1),3);
             end
             oo=std2(V);              %oo为z值集合均方差，若小于阈值，则判断为地形，需要去掉
%              OO(e,w)=oo;             
             if oo<0.1
               landcell{e,w}(s,:)=[];
               count(e,w)=count(e,w)-length(s);
             end
            end    
        end
    end
end
%% 去除车辆
% ZJZ=zeros(max(I(:,5)),max(I(:,6)));
for oa=1:max(I(:,5))
    for qa=1:max(I(:,6))
      if isempty(landcell{oa,qa})~=1
         zjz=mean(landcell{oa,qa}(:,3));
%          ZJZ(oa,qa)=zjz-74.3;
         if zjz<zmin+2
             landcell{oa,qa}=[]; 
             count(oa,qa)=0;
         end
      end
    end
end
% %% 去除阶跃值的残余顽固建筑物墙壁（周围包含较多车）
% % FF=zeros(max(I(:,5)),max(I(:,6)));
% for  jj=1:max(I(:,5))
%     for kk=1:max(I(:,6)) 
%         if isempty(landcell{jj,kk})~=1
%         E=landcell{jj,kk};
%         G=sort(E(:,3));              %对高程值进行排序，做累减运算
%         F=zeros(1,size(E,1)-1);
%         for pp=2:size(E,1)
%            F(1,pp-1)=G(pp,1)-G(pp-1,1);         %累减运算并赋值,得到F矩阵,墙壁出现高程阶跃3m以上情况    
%         end                        
%         if length(find(F>3))>=1             
%           landcell{jj,kk}=[];
%         end
%         end
%         end
u=100;
while (u>2)
[vegetation,count,u]=diedsc(landcell,I,count);
landcell=vegetation;
end
end
