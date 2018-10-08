function [vegetation,count,u] = diedsc(landcell,I,count)
%% 去除残余建筑物顶和单独小车
vegetation=landcell;
m1=max(I(:,5))-2;
m2=max(I(:,6))-2;
cd=m1*m2;
J=zeros(cd,2);
u=1;
for  d=2:max(I(:,5))-1
    for  f=2:max(I(:,6))-1    
        if isempty(vegetation{d,f})~=1
            js=0;                                       %js为中间方格计数器
            for mm=-1:1
                for nn=-1:1
                if count(d+mm,f+nn)>=20                     %比较3*3格网内有点的格网个数
                js=js+1;
                end
                end
            end
            if js<=3
            J(u,1)=d;                              %d为行数，f为列数
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

