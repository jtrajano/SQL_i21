CREATE VIEW [dbo].[vyuCTContractHeaderView2]

AS

	SELECT	CH.intContractHeaderId,			CH.strContractNumber,			CH.dtmContractDate,				CH.dblQuantity				AS	dblHeaderQuantity,
			CH.dtmDeferPayDate,				CH.dblDeferPayRate,				CH.strInternalComment,			CH.ysnSigned,												
			CH.strPrintableRemarks,			CH.dblTolerancePct,				CH.dblProvisionalInvoicePct,	NM.ysnPrepaid,			
			EY.strEntityName,				CH.strCustomerContract,			CH.ysnPrinted,
			CH.ysnSubstituteItem,			CH.ysnUnlimitedQuantity,		CH.ysnMaxPrice,					EY.intEntityId,	
			CH.ysnProvisional,				CH.ysnLoad,						CH.intNoOfLoad,					CH.dblQuantityPerLoad,			
			CH.ysnCategory,					CH.ysnMultiplePriceFixation,	CH.ysnExported,
			CH.dtmExported,					CH.dtmSigned,					CY.strDescription			AS	strCommodityDescription,
			U2.strUnitMeasure			AS	strHeaderUnitMeasure,
			W1.strWeightGradeDesc		AS	strGrade,
			W2.strWeightGradeDesc		AS	strWeight,	
			TX.strTextCode,					AN.strName					AS	strAssociationName,
			TM.strTerm,	
			PO.strPosition,
			TP.strContractType,				IB.strInsuranceBy,
			IT.strInvoiceType,				CO.strCountry,
			CY.strCommodityCode,			SP.strSalespersonId,			U3.strUnitMeasure			AS	strLoadUnitMeasure,
			AB.strApprovalBasis,			CB.strContractBasis,
			PL.strPricingLevelName,			PT.strPricingType,				
			CH.dtmCreated,					CE.strName					AS	strCreatedBy,
			CP.strContractPlan,				UE.strName					AS	strLastModifiedBy,					
			YR.strCropYear,					CASE WHEN strINCOLocationType = 'City' THEN CT.strCity ELSE SL.strSubLocationName	END	AS	strINCOLocation,								
			dbo.fnCTGetContractStatuses(CH.intContractHeaderId)	AS	strStatuses			
	FROM	tblCTContractHeader					CH	
	jOIN	vyuCTContractHeaderNotMapped		NM	ON	NM.intContractHeaderId				=		CH.intContractHeaderId
	JOIN	tblCTContractType					TP	ON	TP.intContractTypeId				=		CH.intContractTypeId
	JOIN	vyuCTEntity							EY	ON	EY.intEntityId						=		CH.intEntityId			AND		
												EY.strEntityType					=		(CASE WHEN CH.intContractTypeId = 1 THEN 'Vendor' ELSE 'Customer' END)
	JOIN	tblARSalesperson					SP	ON	SP.intEntitySalespersonId			=		CH.intSalespersonId					LEFT
	JOIN	tblSMTerm							TM	ON	TM.intTermID						=		CH.intTermId						LEFT
	JOIN	tblICCommodity						CY	ON	CY.intCommodityId					=		CH.intCommodityId					LEFT
	JOIN	tblCTAssociation					AN	ON	AN.intAssociationId					=		CH.intAssociationId					LEFT
	JOIN	tblCTContractText					TX	ON	TX.intContractTextId				=		CH.intContractTextId				LEFT
	JOIN	tblCTApprovalBasis					AB	ON	AB.intApprovalBasisId				=		CH.intApprovalBasisId				LEFT
	JOIN	tblCTContractBasis					CB	ON	CB.intContractBasisId				=		CH.intContractBasisId				LEFT
	JOIN	tblCTPosition						PO	ON	PO.intPositionId					=		CH.intPositionId					LEFT
	JOIN	tblCTInsuranceBy					IB	ON	IB.intInsuranceById					=		CH.intInsuranceById					LEFT
	JOIN	tblCTInvoiceType					IT	ON	IT.intInvoiceTypeId					=		CH.intInvoiceTypeId					LEFT
	JOIN	tblSMCountry						CO	ON	CO.intCountryID						=		CH.intCountryId						LEFT
	JOIN	tblICCommodityUnitMeasure			CM	ON	CM.intCommodityUnitMeasureId		=		CH.intCommodityUOMId				LEFT
	JOIN	tblICUnitMeasure					U2	ON	U2.intUnitMeasureId					=		CM.intUnitMeasureId					LEFT
	JOIN	tblCTWeightGrade					W1	ON	W1.intWeightGradeId					=		CH.intGradeId						LEFT
	JOIN	tblCTWeightGrade					W2	ON	W2.intWeightGradeId					=		CH.intWeightId						LEFT
	JOIN	tblCTPricingType					PT	ON	PT.intPricingTypeId					=		CH.intPricingTypeId					LEFT
	JOIN	tblICCommodityUnitMeasure			CL	ON	CL.intCommodityUnitMeasureId		=		CH.intLoadUOMId						LEFT
	JOIN	tblICUnitMeasure					U3	ON	U3.intUnitMeasureId					=		CL.intUnitMeasureId					LEFT
	JOIN	tblSMCompanyLocationPricingLevel	PL	ON	PL.intCompanyLocationPricingLevelId	=		CH.intCompanyLocationPricingLevelId LEFT
	JOIN	tblEMEntity							CE	ON	CE.intEntityId						=		CH.intCreatedById					LEFT
	JOIN	tblEMEntity							UE	ON	UE.intEntityId						=		CH.intLastModifiedById				LEFT
	JOIN	tblCTContractPlan					CP	ON	CP.intContractPlanId				=		CH.intContractPlanId				LEFT
	JOIN	tblSMCompanyLocationSubLocation		SL	ON	SL.intCompanyLocationSubLocationId	=		CH.intINCOLocationTypeId			LEFT
	JOIN	tblSMCity							CT	ON	CT.intCityId						=		CH.intINCOLocationTypeId			LEFT
	JOIN	tblCTCropYear						YR	ON	YR.intCropYearId					=		CH.intCropYearId