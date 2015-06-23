CREATE VIEW [dbo].[vyuCTContractHeaderView]

AS

	SELECT	CH.intContractHeaderId,		CH.intContractTypeId,			CH.intConcurrencyId		AS	intHeaderConcurrencyId,					
			CH.intCommodityId,			CH.strCustomerContract,			CH.intCommodityUOMId	AS	intCommodityUnitMeasureId,					
			CH.intContractNumber,		CH.dtmContractDate,				CH.dblQuantity			AS	dblHeaderQuantity,
			CH.dtmDeferPayDate,			CH.dblDeferPayRate,				CH.intContractTextId,			
			CH.strInternalComments,		CH.ysnSigned,					CH.ysnPrinted,
			CH.intSalespersonId,		CH.intGradeId,					CH.intWeightId,									
			CH.intCropYearId,			CH.strContractComments,			CH.intAssociationId,							
			CH.intTermId,				CH.intApprovalBasisId,			CH.intContractBasisId,				
			CH.intPositionId,			CH.intInsuranceById,			CH.intInvoiceTypeId,
			CH.dblTolerancePct,			CH.dblProvisionalInvoicePct,	CH.ysnPrepaid,
			CH.ysnSubstituteItem,		CH.ysnUnlimitedQuantity,		CH.ysnMaxPrice,
			CH.intINCOLocationTypeId,	CH.intCountryId,
			
			EY.intEntityId,				EY.strEntityName,				CY.strDescription		AS	strCommodityDescription,
			EY.strEntityNumber,			EY.strEntityAddress,			U2.strUnitMeasure		AS	strHeaderUnitMeasure,
			EY.strEntityState,			EY.strEntityZipCode,			W1.strWeightGradeDesc	AS	strGrade,
			EY.strEntityPhone,			EY.intDefaultLocationId,		W1.strWeightGradeDesc	AS	strWeight,	
			EY.strEntityType,			TX.strTextCode,					AN.strName				AS	strAssociationName,
			EY.strEntityCity,			TM.strTerm,						CB.strDescription		AS	strContractBasisDescription,
			EY.strEntityCountry,		PO.strPosition,					IB.strDescription		AS	strInsuranceByDescription,
			TP.strContractType,			IB.strInsuranceBy,				IT.strDescription		AS	strInvoiceTypeDescription,
			IT.strInvoiceType,			CO.strCountry,					AB.strDescription		AS	strApprovalBasisDescription,
			CY.strCommodityCode,		SP.strSalespersonId,
			AB.strApprovalBasis,		CB.strContractBasis				
			
	FROM	tblCTContractHeader			CH	
	JOIN	vyuCTEntity					EY	ON	EY.intEntityId					=		CH.intEntityId
	JOIN	tblCTContractType			TP	ON	TP.intContractTypeId			=		CH.intContractTypeId
	JOIN	tblARSalesperson			SP	ON	SP.intEntitySalespersonId		=		CH.intSalespersonId
	JOIN	tblSMTerm					TM	ON	TM.intTermID					=		CH.intTermId			LEFT
	JOIN	tblICCommodity				CY	ON	CY.intCommodityId				=		CH.intCommodityId		LEFT
	JOIN	tblCTAssociation			AN	ON	AN.intAssociationId				=		CH.intAssociationId		LEFT
	JOIN	tblCTContractText			TX	ON	TX.intContractTextId			=		CH.intContractTextId	LEFT
	JOIN	tblCTApprovalBasis			AB	ON	AB.intApprovalBasisId			=		CH.intApprovalBasisId	LEFT
	JOIN	tblCTContractBasis			CB	ON	CB.intContractBasisId			=		CH.intContractBasisId	LEFT
	JOIN	tblCTPosition				PO	ON	PO.intPositionId				=		CH.intPositionId		LEFT
	JOIN	tblCTInsuranceBy			IB	ON	IB.intInsuranceById				=		CH.intInsuranceById		LEFT
	JOIN	tblCTInvoiceType			IT	ON	IT.intInvoiceTypeId				=		CH.intInvoiceTypeId		LEFT
	JOIN	tblSMCountry				CO	ON	CO.intCountryID					=		CH.intCountryId			LEFT
	JOIN	tblICCommodityUnitMeasure	CM	ON	CM.intCommodityUnitMeasureId	=		CH.intCommodityUOMId	LEFT
	JOIN	tblICUnitMeasure			U2	ON	U2.intUnitMeasureId				=		CM.intUnitMeasureId		LEFT
	JOIN	tblCTWeightGrade			W1	ON	W1.intWeightGradeId				=		CH.intGradeId			LEFT
	JOIN	tblCTWeightGrade			W2	ON	W2.intWeightGradeId				=		CH.intWeightId