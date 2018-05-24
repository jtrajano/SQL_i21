IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspCTImportContract]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [uspCTImportContract]; 
GO 

CREATE PROCEDURE [dbo].[uspCTImportContract]
	@Checking BIT = 0,
	@UserId INT = 0,
	@Total INT = 0 OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

	DECLARE @ysnGA BIT = 0
    DECLARE @ysnPT BIT = 0

	SELECT TOP 1 @ysnGA = CASE WHEN ISNULL(coctl_ga, '') = 'Y' THEN 1 ELSE 0 END
			   , @ysnPT = CASE WHEN ISNULL(coctl_pt, '') = 'Y' THEN 1 ELSE 0 END 
	FROM coctlmst	

	DECLARE @defaultSalePerson AS INT, @defaultCurrencyId AS INT,
			@MaxContractId as INT

	SELECT @defaultSalePerson = intEntityId FROM tblARSalesperson WHERE strSalespersonId = 'CO'

	SELECT @defaultCurrencyId = intDefaultCurrencyId FROM tblSMCompanyPreference

	SELECT @MaxContractId = MAX(intContractHeaderId) FROM tblCTContractHeader 
	SET @MaxContractId = ISNULL(@MaxContractId, 0)

	IF(@Checking = 1)
	BEGIN
		IF @ysnGA = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'gacntmst')
		 BEGIN
			SELECT @Total =
				 COUNT(gacnt_cnt_no) 	
			FROM	gacntmst							CT
			JOIN	tblCTContractType			TY	ON	TY.strContractType	=	CASE	WHEN gacnt_pur_sls_ind IN ('1','P') THEN 'Purchase'  ELSE 'Sale' END
			JOIN	tblCTPricingType			PT	ON	PT.strPricingType	=	CASE	WHEN LTRIM(RTRIM(ISNULL(gacnt_pbhcu_ind,''))) = ''	 THEN 'DP (Priced Later)' 
																						WHEN LTRIM(RTRIM(ISNULL(gacnt_pbhcu_ind,''))) = 'B'  THEN 'Basis' 
																						WHEN LTRIM(RTRIM(ISNULL(gacnt_pbhcu_ind,''))) = 'H'  THEN 'HTA' 
																						WHEN LTRIM(RTRIM(ISNULL(gacnt_pbhcu_ind,''))) = 'P'  THEN 'Priced' 
																						WHEN LTRIM(RTRIM(ISNULL(gacnt_pbhcu_ind,''))) = 'U'  THEN 'Unit' 
																				END
			JOIN	tblARCustomer				CV	ON	LTRIM(RtRIM(CV.strCustomerNumber)) collate Latin1_General_CI_AS  = LTRIM(RtRIM(CT.gacnt_cus_no))  
			JOIN	tblICCommodity				CO	ON	LTRIM(RtRIM(CO.strCommodityCode)) collate Latin1_General_CI_AS = LTRIM(RtRIM(CT.gacnt_com_cd))
			JOIN	gacommst					CM	ON	LTRIM(RtRIM(CM.gacom_com_cd)) = CT.gacnt_com_cd
			JOIN	tblICUnitMeasure			UM	ON	LTRIM(RtRIM(UM.strUnitMeasure)) collate Latin1_General_CI_AS = LTRIM(RtRIM(gacom_un_desc))
			JOIN	tblICCommodityUnitMeasure	CU	ON	CU.intCommodityId = CO.intCommodityId AND CU.intUnitMeasureId = UM.intUnitMeasureId
			JOIN	tblCTContractText			TX	ON	TX.intContractType		= TY.intContractTypeId AND
													TX.intContractPriceType = PT.intPricingTypeId AND
													LTRIM(RtRIM(TX.strTextCode)) collate Latin1_General_CI_AS =  LTRIM(RtRIM(CT.gacnt_text_no))
			LEFT JOIN tblCTContractHeader		CH  ON CH.intEntityId = CV.intEntityId AND CH.intCommodityId = CO.intCommodityId
														AND CH.strContractNumber collate Latin1_General_CI_AS = CT.gacnt_cnt_no collate Latin1_General_CI_AS
														AND CH.intPricingTypeId = PT.intPricingTypeId
			WHERE gacnt_pur_sls_ind <> '1' AND (gacnt_un_bal <> 0 OR gacnt_un_bal_transit <> 0 OR gacnt_un_bal_unprc <> 0 OR gacnt_sched_un <> 0) AND CH.intContractHeaderId IS NULL
		END

		IF @ysnPT = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ptcntmst')
		 BEGIN
			SELECT @Total =	 COUNT(ptcnt_cnt_no) 	
			FROM	ptcntmst					CT
			JOIN	tblCTContractType			TY	ON	TY.strContractType	=	'Sale' 
			JOIN	tblCTPricingType			PT	ON	PT.strPricingType	=	'Cash'
			join    tblARCustomer C on LTRIM(RtRIM(C.strCustomerNumber)) collate Latin1_General_CI_AS  = LTRIM(RtRIM(CT.ptcnt_cus_no))
			where CT.ptcnt_line_no = 1 AND CT.ptcnt_un_bal > 0 AND  CT.ptcnt_due_rev_dt !< (select pt3cf_business_rev_dt from ptctlmst where ptctl_key = 3)
		END

			RETURN @Total
	END

	--================================================
	--              Insert GA CONTRACTS             --
	--================================================			
