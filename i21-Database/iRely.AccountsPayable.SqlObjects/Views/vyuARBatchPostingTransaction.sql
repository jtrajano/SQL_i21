CREATE VIEW [dbo].[vyuARBatchPostingTransaction]
AS
SELECT
	 GL.strBatchId
	,dtmDate					= GL.dtmDateEntered
	,GL.strTransactionType
	,dblEntriesCount			= COUNT(AR.intTransactionId)  
	,dblTotalAmount				= SUM(AR.dblTotal) 
	,strUserName				= E.strName
	,AR.strLocationName	
	,intCurrencyId				= AR.intCurrencyID
	,AR.strCurrency
	,AR.strCurrencyDescription
FROM
	(SELECT DISTINCT
		  strBatchId
		, strCode
		, intTransactionId
		, strTransactionId
		, dtmDate
		, dtmDateEntered = CAST(dtmDateEntered AS DATE)
		, intEntityId
		, strTransactionType
		, intAccountId
	 FROM
		tblGLDetail
	 WHERE
		ysnIsUnposted = 0) GL
INNER JOIN 
	(
		SELECT 
			 intEntityId
			,strName
		FROM 
			tblEMEntity
	) E ON GL.intEntityId = E.intEntityId			
INNER JOIN
	(
		SELECT
			 strPostingType			= 'Invoice' 
			,dblTotal				= INV.dblInvoiceTotal
			,intTransactionId		= INV.intInvoiceId
			,strTransactionId		= INV.strInvoiceNumber
			,intAccountId			= INV.intAccountId
			,strLocationName		= LOC.strLocationName
			,intCurrencyID			= SMC.intCurrencyID
			,strCurrency			= SMC.strCurrency
			,strCurrencyDescription	= SMC.strDescription
		FROM
			(SELECT 
				intInvoiceId
				, strInvoiceNumber
				, intAccountId
				, intCompanyLocationId
				, dblInvoiceTotal	
				, intCurrencyId			
			 FROM 
				tblARInvoice
			 WHERE
				ysnPosted = 1) INV			 						
			 LEFT OUTER JOIN 	
				 (SELECT 
					intCompanyLocationId
					, strLocationName
				  FROM 
					dbo.tblSMCompanyLocation) LOC ON INV.intCompanyLocationId  = LOC.intCompanyLocationId 
			LEFT OUTER JOIN 
				(SELECT intCurrencyID, 
						strCurrency, 
						strDescription 
				FROM 
					tblSMCurrency) SMC ON INV.intCurrencyId = SMC.intCurrencyID	
			
		UNION
		
		SELECT
			 strPostingType		= 'Receive Payments' 
			,dblTotal			= AR.dblAmountPaid
			,intTransactionId	= AR.intPaymentId
			,strTransactionId	= AR.strRecordNumber
			,intAccountId		= AR.intAccountId
			,strLocationName	= LOC.strLocationName
			,intCurrencyID			= SMC.intCurrencyID
			,strCurrency			= SMC.strCurrency
			,strCurrencyDescription	= SMC.strDescription
		FROM
			(SELECT 
				intPaymentId
				, strRecordNumber
				, intAccountId
				, dblAmountPaid
				, intLocationId
				, intCurrencyId
			 FROM 
				tblARPayment
			 WHERE 
				ysnPosted = 1) AR		
			LEFT OUTER JOIN 
				(SELECT
					intCompanyLocationId
					, strLocationName
				 FROM 
					dbo.tblSMCompanyLocation) LOC ON AR.intLocationId  = LOC.intCompanyLocationId 			
			LEFT OUTER JOIN 
				(SELECT intCurrencyID, 
						strCurrency, 
						strDescription 
				FROM 
					tblSMCurrency) SMC ON AR.intCurrencyId = SMC.intCurrencyID	
	) AR
ON GL.intTransactionId = AR.intTransactionId	
AND GL.strTransactionType IN ('Invoice','Receive Payments', 'Credit Memo')
AND GL.strCode = 'AR'		
AND GL.strTransactionId = AR.strTransactionId
AND GL.intAccountId = AR.intAccountId		
GROUP BY
	 GL.strBatchId
	--,GL.dtmDate
	,GL.dtmDateEntered
	,GL.strTransactionType 
	,E.strName
	,AR.strLocationName
	,AR.intCurrencyID
	,AR.strCurrency
	,AR.strCurrencyDescription