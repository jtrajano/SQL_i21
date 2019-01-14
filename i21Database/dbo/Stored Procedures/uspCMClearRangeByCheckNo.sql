﻿CREATE PROCEDURE uspCMClearRangeByCheckNo
	@intBankAccountId INT = NULL,
	@strSide AS NVARCHAR(10) = null, 
	@strCheckNoFrom AS NVARCHAR(50) = NULL,
	@strCheckNoTo AS NVARCHAR(50) = NULL
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
		,@ACH AS INT = 22
		,@DIRECT_DEPOSIT AS INT = 23
		,@NSF INT = 25
		

-- Bulk update the ysnClr
UPDATE	tblCMBankTransaction 
SET		ysnClr = 1
		,intConcurrencyId = intConcurrencyId + 1
WHERE	ysnPosted = 1
		AND ysnClr = 0
		AND dtmDateReconciled IS NULL
		AND intBankAccountId = @intBankAccountId
		AND strReferenceNo BETWEEN @strCheckNoFrom AND @strCheckNoTo
		AND 1 = 
			CASE	WHEN	@strSide = 'DEBIT' 
							AND (
								intBankTransactionTypeId IN (@BANK_WITHDRAWAL,@NSF,@MISC_CHECKS, @BANK_TRANSFER_WD, @ORIGIN_CHECKS, @ORIGIN_EFT, @ORIGIN_WITHDRAWAL, @ORIGIN_WIRE, @AP_PAYMENT, @AP_ECHECK, @PAYCHECK, @ACH, @DIRECT_DEPOSIT)
								OR ( dblAmount < 0 AND intBankTransactionTypeId = @BANK_TRANSACTION )
							) THEN 1 					
					WHEN	@strSide = 'CREDIT' 
							AND (
								intBankTransactionTypeId IN (@BANK_DEPOSIT, @BANK_TRANSFER_DEP, @ORIGIN_DEPOSIT)
								OR ( dblAmount > 0 AND intBankTransactionTypeId = @BANK_TRANSACTION )
							)
							AND dbo.fnIsDepositEntry(strLink) = 0 
					THEN 1
					WHEN @strSide = 'BOTH' THEN 1
					ELSE
					0 -- ALL
			END
		AND 1 = (
					-- If check transaction is not yet printed, do not include record in the update.
			CASE	WHEN intBankTransactionTypeId IN (@MISC_CHECKS, @ORIGIN_CHECKS, @AP_PAYMENT, @PAYCHECK, @ACH, @DIRECT_DEPOSIT) AND dtmCheckPrinted IS NULL THEN 0
					-- If record is a non-check, no need to check the date printed. 
					ELSE 1
			END 		
		)
		AND strReferenceNo <> ''