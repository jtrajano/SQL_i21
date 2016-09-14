CREATE PROCEDURE [dbo].[uspCTSequencePriceChanged]
		
	@intContractDetailId int
	
AS

BEGIN TRY
	
	DECLARE @ErrMsg					NVARCHAR(MAX),
			@dblCashPrice			NUMERIC(18,6),
			@ysnPosted				BIT,
			@strReceiptNumber		NVARCHAR(50),
			@intLastModifiedById	INT,
			@intInventoryReceiptId	INT,
			@intPricingTypeId		INT

	SELECT	@dblCashPrice = dblCashPrice, @intPricingTypeId = intPricingTypeId, @intLastModifiedById = intLastModifiedById FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId

	IF 	@intPricingTypeId NOT IN (1,6)
		RETURN

	IF OBJECT_ID('tempdb..#tblReceipt') IS NOT NULL  								
		DROP TABLE #tblReceipt								

	SELECT	DISTINCT ISNULL(IR.ysnPosted,0) ysnPosted, strReceiptNumber, RI.intInventoryReceiptId
	INTO	#tblReceipt
	FROM	tblICInventoryReceipt		IR
	JOIN	tblICInventoryReceiptItem	RI ON RI.intInventoryReceiptId = IR.intInventoryReceiptId
	WHERE	RI.intLineNo = @intContractDetailId AND IR.strReceiptType = 'Purchase Contract' AND RI.dblUnitCost <> ISNULL(@dblCashPrice,0) 

	IF EXISTS(SELECT * FROM #tblReceipt)
	BEGIN
		SELECT @intInventoryReceiptId = MIN(intInventoryReceiptId) FROM #tblReceipt WHERE ysnPosted= 1

		WHILE ISNULL(@intInventoryReceiptId,0) <> 0
		BEGIN			
			SELECT @ysnPosted = ysnPosted, @strReceiptNumber = strReceiptNumber FROM #tblReceipt WHERE intInventoryReceiptId = @intInventoryReceiptId

			EXEC uspICPostInventoryReceipt 0,0,@strReceiptNumber,@intLastModifiedById

			SELECT @intInventoryReceiptId = MIN(intInventoryReceiptId) FROM #tblReceipt WHERE ysnPosted= 1 AND intInventoryReceiptId > @intInventoryReceiptId
		END
	
		EXEC uspICUpdateInventoryReceiptUnitCost @intContractDetailId,@dblCashPrice 

		SELECT @intInventoryReceiptId = MIN(intInventoryReceiptId) FROM #tblReceipt WHERE ysnPosted= 1

		WHILE ISNULL(@intInventoryReceiptId,0) <> 0
		BEGIN			
			SELECT @ysnPosted = ysnPosted, @strReceiptNumber = strReceiptNumber FROM #tblReceipt WHERE intInventoryReceiptId = @intInventoryReceiptId

			EXEC uspICPostInventoryReceipt 1,0,@strReceiptNumber,@intLastModifiedById

			SELECT @intInventoryReceiptId = MIN(intInventoryReceiptId) FROM #tblReceipt WHERE ysnPosted= 1 AND intInventoryReceiptId > @intInventoryReceiptId 
		END
	END
	

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
GO