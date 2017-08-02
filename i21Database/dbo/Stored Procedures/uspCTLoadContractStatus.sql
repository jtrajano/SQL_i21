CREATE PROCEDURE [dbo].[uspCTLoadContractStatus]

	@intContractDetailId INT,
	@strGrid NVARCHAR(100)
AS

BEGIN TRY
	DECLARE @ErrMsg					NVARCHAR(MAX),
			@intContractHeaderId	INT

	SELECT @intContractHeaderId = intContractHeaderId FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId

	IF @strGrid = 'vyuCTContStsContractSummary'
	BEGIN
		SELECT	CAST(ROW_NUMBER() OVER (ORDER BY UP.intContractDetailId ASC) AS INT) intUniqueId,
			UP.intContractDetailId,
			UP.strName,
			UP.strValue
		FROM(
				SELECT	CD.intContractDetailId,
						ISNULL(CAST(dbo.fnRemoveTrailingZeroes(dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,QU.intUnitMeasureId,LP.intWeightUOMId,CD.dblQuantity)) AS NVARCHAR(100)) collate Latin1_General_CI_AS,'') Quantity,
						ISNULL(CAST(dbo.fnRemoveTrailingZeroes(CAST(CD.dblBasis AS NUMERIC(18, 6)))  + ' ' + CY.strCurrency + ' Per ' + PM.strUnitMeasure AS NVARCHAR(100) ) collate Latin1_General_CI_AS,'') [Differential],
						ISNULL(CAST(dbo.fnRemoveTrailingZeroes(PF.[dblLotsFixed]) + '/' + dbo.fnRemoveTrailingZeroes(PF.[dblTotalLots] - PF.[dblLotsFixed]) AS NVARCHAR(100)) collate Latin1_General_CI_AS,'') AS [Fixed/Unfixed],
						ISNULL(CAST(dbo.fnRemoveTrailingZeroes(PF.intLotsHedged) + '/' + dbo.fnRemoveTrailingZeroes(PF.[dblTotalLots] - PF.intLotsHedged) AS NVARCHAR(100)) collate Latin1_General_CI_AS,'') AS [Hedge/Not Hedge],
						ISNULL(CAST(dbo.fnRemoveTrailingZeroes(CAST(ISNULL(PF.dblFinalPrice,CD.dblCashPrice) AS NUMERIC(18, 6)))  + ' ' + CY.strCurrency + ' Per ' + ISNULL(FM.strUnitMeasure,PM.strUnitMeasure) AS NVARCHAR(100)) collate Latin1_General_CI_AS,'') [Final Price]
				FROM	tblCTContractDetail			CD 
				JOIN	tblCTContractHeader			CH	ON	CH.intContractHeaderId				=	CD.intContractHeaderId	
														AND CD.intContractDetailId				=	@intContractDetailId LEFT
				JOIN	tblCTPriceFixation			PF	ON	ISNULL(PF.intContractDetailId,0)	=	CASE	WHEN CH.ysnMultiplePriceFixation = 1 
																											THEN  ISNULL(PF.intContractDetailId,0)	
																											ELSE CD.intContractDetailId	
																									END
														AND	PF.intContractHeaderId = CD.intContractHeaderId					LEFT
	
				JOIN	tblSMCurrency				CY	ON	CY.intCurrencyID				=		CD.intCurrencyId		LEFT
				JOIN	tblICItemUOM				QU	ON	QU.intItemUOMId					=		CD.intItemUOMId			LEFT
				JOIN	tblICItemUOM				PU	ON	PU.intItemUOMId					=		CD.intPriceItemUOMId	LEFT
				JOIN	tblICUnitMeasure			PM	ON	PM.intUnitMeasureId				=		PU.intUnitMeasureId		LEFT
				JOIN	tblICCommodityUnitMeasure	FU	ON	FU.intCommodityUnitMeasureId	=		PF.intFinalPriceUOMId	LEFT
				JOIN	tblICUnitMeasure			FM	ON	FM.intUnitMeasureId				=		FU.intUnitMeasureId		CROSS	
				APPLY	tblLGCompanyPreference		LP 	
			) s
		UNPIVOT	(strValue FOR strName IN 
					(
						[Quantity],
						[Differential],
						[Fixed/Unfixed],
						[Hedge/Not Hedge],
						[Final Price]
					)
		) UP

	END
	ELSE IF @strGrid = 'vyuCTContStsPricingAndHedging'
	BEGIN
		SELECT	SY.intAssignFuturesToContractSummaryId,
				CD.intContractDetailId,
				PD.dtmFixationDate,
				PD.[dblNoOfLots],
				PD.dblFinalPrice,
				CM.strUnitMeasure strPricingUOM,
				SY.dtmMatchDate,
				SY.intHedgedLots,
				FO.dblPrice,
				MM.strUnitMeasure strHedgeUOM
		FROM	tblRKAssignFuturesToContractSummary SY 
		JOIN	tblRKFutOptTransaction				FO	ON	FO.intFutOptTransactionId		=	SY.intFutOptTransactionId	
		JOIN	tblRKFutureMarket					MA	ON	MA.intFutureMarketId			=	FO.intFutureMarketId		
		JOIn	tblICUnitMeasure					MM	ON	MM.intUnitMeasureId				=	MA.intUnitMeasureId			LEFT
		JOIN	tblCTPriceFixationDetail			PD	ON	PD.intFutOptTransactionId		=	SY.intFutOptTransactionId	LEFT
		JOIN	tblCTPriceFixation					PF	ON	PF.intPriceFixationId			=	PD.intPriceFixationId		LEFT
		JOIN	tblCTContractHeader					CH	ON	CH.intContractHeaderId			=	PF.intContractHeaderId		LEFT
		JOIN	tblCTContractDetail					CD	ON	CD.intContractDetailId = CASE WHEN CH.ysnMultiplePriceFixation = 1 THEN  CD.intContractDetailId	ELSE PF.intContractDetailId	END
														AND	CD.intContractHeaderId = CASE WHEN CH.ysnMultiplePriceFixation = 1 THEN  PF.intContractHeaderId	ELSE CD.intContractHeaderId	END	LEFT
	
		JOIN	tblICCommodityUnitMeasure			CU	ON	CU.intCommodityUnitMeasureId	=	PF.intFinalPriceUOMId		LEFT
		JOIN	tblICItemUOM						IU	ON	IU.intItemId					=	CD.intItemId				
														AND	IU.intUnitMeasureId				=	CU.intUnitMeasureId			LEFT
		JOIN	tblICUnitMeasure					CM	ON	CM.intUnitMeasureId				=	CU.intUnitMeasureId	
		WHERE	PF.intPriceFixationId IS NOT NULL AND PF.intContractHeaderId			=	@intContractHeaderId
	END
	ELSE IF @strGrid = 'vyuCTContStsQuality'
	BEGIN
		SELECT	S.intSampleId
				,S.intContractDetailId
				,S.strSampleNumber
				,ST.strSampleTypeName
				,dbo.fnCTConvertQuantityToTargetItemUOM(S.intItemId, S.intSampleUOMId, LP.intWeightUOMId, S.dblSampleQty) dblSampleQty
				,SS.strStatus
		FROM tblQMSample S
		JOIN tblQMSampleStatus SS ON SS.intSampleStatusId = S.intSampleStatusId AND S.intContractDetailId = @intContractDetailId
		JOIN tblQMSampleType ST ON ST.intSampleTypeId = S.intSampleTypeId
		CROSS APPLY tblLGCompanyPreference LP

	END
	ELSE IF @strGrid = 'vyuCTContStsAllocationSummary'
	BEGIN
		SELECT	CAST(ROW_NUMBER() OVER (ORDER BY UP.intContractDetailId ASC) AS INT) intUniqueId,
				UP.intContractDetailId,
				UP.strName,
				UP.strValue
			
		FROM	(
					SELECT	CD.intContractDetailId,
							dbo.fnRemoveTrailingZeroes(ISNULL(RV.dblReservedQuantity,0)) collate Latin1_General_CI_AS [Reserved],				
							--ISNULL(CD.dblQuantity,0) - ISNULL(RV.dblReservedQuantity,0) AS dblUnReservedQuantity,
							dbo.fnRemoveTrailingZeroes(ISNULL(PA.dblAllocatedQty,0) + ISNULL(SA.dblAllocatedQty,0)) collate Latin1_General_CI_AS  AS [Allocated],
							dbo.fnRemoveTrailingZeroes(CAST(dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,CD.intUnitMeasureId,LP.intWeightUOMId,ISNULL(CD.dblQuantity,0)) AS NUMERIC(18, 6)) - ISNULL(PA.dblAllocatedQty,0) - ISNULL(SA.dblAllocatedQty,0)) collate Latin1_General_CI_AS AS [Unallocated],
							dbo.fnRemoveTrailingZeroes(ISNULL(PL.dblPickedQty,0)) collate Latin1_General_CI_AS [Picked Qty],
							dbo.fnRemoveTrailingZeroes(ISNULL(PA.dblAllocatedQty,0) + ISNULL(SA.dblAllocatedQty,0) - PL.dblPickedQty) collate Latin1_General_CI_AS AS [To be Picked]

					FROM	tblCTContractDetail CD LEFT
					JOIN	(
								SELECT		RV.intContractDetailId,
											CAST(ISNULL(SUM(dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,RV.intUnitMeasureId,LP.intWeightUOMId,dblReservedQuantity)),0) AS NUMERIC(18, 6)) AS dblReservedQuantity 
								FROM		tblLGReservation		RV		
								JOIN		tblCTContractDetail		CD	ON	CD.intContractDetailId = RV.intContractDetailId	AND CD.intContractDetailId = @intContractDetailId CROSS	
								APPLY		tblLGCompanyPreference	LP
								Group By	RV.intContractDetailId,CD.intItemId,RV.intUnitMeasureId,LP.intWeightUOMId
							)	RV	  ON	RV.intContractDetailId		=	CD.intContractDetailId		
					AND		CD.intContractDetailId = @intContractDetailId								LEFT	
					JOIN	(
								SELECT		RV.intPContractDetailId,
											CAST(ISNULL(SUM(dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,RV.intPUnitMeasureId,LP.intWeightUOMId,dblPAllocatedQty)),0) AS NUMERIC(18, 6))  AS dblAllocatedQty
								FROM		tblLGAllocationDetail	RV		
								JOIN		tblCTContractDetail		CD	ON	CD.intContractDetailId = RV.intPContractDetailId AND CD.intContractDetailId = @intContractDetailId	 CROSS	
								APPLY		tblLGCompanyPreference	LP
								Group By	intPContractDetailId,CD.intItemId,RV.intPUnitMeasureId,LP.intWeightUOMId
							)	PA	  ON	PA.intPContractDetailId		=	CD.intContractDetailId		LEFT	
					JOIN	(
								SELECT		intSContractDetailId,
											CAST(ISNULL(SUM(dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,RV.intSUnitMeasureId,LP.intWeightUOMId,dblSAllocatedQty)),0) AS NUMERIC(18, 6))  AS dblAllocatedQty
								FROM		tblLGAllocationDetail	RV		
								JOIN		tblCTContractDetail		CD	ON	CD.intContractDetailId = RV.intPContractDetailId AND CD.intContractDetailId = @intContractDetailId	 CROSS	
								APPLY		tblLGCompanyPreference	LP 
								Group By	intSContractDetailId,CD.intItemId,RV.intSUnitMeasureId,LP.intWeightUOMId
							)	SA	  ON	SA.intSContractDetailId		=	CD.intContractDetailId		LEFT
					JOIN	(
								SELECT		intContractDetailId,CAST(ISNULL(SUM(dblPickedQty),0) AS NUMERIC(18, 6))  AS dblPickedQty
								FROM		vyuCTContStsPickedLot 
								WHERE		intContractDetailId = @intContractDetailId
								Group By	intContractDetailId
							)	PL	  ON	PL.intContractDetailId		=	CD.intContractDetailId	CROSS	
					APPLY	tblLGCompanyPreference	LP
					WHERE	CD.intContractDetailId = @intContractDetailId
				) s
				UNPIVOT	(strValue FOR strName IN 
								(
									[Allocated],
									[Unallocated],
									[Picked Qty],
									[To be Picked],
									[Reserved]
								)
				) UP
	END
	ELSE IF @strGrid = 'vyuCTContStsContainer'
	BEGIN
		SELECT	CAST(ROW_NUMBER() OVER (ORDER BY intContractDetailId ASC) AS INT) intUniqueId,*
		FROM
		(	
				SELECT	CQ.intPContractDetailId intContractDetailId,
						SH.strBLNumber,
						BC.strContainerNumber,
						dbo.fnCTConvertQuantityToTargetItemUOM(CQ.intItemId,BC.intWeightUnitMeasureId,LP.intWeightUOMId,BC.dblNetWt) dblShippedWeight,
						IU.intItemUOMId,
						IM.strUnitMeasure,
						CAST(CASE WHEN  SH.intPurchaseSale = 3 THEN 1 ELSE 0 END AS BIT) ysnDirectShipment
					
				FROM	tblLGLoadDetailContainerLink		CC  
				JOIN	tblLGLoadDetail						CQ	ON	CQ.intLoadDetailId			=	CC.intLoadDetailId
																AND	CQ.intPContractDetailId		=	@intContractDetailId
				JOIN	tblLGLoad							SH	ON	SH.intLoadId				=	CC.intLoadId  
				JOIN	tblICItemUOM						IU	ON	IU.intItemId				=	CQ.intItemId	 
																AND	IU.intUnitMeasureId			=	SH.intWeightUnitMeasureId 
				JOIN	tblICUnitMeasure					IM	ON	IM.intUnitMeasureId			=	IU.intUnitMeasureId			LEFT
				JOIN	tblLGLoadContainer					BC	ON	BC.intLoadContainerId		=	CC.intLoadContainerId		CROSS	
				APPLY	tblLGCompanyPreference	LP 	

				UNION ALL

				SELECT	AD.intSContractDetailId,
						SH.strBLNumber,
						BC.strContainerNumber,
						dbo.fnCTConvertQuantityToTargetItemUOM(CQ.intItemId,BC.intWeightUnitMeasureId,LP.intWeightUOMId,BC.dblNetWt) dblShippedWeight,
						IU.intItemUOMId,
						IM.strUnitMeasure,
						CAST(CASE WHEN  SH.intPurchaseSale = 3 THEN 1 ELSE 0 END AS BIT) ysnDirectShipment
					
				FROM	tblLGLoadDetailContainerLink		CC  
				JOIN	tblLGLoadDetail						CQ	ON	CQ.intLoadDetailId				=	CC.intLoadDetailId 
				JOIN	tblLGAllocationDetail				AD	ON	AD.intPContractDetailId			=	CQ.intPContractDetailId 
																AND	CQ.intSContractDetailId			=	@intContractDetailId
				JOIN	tblLGLoad							SH	ON	SH.intLoadId					=	CC.intLoadId  
				JOIN	tblICItemUOM						IU	ON	IU.intItemId					=	CQ.intItemId	 
																AND	IU.intUnitMeasureId				=	SH.intWeightUnitMeasureId 
				JOIN	tblICUnitMeasure					IM	ON	IM.intUnitMeasureId				=	IU.intUnitMeasureId			LEFT
				JOIN	tblLGLoadContainer					BC	ON	BC.intLoadContainerId			=	CC.intLoadContainerId		CROSS	
				APPLY	tblLGCompanyPreference	LP 	  
		)t
	END
	ELSE IF @strGrid = 'vyuCTContStsGoodsShipped'
	BEGIN
		SELECT	CAST(ROW_NUMBER() OVER (ORDER BY intContractDetailId ASC) AS INT) intUniqueId,*
		FROM
		(			
				SELECT	CQ.intPContractDetailId intContractDetailId,
						SH.strLoadNumber,
						IU.intItemUOMId,
						dbo.fnCTConvertQuantityToTargetItemUOM(CQ.intItemId,IU.intUnitMeasureId,LP.intWeightUOMId,CQ.dblNet)	AS dblNetWeight,
						IM.strUnitMeasure,
						SH.intShipmentType,
						SH.intLoadId,
						'intLoadId' AS strIdColumn
				FROM	tblLGLoadDetail	CQ
				JOIN	tblLGLoad					SH	ON	SH.intLoadId			=	CQ.intLoadId 
														AND	CQ.intPContractDetailId	=	@intContractDetailId
				JOIN	tblICItemUOM				IU	ON	IU.intItemId			=	CQ.intItemId	
														AND IU.intUnitMeasureId		=	SH.intWeightUnitMeasureId
				JOIN	tblICUnitMeasure			IM	ON	IM.intUnitMeasureId		=	IU.intUnitMeasureId		CROSS	
				APPLY	tblLGCompanyPreference		LP 	

				UNION ALL

				SELECT	AD.intSContractDetailId,
						SH.strLoadNumber,
						IU.intItemUOMId,
						dbo.fnCTConvertQuantityToTargetItemUOM(CQ.intItemId,IU.intUnitMeasureId,LP.intWeightUOMId,CQ.dblNet),
						IM.strUnitMeasure,
						SH.intShipmentType,
						SH.intLoadId,
						'intLoadId' AS strIdColumn
				FROM	tblLGLoadDetail	CQ
				JOIN	tblLGLoad					SH	ON	SH.intLoadId			=	CQ.intLoadId 
														AND	CQ.intSContractDetailId	=	@intContractDetailId
				JOIN	tblLGAllocationDetail		AD	ON	AD.intPContractDetailId =	CQ.intPContractDetailId
				JOIN	tblICItemUOM				IU	ON	IU.intItemId			=	CQ.intItemId	
														AND IU.intUnitMeasureId		=	SH.intWeightUnitMeasureId
				JOIN	tblICUnitMeasure			IM	ON	IM.intUnitMeasureId		=	IU.intUnitMeasureId		CROSS	
				APPLY	tblLGCompanyPreference		LP 	
		)t
	END
	ELSE IF @strGrid = 'vyuCTContStsInventoryReceipt'
	BEGIN
		SELECT	CAST(ROW_NUMBER() OVER (ORDER BY intContractDetailId ASC) AS INT) intUniqueId,*
		FROM
		(		
			SELECT	RI.intLineNo AS intContractDetailId,
					IR.strReceiptNumber, 
					RL.strLotNumber, 
					CASE	WHEN IR.strReceiptType = 'Inventory Return' 
								THEN -1*RL.dblQuantity
								ELSE	RL.dblQuantity
					END AS dblQuantity,
					dbo.fnCTConvertQuantityToTargetItemUOM(RI.intItemId,IU.intUnitMeasureId,LP.intWeightUOMId,
						CASE	WHEN IR.strReceiptType = 'Inventory Return' 
								THEN -1*(RL.dblGrossWeight - RL.dblTareWeight) 
								ELSE	(RL.dblGrossWeight - RL.dblTareWeight) 
						END
					) AS dblNetWeight,
					RI.intWeightUOMId intItemUOMId,
					IM.strUnitMeasure,
					SL.strSubLocationName,
					IR.intInventoryReceiptId
				
			FROM	tblICInventoryReceiptItemLot	RL
			JOIN	tblICInventoryReceiptItem		RI	ON	RI.intInventoryReceiptItemId		=	RL.intInventoryReceiptItemId
														AND	RI.intLineNo						=	@intContractDetailId
			JOIN	tblICInventoryReceipt			IR	ON	IR.intInventoryReceiptId			=	RI.intInventoryReceiptId 
														AND IR.strReceiptType					IN	('Purchase Contract','Inventory Return')
			JOIN	tblSMCompanyLocationSubLocation SL	ON	SL.intCompanyLocationSubLocationId	=	RI.intSubLocationId
			JOIN	tblICItemUOM					IU	ON	IU.intItemUOMId						=	RI.intWeightUOMId
			JOIN	tblICUnitMeasure				IM	ON	IM.intUnitMeasureId					=	IU.intUnitMeasureId		CROSS	
			APPLY	tblLGCompanyPreference			LP 	

			UNION ALL

			SELECT	AD.intSContractDetailId,
					IR.strReceiptNumber, 
					RL.strLotNumber, 
					CASE	WHEN IR.strReceiptType = 'Inventory Return' 
								THEN -1*RL.dblQuantity
								ELSE	RL.dblQuantity
					END AS dblQuantity,
					dbo.fnCTConvertQuantityToTargetItemUOM(RI.intItemId,IU.intUnitMeasureId,LP.intWeightUOMId,
						CASE	WHEN IR.strReceiptType = 'Inventory Return' 
								THEN -1*(RL.dblGrossWeight - RL.dblTareWeight) 
								ELSE	(RL.dblGrossWeight - RL.dblTareWeight) 
						END
					) AS dblNetWeight,
					RI.intWeightUOMId intItemUOMId,
					IM.strUnitMeasure,
					SL.strSubLocationName,
					IR.intInventoryReceiptId

			FROM	tblICInventoryReceiptItemLot	RL
			JOIN	tblICInventoryReceiptItem		RI	ON	RI.intInventoryReceiptItemId		=	RL.intInventoryReceiptItemId
														AND	RI.intLineNo						=	@intContractDetailId
			JOIN	tblICInventoryReceipt			IR	ON	IR.intInventoryReceiptId			=	RI.intInventoryReceiptId 
														AND IR.strReceiptType					=	'Purchase Contract'
			JOIN	tblSMCompanyLocationSubLocation SL	ON	SL.intCompanyLocationSubLocationId	=	RI.intSubLocationId
			JOIN	tblICItemUOM					IU	ON	IU.intItemUOMId						=	RI.intWeightUOMId
			JOIN	tblICUnitMeasure				IM	ON	IM.intUnitMeasureId					=	IU.intUnitMeasureId
			JOIN	tblLGAllocationDetail			AD	ON	AD.intPContractDetailId				=	RI.intLineNo		CROSS	
			APPLY	tblLGCompanyPreference			LP 	
		)t
	END
	ELSE IF @strGrid = 'vyuCTContStsReceiptSummary'
	BEGIN
		SELECT	CAST(ROW_NUMBER() OVER (ORDER BY UP.intContractDetailId ASC) AS INT) intUniqueId,
				UP.intContractDetailId,
				UP.strName,
				UP.strValue
		FROM	(
					SELECT	CD.intContractDetailId,
							CAST(dbo.fnRemoveTrailingZeroes(GS.dblNetWeight) AS NVARCHAR(100)) collate Latin1_General_CI_AS						[Shipped],
							CAST(dbo.fnRemoveTrailingZeroes(dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,GS.intItemUOMId, CD.dblQuantity)) - GS.dblNetWeight AS NVARCHAR(100)) collate Latin1_General_CI_AS		[To be Shipped],
							CAST(dbo.fnRemoveTrailingZeroes(CR.dblShippedWeight) AS NVARCHAR(100)) collate Latin1_General_CI_AS					[Recd Wt in Wh],
							CAST(dbo.fnRemoveTrailingZeroes(dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,GS.intItemUOMId, CD.dblQuantity)) - CR.dblShippedWeight AS NVARCHAR(100)) collate Latin1_General_CI_AS	[To be Received]
					FROM	tblCTContractDetail			CD								LEFT
					JOIN	(
								SELECT	intContractDetailId,
										CAST(SUM(dblNetWeight) AS NUMERIC(18, 6)) dblNetWeight,
										MIN(intItemUOMId) intItemUOMId
								FROM	vyuCTContStsGoodsShipped
								WHERE	intShipmentType <> 2 
								AND		intContractDetailId	=	@intContractDetailId
								GROUP
								BY		intContractDetailId		
							)GS	ON	GS.intContractDetailId	=	CD.intContractDetailId	
					AND		CD.intContractDetailId	=	@intContractDetailId LEFT
					JOIN	(
								SELECT	intContractDetailId,
										CAST(SUM(dblNetWeight) AS NUMERIC(18, 6)) dblShippedWeight,
										MIN(intItemUOMId) intItemUOMId 
								FROM	vyuCTContStsInventoryReceipt	
								WHERE	intContractDetailId	=	@intContractDetailId
								GROUP
								BY		intContractDetailId	
							)CR	ON	CR.intContractDetailId	=	CD.intContractDetailId	
					WHERE	CD.intContractDetailId	=	@intContractDetailId
				) s
		UNPIVOT	(strValue FOR strName IN 
					(
						[Shipped],
						[To be Shipped],
						[Recd Wt in Wh],
						[To be Received]
					)
		) UP
	END
	ELSE IF @strGrid = 'vyuCTContStsVendorInvoice'
	BEGIN
		SELECT	CAST(ROW_NUMBER() OVER (ORDER BY intContractDetailId ASC) AS INT) intUniqueId,
			*
		FROM	(
					SELECT	CD.intContractDetailId,
							BL.strBillId,
							CH.strContractNumber,
							SUM(BD.dblTotal)dblTotal,
							CY.strCurrency,
							BL.intBillId
					FROM	tblCTContractDetail CD
					JOIN	tblCTContractHeader CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId
													AND	CD.intContractDetailId	=	@intContractDetailId
					JOIN	tblAPBillDetail		BD	ON	BD.intContractDetailId	=	CD.intContractDetailId
					JOIN	tblAPBill			BL	ON	BL.intBillId			=	BD.intBillId
					JOIN	tblSMCurrency		CY	ON	CY.intCurrencyID		=	BL.intCurrencyId
					GROUP 
					BY		CD.intContractDetailId,BL.strBillId,CH.strContractNumber,CY.strCurrency,BL.intBillId

					UNION ALL

					SELECT	AD.intSContractDetailId,
							BL.strBillId,
							CH.strContractNumber,
							SUM(BD.dblTotal)dblTotal,
							CY.strCurrency,
							BL.intBillId
					FROM	tblCTContractDetail		CD
					JOIN	tblLGAllocationDetail	AD	ON	AD.intSContractDetailId =	CD.intContractDetailId
														AND	CD.intContractDetailId	=	@intContractDetailId
					JOIN	tblCTContractDetail		PD	ON	PD.intContractDetailId	=	AD.intPContractDetailId
					JOIN	tblCTContractHeader		CH	ON	CH.intContractHeaderId	=	PD.intContractHeaderId
					JOIN	tblAPBillDetail			BD	ON	BD.intContractDetailId	=	PD.intContractDetailId
					JOIN	tblAPBill				BL	ON	BL.intBillId			=	BD.intBillId
					JOIN	tblSMCurrency			CY	ON	CY.intCurrencyID		=	BL.intCurrencyId
					GROUP 
					BY		AD.intSContractDetailId,BL.strBillId,CH.strContractNumber,CY.strCurrency,BL.intBillId
				)t	
	END
END TRY
BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')
END CATCH
