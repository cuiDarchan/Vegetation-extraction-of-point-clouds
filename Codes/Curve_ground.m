function  [groundpoints,nogroundpoints]= Curve_ground(ave,B,threshold)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%groundpoints  获取的地面点云
%nogroundpoints非地面点云
%ave:          ave为缩放比例，一般取3
%B:            B为输入的点云矩阵，txt下一般为n*4格式
%threshold     均方差阈值，经验上取0.1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%debug变量，可删除
B=load('origin.txt');
ave=1;
threshold=1;
chajz=zeros(length(B),1);
tt=1;
%% 变量定义
d=1;                                                                      %地面点索引值
nd=1;                                                                     %非地面点索引值
dz=1;                                                                     %与d进行大小比较，判断是否采用旧的拟合曲面
zg=0;                                                                     %z相对坐标的估值
%% 获取16个格网内最低点，存入矩阵Qm（曲面）
% 加载数据B，变为正常n*5格式,分别为x,y,z,以及二维格网坐标值
len=length(B);
I=zeros(len,5);
for i=1:len
    I(i,1)=B(i,1);
    I(i,2)=B(i,2);
    I(i,3)=B(i,3);
end
% 写入胞元数据
xmin=min(I(:,1));
ymin=min(I(:,2));
for t=1:len
    I(t,4)=fix((I(t,1)-xmin)/ave)+1;
    I(t,5)=fix((I(t,2)-ymin)/ave)+1;
end
%% 将各个格网内部点封装到相应格网元胞内，方便索引
M=max(I(:,4));
N=max(I(:,5));
netcell=cell(M,N);                                %长M,宽N，二维格网尺度确定
count=zeros(M,N);
for i=1:len
    [p,~]=size(netcell{I(i,4),I(i,5)});           %初始时，p为0，将长宽 数据写入胞元内
    netcell{I(i,4),I(i,5)}(p+1,1)=I(i,1);         %langcell{}是指引用胞元内元素,与()有区别
    netcell{I(i,4),I(i,5)}(p+1,2)=I(i,2);
    netcell{I(i,4),I(i,5)}(p+1,3)=I(i,3);
    count(I(i,4),I(i,5))=count(I(i,4),I(i,5))+1;
end
%%  挑选6个拟合点的变量
Nh=6;                                             %Nh为拟合点个数
n=2;                                              %n为边长，初始选取的格网数目n*n
Cs=zeros(2*Nh,3);                                 %Cs为初始的12个点的矩阵
Qm=zeros(10,3);                                   %Qm为初始10个曲面拟合点的矩阵
q=1;
qmf=((2*Nh)-10)/2+1;                              %Qm中拟合点初始索引
qml=2*Nh-1;                                       %Qm中拟合点末尾索引
groundpoints=zeros(len,3);                        %为地面点分配内存空间
nogroundpoints=zeros(len,3);
cr=0.3;                                           %中心随机因子0.3
% % 准备初始4个方格内的12个数据,每个格网挑选Z最低的3个数据
% for i=1:n
%     %for j=1:n
%         [p,~]=size(netcell{1,i});
%         P=zeros(p,3);                             %P为过渡矩阵，存放排序后的矩阵
%         P=sortrows(netcell{1,i},3);
%         Cs(q:q+Nh-1,:)=P(1:Nh,:);                     %挑选出后6个Z最低值
%         q=q+Nh;
%     %end
% end
% Cs=sortrows(Cs,3);
% Qm=Cs(qmf:qml,:);
Qm=load('NewR.txt');
%初始化求解6参数
Center=mean(Qm);                                     %求解Qm矩阵的中心
xp0=Center(1);yp0=Center(2);zp0=Center(3);
syms a0 a1 a2 a3 a4 a5;
for q=1:Nh
eqn(q)=a0+a1*(Qm(q,1)-xp0)+a2*(Qm(q,2)-yp0)+a3*(Qm(q,1)-xp0).^2+a4*(Qm(q,1)-xp0)*(Qm(q,2)-yp0)+a5*(Qm(q,2)-yp0).^2-(Qm(q,3)-zp0);
end
[a0,a1,a2,a3,a4,a5]=solve(eqn(1),eqn(2),eqn(3),eqn(4),eqn(5),eqn(6),'a0','a1','a2','a3','a4','a5');
c0=double(a0);c1=double(a1);c2=double(a2);c3=double(a3);c4=double(a4);c5=double(a5);
zmin=mean(Qm(:,3));                                  %zmin用来过滤Z高出的点，优化速度
%% 曲面拟合判别
%逐一添加newpoint
newpoint=zeros(1,3);
for i=1:M
    if mod(i,2)==0
        for r=N:-1:1
            [p,~]=size(netcell{i,r});
            for k=1:p
                newpoint=netcell{i,r}(k,:);
                if newpoint(3)<zmin+5
                    %一定范围内的随机中心
                    xp=newpoint(1)+cr*(rand(1,1)*2-1);yp=newpoint(2)+cr*(rand(1,1)*2-1);zp=newpoint(3);
                    if dz~=d                                                       %dz用来控制是否采用旧的拟合曲面
