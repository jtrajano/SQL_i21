﻿/*
	Use this stored procedure to update the 1099 of bills when payment post status was changed.
*/
CREATE PROCEDURE [dbo].[uspAPUpdateBill1099]
	@paymentIds NVARCHAR(MAX)
AS

BEGIN TRY
DECLARE @transCount INT = @@TRANCOUNT;
IF @transCount = 0 	BEGIN TRANSACTION

CREATE TABLE #tmpPayables (
	[intPaymentId] [int] PRIMARY KEY,
	UNIQUE (intPaymentId)
);

INSERT INTO #tmpPayables SELECT [intID] FROM [dbo].fnGetRowsFromDelimitedValues(@paymentIds)

UPDATE A
	--Retain the 1099 created from patronage
	SET A.dbl1099 = CASE WHEN patRef.intBillId IS NOT NULL THEN A.dbl1099 ELSE
						(CASE WHEN C.ysnPosted = 1 THEN A.dbl1099 + (((A.dblTotal + A.dblTax) / B.dblTotal) * ABS(C2.dblPayment))
										ELSE A.dbl1099 - (((A.dblTotal + A.dblTax) / B.dblTotal) * ABS(C2.dblPayment)) END)
							* (CASE WHEN B.dblTotal < 0 THEN -1 ELSE 1 END) --if line item is negative, the 1099 should be negative
					END
FROM tblAPBillDetail A
INNER JOIN tblAPBill B ON A.intBillId = B.intBillId
INNER JOIN (tblAPPayment C INNER JOIN tblAPPaymentDetail C2 ON C.intPaymentId = C2.intPaymentId)
ON B.intBillId = C2.intBillId
INNER JOIN #tmpPayables D ON C.intPaymentId = D.intPaymentId
LEFT JOIN tblPATRefundCustomer patRef ON patRef.intBillId = B.intBillId
WHERE A.int1099Form > 0

IF @transCount = 0 COMMIT TRANSACTION

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
	IF @transCount = 0 AND XACT_STATE() <> 0 ROLLBACK TRANSACTION
	RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
END CATCH