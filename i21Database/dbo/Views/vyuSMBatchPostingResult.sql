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
	SELECT intId as intResultId, strBatchNumber, intTransactionId, strTransactionId, strMessage, NULL, CASE WHEN strTransactionType = 'Bill' THEN 'Voucher' ELSE strTransactionType END, NULL
	FROM tblAPPostResult
	UNION ALL
	SELECT intId as intResultId, strBatchNumber, intTransactionId, strTransactionId, strMessage, NULL, strTransactionType, NULL
	FROM tblARPostResult
	UNION ALL
	SELECT intIntegrationLogDetailId as intResultId, strBatchId as strBatchNumber, intInvoiceId as intTransactionId, [strPostedTransactionId] as strTransactionId, strPostingMessage as strMessage, NULL, strTransactionType, NULL
	FROM tblARInvoiceIntegrationLogDetail
	WHERE ysnHeader = 1 AND ysnSuccess = 1 AND ysnPost IS NOT NULL AND (ysnPosted = 1 or ysnUnPosted = 1)
) BatchPostingResult	
WHERE strDescription IS NOT NULL