IF @ysnGA = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'gacntmst')
 BEGIN
		INSERT INTO tblCTContractHeader
				(intContractTypeId
				,intEntityId
				,intCommodityId
				,strContractNumber
				,dtmContractDate
				,intPricingTypeId
				,dblQuantity
				,intCommodityUOMId
				,intContractTextId
				,ysnSigned
				,ysnPrinted
				,intSalespersonId
				,strInternalComment
				,strCustomerContract
				,intGradeId
				,intWeightId
				,ysnProvisional
				,intCreatedById
				,dtmCreated
				,intConcurrencyId)

		SELECT	TY.intContractTypeId,
				CV.intEntityId,
				CO.intCommodityId,
				LTRIM(RtRIM(gacnt_cnt_no))+'_'+LTRIM(RtRIM(gacnt_cus_no))+'_'+LTRIM(RtRIM(CAST(CT.gacnt_seq_no AS CHAR(3))))+'_'
					+LTRIM(RtRIM(CAST(CT.gacnt_sub_seq_no AS CHAR(3))))+'_'+CAST(CT.A4GLIdentity AS CHAR(6)) AS strContractNumber,
				CONVERT(DATETIME, LEFT(gacnt_cnt_rev_dt,8)) dtmContractDate,		
				PT.intPricingTypeId,
				gacnt_no_un AS dblQuantity,		
				CU.intCommodityUnitMeasureId AS intCommodityUOMId,
				TX.intContractTextId,
				CAST(CASE WHEN gacnt_signed_yn = 'Y' THEN 1 ELSE 0 END AS BIT) AS ysnSigned,
				CAST(CASE WHEN gacnt_printed_yn = 'Y' THEN 1 ELSE 0 END AS BIT) AS ysnPrinted,		
				ISNULL((SELECT TOP 1 SP.intEntityId FROM tblEMEntity SP LEFT JOIN tblEMEntityType ST	ON	ST.intEntityId = SP.intEntityId AND ST.strType = 'Salesperson'
				WHERE LTRIM(RtRIM(SP.strName)) collate Latin1_General_CI_AS  like LTRIM(RtRIM(CT.gacnt_buyer))),@defaultSalePerson),--AS intSalespersonId,
				gacnt_comments AS strInternalComment,
				gacnt_cus_cnt_no AS strCustomerContract,
				CAST(gacnt_grade_cd AS INT) AS intGradeId,
				CAST(gacnt_weight_cd AS INT) AS intWeightId,		
				CAST(CASE WHEN gacnt_prov_cnt_yn = 'Y' THEN 1 ELSE 0 END AS BIT) AS ysnProvisional,
				@UserId,-- AS intCreatedById
				CONVERT(DATETIME, LEFT(CASE WHEN ISNULL(gacnt_user_rev_dt,'19000101') = '0' THEN '19000101' ELSE ISNULL(gacnt_user_rev_dt,'19000101') END,8)) dtmCreated,
				1
		FROM	gacntmst							CT
		JOIN	tblCTContractType			TY	ON	TY.strContractType	=	CASE	WHEN gacnt_pur_sls_ind IN ('1','P') THEN 'Purchase'  ELSE 'Sale' END
		JOIN	tblCTPricingType			PT	ON	PT.strPricingType	=	CASE	WHEN LTRIM(RTRIM(ISNULL(gacnt_pbhcu_ind,''))) = ''	 THEN 'DP (Priced Later)' 
																					WHEN LTRIM(RTRIM(ISNULL(gacnt_pbhcu_ind,''))) = 'B'  THEN 'Basis' 
																					WHEN LTRIM(RTRIM(ISNULL(gacnt_pbhcu_ind,''))) = 'H'  THEN 'HTA' 
																					WHEN LTRIM(RTRIM(ISNULL(gacnt_pbhcu_ind,''))) = 'P'  THEN 'Priced' 
																					WHEN LTRIM(RTRIM(ISNULL(gacnt_pbhcu_ind,''))) = 'U'  THEN 'Unit' 
																			END
		JOIN	tblARCustomer				CV	ON	LTRIM(RtRIM(CV.strCustomerNumber)) collate Latin1_General_CI_AS  = LTRIM(RtRIM(CT.gacnt_cus_no))  
		JOIN	tblICCommodity				CO	ON	LTRIM(RtRIM(CO.strCommodityCode)) collate Latin1_General_CI_AS = LTRIM(RtRIM(CT.gacnt_com_cd))
		JOIN	gacommst					CM	ON	LTRIM(RtRIM(CM.gacom_com_cd)) = CT.gacnt_com_cd
		JOIN	tblICUnitMeasure			UM	ON	LTRIM(RtRIM(UM.strUnitMeasure)) collate Latin1_General_CI_AS = LTRIM(RtRIM(gacom_un_desc))
		JOIN	tblICCommodityUnitMeasure	CU	ON	CU.intCommodityId = CO.intCommodityId AND CU.intUnitMeasureId = UM.intUnitMeasureId
		JOIN	tblCTContractText			TX	ON	TX.intContractType		= TY.intContractTypeId AND
												TX.intContractPriceType = PT.intPricingTypeId AND
												LTRIM(RtRIM(TX.strTextCode)) collate Latin1_General_CI_AS =  LTRIM(RtRIM(CT.gacnt_text_no))
		LEFT JOIN tblCTContractHeader		CH  ON CH.intEntityId = CV.intEntityId AND CH.intCommodityId = CO.intCommodityId
													AND CH.strContractNumber collate Latin1_General_CI_AS = CT.gacnt_cnt_no collate Latin1_General_CI_AS
													AND CH.intPricingTypeId = PT.intPricingTypeId
		WHERE gacnt_pur_sls_ind <> '1' AND (gacnt_un_bal <> 0 OR gacnt_un_bal_transit <> 0 or gacnt_un_bal_unprc <> 0 OR gacnt_sched_un <> 0) AND CH.intContractHeaderId IS NULL

		--Insert GA Contract Details--

		INSERT INTO tblCTContractDetail
				(intContractHeaderId
				,intContractStatusId
				,intCompanyLocationId
				,intContractSeq
				,dtmStartDate
				,dtmEndDate
				,intFreightTermId
				,intPricingTypeId
				,intItemId
				,intItemUOMId
				,intPriceItemUOMId
				,intBasisUOMId
				,intUnitMeasureId
				,dblQuantity
				,dblBalance
				,dblScheduleQty
				,intFutureMarketId
				,intFutureMonthId
				,dblFutures
				,dblBasis
				,dblCashPrice
				,intDiscountTypeId
				,strRemark
				,intRailGradeId
				,intCreatedById
				,dtmCreated
				,intCurrencyId
				,intBasisCurrencyId
				,intConcurrencyId)		
		SELECT	CH.intContractHeaderId,
				CASE WHEN gacnt_un_bal = 0 THEN 5 ELSE 1 END AS intContractStatusId,
				CL.intCompanyLocationId,
				gacnt_seq_no intContractSeq,
				CONVERT(DATETIME, LEFT(CASE WHEN ISNULL(gacnt_beg_ship_rev_dt,'19000101') = '0' THEN '19000101' ELSE ISNULL(gacnt_beg_ship_rev_dt,'19000101') END,8)),
				CONVERT(DATETIME, LEFT(CASE WHEN ISNULL(gacnt_due_rev_dt,'19000101') = '0' THEN '19000101' ELSE ISNULL(gacnt_due_rev_dt,'19000101') END,8)),
				FT.intFreightTermId,
				PT.intPricingTypeId,
				IM.intItemId,
				IU.intItemUOMId,
				IU.intItemUOMId as intPriceItemUOMId,
				IU.intItemUOMId as intBasisUOMId,
				IU.intUnitMeasureId,
				gacnt_no_un AS dblQuantity,
				gacnt_un_bal AS dblBalance,
				gacnt_un_bal_transit AS dblScheduleQty,
				MA.intFutureMarketId,
				MO.intFutureMonthId,
				gacnt_un_bot_prc AS dblFutures,
				gacnt_un_bot_basis dblBasis,
				gacnt_un_bot_prc + gacnt_un_bot_basis dblCashPrice,
				DT.intDiscountTypeId,
				LTRIM(RTRIM(ISNULL(gacnt_remarks_1,'') + CHAR(13)+CHAR(10) + 
				ISNULL(gacnt_remarks_2 + CHAR(13)+CHAR(10),'') + 
				ISNULL(gacnt_remarks_3 + CHAR(13)+CHAR(10),'') + 
				ISNULL(gacnt_remarks_4 + CHAR(13)+CHAR(10),'') + 
				ISNULL(gacnt_remarks_5 + CHAR(13)+CHAR(10),'') + 
				ISNULL(gacnt_remarks_6 + CHAR(13)+CHAR(10),'') + 
				ISNULL(gacnt_remarks_7 + CHAR(13)+CHAR(10),'') + 
				ISNULL(gacnt_remarks_8 + CHAR(13)+CHAR(10),'') + 
				ISNULL(gacnt_remarks_9,''))) AS strRemark,
				RG.intRailGradeId,
				@UserId AS intCreatedById,
				CONVERT(DATETIME, LEFT(CASE WHEN ISNULL(gacnt_user_rev_dt,'19000101') = '0' THEN '19000101' ELSE ISNULL(gacnt_user_rev_dt,'19000101') END,8)) dtmCreated,
				@defaultCurrencyId AS intCurrencyId,
				@defaultCurrencyId AS intBasisCurrencyId,
				1
		FROM gacntmst				CT
		JOIN tblCTContractHeader    CH	ON	LTRIM(RTRIM(strContractNumber)) collate Latin1_General_CI_AS = LTRIM(RtRIM(gacnt_cnt_no))+'_'+LTRIM(RtRIM(gacnt_cus_no))
											+'_'+LTRIM(RtRIM(CAST(CT.gacnt_seq_no AS CHAR(3))))+'_'+LTRIM(RtRIM(CAST(CT.gacnt_sub_seq_no AS CHAR(3))))+'_'+CAST(CT.A4GLIdentity AS CHAR(6)) collate Latin1_General_CI_AS
		JOIN tblCTPricingType		PT	ON	PT.strPricingType	=	CASE	WHEN LTRIM(RTRIM(ISNULL(gacnt_pbhcu_ind,''))) = ''	 THEN 'DP (Priced Later)' 
																				WHEN LTRIM(RTRIM(ISNULL(gacnt_pbhcu_ind,''))) = 'B'  THEN 'Basis' 
																				WHEN LTRIM(RTRIM(ISNULL(gacnt_pbhcu_ind,''))) = 'H'  THEN 'HTA' 
																				WHEN LTRIM(RTRIM(ISNULL(gacnt_pbhcu_ind,''))) = 'P'  THEN 'Priced' 
																				WHEN LTRIM(RTRIM(ISNULL(gacnt_pbhcu_ind,''))) = 'U'  THEN 'Unit' 
																		END
		JOIN tblICCommodity			CO	ON	LTRIM(RtRIM(CO.strCommodityCode)) collate Latin1_General_CI_AS = LTRIM(RtRIM(CT.gacnt_com_cd))
		JOIN tblSMCompanyLocation	CL	ON	LTRIM(RtRIM(CL.strLocationNumber)) collate Latin1_General_CI_AS = LTRIM(RtRIM(CT.gacnt_loc_no))
		JOIN tblSMFreightTerms		FT	ON	LTRIM(RTRIM(FT.strFreightTerm)) = CASE	WHEN LTRIM(RTRIM(ISNULL(gacnt_trk_rail_ind,''))) = 'B'	THEN 'Barge' 
																						WHEN LTRIM(RTRIM(ISNULL(gacnt_trk_rail_ind,''))) = 'R'  THEN 'Rail' 
																						WHEN LTRIM(RTRIM(ISNULL(gacnt_trk_rail_ind,''))) = 'V'  THEN 'Vessel' 
																						WHEN LTRIM(RTRIM(ISNULL(gacnt_trk_rail_ind,''))) = 'T'  THEN 'Truck' 
																						WHEN LTRIM(RTRIM(ISNULL(gacnt_trk_rail_ind,''))) = 'D'  THEN 'Deliver' 
																						WHEN LTRIM(RTRIM(ISNULL(gacnt_trk_rail_ind,''))) = 'P'  THEN 'Pickup'
																						WHEN LTRIM(RTRIM(ISNULL(gacnt_trk_rail_ind,''))) = 'F'  THEN 'FOB'
																					END
		JOIN tblRKFutureMarket		MA	ON	LTRIM(RTRIM(MA.strFutSymbol)) collate Latin1_General_CI_AS	= LTRIM(RTRIM(CT.gacnt_bot))
		LEFT JOIN tblRKFuturesMonth	MO	ON	UPPER(REPLACE(LTRIM(RTRIM(MO.strFutureMonth)),' ','')) collate Latin1_General_CI_AS = CT.gacnt_bot_option
											AND MO.intFutureMarketId = MA.intFutureMarketId
		LEFT JOIN tblCTDiscountType	DT	ON	LTRIM(RTRIM(DT.strDiscountType)) = CASE	WHEN LTRIM(RTRIM(ISNULL(gacnt_disc_dca_ind,''))) = 'D'	 THEN 'Deliver' 
			 																		WHEN LTRIM(RTRIM(ISNULL(gacnt_disc_dca_ind,''))) = 'A'  THEN 'As-Is' 
			 																		WHEN LTRIM(RTRIM(ISNULL(gacnt_disc_dca_ind,''))) = 'C'  THEN 'Contract' 
			 																	END
		JOIN tblICCommodityUnitMeasure	CU	ON	CU.intCommodityUnitMeasureId = CH.intCommodityUOMId
		JOIN tblICCommodity		CM  ON  CM.strCommodityCode COLLATE LATIN1_GENERAL_CI_AS = CT.gacnt_com_cd COLLATE LATIN1_GENERAL_CI_AS
		JOIN tblICItem			IM	ON	 RtRIM(IM.strItemNo) COLLATE LATIN1_GENERAL_CI_AS = RTRIM(CT.gacnt_com_cd) COLLATE LATIN1_GENERAL_CI_AS
		JOIN tblICItemUOM		IU	ON	IU.intItemId = IM.intItemId AND IU.intUnitMeasureId = CU.intUnitMeasureId
		LEFT JOIN	tblCTRailGrade		RG	ON	LTRIM(RTRIM(RG.strRailGrade)) =		CASE	WHEN LTRIM(RTRIM(ISNULL(gacnt_avg_car_grade,''))) = 'A'	 THEN 'Average' 
																							WHEN LTRIM(RTRIM(ISNULL(gacnt_avg_car_grade,''))) = 'C'  THEN 'Car' 
																					END	
		WHERE gacnt_pur_sls_ind <> '1' AND (gacnt_un_bal <> 0 OR gacnt_un_bal_transit <> 0 or gacnt_un_bal_unprc <> 0 OR gacnt_sched_un <> 0) AND CH.intContractHeaderId > @MaxContractId


 END

	--================================================
	--              Insert PT CONTRACTS             --
	--================================================			
