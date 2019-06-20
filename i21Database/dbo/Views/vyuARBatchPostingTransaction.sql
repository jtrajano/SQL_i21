CREATE VIEW [dbo].[vyuARBatchPostingTransaction]
AS
SELECT intBatchPostingTransactionId = CAST(ROW_NUMBER() OVER (ORDER BY AR.dtmBatchDate DESC, AR.strBatchId DESC) AS INT)
     , strBatchId				    = AR.strBatchId
	 , dtmDate					    = AR.dtmBatchDate
	 , strTransactionType		    = AR.strTransactionType
	 , dblEntriesCount			    = COUNT(AR.intTransactionId)  
	 , dblTotalAmount			    = SUM(AR.dblTotal) 
	 , strUserName				    = E.strName
	 , strLocationName			    = LOC.strLocationName
	 , intCurrencyId			    = AR.intCurrencyId
	 , strCurrency				    = SMC.strCurrency
	 , strCurrencyDescription	    = SMC.strDescription
	 , strPostingType			    = AR.strPostingType
FROM (
	SELECT strPostingType			= 'Invoice' COLLATE Latin1_General_CI_AS
		 , dblTotal					= INV.dblInvoiceTotal
		 , intTransactionId			= INV.intInvoiceId
		 , strTransactionId			= INV.strInvoiceNumber
		 , intAccountId				= INV.intAccountId
		 , intCurrencyId			= INV.intCurrencyId
		 , intCompanyLocationId		= INV.intCompanyLocationId
		 , dtmPostDate				= INV.dtmPostDate
		 , strBatchId				= INV.strBatchId
		 , dtmBatchDate				= CAST(INV.dtmBatchDate AS DATE)
		 , intPostedById			= INV.intPostedById	
		 , strTransactionType		= INV.strTransactionType
	FROM tblARInvoice INV
	WHERE ysnPosted = 1 

	UNION
		
	SELECT strPostingType			= 'Receive Payments' COLLATE Latin1_General_CI_AS
		 , dblTotal					= P.dblAmountPaid
		 , intTransactionId			= P.intPaymentId
		 , strTransactionId			= P.strRecordNumber
		 , intAccountId				= P.intAccountId
		 , intCurrencyId			= P.intCurrencyId
		 , intCompanyLocationId		= P.intLocationId
		 , dtmPostDate				= P.dtmDatePaid
		 , strBatchId				= P.strBatchId
		 , dtmBatchDate				= CAST(P.dtmBatchDate AS DATE)
		 , intPostedById			= P.intPostedById
		 , strTransactionType		= 'Receive Payments'	
	FROM tblARPayment P
	WHERE ysnPosted = 1		
) AR
INNER JOIN (
    SELECT intEntityId
         , strName
    FROM tblEMEntity
) E ON AR.intPostedById = E.intEntityId
LEFT OUTER JOIN (
	SELECT intCompanyLocationId
		 , strLocationName
	FROM dbo.tblSMCompanyLocation
) LOC ON AR.intCompanyLocationId = LOC.intCompanyLocationId 
LEFT OUTER JOIN (
	SELECT intCurrencyID
		 , strCurrency
		 , strDescription 
	FROM tblSMCurrency
) SMC ON AR.intCurrencyId = SMC.intCurrencyID	
GROUP BY AR.strBatchId
	   , AR.dtmBatchDate
	   , AR.strTransactionType 
	   , E.strName
	   , LOC.strLocationName
	   , AR.intCurrencyId
	   , SMC.strCurrency
	   , SMC.strDescription
	   , AR.strPostingType