CREATE PROCEDURE [dbo].[uspAPUpdateBillBatch]
	@billBatchId INT
AS
	
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN

	IF(@billBatchId IS NOT NULL)
	BEGIN
		UPDATE BB
		SET
			BB.dblTotal = BT.dblTotal

		FROM tblAPBillBatch BB
		OUTER APPLY (SELECT ISNULL(SUM(dblTotal), 0) dblTotal FROM tblAPBill WHERE intBillBatchId = @billBatchId) BT
		WHERE BB.intBillBatchId = @billBatchId
	END
END
