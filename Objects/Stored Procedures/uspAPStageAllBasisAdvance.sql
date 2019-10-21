CREATE PROCEDURE [dbo].[uspAPStageAllBasisAdvance]
	@selectAll BIT = 1
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET ANSI_WARNINGS OFF

BEGIN

DECLARE @SavePoint NVARCHAR(32) = 'uspAPStageAllBasisAdvance';
DECLARE @transCount INT = @@TRANCOUNT;

BEGIN TRY

IF @transCount = 0 BEGIN TRANSACTION
ELSE SAVE TRAN @SavePoint

--CLEAR FIRST THE SELECTED, THIS IS ALSO WORKS WITH @selectAll = 0
DELETE FROM tblAPBasisAdvanceStaging
DELETE FROM tblAPBasisAdvanceFuture
DELETE FROM tblAPBasisAdvanceCommodity

IF @selectAll = 1
BEGIN
	INSERT INTO tblAPBasisAdvanceStaging(
		intBasisAdvanceDummyHeaderId,
		intTicketId,
		intContractDetailId
	)
	SELECT
		dh.intBasisAdvanceDummyHeaderId,
		ba.intTicketId,
		ba.intContractDetailId
	FROM vyuAPBasisAdvance ba
	CROSS APPLY tblAPBasisAdvanceDummyHeader dh
	WHERE ba.intAccountId > 0 --stage only those valid

	INSERT INTO tblAPBasisAdvanceCommodity(
		intBasisAdvanceDummyHeaderId,
		intCommodityId,
		strCommodity,
		dblPercentage
	)
	SELECT DISTINCT
		dh.intBasisAdvanceDummyHeaderId,
		ba.intCommodityId,
		ba.strDescription,
		0
	FROM vyuAPBasisAdvance ba
	CROSS APPLY tblAPBasisAdvanceDummyHeader dh
	WHERE ba.intAccountId > 0

	INSERT INTO tblAPBasisAdvanceFuture(
		intBasisAdvanceDummyHeaderId,
		intFutureMarketId,
		intMonthId,
		strFutures,
		strMonthYear,
		dblPrice
	)
	SELECT DISTINCT
		dh.intBasisAdvanceDummyHeaderId,
		ba.intFutureMarketId,
		ba.intFutureMonthId,
		ba.strFutMarketName,
		ba.strFutureMonth,
		0
	FROM vyuAPBasisAdvance ba
	CROSS APPLY tblAPBasisAdvanceDummyHeader dh
	WHERE ba.intAccountId > 0

END

IF @transCount = 0 COMMIT TRANSACTION;

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

	SET @ErrorMessage  = 'Error selecting basis advance.' + CHAR(13) + 
		'SQL Server Error Message is: ' + CAST(@ErrorNumber AS VARCHAR(10)) + 
		' in procedure: ' + @ErrorProc + ' Line: ' + CAST(@ErrorLine AS VARCHAR(10)) + ' Error text: ' + @ErrorMessage

	IF (XACT_STATE()) = -1
	BEGIN
		ROLLBACK TRANSACTION
	END
	ELSE IF (XACT_STATE()) = 1 AND @transCount = 0
	BEGIN
		ROLLBACK TRANSACTION
	END
	ELSE IF (XACT_STATE()) = 1 AND @transCount > 0
	BEGIN
		ROLLBACK TRANSACTION  @SavePoint
	END

	RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
END CATCH

END