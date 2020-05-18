CREATE VIEW [dbo].[vyuARInvoiceCompact]
AS
SELECT intInvoiceId			= I.intInvoiceId
	 , intEntityCustomerId	= I.intEntityCustomerId
	 , intCompanyLocationId	= I.intCompanyLocationId
	 , strInvoiceNumber		= I.strInvoiceNumber
	 , strCustomerName		= EM.strName
	 , strCustomerNumber	= C.strCustomerNumber
	 , strTransactionType	= I.strTransactionType
	 , strType				= I.strType
	 , strLocationName		= CL.strLocationName
	 , strComments			= CASE WHEN ISNULL(I.strComments, '') <> '' THEN dbo.fnStripHtml(I.strComments) ELSE NULL END
	 , strEnteredBy			= EE.strName
	 , strCurrency			= SM.strCurrency
	 , strStatus			= CASE WHEN ISNULL(EMAILSETUP.ysnHasEmailSetup, CAST(0 AS BIT)) = 1 THEN 'Ready' ELSE 'Email not Configured.' END COLLATE Latin1_General_CI_AS
	 , strBatchId			= I.strBatchId
	 , dtmDate				= I.dtmDate
	 , dtmBatchDate			= I.dtmBatchDate
	 , dblInvoiceTotal		= I.dblInvoiceTotal
	 , dblAmountDue			= I.dblAmountDue
	 , ysnPosted			= I.ysnPosted
	 , ysnPaid = CASE WHEN (I.strTransactionType IN ('Customer Prepayment') AND I.ysnPaid = 0) THEN I.ysnPaidCPP ELSE I.ysnPaid END
	 , ysnHasEmailSetup		= ISNULL(EMAILSETUP.ysnHasEmailSetup, CAST(0 AS BIT))
	 , ysnMailSent			= ISNULL(EMAILSTATUS.ysnMailSent, CAST(0 AS BIT))
FROM tblARInvoice I WITH (NOLOCK)
INNER JOIN tblEMEntity EM WITH (NOLOCK) ON I.intEntityCustomerId = EM.intEntityId
INNER JOIN tblARCustomer C WITH (NOLOCK) ON I.intEntityCustomerId = C.intEntityId
INNER JOIN tblSMCompanyLocation CL WITH (NOLOCK) ON I.intCompanyLocationId = CL.intCompanyLocationId
INNER JOIN tblSMCurrency SM WITH (NOLOCK) ON I.intCurrencyId = SM.intCurrencyID
INNER JOIN tblEMEntity EE WITH (NOLOCK) ON I.intEntityId = EE.intEntityId
OUTER APPLY (
	SELECT ysnHasEmailSetup	= CASE WHEN COUNT(ETC.intEntityId) > 0 THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END
	FROM tblEMEntityToContact ETC WITH (NOLOCK) 
	INNER JOIN tblEMEntity EM ON ETC.intEntityContactId = EM.intEntityId 
	WHERE ISNULL(EM.strEmail, '') <> ''
	  AND ISNULL(EM.strEmailDistributionOption, '') <> ''
	  AND ETC.intEntityId = I.intEntityCustomerId 
	  AND EM.strEmailDistributionOption LIKE '%' + I.strTransactionType + '%'
) EMAILSETUP
LEFT JOIN (
	SELECT intInvoiceId = SMT.intRecordId 
		 , ysnMailSent	= CASE WHEN COUNT(SMA.intTransactionId) > 0 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END 
	FROM (SELECT intRecordId, intTransactionId, intScreenId FROM tblSMTransaction WITH (NOLOCK)) SMT 
	INNER JOIN (SELECT intScreenId FROM tblSMScreen WHERE strScreenName = 'Invoice') SC ON SMT.intScreenId = SC.intScreenId
	INNER JOIN (SELECT intTransactionId, strType, strStatus FROM tblSMActivity WITH (NOLOCK) WHERE strType = 'Email' and strStatus = 'Sent') SMA ON SMA.intTransactionId = SMT.intTransactionId 
	GROUP BY SMT.intRecordId
) EMAILSTATUS ON I.intInvoiceId = EMAILSTATUS.intInvoiceId
WHERE I.strType NOT IN ('CF Tran', 'CF Invoice')