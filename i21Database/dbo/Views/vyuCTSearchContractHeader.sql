CREATE VIEW [dbo].[vyuCTSearchContractHeader]
AS
SELECT	CH.intContractHeaderId,
		CH.intContractTypeId,
		CH.strContractNumber,			
		CH.dtmContractDate,				
		CH.dblQuantity				AS	dblHeaderQuantity,		
		CH.ysnSigned,							
		CH.strCustomerContract,			
		CH.ysnPrinted,							
		CH.dtmCreated,				
		CH.ysnLoad,	
		CH.dtmSigned,		
		U2.strUnitMeasure			AS	strHeaderUnitMeasure,
		TP.strContractType,				
		EY.strName AS strEntityName,					
		EY.intEntityId,
		-- Hidden fields
		CH.dtmDeferPayDate,	
		CH.dblDeferPayRate,
		CH.strInternalComment,
		CH.strPrintableRemarks,
		CH.dblTolerancePct,
		CH.dblProvisionalInvoicePct,
		CAST(CASE WHEN ISNULL(
			(SELECT COUNT(*)
			 FROM tblAPBillDetail BD JOIN tblAPBill BL	
				ON BL.intBillId	= BD.intBillId
		WHERE BL.intTransactionType = 2 AND BD.intContractHeaderId = CH.intContractHeaderId), 0) = 0 THEN 0 ELSE 1 END AS BIT) ysnPrepaid,		
		CH.ysnSubstituteItem,
		CH.ysnUnlimitedQuantity,
		CH.ysnMaxPrice,
		CH.ysnProvisional,
		CH.intNoOfLoad,
		CH.dblQuantityPerLoad,
		CH.ysnCategory,
		CH.ysnMultiplePriceFixation,
		CH.strCPContract,
		CH.ysnBrokerage,

		PR.strName AS strProducer,
		ES.strName AS strSalesperson,
		CY.strDescription			AS	strCommodityDescription,
		W1.strWeightGradeDesc		AS	strGrade,
		W2.strWeightGradeDesc		AS	strWeight,
		TX.strTextCode,	
		AN.strName					AS	strAssociationName,
		TM.strTerm,
		PO.strPosition,
		IB.strInsuranceBy,
		IT.strInvoiceType,
		CO.strCountry,
		CY.strCommodityCode,
		AB.strApprovalBasis,
		CB.strContractBasis,
		PT.strPricingType,
		PL.strPricingLevelName,
		U3.strUnitMeasure			AS	strLoadUnitMeasure,
		CASE WHEN CB.strINCOLocationType = 'City' THEN CT.strCity ELSE SL.strSubLocationName	END	AS	strINCOLocation,
		CP.strContractPlan,	
		CE.strName					AS	strCreatedBy,
		UE.strName					AS	strLastModifiedBy,	
		CH.ysnExported,
		CH.dtmExported,
		YR.strCropYear,
		dbo.fnCTGetContractStatuses(CH.intContractHeaderId)	COLLATE Latin1_General_CI_AS AS	strStatuses,
		CS.intUnitMeasureId AS intStockCommodityUnitMeasureId,
		U1.strUnitMeasure AS strStockCommodityUnitMeasure,
		PY.strName AS strCounterParty,
		CD.intUnitMeasureId	AS	intDefaultCommodityUnitMeasureId,
		BK.strBook,
		BK.intBookId,
		SB.strSubBook,
		SB.intSubBookId,
		
		FT.intFreightTermId,
		FT.strFreightTerm,

		CH.strExternalEntity,
		CH.strExternalContractNumber,
		CH.ysnReceivedSignedFixationLetter

FROM	tblCTContractHeader					CH	
JOIN	tblCTContractType					TP	ON	TP.intContractTypeId				=		CH.intContractTypeId
JOIN	tblEMEntity							EY	ON	EY.intEntityId						=		CH.intEntityId						LEFT
JOIN	tblEMEntity							PR	ON	PR.intEntityId						=		CH.intProducerId					LEFT
JOIN	tblEMEntity							ES	ON	ES.intEntityId						=		CH.intSalespersonId					LEFT
JOIN	tblEMEntity							PY	ON	PY.intEntityId						=		CH.intCounterPartyId				LEFT
JOIN	tblICCommodityUnitMeasure			CS	ON	CS.intCommodityId					=		CH.intCommodityId				
												AND	CS.ysnStockUnit						=		1									LEFT
