CREATE PROCEDURE dbo.uspARDuplicateInvoice
	 @InvoiceId			int
	,@InvoiceDate		datetime
	,@UserId			int
AS

DECLARE @InvoiceNumber nvarchar(25)
EXEC uspSMGetStartingNumber 19, @InvoiceNumber OUT

INSERT INTO tblARInvoice(
	strInvoiceNumber
	,strInvoiceOriginId
	,intCustomerId
	,dtmDate
	,dtmDueDate
	,intCurrencyId
	,intCompanyLocationId
	,intSalespersonId
	,dtmShipDate
	,intShipViaId
	,strPONumber
	,intTermId
	,dblInvoiceSubtotal
	,dblShipping
	,dblTax
	,dblInvoiceTotal
	,dblDiscount
	,dblAmountDue
	,dblPayment
	,strTransactionType
	,intPaymentMethodId
	,strComments
	,intAccountId
	,ysnPosted
	,ysnPaid
	,strShipToAddress
	,strShipToCity
	,strShipToState
	,strShipToZipCode
	,strShipToCountry
	,strBillToAddress
	,strBillToCity
	,strBillToState
	,strBillToZipCode
	,strBillToCountry
	,intConcurrencyId)
SELECT 
	@InvoiceNumber
	,strInvoiceOriginId
	,intCustomerId
	,@InvoiceDate
	,dbo.fnGetDueDateBasedOnTerm(@InvoiceDate, intTermId)
	,intCurrencyId
	,intCompanyLocationId
	,intSalespersonId
	,dtmShipDate
	,intShipViaId
	,strPONumber
	,intTermId
	,dblInvoiceSubtotal
	,dblShipping
	,dblTax
	,dblInvoiceTotal
	,dblDiscount
	,dblAmountDue
	,dblPayment
	,strTransactionType
	,intPaymentMethodId
	,strComments
	,intAccountId
	,0
	,0
	,strShipToAddress
	,strShipToCity
	,strShipToState
	,strShipToZipCode
	,strShipToCountry
	,strBillToAddress
	,strBillToCity
	,strBillToState
	,strBillToZipCode
	,strBillToCountry
	,0
FROM 
	tblARInvoice
WHERE
	intInvoiceId = @InvoiceId
	
	

DECLARE @NewInvoiceId int

SET @NewInvoiceId = SCOPE_IDENTITY()

INSERT INTO tblARInvoiceDetail(
	intInvoiceId
    ,intItemId
    ,strItemDescription
    ,dblQtyOrdered
    ,dblQtyShipped
    ,dblPrice
    ,dblTotal
    ,intConcurrencyId)
SELECT
	@NewInvoiceId
	,intItemId
	,strItemDescription
	,dblQtyOrdered
	,dblQtyShipped
	,dblPrice
	,dblTotal
	,intConcurrencyId
FROM
	tblARInvoiceDetail
WHERE
	intInvoiceId = @InvoiceId	



