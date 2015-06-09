CREATE PROCEDURE [dbo].[uspICUpdatePOStatusOnReceiptSave]
	@intReceiptNo INT,
	@ysnOpenStatus BIT = 0
AS

DECLARE @POId INT

BEGIN

	IF EXISTS(SELECT * FROM tblICInventoryReceipt WHERE strReceiptType = 'Purchase Order')
	BEGIN
		SELECT DISTINCT intOrderId INTO #tmpPOList FROM tblICInventoryReceiptItem
		WHERE intInventoryReceiptId = @intReceiptNo
			AND ISNULL(intOrderId, '') <> ''

		WHILE EXISTS(SELECT TOP 1 1 FROM #tmpPOList)
		BEGIN
			SELECT TOP 1 @POId = intOrderId FROM #tmpPOList

			IF (@ysnOpenStatus = 1)
				EXEC uspPOUpdateStatus @POId, 1
			ELSE
				EXEC uspPOUpdateStatus @POId, null

			DELETE FROM #tmpPOList WHERE intOrderId = @POId
		END
		
		DROP TABLE #tmpPOList
	END

	RETURN
END