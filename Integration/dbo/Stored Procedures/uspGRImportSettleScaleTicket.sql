IF EXISTS (SELECT TOP 1 1 FROM sys.procedures WHERE name = 'uspGRImportSettleScaleTicket')
	DROP PROCEDURE uspGRImportSettleScaleTicket
GO

CREATE PROCEDURE uspGRImportSettleScaleTicket 
	 @Checking BIT = 0
	,@UserId INT = 0
	,@Total INT = 0 OUTPUT
AS
BEGIN
	
	--================================================
	--     IMPORT Scale Station SetUps
	--================================================
	IF (@Checking = 1)
	BEGIN
		
		IF EXISTS(SELECT 1 FROM tblSCTicket)
			SELECT @Total = 0
		ELSE
			SELECT @Total = COUNT(1) FROM gastlmst GT WHERE GT.gastl_pd_yn <> 'Y' AND GT.gastl_rec_type IN('C','M','1','2','3','4','5','6','7','8')
				
		RETURN @Total

	END

	DECLARE @intCurrencyId INT
	DECLARE @intScaleSetupId INT
	DECLARE @intTicketPoolId INT
	
	SELECT @intCurrencyId =intDefaultCurrencyId FROM tblSMCompanyPreference
	SELECT TOP 1 @intScaleSetupId = intScaleSetupId FROM tblSCScaleSetup
	SELECT TOP 1 @intTicketPoolId = intTicketPoolId FROM tblSCTicketPool
	
	INSERT INTO tblSCTicket
	(
	 intConcurrencyId	
	,strTicketStatus
	,strTicketNumber
	,intScaleSetupId
	,intTicketPoolId
	,intTicketLocationId
	,intTicketType
	,intTicketTypeId
	,strInOutFlag
	,dtmTicketDateTime
	,dtmTicketTransferDateTime
	,dtmTicketVoidDateTime
	,intProcessingLocationId
	,strScaleOperatorUser
	,intEntityScaleOperatorId
	,strTruckName
	,strDriverName
	,ysnDriverOff
	,ysnSplitWeightTicket
	,ysnGrossManual
	,dblGrossWeight
	,dblGrossWeightOriginal
	,dblGrossWeightSplit1
	,dblGrossWeightSplit2
	,dtmGrossDateTime
	,intGrossUserId
	,ysnTareManual
	,dblTareWeight
	,dblTareWeightOriginal
	,dblTareWeightSplit1
	,dblTareWeightSplit2
	,dtmTareDateTime
	,intTareUserId
	,dblGrossUnits
	,dblNetUnits
	,strItemUOM
	,intCustomerId
	,strDistributionOption
	,intStorageScheduleTypeId
	,intDiscountSchedule
	,strDiscountLocation
	,dtmDeferDate
	,strContractNumber
	,intContractSequence
	,strContractLocation
	,dblUnitPrice
	,dblUnitBasis
	,dblTicketFees
	,intCurrencyId
	,dblCurrencyRate
	,strTicketComment
	,strCustomerReference
	,ysnTicketPrinted
	,ysnPlantTicketPrinted
	,ysnGradingTagPrinted
	,intHaulerId
	,intFreightCarrierId
	,dblFreightRate
	,dblFreightAdjustment
	,intFreightCurrencyId
	,dblFreightCurrencyRate
	,strFreightCContractNumber
	,ysnFarmerPaysFreight
	,strLoadNumber
	,intLoadLocationId
	,intAxleCount
	,strBinNumber
	,strPitNumber
	,intGradingFactor
	,strVarietyType
	,strFarmNumber
	,strFieldNumber
	,strDiscountComment
	,strCommodityCode
	,intCommodityId
	,intDiscountId
	,intContractId
	,intDiscountLocationId
	,intItemId
	,intEntityId
	,intItemUOMIdFrom
	,intItemUOMIdTo
	,ysnCusVenPaysFees
	)
	 SELECT	 
	 intConcurrencyId 		   =  A4GLIdentity
	,strTicketStatus		   = 'O'
	,strTicketNumber		   = LTRIM(RTRIM(gastl_tic_no))
	,intScaleSetupId		   = @intScaleSetupId
	,intTicketPoolId		   = @intTicketPoolId
	,intTicketLocationId	   = CL.intCompanyLocationId
	,intTicketType			   = CASE WHEN GT.gastl_pur_sls_ind='P' THEN 1 ELSE 2 END
	,intTicketTypeId		   = CASE WHEN GT.gastl_pur_sls_ind='P' THEN 1 ELSE 2 END
	,strInOutFlag			   = CASE WHEN GT.gastl_pur_sls_ind='P' THEN 'I' ELSE 'O' END
	,dtmTicketDateTime		   = dbo.fnCTConvertToDateTime(gastl_stl_rev_dt,null)
	,dtmTicketTransferDateTime = NULL
	,dtmTicketVoidDateTime	   = NULL
	,intProcessingLocationId   = CL.intCompanyLocationId
	,strScaleOperatorUser	   = ISNULL(LTRIM(RTRIM(gastl_user_id)),'')
	,intEntityScaleOperatorId  = 0
	,strTruckName			   = NULL
	,strDriverName			   = NULL
	,ysnDriverOff			   = NULL
	,ysnSplitWeightTicket	   = NULL
	,ysnGrossManual			   = NULL
	,dblGrossWeight			   = gastl_no_un
	,dblGrossWeightOriginal	   = gastl_no_un
	,dblGrossWeightSplit1	   = NULL
	,dblGrossWeightSplit2	   = NULL
	,dtmGrossDateTime		   = NULL
	,intGrossUserId			   = NULL
	,ysnTareManual			   = 0
	,dblTareWeight			   = 0
	,dblTareWeightOriginal	   = 0
	,dblTareWeightSplit1	   = NULL
	,dblTareWeightSplit2	   = NULL
	,dtmTareDateTime		   = NULL
	,intTareUserId			   = NULL
	,dblGrossUnits			   = gastl_no_un
	,dblNetUnits			   = gastl_no_un
	,strItemUOM				   = UM.strUnitMeasure
	,intCustomerId			   = t.intEntityId
	,strDistributionOption	   = CASE 
								 	WHEN LTRIM(RTRIM(GT.gastl_rec_type))='C' THEN 'CNT' 
								 	WHEN LTRIM(RTRIM(GT.gastl_rec_type))='M' THEN 'SPT' 
								 	ELSE LTRIM(RTRIM(GT.gastl_rec_type))  
								 END
	,intStorageScheduleTypeId  = ST.intStorageScheduleTypeId
	,intDiscountSchedule	   = DS.intDiscountScheduleId
	,strDiscountLocation	   = ''
	,dtmDeferDate			   = NULL
	,strContractNumber		   = LTRIM(RTRIM(gastl_cnt_no))
	,intContractSequence	   = gastl_cnt_seq_no
	,strContractLocation	   = LTRIM(RTRIM(gastl_cnt_loc_wrtn))
	,dblUnitPrice			   = gastl_un_prc
	,dblUnitBasis			   = 0
	,dblTicketFees			   = 0
	,intCurrencyId			   = ISNULL(CY.intCurrencyID,@intCurrencyId)
	,dblCurrencyRate		   = gastl_currency_rt
	,strTicketComment		   = LTRIM(RTRIM(gastl_tic_comment))
	,strCustomerReference	   = LTRIM(RTRIM(gastl_cus_ref_no))
	,ysnTicketPrinted		   = NULL
	,ysnPlantTicketPrinted	   = 0
	,ysnGradingTagPrinted	   = 0
	,intHaulerId			   = NULL
	,intFreightCarrierId	   = NULL
	,dblFreightRate			   = NULL
	,dblFreightAdjustment	   = NULL
	,intFreightCurrencyId	   = ISNULL(CY.intCurrencyID,@intCurrencyId)
	,dblFreightCurrencyRate	   = NULL
	,strFreightCContractNumber = NULL
	,ysnFarmerPaysFreight	   = NULL
	,strLoadNumber			   = NULL
	,intLoadLocationId		   = CL.intCompanyLocationId
	,intAxleCount			   = NULL
	,strBinNumber			   = NULL
	,strPitNumber			   = NULL
	,intGradingFactor		   = NULL
	,strVarietyType			   = NULL
	,strFarmNumber			   = NULL
	,strFieldNumber			   = NULL
	,strDiscountComment		   = LTRIM(RTRIM(gastl_tic_comment))
	,strCommodityCode		   = LTRIM(RTRIM(gastl_com_cd))
	,intCommodityId			   = CO.intCommodityId
	,intDiscountId			   = 1
	,intContractId			   = [Contract].intContractDetailId
	,intDiscountLocationId	   = NULL
	,intItemId				   = IM.intItemId
	,intEntityId			   = t.intEntityId
	,intItemUOMIdFrom		   = IU.intItemUOMId
	,intItemUOMIdTo			   = IU.intItemUOMId
	,ysnCusVenPaysFees		   = CAST(0 AS BIT)

	FROM	gastlmst GT
	JOIN (
					SELECT * FROM 
					(
						SELECT	EY.intEntityId,EY.strName,EY.strEntityNo,ET.strType,ROW_NUMBER() OVER (PARTITION BY strEntityNo,ET.strType ORDER BY EY.intEntityId) intRowNum
						FROM	tblEMEntity EY
						JOIN	tblEMEntityType			ET	ON	ET.intEntityId	=	EY.intEntityId
						 WHERE  ET.strType IN('Vendor','Customer') AND ISNULL(EY.strEntityNo,'')<>'' --AND EY.ysnActive =1
					) t  WHERE intRowNum = 1

				)   t ON LTRIM(RTRIM(t.strEntityNo)) collate Latin1_General_CI_AS	= LTRIM(RTRIM(GT.gastl_cus_no))
				AND t.strType = CASE  WHEN GT.gastl_pur_sls_ind='P' THEN 'Vendor' ELSE 'Customer' END 
	JOIN	tblSMCompanyLocation	CL	ON	LTRIM(RTRIM(CL.strLocationNumber)) collate Latin1_General_CI_AS  = LTRIM(RTRIM(GT.gastl_loc_no))
	JOIN	tblICCommodity			CO	ON	LTRIM(RTRIM(CO.strCommodityCode))  collate Latin1_General_CI_AS = LTRIM(RTRIM(GT.gastl_com_cd))	
	JOIN	tblICItem				IM	ON	LTRIM(RTRIM(IM.strItemNo)) = LTRIM(RTRIM(CO.strCommodityCode))
	JOIN	tblICItemUOM			IU	ON	IU.intItemId	=	IM.intItemId AND IU.ysnStockUnit =1
	JOIN	tblICUnitMeasure		UM	ON	UM.intUnitMeasureId	= IU.intUnitMeasureId--SS.intUnitMeasureId
	JOIN    tblGRStorageType        ST  ON  ST.strStorageTypeCode =  CASE 
																				WHEN LTRIM(RTRIM(GT.gastl_rec_type))='C' THEN 'CNT' 
																				WHEN LTRIM(RTRIM(GT.gastl_rec_type))='M' THEN 'SPT' 
																				ELSE LTRIM(RTRIM(GT.gastl_rec_type))  
																			 END 
																			 collate Latin1_General_CI_AS
	LEFT JOIN	tblSMCurrency			 CY	ON	LTRIM(RTRIM(CY.strCurrency)) collate Latin1_General_CI_AS = LTRIM(RTRIM((GT.gastl_currency)))
	LEFT	JOIN	tblGRDiscountSchedule	DS	ON	DS.strDiscountDescription collate Latin1_General_CI_AS =  CASE WHEN LTRIM(RTRIM(GT.gastl_disc_schd_no))='0' THEN CO.strDescription +' Discount' ELSE LTRIM(RTRIM(GT.gastl_disc_schd_no)) END AND DS.intCommodityId = CO.intCommodityId
	LEFT JOIN
			 (
				SELECT CH.[intContractTypeId]
					  ,CH.[strContractNumber]
					  ,CH.[intEntityId]
					  ,CH.[intCommodityId] 
					  ,CH.intContractHeaderId
					  ,CD.intContractDetailId
					  ,CD.intContractSeq
				FROM tblCTContractHeader CH
				JOIN tblCTContractDetail CD ON CD.intContractHeaderId =CH.intContractHeaderId
			  ) [Contract] ON [Contract].strContractNumber = LTRIM(RTRIM(GT.gastl_cnt_no)) collate Latin1_General_CI_AS 
			  			  AND [Contract].intContractSeq	 = gastl_cnt_seq_no 
			  			  AND [Contract].intEntityId		 = t.intEntityId
			  			  AND [Contract].intCommodityId	 = CO.intCommodityId
			  			  AND [Contract].intContractTypeId = CASE WHEN GT.gastl_pur_sls_ind='P' THEN 1 ELSE 2 END
	WHERE GT.gastl_pd_yn <> 'Y' AND GT.gastl_rec_type IN('C','M','1','2','3','4','5','6','7','8')
	AND LTRIM(RTRIM(gastl_tic_no)) NOT IN('14170j0000','473468')
	
  
	UPDATE tblSCTicket SET strDistributionOption='CNT',intStorageScheduleTypeId = -2 WHERE intContractId >0
	UPDATE tblSCTicket SET ysnHasGeneratedTicketNumber = 1
  
	UPDATE CD
	SET CD.intContractStatusId = 4
	FROM tblSCTicket SC JOIN tblCTContractDetail CD ON CD.intContractDetailId = SC.intContractId
	WHERE CD.intContractStatusId = 5 AND SC.strTicketStatus='O'
  
  
     DECLARE @intStorageScheduleTypeId INT
     SELECT	@intStorageScheduleTypeId = intStorageScheduleTypeId FROM tblGRStorageType WHERE strStorageTypeDescription = 'Default'
  
    INSERT INTO tblQMTicketDiscount (intConcurrencyId, dblGradeReading, strShrinkWhat, dblShrinkPercent, intDiscountScheduleCodeId, intTicketId, intTicketFileId, strSourceType, strDiscountChargeType)	
  	SELECT 
  	DISTINCT 
  	 1 AS intConcurrencyId
  	,gasct_reading AS dblGradeReading
  	,gasct_shrk_what AS strShrinkWhat
  	,gasct_shrk_pct AS dblShrinkPercent
  	,intDiscountScheduleCodeId
  	,intTicketId
  	,intTicketId AS intTicketFileId
  	,'Scale' AS strSourceType
  	,'Dollar' strDiscountChargeType 
  	FROM (
  			SELECT	
  				gasct_disc_cd_1		gasct_disc_cd,
  				gasct_reading_1		gasct_reading,
  				gasct_disc_calc_1	gasct_disc_calc,
  				gasct_un_disc_amt_1 gasct_un_disc_amt,
  				gasct_shrk_what_1	gasct_shrk_what,
  				gasct_shrk_pct_1	gasct_shrk_pct,
  				A4GLIdentity		
  				FROM gasctmst 
  				WHERE gasct_disc_cd_1 IS NOT NULL
  
  			UNION ALL
  				SELECT gasct_disc_cd_2,gasct_reading_2,gasct_disc_calc_2,gasct_un_disc_amt_2,gasct_shrk_what_2,gasct_shrk_pct_2,A4GLIdentity      
  				FROM gasctmst  WHERE gasct_disc_cd_2 IS NOT NULL
  			UNION ALL
  			
  				SELECT gasct_disc_cd_3,gasct_reading_3,gasct_disc_calc_3,gasct_un_disc_amt_3,gasct_shrk_what_3,gasct_shrk_pct_3,A4GLIdentity
  				FROM gasctmst  WHERE gasct_disc_cd_3 IS NOT NULL AND gasct_disc_cd_3 <> gasct_disc_cd_4 AND gasct_disc_cd_4 <>'TW' 
  			UNION ALL
  				SELECT gasct_disc_cd_4,gasct_reading_4,gasct_disc_calc_4,gasct_un_disc_amt_4,gasct_shrk_what_4,gasct_shrk_pct_4,A4GLIdentity
  				FROM gasctmst  WHERE gasct_disc_cd_4 IS NOT NULL AND gasct_disc_cd_3 <> gasct_disc_cd_4 AND gasct_disc_cd_4 <>'TW'
  			UNION ALL
  				(
  				 SELECT disc_cd
  				 	,SUM(reading)
  				 	,SUM(disc_calc)
  				 	,SUM(un_disc)
  				 	,shrk_what
  				 	,SUM(gasct_shrk_pct)
  				 	,A4GLIdentity
  				 FROM (
  				 		SELECT 
  				 		 gasct_disc_cd_4 disc_cd
  				 		,Convert(FLOAT, gasct_reading_4) reading
  				 		,Convert(FLOAT, gasct_disc_calc_4) disc_calc
  				 		,Convert(FLOAT, gasct_un_disc_amt_4) un_disc
  				 		,gasct_shrk_what_4 shrk_what
  				 		,Convert(FLOAT, gasct_shrk_pct_4) gasct_shrk_pct
  				 		,A4GLIdentity
  				 	    FROM gasctmst
  				 	    WHERE gasct_disc_cd_4 IS NOT NULL
  				 	    	AND gasct_disc_cd_3 IS NOT NULL
  				 	    	AND gasct_disc_cd_3 = gasct_disc_cd_4
  				 	    	AND gasct_disc_cd_4 = 'TW'
  				 	
  				 	UNION ALL
  				 	
  				 	SELECT 
  				 		gasct_disc_cd_3
  				 		,Convert(FLOAT, gasct_reading_3)
  				 		,Convert(FLOAT, gasct_disc_calc_3)
  				 		,Convert(FLOAT, gasct_un_disc_amt_3)
  				 		,gasct_shrk_what_3
  				 		,Convert(FLOAT, gasct_shrk_pct_3)
  				 		,A4GLIdentity
  				 	    FROM gasctmst
  				 	    WHERE gasct_disc_cd_3 IS NOT NULL
  				 	    	AND gasct_disc_cd_4 IS NOT NULL
  				 	    	AND gasct_disc_cd_3 = gasct_disc_cd_4
  				 	    	AND gasct_disc_cd_3 = 'TW'
  				 	) t
  				 GROUP BY disc_cd
  				 	,shrk_what
  				 	,A4GLIdentity
  				 
  				) 
  			UNION ALL
  				SELECT gasct_disc_cd_5,gasct_reading_5,gasct_disc_calc_5,gasct_un_disc_amt_5,gasct_shrk_what_5,gasct_shrk_pct_5,A4GLIdentity
  				FROM gasctmst  WHERE gasct_disc_cd_5 IS NOT NULL 
  			UNION ALL
  				SELECT gasct_disc_cd_6,gasct_reading_6,gasct_disc_calc_6,gasct_un_disc_amt_6,gasct_shrk_what_6,gasct_shrk_pct_6,A4GLIdentity
  				FROM gasctmst  WHERE gasct_disc_cd_6 IS NOT NULL
  			UNION ALL
  				SELECT gasct_disc_cd_7,gasct_reading_7,gasct_disc_calc_7,gasct_un_disc_amt_7,gasct_shrk_what_7,gasct_shrk_pct_7,A4GLIdentity
  				FROM gasctmst  WHERE gasct_disc_cd_7 IS NOT NULL 
  			UNION ALL
  				SELECT gasct_disc_cd_8,gasct_reading_8,gasct_disc_calc_8,gasct_un_disc_amt_8,gasct_shrk_what_8,gasct_shrk_pct_8,A4GLIdentity
  				FROM gasctmst  WHERE gasct_disc_cd_8 IS NOT NULL  
  			UNION ALL
  				SELECT gasct_disc_cd_9,gasct_reading_9,gasct_disc_calc_9,gasct_un_disc_amt_9,gasct_shrk_what_9,gasct_shrk_pct_9,A4GLIdentity
  				FROM gasctmst  WHERE gasct_disc_cd_9 IS NOT NULL 
  			UNION ALL
  				SELECT gasct_disc_cd_10,gasct_reading_10,gasct_disc_calc_10,gasct_un_disc_amt_10,gasct_shrk_what_10,gasct_shrk_pct_10,A4GLIdentity
  				FROM gasctmst  WHERE gasct_disc_cd_10 IS NOT NULL 
  			UNION ALL
  				SELECT gasct_disc_cd_11,gasct_reading_11,gasct_disc_calc_11,gasct_un_disc_amt_11,gasct_shrk_what_11,gasct_shrk_pct_11,A4GLIdentity
  				FROM gasctmst  WHERE gasct_disc_cd_11 IS NOT NULL 
  			UNION ALL
  				SELECT gasct_disc_cd_12,gasct_reading_12,gasct_disc_calc_12,gasct_un_disc_amt_12,gasct_shrk_what_12,gasct_shrk_pct_12,A4GLIdentity
  				FROM gasctmst  WHERE gasct_disc_cd_12 IS NOT NULL
  	)b 
  	JOIN tblSCTicket k ON	k.intConcurrencyId = b.A4GLIdentity AND b.gasct_disc_cd is not null
  	JOIN tblGRDiscountSchedule d ON d.intDiscountScheduleId = k.intDiscountSchedule
  	JOIN tblGRDiscountScheduleCode c ON c.intDiscountScheduleId = d.intDiscountScheduleId AND c.intStorageTypeId = @intStorageScheduleTypeId
  	JOIN tblICItem i on i.intItemId = c.intItemId AND i.strShortName = b.gasct_disc_cd  COLLATE Latin1_General_CI_AS
  	WHERE b.gasct_disc_cd IS NOT NULL

	UPDATE tblSCTicket SET intConcurrencyId = 1

END

GO	