CREATE VIEW [dbo].[vyuARPaymentSearch]
AS
SELECT 
	 P.intPaymentId
	,P.strRecordNumber
	,P.intEntityId
	,P.intEntityCustomerId
	,P.intBankAccountId
	,strBankAccountNo		= LTRIM(RTRIM(BA.strBankAccountNo))
	,strCustomerName		= LTRIM(RTRIM(E.strName))
	,strCustomerNumber		= ISNULL(C.strCustomerNumber, E.strEntityNo)
	,P.dtmDatePaid
	,P.intPaymentMethodId
	,strPaymentMethod		= PM.strPaymentMethod
	,dblAmountPaid			= P.dblAmountPaid
	,P.ysnPosted
	,strPaymentType			= 'Payment'
	,strInvoices			= dbo.fnARGetInvoiceNumbersFromPayment(intPaymentId)
	,P.intLocationId 
	,CL.strLocationName
	,dtmBatchDate			= GL.dtmDate
	,GL.strBatchId
	,strUserEntered			= ISNULL(GL.strName, EM.strName)
	,strTicketNumbers		= dbo.fnARGetScaleTicketNumbersFromPayment(P.intPaymentId)
	,strCustomerReferences	= dbo.fnARGetCustomerReferencesFromPayment(P.intPaymentId)
	,intCurrencyId			= P.intCurrencyId
	,strCurrency			= SMC.strCurrency
    ,strCurrencyDescription	= SMC.strDescription	 
FROM (SELECT intPaymentId
		   , strRecordNumber 
		   , intEntityId
		   , intEntityCustomerId
		   , intBankAccountId
		   , dtmDatePaid
		   , intPaymentMethodId
		   , dblAmountPaid
		   , ysnPosted
		   , intLocationId
		   , intAccountId 
		   , intCurrencyId  
	  FROM dbo.tblARPayment WITH (NOLOCK)
) P 
LEFT OUTER JOIN (SELECT intEntityId
					  , strName 
				 FROM dbo.tblEMEntity WITH (NOLOCK)
) EM ON P.intEntityId = EM.intEntityId
LEFT OUTER JOIN (SELECT intPaymentMethodID
					  , strPaymentMethod 
				 FROM dbo.tblSMPaymentMethod WITH (NOLOCK)
) PM ON P.intPaymentMethodId = PM.intPaymentMethodID
INNER JOIN (SELECT intEntityId 
			     , strEntityNo
			     , strName 
		    FROM dbo.tblEMEntity WITH (NOLOCK)
) E ON P.intEntityCustomerId = E.intEntityId
LEFT OUTER JOIN (SELECT intEntityCustomerId
					 ,  strCustomerNumber 
				 FROM dbo.tblARCustomer WITH (NOLOCK)
) C ON E.intEntityId = C.intEntityCustomerId
LEFT OUTER JOIN (SELECT intBankAccountId
					  , strBankAccountNo 
				 FROM dbo.tblCMBankAccount WITH (NOLOCK)
) BA ON P.intBankAccountId = BA.intBankAccountId
LEFT OUTER JOIN (SELECT intCompanyLocationId
					  , strLocationName 
				 FROM dbo.tblSMCompanyLocation WITH (NOLOCK)
) CL ON P.intLocationId = CL.intCompanyLocationId
LEFT OUTER JOIN (SELECT G.intTransactionId
			          , G.strTransactionId
			          , G.intAccountId
			          , G.strTransactionType
			          , G.dtmDate
			          , G.strBatchId
			          , E.intEntityId
			          , E.strName
				FROM (SELECT intTransactionId
					       , strTransactionId 
					       , intAccountId
					       , strTransactionType
					       , dtmDate
					       , strBatchId
					       , intEntityId 
					 FROM dbo.tblGLDetail WITH (NOLOCK)
					 WHERE strTransactionType IN ('Receive Payments') 
					   AND ysnIsUnposted = 0 
					   AND strCode = 'AR') G
				LEFT OUTER JOIN (SELECT intEntityId
									  , strName 
								 FROM dbo.tblEMEntity WITH (NOLOCK)
				) E ON G.intEntityId = E.intEntityId
) GL ON P.intPaymentId = GL.intTransactionId AND P.intAccountId = GL.intAccountId AND P.strRecordNumber = GL.strTransactionId
LEFT OUTER JOIN (SELECT intCurrencyID
					  , strCurrency
					  , strDescription 
				 FROM dbo.tblSMCurrency WITH (NOLOCK)
) SMC ON P.intCurrencyId = SMC.intCurrencyID