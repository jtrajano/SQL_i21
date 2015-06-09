CREATE VIEW [dbo].[vyuCTContractDetailView]

AS

	SELECT	CD.intContractDetailId,
			CD.intConcurrencyId					AS	intDetailConcurrencyId,
			CD.intContractHeaderId,
			CD.intContractSeq,
			CD.intCompanyLocationId,		
				CL.strLocationName,
			CD.dtmStartDate,
			CD.intItemId,					
				IM.strItemNo,
				IM.strDescription				AS	strItemDescription,
			CD.dtmEndDate,
			CD.intFreightTermId,			
				FT.strFreightTerm,
			CD.intShipViaId,				
				SV.strShipVia,
			CD.dblQuantity						AS	dblDetailQuantity,
			CD.intUnitMeasureId,			
				U1.strUnitMeasure				AS	strDetailUnitMeasure,
			CD.intPricingTypeId,			
				PT.strPricingType,
			CD.dblFutures,
			CD.dblBasis,
			CD.intFutureMarketId,			
				FM.strFutMarketName,
			CD.intFutureMonthId,			
				MO.strFutureMonth,
			CD.dblCashPrice,
			CD.intCurrencyId,				
				CU.strCurrency,
			CD.dblRate,
			CD.strCurrencyReference,
			CD.intMarketZoneId,				
				MZ.strMarketZoneCode,
			CD.intDiscountTypeId,
			CD.intDiscountId,			
			CD.intContractOptHeaderId,		
				OH.strContractOptDesc,
			CD.strBuyerSeller,
			CD.intBillTo,					
				VR.strVendorId,
			CD.intFreightRateId,			
				FR.strOrigin+' - '+FR.strDest	AS	strOriginDest,
			CD.strFobBasis,
			CD.intRailGradeId,				
				RG.strRailGrade,
			CD.strRemark,
			CD.dblOriginalQty,
			CD.dblBalance,
			CD.dblIntransitQty,
			CD.dblScheduleQty,
			CD.intPriceUOMId,
			CD.intPriceItemUOMId,
			CD.intLoadingPortId,
			CD.intDestinationPortId,
			CD.strShippingTerm,
			CD.intShippingLineId,
			CD.strVessel,
			CD.intDestinationCityId,
			CD.intShipperId,
			CD.strGarden,
			CD.strVendorLotID,
			CD.strInvoiceNo,
			CD.intPackingDescriptionId,
			CD.dblWeightPerUnit,
			CD.intWeightPerUnitUOMId,
			CD.intWeightPerUnitItemUOMId,
			CD.dblNoOfPacks,
			CD.intPackingTypeUOMId,
			CD.intPackingTypeItemUOMId,
			CD.intUnitsPerLayer,
			CD.intLayersPerPallet,
			CD.dtmEventStartDate,
			CD.dtmPlannedAvailabilityDate,
			CD.dtmUpdatedAvailabilityDate,
			CD.intBookId,
			CD.intSubBookId,
			CD.intContainerTypeId,
			CD.intNumberOfContainers,
			CD.intInvoiceCurrencyId,
			CD.dtmFXValidFrom,
			CD.dtmFXValidTo,
			CD.strFXRemarks,
			CD.dblAssumedFX,
			CD.strFixationBy,

			--Header Detail

			CH.intConcurrencyId					AS	intHeaderConcurrencyId,			
			CH.intContractTypeId,			
				TP.strContractType,
			CH.intEntityId,					
				EY.strName						AS	strCustomerVendor,
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
			
	FROM	tblCTContractDetail		CD
	
	JOIN	tblSMCompanyLocation	CL	ON	CL.intCompanyLocationId		=	CD.intCompanyLocationId
	JOIN	tblCTContractHeader		CH	ON	CH.intContractHeaderId		=	CD.intContractHeaderId		
	JOIN	tblARMarketZone			MZ	ON	MZ.intMarketZoneId			=	CD.intMarketZoneId
	JOIN	tblICItem				IM	ON	IM.intItemId				=	CD.intItemId
	JOIN	tblICUnitMeasure		U1	ON	U1.intUnitMeasureId			=	CD.intUnitMeasureId			
	JOIN	tblCTPricingType		PT	ON	PT.intPricingTypeId			=	CD.intPricingTypeId			LEFT
	JOIN	tblSMFreightTerms		FT	ON	FT.intFreightTermId			=	CD.intFreightTermId			LEFT
	JOIN	tblSMShipVia			SV	ON	SV.intShipViaID				=	CD.intShipViaId				LEFT
	JOIN	tblCTContractOptHeader	OH  ON	OH.intContractOptHeaderId	=	CD.intContractOptHeaderId	LEFT
	JOIN	tblCTFreightRate		FR	ON	FR.intFreightRateId			=	CD.intFreightRateId			LEFT
	JOIN	tblCTRailGrade			RG	ON	RG.intRailGradeId			=	CD.intRailGradeId			LEFT
	JOIN	tblRKFutureMarket		FM	ON	FM.intFutureMarketId		=	CD.intFutureMarketId		LEFT
	JOIN	tblAPVendor				VR	ON	VR.[intEntityVendorId]		=	CD.intBillTo				LEFT
	JOIN	tblRKFuturesMonth		MO	ON	MO.intFutureMonthId			=	CD.intFutureMonthId			LEFT
	JOIN	tblSMCurrency			CU	ON	CU.intCurrencyID			=	CD.intCurrencyId

	JOIN	tblEntity				EY	ON	EY.intEntityId				=	CH.intEntityId
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