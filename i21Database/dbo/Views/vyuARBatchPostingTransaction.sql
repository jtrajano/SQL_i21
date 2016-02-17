CREATE VIEW [dbo].[vyuARBatchPostingTransaction]
AS
SELECT
	 GL.strBatchId
	,GL.dtmDate
	,GL.strTransactionType
	,COUNT(AR.intTransactionId) dblEntriesCount
	,SUM(AR.dblTotal) dblTotalAmount
	,AR.strUserName
	,AR.strLocationName
	
FROM
	tblGLDetail GL
INNER JOIN
	(
		SELECT
			 strPostingType		= 'Invoice' 
			,dblTotal			= INV.dblInvoiceTotal
			,intTransactionId	= INV.intInvoiceId
			,strTransactionId	= INV.strInvoiceNumber
			,intAccountId		= INV.intAccountId
			,strUserName		= E.strName 
			,strLocationName	= LOC.strLocationName
		FROM
			tblARInvoice INV
			LEFT OUTER JOIN tblEntity E ON INV.intEntityId = E.intEntityId								
			LEFT OUTER JOIN 	dbo.tblSMCompanyLocation AS LOC ON INV.intCompanyLocationId  = LOC.intCompanyLocationId 
		WHERE
			INV.ysnPosted = 1
			
		UNION
		
		SELECT
			 strPostingType		= 'Receive Payments' 
			,dblTotal			= AR.dblAmountPaid
			,intTransactionId	= AR.intPaymentId
			,strTransactionId	= AR.strRecordNumber
			,intAccountId		= AR.intAccountId
			,strUserName		= E.strName 
			,strLocationName	= LOC.strLocationName
		FROM
			tblARPayment AR
			LEFT OUTER JOIN tblEntity E ON AR.intEntityId = E.intEntityId			
			LEFT OUTER JOIN 	dbo.tblSMCompanyLocation AS LOC ON AR.intLocationId  = LOC.intCompanyLocationId 
		WHERE
			AR.ysnPosted = 1
			
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
	,AR.strUserName
	,AR.strLocationName
	
	

