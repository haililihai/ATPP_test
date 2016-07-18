function validation_test(PWD,PREFIX,PART,SUB_LIST,METHOD,VOX_SIZE,MAX_CL_NUM,N_ITER,GROUP_THRES,MPM_THRES,LEFT,RIGHT)

addpath('/DATA/233/hli/toolbox');

% methods
split_half=0;
pairwise=0;
leave_one_out=0;
group_cont=1;
indi_cont=1;
group_hi_vi=1;
indi_hi_vi=1;
group_silhouette=1;
indi_silhouette=1;

GROUP_THRES=25;
LEFT=1;
RIGHT=0;

if split_half==1

    if LEFT==1
        validation_split_half(PWD,PREFIX,PART,SUB_LIST,METHOD,VOX_SIZE,MAX_CL_NUM,N_ITER,MPM_THRES,GROUP_THRES,1)
    end
    if RIGHT==1
        validation_split_half(PWD,PREFIX,PART,SUB_LIST,METHOD,VOX_SIZE,MAX_CL_NUM,N_ITER,MPM_THRES,GROUP_THRES,0)
    end
end

if leave_one_out==1

    if LEFT==1
        validation_leave_one_out(PWD,PREFIX,PART,SUB_LIST,METHOD,VOX_SIZE,MAX_CL_NUM,MPM_THRES,GROUP_THRES,1)
    end
    if RIGHT==1
        validation_leave_one_out(PWD,PREFIX,PART,SUB_LIST,METHOD,VOX_SIZE,MAX_CL_NUM,MPM_THRES,GROUP_THRES,0)
    end
end

if pairwise==1

    if LEFT==1
        validation_pairwise(PWD,PREFIX,PART,SUB_LIST,METHOD,VOX_SIZE,MAX_CL_NUM,MPM_THRES,GROUP_THRES,1)
    end
    if RIGHT==1
        validation_pairwise(PWD,PREFIX,PART,SUB_LIST,METHOD,VOX_SIZE,MAX_CL_NUM,MPM_THRES,GROUP_THRES,0)
    end
end

if group_cont==1

    if LEFT==1
        validation_group_cont(PWD,PART,SUB_LIST,VOX_SIZE,MAX_CL_NUM,MPM_THRES,GROUP_THRES,1)
    end
    if RIGHT==1
        validation_group_cont(PWD,PART,SUB_LIST,VOX_SIZE,MAX_CL_NUM,MPM_THRES,GROUP_THRES,0)
    end
end

if indi_cont==1

    if LEFT==1
        validation_indi_cont(PWD,PREFIX,PART,SUB_LIST,METHOD,VOX_SIZE,MAX_CL_NUM,MPM_THRES,GROUP_THRES,1)
    end
    if RIGHT==1
        validation_indi_cont(PWD,PREFIX,PART,SUB_LIST,METHOD,VOX_SIZE,MAX_CL_NUM,MPM_THRES,GROUP_THRES,0)
    end
end

if group_hi_vi==1

    if LEFT==1
        validation_group_hi_vi(PWD,PART,SUB_LIST,VOX_SIZE,MAX_CL_NUM,MPM_THRES,GROUP_THRES,1)
    end
    if RIGHT==1
        validation_group_hi_vi(PWD,PART,SUB_LIST,VOX_SIZE,MAX_CL_NUM,MPM_THRES,GROUP_THRES,0)
    end
end

if indi_hi_vi==1

    if LEFT==1
        validation_indi_hi_vi(PWD,PREFIX,PART,SUB_LIST,METHOD,VOX_SIZE,MAX_CL_NUM,MPM_THRES,GROUP_THRES,1)
    end
    if RIGHT==1
        validation_indi_hi_vi(PWD,PREFIX,PART,SUB_LIST,METHOD,VOX_SIZE,MAX_CL_NUM,MPM_THRES,GROUP_THRES,0)
    end
end

if group_silhouette==1

    if LEFT==1
        validation_group_silhouette(PWD,PART,SUB_LIST,VOX_SIZE,MAX_CL_NUM,MPM_THRES,GROUP_THRES,1)
    end
    if RIGHT==1
        validation_group_silhouette(PWD,PART,SUB_LIST,VOX_SIZE,MAX_CL_NUM,MPM_THRES,GROUP_THRES,0)
    end
end

if indi_silhouette==1

    if LEFT==1
        validation_indi_silhouette(PWD,PREFIX,PART,SUB_LIST,METHOD,VOX_SIZE,MAX_CL_NUM,MPM_THRES,GROUP_THRES,1)
    end
    if RIGHT==1
        validation_indi_silhouette(PWD,PREFIX,PART,SUB_LIST,METHOD,VOX_SIZE,MAX_CL_NUM,MPM_THRES,GROUP_THRES,0)
    end
