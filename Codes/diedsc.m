function [vegetation,count,u] = diedsc(landcell,I,count)
%% ȥ�����ཨ���ﶥ�͵���С��
vegetation=landcell;
m1=max(I(:,5))-2;
m2=max(I(:,6))-2;
cd=m1*m2;
J=zeros(cd,2);
u=1;
for  d=2:max(I(:,5))-1
    for  f=2:max(I(:,6))-1    
        if isempty(vegetation{d,f})~=1
            js=0;                                       %jsΪ�м䷽�������
            for mm=-1:1
                for nn=-1:1
                if count(d+mm,f+nn)>=20                     %�Ƚ�3*3�������е�ĸ�������
                js=js+1;
                end
                end
            end
            if js<=3
            J(u,1)=d;                              %dΪ������fΪ����
            J(u,2)=f;
            u=u+1;
            end    
        end
    end   
end
for ii=1:u-1
vegetation{J(ii,1),J(ii,2)}=[];
count(J(ii,1),J(ii,2))=0;
end
end

