CREATE PROCEDURE [dbo].[uspPATDeleteVoucherForPaidEquity]
	@equityPaymentIds NVARCHAR(MAX) = NULL,
	@error NVARCHAR(MAX) = NULL OUTPUT,
	@success BIT = 0 OUTPUT
AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRANSACTION
	CREATE TABLE #tempValidateTable (
		[strError] [NVARCHAR](MAX),
		[strTransactionType] [NVARCHAR](50),
		[strTransactionNo] [NVARCHAR](50),
		[intTransactionId] INT
	);

	CREATE TABLE #tempEquityPayment(
		[intId] INT PRIMARY KEY,
		UNIQUE([intId])
	);

	INSERT INTO #tempValidateTable
	SELECT * FROM fnPATValidateAssociatedTransaction(@equityPaymentIds, 3)

	SELECT * FROM #tempValidateTable
	IF EXISTS(SELECT 1 FROM #tempValidateTable)
	BEGIN
		SET @error = 'Selected vouchers are already paid.';
		RAISERROR(@error, 16, 1);
		GOTO Post_Rollback;
	END

	INSERT INTO #tempEquityPayment SELECT [intID] AS intTransactionId FROM [dbo].fnGetRowsFromDelimitedValues(@equityPaymentIds)

	DELETE FROM tblAPBill WHERE intBillId IN (SELECT intBillId FROM tblPATEquityPaySummary WHERE intEquityPaySummaryId IN (SELECT intId from #tempEquityPayment));
	UPDATE tblPATEquityPaySummary SET intBillId = NULL WHERE intEquityPaySummaryId IN (SELECT intId from #tempEquityPayment);

IF @@ERROR <> 0	GOTO Post_Rollback;

GOTO Post_Commit;

Post_Commit:
	COMMIT TRANSACTION
	SET @success = 1
	
	GOTO Post_Exit

Post_Rollback:
	ROLLBACK TRANSACTION	
	SET @success = 0
	GOTO Post_Exit

Post_Exit:
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tempValidateTable')) DROP TABLE #tempValidateTable
END