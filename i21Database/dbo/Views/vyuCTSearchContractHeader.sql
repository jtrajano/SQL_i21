CREATE VIEW [dbo].[vyuCTSearchContractHeader]

AS

SELECT CH.intContractHeaderId
	, CH.intContractTypeId
	, CH.strContractNumber
	, CH.dtmContractDate
	, dblHeaderQuantity = CH.dblQuantity
	, CH.ysnSigned
	, CH.strCustomerContract
	, CH.ysnPrinted
	, CH.dtmCreated
	, CH.ysnLoad
	, CH.dtmSigned
	, strHeaderUnitMeasure = U2.strUnitMeasure
	, TP.strContractType
	, strEntityName = EY.strName
	, EY.intEntityId
	-- Hidden fields
	, CH.dtmDeferPayDate
	, CH.dblDeferPayRate
	, CH.strInternalComment
	, CH.strPrintableRemarks
	, CH.dblTolerancePct
	, CH.dblProvisionalInvoicePct
	, ysnPrepaid = CAST(CASE WHEN ISNULL((SELECT COUNT(*) FROM tblAPBillDetail BD
										JOIN tblAPBill BL ON BL.intBillId	= BD.intBillId
										WHERE BL.intTransactionType = 2 AND BD.intContractHeaderId = CH.intContractHeaderId), 0) = 0 THEN 0 ELSE 1 END AS BIT)
	, CH.ysnSubstituteItem
	, CH.ysnUnlimitedQuantity
	, CH.ysnMaxPrice
	, CH.ysnProvisional
	, CH.intNoOfLoad
	, CH.dblQuantityPerLoad
	, CH.ysnCategory
	, CH.ysnMultiplePriceFixation
	, CH.strCPContract
	, CH.ysnBrokerage
	, strProducer = PR.strName
	, strSalesperson = ES.strName
	, strCommodityDescription = CY.strDescription
	, strGrade = W1.strWeightGradeDesc
	, strWeight = W2.strWeightGradeDesc
	, TX.strTextCode
	, strAssociationName = AN.strName
	, TM.strTerm
	, PO.strPosition
	, IB.strInsuranceBy
	, IT.strInvoiceType
	, CO.strCountry
	, CY.strCommodityCode
	, AB.strApprovalBasis
	, CB.strContractBasis
	, PT.strPricingType
	, PL.strPricingLevelName
	, strLoadUnitMeasure = U3.strUnitMeasure
	, strINCOLocation = CASE WHEN CB.strINCOLocationType = 'City' THEN CT.strCity ELSE SL.strSubLocationName END
	, CP.strContractPlan
	, strCreatedBy = CE.strName
	, strLastModifiedBy = UE.strName
	, CH.ysnExported
	, CH.dtmExported
	, YR.strCropYear
	, strStatuses = dbo.fnCTGetContractStatuses(CH.intContractHeaderId)	COLLATE Latin1_General_CI_AS
	, intStockCommodityUnitMeasureId = CS.intUnitMeasureId
	, strStockCommodityUnitMeasure = U1.strUnitMeasure
	, strCounterParty = PY.strName
	, intDefaultCommodityUnitMeasureId = CD.intUnitMeasureId
	, BK.strBook
	, BK.intBookId
	, SB.strSubBook
	, SB.intSubBookId
	, FT.intFreightTermId
	, FT.strFreightTerm
	, CH.strExternalEntity
	, CH.strExternalContractNumber
	, CH.ysnReceivedSignedFixationLetter
	, strEntitySelectedLocation = ESL.strLocationName
	, CH.strReportTo
	, CH.ysnEnableFutures
	, dblTotalBalance = CAST(BL.dblTotalBalance AS NUMERIC(18, 6))
	, dblTotalAppliedQty = CAST(BL.dblTotalAppliedQty AS NUMERIC(18, 6))
	, ysnApproved = ISNULL(TR.ysnApproved, 0)

FROM tblCTContractHeader				CH	WITH (NOLOCK)
JOIN tblCTContractType					TP	WITH (NOLOCK) ON	TP.intContractTypeId				=	CH.intContractTypeId
JOIN tblEMEntity						EY	WITH (NOLOCK) ON	EY.intEntityId						=	CH.intEntityId
LEFT JOIN tblEMEntity					PR	WITH (NOLOCK) ON	PR.intEntityId						=	CH.intProducerId
LEFT JOIN tblEMEntity					ES	WITH (NOLOCK) ON	ES.intEntityId						=	CH.intSalespersonId
LEFT JOIN tblEMEntity					PY	WITH (NOLOCK) ON	PY.intEntityId						=	CH.intCounterPartyId
LEFT JOIN tblICCommodityUnitMeasure		CS	WITH (NOLOCK) ON	CS.intCommodityId					=	CH.intCommodityId
															AND	CS.ysnStockUnit						=	1
LEFT JOIN tblICCommodityUnitMeasure		CD	WITH (NOLOCK) ON	CD.intCommodityId					=	CH.intCommodityId
															AND	CD.ysnDefault						=	1