end

function validation_split_half(PWD,PREFIX,PART,SUB_LIST,METHOD,VOX_SIZE,MAX_CL_NUM,N_ITER,MPM_THRES,GROUP_THRES,LorR)

    if LorR == 1
        LR='L';
    elseif LorR == 0
        LR='R';
    end

    sub=textread(SUB_LIST,'%s');
    sub_num=length(sub);

    if ~exist('N_ITER','var') | isempty(N_ITER)
        N_ITER=100;
    end
    if ~exist('MPM_THRES','var') | isempty(MPM_THRES)
        MPM_THRES=0.25;
    end
    
    MASK_FILE=strcat(PWD,'/group_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',PART,'_',LR,'_roimask_thr',num2str(GROUP_THRES),'.nii');
    MASK_NII=load_untouch_nii(MASK_FILE);
    MASK=MASK_NII.img;

    N=N_ITER;
    n1=floor(sub_num/2);
    dice=zeros(N,2,MAX_CL_NUM);
    nminfo=zeros(N,2,MAX_CL_NUM);
    vi=zeros(N,MAX_CL_NUM);
    cv=zeros(N,1,MAX_CL_NUM);
    for kc=2:MAX_CL_NUM
        list1_sub={};
        list2_sub={};
        for ti=1:N
            tmp=randperm(sub_num);
            list1_sub={sub{tmp(1:n1)}}';
            list2_sub={sub{tmp(n1+1:sub_num)}}';
            mpm_cluster1=cluster_mpm_validation(PWD,PREFIX,PART,list1_sub,METHOD,VOX_SIZE,kc,MPM_THRES,LorR);
            mpm_cluster2=cluster_mpm_validation(PWD,PREFIX,PART,list2_sub,METHOD,VOX_SIZE,kc,MPM_THRES,LorR);
	    mpm_cluster1=mpm_cluster1.*MASK;
	    mpm_cluster2=mpm_cluster2.*MASK;
            
            %compute dice coefficent
            num=0;
            den=0;
            dice_m=zeros(kc,1);
            for ki=1:kc
                tmp1=(mpm_cluster1==ki);
                tmp2=(mpm_cluster2==ki);
                num=num+length(find(tmp1.*tmp2>0));
                den=den+length(find(tmp1+tmp2>0));
                dice_m(ki)=2*length(find(tmp1.*tmp2>0))/(length(find(tmp1>0))+length(find(tmp2>0)));
            end
            dice(ti,1,kc)=2*num/den;
            dice_m(isnan(dice_m))=0;
            dice(ti,2,kc)=mean(dice_m);
            
            %compute the normalized mutual information and variation of information
            [nminfo(ti,1,kc),nminfo(ti,2,kc),vi(ti,kc)]=my_nmi(mpm_cluster1,mpm_cluster2);
            
            %compute cramer V
            [cxy,pxy]=hist_table(mpm_cluster1,mpm_cluster2);
            cv(ti,1,kc)=my_cramerv(pxy);
            
            disp(strcat('N_ITER: ',num2str(ti),'/',num2str(N)));
        end
    end

    if ~exist(strcat(PWD,'/test_validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm')) mkdir(strcat(PWD,'/test_validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm'));end
    save(strcat(PWD,'/test_validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',PART,'_',LR,'_index_split_half.mat'),'dice','nminfo','cv','vi');

    fp=fopen(strcat(PWD,'/test_validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',PART,'_',LR,'_index_split_half.txt'),'at');
    if fp
        for kc=2:MAX_CL_NUM
            fprintf(fp,'%s','cluster num = ');
            fprintf(fp,'%d',kc);
            fprintf(fp,'\n');
            fprintf(fp,'%s','  dice: mean = ');
            fprintf(fp,'%f  %f',mean(dice(:,2,kc)));
            fprintf(fp,'%s',' , std = ');
            fprintf(fp,'%f  %f',std(dice(:,2,kc)));
            fprintf(fp,'\n');
            fprintf(fp,'%s','  normalized mutual info: mean = ');
            fprintf(fp,'%f  %f',mean(nminfo(:,1,kc)));
            fprintf(fp,'%s',' , std = ');
            fprintf(fp,'%f  %f',std(nminfo(:,1,kc)));
            fprintf(fp,'\n');
            fprintf(fp,'%s','  variation of info: mean = ');
            fprintf(fp,'%f  %f',mean(vi(:,kc)));
            fprintf(fp,'%s',' , std = ');
            fprintf(fp,'%f  %f',std(vi(:,kc)));
            fprintf(fp,'\n');
            fprintf(fp,'%s','  cramer V: mean = ');
            fprintf(fp,'%f  %f',mean(cv(:,1,kc)));
            fprintf(fp,'%s',' , std = ');
            fprintf(fp,'%f  %f',std(cv(:,1,kc)));
            fprintf(fp,'\n');
            fprintf(fp,'\n');
        end
    end
    fclose(fp);



