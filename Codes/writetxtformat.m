function C=writetxtformat(newlandcell)
[a,b]=size(newlandcell);
u=1;
C=zeros(9917096,3);
for i=1:a
    for j=1:b
        %for k=1:c
        if isempty(newlandcell{i,j})~=1
          W=size(newlandcell{i,j});
        for w=1:W(1,1)
            C(u,1)=newlandcell{i,j}(w,1);
            C(u,2)=newlandcell{i,j}(w,2);
            C(u,3)=newlandcell{i,j}(w,3);
            u=u+1;
        %end
        end
        end
    end
end
end