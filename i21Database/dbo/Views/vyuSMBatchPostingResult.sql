CREATE VIEW [dbo].[vyuSMBatchPostingResult]
AS
SELECT CAST (ROW_NUMBER() OVER (ORDER BY dtmDate DESC) AS INT) AS intBatchPostingResultId,
intResultId						AS		intResultId,
strBatchId						AS		strBatchId,
intTransactionId                AS		intTransactionId,
strTransactionId                AS		strTransactionId,
strTransactionType              AS		strTransactionType,
strDescription					AS		strDescription,
dtmDate                         AS		dtmDate,
intEntityId						AS		intEntityId
FROM
(
	SELECT intResult as intResultId, strBatchId, intTransactionId, strTransactionId, strDescription, dtmDate, strTransactionType, intEntityId
	FROM tblGLPostResult
	UNION ALL
	SELECT intId as intResultId, strBatchNumber, intTransactionId, strTransactionId, strMessage, NULL, strTransactionType, NULL
	FROM tblAPPostResult
	UNION ALL
	SELECT intId as intResultId, strBatchNumber, intTransactionId, strTransactionId, strMessage, NULL, strTransactionType, NULL
	FROM tblARPostResult
) BatchPostingResult
WHERE strDescription IS NOT NULL