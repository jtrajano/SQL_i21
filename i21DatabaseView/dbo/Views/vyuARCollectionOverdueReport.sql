CREATE VIEW [dbo].[vyuARCollectionOverdueReport]
AS
SELECT 
	ARCOD.intCompanyLocationId		 
	,ARCOD.strCompanyName				 
	,ARCOD.strCompanyAddress			 
	,ARCOD.strCompanyPhone			 
	,ARCOD.intEntityCustomerId		 
	,ARCOD.strCustomerNumber			 
	,ARCOD.strCustomerName			 
	,ARCOD.strCustomerAddress			 
	,ARCOD.strCustomerPhone			 
	,ARCOD.strAccountNumber			 
	,ARCOD.intInvoiceId				 
	,ARCOD.strInvoiceNumber			 
	,ARCOD.strBOLNumber				 
	,ARCOD.dblCreditLimit	
	,ARCO.dblCreditLimitSum				 
	,ARCOD.intTermId					 
	,ARCOD.strTerm					 
	,ARCOD.dblTotalAR
	,ARCO.dblTotalARSum						 
	,ARCOD.dblFuture	
	,ARCO.dblFutureSum						 
	,ARCOD.dbl0Days	
	,ARCO.dbl0DaysSum						 
	,ARCOD.dbl10Days					 
	,ARCO.dbl10DaysSum
	,ARCOD.dbl30Days					 
	,ARCO.dbl30DaysSum
	,ARCOD.dbl60Days					 
	,ARCO.dbl60DaysSum					 
	,ARCOD.dbl90Days					 
	,ARCO.dbl90DaysSum
	,ARCOD.dbl120Days					 
	,ARCO.dbl120DaysSum
	,ARCOD.dbl121Days					 
	,ARCO.dbl121DaysSum
	,ARCOD.dblTotalDue				 
	,ARCO.dblTotalDueSum
	,ARCOD.dblAmountPaid				 
	,ARCO.dblAmountPaidSum
	,ARCOD.dblInvoiceTotal			 		 
	,ARCO.dblInvoiceTotalSum
	,ARCOD.dblCredits					 	
	,ARCO.dblCreditsSum
	,ARCOD.dblPrepaids				 	
	,ARCO.dblPrepaidsSum
	,ARCOD.dtmDate					 
	,ARCOD.dtmDueDate
	, dtmLetterDate = GETDATE()
	, strCreatedByName = USERENTERED.strName
	, strCreatedByPhone = USERENTERED.strPhone
	, strCreatedByEmail = USERENTERED.strEmail
	, strSalesPersonName = SALESPERSON.strName	
 FROM 
	tblARCollectionOverdueDetail ARCOD
INNER JOIN
	tblARCollectionOverdue ARCO ON ARCOD.intEntityCustomerId = ARCO.intEntityCustomerId 
INNER JOIN (
	SELECT intInvoiceId, intPostedById, intEntityId, intEntitySalespersonId, intEntityContactId FROM tblARInvoice
) I ON I.intInvoiceId = ARCOD.intInvoiceId
LEFT OUTER JOIN (
	SELECT intEntityId, strName, strPhone, strEmail FROM dbo.tblEMEntity WITH (NOLOCK)
) USERENTERED ON USERENTERED.intEntityId = I.intEntityId
LEFT OUTER JOIN(
	SELECT intEntityId, strName FROM dbo.tblEMEntity WITH (NOLOCK)
) SALESPERSON ON SALESPERSON.intEntityId = I.intEntitySalespersonId
WHERE ARCOD.intInvoiceId NOT IN (SELECT intInvoiceId FROm tblARInvoice WHERE strTransactionType IN ('Credit Memo', 'Customer Prepayment', 'Overpayment') AND ysnPaid = 1) 