function validation_leave_one_out(PWD,PREFIX,PART,SUB_LIST,METHOD,VOX_SIZE,MAX_CL_NUM,MPM_THRES,GROUP_THRES,LorR)

    if LorR == 1
        LR='L';
    elseif LorR == 0
        LR='R';
    end

    sub=textread(SUB_LIST,'%s');
    sub_num=length(sub);

    if ~exist('MPM_THRES','var') | isempty(MPM_THRES)
        MPM_THRES=0.25;
    end

    MASK_FILE=strcat(PWD,'/group_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',PART,'_',LR,'_roimask_thr',num2str(GROUP_THRES),'.nii');  
    MASK_NII=load_untouch_nii(MASK_FILE);                                                                                                 
    MASK=MASK_NII.img; 

    cv=zeros(sub_num,1,MAX_CL_NUM);
    dice=zeros(sub_num,2,MAX_CL_NUM);
    nminfo=zeros(sub_num,2,MAX_CL_NUM);
    vi=zeros(sub_num,MAX_CL_NUM);
    for kc=2:MAX_CL_NUM
        for ti=1:sub_num
            sub1=sub;
            sub1(ti)=[];
            dice_m=zeros(kc,1);
            
            vnii_ref_file=strcat(PWD,'/',sub{ti},'/',PREFIX,'_',sub{ti},'_',PART,'_',LR,'_',METHOD,'/',num2str(VOX_SIZE),'mm/',num2str(VOX_SIZE),'mm_',PART,'_',LR,'_',num2str(kc),'_MNI_relabel_group.nii');
            vnii_ref=load_untouch_nii(vnii_ref_file);
            mpm_cluster1=vnii_ref.img;
            mpm_cluster2=cluster_mpm_validation(PWD,PREFIX,PART,sub1,METHOD,VOX_SIZE,kc,MPM_THRES,LorR);
	    mpm_cluster1=mpm_cluster1.*MASK;
	    mpm_cluster2=mpm_cluster2.*MASK;


            num=0;
            den=0;
            for ki=1:kc
                tmp1=(mpm_cluster1==ki);
                tmp2=(mpm_cluster2==ki);
                num=num+length(find(tmp1.*tmp2>0));
                den=den+length(find(tmp1+tmp2>0));
                dice_m(ki)=2*length(find(tmp1.*tmp2>0))/(length(find(tmp1>0))+length(find(tmp2>0)));
            end
            dice(ti,1,kc)=2*num/den;
            dice_m(isnan(dice_m))=0;
            dice(ti,2,kc)=mean(dice_m);

            %compute the normalized mutual information and variation of information
            [nminfo(ti,1,kc),nminfo(ti,2,kc),vi(ti,kc)]=my_nmi(mpm_cluster1,mpm_cluster2);
            
            %compute cramer V
            [cxy,pxy]=hist_table(mpm_cluster1,mpm_cluster2);
            cv(ti,1,kc)=my_cramerv(pxy);           
        end
    end

    if ~exist(strcat(PWD,'/test_validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm')) mkdir(strcat(PWD,'/test_validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm'));end
    save(strcat(PWD,'/test_validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',PART,'_',LR,'_index_leave_one_out.mat'),'dice','nminfo','cv','vi');

    fp=fopen(strcat(PWD,'/test_validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',PART,'_',LR,'_index_leave_one_out.txt'),'at');
    if fp 
        for kc=2:MAX_CL_NUM
            fprintf(fp,'clster_num: %d\nmcv: %f, std_cv: %f\nmdice: %f, std_dice: %f\nnmi: %f,std_nmi: %f\nmvi: %f,std_vi: %f\n\n',kc,mean(cv(:,1,kc)),std(cv(:,1,kc)),mean(dice(:,2,kc)),std(dice(:,2,kc)),mean(nminfo(:,1,kc)),std(nminfo(:,1,kc)),mean(vi(:,kc)),std(vi(:,kc)));
        end
    end
    fclose(fp);



