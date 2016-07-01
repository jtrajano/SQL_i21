CREATE PROCEDURE [dbo].[uspCTGetCleanCostBillDetail]
	@intContractDetailId INT,
	@intShipmentId INT,
	@intInventoryReceiptId INT
AS
BEGIN TRY
	DECLARE @intInventoryReceiptItemId	INT,
			@intBillId					INT,
			@intCleanCostUOMId			INT,
			@intCleanCostCurrencyId		INT,
			@intSourceId				INT,
			@intContractHeaderId		INT,
			@ErrMsg						NVARCHAR(MAX)
			
	SELECT	@intSourceId = intShipmentContractQtyId
	FROM	tblLGShipmentContractQty
	WHERE	intContractDetailId = @intContractDetailId AND intShipmentId = @intShipmentId

	SELECT	@intInventoryReceiptItemId	=	intInventoryReceiptItemId 
	FROM	tblICInventoryReceiptItem 
	WHERE	intSourceId					=	@intSourceId 
	AND		intInventoryReceiptId		=	@intInventoryReceiptId

	SELECT 	@intCleanCostUOMId		= intCleanCostUOMId , 
			@intCleanCostCurrencyId = intCleanCostCurrencyId 
	FROM	tblCTCompanyPreference
	
	SELECT	@intContractHeaderId	= intContractHeaderId 
	FROM	tblCTContractDetail
	WHERE	intContractDetailId		=	@intContractDetailId

	IF @intCleanCostUOMId IS NULL OR @intCleanCostCurrencyId IS NULL
	BEGIN 
		RAISERROR('Clean cost configuration is missing under Company Configuration.',16,1)
	END

	SELECT	@intBillId = intBillId 
	FROM	tblAPBillDetail
	WHERE	intInventoryReceiptItemId = @intInventoryReceiptItemId

	SELECT	intItemId,
			SUM(dblValueInCCCurrency)dblValueInCCCurrency,
			SUM(dblQuantity)dblQuantity,
			MAX(intQuantityUOMId)intQuantityUOMId,
			MAX(intCCCurrencyId)intCCCurrencyId,
			SUM(dblValueInOtherCurrency)dblValueInOtherCurrency,
			MAX(intOtherCurrencyId)intOtherCurrencyId,
			ysnValueEnable,
			ysnOtherCurrencyEnable,
			strItemNo,
			strOtherCurrency
	FROM	(
				SELECT	BD.intItemId,
						CASE	WHEN BL.intCurrencyId = @intCleanCostCurrencyId THEN BD.dblTotal
								ELSE CAST(NULL AS NUMERIC(18,0)) 
						END		AS dblValueInCCCurrency,
						CASE	WHEN BD.intWeightUOMId IS NOT NULL
								THEN dbo.fnCTConvertQuantityToTargetItemUOM(BD.intItemId,IU.intUnitMeasureId, @intCleanCostUOMId, BD.dblNetWeight) 
								ELSE NULL 
						END
						dblQuantity,
						BD.intWeightUOMId AS intQuantityUOMId ,
						@intCleanCostCurrencyId intCCCurrencyId,
						CASE	WHEN	BL.intCurrencyId = @intCleanCostCurrencyId THEN CAST(NULL AS NUMERIC(18,0))
								ELSE	BD.dblTotal 
						END		AS		dblValueInOtherCurrency,
						CASE	WHEN	BL.intCurrencyId = @intCleanCostCurrencyId THEN CAST(NULL AS INT)
								ELSE	BL.intCurrencyId 
						END		AS		intOtherCurrencyId,
						CAST(NULL AS NUMERIC(18,0))  AS dblFX,
						CASE	WHEN	BL.intCurrencyId = @intCleanCostCurrencyId THEN CAST(0 AS BIT)
								ELSE	CAST(1 AS BIT)
						END		AS		ysnValueEnable,
						CAST(0 AS BIT)	AS ysnQuantityEnable,
						CASE	WHEN	BL.intCurrencyId = @intCleanCostCurrencyId THEN CAST(1 AS BIT)
								ELSE	CAST(0 AS BIT)
						END		AS		ysnOtherCurrencyEnable,
						IM.strItemNo,
						CASE	WHEN	BL.intCurrencyId = @intCleanCostCurrencyId THEN ''
								ELSE	CU.strCurrency 
						END		AS		strOtherCurrency


				FROM	tblAPBillDetail				BD
				JOIN	tblAPBill					BL	ON	BL.intBillId		=	BD.intBillId
				JOIN	tblICItem					IM	ON	IM.intItemId		=	BD.intItemId		 LEFT			
				JOIN	tblICItemUOM                IU  ON  IU.intItemUOMId     =   BD.intWeightUOMId    LEFT
                JOIN	tblSMCurrency               CU  ON  CU.intCurrencyID    =   BL.intCurrencyId
                WHERE	BD.intContractDetailId = @intContractDetailId AND BL.intTransactionType = 1 
				
				UNION ALL 
				
				SELECT	DISTINCT
						BD.intItemId,
						CASE	WHEN BL.intCurrencyId = @intCleanCostCurrencyId THEN BD.dblTotal
								ELSE CAST(NULL AS NUMERIC(18,0)) 
						END		AS dblValueInCCCurrency,
						dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,BD.intUnitOfMeasureId, @intCleanCostUOMId, BD.dblQtyReceived) AS dblQuantity,
						NUll AS intQuantityUOMId ,
						@intCleanCostCurrencyId intCCCurrencyId,
						CASE	WHEN	BL.intCurrencyId = @intCleanCostCurrencyId THEN CAST(NULL AS NUMERIC(18,0))
								ELSE	BD.dblTotal 
						END		AS		dblValueInOtherCurrency,
						CASE	WHEN	BL.intCurrencyId = @intCleanCostCurrencyId THEN CAST(NULL AS INT)
								ELSE	BL.intCurrencyId 
						END		AS		intOtherCurrencyId,
						CAST(NULL AS NUMERIC(18,0))  AS dblFX,
						CASE	WHEN	BL.intCurrencyId = @intCleanCostCurrencyId THEN CAST(0 AS BIT)
								ELSE	CAST(1 AS BIT)
						END		AS		ysnValueEnable,
						CAST(0 AS BIT)	AS ysnQuantityEnable,
						CASE	WHEN	BL.intCurrencyId = @intCleanCostCurrencyId THEN CAST(1 AS BIT)
								ELSE	CAST(0 AS BIT)
						END		AS		ysnOtherCurrencyEnable,
						'Pre-Payment',
						CASE	WHEN	BL.intCurrencyId = @intCleanCostCurrencyId THEN ''
								ELSE	CU.strCurrency 
						END		AS		strOtherCurrency


				FROM	tblAPBillDetail				BD
				JOIN	tblAPBill					BL	ON	BL.intBillId					=	BD.intBillId
				JOIN	tblSMCurrency				CU	ON	CU.intCurrencyID				=	BL.intCurrencyId
				JOIN	tblCTContractDetail			CD	ON	CD.intContractHeaderId			=	BD.intContractHeaderId
				JOIN	tblICItemUOM				PM	ON	PM.intItemUOMId					=	CD.intPriceItemUOMId
				WHERE	BD.intContractHeaderId	=	@intContractHeaderId AND BL.intTransactionType = 2
		)t
		GROUP BY	intItemId,
					intCCCurrencyId,
					ysnValueEnable,
					ysnOtherCurrencyEnable,
					strItemNo,
					strOtherCurrency
		ORDER BY	dblQuantity DESC

END TRY
BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')  
END CATCH
