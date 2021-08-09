
CREATE PROCEDURE uspCMABRCheckClearing
    @intBankAccountId INT,
    @intEntityId INT
AS
DECLARE @dtmCurrent DATETIME =  CAST(FLOOR(CAST(GETDATE() AS float)) AS DATETIME)
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
	FROM tblCMBankTransaction C
	JOIN tblCMBankTransactionType T 
	ON C.intBankTransactionTypeId=T.intBankTransactionTypeId
	WHERE intBankAccountId = ISNULL (ABR.intBankAccountId, @intBankAccountId)
	AND ysnPosted = 1
	AND ysnCheckVoid = 0
    AND ysnClr = 0
	AND RTRIM(LTRIM(ISNULL(strReferenceNo,''))) = 
		CASE WHEN LTRIM(RTRIM(ISNULL(ABR.strReferenceNo,''))) = '' AND @intABRDaysNoRef > 0
			AND @dtmCurrent<= dateadd(DAY,@intABRDaysNoRef, dtmDate)
			THEN RTRIM(LTRIM(ISNULL(strReferenceNo,'')))
		ELSE
			LTRIM(RTRIM(ISNULL(ABR.strReferenceNo,''))) 
		END
	AND ABS(dblAmount) = ABS(ABR.dblAmount)
	AND ABR.strDebitCredit =
	CASE WHEN C.intBankTransactionTypeId = 5 THEN
		CASE WHEN  dblAmount > 0 THEN 'C' ELSE 'D' END
	ELSE
		T.strDebitCredit
	END
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

INSERT INTO tblCMABRActivityMatched(intABRActivityId, intTransactionId, dtmDateEntered, intEntityId, intConcurrencyId)
SELECT intABRActivityId, intTransactionId,@dtmCurrent, @intEntityId,1 FROM ##tempActivityMatched
