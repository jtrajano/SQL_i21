
CREATE PROCEDURE GetDuplicateCheckNumber
	@intBankAccountID INT = NULL,
	@strTransactionID AS NVARCHAR(40) = NULL,
	@strCheckNo AS NVARCHAR(20) = NULL
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
		
-- Clean the parameter
SET @strCheckNo = LTRIM(RTRIM(ISNULL(@strCheckNo, ''))) 		
		
SELECT	TOP 1 
		intBankAccountId
		,strTransactionId
		,strReferenceNo
FROM	tblCMBankTransaction 
WHERE	strTransactionId <> @strTransactionID
		AND intBankAccountId = @intBankAccountID
		AND intBankTransactionTypeId IN (@MISC_CHECKS, @ORIGIN_CHECKS, @AP_PAYMENT)
		AND (
			strReferenceNo = @strCheckNo 
			OR strReferenceNo = REPLICATE('0', 20 - LEN(CAST(@strCheckNo AS NVARCHAR(20)))) + CAST(@strCheckNo AS NVARCHAR(20))		
		)
		AND @strCheckNo <> ''