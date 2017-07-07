CREATE PROCEDURE uspPRVoidPaycheck
	@strTransactionId NVARCHAR(100),
	@dtmReverseDate DATETIME,
	@intUserId INT,
	@isVoidSuccessful BIT = 0 OUTPUT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

DECLARE @isReversingSuccessful BIT = 0
	,@ysnTransactionVoided AS BIT

SELECT @ysnTransactionVoided = ysnVoid 
FROM tblPRPaycheck 
WHERE strPaycheckId = @strTransactionId

IF (@ysnTransactionVoided = 1)
BEGIN
	RAISERROR('Transaction is already voided.', 11, 1)
	GOTO Void_Exit
END

/* Create Temporary Table required by uspCMBankTransactionReversal */
CREATE TABLE #tmpCMBankTransaction (
    [strTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL,
UNIQUE (strTransactionId))

/* Populate #tmpCMBankTransaction */
INSERT INTO #tmpCMBankTransaction (strTransactionId)
SELECT @strTransactionId

-- Insert Void Paycheck to Check Audit
INSERT INTO tblCMCheckNumberAudit (
		intBankAccountId
		,strCheckNo
		,intCheckNoStatus
		,strRemarks
		,strTransactionId
		,intTransactionId
		,intUserId
		,dtmCreated
		,dtmCheckPrinted
)
SELECT	intBankAccountId = F.intBankAccountId
		,strCheckNo = F.strReferenceNo
		,intCheckNoStatus = 4
		,strRemarks = ''
		,strTransactionId = F.strTransactionId
		,intTransactionId = F.intTransactionId
		,intUserId = @intUserId
		,dtmCreated = GETDATE()
		,dtmCheckPrinted = NULL 
FROM	tblCMBankTransaction F INNER JOIN #tmpCMBankTransaction TMP
			ON F.strTransactionId = TMP.strTransactionId
WHERE	NOT EXISTS (
			SELECT	TOP 1 1
			FROM	tblCMCheckNumberAudit AUDIT
			WHERE	AUDIT.intBankAccountId = F.intBankAccountId
					AND AUDIT.strCheckNo = F.strReferenceNo
					AND AUDIT.intTransactionId = F.intTransactionId
					AND AUDIT.intCheckNoStatus = 4
		)
		AND F.strReferenceNo NOT IN ('Cash')	
		AND F.intBankTransactionTypeId = 21	
		AND ISNULL(F.strReferenceNo, '') <> ''
		AND F.dtmCheckPrinted IS NOT NULL

-- Calling the reversal stored procedure
EXEC dbo.uspCMBankTransactionReversal @intUserId, @dtmReverseDate, @isReversingSuccessful OUTPUT

--If reversal succeeds, Void the Paycheck.
IF (@isReversingSuccessful = 1)
BEGIN

	--Check if Paycheck has Payables created, if so, create Debit Memos for those
	DECLARE @intPaycheckId INT
	DECLARE @intPaycheckIds NVARCHAR(MAX)
	SELECT TOP 1 @intPaycheckId = intPaycheckId FROM tblPRPaycheck WHERE strPaycheckId = @strTransactionId

	IF (EXISTS(SELECT TOP 1 1 FROM tblPRPaycheckTax WHERE intPaycheckId = @intPaycheckId AND intBillId IS NOT NULL)
		OR EXISTS(SELECT TOP 1 1 FROM tblPRPaycheckDeduction WHERE intPaycheckId = @intPaycheckId AND intBillId IS NOT NULL))
	BEGIN
		SELECT @intPaycheckIds = CAST(@intPaycheckId AS NVARCHAR(MAX)) FROM tblPRPaycheck WHERE intPaycheckId = @intPaycheckId
		SET @strTransactionId = @strTransactionId + 'V'
		EXEC uspPRCreatePaycheckPayable @intPaycheckIds, @strTransactionId, @intUserId, 1
	END

	UPDATE tblPRPaycheck
	SET ysnVoid = 1
		,ysnPrinted = CASE WHEN (ysnDirectDeposit = 1) THEN 0 ELSE ysnPrinted END
		,strReferenceNo = CASE WHEN (CHARINDEX('Voided', strReferenceNo) > 0) THEN strReferenceNo ELSE 'Voided-' + strReferenceNo END
		,dtmLastModified = GETDATE()
		,intLastModifiedUserId = @intUserId
	WHERE strPaycheckId = @strTransactionId
	AND ysnPosted = 1 AND ysnPrinted = 1 AND ysnVoid = 0

	SET @isVoidSuccessful = 1

	EXEC uspSMAuditLog 'Payroll.view.Paycheck', @intPaycheckId, @intUserId, 'Voided', '', '', ''
END

-- Clean-up routines:
Void_Exit:
IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpCMBankTransaction')) DROP TABLE #tmpCMBankTransaction

GO