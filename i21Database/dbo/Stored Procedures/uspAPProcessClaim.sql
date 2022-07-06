CREATE PROCEDURE [dbo].[uspAPProcessClaim]
	@billId INT = 0,
	@process BIT = 0,
	@userId INT = 0
AS

BEGIN TRY
	DECLARE @transCount INT = @@TRANCOUNT;
	IF @transCount = 0 BEGIN TRANSACTION

	DECLARE @billIds AS Id
	INSERT INTO @billIds VALUES(@billId) 

	IF OBJECT_ID(N'tempdb..#tmpPostVoucherIntegrationError') IS NOT NULL DROP TABLE #tmpPostVoucherIntegrationError
	CREATE TABLE #tmpPostVoucherIntegrationError(intBillId INT, strBillId NVARCHAR(50), strError NVARCHAR(200));
	
	EXEC uspAPCallPostVoucherIntegration @billIds = @billIds, @post = @process, @intUserId = @userId

	DECLARE @strErrorCount INT = 0
	SELECT @strErrorCount = COUNT(*) FROM #tmpPostVoucherIntegrationError
	IF @strErrorCount != 0
	BEGIN
		DECLARE @strError NVARCHAR(100) = ''
		SELECT TOP 1 @strError = strError FROM #tmpPostVoucherIntegrationError
		RAISERROR(@strError, 16, 1);
	END

	UPDATE B
	SET ysnProcessedClaim = @process
	FROM tblAPBill B
	WHERE B.intBillId = @billId

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