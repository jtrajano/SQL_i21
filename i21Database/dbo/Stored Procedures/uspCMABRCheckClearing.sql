
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
	rowId INT,
	intABRActivityId INT NULL,
	intTransactionId INT NULL,
	
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
	AND (
		(dtmCheckPrinted IS NOT NULL AND strTransactionId NOT LIKE 'B%')
	OR  (dtmCheckPrinted IS NULL AND strTransactionId LIKE 'B%') --exempt bank transactions
	) 
	AND dtmDateReconciled IS NULL
    AND ysnClr = 0
	AND 1 = 
	CASE WHEN  RTRIM(LTRIM(ISNULL(C.strReferenceNo,''))) = '' AND LTRIM(RTRIM(ISNULL(ABR.strReferenceNo,''))) = '' 
	THEN 
		CASE WHEN ABR.dtmClear <= DATEADD(DAY,@intABRDaysNoRef, C.dtmDate)
		THEN 1
		ELSE 0
		END
	ELSE
		CASE WHEN RTRIM(LTRIM(ISNULL(C.strReferenceNo,''))) = LTRIM(RTRIM(ISNULL(ABR.strReferenceNo,'')))
		THEN 1
		ELSE 0
		END
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
INSERT INTO ##tempActivityMatched (rowId, intABRActivityId, intTransactionId)
SELECT ROW_NUMBER() OVER(ORDER BY intABRActivityId) rowId,  intABRActivityId, intTransactionId FROM matching 


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
DECLARE @cntMatched INT , @index INT = 0
SELECT @cntMatched = COUNT(*) FROM ##tempActivityMatched

WHILE (@index < @cntMatched)
BEGIN
	SET @index += 1
	EXEC uspSMGetStartingNumber 162,  @bankMatchingId OUT
	INSERT INTO tblCMABRActivityMatched(strMatchingId,intBankAccountId, intABRActivityId, intTransactionId, dtmDateEntered, intEntityId, intConcurrencyId)
	SELECT @bankMatchingId,@intBankAccountId, intABRActivityId, intTransactionId,@dtmCurrent, @intEntityId,1 FROM ##tempActivityMatched
	WHERE rowId = @index
END