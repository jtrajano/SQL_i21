﻿CREATE PROCEDURE [dbo].[uspPATCreateVoucherForDividends]
	@intDividendId INT,
	@intUserId INT,
	@ysnPosted BIT,
	@dividendsCustomer NVARCHAR(MAX),
	@intAPClearingId INT = 0,
	@successfulCount INT = 0 OUTPUT,
	@strErrorMessage NVARCHAR(MAX) = NULL OUTPUT,
	@invalidCount INT = 0 OUTPUT,
	@success BIT = 0 OUTPUT 

AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRANSACTION

	SELECT	D.intDividendId,
			D.strDividendNo,
			DC.intDividendCustomerId,
			DC.intCustomerId,
			DC.dblDividendAmount,
			DC.dblLessFWT,
			DC.dblCheckAmount
		INTO #tempDivCust 
		FROM tblPATDividends D
	INNER JOIN tblPATDividendsCustomer DC
		ON DC.intDividendId = D.intDividendId
	WHERE DC.intDividendCustomerId IN (SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@dividendsCustomer)) AND DC.dblDividendAmount <> 0

	DECLARE @voucherDetailNonInventory AS VoucherDetailNonInventory;
	DECLARE @dtmDate DATETIME = GETDATE();
	DECLARE @intDivCustId INT;
	DECLARE @intPatronageItemId INT;
	DECLARE @intCustomerId INT;
	DECLARE @dblDividentAmt NUMERIC(18,6);
	DECLARE @strVenderOrderNumber NVARCHAR(MAX);
	DECLARE @intCreatedBillId INT;
	DECLARE @dividendCustomerIds AS Id;
	DECLARE @totalRecords AS INT = 0;

	INSERT INTO @dividendCustomerIds
	SELECT intDividendCustomerId FROM #tempDivCust

	SELECT * from @dividendCustomerIds
BEGIN TRY

	WHILE EXISTS(SELECT 1 FROM @dividendCustomerIds)
	BEGIN
		
		SELECT TOP 1 
			@intDivCustId = T.intDividendCustomerId,
			@intCustomerId = T.intCustomerId, 
			@dblDividentAmt = T.dblDividendAmount,
			@strVenderOrderNumber = '' + T.strDividendNo + '' + CONVERT(NVARCHAR(MAX),T.intDividendCustomerId)
			FROM @dividendCustomerIds Div INNER JOIN #tempDivCust T ON T.intDividendCustomerId = Div.intId

		INSERT INTO @voucherDetailNonInventory([intAccountId],[intItemId],[strMiscDescription],[dblQtyReceived],[dblDiscount],[dblCost],[intTaxGroupId])
			VALUES(@intAPClearingId,NULL,'Patronage Dividend Voucher (Tax Inclusive)', 1, 0, @dblDividentAmt, NULL)
			
		EXEC [dbo].[uspAPCreateBillData]
			@userId	= @intUserId
			,@vendorId = @intCustomerId
			,@type = 1	
			,@voucherNonInvDetails = @voucherDetailNonInventory
			,@shipTo = NULL
			,@vendorOrderNumber = @strVenderOrderNumber
			,@voucherDate = @dtmDate
			,@billId = @intCreatedBillId OUTPUT

		UPDATE tblAPBillDetail SET int1099Form = 5, int1099Category= 0 WHERE intBillId = @intCreatedBillId

		DELETE FROM @dividendCustomerIds WHERE intId = @intDivCustId;
		DELETE FROM @voucherDetailNonInventory;

		SET @totalRecords = @totalRecords + 1;
	END

	UPDATE tblPATDividends SET ysnVoucherProcessed = 1 WHERE intDividendId = @intDividendId
		
	
IF @@ERROR <> 0	GOTO Post_Rollback;

END TRY

BEGIN CATCH
	DECLARE @intErrorSeverity INT,
			@intErrorNumber   INT,
			@intErrorState INT;
		
	SET @intErrorSeverity = ERROR_SEVERITY()
	SET @intErrorNumber   = ERROR_NUMBER()
	SET @strErrorMessage  = ERROR_MESSAGE()
	SET @intErrorState    = ERROR_STATE()
	RAISERROR (@strErrorMessage , @intErrorSeverity, @intErrorState, @intErrorNumber)
	GOTO Post_RollBack
END CATCH

Post_Commit:
	COMMIT TRANSACTION
	SET @success = 1
	SET @successfulCount = @totalRecords
	GOTO Post_Exit

Post_Rollback:
	ROLLBACK TRANSACTION	
	SET @success = 0
	GOTO Post_Exit
Post_Exit:
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tempDivCust')) DROP TABLE #tempDivCust
GO