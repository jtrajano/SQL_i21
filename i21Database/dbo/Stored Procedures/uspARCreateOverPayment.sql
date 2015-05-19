﻿CREATE PROCEDURE [dbo].[uspARCreateOverPayment]
	 @PaymentId		as int
	,@Post			as bit			= 1
	,@BatchId		as nvarchar(20)	= NULL
	,@UserId		as int			= 1
	,@NewInvoiceId	as int			= NULL OUTPUT			
AS

BEGIN


SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ZeroDecimal decimal(18,6)
		,@DateOnly DATETIME

SET @ZeroDecimal = 0.000000
		
SELECT @DateOnly = CAST(GETDATE() as date)

INSERT INTO [tblARInvoice]
	([strInvoiceOriginId]
	,[intEntityCustomerId]
	,[dtmDate]
	,[dtmDueDate]
	,[intCurrencyId]
	,[intCompanyLocationId]
	,[intEntitySalespersonId]
	,[dtmShipDate]
	,[intShipViaId]
	,[strPONumber]
	,[intTermId]
	,[dblInvoiceSubtotal]
	,[dblShipping]
	,[dblTax]
	,[dblInvoiceTotal]
	,[dblDiscount]
	,[dblAmountDue]
	,[dblPayment]
	,[strTransactionType]
	,[intPaymentMethodId]
	,[strComments]
	,[intAccountId]
	,[dtmPostDate]
	,[ysnPosted]
	,[ysnPaid]
	,[strShipToLocationName]
	,[strShipToAddress]
	,[strShipToCity]
	,[strShipToState]
	,[strShipToZipCode]
	,[strShipToCountry]
	,[strBillToLocationName]
	,[strBillToAddress]
	,[strBillToCity]
	,[strBillToState]
	,[strBillToZipCode]
	,[strBillToCountry]
	,[intConcurrencyId]
	,[intEntityId])
SELECT
	[strInvoiceOriginId]	= NULL
	,[intCustomerId]		= A.[intEntityCustomerId] 
	,[dtmDate]				= @DateOnly
	,[dtmDueDate]			= @DateOnly
	,[intCurrencyId]		= ISNULL(A.[intCurrencyId], 0)
	,[intCompanyLocationId]	= ISNULL(A.[intLocationId], 0)
	,[intSalespersonId]		= ISNULL(C.[intSalespersonId], 0) 
	,[dtmShipDate]			= GETDATE()
	,[intShipViaId]			= ISNULL(EL.[intShipViaId], 0)
	,[strPONumber]			= ''
	,[intTermId]			= ISNULL(EL.[intTermsId], 0)
	,[dblInvoiceSubtotal]	= A.[dblOverpayment] 
	,[dblShipping]			= @ZeroDecimal
	,[dblTax]				= @ZeroDecimal
	,[dblInvoiceTotal]		= A.[dblOverpayment] 
	,[dblDiscount]			= @ZeroDecimal		
	,[dblAmountDue]			= A.[dblOverpayment] 
	,[dblPayment]			= @ZeroDecimal
	,[strTransactionType]	= 'Overpayment'
	,[intPaymentMethodId]	= ISNULL(A.[intPaymentMethodId], 0)
	,[strComments]			= A.strRecordNumber 
	,[intAccountId]			= ISNULL(CL.[intARAccount], 0) 
	,[dtmPostDate]			= NULL
	,[ysnPosted]			= 1
	,[ysnPaid]				= 0
	,[strShipToLocationName]= ISNULL(SL.[strLocationName], EL.[strLocationName])
	,[strShipToAddress]		= ISNULL(SL.[strAddress], EL.[strAddress])
	,[strShipToCity]		= ISNULL(SL.[strCity], EL.[strCity])
	,[strShipToState]		= ISNULL(SL.[strState], EL.[strState])
	,[strShipToZipCode]		= ISNULL(SL.[strZipCode], EL.[strZipCode])
	,[strShipToCountry]		= ISNULL(SL.[strCountry], EL.[strCountry])
	,[strBillToLocationName]= ISNULL(BL.[strLocationName], EL.[strLocationName])
	,[strBillToAddress]		= ISNULL(BL.[strAddress], EL.[strAddress])
	,[strBillToCity]		= ISNULL(BL.[strCity], EL.[strCity])
	,[strBillToState]		= ISNULL(BL.[strState], EL.[strState])
	,[strBillToZipCode]		= ISNULL(BL.[strZipCode], EL.[strZipCode])
	,[strBillToCountry]		= ISNULL(BL.[strCountry], EL.[strCountry])
	,[intConcurrencyId]		= 1
	,[intEntityId]			= 1
