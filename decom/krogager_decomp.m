function[result]=krogager_decomp(hh,hv,vv,show_pic)
% 实现KROGAGER分解,输出为3维 的 向量      show_pic 为显示分解后的伪彩图的选项      
if nargin==3
    show_pic=0;
end
hv = double(hv); 
[s1,s2]=size(hh);
result=zeros(s1,s2,3);
rr=hv*1i+(hh-vv)/2;
ll=hv*1i-(hh-vv)/2;
rl=1i*(hh+vv)/2;
% result(:,:,1)=abs(rl);
result_temp=zeros(1,3);
if show_pic
    fake_image=zeros(s1,s2,3);   sphere=zeros(s1,s2);
    helix=zeros(s1,s2);  diplane=zeros(s1,s2);
end
for ii=1:s1
    for jj=1:s2
        result_temp(1)=abs(rl(ii,jj));
        abs_ll=abs(ll(ii,jj));
        abs_rr=abs(rr(ii,jj));
		if abs_rr>abs_ll
			result_temp(2)=abs_ll;
			result_temp(3)=abs_rr-abs_ll;
		else
			result_temp(2)=abs_rr;
			result_temp(3)=abs_ll-abs_rr;
		end
        if show_pic
            sphere(ii,jj)=result_temp(1);
            diplane(ii,jj)=result_temp(2);
            helix(ii,jj)=result_temp(3);
        end
        result(ii,jj,1:3)=result_temp/norm(result_temp);
    end
end
if show_pic
    
    temp_all=[sphere,diplane,helix];
    max_value=max(max(temp_all));
    temp_all=temp_all/max_value;
    figure;imagesc(temp_all(1:s1,1:s2));title('sphere');colormap(gray);
    figure;imagesc(temp_all(1:s1,s2+1:2*s2));title('diplane');colormap(gray);
    figure;imagesc(temp_all(1:s1,2*s2+1:3*s2));title('helix');
    figure; imagesc(sphere);title('sphere');
    figure; imagesc(diplane);title('diplane'); 
    figure; imagesc(helix);title('helix');
    fake_image(:,:,1)=temp_all(1:s1,1:s2);
    fake_image(:,:,2)=temp_all(1:s1,s2+1:2*s2);
    fake_image(:,:,3)=temp_all(1:s1,2*s2+1:3*s2);
    fake_image = fake_image/max(fake_image(:));
    figure; imshow(fake_image); title('KROGAGER分解');
end