function  [groundpoints,nogroundpoints]= Curve_ground(ave,B,threshold)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%groundpoints  ��ȡ�ĵ������
%nogroundpoints�ǵ������
%ave:          aveΪ���ű�����һ��ȡ3
%B:            BΪ����ĵ��ƾ���txt��һ��Ϊn*4��ʽ
%threshold     ��������ֵ��������ȡ0.1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%debug��������ɾ��
B=load('origin.txt');
ave=1;
threshold=1;
chajz=zeros(length(B),1);
tt=1;
%% ��������
d=1;                                                                      %���������ֵ
nd=1;                                                                     %�ǵ��������ֵ
dz=1;                                                                     %��d���д�С�Ƚϣ��ж��Ƿ���þɵ��������
zg=0;                                                                     %z�������Ĺ�ֵ
%% ��ȡ16����������͵㣬�������Qm�����棩
% ��������B����Ϊ����n*5��ʽ,�ֱ�Ϊx,y,z,�Լ���ά��������ֵ
len=length(B);
I=zeros(len,5);
for i=1:len
    I(i,1)=B(i,1);
    I(i,2)=B(i,2);
    I(i,3)=B(i,3);
end
% д���Ԫ����
xmin=min(I(:,1));
ymin=min(I(:,2));
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
Nh=6;                                             %NhΪ��ϵ����
n=2;                                              %nΪ�߳�����ʼѡȡ�ĸ�����Ŀn*n
Cs=zeros(2*Nh,3);                                 %CsΪ��ʼ��12����ľ���
Qm=zeros(10,3);                                   %QmΪ��ʼ10��������ϵ�ľ���
q=1;
qmf=((2*Nh)-10)/2+1;                              %Qm����ϵ��ʼ����
qml=2*Nh-1;                                       %Qm����ϵ�ĩβ����
groundpoints=zeros(len,3);                        %Ϊ���������ڴ�ռ�
nogroundpoints=zeros(len,3);
cr=0.3;                                           %�����������0.3
% % ׼����ʼ4�������ڵ�12������,ÿ��������ѡZ��͵�3������
% for i=1:n
%     %for j=1:n
%         [p,~]=size(netcell{1,i});
%         P=zeros(p,3);                             %PΪ���ɾ��󣬴�������ľ���
%         P=sortrows(netcell{1,i},3);
%         Cs(q:q+Nh-1,:)=P(1:Nh,:);                     %��ѡ����6��Z���ֵ
%         q=q+Nh;
%     %end
% end
% Cs=sortrows(Cs,3);
% Qm=Cs(qmf:qml,:);
Qm=load('NewR.txt');
%��ʼ�����6����
Center=mean(Qm);                                     %���Qm���������
xp0=Center(1);yp0=Center(2);zp0=Center(3);
syms a0 a1 a2 a3 a4 a5;
for q=1:Nh
eqn(q)=a0+a1*(Qm(q,1)-xp0)+a2*(Qm(q,2)-yp0)+a3*(Qm(q,1)-xp0).^2+a4*(Qm(q,1)-xp0)*(Qm(q,2)-yp0)+a5*(Qm(q,2)-yp0).^2-(Qm(q,3)-zp0);
end
[a0,a1,a2,a3,a4,a5]=solve(eqn(1),eqn(2),eqn(3),eqn(4),eqn(5),eqn(6),'a0','a1','a2','a3','a4','a5');
c0=double(a0);c1=double(a1);c2=double(a2);c3=double(a3);c4=double(a4);c5=double(a5);
zmin=mean(Qm(:,3));                                  %zmin��������Z�߳��ĵ㣬�Ż��ٶ�
%% ��������б�
%��һ���newpoint
newpoint=zeros(1,3);
for i=1:M
    if mod(i,2)==0
        for r=N:-1:1
            [p,~]=size(netcell{i,r});
            for k=1:p
                newpoint=netcell{i,r}(k,:);
                if newpoint(3)<zmin+5
                    %һ����Χ�ڵ��������
                    xp=newpoint(1)+cr*(rand(1,1)*2-1);yp=newpoint(2)+cr*(rand(1,1)*2-1);zp=newpoint(3);
                    if dz~=d                                                       %dz���������Ƿ���þɵ��������
