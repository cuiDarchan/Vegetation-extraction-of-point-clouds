function [groundpoints,nogroundpoints]=Groundpoints_classification(Ave_m,B,threshold)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%groundpoints  ��ȡ�ĵ������
%nogroundpoints�ǵ������
%ave:          aveΪ���ű�����һ��ȡ1
%B:            BΪ����ĵ��ƾ���txt��һ��Ϊn*4��ʽ
%threshold     ��ֵ��������ȡ2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% ��������
Ave_Num=12;
ave=fix(sqrt((Ave_Num/Ave_m)))+1;
chajz=zeros(length(B),1);
tt=1;
d=1;                                                                      %���������ֵ
nd=1;                                                                     %�ǵ��������ֵ
h_threshlod=3;                                                            %�߳���ֵ��ֱ���ж�Ϊ�ǵ����
zg=0;                                                                     %z�������Ĺ�ֵ
%% ��ȡ16����������͵㣬�������Qm�����棩
% ��������B����Ϊ����n*5��ʽ,�ֱ�Ϊx,y,z,�Լ���ά��������ֵ
len=length(B);
I=zeros(len,6);
for i=1:len
    I(i,1)=B(i,1);
    I(i,2)=B(i,2);
    I(i,3)=B(i,3);
    %I(i,6)=B(i,4);
end
% д���Ԫ����
xmin=min(I(:,1));
xmax=max(I(:,1));
ymin=min(I(:,2));
ymax=max(I(:,2));
ZMIN=min(I(:,3));                                 %ȫ�����ֵ
for t=1:len
    I(t,4)=fix((I(t,1)-xmin)/ave)+1;
    I(t,5)=fix((I(t,2)-ymin)/ave)+1;
end
%% �����������ڲ����װ����Ӧ����Ԫ���ڣ���������
M=max(I(:,4));
N=max(I(:,5));
netcell=cell(M,N);                                %��M,��N����ά�����߶�ȷ��
count=zeros(M,N);
for i=1:len
    [p,~]=size(netcell{I(i,4),I(i,5)});           %��ʼʱ��pΪ0�������� ����д���Ԫ��
    netcell{I(i,4),I(i,5)}(p+1,1)=I(i,1);         %langcell{}��ָ���ð�Ԫ��Ԫ��,��()������
    netcell{I(i,4),I(i,5)}(p+1,2)=I(i,2);
    netcell{I(i,4),I(i,5)}(p+1,3)=I(i,3);
    count(I(i,4),I(i,5))=count(I(i,4),I(i,5))+1;
end
%%  ��ѡ6����ϵ�ı���
%�������
Nh=6;                                             %NhΪ��ϵ����
groundpoints=zeros(len,5);                        %Ϊ���������ڴ�ռ�
nogroundpoints=zeros(len,5);
cr=0.01;                                          %�����������0.1
theshold_Num=4;                                   %��Ѱ�����м��4�����ֵ
Qm=zeros(Nh,3);                                   %6��������Z��һ�͵�ֵ�������������
TQm=zeros(theshold_Num,3);                        %4���������ĸ�����Z���ֵ
Rmin=30;
Rmax=60;
Rf=(fix(Rmin/ave)+1)*ave;
Rl=(fix(Rmax/ave))*ave;
R_num=(Rl-Rf)/ave+1;
RMatrix=zeros(R_num,4);
R_i=1;
for R=Rf:+ave:Rl
    RMatrix(R_i,1)=R;
    RMatrix(R_i,2)=mod(M*ave,R);
    RMatrix(R_i,3)=mod(N*ave,R);
    RMatrix(R_i,4)=RMatrix(R_i,2)+RMatrix(R_i,3);
    R_i=R_i+1;
