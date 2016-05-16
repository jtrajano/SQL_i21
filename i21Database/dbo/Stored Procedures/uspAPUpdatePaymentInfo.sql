CREATE PROCEDURE [dbo].[uspAPUpdatePaymentInfo]
	@strBatchId NVARCHAR(200)
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

DECLARE @totalPaymentToUpdate INT, @totalPaymentUpdated INT;
DECLARE @transCount INT = @@TRANCOUNT;
DECLARE @paymentIds TABLE(intId INT, strReferenceNo NVARCHAR(20))
--if this is greater than 1, someone already created the transaction and WE ARE COVERED BY THE TRANSACTION SO DON''T WORRY
IF @transCount = 0 BEGIN TRANSACTION

INSERT INTO @paymentIds
SELECT 
	A.intPaymentId
	,B.strReferenceNo
FROM tblAPPayment A
INNER JOIN tblCMBankTransaction B ON A.strPaymentRecordNum = B.strTransactionId
WHERE B.strLink = @strBatchId

SELECT 
	@totalPaymentToUpdate = COUNT(*)
FROM tblCMBankTransaction B
WHERE B.strLink = @strBatchId

UPDATE A
	SET A.strPaymentInfo = B.strReferenceNo
FROM tblAPPayment A
INNER JOIN @paymentIds B ON A.intPaymentId = B.intId

SET @totalPaymentUpdated = @@ROWCOUNT;

IF @totalPaymentToUpdate != @totalPaymentUpdated RAISERROR('Unexpected number of payment records updated.', 16, 1);

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
SET @ErrorMessage = @ErrorMessage + CHAR(13) + 'Please contact support.'
IF @transCount = 0 AND XACT_STATE() <> 0 ROLLBACK TRANSACTION
RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
END CATCH