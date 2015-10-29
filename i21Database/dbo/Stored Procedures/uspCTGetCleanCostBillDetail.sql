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
	
	IF @intCleanCostUOMId IS NULL OR @intCleanCostCurrencyId IS NULL
	BEGIN 
		RAISERROR('Clean cost configuration is missing under Company Configuration.',16,1)
	END

	SELECT	@intBillId = intBillId 
	FROM	tblAPBillDetail
	WHERE	intInventoryReceiptItemId = @intInventoryReceiptItemId

	SELECT	BD.intBillDetailId AS intExpenseId,
			BD.intItemId,
			CASE	WHEN BL.intCurrencyId = @intCleanCostCurrencyId THEN BD.dblTotal
					ELSE CAST(NULL AS NUMERIC(18,0)) 
			END		AS dblValueInCCCurrency,
			dbo.fnCTConvertQuantityToTargetItemUOM(BD.intItemId,IU.intUnitMeasureId, @intCleanCostUOMId, RI.dblNet) dblQuantity,
			RI.intWeightUOMId AS intQuantityUOMId ,
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
	JOIN	tblAPBill					BL	ON	BL.intBillId					=	BD.intBillId
	JOIN	tblICItem					IM	ON	IM.intItemId					=	BD.intItemId					LEFT
	JOIN	tblICInventoryReceiptItem	RI	ON	RI.intInventoryReceiptItemId	=	BD.intInventoryReceiptItemId	LEFT
	JOIN	tblICItemUOM				IU	ON	IU.intItemUOMId					=	RI.intWeightUOMId				LEFT
	JOIN	tblSMCurrency				CU	ON	CU.intCurrencyID				=	BL.intCurrencyId
	WHERE	BD.intBillId = @intBillId
	ORDER BY BD.intBillDetailId DESC

END TRY
BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')  
END CATCH
