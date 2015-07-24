CREATE PROCEDURE [dbo].[uspARCreateCustomerInvoice]
	 @EntityCustomerId				INT
	,@InvoiceDate					DATETIME
	,@CompanyLocationId				INT
	,@EntityId						INT
	,@NewInvoiceId					INT				= NULL			OUTPUT 
	,@ShipDate						DATETIME		= NULL
	,@TransactionType				NVARCHAR(50)	= 'Invoice'
	,@Type							NVARCHAR(200)	= 'General'
	,@Comment						NVARCHAR(500)	= ''
	,@DistributionHeaderId			INT				= NULL
	,@PaymentMethodId				INT				= 0
	,@FreightTermId					INT				= NULL
	,@DeliverPickUp					NVARCHAR(100)	= NULL
	,@ItemId						INT				= NULL
	,@ItemUOMId						INT				= NULL
	,@ItemQtyShipped				NUMERIC(18,6)	= 0.000000
	,@ItemPrice						NUMERIC(18,6)	= 0.000000
	,@ItemDescription				NVARCHAR(500)	= NULL
	,@ItemSiteId					INT				= NULL												
	,@ItemBillingBy					NVARCHAR(200)	= NULL
	,@ItemPercentFull				NUMERIC(18,6)	= 0.000000
	,@ItemNewMeterReading			NUMERIC(18,6)	= 0.000000
	,@ItemPreviousMeterReading		NUMERIC(18,6)	= 0.000000
	,@ItemConversionFactor			NUMERIC(18,8)	= 0.00000000
	,@ItemPerformerId				INT				= NULL
	,@ItemLeaseBilling				BIT				= 0
	,@TaxMasterId					INT				= NULL
	,@ItemContractHeaderId			INT				= NULL
	,@ItemContractDetailId			INT				= NULL
	,@ItemMaintenanceType			NVARCHAR(50)	= NULL
	,@ItemFrequency					NVARCHAR(50)	= NULL
	,@ItemMaintenanceDate			DATETIME		= NULL
	,@ItemMaintenanceAmount			NUMERIC(18,6)	= 0.000000
	,@ItemLicenseAmount				NUMERIC(18,6)	= 0.000000		
	,@ItemTicketId					INT				= NULL		
	,@ItemSCInvoiceId				INT				= NULL
	,@ItemSCInvoiceNumber			NVARCHAR(50)	= NULL
	,@ItemServiceChargeAccountId	INT				= NULL
AS

BEGIN


SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ZeroDecimal NUMERIC(18, 6)
		,@DateOnly DATETIME
		,@Currency INT
		,@ARAccountId INT
		

SET @ZeroDecimal = 0.000000	
SET @Currency = ISNULL((SELECT strValue FROM tblSMPreferences WHERE strPreference = 'defaultCurrency'),0)
SET @ARAccountId = ISNULL((SELECT TOP 1 intARAccountId FROM tblARCompanyPreference WHERE intARAccountId IS NOT NULL AND intARAccountId <> 0),0)

IF @DeliverPickUp IS NULL OR LTRIM(RTRIM(@DeliverPickUp)) = ''
	SET @DeliverPickUp = ISNULL((SELECT TOP 1 strDeliverPickupDefault FROM tblSMCompanyLocation WHERE intCompanyLocationId = @CompanyLocationId),'')
	
IF @Comment IS NULL OR LTRIM(RTRIM(@Comment)) = ''
	SET @Comment = ISNULL((SELECT TOP 1 ISNULL(strInvoiceComments,'') FROM tblSMCompanyLocation WHERE intCompanyLocationId = @CompanyLocationId),'')

IF(@ARAccountId IS NULL OR @ARAccountId = 0)  
	BEGIN			
		RAISERROR('There is no setup for AR Account in the Company Preference.', 11, 1) 
		RETURN 0
	END		

INSERT INTO [tblARInvoice]
	([intEntityCustomerId]
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
	,[strType]
	,[intPaymentMethodId]
	,[strComments]
	,[intAccountId]
	,[dtmPostDate]
	,[ysnPosted]
	,[ysnPaid]
	,[ysnTemplate]
	,[ysnForgiven]
	,[ysnCalculated]
	,[intFreightTermId]
	,[strDeliverPickup]
	,[intShipToLocationId]
	,[strShipToLocationName]
	,[strShipToAddress]
	,[strShipToCity]
	,[strShipToState]
	,[strShipToZipCode]
	,[strShipToCountry]
	,[intBillToLocationId]
	,[strBillToLocationName]
	,[strBillToAddress]
	,[strBillToCity]
	,[strBillToState]
	,[strBillToZipCode]
	,[strBillToCountry]
	,[intDistributionHeaderId]
	,[intConcurrencyId]
	,[intEntityId])

