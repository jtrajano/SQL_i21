CREATE PROCEDURE uspCMABRCheckClearing
    @intBankAccountId INT,
    @intEntityId INT
AS
DECLARE @dtmCurrent DATETIME = GETDATE()
DECLARE @intABRDaysNoRef INT

IF OBJECT_ID('tempdb..##tempActivityMatched') IS NOT NULL
			DROP TABLE ##tempActivityMatched

CREATE TABLE ##tempActivityMatched
(
	intABRActivityId INT NULL,
	intTransactionId INT NULL
)

SELECT @intABRDaysNoRef=ISNULL(intABRDaysNoRef,0)
FROM tblCMBankAccount WHERE @intBankAccountId = intBankAccountId

;WITH matching as(
    SELECT intABRActivityId, intTransactionId, intBankAccountId
    FROM tblCMABRActivity ABR 
OUTER APPLY(
	SELECT 
	TOP 1
	intTransactionId
	FROM tblCMBankTransaction 
	WHERE intBankAccountId = ISNULL (ABR.intBankAccountId, @intBankAccountId)
	AND ysnPosted = 1
	AND ysnCheckVoid = 0
    AND ysnClr = 0
	AND RTRIM(LTRIM(strReferenceNo)) = 
		CASE WHEN ABR.strReferenceNo = '' 
			AND @dtmCurrent<= DATEADD(DAY,@intABRDaysNoRef, dtmDate)
			THEN RTRIM(LTRIM(strReferenceNo))
		ELSE
			ABR.strReferenceNo
		END
	AND ABS(dblAmount) = ABS(ABR.dblAmount)
	AND ABR.strDebitCredit  = 'C'
    AND intBankTransactionTypeId in  (SELECT intBankTransactionTypeId FROM tblCMBankTransactionType WHERE strDebitCredit IN('C','DC'))
	AND dblAmount > 0
	ORDER BY dtmDate
)CM
UNION ALL
SELECT intABRActivityId, intTransactionId, intBankAccountId
FROM tblCMABRActivity ABR
OUTER APPLY(
	SELECT 
	TOP 1
	intTransactionId
	FROM tblCMBankTransaction 
	WHERE intBankAccountId = ISNULL (ABR.intBankAccountId, @intBankAccountId)
	AND ysnPosted = 1
	AND ysnCheckVoid = 0
    AND ysnClr = 0
	AND RTRIM(LTRIM(strReferenceNo)) = 
		CASE WHEN ABR.strReferenceNo = '' 
			AND @dtmCurrent<= dateadd(DAY,@intABRDaysNoRef, dtmDate)
			THEN RTRIM(LTRIM(strReferenceNo))
		ELSE
			ABR.strReferenceNo
		END
	AND ABS(dblAmount) = ABS(ABR.dblAmount)
	AND ABR.strDebitCredit  = 'D'
    AND intBankTransactionTypeId in  (SELECT intBankTransactionTypeId FROM tblCMBankTransactionType WHERE strDebitCredit  IN('C','DC'))
	AND dblAmount < 0
	ORDER BY dtmDate
)CM
)
INSERT INTO ##tempActivityMatched (intABRActivityId, intTransactionId)
SELECT  intABRActivityId, intTransactionId FROM matching WHERE intTransactionId IS NOT NULL

UPDATE CM
SET ysnClr = 1
FROM
tblCMBankTransaction CM JOIN
##tempActivityMatched T ON
T.intTransactionId = CM.intTransactionId

UPDATE ABR
SET intImportStatus = 1
FROM
tblCMABRActivity ABR JOIN
##tempActivityMatched T ON
T.intABRActivityId = ABR.intABRActivityId

DECLARE @bankMatchingId NVARCHAR(20)
EXEC uspSMGetStartingNumber 162,  @bankMatchingId OUT

INSERT INTO tblCMABRActivityMatched( strActivityMatched, dtmDateEntered, intEntityId)
SELECT @bankMatchingId, @dtmCurrent, @intEntityId

INSERT INTO tblCMABRActivityMatchedDetail(intABRActivityMatchedId, intABRActivityId, intTransactionId)
SELECT SCOPE_IDENTITY(), intABRActivityId, intTransactionId FROM ##tempActivityMatched



