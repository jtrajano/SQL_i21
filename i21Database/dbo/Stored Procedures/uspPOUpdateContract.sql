CREATE PROCEDURE [dbo].[uspPOUpdateContract]
	@poId INT,
	@userId INT,
	@negate INT
AS

BEGIN TRY

CREATE TABLE #poContractDetails(intContractDetailId INT, intPurchaseDetailId INT, dblQtyOrdered NUMERIC(18,6));
DECLARE @transCount INT;

SET @transCount = @@TRANCOUNT
IF(@transCount = 0) BEGIN TRANSACTION

INSERT INTO #poContractDetails
SELECT intContractDetailId, intPurchaseDetailId, CASE WHEN @negate = 1 THEN dblQtyOrdered * -1 ELSE dblQtyOrdered END 
FROM tblPOPurchaseDetail WHERE intPurchaseId = @poId AND intContractDetailId IS NOT NULL

WHILE EXISTS(SELECT 1 FROM #poContractDetails)
BEGIN
	DECLARE @contractDetailId INT;
	DECLARE @purchaseDetailId INT;
	DECLARE @qty NUMERIC(18,6);
	 SELECT TOP 1 
		@contractDetailId = intContractDetailId 
		,@purchaseDetailId = intPurchaseDetailId
		,@qty = dblQtyOrdered
	FROM #poContractDetails;

	IF(@contractDetailId IS NOT NULL AND @contractDetailId > 0)
	EXEC uspCTUpdateScheduleQuantity @contractDetailId, @qty, @userId, @purchaseDetailId, 'Purchase Order'

	DELETE FROM #poContractDetails WHERE intPurchaseDetailId = @purchaseDetailId
END

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
    SET @ErrorProc     = ERROR_PROCEDURE()
    SET @ErrorMessage  = 'Problem updating contract quantity.' + CHAR(13) + 
			'SQL Server Error Message is: ' + CAST(@ErrorNumber AS VARCHAR(10)) + 
			' in procedure: ' + @ErrorProc + ' Line: ' + CAST(@ErrorLine AS VARCHAR(10)) + ' Error text: ' + @ErrorMessage
    -- Not all errors generate an error state, to set to 1 if it's zero
    IF @ErrorState  = 0
    SET @ErrorState = 1
    -- If the error renders the transaction as uncommittable or we have open transactions, we may want to rollback
    IF @transCount = 0 AND XACT_STATE() <> 0
    BEGIN
		ROLLBACK TRANSACTION
    END
	RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
END CATCH