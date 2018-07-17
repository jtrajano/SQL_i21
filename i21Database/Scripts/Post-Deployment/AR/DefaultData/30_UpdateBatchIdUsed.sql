print('/*******************  BEGIN Fix amounts for tblARInvoice.strBatchId, dtmBatchDate, intPostedById *******************/')
GO

UPDATE I
SET strBatchId		= CASE WHEN I.ysnPosted = 1 THEN GL.strBatchId ELSE NULL END
  , dtmBatchDate	= CASE WHEN I.ysnPosted = 1 THEN GL.dtmDateEntered ELSE NULL END
  , intPostedById	= CASE WHEN I.ysnPosted = 1 THEN GL.intEntityId ELSE NULL END
FROM tblARInvoice I
OUTER APPLY (
	SELECT TOP 1 strBatchId
			   , dtmDateEntered
			   , intEntityId
	FROM dbo.tblGLDetail WITH (NOLOCK)
	WHERE ysnIsUnposted = 0
	  AND intTransactionId = I.intInvoiceId
	  AND strTransactionId = I.strInvoiceNumber
) GL

GO
print('/*******************  END Fix amounts for tblARInvoice.strBatchId, dtmBatchDate, intPostedById *******************/')

print('/*******************  BEGIN Fix amounts for tblARPayment.strBatchId, dtmBatchDate, intPostedById *******************/')
GO

UPDATE P
SET strBatchId				= CASE WHEN P.ysnPosted = 1 THEN GL.strBatchId ELSE NULL END
  , dtmBatchDate			= CASE WHEN P.ysnPosted = 1 THEN GL.dtmDateEntered ELSE NULL END
  , intPostedById			= CASE WHEN P.ysnPosted = 1 THEN GL.intEntityId ELSE NULL END
	, intCurrentStatus 	= CASE WHEN P.ysnPosted = 1 THEN 4 ELSE 5 END
FROM tblARPayment P
OUTER APPLY (
	SELECT TOP 1 strBatchId
			   , dtmDateEntered
			   , intEntityId
	FROM dbo.tblGLDetail WITH (NOLOCK)
	WHERE ysnIsUnposted = 0
	  AND intTransactionId = P.intPaymentId
	  AND strTransactionId = P.strRecordNumber
) GL

GO
print('/*******************  END Fix amounts for tblARPayment.strBatchId, dtmBatchDate, intPostedById *******************/')