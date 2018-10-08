function buildpoints=Buildingpoints_classification(ave,B,threshold)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%buildpoints   ��ȡ�Ľ��������
%ave:          aveΪ���ű�����һ��ȡ3  
%B:            BΪ����ĵ��ƾ���txt��һ��Ϊn*4��ʽ
%threshold     ������ֵ��������ȡ0.9
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% ��һ����ͳһ��������
tall=25;
low=3;
[netcell,I,count]=Baseprocessing(ave,B,tall,low); 
%% ���±�����ȥ�������ﶥ
M=max(I(:,5));
N=max(I(:,6));
buildpoints=cell(M,N);
zmin=min(I(:,3));
zmax=max(I(:,3));
SY=zeros(M,N);
for o=1:M
    for q=1:N
        if isempty(netcell{o,q})~=1
            zmax=mean(netcell{o,q}(:,3));                  %zmax����������ĸ߳�
            %[k,~]=size(netcell{o,q});                     %k��Ԫ���ڵ�����������ĸ���
            A=netcell{o,q}(:,3);
            j=length(find(A>zmin+3&A>zmax-0.6));           %jΪzmax ����1m���ڵĵ����������0.7���ټ����ж����ɾ��
            c=j/count(o,q);                                %count(o,q)=k,Ϊ��λ��ά�����ڵ�ĸ���
            SY(o,q)=c;
        end                                                      
    end
end

%���ϱ߽磬����Χ��������Ϊ1ʱ���ҵ��߽粢���Ϊ2
for o=2:M-1
    for q=2:N-1
        if isempty(netcell{o,q})~=1
            if  SY(o-1,q-1)==1||SY(o,q-1)==1||SY(o+1,q-1)==1||SY(o,q-1)==1||SY(o,q+1)==1||SY(o-1,q+1)==1||SY(o,q+1)==1||SY(o+1,q+1)==1                                      
                  SY(o,q)=2;                               % 2�����������Ϊ���ʹ��             
            end
        end
    end
end

%����Ǹ�Ϊ1��ȥ���߱����Ķ���
for o=2:M-1
    for q=2:N-1
        if isempty(netcell{o,q})~=1
            if SY(o,q)==2
               SY(o,q)=1;
            end
            b=1;                                            %��Ϊ�յĻ����ӵ�һ����ʼд
            zmax=mean(netcell{o,q}(:,3));                   %zmax����������ĸ߳�
            if SY(o,q)>threshold
              for x=1:count(o,q)                            %������0.9���ϵ� ����ж�
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