function validation_pairwise(PWD,PREFIX,PART,SUB_LIST,METHOD,VOX_SIZE,MAX_CL_NUM,MPM_THRES,GROUP_THRES,LorR)

    if LorR == 1
        LR='L';
    elseif LorR == 0
        LR='R';
    end

    sub=textread(SUB_LIST,'%s');
    sub_num=length(sub);

    if ~exist('MPM_THRES','var') | isempty(MPM_THRES)
        MPM_THRES=0.25;
    end


    MASK_FILE=strcat(PWD,'/group_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',PART,'_',LR,'_roimask_thr',num2str(GROUP_THRES),'.nii');  
    MASK_NII=load_untouch_nii(MASK_FILE);                                                                                                 
    MASK=MASK_NII.img; 

    cv=zeros(sub_num,sub_num,MAX_CL_NUM);
    dice=zeros(sub_num,sub_num,MAX_CL_NUM);
    nminfo=zeros(sub_num,sub_num,MAX_CL_NUM);
    vi=zeros(sub_num,sub_num,MAX_CL_NUM);
    for kc=2:MAX_CL_NUM
        for ti=1:sub_num-1
            vnii_ref_file=strcat(PWD,'/',sub{ti},'/',PREFIX,'_',sub{ti},'_',PART,'_',LR,'_',METHOD,'/',num2str(VOX_SIZE),'mm/',num2str(VOX_SIZE),'mm_',PART,'_',LR,'_',num2str(kc),'_MNI_relabel_group.nii');
            vnii_ref=load_untouch_nii(vnii_ref_file);
            mpm_cluster1=vnii_ref.img;
	    mpm_cluster1=mpm_cluster1.*MASK;
            for tn=ti+1:sub_num
                vnii_ref1_file=strcat(PWD,'/',sub{tn},'/',PREFIX,'_',sub{tn},'_',PART,'_',LR,'_',METHOD,'/',num2str(VOX_SIZE),'mm/',num2str(VOX_SIZE),'mm_',PART,'_',LR,'_',num2str(kc),'_MNI_relabel_group.nii');
                vnii_ref1=load_untouch_nii(vnii_ref1_file);
                mpm_cluster2=vnii_ref1.img;
	        mpm_cluster2=mpm_cluster2.*MASK;
                
                num=0;
                den=0;
                dice_m=zeros(kc,1);
                for ki=1:kc
                    tmp1=(mpm_cluster1==ki);
                    tmp2=(mpm_cluster2==ki);
                    num=num+length(find(tmp1.*tmp2>0));
                    den=den+length(find(tmp1+tmp2>0));
                    dice_m(ki)=2*length(find(tmp1.*tmp2>0))/(length(find(tmp1>0))+length(find(tmp2>0)));
                end
                
                dice_m(isnan(dice_m))=0;
                dice(ti,tn,kc)=mean(dice_m);

                %compute the normalized mutual information and variation of information
                [nminfo(ti,tn,kc),minfo,vi(ti,tn,kc)]=my_nmi(mpm_cluster1,mpm_cluster2);               
                
                %compute cramer V
                [cxy,pxy]=hist_table(mpm_cluster1,mpm_cluster2);
                cv(ti,tn,kc)=my_cramerv(pxy);
            end      
        end
    end
    
    if ~exist(strcat(PWD,'/test_validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm')) mkdir(strcat(PWD,'/test_validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm'));end  
    save(strcat(PWD,'/test_validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',PART,'_',LR,'_index_pairwise.mat'),'dice','nminfo','cv','vi');

    fp=fopen(strcat(PWD,'/test_validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',PART,'_',LR,'_index_pairwise.txt'),'at');
    if fp
        for kc=2:MAX_CL_NUM
            col_cv=cv(:,:,kc);
            col_cv=col_cv(find(col_cv~=0));
            col_dice=dice(:,:,kc);
            col_dice=col_dice(find(col_dice~=0));
            col_nmi=nminfo(:,:,kc); 
            col_nmi=col_nmi(find(col_nmi~=0));
            col_vi=vi(:,:,kc); 
            col_vi=col_vi(find(col_vi~=0)); 
            fprintf(fp,'cluster_num: %d\nmcv: %f, std_cv: %f\nmdice: %f, std_dice: %f\nnminfo: %f,std_nminfo: %f\nmvi: %f,std_vi: %f\n\n',kc,mean(col_cv),std(col_cv),mean(col_dice),std(col_dice),mean(col_nmi),std(col_nmi),mean(col_vi),std(col_vi));
        end
    end
    fclose(fp);

