CREATE VIEW [dbo].[vyuCTContractCostEnquiryMain]
AS

	SELECT	intContractDetailId
			,strContractSeq
			,strEntityName
			,dtmContractDate
			,strContractBasis
			,strINCOLocation
			,strCountry
			,strPosition
			,dtmStartDate
			,dtmEndDate
			,strPricingType
			,strTerm
			,strGrade
			,strWeight
			,strItemNo
			,strOrigin
			,strProductType
			,strProductLine
			,strItemGrade
			,strLoadingPointType
			,strLoadingPoint
			,strDestinationPointType
			,strDestinationPoint
			,strDestinationCity
			,strFutMarketName
			,strFutureMonth
			,dblDetailQuantity
			,strItemUOM
			,dblOpenReceive
			,strReceivedUOM
			,dblCashPrice
			,strPriceUOM
			,dblAmount
			,dblAmountPer
			,dblActual
			,dblActualPer
			,dblNetImpact
			,dblLong
			,dblShort
			,dblFuturesVolume
			,dblNetImpactPer
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
				WHEN ISNULL(dblQtyInPriceUOM, 0) = 0
					THEN NULL
				ELSE (he.dblNetImpactInDefCurrency / dblQtyInPriceUOM)
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
					W2.strWeightGradeDesc		AS	strWeight,
					dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId, CD.intUnitMeasureId, PU.intUnitMeasureId, CASE WHEN CH.ysnMultiplePriceFixation = 1 THEN CH.dblQuantity ELSE CD.dblQuantity END) AS dblQtyInPriceUOM
			FROM	dbo.tblCTContractDetail CD
			JOIN	dbo.tblCTContractHeader CH	ON CH.intContractHeaderId	=	CD.intContractHeaderId	
												AND	CD.intContractStatusId	NOT IN (2,3)					LEFT
			JOIN	dbo.tblRKFutureMarket	FM	ON	FM.intFutureMarketId	=	CD.intFutureMarketId		LEFT
			JOIN	dbo.tblRKFuturesMonth	MO	ON	MO.intFutureMonthId		=	CD.intFutureMonthId			LEFT
			JOIN	dbo.tblSMCity			LP	ON	LP.intCityId			=	CD.intLoadingPortId			LEFT
			JOIN	dbo.tblSMCity			DP	ON	DP.intCityId			=	CD.intLoadingPortId			LEFT
			JOIN	dbo.tblSMCity			DC	ON	DC.intCityId			=	CD.intDestinationCityId		LEFT
			JOIN	dbo.tblICItemUOM		IU	ON	IU.intItemUOMId			=	CD.intItemUOMId				LEFT
			JOIN	dbo.tblICUnitMeasure	U1	ON	U1.intUnitMeasureId		=	IU.intUnitMeasureId			LEFT
			JOIN	dbo.tblICItemUOM		PU	ON	PU.intItemUOMId			=	CD.intPriceItemUOMId		LEFT
			JOIN	dbo.tblSMCurrency		CU	ON	CU.intCurrencyID		=	CD.intCurrencyId			LEFT
			JOIN	dbo.tblICUnitMeasure	U2	ON	U2.intUnitMeasureId		=	PU.intUnitMeasureId			LEFT
			JOIN	dbo.tblCTPricingType	PT	ON	PT.intPricingTypeId		=	CD.intPricingTypeId			LEFT
			JOIN	dbo.tblCTContractBasis	CB	ON	CB.intContractBasisId	=	CH.intContractBasisId		LEFT		
			JOIN	dbo.tblCTPosition		PO	ON	PO.intPositionId		=	CH.intPositionId			LEFT
			JOIN	dbo.tblSMTerm			TM	ON	TM.intTermID			=	CH.intTermId				LEFT
			JOIN	dbo.tblCTWeightGrade	W1	ON	W1.intWeightGradeId		=	CH.intGradeId				LEFT				
			JOIN	dbo.tblCTWeightGrade	W2	ON	W2.intWeightGradeId		=	CH.intWeightId				LEFT
			JOIN	dbo.tblEMEntity			EY	ON	EY.intEntityId			=	CH.intEntityId				LEFT
			JOIN	dbo.tblSMCity			CT	ON	CT.intCityId			=	CH.intINCOLocationTypeId	LEFT
			JOIN	dbo.tblSMCountry		CO	ON	CO.intCountryID			=	CH.intCountryId	
		)cd
		JOIN dbo.tblICItem i ON i.intItemId = cd.intItemId
		LEFT JOIN dbo.tblSMCountry c ON c.intCountryID = i.intOriginId
		LEFT JOIN dbo.tblSMCurrency CU	ON	CU.intCurrencyID = cd.intCurrencyId			
		LEFT JOIN dbo.tblICCommodityProductLine pl ON pl.intCommodityProductLineId = i.intProductLineId
		LEFT JOIN dbo.tblICCommodityAttribute cp ON cp.intCommodityAttributeId = i.intProductTypeId
		LEFT JOIN dbo.tblICCommodityAttribute cg ON cg.intCommodityAttributeId = i.intGradeId
		LEFT JOIN 
		(
			SELECT 
			ri.intLineNo intContractDetailId
			,SUM(dbo.fnCTConvertQtyToTargetItemUOM(iri.intUnitMeasureId, cd.intItemUOMId, iri.dblOpenReceive)) dblOpenReceive
			FROM dbo.tblICInventoryReceiptItem ri
			JOIN dbo.tblCTContractDetail cd ON cd.intContractDetailId = ri.intLineNo
			JOIN dbo.tblICInventoryReceipt r ON r.intInventoryReceiptId = ri.intInventoryReceiptId
			JOIN dbo.tblICInventoryReceiptItem iri ON iri.intInventoryReceiptItemId = ri.intInventoryReceiptItemId
			WHERE r.strReceiptType = 'Purchase Contract' AND r.ysnPosted = 1
			GROUP BY ri.intLineNo
		) ri ON ri.intContractDetailId = cd.intContractDetailId
		LEFT JOIN 
		(
			SELECT	 intContractDetailId
					,SUM(dblAmount) dblAmount
					,SUM(dblAmountPer) dblAmountPer
					,SUM(dblActual) dblActual
					,SUM(dblActualPer) dblActualPer
			FROM	vyuCTContractCostEnquiryCost
			GROUP BY intContractDetailId
		) cc ON cc.intContractDetailId = cd.intContractDetailId
		LEFT JOIN 
		(
			SELECT   intContractDetailId
					,ISNULL(SUM(dblPosLots),0) AS dblLong
					,ISNULL(ABS(SUM(dblNegLots)),0) AS dblShort     
					,SUM(dblNetImpactInDefCurrency) dblNetImpactInDefCurrency
			FROM	dbo.vyuCTContractCostEnquiryHedge bd
			GROUP BY intContractDetailId
		) he ON he.intContractDetailId = cd.intContractDetailId
	) t