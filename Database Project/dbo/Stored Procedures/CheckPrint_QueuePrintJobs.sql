
CREATE PROCEDURE CheckPrint_QueuePrintJobs
	@intBankAccountID INT = NULL,
	@strTransactionID NVARCHAR(40) = NULL,
	@strBatchID NVARCHAR(20) = NULL,
	@intUserID	INT = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
--SET NOCOUNT ON // This is commented out. We need the number rows of affected by this stored procedure. 
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

-- Insert the check transaction in the check print-job spool table. 
INSERT INTO tblCMCheckPrintJobSpool(
		intBankAccountID
		,strTransactionID
		,strBatchID
		,strCheckNumber
		,dtmPrintJobCreated
		,dtmCheckPrinted
		,intCreatedUserID
)
SELECT	intBankAccountID	= F.intBankAccountID
		,strTransactionID	= F.strTransactionID
		,strBatchID			= F.strLink
		,strCheckNumber		= F.strReferenceNo
		,dtmPrintJobCreated	= GETDATE()
		,dtmCheckPrinted	= NULL
		,intCreatedUserID	= @intUserID
FROM	tblCMBankTransaction F
WHERE	F.intBankAccountID = @intBankAccountID
		AND F.strTransactionID = ISNULL(@strTransactionID, F.strTransactionID)
		AND F.strLink = ISNULL(@strBatchID, F.strLink)
		AND F.intBankTransactionTypeID IN (@MISC_CHECKS, @AP_PAYMENT)
		AND F.ysnPosted = 1
		AND F.ysnClr = 0
		AND F.dblAmount <> 0