function validation_group_cont(PWD,PART,SUB_LIST,VOX_SIZE,MAX_CL_NUM,MPM_THRES,GROUP_THRES,LorR)

    if LorR == 1
        LR='L';
    elseif LorR == 0
        LR='R';
    end

    sub=textread(SUB_LIST,'%s');
    sub_num=length(sub);

    if ~exist('MPM_THRES','var') | isempty(MPM_THRES)
        MPM_THRES=0.25;
    end

    % group-level continuity
    group_cont=zeros(1,MAX_CL_NUM);
    for kc=2:MAX_CL_NUM
        mpm_file=strcat(PWD,'/MPM_40_',num2str(VOX_SIZE),'mm/',num2str(VOX_SIZE),'mm_',PART,'_',LR,'_',num2str(kc),'_MPM_thr',num2str(MPM_THRES*100),'_group.nii.gz');
        mpm=load_untouch_nii(mpm_file);
        tempimg=double(mpm.img);
        cont=cell(kc,1);
        sum=0;
        for i=1:kc
            tmp=tempimg;
            tmp(tempimg~=i)=0;
            [L,NUM]=spm_bwlabel(tmp,6); % 6 surface, 18 edge, 26 corner
            tmp1=zeros(NUM,1);
            tmp_total=length(find(L~=0));
            for j=1:NUM
                tmp_num=length(find(L==j));
                tmp1(j)=tmp_num/tmp_total;
            end
            cont{i}=tmp1;
            sum=sum+max(cont{i});
        end
        group_cont(kc)=sum/kc;
    end

    if ~exist(strcat(PWD,'/test_validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm')) mkdir(strcat(PWD,'/test_validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm'));end
    save(strcat(PWD,'/test_validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',PART,'_',LR,'_index_group_continuity.mat'),'group_cont');

    fp=fopen(strcat(PWD,'/test_validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',PART,'_',LR,'_index_group_continuity.txt'),'at');
    if fp
        for kc=2:MAX_CL_NUM
            fprintf(fp,'cluster_num: %d\ngroup_continuity: %f\n\n',kc,group_cont(kc));
        end
    end
    fclose(fp);


function validation_group_silhouette(PWD,PART,SUB_LIST,VOX_SIZE,MAX_CL_NUM,MPM_THRES,GROUP_THRES,LorR)

    if LorR == 1
        LR='L';
    elseif LorR == 0
        LR='R';
    end

    sub=textread(SUB_LIST,'%s');
    sub_num=length(sub);

    if ~exist('MPM_THRES','var') | isempty(MPM_THRES)
        MPM_THRES=0.25;
    end

    % group-level silhouette
    group_sil=zeros(1,MAX_CL_NUM);
    for kc=2:MAX_CL_NUM
        mpm_file=strcat(PWD,'/MPM_40_',num2str(VOX_SIZE),'mm/',num2str(VOX_SIZE),'mm_',PART,'_',LR,'_',num2str(kc),'_MPM_thr',num2str(MPM_THRES*100),'_group.nii.gz');
        mpm=load_untouch_nii(mpm_file);
        tempimg=mpm.img;
        [xx,yy,zz]=size(tempimg);
        data=zeros(length(find(tempimg~=0 & ~isnan(tempimg))),4);
        n=1;
        for x=1:xx
            for y=1:yy
                for z=1:zz
                    if tempimg(x,y,z)~=0 && ~isnan(tempimg(x,y,z))
                        data(n,1)=x;data(n,2)=y;data(n,3)=z;data(n,4)=tempimg(x,y,z);
                        n=n+1;
                    end
                end
            end
        end
        coord=data(:,1:3);
        label=data(:,4);
        group_sil(1,kc)=mean(silhouette(data,label));
    end


    if ~exist(strcat(PWD,'/test_validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm')) mkdir(strcat(PWD,'/test_validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm'));end
    save(strcat(PWD,'/test_validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',PART,'_',LR,'_index_group_silhouette.mat'),'group_sil');

    fp=fopen(strcat(PWD,'/test_validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',PART,'_',LR,'_index_group_silhouette.txt'),'at');
    if fp
        for kc=2:MAX_CL_NUM
            fprintf(fp,'cluster_num: %d\naverage_group_silhouette: %f\n\n',kc,group_sil(kc));
        end
    end
    fclose(fp);

