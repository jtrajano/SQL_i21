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
	(SELECT 
		strBatchId
		, strCode
		, intTransactionId
		, strTransactionId
		, dtmDate
		, strTransactionType
		, intAccountId
	 FROM
		tblGLDetail
	 WHERE
		ysnIsUnposted = 0) GL
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
			(SELECT 
				intInvoiceId
				, strInvoiceNumber
				, intEntityId
				, intAccountId
				, intCompanyLocationId
				, dblInvoiceTotal
			 FROM 
				tblARInvoice
			 WHERE
				ysnPosted = 1) INV
			 LEFT OUTER JOIN 
				(SELECT 
					intEntityId
					, strName
				 FROM 
					tblEMEntity) E ON INV.intEntityId = E.intEntityId								
			 LEFT OUTER JOIN 	
				 (SELECT 
					intCompanyLocationId
					, strLocationName
				  FROM 
					dbo.tblSMCompanyLocation) LOC ON INV.intCompanyLocationId  = LOC.intCompanyLocationId 
			
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
			(SELECT 
				intPaymentId
				, strRecordNumber
				, intAccountId
				, intEntityId
				, dblAmountPaid
				, intLocationId
			 FROM 
				tblARPayment
			 WHERE 
				ysnPosted = 1) AR
			LEFT OUTER JOIN 
				(SELECT 
					intEntityId
					, strName
				 FROM 
					tblEMEntity) E ON AR.intEntityId = E.intEntityId			
			LEFT OUTER JOIN 
				(SELECT
					intCompanyLocationId
					, strLocationName
				 FROM 
					dbo.tblSMCompanyLocation) LOC ON AR.intLocationId  = LOC.intCompanyLocationId 			
	) AR
ON GL.intTransactionId = AR.intTransactionId
AND GL.strTransactionType IN ('Invoice','Receive Payments', 'Credit Memo')
AND GL.strCode = 'AR'		
AND GL.strTransactionId = AR.strTransactionId
AND GL.intAccountId = AR.intAccountId		
GROUP BY
	 GL.strBatchId
	,GL.dtmDate
	,GL.strTransactionType 
	,AR.strUserName
	,AR.strLocationName