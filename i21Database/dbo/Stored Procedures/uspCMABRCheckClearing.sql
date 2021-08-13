
CREATE PROCEDURE uspCMABRCheckClearing
    @intBankAccountId INT,
	@intImportBankStatementLogId INT,
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

SELECT intABRActivityId, CM.intTransactionId, ABR.intBankAccountId
FROM tblCMABRActivity ABR 

CROSS APPLY(
	SELECT 
	TOP 1
	C.intTransactionId
	FROM tblCMBankTransaction C
	JOIN tblCMBankTransactionType T 
	ON C.intBankTransactionTypeId=T.intBankTransactionTypeId
	WHERE intBankAccountId = ISNULL (ABR.intBankAccountId, @intBankAccountId)
	AND ysnPosted = 1
	AND ysnCheckVoid = 0
    AND ysnClr = 0
	AND 1 = 
	CASE WHEN  RTRIM(LTRIM(ISNULL(C.strReferenceNo,''))) = '' AND LTRIM(RTRIM(ISNULL(ABR.strReferenceNo,''))) = '' 
	THEN 
		IIF(@dtmCurrent<= DATEADD(DAY,@intABRDaysNoRef, C.dtmDate), 1, 0)
	ELSE
		IIF(RTRIM(LTRIM(ISNULL(C.strReferenceNo,''))) = LTRIM(RTRIM(ISNULL(ABR.strReferenceNo,''))), 1, 0)
	END
	AND ABS(dblAmount) = ABS(ABR.dblAmount)
	AND ABR.strDebitCredit =
	CASE WHEN C.intBankTransactionTypeId = 5 THEN
		CASE WHEN  dblAmount > 0 THEN 'C' ELSE 'D' END
	ELSE
		T.strDebitCredit
	END
	ORDER BY C.dtmDate
)CM
WHERE intImportBankStatementLogId =@intImportBankStatementLogId
AND ABR.intImportStatus =2
)
INSERT INTO ##tempActivityMatched (intABRActivityId, intTransactionId)
SELECT  intABRActivityId, intTransactionId FROM matching 


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

INSERT INTO tblCMABRActivityMatched(strMatchingId,intBankAccountId, intABRActivityId, intTransactionId, dtmDateEntered, intEntityId, intConcurrencyId)
SELECT @bankMatchingId,@intBankAccountId, intABRActivityId, intTransactionId,@dtmCurrent, @intEntityId,1 FROM ##tempActivityMatched
