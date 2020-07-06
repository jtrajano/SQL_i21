CREATE VIEW [dbo].[vyuCTContractPlan]

AS	
	SELECT	CP.intContractPlanId,
			CP.strContractPlan,
			CP.strDescription,
			CP.intContractTypeId,
			CP.intCommodityId,
			CP.intPositionId,
			CP.intPricingTypeId,
			CP.intTermId,
			CP.intGradeId,
			CP.intWeightId,
			CP.dtmStartDate,
			CP.dtmEndDate,
			CP.ysnMaxPrice,
			CP.ysnUnlimitedQuantity,
			CP.ysnSubstituteItem,
			CP.intItemId,
			CP.dblPrice,
			CP.intSalespersonId,
			CP.intContractTextId,
			CP.intAssociationId,
			CP.intCropYearId,
			CP.intCompanyLocationId,
			CP.ysnActive,
			CP.intConcurrencyId,
			CP.intContractBasisId,
			CP.intInsuranceById,
			CP.intArbitrationId,
			CP.strInternalComment,
			CP.strPrintableRemarks,
			CP.intContainerTypeId,
			CP.strFixationBy,
			CP.strReference,
			CY.strCommodityCode,
			CY.ysnExchangeTraded,
			CY.intFutureMarketId,
			SP.strName					AS	strSalesperson,
			PO.strPosition,
			PT.strPricingType,
			W1.strWeightGradeDesc		AS	strGrade,			
			W2.strWeightGradeDesc		AS	strWeight,	
			TM.strTerm,											
			TP.strContractType,						
			TX.strTextCode,	
			YR.strCropYear,
			AN.strName					AS	strAssociationName,
			strContractBasis = CB.strFreightTerm,
			strINCOLocationType = CB.strINCOLocationType,
			IM.strItemNo,
			CL.strLocationName,
			IB.strInsuranceBy,
			CQ.strContainerType,
			CT.strCity					AS strArbitration

	FROM	tblCTContractPlan		CP	LEFT
	JOIN	tblEMEntity				SP	ON	SP.intEntityId				=		CP.intSalespersonId					LEFT
	JOIN	tblICCommodity			CY	ON	CY.intCommodityId			=		CP.intCommodityId					LEFT
	JOIN	tblCTPosition			PO	ON	PO.intPositionId			=		CP.intPositionId					LEFT	
	JOIN	tblCTWeightGrade		W1	ON	W1.intWeightGradeId			=		CP.intGradeId						LEFT
	JOIN	tblCTWeightGrade		W2	ON	W2.intWeightGradeId			=		CP.intWeightId						LEFT
	JOIN	tblSMTerm				TM	ON	TM.intTermID				=		CP.intTermId						LEFT
	JOIN	tblSMFreightTerms		CB	ON	CB.intFreightTermId		=			CP.intContractBasisId				LEFT
	JOIN	tblCTContractType		TP	ON	TP.intContractTypeId		=		CP.intContractTypeId				LEFT
	JOIN	tblCTAssociation		AN	ON	AN.intAssociationId			=		CP.intAssociationId					LEFT
	JOIN	tblCTContractText		TX	ON	TX.intContractTextId		=		CP.intContractTextId				LEFT
	JOIN	tblCTCropYear			YR	ON	YR.intCropYearId			=		CP.intCropYearId					LEFT
	JOIN	tblCTPricingType		PT	ON	PT.intPricingTypeId			=		CP.intPricingTypeId					LEFT			
	JOIN	tblICItem				IM	ON	IM.intItemId				=		CP.intItemId						LEFT
	JOIN	tblSMCompanyLocation	CL	ON	CL.intCompanyLocationId		=		CP.intCompanyLocationId				LEFT
	JOIN	tblCTInsuranceBy		IB	ON	CP.intInsuranceById			=		IB.intInsuranceById					LEFT
	JOIN	tblSMCity				CT	ON	CP.intArbitrationId			=		CT.intCityId
	OUTER	APPLY	dbo.fnCTGetSeqContainerInfo(CP.intCommodityId,CP.intContainerTypeId,dbo.[fnCTGetSeqDisplayField](CP.intContractPlanId,'ContractPlan')) CQ
