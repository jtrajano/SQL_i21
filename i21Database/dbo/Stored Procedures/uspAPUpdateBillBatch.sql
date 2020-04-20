CREATE PROCEDURE [dbo].[uspAPUpdateBillBatch]
	@billId INT
AS
	
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN

	IF(EXISTS(SELECT NULL FROM tblAPBill WHERE intBillId = @billId AND intBillBatchId IS NOT NULL))
	BEGIN
		DECLARE @voucherCount INT;

		SET @voucherCount = (SELECT COUNT(*)
							FROM tblAPBill BT
							WHERE intBillBatchId = (SELECT intBillBatchId FROM tblAPBill WHERE intBillId = @billId))
		
		IF(@voucherCount > 1)
			BEGIN
				UPDATE BB
				SET BB.dblTotal = BB.dblTotal - BT.dblTotal
				FROM tblAPBillBatch BB
				INNER JOIN tblAPBill BT
					ON BT.intBillId = @billId
				WHERE BB.intBillBatchId = BT.intBillBatchId
			END

		ELSE
			BEGIN
				DELETE BB
				FROM tblAPBillBatch BB
				INNER JOIN tblAPBill BT
					ON BT.intBillId = @billId
				WHERE BB.intBillBatchId = BT.intBillBatchId
			END
	END
END