function validation_indi_cont(PWD,PREFIX,PART,SUB_LIST,METHOD,VOX_SIZE,MAX_CL_NUM,MPM_THRES,GROUP_THRES,LorR)

    if LorR == 1
        LR='L';
    elseif LorR == 0
        LR='R';
    end

    sub=textread(SUB_LIST,'%s');
    sub_num=length(sub);

    if ~exist('MPM_THRES','var') | isempty(MPM_THRES)
        MPM_THRES=0.25;
    end

    MASK_FILE=strcat(PWD,'/group_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',PART,'_',LR,'_roimask_thr',num2str(GROUP_THRES),'.nii');  
    MASK_NII=load_untouch_nii(MASK_FILE);                                                                                                 
    MASK=MASK_NII.img; 

    % individual-level continuity
    indi_cont=zeros(MAX_CL_NUM,sub_num);
    for kc=2:MAX_CL_NUM
        for ti=1:sub_num
            nii_file=strcat(PWD,'/',sub{ti},'/',PREFIX,'_',sub{ti},'_',PART,'_',LR,'_',METHOD,'/',num2str(VOX_SIZE),'mm/',num2str(VOX_SIZE),'mm_',PART,'_',LR,'_',num2str(kc),'_MNI_relabel_group.nii');
            nii=load_untouch_nii(nii_file);
            nii.img=nii.img.*MASK;
            tempimg=double(nii.img);
            cont=cell(kc,1);
            sum=0;
            for i=1:kc
                tmp=tempimg;
                tmp(tempimg~=i)=0;
                [L,NUM]=spm_bwlabel(tmp,6); % 6 surface, 18 edge, 26 corner
                tmp1=zeros(NUM,1);
                tmp_total=length(find(L~=0));
                for j=1:NUM
                    tmp_num=length(find(L==j));
                    tmp1(j)=tmp_num/tmp_total;
                end
                cont{i}=tmp1;
                sum=sum+max(cont{i});
            end
            indi_cont(kc,ti)=sum/kc;
        end
    end

    if ~exist(strcat(PWD,'/test_validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm')) mkdir(strcat(PWD,'/test_validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm'));end
    save(strcat(PWD,'/test_validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',PART,'_',LR,'_index_indi_continuity.mat'),'indi_cont');

    fp=fopen(strcat(PWD,'/test_validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',PART,'_',LR,'_index_indi_continuity.txt'),'at');
    if fp
        for kc=2:MAX_CL_NUM
            fprintf(fp,'cluster_num: %d\navg_indi_continuity: %f\nstd_indi_continuity: %f\nmedian_indi_continuity: %f\n\n',kc,mean(indi_cont(kc,:)),std(indi_cont(kc,:)),median(indi_cont(kc,:)));
        end
    end
    fclose(fp);


%function validation_indi_silhouette(PWD,PREFIX,PART,SUB_LIST,METHOD,VOX_SIZE,MAX_CL_NUM,MPM_THRES,LorR)
%
%    if LorR == 1
%        LR='L';
%    elseif LorR == 0
%        LR='R';
%    end
%
%    sub=textread(SUB_LIST,'%s');
%    sub_num=length(sub);
%
%    if ~exist('MPM_THRES','var') | isempty(MPM_THRES)
%        MPM_THRES=0.25;
%    end
%
%    % individual-level silhouette
%    indi_sil=zeros(MAX_CL_NUM,sub_num);
%    for kc=2:MAX_CL_NUM
%        for ti=1:sub_num
%            nii_file=strcat(PWD,'/',sub{ti},'/',PREFIX,'_',sub{ti},'_',PART,'_',LR,'_',METHOD,'/',num2str(VOX_SIZE),'mm/',num2str(VOX_SIZE),'mm_',PART,'_',LR,'_',num2str(kc),'_MNI_relabel_group.nii');
%            nii=load_untouch_nii(nii_file);
%            tempimg=nii.img;
%            [xx,yy,zz]=size(tempimg);
%            data=zeros(length(find(tempimg~=0 & ~isnan(tempimg))),4);
%            n=1;
%            for x=1:xx
%                for y=1:yy
%                    for z=1:zz
%                        if tempimg(x,y,z)~=0 && ~isnan(tempimg(x,y,z))
%                            data(n,1)=x;data(n,2)=y;data(n,3)=z;data(n,4)=tempimg(x,y,z);
%                            n=n+1;
%                        end
%                    end
%                end
%            end
%            coord=data(:,1:3);
%            label=data(:,4);
%            indi_sil(kc,ti)=mean(silhouette(data,label));
%        end
%    end
%
%
%    if ~exist(strcat(PWD,'/test_validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm')) mkdir(strcat(PWD,'/test_validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm'));end
%    save(strcat(PWD,'/test_validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',PART,'_',LR,'_index_indi_silhouette.mat'),'indi_sil');
%
%    fp=fopen(strcat(PWD,'/test_validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',PART,'_',LR,'_index_indi_silhouette.txt'),'at');
%    if fp
%        for kc=2:MAX_CL_NUM
%            fprintf(fp,'cluster_num: %d\navg_indi_silhouette: %f\nstd_indi_silhouette: %f\nmedian_indi_silhouette: %f\n\n',kc,mean(indi_sil(kc,:)),std(indi_sil(kc,:)),median(indi_sil(kc,:)));
%        end
%    end
%    fclose(fp);
function validation_indi_silhouette(PWD,PREFIX,PART,SUB_LIST,METHOD,VOX_SIZE,MAX_CL_NUM,MPM_THRES,GROUP_THRES,LorR)

    if LorR == 1
        LR='L';
    elseif LorR == 0
        LR='R';
    end

    sub=textread(SUB_LIST,'%s');
    sub_num=length(sub);

    if ~exist('MPM_THRES','var') | isempty(MPM_THRES)
        MPM_THRES=0.25;
    end


    % individual-level silhouette
    indi_sil=zeros(MAX_CL_NUM,sub_num);
    for ti=1:sub_num
        matrix_file=strcat(PWD,'/',sub{ti},'/',PREFIX,'_',sub{ti},'_',PART,'_',LR,'_matrix/connection_matrix.mat');
        display(matrix_file);

        load(matrix_file);
        distance=pdist(matrix,'cosine');

        for kc=2:MAX_CL_NUM
            nii_file=strcat(PWD,'/',sub{ti},'/',PREFIX,'_',sub{ti},'_',PART,'_',LR,'_',METHOD,'/',PART,'_',LR,'_',num2str(kc),'.nii');
            nii=load_untouch_nii(nii_file);
            tempimg=nii.img;
            [xx,yy,zz]=size(tempimg);    
    	    label=zeros(length(xyz),1);
    	    for n=1:length(xyz)
    		    label(n,1)=tempimg(xyz(n,1)+1,xyz(n,2)+1,xyz(n,3)+1);
    	    end
                indi_sil(kc,ti)=mean(silhouette([],label,distance));
        end
    end


    if ~exist(strcat(PWD,'/test_validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm')) mkdir(strcat(PWD,'/test_validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm'));end
    save(strcat(PWD,'/test_validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',PART,'_',LR,'_index_indi_silhouette.mat'),'indi_sil');

    fp=fopen(strcat(PWD,'/test_validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',PART,'_',LR,'_index_indi_silhouette.txt'),'at');
    if fp
        for kc=2:MAX_CL_NUM
            fprintf(fp,'cluster_num: %d\navg_indi_silhouette: %f\nstd_indi_silhouette: %f\nmedian_indi_silhouette: %f\n\n',kc,mean(indi_sil(kc,:)),std(indi_sil(kc,:)),median(indi_sil(kc,:)));
        end
    end
    fclose(fp);



