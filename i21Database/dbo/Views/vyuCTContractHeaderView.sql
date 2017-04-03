CREATE VIEW [dbo].[vyuCTContractHeaderView]

AS

	SELECT	CH.intContractHeaderId,			CH.intContractTypeId,			CH.intConcurrencyId			AS	intHeaderConcurrencyId,					
			CH.intCommodityId,				CH.strCustomerContract,			CH.intCommodityUOMId		AS	intCommodityUnitMeasureId,					
			CH.strContractNumber,			CH.dtmContractDate,				CH.dblQuantity				AS	dblHeaderQuantity,
			CH.dtmDeferPayDate,				CH.dblDeferPayRate,				CH.intContractTextId,			
			CH.strInternalComment,			CH.ysnSigned,					CH.ysnPrinted,
			CH.intSalespersonId,			CH.intGradeId,					CH.intWeightId,									
			CH.intCropYearId,				CH.strPrintableRemarks,			CH.intAssociationId,							
			CH.intTermId,					CH.intApprovalBasisId,			CH.intContractBasisId,				
			CH.intPositionId,				CH.intInsuranceById,			CH.intInvoiceTypeId,
			CH.dblTolerancePct,				CH.dblProvisionalInvoicePct,	NM.ysnPrepaid,
			CH.ysnSubstituteItem,			CH.ysnUnlimitedQuantity,		CH.ysnMaxPrice,
			CH.intINCOLocationTypeId,		CH.intCountryId,				CH.intPricingTypeId,
			CH.ysnProvisional,				CH.ysnLoad,						CH.intCompanyLocationPricingLevelId,
			CH.intNoOfLoad,					CH.dblQuantityPerLoad,			CH.intLoadUOMId,
			CH.ysnCategory,					CH.ysnMultiplePriceFixation,	CH.intCategoryUnitMeasureId,
			CH.intLoadCategoryUnitMeasureId,CH.intContractPlanId,			CH.ysnExported,
			CH.dtmExported,					CH.dtmSigned,					CH.intCreatedById,
			CH.intLastModifiedById,

			EY.intEntityId,					EY.strEntityName,				CY.strDescription			AS	strCommodityDescription,
			EY.strEntityNumber,				EY.strEntityAddress,			U2.strUnitMeasure			AS	strHeaderUnitMeasure,
			EY.strEntityState,				EY.strEntityZipCode,			W1.strWeightGradeDesc		AS	strGrade,
			EY.strEntityPhone,				EY.intDefaultLocationId,		W2.strWeightGradeDesc		AS	strWeight,	
			EY.strEntityType,				TX.strTextCode,					AN.strName					AS	strAssociationName,
			EY.strEntityCity,				TM.strTerm,						CB.strDescription			AS	strContractBasisDescription,
			EY.strEntityCountry,			PO.strPosition,					IB.strDescription			AS	strInsuranceByDescription,
			TP.strContractType,				IB.strInsuranceBy,				IT.strDescription			AS	strInvoiceTypeDescription,
			IT.strInvoiceType,				CO.strCountry,					AB.strDescription			AS	strApprovalBasisDescription,
			CY.strCommodityCode,			SP.strSalespersonId,			U3.strUnitMeasure			AS	strLoadUnitMeasure,
			AB.strApprovalBasis,			CB.strContractBasis,			U4.strUnitMeasure			AS	strCategoryUnitMeasure,
			PL.strPricingLevelName,			PT.strPricingType,				U5.strUnitMeasure			AS	strLoadCategoryUnitMeasure,				
			CB.strINCOLocationType,			CH.dtmCreated,					CE.strName					AS	strCreatedBy,
			CH.dtmLastModified,				CP.strContractPlan,				UE.strName					AS	strLastModifiedBy,					
			YR.strCropYear,					TM.strTermCode,										
																		
			CASE WHEN NM.strINCOLocationType = 'City' THEN CT.strCity ELSE SL.strSubLocationName	END	AS	strINCOLocation,
			dbo.fnCTGetContractStatuses(CH.intContractHeaderId)	AS	strStatuses
			
	FROM	tblCTContractHeader					CH	
	jOIN	vyuCTContractHeaderNotMapped		NM	ON	NM.intContractHeaderId				=		CH.intContractHeaderId
	JOIN	vyuCTEntity							EY	ON	EY.intEntityId						=		CH.intEntityId			AND
														EY.strEntityType					=		(CASE WHEN CH.intContractTypeId = 1 THEN 'Vendor' ELSE 'Customer' END)
	JOIN	tblCTContractType					TP	ON	TP.intContractTypeId				=		CH.intContractTypeId
	JOIN	tblARSalesperson					SP	ON	SP.[intEntityId]			=		CH.intSalespersonId					LEFT
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
	JOIN	tblSMCity							CT	ON	CT.intCityId						=		CH.intINCOLocationTypeId			LEFT
	JOIN	tblCTPricingType					PT	ON	PT.intPricingTypeId					=		CH.intPricingTypeId					LEFT
	JOIN	tblICCommodityUnitMeasure			CL	ON	CL.intCommodityUnitMeasureId		=		CH.intLoadUOMId						LEFT
	JOIN	tblICUnitMeasure					U3	ON	U3.intUnitMeasureId					=		CL.intUnitMeasureId					LEFT
	JOIN	tblICUnitMeasure					U4	ON	U4.intUnitMeasureId					=		CH.intCategoryUnitMeasureId			LEFT
	JOIN	tblICUnitMeasure					U5	ON	U5.intUnitMeasureId					=		CH.intLoadCategoryUnitMeasureId		LEFT
	JOIN	tblSMCompanyLocationPricingLevel	PL	ON	PL.intCompanyLocationPricingLevelId	=		CH.intCompanyLocationPricingLevelId LEFT
	JOIN	tblSMCompanyLocationSubLocation		SL	ON	SL.intCompanyLocationSubLocationId	=		CH.intINCOLocationTypeId			LEFT
	JOIN	tblEMEntity							CE	ON	CE.intEntityId						=		CH.intCreatedById					LEFT
	JOIN	tblEMEntity							UE	ON	UE.intEntityId						=		CH.intLastModifiedById				LEFT
	JOIN	tblCTContractPlan					CP	ON	CP.intContractPlanId				=		CH.intContractPlanId				LEFT
	JOIN	tblCTCropYear						YR	ON	YR.intCropYearId					=		CH.intCropYearId				