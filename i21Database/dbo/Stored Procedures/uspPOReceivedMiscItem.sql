CREATE PROCEDURE [dbo].[uspPOReceivedMiscItem]
	@billId INT
AS
BEGIN

	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @posted BIT = 0;
	DECLARE @purchaseId INT;

	SELECT @posted = ysnPosted FROM tblAPBill WHERE intBillId = @billId;

	SELECT	B.intBillId
			,B.[intPurchaseDetailId]
			,B.dblQtyReceived
			,B.intItemId
			,A.ysnPosted
	INTO	#tmpReceivedPOMiscItems
	FROM	tblAPBill A INNER JOIN tblAPBillDetail B 
				ON A.intBillId = B.intBillId
			INNER JOIN tblICItem C
				ON B.intItemId = C.intItemId
	WHERE	A.intBillId= @billId
	AND C.strType IN ('Service','Software','Non-Inventory','Other Charge')

	--SELECT TOP 1 @posted = ysnPosted FROM #tmpReceivedPOMiscItems

	UPDATE	A
	SET		A.dblQtyReceived = CASE	WHEN	 @posted = 1 THEN (A.dblQtyReceived + B.dblQtyReceived) 
									ELSE (A.dblQtyReceived - B.dblQtyReceived) 
							END
	FROM	tblPOPurchaseDetail A INNER JOIN #tmpReceivedPOMiscItems B 
				ON A.intItemId = B.intItemId 
				AND A.intPurchaseDetailId = B.[intPurchaseDetailId]

	--Validate
	IF(@@ROWCOUNT != (SELECT COUNT(*) FROM #tmpReceivedPOMiscItems))
	BEGIN
		RAISERROR('There was a problem on updating item quantity receive.', 16, 1);
	END

	--Update PO Status
	DECLARE @counter INT = 0, @countReceivedMisc INT, @purchaseDetailId INT;
	SET @countReceivedMisc = (SELECT COUNT(*) FROM #tmpReceivedPOMiscItems)

	WHILE @counter != @countReceivedMisc
	BEGIN
		SET @counter = @counter + 1;
		SELECT TOP(1) @purchaseId = intPurchaseId, @purchaseDetailId = B.[intPurchaseDetailId] FROM #tmpReceivedPOMiscItems A INNER JOIN tblPOPurchaseDetail B ON A.[intPurchaseDetailId] = B.intPurchaseDetailId
		EXEC uspPOUpdateStatus @purchaseId, DEFAULT
		DELETE FROM #tmpReceivedPOMiscItems WHERE [intPurchaseDetailId] = @purchaseDetailId
	END

END