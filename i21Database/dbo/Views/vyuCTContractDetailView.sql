CREATE VIEW [dbo].[vyuCTContractDetailView]

AS

	SELECT	CD.intContractDetailId,
			CD.intConcurrencyId												AS	intDetailConcurrencyId,
			CD.intContractHeaderId,
			CD.intContractSeq,
			CD.intCompanyLocationId,		CL.strLocationName,
			CD.dtmStartDate,
			CD.intItemId,					IM.strItemNo,
			CD.dtmEndDate,
			CD.intFreightTermId,			FT.strFreightTerm,
			CD.intShipViaId,				SV.strShipVia,
			CD.dblQuantity													AS	dblDetailQuantity,
			CD.intUnitMeasureId,
			CD.intPricingType,				PT.Name							AS	strPricingType,
			CD.dblFutures,
			CD.dblBasis,
			CD.intFutureMarketId,			FM.strFutMarketName,
			CD.strFuturesMonth,
			CD.dblCashPrice,
			CD.intCurrencyId,				CU.strCurrency,
			CD.dblRate,
			CD.strCurrencyReference,
			CD.intMarketZoneId,				MZ.strMarketZoneCode,
			CD.intDiscountType,
			CD.intDiscountId,			
			CD.intContractOptHeaderId,		OH.strContractOptDesc,
			CD.strBuyerSeller,
			CD.intBillTo,					VR.strVendorId,
			CD.intFreightRateId,			FR.strOrigin +' - ' + FR.strDest AS strOriginDest,
			CD.strFobBasis,
			CD.intGrade,					RG.Name		AS	strRail,
			CD.strRemark,
			CD.dblOriginalQty,
			CD.dblBalance,
			CD.dblIntransitQty,
			CD.dblScheduleQty,
			
			CH.intConcurrencyId												AS	intHeaderConcurrencyId,			
			CH.intPurchaseSale,				TP.Name							AS	strContractType,
			CH.intEntityId,					EY.strName						AS	strCustomerVendor,
			CH.intCommodityId,
			CH.dblQuantity													AS	dblHeaderQuantity,
			CH.intCommodityUnitMeasureId,	U2.strUnitMeasure,
			CH.intContractNumber,
			CH.dtmContractDate,
			CH.strCustomerContract,
			CH.dtmDeferPayDate,
			CH.dblDeferPayRate,
			CH.intContractTextId,			TX.strTextCode,
			CH.strInternalComments,
			CH.ysnSigned,
			CH.ysnPrinted,
			CH.intSalespersonId,			SP.strSalespersonId,
			CH.intGradeId,					W1.strWeightGradeDesc			AS	strGrade,
			CH.intWeightId,					W1.strWeightGradeDesc			AS	strWeight,
			CH.intCropYearId,
			CH.strContractComments,
			CH.intAssociationId,			AN.strName						AS strAssociationName,
			CH.intTermId,					TM.strTerm
			
	FROM	tblCTContractDetail		CD
	
	JOIN	tblSMCompanyLocation	CL	ON	CL.intCompanyLocationId		=	CD.intCompanyLocationId
	JOIN	tblCTContractHeader		CH	ON	CH.intContractHeaderId		=	CD.intContractHeaderId		
	JOIN	tblARMarketZone			MZ	ON	MZ.intMarketZoneId			=	CD.intMarketZoneId
	JOIN	tblICItem				IM	ON	IM.intItemId				=	CD.intItemId
	JOIN	tblICUnitMeasure		U1	ON	U1.intUnitMeasureId			=	CD.intUnitMeasureId
	JOIN	tblSMCurrency			CU	ON	CU.intCurrencyID			=	CD.intCurrencyId
	JOIN	tblSMFreightTerms		FT	ON	FT.intFreightTermId			=	CD.intFreightTermId
	JOIN	tblCTPricingType		PT	ON	PT.Value					=	CD.intPricingType
	JOIN	tblSMShipVia			SV	ON	SV.intShipViaID				=	CD.intShipViaId				LEFT
	JOIN	tblCTContractOptHeader	OH  ON	OH.intContractOptHeaderId	=	CD.intContractOptHeaderId	LEFT
	JOIN	tblCTFreightRate		FR	ON	FR.intFreightRateId			=	CD.intFreightRateId			LEFT
	JOIN	tblCTRailGrade			RG	ON	RG.Value					=	CD.intGrade					LEFT
	JOIN	tblRKFutureMarket		FM	ON	FM.intFutureMarketId		=	CD.intFutureMarketId		LEFT
	JOIN	tblAPVendor				VR	ON	VR.intVendorId				=	CD.intBillTo
	
	JOIN	tblEntity				EY	ON	EY.intEntityId				=	CH.intEntityId
	JOIN	tblICCommodity			CY	ON	CY.intCommodityId			=	CH.intCommodityId
	JOIN	tblCTContractType		TP	ON	TP.Value					=	CH.intPurchaseSale
	JOIN	tblICUnitMeasure		U2	ON	U2.intUnitMeasureId			=	CH.intCommodityUnitMeasureId
	JOIN	tblCTContractText		TX	ON	TX.intContractTextId		=	CH.intContractTextId
	JOIN	tblARSalesperson		SP	ON	SP.intSalespersonId			=	CH.intSalespersonId
	JOIN	tblCTWeightGrade		W1	ON	W1.intWeightGradeId			=	CH.intGradeId
	JOIN	tblCTWeightGrade		W2	ON	W2.intWeightGradeId			=	CH.intWeightId
	JOIN	tblCTAssociation		AN	ON	AN.intAssociationId			=	CH.intAssociationId
	JOIN	tblSMTerm				TM	ON	TM.intTermID				=	CH.intTermId

