function vegetation=new3veg_classification(ave,B)
%%�������� ��Ϊ����n*4��ʽ,�ֱ�Ϊx,y,z,�Լ�ǿ��
% B=load('pointCloud_terrain_000.txt');
%Bb=lasdata('B.las');
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
%% ��һ����ִ��ȥ�����,�������д��txt��ʽ����I
 ave=3;
 I = quzao(I,xmin,ymin,zmin,len,ave);
 len2=length(I);
%% ������ά����,ȥ���ߵ�͵͵㣬aveΪ���ű�����һ��ȡ3
for t=1:len2
    I(t,5)=fix((I(t,1)-min(I(:,1)))/ave)+1;
    I(t,6)=fix((I(t,2)-min(I(:,2)))/ave)+1;
end
%% �����������ڲ����װ����Ӧ����Ԫ���ڣ���������
landcell=cell(max(I(:,5)),max(I(:,6)));    %��,����ά�����߶�ȷ��
count=zeros(max(I(:,5)),max(I(:,6)));               
for i=1:len2                                      %��ʼʱK(1,1)��0,����i����,ÿ����Ԫ������������
    [p,~]=size(landcell{I(i,5),I(i,6)});        %�����������д���Ԫ��
    landcell{I(i,5),I(i,6)}(p+1,1)=I(i,1);            %langcell{}��ָ���ð�Ԫ��Ԫ��,��()������
    landcell{I(i,5),I(i,6)}(p+1,2)=I(i,2);
    landcell{I(i,5),I(i,6)}(p+1,3)=I(i,3);
    count(I(i,5),I(i,6))=count(I(i,5),I(i,6))+1;
end
%% ������ά������ȥ���ߵ�͵͵�
for m=1:max(I(:,5))
    for n=1:max(I(:,6))
       if isempty(landcell{m,n})~=1
         if zmi>min(landcell{m,n}(:,3))                                        %zmi��ε���Сֵ��δȥ�͵�ǰ��
          zmi=min(landcell{m,n}(:,3));
        end
           are=mean(landcell{m,n}(:,3));                                   %areΪ��ֵ
        while  (max(landcell{m,n}(:,3))-zmi>25)                            %���ֵ����Сֵ֮���20m��ȥ���ߵ�
            [h,~]=find(landcell{m,n}(:,3)==max(landcell{m,n}(:,3)));       %�ҵ����ֵ�����У���ɾ��һ����
            landcell{m,n}(h,:)=[];
            count(m,n)=count(m,n)-length(h);
        end         
         while  (are-min(landcell{m,n}(:,3))>3)
           [g,~]=find(landcell{m,n}(:,3)==min(landcell{m,n}(:,3)));        %�ҵ���Сֵ�����У���ɾ��һ������߶���㣨���ܴ��ڶ����ͬ��Сֵ��
           landcell{m,n}(g,:)=[]; 
           count(m,n)=count(m,n)-length(g);
         end
        if zmin>min(landcell{m,n}(:,3))                                        %��ȥ���͵������������������͵�zmin
          zmin=min(landcell{m,n}(:,3));
        end
       end
    end
end
%% ���±�����ȥ�������ﶥ
SY=zeros(max(I(:,5)),max(I(:,6)));
for o=1:max(I(:,5))
    for q=1:max(I(:,6))
        if isempty(landcell{o,q})~=1
            zmax=mean(landcell{o,q}(:,3));               %zmax����������ĸ߳�
            %[k,~]=size(landcell{o,q});                     %k��Ԫ���ڵ�����������ĸ���
            A=landcell{o,q}(:,3);
            j=length(find(A>zmin+3&A>zmax-0.6));           %jΪzmax ����1m���ڵĵ����������0.7���ټ����ж����ɾ��
            c=j/count(o,q);                                     %count(o,q)=k,Ϊ��λ��ά�����ڵ�ĸ���
            SY(o,q)=c;
        end                                                      
    end
end

%���ϱ߽磬����Χ��������Ϊ1ʱ���ҵ��߽粢���Ϊ2
for o=2:max(I(:,5))-1
    for q=2:max(I(:,6))-1
        if isempty(landcell{o,q})~=1
                if  SY(o-1,q-1)==1||SY(o,q-1)==1||SY(o+1,q-1)==1||SY(o,q-1)==1||SY(o,q+1)==1||SY(o-1,q+1)==1||SY(o,q+1)==1||SY(o+1,q+1)==1                                      
                  SY(o,q)=2;     % 2�����������Ϊ���ʹ��             
                end
        end
    end
end
%����Ǹ�Ϊ1��ȥ���߱����Ķ���
for o=2:max(I(:,5))-1
    for q=2:max(I(:,6))-1
        if isempty(landcell{o,q})~=1
            if SY(o,q)==2
                SY(o,q)=1;
            end 
            zmax=mean(landcell{o,q}(:,3));               %zmax����������ĸ߳�
            if SY(o,q)>0.9
              for x=1:count(o,q)                                     %������0.8���ϵ� ����ж�
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
%% ���þ�����ȥ������
% OO=zeros(max(I(:,5)),max(I(:,6)));
for e=1:max(I(:,5))
    for w=1:max(I(:,6))
        if isempty(landcell{e,w})~=1
           D=landcell{e,w}(:,3);
           Zm=min(D);           %ZmΪ��λ���ڸ߳���Сֵ
            if Zm<zmin+3
             [s,~]=find(D<Zm+2);                    
             V=zeros(1,length(s));                        %VΪ�߳����� Zm+2������zֵ����
             for z=1:length(s)
               V(1,z)=landcell{e,w}(s(z,1),3);
             end
             oo=std2(V);              %ooΪzֵ���Ͼ������С����ֵ�����ж�Ϊ���Σ���Ҫȥ��
%              OO(e,w)=oo;             
             if oo<0.1
               landcell{e,w}(s,:)=[];
               count(e,w)=count(e,w)-length(s);
             end
            end    
        end
    end
end
%% ȥ������
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
% %% ȥ����Ծֵ�Ĳ�����̽�����ǽ�ڣ���Χ�����϶೵��
% % FF=zeros(max(I(:,5)),max(I(:,6)));
% for  jj=1:max(I(:,5))
%     for kk=1:max(I(:,6)) 
%         if isempty(landcell{jj,kk})~=1
%         E=landcell{jj,kk};
%         G=sort(E(:,3));              %�Ը߳�ֵ�����������ۼ�����
%         F=zeros(1,size(E,1)-1);
%         for pp=2:size(E,1)
%            F(1,pp-1)=G(pp,1)-G(pp-1,1);         %�ۼ����㲢��ֵ,�õ�F����,ǽ�ڳ��ָ߳̽�Ծ3m�������    
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