SELECT			
	 [intEntityCustomerId]			= C.[intEntityCustomerId]
	,[dtmDate]						= CAST(@InvoiceDate AS DATE)
	,[dtmDueDate]					= CAST(dbo.fnGetDueDateBasedOnTerm(@InvoiceDate, ISNULL(EL.[intTermsId],0)) AS DATE) 
	,[intCurrencyId]				= ISNULL(C.[intCurrencyId], @Currency)
	,[intCompanyLocationId]			= @CompanyLocationId
	,[intEntitySalespersonId]		= C.[intSalespersonId]
	,[dtmShipDate]					= @ShipDate
	,[intShipViaId]					= EL.[intShipViaId]
	,[strPONumber]					= NULL
	,[intTermId]					= EL.[intTermsId]
	,[dblInvoiceSubtotal]			= @ZeroDecimal
	,[dblShipping]					= @ZeroDecimal
	,[dblTax]						= @ZeroDecimal
	,[dblInvoiceTotal]				= @ZeroDecimal
	,[dblDiscount]					= @ZeroDecimal
	,[dblAmountDue]					= @ZeroDecimal
	,[dblPayment]					= @ZeroDecimal
	,[strTransactionType]			= @TransactionType
	,[strType]						= @Type 
	,[intPaymentMethodId]			= @PaymentMethodId
	,[strComments]					= @Comment
	,[intAccountId]					= @ARAccountId
	,[dtmPostDate]					= NULL
	,[ysnPosted]					= 0
	,[ysnPaid]						= 0
	,[ysnTemplate]					= 0
	,[ysnForgiven]					= 0
	,[ysnCalculated]				= 0
	,[intFreightTermId]				= @FreightTermId
	,[strDeliverPickup]				= @DeliverPickUp
	,[intShipToLocationId]			= ISNULL(SL.[intEntityLocationId], EL.[intEntityLocationId])
	,[strShipToLocationName]		= ISNULL(SL.[strLocationName], EL.[strLocationName])
	,[strShipToAddress]				= ISNULL(SL.[strAddress], EL.[strAddress])
	,[strShipToCity]				= ISNULL(SL.[strCity], EL.[strCity])
	,[strShipToState]				= ISNULL(SL.[strState], EL.[strState])
	,[strShipToZipCode]				= ISNULL(SL.[strZipCode], EL.[strZipCode])
	,[strShipToCountry]				= ISNULL(SL.[strCountry], EL.[strCountry])
	,[intBillToLocationId]			= ISNULL(BL.[intEntityLocationId], EL.[intEntityLocationId])
	,[strBillToLocationName]		= ISNULL(BL.[strLocationName], EL.[strLocationName])
	,[strBillToAddress]				= ISNULL(BL.[strAddress], EL.[strAddress])
	,[strBillToCity]				= ISNULL(BL.[strCity], EL.[strCity])
	,[strBillToState]				= ISNULL(BL.[strState], EL.[strState])
	,[strBillToZipCode]				= ISNULL(BL.[strZipCode], EL.[strZipCode])
	,[strBillToCountry]				= ISNULL(BL.[strCountry], EL.[strCountry])
	,[intDistributionHeaderId]		= @DistributionHeaderId
	,[intConcurrencyId]				= 1
	,[intEntityId]					= @EntityId
FROM	
	tblARCustomer C
LEFT OUTER JOIN
				(	SELECT 
						 [intEntityLocationId]
						,[strLocationName]
						,[strAddress]
						,[intEntityId] 
						,[strCountry]
						,[strState]
						,[strCity]
						,[strZipCode]
						,[intTermsId]
						,[intShipViaId]
					FROM 
						tblEntityLocation
					WHERE
						ysnDefaultLocation = 1
				) EL
					ON C.[intEntityCustomerId] = EL.[intEntityId]
LEFT OUTER JOIN
	tblEntityLocation SL
		ON C.intShipToId = SL.intEntityLocationId
LEFT OUTER JOIN
	tblEntityLocation BL
		ON C.intShipToId = BL.intEntityLocationId
WHERE C.[intEntityCustomerId] = @EntityCustomerId


DECLARE @NewId INT
SET @NewId = SCOPE_IDENTITY()


IF EXISTS(SELECT NULL FROM tblARCustomer WHERE [intEntityCustomerId] = @EntityCustomerId AND [ysnPORequired] = 1)
	BEGIN
		DECLARE  @ShipToId	INT
				,@PONumber	NVARCHAR(200)
		SET @ShipToId = (SELECT [intShipToLocationId] FROM tblARInvoice WHERE intInvoiceId = @NewId)
		
		EXEC dbo.[uspARGetPONumber]  
			 @ShipToId  
			,@CompanyLocationId
			,@InvoiceDate
			,@PONumber OUT
			
		UPDATE
			tblARInvoice
		SET
			[strPONumber] = @PONumber
		WHERE
			[intInvoiceId] = @NewId
				
	END
	

