CREATE VIEW vyuCTContractAdjustment

AS

	SELECT	intContractDetailId,
			CAST(NULL AS NVARCHAR(50)) AS strAdjustmentNo,
			GETDATE() AS dtmAdjustmentDate,
			CAST(NULL AS NVARCHAR(MAX)) AS strComment,
			D.intContractSeq,
			D.dblQuantity,
			D.intFutureMonthId,
			D.intConcurrencyId,
			D.dblBalance,
			D.dblBalance * -1 AS dblAdjAmount,
			CASE	WHEN D.intPricingType = 1 THEN D.dblCashPrice
					WHEN D.intPricingType = 2 THEN D.dblBasis
					WHEN D.intPricingType = 3 THEN D.dblFutures
			ELSE 
				NULL
			END		AS	dblContractPrice,
			P.Name	AS	strPricingType,
			UM1.strUnitMeasure	AS strQuantityUOM,
			UM2.strUnitMeasure	AS strPriceUOM,
			CAST(NULL AS NUMERIC(8,4))	AS	dblCancellationPrice,
			CAST(NULL AS NUMERIC(8,4))	AS 	dblGainLossPerUnit,
			CAST(NULL AS NUMERIC(8,4))	AS 	dblCancelFeePerUnit,
			CAST(NULL AS NUMERIC(8,4))	AS	dblCancelFeeFlatAmount,
			CAST(NULL AS NUMERIC(8,4))	AS	dblTotalGainLoss,
			CAST(NULL AS INT)	AS	intUserId,
			CAST(NULL AS DATETIME)	AS	dtmCreatedDate,
			
			H.intContractNumber,
			E.strName	AS strCustomerVendor,
			I.strItemNo,
			T.Name	AS	strContractType,
			M.strFutureMonth
			
	FROM	tblCTContractDetail		D
	JOIN	tblCTContractHeader		H	ON	D.intContractHeaderId	=	H.intContractHeaderId
	JOIN	tblCTContractType		T	ON	T.Value					=	H.intPurchaseSale
	JOIN	tblEntity				E	ON	H.intEntityId			=	E.intEntityId
	JOIN	tblICItem				I	ON	I.intItemId				=	D.intItemId
	JOIN	tblCTPricingType		P	ON	P.Value					=	D.intPricingType
	JOIN	tblICUnitMeasure		UM1 ON	UM1.intUnitMeasureId	=	D.intUnitMeasureId		LEFT
	JOIN	tblICUnitMeasure		UM2 ON	UM2.intUnitMeasureId	=	D.intPriceUOMId			LEFT
	JOIN	tblRKFuturesMonth		M	ON	M.intFutureMonthId		=	D.intFutureMonthId


