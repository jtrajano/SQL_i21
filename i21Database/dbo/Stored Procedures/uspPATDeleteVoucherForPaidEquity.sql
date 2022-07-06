CREATE PROCEDURE [dbo].[uspPATDeleteVoucherForPaidEquity]
	@equityPaymentIds	NVARCHAR(MAX) = NULL,
	@intUserId			INT = NULL,
	@error				NVARCHAR(MAX) = NULL OUTPUT,
	@success			BIT = 0 OUTPUT
AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRANSACTION
	CREATE TABLE #tempValidateTable (
		[strError]				NVARCHAR(MAX),
		[strTransactionType]	NVARCHAR(50),
		[strTransactionNo]		NVARCHAR(50),
		[intTransactionId]		INT
	);

	CREATE TABLE #tempEquityPayment(
		[intEquityPaySummaryId]		INT PRIMARY KEY,
		[intBillId]					INT NULL,
		[intEquityPayId]			INT,		
		[strPaymentNumber]			NVARCHAR(50),
		UNIQUE([intEquityPaySummaryId])
	);

	DECLARE @MODULE_NAME NVARCHAR(25) = 'Patronage';
	DECLARE @PAID_EQUITY NVARCHAR(25) = 'Paid Equity';

	INSERT INTO #tempValidateTable
	SELECT * FROM fnPATValidateAssociatedTransaction(@equityPaymentIds, 3, @MODULE_NAME)
	
	IF EXISTS(SELECT 1 FROM #tempValidateTable)
	BEGIN
		SET @error = 'Selected vouchers are already paid.';
		RAISERROR(@error, 16, 1);
		GOTO Post_Rollback;
	END

	INSERT INTO #tempEquityPayment 
	SELECT intId			= intEquityPaySummaryId
		 , intBillId		= EPS.intBillId
		 , intEquityPayId	= EP.intEquityPayId
	     , strPaymentNumber	= EP.strPaymentNumber
	FROM dbo.fnGetRowsFromDelimitedValues(@equityPaymentIds) DV
	INNER JOIN tblPATEquityPaySummary EPS ON DV.intID = EPS.intEquityPaySummaryId
	INNER JOIN tblPATEquityPay EP ON EP.intEquityPayId = EPS.intEquityPayId

	UPDATE EPS 
	SET intBillId = NULL 
	FROM tblPATEquityPaySummary EPS
	INNER JOIN #tempEquityPayment EP ON EPS.intEquityPaySummaryId = EP.intEquityPaySummaryId

	SELECT * FROM #tempEquityPayment
	BEGIN TRY	
		SET ANSI_WARNINGS ON;

		DECLARE @voucherId AS NVARCHAR(MAX);
		
		SELECT @voucherId = STUFF((SELECT ',' + CONVERT(NVARCHAR(MAX), EP.intBillId) 
		FROM tblPATEquityPaySummary EPS
		INNER JOIN #tempEquityPayment EP ON EPS.intEquityPaySummaryId = EP.intEquityPaySummaryId
		FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)'),1,1,'')
		
		SET ANSI_WARNINGS OFF;

		EXEC [dbo].[uspAPPostBill] @batchId = NULL
								 , @billBatchId = NULL
								 , @transactionType = NULL
								 , @post = 0
								 , @recap = 0
								 , @isBatch = 0
								 , @param = @voucherId
								 , @userId = @intUserId
								 , @beginTransaction = NULL
								 , @endTransaction = NULL
								 , @success = @success OUTPUT

								 SELECT @success
	END TRY
	BEGIN CATCH
		SET @error = ERROR_MESSAGE();
		RAISERROR(@error, 16, 1);
		GOTO Post_Rollback;
	END CATCH

	WHILE EXISTS (SELECT TOP 1 NULL FROM #tempEquityPayment)
		BEGIN
			DECLARE @intEquityPayId		INT = NULL
				  , @intBilldId			INT = NULL
				  , @strPaymentNumber	NVARCHAR(100) = NULL
				  , @strVoucherNumber	NVARCHAR(100) = NULL

			SELECT TOP 1 @intEquityPayId	= EP.intEquityPayId
					   , @intBilldId		= EP.intBillId
					   , @strPaymentNumber	= EP.strPaymentNumber
					   , @strVoucherNumber	= BILL.strBillId
			FROM #tempEquityPayment EP
			INNER JOIN tblAPBill BILL ON EP.intBillId = BILL.intBillId

			DELETE TN
			FROM tblICTransactionNodes TN
			INNER JOIN (
				SELECT guiTransactionGraphId
					 , intDestId
				FROM tblICTransactionLinks
				WHERE intSrcId = @intEquityPayId
				  AND strSrcTransactionNo = @strPaymentNumber
				  AND strSrcTransactionType = @PAID_EQUITY
				  AND strSrcModuleName = @MODULE_NAME
				  AND intDestId = @intBilldId
				  AND strDestTransactionNo = @strVoucherNumber
			) TL ON TN.guiTransactionGraphId = TL.guiTransactionGraphId AND TL.intDestId = TN.intTransactionId
			WHERE TN.intTransactionId = @intBilldId 
			  AND TN.strTransactionNo = @strVoucherNumber
			  AND TN.strTransactionType = 'Voucher'
			  AND TN.strModuleName = 'Purchasing'

			DELETE tblICTransactionLinks 
			FROM tblICTransactionLinks
			WHERE intSrcId = @intEquityPayId
			  AND strSrcTransactionNo = @strPaymentNumber
			  AND strSrcTransactionType = @PAID_EQUITY
			  AND strSrcModuleName = @MODULE_NAME
			  AND intDestId = @intBilldId
			  AND strDestTransactionNo = @strVoucherNumber			

			DELETE FROM #tempEquityPayment 
			WHERE intEquityPayId = @intEquityPayId 
			  AND intBillId = @intBilldId
		END

	DELETE BILL
	FROM tblAPBill BILL	
	INNER JOIN #tempEquityPayment EP ON BILL.intBillId = EP.intBillId

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