IF ((@ItemId IS NOT NULL OR @ItemId <> 0) AND (@ItemPrice IS NULL OR @ItemPrice = @ZeroDecimal) )
	BEGIN
		EXEC dbo.[uspARGetItemPrice]  
				 @ItemId  
				,@EntityCustomerId
				,@CompanyLocationId
				,@ItemUOMId
				,@InvoiceDate
				,@ItemQtyShipped
				,@ItemPrice OUTPUT
	END	

INSERT INTO [tblARInvoiceDetail]
	([intInvoiceId]
	,[intItemId]
	,[strItemDescription]
	,[intSCInvoiceId]
	,[strSCInvoiceNumber]
	,[intItemUOMId]
	,[dblQtyOrdered]
	,[dblQtyShipped]
	,[dblDiscount]
	,[dblPrice]
	,[dblTotalTax]
	,[dblTotal]
	,[intAccountId]
	,[intCOGSAccountId]
	,[intSalesAccountId]
	,[intInventoryAccountId]
	,[intServiceChargeAccountId]
	,[intInventoryShipmentItemId]
	,[strShipmentNumber]
	,[intSalesOrderDetailId]
	,[strSalesOrderNumber]
	,[intSiteId]
	,[strBillingBy]
	,[dblPercentFull]
	,[dblNewMeterReading]
	,[dblPreviousMeterReading]
	,[dblConversionFactor]
	,[intPerformerId]
	,[intContractHeaderId]
	,[strMaintenanceType]
	,[strFrequency]
	,[dtmMaintenanceDate]
	,[dblMaintenanceAmount]
	,[dblLicenseAmount]
	,[intContractDetailId]
	,[intTicketId]
	,[ysnLeaseBilling]
	,[intConcurrencyId])
SELECT
	 [intInvoiceId]						= @NewId
	,[intItemId]						= IC.[intItemId] 
	,[strItemDescription]				= ISNULL(@ItemDescription, IC.[strDescription])
	,[intSCInvoiceId]					= @ItemSCInvoiceId
	,[strSCInvoiceNumber]				= @ItemSCInvoiceNumber 
	,[intItemUOMId]						= ISNULL(@ItemUOMId, IL.intIssueUOMId)
	,[dblQtyOrdered]					= ISNULL(@ItemQtyShipped, @ZeroDecimal)
	,[dblQtyShipped]					= ISNULL(@ItemQtyShipped, @ZeroDecimal)
	,[dblDiscount]						= @ZeroDecimal
	,[dblPrice]							= ISNULL(@ItemPrice, @ZeroDecimal)
	,[dblTotalTax]						= @ZeroDecimal
	,[dblTotal]							= @ZeroDecimal
	,[intAccountId]						= Acct.[intAccountId] 
	,[intCOGSAccountId]					= Acct.[intCOGSAccountId] 
	,[intSalesAccountId]				= Acct.[intSalesAccountId]
	,[intInventoryAccountId]			= Acct.[intInventoryAccountId]
	,[intServiceChargeAccountId]		= NULL
	,[intInventoryShipmentItemId]		= NULL
	,[strShipmentNumber]				= NULL
	,[intSalesOrderDetailId]			= NULL
	,[strSalesOrderNumber]				= NULL
	,[intSiteId]						= @ItemSiteId												
	,[strBillingBy]						= @ItemBillingBy		
	,[dblPercentFull]					= @ItemPercentFull
	,[dblNewMeterReading]				= @ItemNewMeterReading
	,[dblPreviousMeterReading]			= @ItemPreviousMeterReading
	,[dblConversionFactor]				= @ItemConversionFactor
	,[intPerformerId]					= @ItemPerformerId
	,[intContractHeaderId]				= @ItemContractHeaderId
	,[strMaintenanceType]				= @ItemMaintenanceType
	,[strFrequency]						= @ItemFrequency
	,[dtmMaintenanceDate]				= @ItemMaintenanceDate
	,[dblMaintenanceAmount]				= @ItemMaintenanceAmount
	,[dblLicenseAmount]					= @ItemLicenseAmount
	,[intContractDetailId]				= @ItemContractDetailId
	,[intTicketId]						= @ItemTicketId
	,[ysnLeaseBilling]					= @ItemLeaseBilling
	,1
FROM
	tblICItem IC
INNER JOIN
	tblICItemLocation IL
		ON IC.intItemId = IL.intItemId
LEFT OUTER JOIN
	vyuARGetItemAccount Acct
		ON IC.[intItemId] = Acct.[intItemId]
WHERE
	IC.[intItemId] = @ItemId
	AND IL.[intLocationId] = @CompanyLocationId
	
	
	
IF (@ItemId IS NOT NULL OR @ItemId <> 0)
	BEGIN
		EXEC dbo.[uspARReComputeInvoiceTaxes]  
				 @NewId  
				,@TaxMasterId
	END
	
EXEC [dbo].[uspARReComputeInvoiceAmounts] @NewId

SET @NewInvoiceId = @NewId
	
	
END