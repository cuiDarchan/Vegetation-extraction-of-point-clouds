function carpoints=Carpoints_classification(ave,B,hcar)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%carpoints  ��ȡ�ĳ�������
%ave:       aveΪ���ű�����һ��ȡ3  
%B:         BΪ����ĵ��ƾ���txt��һ��Ϊn*4��ʽ
%hcar       �����ȵ���߳���һ��߶ȣ�������2.5m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% ��һ����ͳһ��������
tall=25;
low=3;
[netcell,I]=Baseprocessing(ave,B,tall,low);    
%% ��ȡ��������
M=max(I(:,5));
N=max(I(:,6));
dmin=min(I(:,3));
carpoints=cell(M,N);
for i=1:M
    for j=1:N
      if isempty(netcell{i,j})~=1
         car_mean=mean(netcell{i,j}(:,3));            %car_meanΪ��άԪ��ƽ��ֵ
         if car_mean<dmin+hcar
             carpoints{i,j}=netcell{i,j}; 
         end
      end
    end
end
end

