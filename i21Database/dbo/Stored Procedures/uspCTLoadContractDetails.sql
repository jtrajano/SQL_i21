﻿CREATE PROCEDURE [dbo].[uspCTLoadContractDetails]

	@intContractHeaderId INT
AS

BEGIN TRY

	DECLARE @ErrMsg	NVARCHAR(MAX)

	;With ContractDetail AS (
	   SELECT * FROM tblCTContractDetail WHERE intContractHeaderId = @intContractHeaderId --1247
    ),
	CTE1 AS(
		SELECT	 CD.intContractDetailId
				,AD.intSeqCurrencyId
				,AD.strSeqCurrency
				,AD.ysnSeqSubCurrency
				,AD.intSeqPriceUOMId
				,AD.strSeqPriceUOM
				,AD.dblSeqPrice

				,CAST(ISNULL(LG.intLoadDetailId, 0) AS BIT) AS ysnLoadAvailable

				,CQ.dblBulkQuantity
				,CQ.dblBagQuantity
				,CQ.strContainerType
				,CQ.strContainerUOM --RM.strUnitMeasure strContainerUOM

				,FI.dblQuantityPriceFixed
				,FI.dblPFQuantityUOMId
				,FI.[dblTotalLots]
				,FI.[dblLotsFixed]
				,FI.intPriceFixationId
				,FI.intPriceContractId
				,FI.ysnSpreadAvailable
				,FI.ysnFixationDetailAvailable
				,FI.ysnMultiPricingDetail

				,QA.strContainerNumber
				,QA.strSampleTypeName
				,QA.strSampleStatus
				,QA.dtmTestingEndDate
				,QA.dblApprovedQty
		FROM ContractDetail CD
		JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId

		LEFT    JOIN	(
								SELECT ROW_NUMBER() OVER (PARTITION BY ISNULL(intPContractDetailId,intSContractDetailId) ORDER BY intLoadDetailId DESC) intRowNum,ISNULL(intPContractDetailId,intSContractDetailId)intContractDetailId,intLoadDetailId 
								FROM tblLGLoadDetail
							)LG ON LG.intRowNum = 1 AND LG.intContractDetailId = CD.intContractDetailId
		OUTER APPLY dbo.fnCTGetSampleDetail(CD.intContractDetailId)	QA
		OUTER APPLY dbo.fnCTGetSeqPriceFixationInfo(CD.intContractDetailId) FI
		OUTER APPLY dbo.fnCTGetSeqContainerInfo(CH.intCommodityId,CD.intContainerTypeId,dbo.[fnCTGetSeqDisplayField](CD.intContractDetailId,'Origin')) CQ
		CROSS APPLY	dbo.fnCTGetAdditionalColumnForDetailView(CD.intContractDetailId) AD
	)

	SELECT	*
	FROM
	(
		SELECT	 CD.*

				,CD.dblBalance - ISNULL(CD.dblScheduleQty, 0) dblAvailableQty
				,CD.intContractStatusId intCurrentContractStatusId
				,dbo.[fnCTGetSeqDisplayField](CD.intMarketZoneId,'tblARMarketZone') strMarketZoneCode--MZ.strMarketZoneCode
				,IM.strItemNo
				,dbo.[fnCTGetSeqDisplayField](CD.intAdjItemUOMId,'tblICItemUOM') strAdjustmentUOM--XM.strUnitMeasure strAdjustmentUOM
				,CL.strLocationName
				,FT.strFreightTerm
				,dbo.[fnCTGetSeqDisplayField](CD.intShipViaId,'tblEMEntity') strShipVia--SV.strName AS strShipVia
				,CU.strCurrency
				,CY.strCurrency strMainCurrency
				,CU.ysnSubCurrency
				,dbo.[fnCTGetSeqDisplayField](CD.intFreightRateId,'tblCTFreightRate') strOriginDest--FR.strOrigin + FR.strDest strOriginDest
				,dbo.[fnCTGetSeqDisplayField](CD.intRailGradeId,'tblCTRailGrade') strRailGrade--RG.strRailGrade
				,PT.strPricingType
				,NULL AS strContractOptDesc --Screen not in use
				,dbo.[fnCTGetSeqDisplayField](CD.intDiscountTypeId,'tblCTDiscountType') strDiscountType
				,dbo.[fnCTGetSeqDisplayField](CD.intDiscountId,'tblGRDiscountId') strDiscountId
				
				,IC.strContractItemName
				,dbo.[fnCTGetSeqDisplayField](CD.intNetWeightUOMId,'tblICItemUOM') strNetWeightUOM--WM.strUnitMeasure strNetWeightUOM
				,dbo.[fnCTGetSeqDisplayField](CD.intPriceItemUOMId,'tblICItemUOM') strPriceUOM--PM.strUnitMeasure strPriceUOM
				,dbo.[fnCTGetSeqDisplayField](CD.intContractDetailId,'Origin') strOrigin--ISNULL(RY.strCountry, OG.strCountry) AS strOrigin
				,dbo.[fnCTGetSeqDisplayField](CD.intIndexId,'tblCTIndex') strIndex--IX.strIndex
				,CS.strContractStatus
				
				
				,MA.strFutMarketName AS strFutureMarket
				,REPLACE(MO.strFutureMonth, ' ', '(' + MO.strSymbol + ') ') strFutureMonth
				
				,dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId, CM.intItemUOMId, 1) AS dblConversionFactor
				,dbo.[fnCTGetSeqDisplayField](CD.intItemUOMId,'tblICItemUOM')strUOM --QM.strUnitMeasure strUOM--ISNULL(QM.strUnitMeasure, YM.strUnitMeasure) AS strUOM -- YM. is not in use
				,CASE 
					WHEN CH.ysnLoad = 1
						THEN 1
					ELSE ISNULL(CD.dblQuantity, 0) - ISNULL(CD.dblBalance, 0)
				 END AS dblAppliedQty
				,dbo.fnCTGetCurrencyExchangeRate(CD.intContractDetailId, 0) AS dblExchangeRate
				,IM.intProductTypeId
				
				,CAST(1 AS BIT) ysnItemUOMIdExist
				
				,dbo.[fnCTGetSeqDisplayField](CD.intSubLocationId,'tblSMCompanyLocationSubLocation') strSubLocationName --SB.strSubLocationName
				,dbo.[fnCTGetSeqDisplayField](CD.intStorageLocationId,'tblICStorageLocation') strStorageLocationName --SL.strName AS strStorageLocationName
				,dbo.[fnCTGetSeqDisplayField](CD.intLoadingPortId,'tblSMCity') strLoadingPoint--LP.strCity AS strLoadingPoint
				,dbo.[fnCTGetSeqDisplayField](CD.intDestinationPortId,'tblSMCity') strDestinationPoint--DP.strCity AS strDestinationPoint
				,dbo.[fnCTGetLastApprovalStatus](CD.intContractHeaderId) strApprovalStatus
				,MA.dblContractSize AS dblMarketContractSize
				,MA.intUnitMeasureId AS intMarketUnitMeasureId
				,MA.intCurrencyId AS intMarketCurrencyId
				,MU.strUnitMeasure AS strMarketUnitMeasure
				,dbo.[fnCTGetSeqDisplayField](CD.intAdjItemUOMId,'tblICItemUOMUnitType') strQtyUnitType--XM.strUnitType AS strQtyUnitType
				
				,dbo.[fnCTGetSeqDisplayField](CD.intBookId,'tblCTBook') strBook --BK.strBook
				,dbo.[fnCTGetSeqDisplayField](CD.intSubBookId,'tblCTSubBook') strSubBook --SK.strSubBook
				,dbo.[fnCTGetSeqDisplayField](CD.intBillTo,'tblEMEntity') strBillTo --BT.strName AS strBillTo
				,dbo.[fnCTGetSeqDisplayField](CD.intShipperId,'tblEMEntity') strShipper--SH.strName AS strShipper
				,dbo.[fnCTGetSeqDisplayField](CD.intShippingLineId,'tblEMEntity') strShippingLine--SN.strName AS strShippingLine
				,dbo.[fnCTGetSeqDisplayField](CD.intFarmFieldId,'tblEMEntityLocation') strFarmNumber --EF.strLocationName AS strFarmNumber
				,dbo.[fnCTGetSeqDisplayField](CD.intSplitId,'tblEMEntitySplit') strSplitNumber --ES.strSplitNumber
				,dbo.[fnCTGetSeqDisplayField](CD.intDiscountScheduleId,'tblGRDiscountSchedule') strDiscountDescription--DS.strDiscountDescription
				,dbo.[fnCTGetSeqDisplayField](CD.intDiscountScheduleCodeId,'tblGRDiscountScheduleCode') strScheduleCode--,SI.strDescription AS strScheduleCode
				,dbo.[fnCTGetSeqDisplayField](CD.intStorageScheduleRuleId,'tblGRStorageScheduleRule') strScheduleDescription--,SR.strScheduleDescription
				,NULL AS strCategoryCode--CG.strCategoryCode --CG. is not in use
				
				,dbo.[fnCTGetSeqDisplayField](CD.intDestinationCityId,'tblSMCity') strDestinationCity--DY.strCity AS strDestinationCity
				,IY.strCurrency AS strInvoiceCurrency
				,'From ' + FY.strCurrency + ' To ' + TY.strCurrency AS strExchangeRate
				,PG.strName AS strPurchasingGroup
				,dbo.[fnCTGetSeqDisplayField](CD.intFXPriceUOMId,'tblICItemUOM') strFXPriceUOM--FM.strUnitMeasure AS strFXPriceUOM
				,RT.strCurrencyExchangeRateType
				,dbo.[fnCTGetSeqDisplayField](CD.intProducerId,'tblEMEntity') strProducer--PR.strName AS strProducer
				,CU.intCent AS intPriceCurrencyCent
				,MY.strCurrency AS strMarketCurrency
				,BC.strCurrency AS strBasisCurrency
				,BN.strCurrency AS strBasisMainCurrency
				,BC.ysnSubCurrency AS ysnBasisSubCurrency
				,CC.strCurrency AS strConvertedCurrency
				,CC.ysnSubCurrency AS ysnConvertedSubCurrency
				,dbo.[fnCTGetSeqDisplayField](CD.intBasisUOMId,'tblICItemUOM') strBasisUOM --BM.strUnitMeasure AS strBasisUOM
				,dbo.[fnCTGetSeqDisplayField](CD.intConvPriceUOMId,'tblICItemUOM') strConvertedUOM -- VM.strUnitMeasure AS strConvertedUOM
				,[dbo].[fnCTIsMultiAllocationExists](CD.intContractDetailId) ysnMultiAllocation
				,[dbo].[fnCTIsMultiDerivativesExists](CD.intContractDetailId) ysnMultiDerivatives
				
				,CT.intSeqCurrencyId
				,CT.strSeqCurrency
				,CT.ysnSeqSubCurrency
				,CT.intSeqPriceUOMId
				,CT.strSeqPriceUOM
				,CT.dblSeqPrice

				,CT.ysnLoadAvailable

				,CT.dblBulkQuantity
				,CT.dblBagQuantity
				,CT.strContainerType
				,CT.strContainerUOM --RM.strUnitMeasure strContainerUOM

				,CT.dblQuantityPriceFixed
				,CT.dblPFQuantityUOMId
				,CT.[dblTotalLots]
				,CT.[dblLotsFixed]
				,CT.intPriceFixationId
				,CT.intPriceContractId
				,CT.ysnSpreadAvailable
				,CT.ysnFixationDetailAvailable
				,CT.ysnMultiPricingDetail

				,CT.strContainerNumber
				,CT.strSampleTypeName
				,CT.strSampleStatus
				,CT.dtmTestingEndDate
				,CT.dblApprovedQty
				
		FROM			ContractDetail					CD
				JOIN	tblCTContractHeader				CH	ON	CH.intContractHeaderId				=		CD.intContractHeaderId	
				JOIN    CTE1 CT ON CT.intContractDetailId = CD.intContractDetailId
															--AND CD.intContractHeaderId			=		@intContractHeaderId
		LEFT    JOIN	tblCTContractStatus				CS	ON	CS.intContractStatusId				=		CD.intContractStatusId		--strContractStatus
		LEFT    JOIN	tblCTPricingType				PT	ON	PT.intPricingTypeId					=		CD.intPricingTypeId			--strPricingType
	
		LEFT    JOIN	tblICItem						IM	ON	IM.intItemId						=		CD.intItemId				--strItemNo
		LEFT    JOIN	tblICItemContract				IC	ON	IC.intItemContractId				=		CD.intItemContractId		--strContractItemName

	
		LEFT    JOIN	tblRKFutureMarket				MA	ON	MA.intFutureMarketId				=		CD.intFutureMarketId		--strFutureMarket
		LEFT    JOIN	tblICUnitMeasure				MU	ON	MU.intUnitMeasureId					=		MA.intUnitMeasureId
		LEFT    JOIN	tblRKFuturesMonth				MO	ON	MO.intFutureMonthId					=		CD.intFutureMonthId			--strFutureMonth
	
		LEFT    JOIN	tblSMCompanyLocation			CL	ON	CL.intCompanyLocationId				=		CD.intCompanyLocationId		--strLocationName
		LEFT    JOIN	tblSMCurrency					CU	ON	CU.intCurrencyID					=		CD.intCurrencyId			--strCurrency
		LEFT    JOIN	tblSMCurrency					CY	ON	CY.intCurrencyID					=		CU.intMainCurrencyId
		LEFT    JOIN	tblSMCurrency					BC	ON	BC.intCurrencyID					=		CD.intBasisCurrencyId		--strBasisCurrency
		LEFT    JOIN	tblSMCurrency					BN	ON	BN.intCurrencyID					=		BC.intMainCurrencyId		--strBasisMainCurrency
		LEFT    JOIN	tblSMCurrency					CC	ON	CC.intCurrencyID					=		CD.intConvPriceCurrencyId	--strConvertedCurrency

		LEFT    JOIN	tblSMCurrency					IY	ON	IY.intCurrencyID					=		CD.intInvoiceCurrencyId		--strInvoiceCurrency
		LEFT    JOIN	tblSMCurrency					MY	ON	MY.intCurrencyID					=		MA.intCurrencyId			--strMarketCurrency
		LEFT    JOIN	tblSMCurrencyExchangeRate		ER	ON	ER.intCurrencyExchangeRateId		=		CD.intCurrencyExchangeRateId--strExchangeRate
		LEFT    JOIN	tblSMCurrency					FY	ON	FY.intCurrencyID					=		ER.intFromCurrencyId			
		LEFT    JOIN	tblSMCurrency					TY	ON	TY.intCurrencyID					=		ER.intToCurrencyId	
		LEFT    JOIN	tblSMCurrencyExchangeRateType	RT	ON	RT.intCurrencyExchangeRateTypeId	=		CD.intRateTypeId
		LEFT    JOIN	tblSMFreightTerms				FT	ON	FT.intFreightTermId					=		CD.intFreightTermId			--strFreightTerm
		LEFT	JOIN	tblSMPurchasingGroup			PG	ON	PG.intPurchasingGroupId				=		CD.intPurchasingGroupId		--strPurchasingGroup
		LEFT	JOIN	tblICCommodityUnitMeasure		CO	ON	CO.intCommodityUnitMeasureId		=		CH.intCommodityUOMId				
		LEFT    JOIN	tblICItemUOM					CM	ON	CM.intItemId						=		CD.intItemId		
															AND	CM.intUnitMeasureId					=		CO.intUnitMeasureId		

		
	)t ORDER BY intContractSeq

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
GO