JOIN	tblICCommodityUnitMeasure			CD	ON	CD.intCommodityId					=		CH.intCommodityId				
												AND	CD.ysnDefault						=		1									LEFT
JOIN	tblICUnitMeasure					U1	ON	U1.intUnitMeasureId					=		CS.intUnitMeasureId					LEFT
JOIN	tblICCommodityUnitMeasure			CM	ON	CM.intCommodityUnitMeasureId		=		CH.intCommodityUOMId				LEFT
JOIN	tblICUnitMeasure					U2	ON	U2.intUnitMeasureId					=		CM.intUnitMeasureId					LEFT
JOIN	tblICCommodityUnitMeasure			CL	ON	CL.intCommodityUnitMeasureId		=		CH.intLoadUOMId						LEFT
JOIN	tblICUnitMeasure					U3	ON	U3.intUnitMeasureId					=		CL.intUnitMeasureId					LEFT

JOIN	tblICCommodity						CY	ON	CY.intCommodityId					=		CH.intCommodityId					LEFT
JOIN	tblCTWeightGrade					W1	ON	W1.intWeightGradeId					=		CH.intGradeId						LEFT
JOIN	tblCTWeightGrade					W2	ON	W2.intWeightGradeId					=		CH.intWeightId						LEFT
JOIN	tblCTContractText					TX	ON	TX.intContractTextId				=		CH.intContractTextId				LEFT
JOIN	tblCTAssociation					AN	ON	AN.intAssociationId					=		CH.intAssociationId					LEFT
JOIN	tblSMTerm							TM	ON	TM.intTermID						=		CH.intTermId						LEFT	
JOIN	tblCTApprovalBasis					AB	ON	AB.intApprovalBasisId				=		CH.intApprovalBasisId				LEFT
JOIN	tblCTContractBasis					CB	ON	CB.intContractBasisId				=		CH.intContractBasisId				LEFT
JOIN	tblCTPosition						PO	ON	PO.intPositionId					=		CH.intPositionId					LEFT
JOIN	tblCTInsuranceBy					IB	ON	IB.intInsuranceById					=		CH.intInsuranceById					LEFT
JOIN	tblCTInvoiceType					IT	ON	IT.intInvoiceTypeId					=		CH.intInvoiceTypeId					LEFT
JOIN	tblSMCountry						CO	ON	CO.intCountryID						=		CH.intCountryId						LEFT
JOIN	tblCTPricingType					PT	ON	PT.intPricingTypeId					=		CH.intPricingTypeId					LEFT
JOIN	tblSMCompanyLocationPricingLevel	PL	ON	PL.intCompanyLocationPricingLevelId	=		CH.intCompanyLocationPricingLevelId LEFT
JOIN	tblSMCity							CT	ON	CT.intCityId						=		CH.intINCOLocationTypeId			LEFT
JOIN	tblSMCompanyLocationSubLocation		SL	ON	SL.intCompanyLocationSubLocationId	=		CH.intWarehouseId					LEFT
JOIN	tblCTContractPlan					CP	ON	CP.intContractPlanId				=		CH.intContractPlanId				LEFT
JOIN	tblEMEntity							CE	ON	CE.intEntityId						=		CH.intCreatedById					LEFT
JOIN	tblEMEntity							UE	ON	UE.intEntityId						=		CH.intLastModifiedById				LEFT
JOIN	tblCTCropYear						YR	ON	YR.intCropYearId					=		CH.intCropYearId					LEFT
JOIN	tblCTBook							BK	ON	BK.intBookId						=		CH.intBookId						LEFT
JOIN	tblCTSubBook						SB	ON	SB.intSubBookId						=		CH.intSubBookId						LEFT
JOIN	tblSMFreightTerms					FT	ON	FT.intFreightTermId					=		CH.intFreightTermId