%                         %��ʼ�������6������
%                          Center=(Nh*mean(Qm)+newpoint)/(Nh+1);                      %���Qm���������
%                          xp=Center(1);yp=Center(2);zp=Center(3);
%                         syms a0 a1 a2 a3 a4 a5;
%                         for q=1:Nh
%                             eqn(q)=a0+a1*(Qm(q,1)-xp)+a2*(Qm(q,2)-yp)+a3*(Qm(q,1)-xp).^2+a4*(Qm(q,1)-xp)*(Qm(q,2)-yp)+a5*(Qm(q,2)-yp).^2-(Qm(q,3)-zp);
%                         end
%                         [a0,a1,a2,a3,a4,a5]=solve(eqn(1),eqn(2),eqn(3),eqn(4),eqn(5),eqn(6),'a0','a1','a2','a3','a4','a5');
%                         %�ж��¼�����Ƿ�Ϊ�����
%                         c0=double(a0);c1=double(a1);c2=double(a2);c3=double(a3);c4=double(a4);c5=double(a5);
                        zg=c0+c1*(newpoint(1)-xp)+c2*(newpoint(2)-yp)+c3*(newpoint(1)-xp).^2+c4*(newpoint(1)-xp)*(newpoint(2)-yp)+c5*(newpoint(2)-yp).^2+zp0;
                    else                      
                        %������һ���е��������������ƶ���������
%                         Center=(Nh*mean(Qm)+newpoint)/(Nh+1);                       %���Qm���������
%                         xp=Center(1);yp=Center(2);zp=Center(3);
                        zg=c0+c1*(newpoint(1)-xp)+c2*(newpoint(2)-yp)+c3*(newpoint(1)-xp).^2+c4*(newpoint(1)-xp)*(newpoint(2)-yp)+c5*(newpoint(2)-yp).^2+zp0;
                    end
                    cha=double(zg-zp);                                                 %chaΪ�ӽ�0����
                    chajz(tt,1)=cha;
                    tt=tt+1;
                    if abs(cha)<threshold
                        groundpoints(d,:)=newpoint;
                        dz=d;
                        d=d+1;
%                         %���µ���뵽����ʽ�����޳�һ����Զ�㣬ÿ���滻��6��
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
                        %һ����Χ�ڵ������������xp��yp��zp
                        xp=newpoint(1)+cr*(rand(1,1)*2-1);yp=newpoint(2)+cr*(rand(1,1)*2-1);zp=newpoint(3);
                        if dz~=d                                                        %dz���������Ƿ���þɵ��������
                            %��ʼ�������6������
%                             Center=(Nh*mean(Qm)+newpoint)/(Nh+1);                     %���Qm���������
%                              xp=Center(1);yp=Center(2);zp=Center(3);
%                             syms a0 a1 a2 a3 a4 a5;
%                             for q=1:Nh
%                                 eqn(q)=a0+a1*(Qm(q,1)-xp)+a2*(Qm(q,2)-yp)+a3*(Qm(q,1)-xp).^2+a4*(Qm(q,1)-xp)*(Qm(q,2)-yp)+a5*(Qm(q,2)-yp).^2-(Qm(q,3)-zp);
%                             end
%                             [a0,a1,a2,a3,a4,a5]=solve(eqn(1),eqn(2),eqn(3),eqn(4),eqn(5),eqn(6),'a0','a1','a2','a3','a4','a5');
%                             %�ж��¼�����Ƿ�Ϊ�����
%                             c0=double(a0);c1=double(a1);c2=double(a2);c3=double(a3);c4=double(a4);c5=double(a5);
                            zg=c0+c1*(newpoint(1)-xp)+c2*(newpoint(2)-yp)+c3*(newpoint(1)-xp).^2+c4*(newpoint(1)-xp)*(newpoint(2)-yp)+c5*(newpoint(2)-yp).^2+zp0;
                        else
                            %������һ���е��������������ƶ���������
%                             Center=(Nh*mean(Qm)+newpoint)/(Nh+1);                       %���Qm���������
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
%                             %���µ���뵽����ʽ�����޳�һ����Զ�㣬ÿ���滻��6��
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

