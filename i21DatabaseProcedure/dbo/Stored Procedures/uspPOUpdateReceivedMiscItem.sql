CREATE PROCEDURE [dbo].[uspPOUpdateReceivedMiscItem]
	@billId INT,
	@ysnDeleted INT
AS
BEGIN

	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	--UPDATE PO Status for misc/othercharge
		IF EXISTS(SELECT 1 FROM tblAPBillDetail A 
		LEFT JOIN tblICItem B 
					ON A.intItemId = B.intItemId 
		LEFT JOIN tblPOPurchaseDetail C
					ON C.intPurchaseDetailId = A.intPurchaseDetailId
					WHERE 
					(B.strType IN ('Service','Software','Non-Inventory','Other Charge') OR C.intItemId IS NULL)
					AND A.intBillId IN (@billId)
					AND A.[intPurchaseDetailId] > 0)
		BEGIN
			DECLARE @countReceivedMisc INT = 0, @billIdReceived INT;
			BEGIN
				EXEC [uspPOReceivedMiscItem] @billId
			END
			IF @ysnDeleted = 1
			BEGIN 
				EXEC [uspPOReverseReceivedMiscItem] @billId
			END            
		END

END