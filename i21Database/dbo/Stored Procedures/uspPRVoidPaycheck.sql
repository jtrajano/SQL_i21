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
SET ANSI_WARNINGS OFF

DECLARE @isReversingSuccessful BIT = 0

/* Create Temporary Table required by uspCMBankTransactionReversal */
CREATE TABLE #tmpCMBankTransaction (
    [strTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL,
UNIQUE (strTransactionId))

/* Populate #tmpCMBankTransaction */
INSERT INTO #tmpCMBankTransaction (strTransactionId)
SELECT @strTransactionId

-- Calling the reversal stored procedure
EXEC dbo.uspCMBankTransactionReversal @intUserId, @dtmReverseDate, @isReversingSuccessful OUTPUT

--If reversal succeeds, Void the Paycheck.
IF (@isReversingSuccessful = 1)
BEGIN
	UPDATE tblPRPaycheck
	SET ysnVoid = 1
		,strReferenceNo = CASE WHEN (CHARINDEX('Voided', strReferenceNo) > 0) THEN strReferenceNo ELSE 'Voided-' + strReferenceNo END
		,dtmLastModified = GETDATE()
		,intLastModifiedUserId = @intUserId
	WHERE strPaycheckId = @strTransactionId
	AND ysnPosted = 1 AND ysnPrinted = 1 AND ysnVoid = 0

	SET @isVoidSuccessful = 1
END

-- Clean-up routines:
IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpCMBankTransaction')) DROP TABLE #tmpCMBankTransaction

GO