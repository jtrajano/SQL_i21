﻿CREATE VIEW [dbo].[vyuSMBatchPostingResult]
AS
SELECT intRowId					AS		intBatchPostingResultId,
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
	SELECT ROW_NUMBER() OVER (ORDER BY dtmDate DESC) AS intRowId, intPostForeignTransResultId as intResultId, strBatchId, intTransactionId, strTransactionId, strDescription, dtmDate, strTransactionType, intEntityId
	FROM tblCFPostForeignTransResult
	UNION ALL
	SELECT ROW_NUMBER() OVER (ORDER BY dtmDate DESC) AS intRowId, intResult as intResultId, strBatchId, intTransactionId, strTransactionId, strDescription, dtmDate, strTransactionType, intEntityId
	FROM tblGLPostResult
	UNION ALL
	SELECT ROW_NUMBER() OVER (ORDER BY GETDATE() DESC) AS intRowId, intId as intResultId, strBatchNumber, intTransactionId, strTransactionId, strMessage, NULL, CASE WHEN strTransactionType = 'Bill' THEN 'Voucher' ELSE strTransactionType END, NULL
	FROM tblAPPostResult
	UNION ALL
	SELECT ROW_NUMBER() OVER (ORDER BY GETDATE() DESC) AS intRowId, intId as intResultId, strBatchNumber, intTransactionId, strTransactionId, strMessage, NULL, strTransactionType, NULL
	FROM tblARPostResult
	UNION ALL
	SELECT ROW_NUMBER() OVER (ORDER BY dtmDate DESC) AS intRowId, intResult as intResultId, strBatchId as strBatchNumber, intTransactionId, strTransactionId,strDescription, dtmDate, strTransactionType, intEntityId
	FROM tblSTPostResult
	UNION ALL
	SELECT ROW_NUMBER() OVER (ORDER BY dtmDate DESC) AS intRowId, intResult as intResultId, strBatchId as strBatchNumber, intTransactionId, strTransactionId, strDescription, dtmDate, strTransactionType, intEntityId
	FROM tblTRPostResult
	UNION ALL
	SELECT ROW_NUMBER() OVER (ORDER BY dtmDate DESC) AS intRowId, intResult as intResultId, strBatchId, intTransactionId, strTransactionId, strDescription, dtmDate, strTransactionType, intEntityId
	FROM tblMBPostResult
	UNION ALL
	SELECT ROW_NUMBER() OVER (ORDER BY dtmDate DESC) AS intRowId, ARIILD.intIntegrationLogDetailId as intResultId, ARIILD.strBatchId as strBatchNumber, ARIILD.intInvoiceId as intTransactionId, ARIILD.[strPostedTransactionId] as strTransactionId, ARIILD.strPostingMessage as strMessage, ARIIL.dtmDate as dtmDate, ARIILD.strTransactionType, ARIIL.[intEntityId] as intEntityId
	FROM tblARInvoiceIntegrationLogDetail ARIILD
	INNER JOIN tblARInvoiceIntegrationLog ARIIL ON ARIILD.[intIntegrationLogId] = ARIIL.[intIntegrationLogId]
	WHERE ARIILD.ysnHeader = 1 AND ARIILD.ysnSuccess = 1 AND ARIILD.ysnPost IS NOT NULL --AND (ARIILD.ysnPosted = 1 or ARIILD.ysnUnPosted = 1)	
	UNION ALL
	SELECT ROW_NUMBER() OVER (ORDER BY dtmDate DESC) AS intRowId, ARIILD.intIntegrationLogDetailId as intResultId, ARIILD.strBatchId as strBatchNumber, ISNULL(ARIILD.intInvoiceId, ARIILD.intSourceId) as intTransactionId, ISNULL(ARIILD.[strPostedTransactionId], ARIILD.[strSourceId]) as strTransactionId, ISNULL(ARIILD.strPostingMessage, ARIILD.strMessage) as strMessage, ARIIL.dtmDate as dtmDate, ARIILD.strTransactionType, ARIIL.[intEntityId] as intEntityId
	FROM tblARInvoiceIntegrationLogDetail ARIILD
	INNER JOIN tblARInvoiceIntegrationLog ARIIL ON ARIILD.[intIntegrationLogId] = ARIIL.[intIntegrationLogId]
	WHERE ARIILD.ysnHeader = 1 AND ARIILD.ysnSuccess = 0
	UNION ALL
	SELECT ROW_NUMBER() OVER (ORDER BY dtmDate DESC) AS intRowId, ARPILD.intIntegrationLogDetailId as intResultId, ARPILD.strBatchId as strBatchNumber, ARPILD.intPaymentId as intTransactionId, ARPILD.[strPostedTransactionId] as strTransactionId, ARPILD.strPostingMessage as strMessage, ARPIL.[dtmDate] as dtmDate, 'Receivable' AS strTransactionType, ARPIL.[intEntityId] as intEntityId
	FROM tblARPaymentIntegrationLogDetail ARPILD
	INNER JOIN tblARPaymentIntegrationLog ARPIL ON ARPILD.[intIntegrationLogId] = ARPIL.[intIntegrationLogId] 
	WHERE ARPILD.ysnHeader = 1 AND ARPILD.ysnSuccess = 1 AND ARPILD.ysnPost IS NOT NULL --AND (ysnPosted = 1 or ysnUnPosted = 1)
) BatchPostingResult	
WHERE strDescription IS NOT NULL
