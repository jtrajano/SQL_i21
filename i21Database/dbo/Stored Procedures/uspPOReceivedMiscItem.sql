CREATE PROCEDURE [dbo].[uspPOReceivedMiscItem]
	@voucherPayables AS VoucherPayable READONLY,
	@decrease BIT = 0
AS
BEGIN

	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	-- SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF


	BEGIN TRY

	DECLARE @SavePoint NVARCHAR(32) = 'uspPOReceivedMiscItem';
	DECLARE @transCount INT = @@TRANCOUNT;
	DECLARE @error NVARCHAR(MAX);
	DECLARE @decreaseQty BIT = @decrease
	DECLARE @purchaseId INT;
	/*
	SELECT @posted = ysnPosted FROM tblAPBill WHERE intBillId = @billId;

	SELECT	B.intBillId
			,B.[intPurchaseDetailId]
			,Billed.dblQtyReceived
			,B.intItemId
			,A.ysnPosted
	INTO	#tmpReceivedPOMiscItems
	FROM	tblAPBill A 
			INNER JOIN tblAPBillDetail B 
				ON A.intBillId = B.intBillId
			INNER JOIN @voucherDetailIds B2 ON B.intBillDetailId = B2.intBillDetailId
			LEFT JOIN tblICItem C
				ON B.intItemId = C.intItemId
			LEFT JOIN tblPOPurchaseDetail D
				ON D.intPurchaseDetailId = B.intPurchaseDetailId
	CROSS APPLY (
			SELECT SUM(ISNULL(G.dblQtyReceived,0)) AS dblQtyReceived FROM tblAPBillDetail G WHERE G.intPurchaseDetailId = D.intPurchaseDetailId
	) Billed	
	WHERE
	(dbo.fnIsStockTrackingItem(C.intItemId) = 0 OR C.intItemId IS NULL)
	--(C.strType IN ('Service','Software','Non-Inventory','Other Charge') OR C.intItemId IS NULL)
	AND D.intPurchaseDetailId IS NOT NULL
	*/
	--UPDATING ON ORDER QUANTITY
	/*
	DECLARE @ItemToUpdateOnOrderQty ItemCostingTableType

	-- Get the list. 
	INSERT INTO @ItemToUpdateOnOrderQty (
			dtmDate
			,intItemId
			,intItemLocationId
			,intItemUOMId
			,intSubLocationId
			,dblQty
			,dblUOMQty
			,intTransactionId
			,intTransactionDetailId
			,strTransactionId
			,intTransactionTypeId
	)
	SELECT	dtmDate					= A.dtmDate
			,intItemId				= B.intItemId
			,intItemLocationId		= ItemLocation.intItemLocationId
			,intItemUOMId			= C.intUnitOfMeasureId
			,intSubLocationId		= C.intSubLocationId
			,dblQty					= B.dblQtyReceived * -1 --CASE WHEN @posted = 1 THEN -1 ELSE 1 END -- dbo.fnCalculateQtyBetweenUOM(ReceiptItem.intUnitMeasureId, PODetail.intUnitOfMeasureId, ReceiptItem.dblOpenReceive) 
			,dblUOMQty				= 1   --1 -- Keep value as one (1). The dblQty is converted manually by using the fnCalculateQtyBetweenUOM function.
			,intTransactionId		= A.intBillId
			,intTransactionDetailId = B.intBillDetailId
			,strTransactionId		= A.strBillId
			,intTransactionTypeId	= -1 -- any value
	FROM	dbo.tblAPBill A
			INNER JOIN dbo.tblAPBillDetail B
				ON A.intBillId = B.intBillId
			INNER JOIN @voucherDetailIds B2 ON B.intBillDetailId = B2.intBillDetailId
			INNER JOIN tblPOPurchaseDetail C
				ON B.intPurchaseDetailId = C.intPurchaseDetailId
			LEFT JOIN dbo.tblICItemLocation ItemLocation
				ON ItemLocation.intItemId = B.intItemId
				AND ItemLocation.intLocationId = A.intShipToId				
			LEFT JOIN dbo.tblICItemUOM	ItemUOM
				ON ItemUOM.intItemUOMId = ItemLocation.intReceiveUOMId
	WHERE	
	B.intUnitOfMeasureId > 0
	*/
	
	
	IF @transCount = 0 BEGIN TRANSACTION
	ELSE SAVE TRAN @SavePoint

	DECLARE @counter INT = 0, @countReceivedMisc INT, @purchaseDetailId INT;
	SET @countReceivedMisc = (SELECT COUNT(*) FROM @voucherPayables);

	UPDATE	A
	SET		A.dblQtyReceived = (CASE	WHEN	 @decreaseQty = 1 THEN A.dblQtyReceived - B.dblQuantityToBill
										ELSE	  A.dblQtyReceived + B.dblQuantityToBill
								END)
	FROM	tblPOPurchaseDetail A 
	INNER JOIN @voucherPayables B 
		ON	A.intPurchaseDetailId = B.[intPurchaseDetailId]
	LEFT JOIN tblICItem C
		ON A.intItemId = C.intItemId
	WHERE (dbo.fnIsStockTrackingItem(C.intItemId) = 0 OR C.intItemId IS NULL)
	
	--Validate
	IF(@@ROWCOUNT != @countReceivedMisc)
	BEGIN
		RAISERROR('There was a problem on updating item quantity receive.', 16, 1);
		RETURN;
	END

	DECLARE @po NVARCHAR(50);
	DECLARE @itemDesc NVARCHAR(100);

	--DO NOT ALLOW OVER BILL OF MISC ITEM
	SELECT TOP 1
		@po = A2.strPurchaseOrderNumber
		,@itemDesc = ISNULL(C.strItemNo, A.strMiscDescription)
	FROM tblPOPurchaseDetail A
	INNER JOIN tblPOPurchase A2 ON A.intPurchaseId = A2.intPurchaseId
	INNER JOIN @voucherPayables B
		ON A.intPurchaseDetailId = B.intPurchaseDetailId
	LEFT JOIN tblICItem C
		ON A.intItemId = C.intItemId
	WHERE (dbo.fnIsStockTrackingItem(C.intItemId) = 0 OR C.intItemId IS NULL)
	AND A.dblQtyReceived > A.dblQtyOrdered
	AND A.dblQtyReceived != 0

	IF @po IS NOT NULL
	BEGIN
		SET @error = 'You cannot over bill (' + @itemDesc + ') for ' + @po;
		RAISERROR(@error, 16, 1);
		RETURN;
	END

	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpPurchaseId')) DROP TABLE #tmpPurchaseId
	
	SELECT DISTINCT
		B.intPurchaseId
	INTO #tmpPurchaseId
	FROM @voucherPayables A 
	INNER JOIN tblPOPurchaseDetail B 
		ON A.[intPurchaseDetailId] = B.intPurchaseDetailId	

	--Update PO Status
	WHILE EXISTS(SELECT 1 FROM #tmpPurchaseId)
	BEGIN
		SELECT TOP(1) 
			@purchaseId = intPurchaseId
		FROM #tmpPurchaseId
		EXEC uspPOUpdateStatus @purchaseId, DEFAULT
		DELETE FROM #tmpPurchaseId WHERE intPurchaseId = @purchaseId
	END

	IF @transCount = 0
		BEGIN
			IF (XACT_STATE()) = -1
			BEGIN
				ROLLBACK TRANSACTION
			END
			ELSE IF (XACT_STATE()) = 1
			BEGIN
				COMMIT TRANSACTION
			END
		END		
	ELSE
		BEGIN
			IF (XACT_STATE()) = -1
			BEGIN
				ROLLBACK TRANSACTION  @SavePoint
			END
		END	
	END TRY
	BEGIN CATCH
	DECLARE @ErrorSeverity INT,
			@ErrorNumber   INT,
			@ErrorMessage nvarchar(4000),
			@ErrorState INT,
			@ErrorLine  INT,
			@ErrorProc nvarchar(200);
	-- Grab error information from SQL functions
	SET @ErrorSeverity = ERROR_SEVERITY()
	SET @ErrorNumber   = ERROR_NUMBER()
	SET @ErrorMessage  = ERROR_MESSAGE()
	SET @ErrorState    = ERROR_STATE()
	SET @ErrorLine     = ERROR_LINE()

	IF @transCount = 0
		BEGIN
			IF (XACT_STATE()) = -1
			BEGIN
				ROLLBACK TRANSACTION
			END
			ELSE IF (XACT_STATE()) = 1
			BEGIN
				COMMIT TRANSACTION
			END
		END		
	ELSE
		BEGIN
			IF (XACT_STATE()) = -1
			BEGIN
				ROLLBACK TRANSACTION  @SavePoint
			END
		END	

	RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
	END CATCH

END