%                         %初始化，求解6个参数
%                          Center=(Nh*mean(Qm)+newpoint)/(Nh+1);                      %求解Qm矩阵的中心
%                          xp=Center(1);yp=Center(2);zp=Center(3);
%                         syms a0 a1 a2 a3 a4 a5;
%                         for q=1:Nh
%                             eqn(q)=a0+a1*(Qm(q,1)-xp)+a2*(Qm(q,2)-yp)+a3*(Qm(q,1)-xp).^2+a4*(Qm(q,1)-xp)*(Qm(q,2)-yp)+a5*(Qm(q,2)-yp).^2-(Qm(q,3)-zp);
%                         end
%                         [a0,a1,a2,a3,a4,a5]=solve(eqn(1),eqn(2),eqn(3),eqn(4),eqn(5),eqn(6),'a0','a1','a2','a3','a4','a5');
%                         %判断新加入点是否为地面点
%                         c0=double(a0);c1=double(a1);c2=double(a2);c3=double(a3);c4=double(a4);c5=double(a5);
                        zg=c0+c1*(newpoint(1)-xp)+c2*(newpoint(2)-yp)+c3*(newpoint(1)-xp).^2+c4*(newpoint(1)-xp)*(newpoint(2)-yp)+c5*(newpoint(2)-yp).^2+zp0;
                    else                      
                        %采用上一轮中的拟合曲面参数，移动曲面中心
%                         Center=(Nh*mean(Qm)+newpoint)/(Nh+1);                       %求解Qm矩阵的中心
%                         xp=Center(1);yp=Center(2);zp=Center(3);
                        zg=c0+c1*(newpoint(1)-xp)+c2*(newpoint(2)-yp)+c3*(newpoint(1)-xp).^2+c4*(newpoint(1)-xp)*(newpoint(2)-yp)+c5*(newpoint(2)-yp).^2+zp0;
                    end
                    cha=double(zg-zp);                                                 %cha为接近0的数
                    chajz(tt,1)=cha;
                    tt=tt+1;
                    if abs(cha)<threshold
                        groundpoints(d,:)=newpoint;
                        dz=d;
                        d=d+1;
%                         %将新点加入到方程式，并剔除一个最远点，每次替换第6个
%                         for b=2:Nh
%                             Qm(b-1,:)=Qm(b,:);
%                         end
%                         Qm(b,:)=newpoint;
                    else
                        nogroundpoints(nd,:)=newpoint;
                        nd=nd+1;
                        dz=d;
                    end
                else    
                nogroundpoints(nd,:)=newpoint;
                nd=nd+1;
                dz=d;
                end
            end
        end
        
    else if mod(i,2)~=0
            for j=1:N
                [p,~]=size(netcell{i,j});
                for k=1:p
                    newpoint=netcell{i,j}(k,:);
                    if newpoint(3)<zmin+5
                        %一定范围内的随机中心坐标xp，yp，zp
                        xp=newpoint(1)+cr*(rand(1,1)*2-1);yp=newpoint(2)+cr*(rand(1,1)*2-1);zp=newpoint(3);
                        if dz~=d                                                        %dz用来控制是否采用旧的拟合曲面
                            %初始化，求解6个参数
%                             Center=(Nh*mean(Qm)+newpoint)/(Nh+1);                     %求解Qm矩阵的中心
%                              xp=Center(1);yp=Center(2);zp=Center(3);
%                             syms a0 a1 a2 a3 a4 a5;
%                             for q=1:Nh
%                                 eqn(q)=a0+a1*(Qm(q,1)-xp)+a2*(Qm(q,2)-yp)+a3*(Qm(q,1)-xp).^2+a4*(Qm(q,1)-xp)*(Qm(q,2)-yp)+a5*(Qm(q,2)-yp).^2-(Qm(q,3)-zp);
%                             end
%                             [a0,a1,a2,a3,a4,a5]=solve(eqn(1),eqn(2),eqn(3),eqn(4),eqn(5),eqn(6),'a0','a1','a2','a3','a4','a5');
%                             %判断新加入点是否为地面点
%                             c0=double(a0);c1=double(a1);c2=double(a2);c3=double(a3);c4=double(a4);c5=double(a5);
                            zg=c0+c1*(newpoint(1)-xp)+c2*(newpoint(2)-yp)+c3*(newpoint(1)-xp).^2+c4*(newpoint(1)-xp)*(newpoint(2)-yp)+c5*(newpoint(2)-yp).^2+zp0;
                        else
                            %采用上一轮中的拟合曲面参数，移动曲面中心
%                             Center=(Nh*mean(Qm)+newpoint)/(Nh+1);                       %求解Qm矩阵的中心
%                             xp=Center(1);yp=Center(2);zp=Center(3);
                            zg=c0+c1*(newpoint(1)-xp)+c2*(newpoint(2)-yp)+c3*(newpoint(1)-xp).^2+c4*(newpoint(1)-xp)*(newpoint(2)-yp)+c5*(newpoint(2)-yp).^2+zp0;
                        end
                        cha=double(zg-zp);
                        chajz(tt,1)=cha;
                        tt=tt+1;
                        if abs(cha)<threshold
                            groundpoints(d,:)=newpoint;
                            dz=d;
                            d=d+1;
%                             %将新点加入到方程式，并剔除一个最远点，每次替换第6个
%                             for b=2:Nh
%                                 Qm(b-1,:)=Qm(b,:);
%                             end
%                             Qm(b,:)=newpoint;
                           if newpoint>75
                           end
                        else
                            nogroundpoints(nd,:)=newpoint;
                            nd=nd+1;
                            dz=d;
                            if newpoint(1,3)<75
                            end
                        end
                    else
                    nogroundpoints(nd,:)=newpoint;
                    nd=nd+1;
                    dz=d; 
                    end
                end
            end
        end
    end
end
groundpoints=groundpoints(1:d-1,:);
nogroundpoints=nogroundpoints(1:nd-1,:);
%AAA=min(nogroundpoints(:,3));
end

