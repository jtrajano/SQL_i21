CREATE PROCEDURE [dbo].[uspRKPNLPhysicalFuturesResult]
	@intSContractDetailId	INT,
	@intCurrencyId			INT,-- currency
	@intUnitMeasureId		INT,--- Price uom	
	@intWeightUOMId			INT -- weight 
AS
--declare @intSContractDetailId	INT,
--	@intCurrencyId			INT,-- currency
--	@intUnitMeasureId		INT,--- Price uom	
--	@intWeightUOMId			INT -- weight 

--select @intSContractDetailId=107,@intCurrencyId=3,@intUnitMeasureId=19,@intWeightUOMId=19

BEGIN
	DECLARE	@strPContractDetailId	NVARCHAR(MAX),
			@strDetailIds			NVARCHAR(MAX),
			@ysnSubCurrency			BIT	
		--,@intSContractDetailId	INT= 3
		--,@intCurrencyId			INT=9
		--,@intUnitMeasureId		INT=9
		--,@intWeightUOMId			INT=9

	SELECT @ysnSubCurrency = ysnSubCurrency FROM tblSMCurrency WHERE intCurrencyID = @intCurrencyId

	DECLARE @tblLGAllocationDetail TABLE
	(
		intPUnitMeasureId		INT,
		dblPAllocatedQty		NUMERIC(18,6),
		dtmAllocatedDate		DATETIME,
		intPContractDetailId	INT,
		intSContractDetailId	INT
	)

	IF EXISTS(SELECT * FROM   tblLGAllocationDetail WHERE intSContractDetailId	=	@intSContractDetailId) -- Replace this condition with Risk setting
	BEGIN
		INSERT	INTO @tblLGAllocationDetail
		SELECT	AD.intPUnitMeasureId,
				AD.dblPAllocatedQty,
				AD.dtmAllocatedDate,
				AD.intPContractDetailId,
				AD.intSContractDetailId
		FROM	tblLGAllocationDetail	AD
		WHERE	AD.intSContractDetailId = @intSContractDetailId
	END
	ELSE
	BEGIN
		INSERT	INTO @tblLGAllocationDetail
		SELECT
				IU.intUnitMeasureId		AS	intPUnitMeasureId,
				SUM(DL.dblLotQuantity)		AS	dblPAllocatedQty,
				NULL	AS	dtmAllocatedDate,
				RI.intLineNo			AS	intPContractDetailId,
				LD.intSContractDetailId
		FROM	tblLGLoadDetail					LD
		JOIN	tblLGLoadDetailLot				DL	ON	LD.intLoadDetailId				=	DL.intLoadDetailId
		JOIN	tblICItemUOM					IU	ON	IU.intItemUOMId					=	DL.intItemUOMId
		JOIN	tblICInventoryReceiptItemLot	IL	ON	IL.intLotId						=	DL.intLotId
		JOIN	tblICInventoryReceiptItem		RI	ON	RI.intInventoryReceiptItemId	=	IL.intInventoryReceiptItemId
		GROUP BY IU.intUnitMeasureId, RI.intLineNo, LD.intSContractDetailId HAVING LD.intSContractDetailId = @intSContractDetailId
	END

	SELECT @strPContractDetailId = COALESCE(@strPContractDetailId + ',', '') + CAST(intPContractDetailId AS NVARCHAR(50)) FROM   @tblLGAllocationDetail WHERE intSContractDetailId	=	@intSContractDetailId
	SELECT @strDetailIds = @strPContractDetailId + ',' + LTRIM(@intSContractDetailId)

	SELECT	CONVERT(int,ROW_NUMBER() OVER (ORDER BY strContractType)) intRowNum
			,strContractType
			,strNumber
			,strDescription
			,strConfirmed
			,dblAllocatedQty
			,dblPrice
			,strCurrency
			,dblFX
			,dblBooked
			,dblAccounting * dblFX AS dblAccounting
			,dtmDate
			,strType
			,dblTranValue
			,intSort
			,CAST(ysnPosted AS BIT) ysnPosted,
			CASE	WHEN strType IN ('Invoice') THEN dblAccounting 
					WHEN strType IN ('Amount', 'Per Unit')	THEN dblTranValue 
					WHEN strType IN ('4 Supp. Invoice') AND strDescription <> 'Supp. Invoice' THEN dblPrice * -1 
					WHEN strType IN ('4 Supp. Invoice') AND strDescription = 'Supp. Invoice' THEN dblTranValue * -1 
			ELSE ISNULL(dblAllocatedQtyPrice,dblBookedPrice) * dblPrice END AS	dblTransactionValue,
			CASE WHEN strDescription IN ('Invoice', 'Supp. Invoice') THEN NULL
				 ELSE ISNULL(dblAllocatedQtyPrice,dblBookedPrice) * dblPrice * dblFX
			END AS	dblForecast,
			@intSContractDetailId as intContractDetailId
	FROM
	(
		-- Purchase side -> commodity forecast 
		SELECT	TP.strContractType + ' - ' + CH.strContractNumber strContractType,
				'Sales - ' + SH.strContractNumber	AS	strNumber,
				'Allocated' AS strDescription,
				NULL AS strConfirmed,
				dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,AD.intPUnitMeasureId,@intWeightUOMId, AD.dblPAllocatedQty) *-1 AS dblAllocatedQty,
				dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,AD.intPUnitMeasureId,@intUnitMeasureId, AD.dblPAllocatedQty) *-1 AS dblAllocatedQtyPrice,
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
								dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,@intUnitMeasureId,PU.intUnitMeasureId,CD.dblConvertedBasis)
						ELSE	dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,@intUnitMeasureId,PU.intUnitMeasureId, CD.dblCashPrice)
				END / CASE	 WHEN	CY.ysnSubCurrency = 1 THEN 100 ELSE 1 END AS dblPrice,
				ISNULL(MY.strCurrency,CY.strCurrency) AS strCurrency,
				CASE WHEN ISNULL(CD.intCurrencyId, 0) = @intCurrencyId 
						THEN 1
						ELSE 
							CASE WHEN @intCurrencyId = CD.intInvoiceCurrencyId AND ISNULL(CD.dblRate, 0) <> 0 
							THEN
								CD.dblRate
							ELSE
								ISNULL(dbo.fnCTCalculateAmountBetweenCurrency(CASE WHEN CY.ysnSubCurrency = 1 THEN MY.intCurrencyID ELSE CD.intCurrencyId END, @intCurrencyId, 1, 0), 0)
							END
						END  AS dblFX,
				NUll AS dblBooked,
				NUll AS dblBookedPrice,
				NULL AS dblAccounting,
				AD.dtmAllocatedDate AS dtmDate,
				'3 Purchase Allocated'	AS strType,
				0.0 AS dblTranValue, --Dummy
				9999999 + AD.intPContractDetailId AS intSort,
				CAST(0 AS BIT) ysnPosted
		FROM	@tblLGAllocationDetail	AD 
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

		-- Sales side -> commodity actual
		SELECT *,ROW_NUMBER() OVER (ORDER BY dblPrice ASC)  AS intSort FROM (
			SELECT	DISTINCT NULL AS strContractType,
					IV.strInvoiceNumber strNumber,
					'Invoice' AS strDescription,
					NULL AS strConfirmed,
					NULL AS dblAllocatedQty,
					NULL AS dblAllocatedQtyPrice,
					dbo.[fnCTConvertQuantityToTargetItemUOM](ID.intItemId,@intUnitMeasureId,QU.intUnitMeasureId,ID.dblPrice) *
					CASE	WHEN	CD.intCurrencyId = SY.intCurrencyID THEN	1 
							WHEN	SY.ysnSubCurrency = 1				THEN	100 	
							ELSE	1 	
					END AS	dblPrice,
					ISNULL(MY.strCurrency,CY.strCurrency) AS strCurrency,
					CASE WHEN ISNULL(IV.intCurrencyId, 0) = @intCurrencyId 
						THEN 1
						ELSE 
							CASE WHEN @intCurrencyId = CD.intInvoiceCurrencyId AND ISNULL(CD.dblRate, 0) <> 0 
							THEN
								CD.dblRate
							ELSE
								ISNULL(dbo.fnCTCalculateAmountBetweenCurrency(IV.intCurrencyId,@intCurrencyId, 1, 0), 0)
							END
					END  AS dblFX,
					dbo.fnCTConvertQuantityToTargetItemUOM(ID.intItemId,QU.intUnitMeasureId,@intWeightUOMId, ID.dblQtyShipped) AS dblBooked,
					dbo.fnCTConvertQuantityToTargetItemUOM(ID.intItemId,QU.intUnitMeasureId,@intUnitMeasureId, ID.dblQtyShipped) AS dblBookedPrice,
					ID.dblTotal AS dblAccounting,
					IV.dtmDate AS dtmDate,
					'2 Invoice'	AS strType,
					0.0 AS dblTranValue, --Dummy
					IV.ysnPosted

			FROM	tblARInvoiceDetail		ID 
			JOIN	tblARInvoice			IV	ON	IV.intInvoiceId			=	ID.intInvoiceId
			JOIN	tblCTContractDetail		CD	ON	CD.intContractDetailId	=	ID.intContractDetailId 
			JOIN	tblCTContractHeader		CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId
			JOIN	tblCTContractType		TP	ON	TP.intContractTypeId	=	CH.intContractTypeId
			JOIN	tblICItemUOM			QU	ON	QU.intItemUOMId			=	ID.intItemUOMId	
			JOIN	tblICItemUOM			PU	ON	PU.intItemUOMId			=	CD.intPriceItemUOMId	
			JOIN	tblSMCurrency			CY	ON	CY.intCurrencyID		=	IV.intCurrencyId
			JOIN	tblSMCurrency			SY	ON	SY.intCurrencyID		=	@intCurrencyId
			JOIN	@tblLGAllocationDetail	AD	ON	AD.intSContractDetailId	=	ID.intContractDetailId
	LEFT	JOIN	tblSMCurrency			MY	ON	MY.intCurrencyID		=	CY.intMainCurrencyId
			WHERE	ID.intContractDetailId	=	@intSContractDetailId
			AND NOT EXISTS(SELECT * FROM tblARInvoiceDetail WHERE strDocumentNumber = IV.strInvoiceNumber)
		)d

		UNION ALL

		-- Purchase side -> commodity actual
		SELECT	DISTINCT NULL AS strContractType,
				IV.strBillId,
				CASE	WHEN IM.strType = 'Other Charge' THEN IM.strItemNo ELSE 'Supp. Invoice' END AS strDescription,
				NULL AS strConfirmed,
				NULL AS dblAllocatedQty,
				NULL AS dblAllocatedQtyPrice,
				CASE	WHEN	IM.strType = 'Other Charge' 
						THEN	ID.dblCost * AD.dblPAllocatedQty/ISNULL(TA.dblTotalAllocation,1) 
						ELSE	dbo.fnCTConvertQuantityToTargetItemUOM(ID.intItemId,@intUnitMeasureId,CD.intUnitMeasureId, ID.dblCost) 
				END / CASE	WHEN CY.ysnSubCurrency = 1 THEN 100 ELSE 1 END dblPrice,
				CY.strCurrency AS strCurrency,
				CASE WHEN ISNULL(IV.intCurrencyId, 0) = @intCurrencyId 
						THEN 1
						ELSE
							CASE WHEN @intCurrencyId = CD.intInvoiceCurrencyId AND ISNULL(CD.dblRate, 0) <> 0 
							THEN
								CD.dblRate
							ELSE 
								ISNULL(dbo.fnCTCalculateAmountBetweenCurrency(IV.intCurrencyId,@intCurrencyId, 1, 0), 0)
							END
				END  AS dblFX,
				CASE	WHEN	IM.strType = 'Other Charge' 
						THEN	dbo.fnCTConvertQuantityToTargetItemUOM(ID.intItemId,CD.intUnitMeasureId,@intWeightUOMId, AD.dblPAllocatedQty)
						ELSE	
							CASE WHEN dbo.fnCTConvertQuantityToTargetItemUOM(ID.intItemId,QU.intUnitMeasureId,@intWeightUOMId, ID.dblQtyReceived) > AD.dblPAllocatedQty
							THEN AD.dblPAllocatedQty
							ELSE dbo.fnCTConvertQuantityToTargetItemUOM(ID.intItemId,QU.intUnitMeasureId,@intWeightUOMId, ID.dblQtyReceived)
							END
				END * -1 AS dblBooked,
				--CASE	WHEN	IM.strType = 'Other Charge' 
				--		THEN	dbo.fnCTConvertQuantityToTargetItemUOM(ID.intItemId,CD.intUnitMeasureId,@intWeightUOMId, AD.dblPAllocatedQty) * -1 
				--		ELSE	dbo.fnCTConvertQuantityToTargetItemUOM(ID.intItemId,QU.intUnitMeasureId,@intUnitMeasureId, ID.dblQtyReceived)*AD.dblPAllocatedQty/ISNULL(TA.dblTotalAllocation,1) * -1
				--END 
				NULL AS dblBookedPrice,
				--ID.dblTotal * AD.dblPAllocatedQty/ISNULL(TA.dblTotalAllocation,1) *-1 AS dblAccounting,
				CASE WHEN IM.strType <> 'Other Charge' 
						THEN ID.dblTotal * AD.dblPAllocatedQty / dbo.fnCTConvertQuantityToTargetItemUOM(ID.intItemId,QU.intUnitMeasureId,@intWeightUOMId, ID.dblQtyReceived)
						ELSE ID.dblTotal * AD.dblPAllocatedQty/ISNULL(TA.dblTotalAllocation,1)
				END * -1 AS dblAccounting,
				IV.dtmDate AS dtmDate,
				'4 Supp. Invoice'	AS strType,
				--0.0 AS dblTranValue, --Dummy
				CASE WHEN IM.strType <> 'Other Charge' 
					THEN ID.dblTotal  * AD.dblPAllocatedQty / dbo.fnCTConvertQuantityToTargetItemUOM(ID.intItemId,QU.intUnitMeasureId,@intWeightUOMId, ID.dblQtyReceived)
					ELSE 0.0 
				END AS dblTranValue, 
				9999999 + AD.intPContractDetailId AS intSort,
				IV.ysnPosted
				
		FROM	@tblLGAllocationDetail	AD
		JOIN	tblAPBillDetail			ID	ON	ID.intContractDetailId	=	AD.intPContractDetailId
		JOIN	tblAPBill				IV	ON	IV.intBillId			=	ID.intBillId
		JOIN	tblCTContractDetail		CD	ON	CD.intContractDetailId	=	ID.intContractDetailId 
		JOIN	tblCTContractHeader		CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId
		JOIN	tblCTContractType		TP	ON	TP.intContractTypeId	=	CH.intContractTypeId
		JOIN	tblICItem				IM	ON	IM.intItemId			=	ID.intItemId	
		JOIN	tblICItemUOM			QU	ON	QU.intItemUOMId			=	ID.intUnitOfMeasureId	
		JOIN	tblICItemUOM			PU	ON	PU.intItemUOMId			=	CD.intPriceItemUOMId	
		JOIN	tblSMCurrency			CY	ON	CY.intCurrencyID		=	ID.intCurrencyId
   LEFT JOIN
		(
				SELECT SUM(dblPAllocatedQty) dblTotalAllocation, intPContractDetailId 
				FROM	@tblLGAllocationDetail 
				GROUP BY intPContractDetailId
		) TA ON TA.intPContractDetailId = AD.intPContractDetailId
		WHERE	AD.intSContractDetailId	=	@intSContractDetailId
		AND		ID.intContractCostId IS NULL

		UNION ALL

		-- Sales side -> commodity forecast
		SELECT *,ROW_NUMBER() OVER (ORDER BY dblAllocatedQty ASC)  AS intSort FROM (
			SELECT	TP.strContractType + ' - ' + CH.strContractNumber strContractType,
					'Purchase - ' + PH.strContractNumber  AS strNumbe,
					'Allocated' AS strDescription,
					NULL AS strConfirmed,
					dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,AD.intPUnitMeasureId,@intWeightUOMId, AD.dblPAllocatedQty) AS dblAllocatedQty,
					dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,AD.intPUnitMeasureId,@intUnitMeasureId, AD.dblPAllocatedQty) AS dblAllocatedQtyPrice,
					CASE	WHEN CD.dblCashPrice IS NULL 
							THEN	(
										(
											(ISNULL(PF.dblLotsFixed,0) * ISNULL(FD.dblFutures,0))+
											(
												(ISNULL(PF.dblTotalLots,ISNULL(CD.dblNoOfLots,ISNULL(CH.dblNoOfLots,0))) - ISNULL(PF.dblLotsFixed,0)) *
												dbo.fnCTConvertQuantityToTargetItemUOM(	CD.intItemId,@intUnitMeasureId,MA.intUnitMeasureId,dbo.[fnCTGetLastSettlementPrice](CD.intFutureMarketId,CD.intFutureMonthId)))
										)
									)/ISNULL(PF.dblTotalLots,ISNULL(CD.dblNoOfLots,ISNULL(CH.dblNoOfLots,0))) +  
									dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,@intUnitMeasureId,PU.intUnitMeasureId,CD.dblConvertedBasis)
							ELSE	dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,@intUnitMeasureId,PU.intUnitMeasureId, CD.dblCashPrice)
					END / CASE	 WHEN	CY.ysnSubCurrency = 1 THEN 100 ELSE 1 END AS dblPrice,
					ISNULL(MY.strCurrency,CY.strCurrency) AS strCurrency,
					CASE WHEN ISNULL(CD.intCurrencyId, 0) = @intCurrencyId 
						THEN 1
						ELSE 
							CASE WHEN @intCurrencyId = CD.intInvoiceCurrencyId AND ISNULL(CD.dblRate, 0) <> 0 
							THEN
								CD.dblRate
							ELSE
								ISNULL(dbo.fnCTCalculateAmountBetweenCurrency(CASE WHEN CY.ysnSubCurrency = 1 THEN MY.intCurrencyID ELSE CD.intCurrencyId END,@intCurrencyId, 1, 0), 0)
							END
					END  AS  dblFX,
					NUll AS dblBooked,
					NUll AS dblBookedPrice,
					NULL AS dblAccounting,
					AD.dtmAllocatedDate AS dtmDate,
					'1 Sales Allocated'	AS strType,
					0.0 AS dblTranValue, --Dummy
					CAST(0 AS BIT) ysnPosted

			FROM	@tblLGAllocationDetail	AD 
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
		)d

		UNION ALL

		-- Secondary Costs - forecast
		SELECT TOP 100 PERCENT strItemNo strContractType, strBillId strNumber, strDescription, strConfirmed, SUM(dblAllocatedQty) dblAllocatedQty, SUM(dblAllocatedQtyPrice) dblAllocatedQtyPrice, dblPrice, strCurrency, dblFX, dblBooked, dblBookedPrice, dblAccounting, dtmContractDate dtmDate, strType,dblTranValue, intSort, ysnPosted
		FROM(
			SELECT	IM.strItemNo,
					NULL strBillId,
					TP.strContractType + ' - ' +  CH.strContractNumber AS strDescription,
					NULL AS strConfirmed,
					dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,AD.intPUnitMeasureId,@intWeightUOMId, AD.dblPAllocatedQty) AS dblAllocatedQty,
					dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,AD.intPUnitMeasureId,@intUnitMeasureId, AD.dblPAllocatedQty) AS dblAllocatedQtyPrice,
					CASE	WHEN	CC.strCostMethod = 'Per Unit'	THEN 
							dbo.fnCTConvertQuantityToTargetItemUOM(CC.intItemId,@intUnitMeasureId,CU.intUnitMeasureId,1)*CC.dblRate
						WHEN	CC.strCostMethod = 'Amount'		THEN
							CC.dblRate/
							dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,CD.intUnitMeasureId,@intUnitMeasureId,CD.dblQuantity)
					END *
					CASE	WHEN	CC.intCurrencyId = OY.intCurrencyID THEN	1 
							WHEN	OY.ysnSubCurrency = 1				THEN	100 	
							ELSE	1 	
					END  * -1 
					AS	dblPrice,
					ISNULL(MY.strCurrency,CY.strCurrency) AS strCurrency,
					CASE WHEN CC.intCurrencyId = @intCurrencyId THEN
								1
							ELSE
								CASE WHEN ISNULL (CC.dblFX, 0) <> 0 THEN
										CC.dblFX
									ELSE
										ISNULL(dbo.fnCTCalculateAmountBetweenCurrency(CASE WHEN CY.ysnSubCurrency = 1 THEN MY.intCurrencyID ELSE CD.intCurrencyId END,@intCurrencyId, 1, 0), 0) 
							END
					END AS dblFX,
					NULL dblBooked,
					NUll AS dblBookedPrice,
					NULL dblAccounting,
					CH.dtmContractDate,
					CC.strCostMethod strType,
					(CASE WHEN CC.strCostMethod = 'Amount' THEN  CC.dblRate WHEN CC.strCostMethod = 'Per Unit' THEN CC.dblRate * CD.dblQuantity ELSE NULL END 
									/ CD.dblQuantity) * dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,AD.intPUnitMeasureId,@intWeightUOMId, AD.dblPAllocatedQty)
									* -1 AS dblTranValue,
					99999999 + AD.intPContractDetailId AS intSort,
					CAST(0 AS BIT) ysnPosted

			FROM	@tblLGAllocationDetail	AD 
			JOIN	tblCTContractDetail		CD	ON	CD.intContractDetailId	IN	(AD.intPContractDetailId, AD.intSContractDetailId)
			JOIN	tblCTContractHeader		CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId
			JOIN	tblCTContractCost		CC	ON	CC.intContractDetailId	=	CD.intContractDetailId AND ISNULL(ysnBasis,0) = 0
			JOIN	tblICItem				IM	ON	IM.intItemId			=	CC.intItemId
			JOIN	tblCTContractType		TP	ON	TP.intContractTypeId	=	CH.intContractTypeId
			JOIN	tblICItemUOM			PU	ON	PU.intItemUOMId			=	CD.intPriceItemUOMId	LEFT
			JOIN	tblICItemUOM			CU	ON	CU.intItemUOMId			=	CC.intItemUOMId			LEFT
			JOIN	tblSMCurrency			OY	ON	OY.intCurrencyID		=	@intCurrencyId			LEFT 
			JOIN	tblSMCurrency			CY	ON	CY.intCurrencyID		=	CC.intCurrencyId		LEFT 
			JOIN	tblICM2MComputation		MC	ON	MC.intM2MComputationId	=	IM.intM2MComputationId	LEFT
			JOIN	tblSMCurrency			MY	ON	MY.intCurrencyID		=	CY.intMainCurrencyId
			WHERE	intSContractDetailId	IN (SELECT * FROM dbo.fnSplitString(@strDetailIds,',')) AND ISNULL(MC.strM2MComputation,'No')	=	'No'
		)d
		GROUP BY strItemNo, strBillId, strDescription, strConfirmed, dblPrice, strCurrency, dblFX, dblBooked, dblBookedPrice, dblAccounting, dtmContractDate, intSort, strType, dblTranValue, ysnPosted
		ORDER BY strItemNo

		UNION ALL

		-- Secondary Costs - actuals
		SELECT TOP 100 PERCENT strItemNo strContractType, strBillId strNumber, strDescription, strConfirmed, SUM(dblAllocatedQty) dblAllocatedQty, SUM(dblAllocatedQtyPrice) dblAllocatedQtyPrice, dblPrice, strCurrency, dblFX, dblBooked, dblBookedPrice, dblAccounting, dtmContractDate dtmDate, strType,dblTranValue, intSort, ysnPosted
		FROM(
			SELECT	IM.strItemNo,
					strBillId,
					TP.strContractType + ' - ' +  CH.strContractNumber AS strDescription,
					NULL AS strConfirmed,
					dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,AD.intPUnitMeasureId,@intWeightUOMId, AD.dblPAllocatedQty) AS dblAllocatedQty,
					CASE WHEN ISNULL(strBillId, '') <> '' THEN
						NULL
						ELSE
							dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,AD.intPUnitMeasureId,@intUnitMeasureId, AD.dblPAllocatedQty)
					END AS dblAllocatedQtyPrice,
					CASE	WHEN	CC.strCostMethod = 'Per Unit'	THEN 
							dbo.fnCTConvertQuantityToTargetItemUOM(CC.intItemId,@intUnitMeasureId,CU.intUnitMeasureId,1)*CC.dblRate
						WHEN	CC.strCostMethod = 'Amount'		THEN
							CC.dblRate/
							dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,CD.intUnitMeasureId,@intUnitMeasureId,CD.dblQuantity)
					END *
					CASE	WHEN	CC.intCurrencyId = OY.intCurrencyID THEN	1 
							WHEN	OY.ysnSubCurrency = 1				THEN	100 	
							ELSE	1 	
					END  * -1 
					AS	dblPrice,
					ISNULL(MY.strCurrency,CY.strCurrency) AS strCurrency,
					CASE WHEN CC.intCurrencyId = @intCurrencyId THEN
								1
							ELSE
								CASE WHEN ISNULL (CC.dblFX, 0) <> 0 THEN
										CC.dblFX
									ELSE
										ISNULL(dbo.fnCTCalculateAmountBetweenCurrency(CASE WHEN CY.ysnSubCurrency = 1 THEN MY.intCurrencyID ELSE CD.intCurrencyId END,@intCurrencyId, 1, 0), 0) 
							END
					END AS dblFX,
					NULL dblBooked,
					NUll AS dblBookedPrice,
					(dblAccounting / dblBooked) * CASE WHEN CC.strCostMethod = 'Per Unit' THEN dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,AD.intPUnitMeasureId,@intUnitMeasureId, AD.dblPAllocatedQty) ELSE 1 END * -1 AS dblAccounting,
					CH.dtmContractDate,
					CC.strCostMethod strType,
					(dblAccounting / dblBooked) * CASE WHEN CC.strCostMethod = 'Per Unit' THEN dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,AD.intPUnitMeasureId,@intUnitMeasureId, AD.dblPAllocatedQty) ELSE 1 END * -1 AS dblTranValue,
					99999999 + AD.intPContractDetailId AS intSort,
					CAST(0 AS BIT) ysnPosted

			FROM	@tblLGAllocationDetail	AD 
			JOIN	tblCTContractDetail		CD	ON	CD.intContractDetailId	IN	(AD.intPContractDetailId, AD.intSContractDetailId)
			JOIN	tblCTContractHeader		CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId
			JOIN	tblCTContractCost		CC	ON	CC.intContractDetailId	=	CD.intContractDetailId AND ISNULL(ysnBasis,0) = 0
			JOIN	tblICItem				IM	ON	IM.intItemId			=	CC.intItemId
			JOIN	tblCTContractType		TP	ON	TP.intContractTypeId	=	CH.intContractTypeId
			JOIN	tblICItemUOM			PU	ON	PU.intItemUOMId			=	CD.intPriceItemUOMId	LEFT
			JOIN	tblICItemUOM			CU	ON	CU.intItemUOMId			=	CC.intItemUOMId			LEFT
			JOIN	tblSMCurrency			OY	ON	OY.intCurrencyID		=	@intCurrencyId			LEFT 
			JOIN	tblSMCurrency			CY	ON	CY.intCurrencyID		=	CC.intCurrencyId		LEFT 
			JOIN	tblICM2MComputation		MC	ON	MC.intM2MComputationId	=	IM.intM2MComputationId	LEFT
			JOIN	tblSMCurrency			MY	ON	MY.intCurrencyID		=	CY.intMainCurrencyId	LEFT
			JOIN	(
						SELECT	BD.intContractDetailId,
								BD.intItemId,
								BL.strBillId,
								SUM(RC.dblQuantity) AS dblBooked,
								SUM(BD.dblTotal) 	dblAccounting,
								SUM(RC.dblQuantity *
										dblCost /
										CASE WHEN BD.ysnSubCurrency = 1 THEN 100 ELSE 1 END
									)	dblTranValue
						FROM	tblAPBillDetail BD
						JOIN	tblAPBill		BL	ON	BL.intBillId	=	BD.intBillId
						JOIN	tblICInventoryReceiptCharge RC ON RC.intInventoryReceiptChargeId = BD.intInventoryReceiptChargeId
						WHERE	BD.intContractDetailId IN (SELECT * FROM dbo.fnSplitString(@strDetailIds,',')) 
						GROUP BY BD.intContractDetailId, BD.intItemId, BL.strBillId
					)						BL	ON	BL.intContractDetailId = CD.intContractDetailId AND BL.intItemId = CC.intItemId	
			WHERE	intSContractDetailId	IN (SELECT * FROM dbo.fnSplitString(@strDetailIds,',')) AND ISNULL(MC.strM2MComputation,'No')	=	'No'
		)d
		GROUP BY strItemNo, strBillId, strDescription, strConfirmed, dblPrice, strCurrency, dblFX, dblBooked, dblBookedPrice, dblAccounting, dtmContractDate, intSort, strType, dblTranValue, ysnPosted
		ORDER BY strItemNo
	)t
	ORDER by intSort,strType
END