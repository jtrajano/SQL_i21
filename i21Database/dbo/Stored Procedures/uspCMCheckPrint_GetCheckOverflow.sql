/*  
 This stored procedure is used to check if there are overflow on checks
*/ 
CREATE PROCEDURE uspCMCheckPrint_GetCheckOverflow
	@intBankAccountId INT = NULL,
	@strTransactionIds NVARCHAR(MAX) = NULL,
	@ysnCheckOverflow INT = NULL OUTPUT 
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

--Check if there are any check overflow
SELECT TOP 1
@ysnCheckOverflow = 1		
FROM	dbo.tblCMBankTransaction CHK INNER JOIN dbo.tblCMCheckPrintJobSpool PRINTSPOOL
			ON CHK.strTransactionId = PRINTSPOOL.strTransactionId
			AND CHK.intBankAccountId = PRINTSPOOL.intBankAccountId
		LEFT JOIN tblAPPayment PYMT
			ON CHK.strTransactionId = PYMT.strPaymentRecordNum			
WHERE	CHK.intBankAccountId = @intBankAccountId
		AND CHK.strTransactionId IN (SELECT strValues COLLATE Latin1_General_CI_AS FROM dbo.fnARGetRowsFromDelimitedValues(@strTransactionIds))
		--AND PRINTSPOOL.strBatchId =  PRINTSPOOL.strBatchId
		AND (SELECT COUNT(intPaymentId) FROM tblAPPaymentDetail WHERE intPaymentId = PYMT.intPaymentId) > 10
		

SET @ysnCheckOverflow = ISNULL(@ysnCheckOverflow, 0)