CREATE VIEW [dbo].[vyuARBatchPostingTransaction]
AS
SELECT
	 AR.strBatchId
	,dtmDate					= AR.dtmBatchDate
	,AR.strTransactionType
	,dblEntriesCount			= COUNT(AR.intTransactionId)  
	,dblTotalAmount				= SUM(AR.dblTotal) 
	,strUserName				= E.strName
	,AR.strLocationName	
	,intCurrencyId				= AR.intCurrencyID
	,AR.strCurrency
	,AR.strCurrencyDescription
FROM
	--(SELECT DISTINCT
	--	  strBatchId
	--	, strCode
	--	, intTransactionId
	--	, strTransactionId
	--	, dtmDate
	--	, dtmDateEntered = CAST(dtmDateEntered AS DATE)
	--	, intEntityId
	--	, strTransactionType
	--	, intAccountId
	-- FROM
	--	tblGLDetail
	-- WHERE
	--	ysnIsUnposted = 0) GL
--INNER JOIN
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
			,dtmPostDate			= INV.dtmPostDate
			,strBatchId				= INV.strBatchId
			,dtmBatchDate			= CAST(INV.dtmBatchDate AS DATE)
			,intPostedById			= INV.intPostedById	
			,strTransactionType		= INV.strTransactionType
		FROM
			(SELECT 
				intInvoiceId
				, strInvoiceNumber
				, intAccountId
				, intCompanyLocationId
				, dblInvoiceTotal	
				, intCurrencyId
				, dtmPostDate
				, strBatchId
				, dtmBatchDate
				, intPostedById	
				, strTransactionType
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
			,dtmPostDate			= AR.dtmDatePaid
			,strBatchId				= AR.strBatchId
			,dtmBatchDate			= CAST(AR.dtmBatchDate AS DATE)
			,intPostedById			= AR.intPostedById
			,strTransactionType		= 'Receive Payments'	
		FROM
			(SELECT 
				intPaymentId
				, strRecordNumber
				, intAccountId
				, dblAmountPaid
				, intLocationId
				, intCurrencyId
				, dtmDatePaid
				, strBatchId
				, dtmBatchDate
				, intPostedById	
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
INNER JOIN 
    (
        SELECT 
             intEntityId
            ,strName
        FROM 
            tblEMEntity
    ) E ON AR.intPostedById = E.intEntityId            
	
GROUP BY
	 AR.strBatchId
	--,GL.dtmDate
	,AR.dtmBatchDate
	,AR.strTransactionType 
	,E.strName
	,AR.strLocationName
	,AR.intCurrencyID
	,AR.strCurrency
	,AR.strCurrencyDescription