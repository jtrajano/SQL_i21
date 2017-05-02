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
			CH.intLastModifiedById,			CH.dtmCreated,					CH.dtmLastModified,

			EY.intEntityId,					EY.strEntityName,				NM.strCommodityDescription,
			EY.strEntityNumber,				EY.strEntityAddress,			U2.strUnitMeasure	AS strHeaderUnitMeasure,
			EY.strEntityState,				EY.strEntityZipCode,			NM.strGrade,
			EY.strEntityPhone,				EY.intDefaultLocationId,		NM.strWeight,	
			EY.strEntityType,				NM.strTextCode,					NM.strAssociationName,
			EY.strEntityCity,				NM.strTerm,						NM.strContractBasisDescription,
			EY.strEntityCountry,			NM.strPosition,					NM.strInsuranceByDescription,
			NM.strContractType,				NM.strInsuranceBy,				NM.strInvoiceTypeDescription,
			NM.strInvoiceType,				NM.strCountry,					AB.strDescription AS  strApprovalBasisDescription,
			NM.strCommodityCode,			SP.strSalespersonId,			NM.strLoadUnitMeasure,
			AB.strApprovalBasis,			NM.strContractBasis,			NM.strCategoryUnitMeasure,
			NM.strPricingLevelName,			NM.strPricingType,				NM.strLoadCategoryUnitMeasure,				
			NM.strINCOLocationType,			NM.strContractPlan,				CE.strName AS strCreatedBy,
			NM.strTermCode,					NM.strCropYear,					UE.strName AS strLastModifiedBy,					
								
			CASE WHEN NM.strINCOLocationType = 'City' THEN NM.strINCOLocation ELSE NM.strSubLocationName	END	AS	strINCOLocation,
			dbo.fnCTGetContractStatuses(CH.intContractHeaderId)	AS	strStatuses
			
	FROM	tblCTContractHeader					CH	
	jOIN	vyuCTContractHeaderNotMapped		NM	ON	NM.intContractHeaderId				=		CH.intContractHeaderId
	JOIN	vyuCTEntity							EY	ON	EY.intEntityId						=		CH.intEntityId			AND
														EY.strEntityType					=		(CASE WHEN CH.intContractTypeId = 1 THEN 'Vendor' ELSE 'Customer' END) LEFT
	JOIN	tblARSalesperson					SP	ON	SP.intEntityId						=		CH.intSalespersonId					LEFT
	JOIN	tblCTApprovalBasis					AB	ON	AB.intApprovalBasisId				=		CH.intApprovalBasisId				LEFT
	JOIN	tblEMEntity							CE	ON	CE.intEntityId						=		CH.intCreatedById					LEFT
	JOIN	tblEMEntity							UE	ON	UE.intEntityId						=		CH.intLastModifiedById				LEFT
	JOIN	tblICCommodityUnitMeasure			CM	ON	CM.intCommodityUnitMeasureId		=		CH.intCommodityUOMId				LEFT
	JOIN	tblICUnitMeasure					U2	ON	U2.intUnitMeasureId					=		CM.intUnitMeasureId							
	
				