function validation_group_hi_vi(PWD,PART,SUB_LIST,VOX_SIZE,MAX_CL_NUM,MPM_THRES,GROUP_THRES,LorR)

    if LorR == 1
        LR='L';
    elseif LorR == 0
        LR='R';
    end

    sub=textread(SUB_LIST,'%s');
    sub_num=length(sub);

    if ~exist('MPM_THRES','var') | isempty(MPM_THRES)
        MPM_THRES=0.25;
    end

    group_hi=zeros(1,MAX_CL_NUM);
    group_vi=zeros(1,MAX_CL_NUM);
    for kc=3:MAX_CL_NUM
        mpm_file1=strcat(PWD,'/MPM_40_',num2str(VOX_SIZE),'mm/',num2str(VOX_SIZE),'mm_',PART,'_',LR,'_',num2str(kc-1),'_MPM_thr',num2str(MPM_THRES*100),'_group.nii.gz');
        mpm1=load_untouch_nii(mpm_file1);
        mpmimg1=mpm1.img;
        mpm_file2=strcat(PWD,'/MPM_40_',num2str(VOX_SIZE),'mm/',num2str(VOX_SIZE),'mm_',PART,'_',LR,'_',num2str(kc),'_MPM_thr',num2str(MPM_THRES*100),'_group.nii.gz');
        mpm2=load_untouch_nii(mpm_file2);
        mpmimg2=mpm2.img;

        xmatrix = zeros(kc,kc-1);
        xi = zeros(kc,1);
        for i = 1:kc
            index_kc = mpmimg2==i;
            for j = 1:kc-1
                index_ij = find(mpmimg1(index_kc)==j);
                xmatrix(i,j) = length(index_ij);
            end
            xi(i,1) = max(xmatrix(i,:))/sum(xmatrix(i,:));
        end
        group_hi(1,kc) = mean(xi);

        [nminfo,minfo,group_vi(1,kc)]=my_nmi(mpmimg1,mpmimg2);
    end

    if ~exist(strcat(PWD,'/test_validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm')) mkdir(strcat(PWD,'/test_validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm'));end
    save(strcat(PWD,'/test_validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',PART,'_',LR,'_index_group_hi.mat'),'group_hi','group_vi');

    fp=fopen(strcat(PWD,'/test_validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',PART,'_',LR,'_index_group_hi_vi.txt'),'at');
    if fp
        for kc=3:MAX_CL_NUM
            fprintf(fp,'cluster_num: %d -> %d \ngroup_hierarchy_index: %f\ngroup_variation_of_info: %f\n\n',kc-1,kc,group_hi(1,kc),group_vi(1,kc));
        end
    end
    fclose(fp);


