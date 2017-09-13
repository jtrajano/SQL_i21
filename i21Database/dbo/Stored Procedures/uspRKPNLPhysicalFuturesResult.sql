﻿CREATE PROCEDURE [dbo].[uspRKPNLPhysicalFuturesResult]
	@intSContractDetailId	INT,
	@intUnitMeasureId		INT
AS

BEGIN
	DECLARE	@strPContractDetailId	NVARCHAR(MAX),
			@strDetailIds			NVARCHAR(MAX)
	--		,@intSContractDetailId INT = 14604
	--		,@intUnitMeasureId INT = 10

	SELECT @strPContractDetailId = COALESCE(@strPContractDetailId + ',', '') + CAST(intPContractDetailId AS NVARCHAR(50)) FROM   tblLGAllocationDetail WHERE intSContractDetailId	=	@intSContractDetailId
	SELECT @strDetailIds = @strPContractDetailId + ',' + LTRIM(@intSContractDetailId)

	SELECT	CONVERT(int,ROW_NUMBER() OVER (ORDER BY strContractType)) intRowNum,
			*,
			ISNULL(dblAllocatedQty,dblBooked) * dblPrice	AS	dblTransactionValue,
			ISNULL(dblAllocatedQty,dblBooked) * dblPrice * dblFX	AS	dblForecast
	FROM
	(
		SELECT	TP.strContractType + ' - ' + CH.strContractNumber strContractType,
				'Sales - ' + SH.strContractNumber	AS	strNumber,
				'Allocated' AS strDescription,
				NULL AS strConfirmed,
				dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,AD.intPUnitMeasureId,@intUnitMeasureId, AD.dblPAllocatedQty) AS dblAllocatedQty,
				CASE	WHEN CD.dblCashPrice IS NULL 
						THEN	(
									(
										(ISNULL(PF.dblLotsFixed,0) * ISNULL(FD.dblFutures,0))+
										(
											(ISNULL(PF.dblTotalLots,ISNULL(CD.dblNoOfLots,ISNULL(CH.dblNoOfLots,0))) - ISNULL(PF.dblLotsFixed,0)) *
											dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,@intUnitMeasureId,MA.intUnitMeasureId,dbo.[fnCTGetLastSettlementPrice](CD.intFutureMarketId,CD.intFutureMonthId))
										)
									)
								)/
								ISNULL(PF.dblTotalLots,ISNULL(CD.dblNoOfLots,ISNULL(CH.dblNoOfLots,0))) +  
								dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,@intUnitMeasureId,MA.intUnitMeasureId,CD.dblBasis)
						ELSE	dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,@intUnitMeasureId,PU.intUnitMeasureId, CD.dblCashPrice)
				END /
				CASE WHEN CY.ysnSubCurrency = 1 THEN 100 ELSE 1 END	AS	dblPrice,
				ISNULL(MY.strCurrency,CY.strCurrency) AS strCurrency,
				ISNULL(dbo.fnCTGetCurrencyExchangeRate(CD.intContractDetailId,0),1) AS dblFX,
				NUll AS dblBooked,
				NULL AS dblAccounting,
				AD.dtmAllocatedDate AS dtmDate,
				3 AS intSort

		FROM	tblLGAllocationDetail	AD 
		JOIN	tblCTContractDetail		CD	ON	CD.intContractDetailId	=	AD.intPContractDetailId 
											AND intSContractDetailId	=	@intSContractDetailId
		JOIN	tblCTContractHeader		CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId
		JOIN	tblCTContractDetail		SD	ON	SD.intContractDetailId	=	@intSContractDetailId
		JOIN	tblCTContractHeader		SH	ON	SH.intContractHeaderId	=	SD.intContractHeaderId
		JOIN	tblCTContractType		TP	ON	TP.intContractTypeId	=	CH.intContractTypeId
		JOIN	tblICItemUOM			PU	ON	PU.intItemUOMId			=	CD.intPriceItemUOMId	
		JOIN	tblRKFutureMarket		MA	ON	MA.intFutureMarketId	=	CD.intFutureMarketId
		JOIN	tblSMCurrency			CY	ON	CY.intCurrencyID		=	CD.intCurrencyId		LEFT 
		JOIN	tblSMCurrency			MY	ON	MY.intCurrencyID		=	CY.intMainCurrencyId	LEFT
		JOIN	tblCTPriceFixation		PF	ON	PF.intContractDetailId	=	CASE	WHEN CH.ysnMultiplePriceFixation = 1 
																					THEN PF.intContractDetailId
																					ELSE CD.intContractDetailId	END	AND 
		
																			PF.intContractHeaderId	=	CD.intContractHeaderId	LEFT
		JOIN	(
					SELECT intPriceFixationId,SUM(dblFutures) dblFutures FROM tblCTPriceFixationDetail GROUP BY intPriceFixationId
				)						FD	ON	FD.intPriceFixationId	=	PF.intPriceFixationId
		WHERE	intSContractDetailId	=	@intSContractDetailId

		UNION ALL

		SELECT	NULL AS strContractType,
				IV.strInvoiceNumber,
				'Invoice' AS strDescription,
				NULL AS strConfirmed,
				NULL AS dblAllocatedQty,
				ID.dblPrice /
				CASE WHEN ID.intSubCurrencyId IS NOT NULL THEN 100 ELSE 1 END	AS	dblPrice,
				CY.strCurrency AS strCurrency,
				NULL AS dblFX,
				dbo.fnCTConvertQuantityToTargetItemUOM(ID.intItemId,QU.intUnitMeasureId,@intUnitMeasureId, ID.dblQtyShipped) AS dblBooked,
				ID.dblTotal AS dblAccounting,
				IV.dtmDate AS dtmDate,
				2 AS intSort

		FROM	tblARInvoiceDetail		ID 
		JOIN	tblARInvoice			IV	ON	IV.intInvoiceId			=	ID.intInvoiceId
		JOIN	tblCTContractDetail		CD	ON	CD.intContractDetailId	=	ID.intContractDetailId 
		JOIN	tblCTContractHeader		CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId
		JOIN	tblCTContractType		TP	ON	TP.intContractTypeId	=	CH.intContractTypeId
		JOIN	tblICItemUOM			QU	ON	QU.intItemUOMId			=	ID.intItemUOMId	
		JOIN	tblICItemUOM			PU	ON	PU.intItemUOMId			=	CD.intPriceItemUOMId	
		JOIN	tblSMCurrency			CY	ON	CY.intCurrencyID		=	IV.intCurrencyId
		WHERE	ID.intContractDetailId	=	@intSContractDetailId

		UNION ALL

		SELECT	TP.strContractType + ' - ' + CH.strContractNumber strContractType,
				'Purchase - ' + PH.strContractNumber,
				'Allocated' AS strDescription,
				NULL AS strConfirmed,
				dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,AD.intPUnitMeasureId,@intUnitMeasureId, AD.dblPAllocatedQty) AS dblAllocatedQty,
				CASE	WHEN CD.dblCashPrice IS NULL 
						THEN	(
									(
										(ISNULL(PF.dblLotsFixed,0) * ISNULL(FD.dblFutures,0))+
										(
											(ISNULL(PF.dblTotalLots,ISNULL(CD.dblNoOfLots,ISNULL(CH.dblNoOfLots,0))) - ISNULL(PF.dblLotsFixed,0)) *
											dbo.fnCTConvertQuantityToTargetItemUOM(	CD.intItemId,@intUnitMeasureId,MA.intUnitMeasureId,dbo.[fnCTGetLastSettlementPrice](CD.intFutureMarketId,CD.intFutureMonthId)))
									)
								)/ISNULL(PF.dblTotalLots,ISNULL(CD.dblNoOfLots,ISNULL(CH.dblNoOfLots,0))) +  
								dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,@intUnitMeasureId,MA.intUnitMeasureId,CD.dblBasis)
						ELSE	dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,@intUnitMeasureId,PU.intUnitMeasureId, CD.dblCashPrice)
				END /
				CASE WHEN CY.ysnSubCurrency = 1 THEN 100 ELSE 1 END	AS	dblPrice,
				ISNULL(MY.strCurrency,CY.strCurrency) AS strCurrency,
				ISNULL(dbo.fnCTGetCurrencyExchangeRate(CD.intContractDetailId,0),1) AS dblFX,
				NUll AS dblBooked,
				NULL AS dblAccounting,
				AD.dtmAllocatedDate AS dtmDate,
				1 AS intSort

		FROM	tblLGAllocationDetail	AD 
		JOIN	tblCTContractDetail		CD	ON	CD.intContractDetailId	=	@intSContractDetailId
		JOIN	tblCTContractHeader		CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId
		JOIN	tblCTContractType		TP	ON	TP.intContractTypeId	=	CH.intContractTypeId
		JOIN	tblCTContractDetail		PD	ON	PD.intContractDetailId	=	AD.intPContractDetailId
		JOIN	tblCTContractHeader		PH	ON	PH.intContractHeaderId	=	PD.intContractHeaderId
		JOIN	tblICItemUOM			PU	ON	PU.intItemUOMId			=	CD.intPriceItemUOMId	
		JOIN	tblRKFutureMarket		MA	ON	MA.intFutureMarketId	=	CD.intFutureMarketId
		JOIN	tblSMCurrency			CY	ON	CY.intCurrencyID		=	CD.intCurrencyId		LEFT 
		JOIN	tblSMCurrency			MY	ON	MY.intCurrencyID		=	CY.intMainCurrencyId	LEFT
		JOIN	tblCTPriceFixation		PF	ON	PF.intContractDetailId	=	CASE	WHEN CH.ysnMultiplePriceFixation = 1 
																					THEN PF.intContractDetailId
																					ELSE CD.intContractDetailId	END	AND 
		
																			PF.intContractHeaderId	=	CD.intContractHeaderId	LEFT
		JOIN	(
					SELECT intPriceFixationId,SUM(dblFutures) dblFutures FROM tblCTPriceFixationDetail GROUP BY intPriceFixationId
				)						FD	ON	FD.intPriceFixationId	=	PF.intPriceFixationId
		WHERE	intSContractDetailId	=	@intSContractDetailId

		UNION ALL

		SELECT strItemNo, strContractNumber, strDescription, strConfirmed, SUM(dblAllocatedQty) dblAllocatedQty, dblPrice, strCurrency, dblFX, dblBooked, dblAccounting, dtmContractDate, intSort
		FROM(
			SELECT	IM.strItemNo,
					CH.strContractNumber,
					TP.strContractType + ' - ' +  CH.strContractNumber AS strDescription,
					NULL AS strConfirmed,
					dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,AD.intPUnitMeasureId,@intUnitMeasureId, AD.dblPAllocatedQty) AS dblAllocatedQty,
					CASE	WHEN	CC.strCostMethod = 'Per Unit'	THEN 
							dbo.fnCTConvertQuantityToTargetItemUOM(CC.intItemId,@intUnitMeasureId,CU.intUnitMeasureId,1)*CC.dblRate
						WHEN	CC.strCostMethod = 'Amount'		THEN
							CC.dblRate
					END /
					CASE WHEN OY.ysnSubCurrency = 1 THEN 100 ELSE 1 END	AS	dblPrice,
					ISNULL(MY.strCurrency,CY.strCurrency) AS strCurrency,
					ISNULL(dbo.fnCTGetCurrencyExchangeRate(CD.intContractDetailId,0),1) AS dblFX,
					BL.dblBooked,
					BL.dblAccounting,
					CH.dtmContractDate,
					CC.intItemId  AS intSort

			FROM	tblLGAllocationDetail	AD 
			JOIN	tblCTContractDetail		CD	ON	CD.intContractDetailId	IN	(AD.intPContractDetailId, AD.intSContractDetailId)
			JOIN	tblCTContractHeader		CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId
			JOIN	tblCTContractCost		CC	ON	CC.intContractDetailId	=	CD.intContractDetailId AND ISNULL(ysnBasis,0) = 0
			JOIN	tblICItem				IM	ON	IM.intItemId			=	CC.intItemId
			JOIN	tblCTContractType		TP	ON	TP.intContractTypeId	=	CH.intContractTypeId
			JOIN	tblICItemUOM			PU	ON	PU.intItemUOMId			=	CD.intPriceItemUOMId	LEFT
			JOIN	tblICItemUOM			CU	ON	CU.intItemUOMId			=	CC.intItemUOMId			LEFT
			JOIN	tblSMCurrency			OY	ON	OY.intCurrencyID		=	CC.intCurrencyId		LEFT 
			JOIN	tblSMCurrency			CY	ON	CY.intCurrencyID		=	CD.intCurrencyId		LEFT 
			JOIN	tblICM2MComputation		MC	ON	MC.intM2MComputationId	=	IM.intM2MComputationId	LEFT
			JOIN	tblSMCurrency			MY	ON	MY.intCurrencyID		=	CY.intMainCurrencyId	LEFT
			JOIN	(
						SELECT	intContractCostId,
								SUM(dbo.fnCTConvertQuantityToTargetItemUOM(BD.intItemId,IU.intUnitMeasureId,@intUnitMeasureId, BD.dblQtyReceived)) AS dblBooked,
								SUM(	dbo.fnCTConvertQuantityToTargetItemUOM(BD.intItemId,IU.intUnitMeasureId,@intUnitMeasureId, BD.dblQtyReceived)*
										dblCost/
										CASE WHEN BD.ysnSubCurrency = 1 THEN 100 ELSE 1 END)	dblAccounting
						FROM	tblAPBillDetail BD
						JOIN	tblICItemUOM	IU	ON	IU.intItemUOMId = BD.intUnitOfMeasureId
						WHERE	intContractDetailId IN (SELECT * FROM dbo.fnSplitString(@strDetailIds,',')) AND intContractCostId IS NOT NULL 
						GROUP BY intContractCostId
					)						BL	ON	BL.intContractCostId = CC.intContractCostId	
			WHERE	intSContractDetailId	IN (SELECT * FROM dbo.fnSplitString(@strDetailIds,',')) AND ISNULL(MC.strM2MComputation,'No')	=	'No'
		)d
		GROUP BY strItemNo, strContractNumber, strDescription, strConfirmed, dblPrice, strCurrency, dblFX, dblBooked, dblAccounting, dtmContractDate, intSort
	)t

END