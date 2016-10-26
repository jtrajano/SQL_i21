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
 FROM 
	tblARCollectionOverdueDetail ARCOD
INNER JOIN
	tblARCollectionOverdue ARCO ON ARCOD.intEntityCustomerId = ARCO.intEntityCustomerId 
WHERE intInvoiceId NOT IN (SELECT intInvoiceId FROm tblARInvoice WHERE strTransactionType IN ('Credit Memo', 'Customer Prepayment', 'Overpayment') AND ysnPaid = 1) 


