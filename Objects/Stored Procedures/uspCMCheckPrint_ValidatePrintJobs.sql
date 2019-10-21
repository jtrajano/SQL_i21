﻿
CREATE PROCEDURE uspCMCheckPrint_ValidatePrintJobs
	@intBankAccountId INT = NULL,
	@intUserId INT = NULL,
	@ysnPrintJobExists INT = NULL OUTPUT,
	@intBankTransactionTypeId INT = NULL OUTPUT  
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @BANK_DEPOSIT INT = 1
		,@BANK_WITHDRAWAL INT = 2
		,@MISC_CHECKS INT = 3
		,@BANK_TRANSFER INT = 4
		,@BANK_TRANSACTION INT = 5
		,@CREDIT_CARD_CHARGE INT = 6
		,@CREDIT_CARD_RETURNS INT = 7
		,@CREDIT_CARD_PAYMENTS INT = 8
		,@BANK_TRANSFER_WD INT = 9
		,@BANK_TRANSFER_DEP INT = 10
		,@ORIGIN_DEPOSIT AS INT = 11
		,@ORIGIN_CHECKS AS INT = 12
		,@ORIGIN_EFT AS INT = 13
		,@ORIGIN_WITHDRAWAL AS INT = 14
		,@ORIGIN_WIRE AS INT = 15
		,@AP_PAYMENT AS INT = 16
		,@BANK_STMT_IMPORT AS INT = 17
		,@AR_PAYMENT AS INT = 18
		,@VOID_CHECK AS INT = 19
		,@AP_ECHECK AS INT = 20
		,@PAYCHECK AS INT = 21

-- Check if there are any print jobs for the specified bank account. 
SELECT	TOP 1 
		@ysnPrintJobExists = 1,
		@intBankTransactionTypeId = intBankTransactionTypeId
FROM	[dbo].[tblCMCheckPrintJobSpool]
WHERE	intBankAccountId = @intBankAccountId
		AND intCreatedUserId = @intUserId

SET @ysnPrintJobExists = ISNULL(@ysnPrintJobExists, 0)
SET @intBankTransactionTypeId = ISNULL(@intBankTransactionTypeId, 0)