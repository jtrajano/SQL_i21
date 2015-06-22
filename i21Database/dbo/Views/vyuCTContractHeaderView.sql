CREATE VIEW [dbo].[vyuCTContractHeaderView]

AS

	SELECT	CH.intContractHeaderId,
			CH.intConcurrencyId					AS	intHeaderConcurrencyId,			
			CH.intContractTypeId,			
				TP.strContractType,		
						
			EY.intEntityId,
			EY.strEntityName,
			EY.strEntityType,
			EY.strEntityNumber,
			EY.strEntityAddress,
			EY.strEntityCity,
			EY.strEntityState,
			EY.strEntityZipCode,
			EY.strEntityCountry,
			EY.strEntityPhone,
			EY.intDefaultLocationId,

			CH.intCommodityId,				
				CY.strCommodityCode,		
				CY.strDescription				AS	strCommodityDescription,
			CH.dblQuantity						AS	dblHeaderQuantity,
			CH.intCommodityUnitMeasureId,	
				U2.strUnitMeasure				AS	strHeaderUnitMeasure,
			CH.intContractNumber,
			CH.dtmContractDate,
			CH.strCustomerContract,
			CH.dtmDeferPayDate,
			CH.dblDeferPayRate,
			CH.intContractTextId,			
				TX.strTextCode,
			CH.strInternalComments,
			CH.ysnSigned,
			CH.ysnPrinted,
			CH.intSalespersonId,			
				SP.strSalespersonId,
			CH.intGradeId,					
				W1.strWeightGradeDesc			AS	strGrade,
			CH.intWeightId,					
				W1.strWeightGradeDesc			AS	strWeight,
			CH.intCropYearId,
			CH.strContractComments,
			CH.intAssociationId,			
				AN.strName						AS strAssociationName,
			CH.intTermId,					
				TM.strTerm,
			CH.intApprovalBasisId,
				AB.strApprovalBasis,
				AB.strDescription				AS	strApprovalBasisDescription,
			CH.intContractBasisId,
				CB.strContractBasis,
				CB.strDescription				AS	strContractBasisDescription,
			CH.intPositionId,
				PO.strPosition,				
			CH.intInsuranceById,
				IB.strInsuranceBy,
				IB.strDescription				AS	strInsuranceByDescription,
			CH.intInvoiceTypeId,
				IT.strInvoiceType,
				IT.strDescription				AS	strInvoiceTypeDescription,
			CH.dblTolerancePct,
			CH.dblProvisionalInvoicePct,
			CH.ysnPrepaid,
			CH.ysnSubstituteItem,
			CH.ysnUnlimitedQuantity,
			CH.ysnMaxPrice,
			CH.intINCOLocationTypeId,
			CH.intCountryId,
				CO.strCountry
			
	FROM	tblCTContractHeader		CH	

	JOIN	vyuCTEntity				EY	ON	EY.intEntityId				=	CH.intEntityId
	JOIN	tblICCommodity			CY	ON	CY.intCommodityId			=	CH.intCommodityId
	JOIN	tblCTContractType		TP	ON	TP.intContractTypeId		=	CH.intContractTypeId
	JOIN	tblICUnitMeasure		U2	ON	U2.intUnitMeasureId			=	CH.intCommodityUnitMeasureId
	JOIN	tblARSalesperson		SP	ON	SP.intEntitySalespersonId   =	CH.intSalespersonId
	JOIN	tblCTWeightGrade		W1	ON	W1.intWeightGradeId			=	CH.intGradeId
	JOIN	tblCTWeightGrade		W2	ON	W2.intWeightGradeId			=	CH.intWeightId
	JOIN	tblSMTerm				TM	ON	TM.intTermID				=	CH.intTermId				LEFT
	JOIN	tblCTAssociation		AN	ON	AN.intAssociationId			=	CH.intAssociationId			LEFT
	JOIN	tblCTContractText		TX	ON	TX.intContractTextId		=	CH.intContractTextId		LEFT
	JOIN	tblCTApprovalBasis		AB	ON	AB.intApprovalBasisId		=	CH.intApprovalBasisId		LEFT
	JOIN	tblCTContractBasis		CB	ON	CB.intContractBasisId		=	CH.intContractBasisId		LEFT
	JOIN	tblCTPosition			PO	ON	PO.intPositionId			=	CH.intPositionId			LEFT
	JOIN	tblCTInsuranceBy		IB	ON	IB.intInsuranceById			=	CH.intInsuranceById			LEFT
	JOIN	tblCTInvoiceType		IT	ON	IT.intInvoiceTypeId			=	CH.intInvoiceTypeId			LEFT
	JOIN	tblSMCountry			CO	ON	CO.intCountryID				=	CH.intCountryId		