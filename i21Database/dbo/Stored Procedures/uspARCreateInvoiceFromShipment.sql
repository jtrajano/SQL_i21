CREATE PROCEDURE [dbo].[uspARCreateInvoiceFromShipment]
	 @ShipmentId		AS INT
	,@UserId			AS INT
	,@NewInvoiceId		AS INT			= NULL OUTPUT			
AS

BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ZeroDecimal		DECIMAL(18,6)
		,@DateOnly			DATETIME
		,@Currency			INT
		,@ARAccountId		INT
		,@ShipmentNumber	NVARCHAR(100)

SET @ZeroDecimal = 0.000000
	
SELECT @DateOnly = CAST(GETDATE() as date)

SET @Currency = ISNULL((SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference WHERE intDefaultCurrencyId IS NOT NULL AND intDefaultCurrencyId <> 0),0)
SET @ARAccountId = ISNULL((SELECT TOP 1 intARAccountId FROM tblARCompanyPreference WHERE intARAccountId IS NOT NULL AND intARAccountId <> 0),0)

SELECT @ShipmentNumber = [strShipmentNumber] FROM tblICInventoryShipment WHERE [intInventoryShipmentId] = @ShipmentId


IF(@ARAccountId IS NULL OR @ARAccountId = 0)  
	BEGIN			
		RAISERROR('There is no setup for AR Account in the Company Preference.', 11, 1) 
		RETURN 0
	END


INSERT INTO  [tblARInvoice]
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
	,[strType]
	,[intPaymentMethodId]
	,[intSplitId]
	,[strComments]
	,[intAccountId]
	,[dtmPostDate]
	,[ysnPosted]
	,[ysnPaid]
	,[intFreightTermId]
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
	,[intConcurrencyId]
	,[intEntityId])

SELECT 
	 NULL										--[strInvoiceOriginId]	 
	,S.[intEntityCustomerId]					--[intEntityCustomerId]
	,@DateOnly									--[dtmDate]
	,dbo.fnGetDueDateBasedOnTerm(@DateOnly, ISNULL(EL.[intTermsId],0))		--[dtmDueDate]
	,ISNULL(C.[intCurrencyId], @Currency)		--[intCurrencyId]
	,S.[intShipFromLocationId]					--[intCompanyLocationId]
	,C.[intSalespersonId]						--[intEntitySalespersonId]
	,S.[dtmShipDate]							--[dtmShipDate]
	,S.[intShipViaId]							--[intShipViaId]
	,SO.[strPONumber]							--[strPONumber]
	,EL.[intTermsId]							--[intTermId]
	,@ZeroDecimal								--[dblInvoiceSubtotal]
	,@ZeroDecimal								--[dblShipping]
	,@ZeroDecimal								--[dblTax]
	,@ZeroDecimal								--[dblInvoiceTotal]
	,@ZeroDecimal								--[dblDiscount]
	,@ZeroDecimal								--[dblAmountDue]
	,@ZeroDecimal								--[dblPayment]
	,'Invoice'									--[strTransactionType]
	,'Standard'									--[strType]
	,0											--[intPaymentMethodId]
	,SO.intSplitId
	,S.[strShipmentNumber] + ' : '	+ S.[strReferenceNumber]				--[strComments]
	,@ARAccountId								--[intAccountId]
	,NULL										--[dtmPostDate]
	,0											--[ysnPosted]
	,0											--[ysnPaid]
	,S.[intFreightTermId]						--[intFreightTermId]
	,S.[intShipToLocationId]					--[intShipToLocationId] 
	,SL.[strLocationName]						--[strShipToLocationName]
	,SL.[strAddress]							--[strShipToAddress]
	,SL.[strCity]								--[strShipToCity]
	,SL.[strState]								--[strShipToState]
	,SL.[strZipCode]							--[strShipToZipCode]
	,SL.[strCountry]							--[strShipToCountry]
	,ISNULL(C.[intBillToId], EL.[intEntityLocationId])						--[intBillToLocationId] 
	,BL.[strLocationName]						--[strBillToLocationName]
	,BL.[strAddress]							--[strBillToAddress]
	,BL.[strCity]								--[strBillToCity]
	,BL.[strState]								--[strBillToState]
	,BL.[strZipCode]							--[strBillToZipCode]
	,BL.[strCountry]							--[strBillToCountry]
	,1
	,@UserId
