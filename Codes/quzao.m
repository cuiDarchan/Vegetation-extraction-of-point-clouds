function I = quzao(I,xmin,ymin,zmin,len,ave)
%% ������ά����
for t=1:len
    I(t,5)=fix((I(t,1)-xmin)/ave)+1;
    I(t,6)=fix((I(t,2)-ymin)/ave)+1;
    I(t,7)=fix((I(t,3)-zmin)/ave)+1;
end
%% �����������ڲ����װ����Ӧ����Ԫ���ڣ���������
landcell=cell(max(I(:,5)),max(I(:,6)),max(I(:,7)));    %��,���ߣ���ά�����߶�ȷ��
count=zeros(max(I(:,5)),max(I(:,6)),max(I(:,7)));               
for i=1:length(I)                                      %��ʼʱK(1,1)��0,����i����,ÿ����Ԫ������������
    [p,~]=size(landcell{I(i,5),I(i,6),I(i,7)});        %�����������д���Ԫ��,p��ʼΪ0
    landcell{I(i,5),I(i,6),I(i,7)}(p+1,1)=I(i,1);            %landcell{}��ָ���ð�Ԫ��Ԫ��,��()������
    landcell{I(i,5),I(i,6),I(i,7)}(p+1,2)=I(i,2);
    landcell{I(i,5),I(i,6),I(i,7)}(p+1,3)=I(i,3);
    count(I(i,5),I(i,6),I(i,7))=count(I(i,5),I(i,6),I(i,7))+1;
end
%����ÿ����Ԫ��ȥ�����
for i=1:max(I(:,5))
    for j=1:max(I(:,6))
        for k=1:max(I(:,7))
        if count(i,j,k)<=3
          landcell{i,j,k}=[];       
        end
        end
    end
end
% ����д��I����
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
%ȥ������
C(u:9917096,:)=[];
I=C;
end