LEFT JOIN tblICUnitMeasure				U1	WITH (NOLOCK) ON	U1.intUnitMeasureId					=	CS.intUnitMeasureId
LEFT JOIN tblICCommodityUnitMeasure		CM	WITH (NOLOCK) ON	CM.intCommodityUnitMeasureId		=	CH.intCommodityUOMId
cross apply (
	select
		cd.intContractHeaderId
		, dblTotalBalance = SUM(F.dblBalance)
		, dblTotalAppliedQty = SUM(F.dblAppliedQuantity)
	from tblCTContractDetail cd
	CROSS APPLY (
		SELECT dblBalance, dblBalanceLoad, dblAppliedQuantity
        FROM [dbo].[fnCTConvertQuantityToTargetItemUOM2](cd.intItemId, cd.intUnitMeasureId, CM.intUnitMeasureId, cd.dblBalance, ISNULL(cd.intNoOfLoad, 0), ISNULL(cd.dblQuantity, 0), CH.ysnLoad)
    ) F
	where cd.intContractHeaderId = CH.intContractHeaderId
	group by cd.intContractHeaderId
) BL
LEFT JOIN tblICUnitMeasure				U2	WITH (NOLOCK) ON	U2.intUnitMeasureId					=	CM.intUnitMeasureId
LEFT JOIN tblICCommodityUnitMeasure		CL	WITH (NOLOCK) ON	CL.intCommodityUnitMeasureId		=	CH.intLoadUOMId
LEFT JOIN tblICUnitMeasure				U3	WITH (NOLOCK) ON	U3.intUnitMeasureId					=	CL.intUnitMeasureId
LEFT JOIN tblICCommodity				CY	WITH (NOLOCK) ON	CY.intCommodityId					=	CH.intCommodityId
LEFT JOIN tblCTWeightGrade				W1	WITH (NOLOCK) ON	W1.intWeightGradeId					=	CH.intGradeId
LEFT JOIN tblCTWeightGrade				W2	WITH (NOLOCK) ON	W2.intWeightGradeId					=	CH.intWeightId
LEFT JOIN tblCTContractText				TX	WITH (NOLOCK) ON	TX.intContractTextId				=	CH.intContractTextId
LEFT JOIN tblCTAssociation				AN	WITH (NOLOCK) ON	AN.intAssociationId					=	CH.intAssociationId
LEFT JOIN tblSMTerm						TM	WITH (NOLOCK) ON	TM.intTermID						=	CH.intTermId
LEFT JOIN tblCTApprovalBasis			AB	WITH (NOLOCK) ON	AB.intApprovalBasisId				=	CH.intApprovalBasisId
LEFT JOIN tblCTContractBasis			CB	WITH (NOLOCK) ON	CB.intContractBasisId				=	CH.intContractBasisId
LEFT JOIN tblCTPosition					PO	WITH (NOLOCK) ON	PO.intPositionId					=	CH.intPositionId
LEFT JOIN tblCTInsuranceBy				IB	WITH (NOLOCK) ON	IB.intInsuranceById					=	CH.intInsuranceById
LEFT JOIN tblCTInvoiceType				IT	WITH (NOLOCK) ON	IT.intInvoiceTypeId					=	CH.intInvoiceTypeId
LEFT JOIN tblSMCountry					CO	WITH (NOLOCK) ON	CO.intCountryID						=	CH.intCountryId
LEFT JOIN tblCTPricingType				PT	WITH (NOLOCK) ON	PT.intPricingTypeId					=	CH.intPricingTypeId
LEFT JOIN tblSMCompanyLocationPricingLevel	PL WITH (NOLOCK) ON	PL.intCompanyLocationPricingLevelId	=	CH.intCompanyLocationPricingLevelId
LEFT JOIN tblSMCity							CT WITH (NOLOCK) ON	CT.intCityId						=	CH.intINCOLocationTypeId
LEFT JOIN tblSMCompanyLocationSubLocation	SL WITH (NOLOCK) ON	SL.intCompanyLocationSubLocationId	=	CH.intWarehouseId
LEFT JOIN tblCTContractPlan				CP	WITH (NOLOCK) ON	CP.intContractPlanId				=	CH.intContractPlanId
LEFT JOIN tblEMEntity					CE	WITH (NOLOCK) ON	CE.intEntityId						=	CH.intCreatedById
LEFT JOIN tblEMEntity					UE	WITH (NOLOCK) ON	UE.intEntityId						=	CH.intLastModifiedById
LEFT JOIN tblCTCropYear					YR	WITH (NOLOCK) ON	YR.intCropYearId					=	CH.intCropYearId
LEFT JOIN tblCTBook						BK	WITH (NOLOCK) ON	BK.intBookId						=	CH.intBookId
LEFT JOIN tblCTSubBook					SB	WITH (NOLOCK) ON	SB.intSubBookId						=	CH.intSubBookId
LEFT JOIN tblSMFreightTerms				FT	WITH (NOLOCK) ON	FT.intFreightTermId					=	CH.intFreightTermId
LEFT JOIN tblEMEntityLocation			ESL WITH (NOLOCK) ON	ESL.intEntityLocationId				=	CH.intEntitySelectedLocationId
OUTER APPLY (
	select top 1
		ysnApproved = convert(bit,1)
	from
		tblSMScreen sc
		join tblSMTransaction tr on tr.intScreenId = sc.intScreenId
	where
		sc.strModule = 'Contract Management'
		and sc.strNamespace in ('ContractManagement.view.Contract','ContractManagement.view.Amendments')
		and tr.strApprovalStatus in ('Approved', 'Approved with Modifications')
		and tr.intRecordId = CH.intContractHeaderId
) TR