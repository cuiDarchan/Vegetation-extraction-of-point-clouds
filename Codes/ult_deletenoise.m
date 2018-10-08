function newlandcell=ult_deletenoise(ave,B)
x=min(B(:,1));       
y=min(B(:,2));    
z=min(B(:,3));
lenland=length(B(:,1));
%% 建立三维格网
for t=1:lenland
    B(t,5)=round((B(t,1)-x)/ave)+1;
    B(t,6)=round((B(t,2)-y)/ave)+1;
    B(t,7)=round((B(t,3)-z)/ave)+1;
end
%% 将各个格网内部点封装到相应格网元胞内，方便索引
landcell=cell(max(B(:,5)),max(B(:,6)),max(B(:,7)));
for i=1:lenland
    K=size(landcell{B(i,5),B(i,6),B(i,7)});
    u=K(1,1)+1;
    landcell{B(i,5),B(i,6),B(i,7)}(u,1)=B(i,1);
    landcell{B(i,5),B(i,6),B(i,7)}(u,2)=B(i,2);
    landcell{B(i,5),B(i,6),B(i,7)}(u,3)=B(i,3);
end
%% 设置待修改数据
newlandcell=landcell;
%% 格网索引去噪
U(1,1)=max(B(:,5));    %统计索引格网边界
U(1,2)=max(B(:,6));
U(1,3)=max(B(:,7));
for i=1:U(1,1)
    for j=1:U(1,2) 
        for k=1:U(1,3)
          if isempty(landcell{i,j,k})~=1
             value=0;
             [num,~]=size(landcell{i,j,k});
             for m=-1:1    %邻近像元法                            %%%%%越界新算法，越界格网直接跳过
                 for n=-1:1
                     for o=-1:1
                         if i+m>=1 && i+m<U(1,1) && j+n>=1 && j+n<U(1,2) && k+o>=1 && k+o<U(1,3)
                            if (m==0 && n==0 && o==0)==0
                             if isempty(landcell{i+m,j+n,k+o})~=1
                               value=1;
                               [w,~]=size(landcell{i+m,j+n,k+o});
                               num=num+w;
                             end
                            end
                         end
                     end
                 end
             end
             if num<=5
                value=0;
             end
             if value==0
                newlandcell{i,j,k}=[];
             end
          end
        end  
    end
end
end