function validation_leave_one_out(PWD,PREFIX,PART,SUB_LIST,METHOD,VOX_SIZE,MAX_CL_NUM,POOL_SIZE,GROUP_THRES,MPM_THRES,LorR)

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

    GROUP_THRES=GROUP_THRES*100;
    MASK_FILE=strcat(PWD,'/group_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',PART,'_',LR,'_roimask_thr',num2str(GROUP_THRES),'.nii.gz');
    MASK_NII=load_untouch_nii(MASK_FILE);
    MASK=MASK_NII.img; 

    cv=zeros(sub_num,MAX_CL_NUM);
    dice=zeros(sub_num,MAX_CL_NUM);
    nminfo=zeros(sub_num,MAX_CL_NUM);
    vi=zeros(sub_num,MAX_CL_NUM);

    % before MATLAB R2013b
    if matlabpool('size')==0
        matlabpool(POOL_SIZE);
    end; 

    for kc=2:MAX_CL_NUM
        parfor ti=1:sub_num
            sub1=sub;
            sub1(ti)=[];
            dice_m=zeros(kc,1);
            
            vnii_ref_file=strcat(PWD,'/',sub{ti},'/',PREFIX,'_',sub{ti},'_',PART,'_',LR,'_',METHOD,'/',num2str(VOX_SIZE),'mm/',num2str(VOX_SIZE),'mm_',PART,'_',LR,'_',num2str(kc),'_MNI_relabel_group.nii.gz');
            vnii_ref=load_untouch_nii(vnii_ref_file);
            mpm_cluster1=vnii_ref.img;
            mpm_cluster2=cluster_mpm_validation(PWD,PREFIX,PART,sub1,METHOD,VOX_SIZE,kc,MPM_THRES,LorR);
            mpm_cluster1=mpm_cluster1.*MASK;
            mpm_cluster2=mpm_cluster2.*MASK;


            %compute dice coefficent
            dice(ti,kc)=v_dice(mpm_cluster1,mpm_cluster2,kc);
            
            %compute the normalized mutual information and variation of information
            [nminfo(ti,kc),vi(ti,kc)]=v_nmi(mpm_cluster1,mpm_cluster2);
            
            %compute cramer V
            cv(ti,kc)=v_cramerv(mpm_cluster1,mpm_cluster2);
            
            disp(['leave_one_out: ',PART,'_',LR,' kc=',num2str(kc),' ',num2str(ti),'/',num2str(sub_num)]);
        end
    end
    % matlabpool close

    if ~exist(strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm'))
        mkdir(strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm'));
    end
    save(strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',PART,'_',LR,'_index_leave_one_out.mat'),'dice','nminfo','cv','vi');

    fp=fopen(strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',PART,'_',LR,'_index_leave_one_out.txt'),'at');
    if fp 
        for kc=2:MAX_CL_NUM
            fprintf(fp,'clster_num: %d\nmcv: %f, std_cv: %f\nmdice: %f, std_dice: %f\nnmi: %f,std_nmi: %f\nmvi: %f,std_vi: %f\n\n',kc,nanmean(cv(:,kc)),nanstd(cv(:,kc)),nanmean(dice(:,kc)),nanstd(dice(:,kc)),nanmean(nminfo(:,kc)),nanstd(nminfo(:,kc)),nanmean(vi(:,kc)),nanstd(vi(:,kc)));
        end
    end
    fclose(fp);