end
R_min=min(RMatrix(:,4));
[row,~]=find(RMatrix(:,4)==R_min);
avec=RMatrix(row(1),1);
fg=avec/ave;                                      %������зָ��С��������
MM=fix(M*ave/avec)+1;                             %������߶��зָ���
NN=fix(N*ave/avec)+1;
RefNum=cell(MM,NN);                               %���c0-c5����������Ԫ��
Zmi=zeros(MM,NN);                                 %Zmi��������Z�߳��ĵ㣬�Ż��ٶ�
Zpc=zeros(MM,NN);                                 %ZpcΪ��Ӧ���������ڵ���������
var_th=5;                                         %���ݲ�����ֵ
hz_th=1;                                          %ѡȡ��������ֵ
yc_Matrix=ones(MM-1,NN-1);                        %�쳣�������
yc_Matrix2=ones(MM-1,NN-1);                       %�쳣�������2
%% �����������Ѱ����
for ii=1:MM-1
    for jj=1:NN-1
        while 1
            Num=fix(fg*rand(1,1))+1;
            if Num>0.8*fg
                Num=Num-4;
            elseif Num<0.2*fg
                Num=Num+4;
            end
            %�쳣����
            if isempty(netcell{Num+(ii-1)*fg,Num+(jj-1)*fg})==1||isempty(netcell{Num+(ii-1)*fg,Num+1+(jj-1)*fg})==1||isempty(netcell{Num+(ii-1)*fg,Num+2+(jj-1)*fg})==1 ...
                    ||isempty(netcell{Num+2+(ii-1)*fg,Num+(jj-1)*fg})==1||isempty(netcell{Num+2+(ii-1)*fg,Num+1+(jj-1)*fg})==1||isempty(netcell{Num+2+(ii-1)*fg,Num+2+(jj-1)*fg})==1
                yc_Matrix(ii,jj)=yc_Matrix(ii,jj)+1;
                if yc_Matrix(ii,jj)>=10                  %�������10�λ�δ�ҵ�Num������һ�����е�Qm
                    break;
                end
                continue;
            end
            %�ҵ�6����Сֵ��
            x=1;
            for u=Num:+2:Num+2
                for l=Num:Num+2
                    netcell{u+(ii-1)*fg,l+(jj-1)*fg}=sortrows(netcell{u+(ii-1)*fg,l+(jj-1)*fg},3);
                    Qm(x,:)=netcell{u+(ii-1)*fg,l+(jj-1)*fg}(1,:);
                    x=x+1;
                end
            end
            %�б���
            if jj==1&&ii==1
                bl1=mean(Qm(:,3))-(ZMIN+10);
            elseif jj~=1
                bl1=mean(Qm(:,3))-(Zmi(ii,jj-1)+3);
            elseif jj==1&&ii~=1
                bl1=mean(Qm(:,3))-(Zmi(ii-1,jj)+3);
            end
            bl2=var(Qm(:,3))-var_th;
            yc_Matrix2(ii,jj)=yc_Matrix2(ii,jj)+1;         %�쳣�������
            if yc_Matrix2(ii,jj)>=10                       %����10��ֹͣ
                break;
            end
            if (bl1<0&&bl2<0)
                break;
            end
        end
        %��ʼ�����6����
        Center=mean(Qm);                                  %���Qm���������
        xp0=Center(1);yp0=Center(2);zp0=Center(3);
        syms a0 a1 a2 a3 a4 a5;
        for q=1:Nh
            eqn(q)=a0+a1*(Qm(q,1)-xp0)+a2*(Qm(q,2)-yp0)+a3*(Qm(q,1)-xp0).^2+a4*(Qm(q,1)-xp0)*(Qm(q,2)-yp0)+a5*(Qm(q,2)-yp0).^2-(Qm(q,3)-zp0);
        end
        [a0,a1,a2,a3,a4,a5]=solve(eqn(1),eqn(2),eqn(3),eqn(4),eqn(5),eqn(6),'a0','a1','a2','a3','a4','a5');
        c0=double(a0);c1=double(a1);c2=double(a2);c3=double(a3);c4=double(a4);c5=double(a5);
        RefNum{ii,jj}=[c0,c1,c2,c3,c4,c5];                %����õĲ�����ŵ���Ӧ������
        Zmi(ii,jj)=mean(Qm(:,3));                         %Zmi��������Z�߳��ĵ㣬�Ż��ٶ�
        Zpc(ii,jj)=zp0;                                   %ZpcΪ��������
    end
end
%3����������ֵRefNum��Zmi��Zpc
RefNum(ii+1,:)=RefNum(ii,:);RefNum(:,jj+1)=RefNum(:,jj);
Zmi(ii+1,:)=Zmi(ii,:);Zmi(:,jj+1)=Zmi(:,jj);
Zpc(ii+1,:)=Zpc(ii,:);Zpc(:,jj+1)=Zpc(:,jj);
%% ��������б�
%��һ���newpoint
newpoint=zeros(1,3);
for i=1:M
    for j=1:N
        ii1=fix(i/fg)+1;
        jj1=fix(j/fg)+1;
        [p,~]=size(netcell{i,j});
        for k=1:p
            newpoint=netcell{i,j}(k,:);
            if newpoint(3)<Zmi(ii1,jj1)+h_threshlod;
                %һ����Χ�ڵ��������
                xp=newpoint(1)+cr*(rand(1,1)*2-1);
                yp=newpoint(2)+cr*(rand(1,1)*2-1);
                zp=newpoint(3);
                zg=c0+c1*(newpoint(1)-xp)+c2*(newpoint(2)-yp)+c3*(newpoint(1)-xp).^2+c4*(newpoint(1)-xp)*(newpoint(2)-yp)+c5*(newpoint(2)-yp).^2+Zpc(ii1,jj1);
                cha=double(zg-zp);                                                 %chaΪ�ӽ�0����
                chajz(tt,1)=cha;
                tt=tt+1;
                if abs(cha)<threshold
                    groundpoints(d,1:3)=newpoint;
                    d=d+1;
                else
                    nogroundpoints(nd,1:3)=newpoint;
                    nd=nd+1;
                end
            else
                nogroundpoints(nd,1:3)=newpoint;
                nd=nd+1;
            end
        end
    end
end
groundpoints=groundpoints(1:d-1,:);
nogroundpoints=nogroundpoints(1:nd-1,:);
end
