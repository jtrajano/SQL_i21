CREATE PROCEDURE [dbo].[uspAPApplyPrepaid]
	@billId INT,
	@prepaidIds Id READONLY
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

DECLARE @voucherId INT = @billId;
DECLARE @voucherIds AS Id;
DECLARE @SaveTran NVARCHAR(32) = 'uspAPApplyPrepaid';
DECLARE @transCount INT = @@TRANCOUNT;
DECLARE @prepaidCount INT; 
DECLARE @count INT = 0; 
IF @transCount = 0 
	BEGIN TRANSACTION
ELSE 
	SAVE TRANSACTION @SaveTran

SELECT @prepaidCount = COUNT(@prepaidCount)
WHILE @prepaidCount !=  @count
BEGIN
EXEC uspAPPrepaidAndDebit @billId = @voucherId;

UPDATE A
	SET A.ysnApplied = 1
	,A.dblAmountApplied = A.dblBalance
    ,A.dblBalance = 0
FROM tblAPAppliedPrepaidAndDebit A
INNER JOIN tblAPBill B ON A.intTransactionId = B.intBillId
WHERE A.intTransactionId IN (SELECT intId FROM @prepaidIds) AND A.intBillId = @voucherId

INSERT INTO @voucherIds
SELECT @voucherId

EXEC uspAPUpdateVoucherTotal @voucherIds
SET @count = @count + 1

END
IF @transCount = 0 
	COMMIT TRANSACTION
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
    SET @ErrorProc     = ERROR_PROCEDURE()
    SET @ErrorMessage  = 'Problem applying prepaid.' + CHAR(13) + 
			'SQL Server Error Message is: ' + CAST(@ErrorNumber AS VARCHAR(10)) + 
			' in procedure: ' + @ErrorProc + ' Line: ' + CAST(@ErrorLine AS VARCHAR(10)) + ' Error text: ' + @ErrorMessage
    -- Not all errors generate an error state, to set to 1 if it's zero
    IF @ErrorState  = 0
    SET @ErrorState = 1
    -- If the error renders the transaction as uncommittable or we have open transactions, we may want to rollback
    IF @transCount = 0 AND XACT_STATE() <> 0 ROLLBACK TRANSACTION
	IF @transCount = 0
		IF (XACT_STATE()) <> 0
			ROLLBACK TRANSACTION
	ELSE
		IF (XACT_STATE()) <> 0
			ROLLBACK TRANSACTION @SaveTran
    RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
END CATCH
