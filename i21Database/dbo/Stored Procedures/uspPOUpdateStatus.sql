CREATE PROCEDURE [dbo].[uspPOUpdateStatus]
    @poId INT,
	@status INT = NULL
AS
BEGIN

	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	CREATE TABLE #tmpPO(intPurchaseId INT)

	IF @status IS NOT NULL
	BEGIN
		UPDATE A
			SET A.intOrderStatusId = @status
		FROM tblPOPurchase A
		WHERE A.intPurchaseId = @poId
	END
	ELSE
	BEGIN
		IF @poId > 0
		BEGIN
			INSERT INTO #tmpPO
			SELECT 
				A.intPurchaseId 
			FROM tblPOPurchase A
			WHERE intPurchaseId = @poId
		END
		ELSE
		BEGIN
			INSERT INTO #tmpPO
			SELECT 
				A.intPurchaseId 
			FROM tblPOPurchase A
		END

		UPDATE B
			SET B.intOrderStatusId = (CASE	WHEN 
											--PO is closed when all the dblQtyReceived is greater than or equal to dblQtyOrdered
											NOT EXISTS(SELECT 1 FROM 
															(
																SELECT 
																	CASE WHEN dblQtyReceived >= dblQtyOrdered THEN 1 ELSE 0 END AS ysnFull
																 FROM tblPOPurchaseDetail WHERE intPurchaseId = A.intPurchaseId
															) PODetails WHERE ysnFull = 0
														)
											THEN 3 --Closed
										WHEN dbo.fnPOHasItemReceipt(A.intPurchaseId, NULL) = 0 AND dbo.fnPOHasBill(A.intPurchaseId, NULL) = 0
											THEN 1 --Open
										WHEN (dbo.fnPOHasItemReceipt(A.intPurchaseId, 0) = 1 AND dbo.fnPOHasItemReceipt(A.intPurchaseId, 1) = 0 AND dbo.fnPOHasBill(A.intPurchaseId,null) = 0) OR 
												(dbo.fnPOHasBill(A.intPurchaseId, 0) = 1 AND dbo.fnPOHasBill(A.intPurchaseId, 1) = 0 AND dbo.fnPOHasItemReceipt(A.intPurchaseId, null) = 0)
											THEN 7 --Pending
										WHEN dbo.fnPOHasItemReceipt(A.intPurchaseId, 1) = 1 OR dbo.fnPOHasBill(A.intPurchaseId, 1) = 1
											THEN 2 --Partial
										ELSE NULL
								END)
		FROM #tmpPO A
			INNER JOIN tblPOPurchase B
				ON A.intPurchaseId = B.intPurchaseId
	END
	
END