IF @ysnPT = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ptcntmst')
 BEGIN
	--==================================STEP 1 =====================================
	--import contract header
	--petro has only sales contract

	INSERT INTO tblCTContractHeader
				(intContractTypeId
				,intEntityId
				,intCommodityId
				,strContractNumber
				,dtmContractDate
				,intPricingTypeId
				,intContractPlanId
				,dblQuantity
				,intCommodityUOMId
				,intContractTextId
				,ysnSigned
				,ysnPrinted
				,intSalespersonId
				,strInternalComment
				,strCustomerContract
				,ysnProvisional
				,intCreatedById
				,dtmCreated
				,intConcurrencyId)
			SELECT	TY.intContractTypeId,
					C.intEntityId,
					(select intCommodityId from tblICCommodity CM 
					where CM.strCommodityCode collate Latin1_General_CI_AS = CT.ptcnt_itm_or_cls) 'intCommodityId',
					ptcnt_cnt_no AS strContractNumber,
					CONVERT(DATETIME, LEFT(ptcnt_cnt_rev_dt,8)) dtmContractDate,		
					PT.intPricingTypeId,
					(select intContractPlanId from tblCTContractPlan P 
					where LTRIM(RtRIM(P.strContractPlan)) collate Latin1_General_CI_AS = CT.ptcnt_cnt_plan) as intContractPlanId,
					(SELECT   sum(ptcnt_un_orig) FROM ptcntmst WHERE ptcnt_due_rev_dt !< (SELECT pt3cf_business_rev_dt FROM ptctlmst WHERE ptctl_key = 3) 
						AND ptcnt_cnt_no = CT.ptcnt_cnt_no GROUP BY ptcnt_cus_no, ptcnt_cnt_no, ptcnt_cnt_rev_dt HAVING SUM(ptcnt_un_bal) > 0)  AS dblQuantity,		
					(select top 1 intCommodityUnitMeasureId 
					from tblICCommodityUnitMeasure UM join tblICCommodity CM on CM.intCommodityId = UM.intCommodityId
					where CM.strCommodityCode collate Latin1_General_CI_AS = CT.ptcnt_itm_or_cls) AS intCommodityUOMId,
					null intContractTextId,
					1 AS ysnSigned,
					1 AS ysnPrinted,		
					(select top 1 E.intEntityId from tblEMEntity E join 
					tblEMEntityType	UT	ON	UT.intEntityId = E.intEntityId AND UT.strType = 'Salesperson'
					) AS intSalespersonId,
					ptcnt_hdr_comments AS strInternalComment,
					ptcnt_cnt_no AS strCustomerContract,
					0 AS ysnProvisional,
					@UserId AS intCreatedById,
					CONVERT(DATETIME, LEFT(CASE WHEN ISNULL(ptcnt_cnt_rev_dt,'19000101') = '0' THEN '19000101' ELSE ISNULL(ptcnt_cnt_rev_dt,'19000101') END,8)) dtmCreated,
					1 as intConcurrencyId
			FROM	ptcntmst					CT
			JOIN	tblCTContractType			TY	ON	TY.strContractType	=	'Sale' 
			JOIN	tblCTPricingType			PT	ON	PT.strPricingType	=	'Cash'
			join    tblARCustomer C on LTRIM(RtRIM(C.strCustomerNumber)) collate Latin1_General_CI_AS  = LTRIM(RtRIM(CT.ptcnt_cus_no))
			WHERE CT.ptcnt_line_no = 1 AND CT.ptcnt_un_bal > 0 AND  CT.ptcnt_due_rev_dt !< (select pt3cf_business_rev_dt from ptctlmst where ptctl_key = 3)

		--insert into Contract Sequence		
		
		INSERT INTO tblCTContractDetail
				(intContractHeaderId
				,intContractStatusId
				,intCompanyLocationId
				,intContractSeq
				,dtmStartDate
				,dtmEndDate
				,intFreightTermId
				,intPricingTypeId
				,intItemId
				,intItemUOMId
				,intUnitMeasureId
				,dblQuantity
				,dblBalance
				,dblScheduleQty
				,intFutureMarketId
				,intFutureMonthId
				,dblFutures
				,dblBasis
				,dblCashPrice
				,intDiscountTypeId
				,strRemark
				,intRailGradeId
				,intCreatedById
				,dtmCreated
				,intConcurrencyId)		
		SELECT	CH.intContractHeaderId,
				CASE WHEN ptcnt_un_bal = 0 THEN 5 ELSE 1 END AS intContractStatusId,
				CL.intCompanyLocationId,
				ptcnt_line_no intContractSeq,
				CONVERT(DATETIME, LEFT(ptcnt_cnt_rev_dt,8)) AS dtmStartDate,
				CONVERT(DATETIME, LEFT(ptcnt_due_rev_dt,8)) AS dtmEndDate,
				FT.intFreightTermId,
				PT.intPricingTypeId,
				IM.intItemId,
				case when intItemUOMId IS NULL then
					--for non commodity item contracts like tank lease
					(select top 1 intItemUOMId from tblICItemUOM where intItemId = IM.intItemId) 
				else
					intItemUOMId
				end as 'intItemUOMId',
				IU.intUnitMeasureId,
				ptcnt_un_orig AS dblQuantity,
				ptcnt_un_bal AS dblBalance,
				0 AS dblScheduleQty,
				null as intFutureMarketId,
				null as intFutureMonthId,
				0 AS dblFutures,
				0 dblBasis,
				ptcnt_un_prc dblCashPrice,
				null as intDiscountTypeId,
				null AS strRemark,
				null as intRailGradeId,
				@UserId AS intCreatedById,
				CONVERT(DATETIME, LEFT(CASE WHEN ISNULL(ptcnt_cnt_rev_dt,'19000101') = '0' THEN '19000101' ELSE ISNULL(ptcnt_cnt_rev_dt,'19000101') END,8)) dtmCreated,
				1 as intConcurrencyId
		FROM	ptcntmst				CT
		JOIN	tblCTContractHeader		CH	ON	LTRIM(RTRIM(strContractNumber)) collate Latin1_General_CI_AS = CT.ptcnt_cnt_no
		JOIN	tblCTPricingType		PT	ON	PT.strPricingType	=	'Cash'
		JOIN	tblSMCompanyLocation	CL	ON	LTRIM(RtRIM(CL.strLocationNumber)) collate Latin1_General_CI_AS = LTRIM(RtRIM(CT.ptcnt_loc_no))
		JOIN	tblSMFreightTerms		FT	ON	LTRIM(RTRIM(FT.strFreightTerm)) = CASE	WHEN LTRIM(RTRIM(ISNULL(ptcnt_pkup_ind,''))) = 'D'  THEN 'Deliver' 
																						WHEN LTRIM(RTRIM(ISNULL(ptcnt_pkup_ind,''))) = 'P'  THEN 'Pickup'
																					END
		JOIN	tblICCommodityUnitMeasure	CU	ON	CU.intCommodityUnitMeasureId = CH.intCommodityUOMId
		JOIN	tblICItem			IM	ON	LTRIM(RtRIM(IM.strItemNo)) collate Latin1_General_CI_AS = LTRIM(RTRIM(CT.ptcnt_itm_or_cls))
		left JOIN	tblICItemUOM		IU	ON	IU.intItemId = IM.intItemId AND IU.intUnitMeasureId = CU.intUnitMeasureId

END

GO