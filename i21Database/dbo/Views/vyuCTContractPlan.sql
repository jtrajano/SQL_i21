CREATE VIEW [dbo].[vyuCTContractPlan]

AS	
	SELECT	CP.*,
			CY.strCommodityCode,
			CY.ysnExchangeTraded,
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
			CB.strContractBasis,
			CB.strINCOLocationType,
			IM.strItemNo,
			CL.strLocationName,
			CG.strCategoryCode

	FROM	tblCTContractPlan		CP	LEFT
	JOIN	tblEMEntity				SP	ON	SP.intEntityId				=		CP.intSalespersonId					LEFT
	JOIN	tblICCommodity			CY	ON	CY.intCommodityId			=		CP.intCommodityId					LEFT
	JOIN	tblCTPosition			PO	ON	PO.intPositionId			=		CP.intPositionId					LEFT	
	JOIN	tblCTWeightGrade		W1	ON	W1.intWeightGradeId			=		CP.intGradeId						LEFT
	JOIN	tblCTWeightGrade		W2	ON	W2.intWeightGradeId			=		CP.intWeightId						LEFT
	JOIN	tblSMTerm				TM	ON	TM.intTermID				=		CP.intTermId						LEFT
	JOIN	tblCTContractBasis		CB	ON	CB.intContractBasisId		=		CP.intContractBasisId				LEFT
	JOIN	tblCTContractType		TP	ON	TP.intContractTypeId		=		CP.intContractTypeId				LEFT
	JOIN	tblCTAssociation		AN	ON	AN.intAssociationId			=		CP.intAssociationId					LEFT
	JOIN	tblCTContractText		TX	ON	TX.intContractTextId		=		CP.intContractTextId				LEFT
	JOIN	tblCTCropYear			YR	ON	YR.intCropYearId			=		CP.intCropYearId					LEFT
	JOIN	tblCTPricingType		PT	ON	PT.intPricingTypeId			=		CP.intPricingTypeId					LEFT			
	JOIN	tblICItem				IM	ON	IM.intItemId				=		CP.intItemId						LEFT
	JOIN	tblSMCompanyLocation	CL	ON	CL.intCompanyLocationId		=		CP.intCompanyLocationId				LEFT
	JOIN	tblICCategory			CG	ON	CG.intCategoryId			=		CP.intCategoryId
