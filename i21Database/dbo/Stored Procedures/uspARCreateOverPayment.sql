﻿CREATE PROCEDURE [dbo].[uspARCreateOverPayment]
	  @PaymentId	AS INT
	, @Post			AS BIT			= 1
	, @BatchId		AS NVARCHAR(20)	= NULL
	, @UserId		AS INT			= 1
	, @NewInvoiceId	AS INT			= NULL OUTPUT			
AS

BEGIN


SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ZeroDecimal DECIMAL(18,6)
	  , @ARAccountId INT

SET @ZeroDecimal = 0.000000
SET @ARAccountId = (SELECT TOP 1 intARAccountId FROM tblARCompanyPreference WHERE intARAccountId IS NOT NULL AND intARAccountId <> 0)

IF @ARAccountId IS NULL OR @ARAccountId = 0
	BEGIN
		RAISERROR('There is no setup for AR Account in the Company Configuration.', 16, 1);
		RETURN;
	END

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
	,[intPaymentId]
	,[intConcurrencyId]
	,[intEntityId])
SELECT
	[strInvoiceOriginId]	= NULL
	,[intCustomerId]		= A.[intEntityCustomerId] 
	,[dtmDate]				= A.dtmDatePaid
	,[dtmDueDate]			= A.dtmDatePaid
	,[intCurrencyId]		= ISNULL(A.[intCurrencyId], 0)
	,[intCompanyLocationId]	= ISNULL(A.[intLocationId], 0)
	,[intSalespersonId]		= ISNULL(C.[intSalespersonId], 0) 
	,[dtmShipDate]			= A.dtmDatePaid
	,[intShipViaId]			= ISNULL(EL.[intShipViaId], 0)
	,[strPONumber]			= ''
	,[intTermId]			= ISNULL(EL.[intTermsId], 0)
	,[dblInvoiceSubtotal]	= A.[dblOverpayment] 
	,[dblShipping]			= @ZeroDecimal
	,[dblTax]				= @ZeroDecimal
	,[dblInvoiceTotal]		= A.[dblUnappliedAmount] 
	,[dblDiscount]			= @ZeroDecimal		
	,[dblAmountDue]			= A.[dblOverpayment] 
	,[dblPayment]			= @ZeroDecimal
	,[strTransactionType]	= 'Overpayment'
	,[intPaymentMethodId]	= ISNULL(A.[intPaymentMethodId], 0)
	,[strComments]			= A.strRecordNumber 
	,[intAccountId]			= @ARAccountId 
	,[dtmPostDate]			= A.dtmDatePaid
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
	,[intPaymentId]			= A.intPaymentId		
	,[intConcurrencyId]		= 1
	,[intEntityId]			= 1
FROM
	[tblARPayment] A
INNER JOIN
	[tblARCustomer] C
		ON A.[intEntityCustomerId] = C.[intEntityCustomerId]
INNER JOIN
	(	SELECT
			[intEntityLocationId]
			,[intEntityId]
			,[strLocationName]
			,[strAddress]
			,[strCity]
			,[strState]
			,[strZipCode]
			,[strCountry]
			,[intShipViaId]
			,[intTermsId]
		FROM 
			tblEntityLocation
		WHERE
			ysnDefaultLocation = 1
	) EL
		ON C.[intEntityCustomerId] = EL.[intEntityId] 
LEFT OUTER JOIN
	[tblEntityLocation] SL
		ON C.[intShipToId] = SL.[intEntityLocationId]  	
LEFT OUTER JOIN
	[tblEntityLocation] BL
		ON C.[intBillToId] = BL.[intEntityLocationId]  			
WHERE 
	A.[intPaymentId] = @PaymentId 
	
	
DECLARE @NewId AS INT
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
	,dblPrice				= A.[dblUnappliedAmount]
	,dblTotal				= A.[dblUnappliedAmount]
	,intAccountId			= NULL
	,intCOGSAccountId		= NULL
	,intSalesAccountId		= NULL
	,intInventoryAccountId	= NULL
	,intConcurrencyId		= 1
FROM
	[tblARPayment] A
INNER JOIN
	[tblARCustomer] C
		ON A.[intEntityCustomerId] = C.[intEntityCustomerId]
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