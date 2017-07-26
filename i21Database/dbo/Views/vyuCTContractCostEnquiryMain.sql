CREATE VIEW [dbo].[vyuCTContractCostEnquiryMain]
AS

	SELECT *
	,ISNULL(dblCashPrice, 0) + ISNULL(dblAmountPer, 0) - ISNULL(dblNetImpactPer, 0) dblAdjEstimated
	,ISNULL(dblCashPrice, 0) + ISNULL(dblActualPer, 0) - ISNULL(dblNetImpactPer, 0) dblAdjActual
	FROM 
	(
		    SELECT 
			 cd.intContractDetailId
			,cd.strContractNumber + ' - ' + LTRIM(cd.intContractSeq) strContractSeq
			,cd.strEntityName
			,cd.dtmContractDate
			,cd.strContractBasis
			,cd.strINCOLocation
			,cd.strCountry
			,cd.strPosition
			,cd.dtmStartDate
			,cd.dtmEndDate
			,cd.strPricingType
			,cd.strTerm
			,cd.strGrade
			,cd.strWeight
			,i.strItemNo
			,c.strCountry strOrigin
			,cp.strDescription strProductType
			,pl.strDescription strProductLine
			,cg.strDescription strItemGrade
			,cd.strLoadingPointType
			,cd.strLoadingPoint
			,cd.strDestinationPointType
			,cd.strDestinationPoint
			,cd.strDestinationCity
			,cd.strFutMarketName
			,cd.strFutureMonth
			,cd.dblDetailQuantity
			,cd.strItemUOM
			,ri.dblOpenReceive
			,cd.strItemUOM strReceivedUOM
			,cd.dblCashPrice * ISNULL(dbo.fnCTGetCurrencyExchangeRate(cd.intContractDetailId, 0), 1) dblCashPrice
			,cd.strPriceUOM
			,cc.dblAmount
			,cc.dblAmountPer
			,cc.dblActual
			,cc.dblActualPer
			,he.dblNetImpactInDefCurrency dblNetImpact
			,he.dblLong
			,he.dblShort
			,CASE WHEN he.dblLong >=he.dblShort THEN he.dblShort ELSE he.dblLong END AS dblFuturesVolume
			,CASE 
				WHEN ISNULL(dbo.fnCTConvertQuantityToTargetItemUOM(cd.intItemId, cd.intPriceUnitMeasureId, cd.intUnitMeasureId, cd.dblDetailQuantity), 0) = 0
					THEN NULL
				ELSE (he.dblNetImpactInDefCurrency / dbo.fnCTConvertQuantityToTargetItemUOM(cd.intItemId, cd.intUnitMeasureId, cd.intPriceUnitMeasureId, CASE WHEN cd.ysnMultiplePriceFixation = 1 THEN cd.dblHeaderQuantity ELSE cd.dblDetailQuantity END))
					*(CASE WHEN cd.ysnSubCurrency=0 THEN 1 ELSE ISNULL(CU.intCent,100) END)
			 END 
			 dblNetImpactPer
		FROM
		( 
			SELECT	CD.intContractDetailId,
					CD.intItemId,
					CD.intCurrencyId,
					strLoadingPointType,
					strDestinationPointType,
					CD.dblCashPrice,
					CD.dtmStartDate,
					CD.dtmEndDate,
					CD.intContractSeq,
					CD.intUnitMeasureId,
					PU.intUnitMeasureId				AS	intPriceUnitMeasureId,
					FM.strFutMarketName,				
					MO.strFutureMonth,
					CD.dblQuantity					AS dblDetailQuantity,
					LP.strCity						AS	strLoadingPoint,
					DP.strCity						AS	strDestinationPoint,
					DC.strCity						AS	strDestinationCity,
					U1.strUnitMeasure				AS	strItemUOM,
					U2.strUnitMeasure				AS	strPriceUOM,
					CAST(ISNULL(CU.intMainCurrencyId,0) AS BIT)	AS	ysnSubCurrency,
					PT.strPricingType,
					CH.ysnMultiplePriceFixation,
					CH.dblQuantity	AS	dblHeaderQuantity,
					CH.dtmContractDate,
					CH.strContractNumber,
					EY.strName AS strEntityName,
					CB.strContractBasis,
					CT.strCity AS	strINCOLocation,
					CO.strCountry,
					PO.strPosition,
					TM.strTerm,
					W1.strWeightGradeDesc		AS	strGrade,
					W2.strWeightGradeDesc		AS	strWeight
			FROM	tblCTContractDetail CD
			JOIN	tblCTContractHeader CH ON CH.intContractHeaderId	=	CD.intContractHeaderId		LEFT
			JOIN	tblRKFutureMarket	FM	ON	FM.intFutureMarketId	=	CD.intFutureMarketId		LEFT
			JOIN	tblRKFuturesMonth	MO	ON	MO.intFutureMonthId		=	CD.intFutureMonthId			LEFT
			JOIN	tblSMCity			LP	ON	LP.intCityId			=	CD.intLoadingPortId			LEFT
			JOIN	tblSMCity			DP	ON	DP.intCityId			=	CD.intLoadingPortId			LEFT
			JOIN	tblSMCity			DC	ON	DC.intCityId			=	CD.intDestinationCityId		LEFT
			JOIN	tblICItemUOM		IU	ON	IU.intItemUOMId			=	CD.intItemUOMId				LEFT
			JOIN	tblICUnitMeasure	U1	ON	U1.intUnitMeasureId		=	IU.intUnitMeasureId			LEFT
			JOIN	tblICItemUOM		PU	ON	PU.intItemUOMId			=	CD.intPriceItemUOMId		LEFT
			JOIN	tblSMCurrency		CU	ON	CU.intCurrencyID		=	CD.intCurrencyId			LEFT
			JOIN	tblICUnitMeasure	U2	ON	U2.intUnitMeasureId		=	PU.intUnitMeasureId			LEFT
			JOIN	tblCTPricingType	PT	ON	PT.intPricingTypeId		=	CD.intPricingTypeId			LEFT
			JOIN	tblCTContractBasis	CB	ON	CB.intContractBasisId	=	CH.intContractBasisId		LEFT		
			JOIN	tblCTPosition		PO	ON	PO.intPositionId		=	CH.intPositionId			LEFT
			JOIN	tblSMTerm			TM	ON	TM.intTermID			=	CH.intTermId				LEFT
			JOIN	tblCTWeightGrade	W1	ON	W1.intWeightGradeId		=	CH.intGradeId				LEFT				
			JOIN	tblCTWeightGrade	W2	ON	W2.intWeightGradeId		=	CH.intWeightId				LEFT
			JOIN	tblEMEntity			EY	ON	EY.intEntityId			=	CH.intEntityId				LEFT
			JOIN	tblSMCity			CT	ON	CT.intCityId			=	CH.intINCOLocationTypeId	LEFT
			JOIN	tblSMCountry		CO	ON	CO.intCountryID			=	CH.intCountryId	
		)cd
		JOIN tblICItem i ON i.intItemId = cd.intItemId
		LEFT JOIN tblSMCountry c ON c.intCountryID = i.intOriginId
		LEFT JOIN tblSMCurrency CU	ON	CU.intCurrencyID = cd.intCurrencyId			
		LEFT JOIN tblICCommodityProductLine pl ON pl.intCommodityProductLineId = i.intProductLineId
		LEFT JOIN tblICCommodityAttribute cp ON cp.intCommodityAttributeId = i.intProductTypeId
		LEFT JOIN tblICCommodityAttribute cg ON cg.intCommodityAttributeId = i.intGradeId
		LEFT JOIN 
		(
			SELECT 
			ri.intLineNo intContractDetailId
			,SUM(dbo.fnCTConvertQtyToTargetItemUOM(iri.intUnitMeasureId, cd.intItemUOMId, iri.dblOpenReceive)) dblOpenReceive
			FROM tblICInventoryReceiptItem ri
			JOIN tblCTContractDetail cd ON cd.intContractDetailId = ri.intLineNo
			JOIN tblICInventoryReceipt r ON r.intInventoryReceiptId = ri.intInventoryReceiptId
			JOIN tblICInventoryReceiptItem iri ON iri.intInventoryReceiptItemId = ri.intInventoryReceiptItemId
			WHERE r.strReceiptType = 'Purchase Contract' AND r.ysnPosted = 1
			GROUP BY ri.intLineNo
		) ri ON ri.intContractDetailId = cd.intContractDetailId
		LEFT JOIN 
		(
			SELECT 
			 intContractDetailId
			,SUM(dblAmount) dblAmount
			,SUM(dblAmountPer) dblAmountPer
			,SUM(dblActual) dblActual
			,SUM(dblActualPer) dblActualPer
			FROM vyuCTContractCostEnquiryCost
			GROUP BY intContractDetailId
		) cc ON cc.intContractDetailId = cd.intContractDetailId
		LEFT JOIN 
		(
		    SELECT 
		    intContractDetailId
		   ,(SELECT ISNULL(SUM(dblLots),0) FROM vyuCTContractCostEnquiryHedge Hed WHERE Hed.intContractDetailId = b.intContractDetailId AND dblLots > 0)  AS dblLong
		   ,(SELECT ISNULL(ABS(SUM(dblLots)),0) FROM vyuCTContractCostEnquiryHedge Hed WHERE Hed.intContractDetailId = b.intContractDetailId AND dblLots < 0) AS dblShort     
		   ,SUM(dblNetImpactInDefCurrency) dblNetImpactInDefCurrency
			FROM vyuCTContractCostEnquiryHedge b
			GROUP BY intContractDetailId
		) he ON he.intContractDetailId = cd.intContractDetailId
	) t