FROM 
	[tblICInventoryShipment] S
INNER JOIN
	[tblARCustomer] C
		ON S.[intEntityCustomerId] = C.[intEntityCustomerId] 
LEFT OUTER JOIN
				(	SELECT
						[intEntityLocationId]
						,[intEntityId] 
						,[strCountry]
						,[strState]
						,[strCity]
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
		ON S.[intShipToLocationId] = SL.intEntityLocationId
LEFT OUTER JOIN
	tblEntityLocation BL
		ON C.[intBillToId] = BL.intEntityLocationId
LEFT OUTER JOIN
	tblSOSalesOrder SO
		ON S.strReferenceNumber = SO.strSalesOrderNumber
WHERE
	S.[intInventoryShipmentId] = @ShipmentId		
		
		
DECLARE @NewId as int
SET @NewId = SCOPE_IDENTITY()
							
		
INSERT INTO [tblARInvoiceDetail]
	([intInvoiceId]
	,[strDocumentNumber]
	,[intItemId]
	,[strItemDescription]
	,[dblQtyOrdered]
	,[intOrderUOMId]
	,[dblQtyShipped]
	,[intItemUOMId]
	,[dblDiscount]
	,[dblItemTermDiscount]
	,[dblPrice]
	,[strPricing]
	,[dblTotalTax]
	,[dblTotal]
	,[intAccountId]
	,[intCOGSAccountId]
	,[intSalesAccountId]
	,[intInventoryAccountId]
	,[intServiceChargeAccountId]
	,[strMaintenanceType]
	,[strFrequency]
	,[dtmMaintenanceDate]
	,[dblMaintenanceAmount]
	,[dblLicenseAmount]
	,[intTaxGroupId]
	,[intSCInvoiceId]
	,[intSCBudgetId]
	,[strSCInvoiceNumber]
	,[strSCBudgetDescription]
	,[intInventoryShipmentItemId]
	,[strShipmentNumber]
	,[intSalesOrderDetailId]
	,[strSalesOrderNumber]
	,[intContractHeaderId]
	,[intContractDetailId]
	,[intShipmentId]
	,[intShipmentPurchaseSalesContractId]
	,[intItemWeightUOMId]
	,[dblItemWeight]
	,[dblShipmentGrossWt]
	,[dblShipmentTareWt]
	,[dblShipmentNetWt]
	,[intTicketId]
	,[intTicketHoursWorkedId]
	,[intOriginalInvoiceDetailId]
	,[intEntitySalespersonId]
	,[intSiteId]
	,[strBillingBy]
	,[dblPercentFull]
	,[dblNewMeterReading]
	,[dblPreviousMeterReading]
	,[dblConversionFactor]
	,[intPerformerId]
	,[ysnLeaseBilling]
	,[ysnVirtualMeterReading]
	,[intConcurrencyId])
SELECT 
	 [intInvoiceId]							= @NewId
	,[strDocumentNumber]					= ARSI.[strTransactionNumber] 
	,[intItemId]							= ARSI.[intItemId] 
	,[strItemDescription]					= ARSI.[strItemDescription] 
	,[dblQtyOrdered]						= ARSI.[dblQtyOrdered] 
	,[intOrderUOMId]						= ARSI.[intOrderUOMId] 
	,[dblQtyShipped]						= ARSI.[dblShipmentQuantity] 
	,[intItemUOMId]							= ARSI.[intShipmentItemUOMId] 
	,[dblDiscount]							= ARSI.[dblDiscount]
	,[dblItemTermDiscount]					= @ZeroDecimal 
	,[dblPrice]								= ARSI.[dblShipmentUnitPrice] 
	,[strPricing]							= 'Inventory Shipment'
	,[dblTotalTax]							= ARSI.[dblTotalTax] 
	,[dblTotal]								= ARSI.[dblTotal] 
	,[intAccountId]							= ARSI.[intAccountId] 
	,[intCOGSAccountId]						= ARSI.[intCOGSAccountId]
	,[intSalesAccountId]					= ARSI.[intSalesAccountId]
	,[intInventoryAccountId]				= ARSI.[intInventoryAccountId]
	,[intServiceChargeAccountId]			= NULL
	,[strMaintenanceType]					= ''
	,[strFrequency]							= ''
	,[dtmMaintenanceDate]					= NULL
	,[dblMaintenanceAmount]					= @ZeroDecimal 
	,[dblLicenseAmount]						= @ZeroDecimal
	,[intTaxGroupId]						= ARSI.[intTaxGroupId] 
	,[intSCInvoiceId]						= NULL
	,[intSCBudgetId]						= NULL
	,[strSCInvoiceNumber]					= ''
	,[strSCBudgetDescription]				= ''
	,[intInventoryShipmentItemId]			= ARSI.[intInventoryShipmentItemId] 
	,[strShipmentNumber]					= ARSI.[strTransactionNumber] 
	,[intSalesOrderDetailId]				= ARSI.[intSalesOrderDetailId] 
	,[strSalesOrderNumber]					= ARSI.[strSalesOrderNumber] 
	,[intContractHeaderId]					= ARSI.[intContractHeaderId] 
	,[intContractDetailId]					= ARSI.[intContractDetailId] 
	,[intShipmentId]						= ARSI.[intShipmentId] 	
	,[intShipmentPurchaseSalesContractId]	= NULL
	,[intItemWeightUOMId]					= ARSI.[intWeightUOMId] 
	,[dblItemWeight]						= ARSI.[dblWeight] 
	,[dblShipmentGrossWt]					= ARSI.[dblGrossWt] 
	,[dblShipmentTareWt]					= ARSI.[dblTareWt] 
	,[dblShipmentNetWt]						= ARSI.[dblNetWt] 
	,[intTicketId]							= ARSI.[intTicketId] 
	,[intTicketHoursWorkedId]				= NULL
	,[intOriginalInvoiceDetailId]			= NULL
	,[intEntitySalespersonId]				= NULL
	,[intSiteId]							= NULL
	,[strBillingBy]							= ''
	,[dblPercentFull]						= @ZeroDecimal 
	,[dblNewMeterReading]					= @ZeroDecimal 
	,[dblPreviousMeterReading]				= @ZeroDecimal 
	,[dblConversionFactor]					= @ZeroDecimal 
	,[intPerformerId]						= NULL
	,[ysnLeaseBilling]						= 0
	,[ysnVirtualMeterReading]				= 0	
	,[intConcurrencyId]						= 1
FROM
	vyuARShippedItems ARSI
WHERE
	ARSI.[strTransactionType] = 'Inventory Shipment'
	AND ARSI.[strTransactionNumber] = @ShipmentNumber
	
		
EXEC [dbo].[uspARReComputeInvoiceTaxes] @NewId


IF ISNULL(@NewId, 0) <> 0
	BEGIN
		DECLARE @InvoiceNumber NVARCHAR(250)
				,@SourceScreen NVARCHAR(250)
		SELECT @InvoiceNumber = strInvoiceNumber FROM tblARInvoice WHERE intInvoiceId = @NewId
		SET	@SourceScreen = 'Inventory Shipment to Invoice'
		EXEC dbo.uspSMAuditLog 
			 @keyValue			= @NewId						-- Primary Key Value of the Invoice. 
			,@screenName		= 'AccountsReceivable.view.Invoice'	-- Screen Namespace
			,@entityId			= @UserId							-- Entity Id.
			,@actionType		= 'Processed'						-- Action Type
			,@changeDescription	= @SourceScreen						-- Description
			,@fromValue			= @ShipmentNumber					-- Previous Value
			,@toValue			= @InvoiceNumber					-- New Value	
	END	

SET @NewInvoiceId = @NewId 

         
RETURN 1

END