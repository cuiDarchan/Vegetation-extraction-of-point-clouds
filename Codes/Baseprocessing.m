function [netcell,I,count]=Baseprocessing(ave,B,tall,low)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%netcell:   ��B��������д��Ԫ���ڣ���������ȥ�����ߵ�ͼ��͵�Ĳ���
%I          ԭ�������ݾ�������ϣ�������������ľ���������ֵ{I(2,5),I(2,6)}
%count      ����Ԫ���ڵ�����ľ���
%ave:       aveΪ���ű�����һ��ȡ3  
%B:         BΪ����ĵ��ƾ���txt��һ��Ϊn*4��ʽ
%tall       ���ߵ�������ľ��룬������ȡ25m
%low        ���͵�������ľ��룬������ȡ3m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% �������� ��Ϊ����n*4��ʽ,�ֱ�Ϊx,y,z,�Լ�ǿ��
len=length(B);
I=zeros(len,6);
for i=1:len
    I(i,1)=B(i,1);
    I(i,2)=B(i,2);
    I(i,3)=B(i,3);
end
% �ҵ�x,y,z���ֵ��Сֵ
xmin=min(I(:,1));
xmax=max(I(:,1));
ymin=min(I(:,2));
ymax=max(I(:,2));
zmi=max(I(:,3));
zmin=min(I(:,3));
%% ������ά����,aveΪ���ű�����һ��ȡ3
for t=1:len
    I(t,5)=fix((I(t,1)-xmin)/ave)+1;
    I(t,6)=fix((I(t,2)-ymin)/ave)+1;
end
%% �����������ڲ����װ����Ӧ����Ԫ���ڣ���������
netcell=cell(max(I(:,5)),max(I(:,6)));            %��,����ά�����߶�ȷ��
count=zeros(max(I(:,5)),max(I(:,6)));               
for i=1:len                                       %��ʼʱK(1,1)��0,����i����,ÿ����Ԫ������������
    [p,~]=size(netcell{I(i,5),I(i,6)});           %�����������д���Ԫ��
    netcell{I(i,5),I(i,6)}(p+1,1)=I(i,1);         %langcell{}��ָ���ð�Ԫ��Ԫ��,��()������
    netcell{I(i,5),I(i,6)}(p+1,2)=I(i,2);
    netcell{I(i,5),I(i,6)}(p+1,3)=I(i,3);
    count(I(i,5),I(i,6))=count(I(i,5),I(i,6))+1;
end
%% ������ά������ȥ�����ߵ�ͼ��͵�
M=max(I(:,5));
N=max(I(:,6));
for m=1:M
    for n=1:N
       if isempty(netcell{m,n})~=1
         if zmi>min(netcell{m,n}(:,3))                                        %zmi��ε���Сֵ��δȥ�͵�ǰ��
          zmi=min(netcell{m,n}(:,3));
        end
           are=mean(netcell{m,n}(:,3));                                       %areΪ��ֵ
        while  (max(netcell{m,n}(:,3))-zmi>tall)                                %���ֵ����Сֵ֮���20m��ȥ���ߵ�
            [h,~]=find(netcell{m,n}(:,3)==max(netcell{m,n}(:,3)));            %�ҵ����ֵ�����У���ɾ��һ����
            netcell{m,n}(h,:)=[];
            count(m,n)=count(m,n)-length(h);
        end         
         while  (are-min(netcell{m,n}(:,3))>low)
           [g,~]=find(netcell{m,n}(:,3)==min(netcell{m,n}(:,3)));             %�ҵ���Сֵ�����У���ɾ��һ������߶���㣨���ܴ��ڶ����ͬ��Сֵ��
           netcell{m,n}(g,:)=[]; 
           count(m,n)=count(m,n)-length(g);
         end
        if zmin>min(netcell{m,n}(:,3))                                        %��ȥ���͵������������������͵�zmin
          zmin=min(netcell{m,n}(:,3));
        end
       end
    end
end
end

