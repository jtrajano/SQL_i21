CREATE VIEW [dbo].[vyuARBatchPostingTransaction]
AS
SELECT
	 GL.strBatchId
	,GL.dtmDate
	,GL.strTransactionType
	,COUNT(AR.intTransactionId) dblEntriesCount
	,SUM(AR.dblTotal) dblTotalAmount
FROM
	tblGLDetail GL
INNER JOIN
	(
		SELECT
			 strPostingType		= 'Invoice' 
			,dblTotal			= dblInvoiceTotal
			,intTransactionId	= intInvoiceId
			,strTransactionId	= strInvoiceNumber
			,intAccountId		= intAccountId
		FROM
			tblARInvoice
		WHERE
			ysnPosted = 1
			
		UNION
		
		SELECT
			 strPostingType		= 'Receive Payments' 
			,dblTotal			= dblAmountPaid
			,intTransactionId	= intPaymentId
			,strTransactionId	= strRecordNumber
			,intAccountId		= intAccountId
		FROM
			tblARPayment
		WHERE
			ysnPosted = 1
			
	) AR
		ON GL.intTransactionId = AR.intTransactionId
		AND GL.strTransactionType IN ('Invoice','Receive Payments')
		AND GL.strCode = 'AR'		
		AND GL.strTransactionId = AR.strTransactionId
		AND GL.intAccountId = AR.intAccountId
		AND GL.strTransactionType = AR.strPostingType
		AND GL.ysnIsUnposted = 0			
GROUP BY
	 GL.strBatchId
	,GL.dtmDate
	,GL.strTransactionType