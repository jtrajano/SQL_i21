CREATE PROCEDURE dbo.uspARDuplicateInvoice
	 @InvoiceId			int
	,@InvoiceDate		datetime
	,@UserId			int
	,@NewInvoiceNumber	nvarchar(25) = NULL		OUTPUT
AS

BEGIN

	DECLARE @EntityId int

	SET @EntityId = ISNULL((SELECT TOP 1 intEntityId FROM tblSMUserSecurity WHERE intUserSecurityID = @UserId), 0)

	INSERT INTO tblARInvoice(
		strInvoiceOriginId
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
		,dtmPostDate
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
		,intConcurrencyId
		,intEntityId)
	SELECT 
		strInvoiceOriginId
		,intCustomerId
		,@InvoiceDate
		,dbo.fnGetDueDateBasedOnTerm(@InvoiceDate, intTermId)
		,intCurrencyId
		,intCompanyLocationId
		,intSalespersonId
		,@InvoiceDate
		,intShipViaId
		,strPONumber
		,intTermId
		,dblInvoiceSubtotal
		,dblShipping
		,dblTax
		,dblInvoiceTotal
		,0
		,dblInvoiceTotal
		,0
		,strTransactionType
		,intPaymentMethodId
		,strComments
		,intAccountId
		,@InvoiceDate
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
		,@EntityId
	FROM 
		tblARInvoice
	WHERE
		intInvoiceId = @InvoiceId
		
		
	DECLARE @NewId int

	SET @NewId = SCOPE_IDENTITY()

	INSERT INTO tblARInvoiceDetail(
		intInvoiceId
		,intCompanyLocationId
		,intItemId
		,strItemDescription
		,intItemUOMId
		,dblQtyOrdered
		,dblQtyShipped
		,dblPrice
		,dblTotal
		,intAccountId
		,intCOGSAccountId
		,intSalesAccountId
		,intInventoryAccountId
		,intConcurrencyId)
	SELECT
		@NewId
		,intCompanyLocationId
		,intItemId
		,strItemDescription
		,intItemUOMId
		,dblQtyOrdered
		,dblQtyShipped
		,dblPrice
		,dblTotal
		,intAccountId
		,intCOGSAccountId
		,intSalesAccountId
		,intInventoryAccountId
		,0
	FROM
		tblARInvoiceDetail
	WHERE
		intInvoiceId = @InvoiceId	

	SET  @NewInvoiceNumber = (SELECT strInvoiceNumber FROM tblARInvoice WHERE intInvoiceId = @NewId)

	Return @NewId
END