function validation_indi_hi_vi(PWD,PREFIX,PART,SUB_LIST,METHOD,VOX_SIZE,MAX_CL_NUM,MPM_THRES,GROUP_THRES,LorR)

    if LorR == 1
        LR='L';
    elseif LorR == 0
        LR='R';
    end

    sub=textread(SUB_LIST,'%s');
    sub_num=length(sub);

    if ~exist('MPM_THRES','var') | isempty(MPM_THRES)
        MPM_THRES=0.25;
    end

    MASK_FILE=strcat(PWD,'/group_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',PART,'_',LR,'_roimask_thr',num2str(GROUP_THRES),'.nii');  
    MASK_NII=load_untouch_nii(MASK_FILE);                                                                                                 
    MASK=MASK_NII.img; 

    indi_hi=zeros(sub_num,MAX_CL_NUM);
    indi_vi=zeros(sub_num,MAX_CL_NUM);
    for kc=3:MAX_CL_NUM
        for ti=1:sub_num
            mpm_file1=strcat(PWD,'/',sub{ti},'/',PREFIX,'_',sub{ti},'_',PART,'_',LR,'_',METHOD,'/',num2str(VOX_SIZE),'mm/',num2str(VOX_SIZE),'mm_',PART,'_',LR,'_',num2str(kc-1),'_MNI_relabel_group.nii');
            mpm1=load_untouch_nii(mpm_file1);
            mpmimg1=mpm1.img;
            mpm_file2=strcat(PWD,'/',sub{ti},'/',PREFIX,'_',sub{ti},'_',PART,'_',LR,'_',METHOD,'/',num2str(VOX_SIZE),'mm/',num2str(VOX_SIZE),'mm_',PART,'_',LR,'_',num2str(kc),'_MNI_relabel_group.nii');
            mpm2=load_untouch_nii(mpm_file2);
            mpmimg2=mpm2.img;
	    mpmimg1=mpmimg1.*MASK;
	    mpmimg2=mpmimg2.*MASK;

            xmatrix = zeros(kc,kc-1);
            xi = zeros(kc,1);
            for i = 1:kc
                index_kc = mpmimg2==i;
                for j = 1:kc-1
                    index_ij = find(mpmimg1(index_kc)==j);
                    xmatrix(i,j) = length(index_ij);
                end
                xi(i,1) = max(xmatrix(i,:))/sum(xmatrix(i,:));
            end
            indi_hi(ti,kc) = mean(xi);

            [nminfo,minfo,indi_vi(ti,kc)]=my_nmi(mpmimg1,mpmimg2);
        end
    end

    if ~exist(strcat(PWD,'/test_validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm')) mkdir(strcat(PWD,'/test_validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm'));end
    save(strcat(PWD,'/test_validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',PART,'_',LR,'_index_indi_hi.mat'),'indi_hi','indi_vi');

    fp=fopen(strcat(PWD,'/test_validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',PART,'_',LR,'_index_indi_hi_vi.txt'),'at');
    if fp
        for kc=3:MAX_CL_NUM
            fprintf(fp,'cluster_num: %d -> %d\navg_indi_hi: %f\nstd_indi_hi: %f\nmedian_indi_hi: %f\navg_indi_vi: %f\nstd_indi_vi: %f\nmedian_indi_vi: %f\n\n',kc-1,kc,mean(indi_hi(:,kc)),std(indi_hi(:,kc)),median(indi_hi(:,kc)),mean(indi_vi(:,kc)),std(indi_vi(:,kc)),median(indi_vi(:,kc)));
        end
    end
    fclose(fp);


%TpD
%img1='';img2='';
%
%se=strel(ones(3,3,3));
%
%for i=1:n
%    mat{i}=img1;mat{i}(img1~=i)=0;
%end
%for i=1:n
%    for j=1:n
%        if i~=j
%            tmp=mat{i};tmp=imdilate(tmp,se);tmp=tmp.*mat{j};con1(j,i)=length(find(tmp~=0));
%        end
%    end
%end
%sum1=sum(con1,2);
%con1=con1./sum1(:,ones(1,n));
%
%for i=1:n
%    mat{i}=img2;mat{i}(img2~=i)=0;
%end
%for i=1:n
%    for j=1:n
%        if i~=j
%            tmp=mat{i};tmp=imdilate(tmp,se);tmp=tmp.*mat{j};con2(j,i)=length(find(tmp~=0));
%        end
%    end
%end
%sum2=sum(con2,2);
%con2=con2./sum2(:,ones(1,n));
%
%v_con1=reshape(con1',1,[]);
%v_con2=reshape(con2',1,[]);
%tpd=pdist([v_con1;v_con2],'cosine');