FROM
	[tblARPayment] A
INNER JOIN
	[tblARCustomer] C
		ON A.[intEntityCustomerId] = C.[intEntityCustomerId]
INNER JOIN
	[tblEntityLocation] EL
		ON C.[intDefaultLocationId] = EL.[intEntityLocationId] 
LEFT OUTER JOIN
	[tblEntityLocation] SL
		ON C.[intShipToId] = SL.[intEntityLocationId]  	
LEFT OUTER JOIN
	[tblEntityLocation] BL
		ON C.[intBillToId] = BL.[intEntityLocationId]  			
LEFT OUTER JOIN
	[tblSMCompanyLocation] CL
		ON A.[intLocationId] = CL.[intCompanyLocationId] 
WHERE 
	A.[intPaymentId] = @PaymentId 
	
	
DECLARE @NewId as int
SET @NewId = SCOPE_IDENTITY()
SET @NewInvoiceId = @NewId 

INSERT INTO [tblARInvoiceDetail]
	([intInvoiceId]
	,[intItemId]
	,[strItemDescription]
	,[intItemUOMId]
	,[dblQtyOrdered]
	,[dblQtyShipped]
	,[dblPrice]
	,[dblTotal]
	,[intAccountId]
	,[intCOGSAccountId]
	,[intSalesAccountId]
	,[intInventoryAccountId]
	,[intConcurrencyId])
SELECT
	intInvoiceId			= @NewId 
	,intItemId				= NULL
	,strItemDescription		= 'Overpayment for '+ A.strRecordNumber 
	,intItemUOMId			= NULL
	,dblQtyOrdered			= 1
	,dblQtyShipped			= 1
	,dblPrice				= A.[dblOverpayment]
	,dblTotal				= A.[dblOverpayment]
	,intAccountId			= ISNULL(CL.[intServiceCharges], 0)
	,intCOGSAccountId		= NULL
	,intSalesAccountId		= NULL
	,intInventoryAccountId	= NULL
	,intConcurrencyId		= 1
FROM
	[tblARPayment] A
INNER JOIN
	[tblARCustomer] C
		ON A.[intEntityCustomerId] = C.[intEntityCustomerId]
INNER JOIN
	[tblSMCompanyLocation] CL
		ON A.[intLocationId] = CL.[intCompanyLocationId] 
WHERE 
	A.[intPaymentId] = @PaymentId 
           
           
--IF @Post = 1
--	BEGIN
--		DECLARE	@return_value int,
--				@successfulCount int,
--				@invalidCount int,
--				@success bit

--		EXEC	@return_value = [dbo].[uspARPostInvoice]
--				@batchId = @BatchId,
--				@post = 1,
--				@recap = 0,
--				@param = @NewInvoiceId,
--				@userId = @UserId,
--				@beginDate = NULL,
--				@endDate = NULL,
--				@beginTransaction = NULL,
--				@endTransaction = NULL,
--				@exclude = NULL,
--				@successfulCount = @successfulCount OUTPUT,
--				@invalidCount = @invalidCount OUTPUT,
--				@success = @success OUTPUT,
--				@batchIdUsed = NULL,
--				@recapId = NULL,
--				@transType = N'Overpayment'
--	END           

           
RETURN @NewId

END