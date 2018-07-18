IF EXISTS (SELECT TOP 1 1 FROM sys.procedures WHERE name = 'uspGRImportScaleTicket')
	DROP PROCEDURE uspGRImportScaleTicket
GO

CREATE PROCEDURE uspGRImportScaleTicket 
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
			SELECT @Total = COUNT(1) FROM gasctmst 
			WHERE A4GLIdentity NOT IN (SELECT A4GLIdentity FROM gasctmst WHERE gasct_tic_no = 'o         ' AND  ISNULL(LTRIM(RTRIM(gasct_open_close_ind)),'') = '')
			AND   ISNULL(gasct_open_close_ind,'') <> 'C'
			AND   gasct_tic_type IN('I','O')
			
			SELECT @Total = @Total + COUNT(1) FROM gastlmst GT 
			WHERE GT.gastl_pd_yn <> 'Y' 
			AND GT.gastl_rec_type IN('C','M','1','2','3','4','5','6','7','8') 
				
		RETURN @Total

	END

	 BEGIN

	DECLARE @intCurrencyId INT
	SELECT @intCurrencyId =intDefaultCurrencyId FROM tblSMCompanyPreference

	DECLARE @CustomerId AS Id

	INSERT INTO @CustomerId
	
	SELECT DISTINCT intEntityId 
	FROM
	(
		SELECT DISTINCT CUS.intEntityId
		FROM gasctmst
		JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = gasct_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
		WHERE gasct_in_out_ind = 'I'
			AND NOT EXISTS (SELECT * FROM tblAPVendor WHERE strVendorId = CUS.strCustomerNumber)

		UNION ALL

		SELECT DISTINCT CUS.intEntityId
		FROM gastlmst
		JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = gastl_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
		WHERE gastl_pur_sls_ind = 'P'
			AND NOT EXISTS (SELECT * FROM tblAPVendor WHERE strVendorId = CUS.strCustomerNumber)

		UNION ALL

		SELECT DISTINCT CUS.intEntityId
		FROM gastrmst
		JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = gastr_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
		WHERE gastr_pur_sls_ind = 'P'
			AND NOT EXISTS (SELECT * FROM tblAPVendor WHERE strVendorId = CUS.strCustomerNumber)
    )t

	EXEC uspEMConvertCustomerToVendor @CustomerId
		,@UserId

	
	SET IDENTITY_INSERT tblSCTicket ON

	INSERT INTO tblSCTicket
	(
	 intConcurrencyId
	,intTicketId
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
	 intConcurrencyId 		   = 1
	,intTicketId       		   = A4GLIdentity
	,strTicketStatus		   = CASE WHEN ISNULL(LTRIM(RTRIM(gasct_open_close_ind)),'') = '' THEN 'O' ELSE LTRIM(RTRIM(gasct_open_close_ind)) END
	,strTicketNumber		   = LTRIM(RTRIM(gasct_tic_no))
	,intScaleSetupId		   = SS.intScaleSetupId
	,intTicketPoolId		   = SS.intTicketPoolId
	,intTicketLocationId	   = CL.intCompanyLocationId
	,intTicketType			   = CASE	
										WHEN gasct_tic_type IN ('I','O')  THEN 1
								 		WHEN gasct_tic_type = ('X')       THEN 2 
								 		WHEN gasct_tic_type = ('M')       THEN 3
								 		WHEN gasct_tic_type = ('T')       THEN 4
								 		ELSE 5
								 END
    ,intTicketTypeId		   = CASE WHEN gasct_tic_type ='I' THEN 1 ELSE 2 END
	,strInOutFlag			   = LTRIM(RTRIM(gasct_in_out_ind))
	,dtmTicketDateTime		   = dbo.fnCTConvertToDateTime(gasct_rev_dt,null)
	,dtmTicketTransferDateTime = NULL
	,dtmTicketVoidDateTime	   = NULL
	,intProcessingLocationId   = CL.intCompanyLocationId
	,strScaleOperatorUser	   = ISNULL(LTRIM(RTRIM(gasct_weigher)),'')
	,intEntityScaleOperatorId  = 0
	,strTruckName			   = LTRIM(RTRIM(gasct_truck_id))
	,strDriverName			   = LTRIM(RTRIM(gasct_driver))
	,ysnDriverOff			   = dbo.fnCTConvertYNToBit(gasct_driver_on_yn,0)
	,ysnSplitWeightTicket	   = dbo.fnCTConvertYNToBit(gasct_split_wgt_yn,0)
	,ysnGrossManual			   = dbo.fnCTConvertYNToBit(gasct_gross_manual_yn,0)
	,dblGrossWeight			   = gasct_gross_wgt
	,dblGrossWeightOriginal	   = gasct_orig_gross_wgt
	,dblGrossWeightSplit1	   = gasct_spl_gross_wgt1
	,dblGrossWeightSplit2	   = gasct_spl_gross_wgt2
	,dtmGrossDateTime		   = dbo.fnCTConvertToDateTime(gasct_gross_rev_dt,gasct_gross_time)
	,intGrossUserId			   = NULL
	,ysnTareManual			   = dbo.fnCTConvertYNToBit(gasct_tare_manual_yn,0)
	,dblTareWeight			   = gasct_tare_wgt
	,dblTareWeightOriginal	   = gasct_orig_tare_wgt
	,dblTareWeightSplit1	   = gasct_spl_tare_wgt1
	,dblTareWeightSplit2	   = gasct_spl_tare_wgt2
	,dtmTareDateTime		   = dbo.fnCTConvertToDateTime(gasct_tare_rev_dt,gasct_tare_time)
	,intTareUserId			   = NULL
	,dblGrossUnits			   = gasct_gross_un
	,dblNetUnits			   = gasct_net_un
	,strItemUOM				   = UM.strUnitMeasure
	,intCustomerId			   = t.intEntityId
	,strDistributionOption	   = CASE 
								 	WHEN LTRIM(RTRIM(GT.gasct_dist_option))='C' THEN 'CNT' 
								 	WHEN LTRIM(RTRIM(GT.gasct_dist_option))='M' THEN 'SPT' 
								 	ELSE LTRIM(RTRIM(GT.gasct_dist_option))  
								 END
	,intStorageScheduleTypeId  = ST.intStorageScheduleTypeId
	,intDiscountSchedule	   = DS.intDiscountScheduleId
	,strDiscountLocation	   = ''
	,dtmDeferDate			   = dbo.fnCTConvertToDateTime(gasct_defer_rev_dt,null)
	,strContractNumber		   = LTRIM(RTRIM(gasct_cnt_no))
	,intContractSequence	   = gasct_cnt_seq
	,strContractLocation	   = LTRIM(RTRIM(gasct_cnt_loc))
	,dblUnitPrice			   = gasct_un_prc
	,dblUnitBasis			   = 0
	,dblTicketFees			   = gasct_fees
	,intCurrencyId			   = ISNULL(CY.intCurrencyID,@intCurrencyId)
	,dblCurrencyRate		   = gasct_currency_rt
	,strTicketComment		   = LTRIM(RTRIM(gasct_comment))
	,strCustomerReference	   = LTRIM(RTRIM(gasct_cus_ref_no))
	,ysnTicketPrinted		   = NULL
	,ysnPlantTicketPrinted	   = dbo.fnCTConvertYNToBit(gasct_plant_prt_ind,0)
	,ysnGradingTagPrinted	   = dbo.fnCTConvertYNToBit(gasct_grade_prt_ind,0)
	,intHaulerId			   = NULL
	,intFreightCarrierId	   = NULL
	,dblFreightRate			   = NULL
	,dblFreightAdjustment	   = NULL
	,intFreightCurrencyId	   = ISNULL(FY.intCurrencyID,@intCurrencyId)
	,dblFreightCurrencyRate	   = gasct_frt_currency_rt
	,strFreightCContractNumber = LTRIM(RTRIM(gasct_frt_currency_cnt)) 
	,ysnFarmerPaysFreight	   = dbo.fnCTConvertYNToBit(gasct_frt_deduct_yn,0)
	,strLoadNumber			   = LTRIM(RTRIM(gasct_load_no))
	,intLoadLocationId		   = CL.intCompanyLocationId
	,intAxleCount			   = NULL
	,strBinNumber			   = LTRIM(RTRIM(gasct_bin_no))
	,strPitNumber			   = LTRIM(RTRIM(gasct_pit_no))
	,intGradingFactor		   = gasct_grade
	,strVarietyType			   = LTRIM(RTRIM(gasct_variety))
	,strFarmNumber			   = NULL
	,strFieldNumber			   = NULL
	,strDiscountComment		   = LTRIM(RTRIM(gasct_tic_comment))
	,intCommodityId			   = CO.intCommodityId
	,intDiscountId			   = 1
	,intContractId			   = [Contract].intContractDetailId
	,intDiscountLocationId	   = NULL
	,intItemId				   = IM.intItemId
	,intEntityId			   = t.intEntityId
	,intItemUOMIdFrom		   = IU.intItemUOMId
	,intItemUOMIdTo			   = IU.intItemUOMId
	,ysnCusVenPaysFees		   = CAST(0 AS BIT)
	FROM	gasctmst GT
			JOIN	tblSCScaleSetup			SS	ON	LTRIM(RTRIM(SS.strStationShortDescription)) collate Latin1_General_CI_AS = LTRIM(RTRIM(GT.gasct_loc_no)) + LTRIM(RTRIM(GT.gasct_scale_id))
			JOIN    tblSCTicketPool         TP  ON TP.intTicketPoolId=SS.intTicketPoolId --AND TP.strTicketPool  collate Latin1_General_CI_AS =LTRIM(RTRIM(GT.gasct_loc_no)) + LTRIM(RTRIM(GT.gasct_scale_id))---Added
			JOIN	tblSMCompanyLocation	CL	ON	LTRIM(RTRIM(CL.strLocationNumber)) collate Latin1_General_CI_AS  = LTRIM(RTRIM(GT.gasct_loc_no))
		    JOIN	tblICCommodity			CO	ON	LTRIM(RTRIM(CO.strCommodityCode))  collate Latin1_General_CI_AS = LTRIM(RTRIM(GT.gasct_com_cd))
		    JOIN	tblICItem				IM	ON	LTRIM(RTRIM(IM.strItemNo)) = LTRIM(RTRIM(CO.strCommodityCode))
		    JOIN	tblICItemUOM			IU	ON	IU.intItemId	=	IM.intItemId AND IU.ysnStockUnit =1 ---- IU.intUnitMeasureId = SS.intUnitMeasureId
		    JOIN	tblICUnitMeasure		UM	ON	UM.intUnitMeasureId	= SS.intUnitMeasureId
			JOIN    tblGRStorageType        ST  ON  ST.strStorageTypeCode =  CASE 
																				WHEN LTRIM(RTRIM(GT.gasct_dist_option))='C' THEN 'CNT' 
																				WHEN LTRIM(RTRIM(GT.gasct_dist_option))='M' THEN 'SPT' 
																				ELSE LTRIM(RTRIM(GT.gasct_dist_option))  
																			 END 
																			 collate Latin1_General_CI_AS
			JOIN (
					SELECT * FROM 
					(
						SELECT	EY.intEntityId,EY.strName,EY.strEntityNo,ET.strType,ROW_NUMBER() OVER (PARTITION BY strEntityNo,ET.strType ORDER BY EY.intEntityId) intRowNum
						FROM	tblEMEntity EY
						JOIN	tblEMEntityType			ET	ON	ET.intEntityId	=	EY.intEntityId
						 WHERE  ET.strType IN('Vendor','Customer') AND ISNULL(EY.strEntityNo,'')<>'' --AND EY.ysnActive =1
					) t  WHERE intRowNum = 1

				)   t ON LTRIM(RTRIM(t.strEntityNo)) collate Latin1_General_CI_AS	= LTRIM(RTRIM(GT.gasct_cus_no))
				AND t.strType = CASE  WHEN GT.gasct_tic_type='I' THEN 'Vendor' ELSE 'Customer' END

	LEFT	JOIN	tblGRDiscountSchedule	DS	ON	DS.strDiscountDescription collate Latin1_General_CI_AS =  CASE WHEN LTRIM(RTRIM(GT.gasct_disc_schd_no))='0' THEN CO.strDescription +' Discount' ELSE LTRIM(RTRIM(GT.gasct_disc_schd_no)) END AND DS.intCommodityId = CO.intCommodityId
	LEFT	JOIN	tblSMCurrency			CY	ON	LTRIM(RTRIM(CY.strCurrency)) collate Latin1_General_CI_AS = LTRIM(RTRIM(GT.gasct_currency))
	LEFT	JOIN	tblSMCurrency			FY	ON	LTRIM(RTRIM(FY.strCurrency)) collate Latin1_General_CI_AS = LTRIM(RTRIM(GT.gasct_frt_currency))		
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
			  ) [Contract] ON LEFT([Contract].strContractNumber,8) = LTRIM(RTRIM(GT.gasct_cnt_no)) collate Latin1_General_CI_AS 
			  			  AND [Contract].intContractSeq	 = gasct_cnt_seq 
			  			  AND [Contract].intEntityId	 = t.intEntityId
			  			  AND [Contract].intCommodityId	 = CO.intCommodityId
			  			  AND [Contract].intContractTypeId = CASE WHEN GT.gasct_tic_type = 'I' THEN 1 ELSE 2 END

	WHERE A4GLIdentity NOT IN (SELECT A4GLIdentity FROM gasctmst WHERE gasct_tic_no = 'o         ' AND  ISNULL(LTRIM(RTRIM(gasct_open_close_ind)),'') = '')
	AND   ISNULL(GT.gasct_open_close_ind,'') <> 'C'
	AND   GT.gasct_tic_type IN('I','O')

	SET IDENTITY_INSERT tblSCTicket OFF

	UPDATE tblSCTicket SET strDistributionOption='CNT',intStorageScheduleTypeId = -2 WHERE intContractId >0
	UPDATE tblSCTicket SET ysnHasGeneratedTicketNumber = 1
	UPDATE tblCTContractHeader SET ysnUnlimitedQuantity = 0 WHERE ISNULL(ysnUnlimitedQuantity,0) = 0	

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
	JOIN tblSCTicket k ON	k.intTicketId = b.A4GLIdentity AND b.gasct_disc_cd is not null
	JOIN tblGRDiscountSchedule d ON d.intDiscountScheduleId = k.intDiscountSchedule
	JOIN tblGRDiscountScheduleCode c ON c.intDiscountScheduleId = d.intDiscountScheduleId AND c.intStorageTypeId = @intStorageScheduleTypeId
	JOIN tblICItem i on i.intItemId = c.intItemId AND i.strShortName = b.gasct_disc_cd  COLLATE Latin1_General_CI_AS
	WHERE b.gasct_disc_cd IS NOT NULL	
	
	EXEC uspGRImportSettleScaleTicket

	END

END

GO