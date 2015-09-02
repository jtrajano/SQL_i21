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

DECLARE @ZeroDecimal decimal(18,6)
		,@DateOnly DATETIME
		,@Currency int
		,@ARAccountId int

SET @ZeroDecimal = 0.000000
	
SELECT @DateOnly = CAST(GETDATE() as date)

SET @Currency = ISNULL((SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference WHERE intDefaultCurrencyId IS NOT NULL AND intDefaultCurrencyId <> 0),0)
SET @ARAccountId = ISNULL((SELECT TOP 1 intARAccountId FROM tblARCompanyPreference WHERE intARAccountId IS NOT NULL AND intARAccountId <> 0),0)


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
	,''											--[strPONumber]
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
		ON C.intShipToId = BL.intEntityLocationId
WHERE
	S.[intInventoryShipmentId] = @ShipmentId		
		
		
DECLARE @NewId as int
SET @NewId = SCOPE_IDENTITY()
							

		
INSERT INTO [tblARInvoiceDetail]
	([intInvoiceId]
	,[intItemId]
	,[strItemDescription]
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
	,[intInventoryShipmentItemId]
	,[intSalesOrderDetailId]
	,[intSiteId]
	,[dblPercentFull]
	,[dblNewMeterReading]
	,[intPerformerId]
	,[intContractHeaderId]
    ,[intContractDetailId]
    ,[intTicketId] 
	,[intConcurrencyId])
           
SELECT 
	 @NewId									--[intInvoiceId]
	,SD.[intItemId]							--[intItemId]
	,SOD.[strItemDescription]				--[strItemDescription] 
	,SD.[intItemUOMId]						--[intItemUOMId]
	,SD.[dblQuantity]						--[dblQtyOrdered]
	,SD.[dblQuantity]						--[dblQtyShipped]
	,SOD.[dblDiscount]						--[dblDiscount] 
	,SD.[dblUnitPrice]						--[dblPrice]
	,SOD.[dblTotalTax]						--[dblTotalTax]
	,SOD.[dblTotal]							--[dblTotal]
	,SOD.[intAccountId]						--[intAccountId]
	,SOD.[intCOGSAccountId]					--[intCOGSAccountId]
	,SOD.[intSalesAccountId]				--[intSalesAccountId]
	,SOD.[intInventoryAccountId]			--[intInventoryAccountId]
	,SD.[intInventoryShipmentItemId]		--[intInventoryShipmentItemId]
	,SOD.[intSalesOrderDetailId]			--[intSalesOrderDetailId]
	,NULL									--[intSiteId]
	,@ZeroDecimal							--[dblPercentFull]
	,@ZeroDecimal							--[dblMeterReading]
	,NULL									--[intServicePerformerId]
	,SOD.[intContractHeaderId]				--[intContractHeaderId]
    ,SOD.[intContractDetailId]				--[intContractDetailId]
    ,(CASE WHEN HD.[intSourceType] = 1 THEN SD.intSourceId ELSE NULL END) --[intTicketId]
	,1		
FROM
	[tblICInventoryShipmentItem] SD
INNER JOIN
	[tblICInventoryShipment] HD
		ON SD.[intInventoryShipmentId] = HD.[intInventoryShipmentId]
		AND HD.[intOrderType] = 2 --Sales Order
LEFT OUTER JOIN
	[tblSOSalesOrderDetail] SOD
		ON SD.[intLineNo] = SOD.[intSalesOrderDetailId]
WHERE
	SD.[intInventoryShipmentId] = @ShipmentId
	
	
UNION ALL

SELECT 
	 @NewId									--[intInvoiceId]
	,SD.[intItemId]							--[intItemId]
	,COD.[strItemDescription]				--[strItemDescription] 
	,SD.[intItemUOMId]						--[intItemUOMId]
	,SD.[dblQuantity]						--[dblQtyOrdered]
	,SD.[dblQuantity]						--[dblQtyShipped]
	,@ZeroDecimal							--[dblDiscount] 
	,SD.[dblUnitPrice]						--[dblPrice]
	,@ZeroDecimal							--[dblTotalTax]
	,SD.[dblQuantity] * SD.[dblUnitPrice]	--[dblTotal]
	,ACCT.[intAccountId]					--[intAccountId]
	,ACCT.[intCOGSAccountId]				--[intCOGSAccountId]
	,ACCT.[intSalesAccountId]				--[intSalesAccountId]
	,ACCT.[intInventoryAccountId]			--[intInventoryAccountId]
	,SD.[intInventoryShipmentItemId]		--[intInventoryShipmentItemId]
	,NULL									--[intSalesOrderDetailId]
	,NULL									--[intSiteId]
	,@ZeroDecimal							--[dblPercentFull]
	,@ZeroDecimal							--[dblMeterReading]
	,NULL									--[intServicePerformerId]
	,COD.[intContractHeaderId]				--[intContractHeaderId]
    ,COD.[intContractDetailId]				--[intContractDetailId]
    ,(CASE WHEN HD.[intSourceType] = 1 THEN SD.intSourceId ELSE NULL END) --[intTicketId]
	,1		
FROM
	[tblICInventoryShipmentItem] SD
INNER JOIN
	[tblICInventoryShipment] HD
		ON SD.[intInventoryShipmentId] = HD.[intInventoryShipmentId]
		AND HD.[intOrderType] = 1 --Sales Contract		
LEFT OUTER JOIN
	[vyuCTContractDetailView] COD
		ON SD.[intOrderId] = COD.[intContractHeaderId]
		AND SD.[intLineNo] = COD.[intContractDetailId] 
LEFT OUTER JOIN
	[vyuARGetItemAccount] ACCT
		ON SD.intItemId = ACCT.[intItemId]
		AND HD.[intShipFromLocationId] = ACCT.[intLocationId] 
WHERE
	SD.[intInventoryShipmentId] = @ShipmentId

UNION ALL	
	
SELECT 
	 @NewId									--[intInvoiceId]
	,SD.[intItemId]							--[intItemId]
	,I.[strDescription]						--[strItemDescription]  
	,SD.[intItemUOMId]						--[intItemUOMId]
	,SD.[dblQuantity]						--[dblQtyOrdered]
	,SD.[dblQuantity]						--[dblQtyShipped]
	,@ZeroDecimal							--[dblDiscount] 
	,SD.[dblUnitPrice]						--[dblPrice]
	,@ZeroDecimal							--[dblTotalTax]
	,SD.[dblQuantity] * SD.[dblUnitPrice]	--[dblTotal]
	,ACCT.[intAccountId]					--[intAccountId]
	,ACCT.[intCOGSAccountId]				--[intCOGSAccountId]
	,ACCT.[intSalesAccountId]				--[intSalesAccountId]
	,ACCT.[intInventoryAccountId]			--[intInventoryAccountId]
	,SD.[intInventoryShipmentItemId]		--[intInventoryShipmentItemId]
	,NULL									--[intSalesOrderDetailId]
	,NULL									--[intSiteId]
	,@ZeroDecimal							--[dblPercentFull]
	,@ZeroDecimal							--[dblMeterReading]
	,NULL									--[intServicePerformerId]
	,NULL									--[intContractHeaderId]
    ,NULL									--[intContractDetailId]
    ,(CASE WHEN HD.[intSourceType] = 1 THEN SD.intSourceId ELSE NULL END) --[intTicketId]
	,1		
FROM
	[tblICInventoryShipmentItem] SD
INNER JOIN
	[tblICInventoryShipment] HD
		ON SD.[intInventoryShipmentId] = HD.[intInventoryShipmentId]
		AND HD.[intOrderType] IN (3,4) --Transfer Order & Direct
INNER JOIN
	[tblICItem]	I
		ON SD.[intItemId] = I.[intItemId] 
LEFT OUTER JOIN
	[vyuARGetItemAccount] ACCT
		ON SD.intItemId = ACCT.[intItemId]
		AND HD.[intShipFromLocationId] = ACCT.[intLocationId] 
WHERE
	SD.[intInventoryShipmentId] = @ShipmentId

		
EXEC [dbo].[uspARReComputeInvoiceTaxes] @NewId

SET @NewInvoiceId = @NewId 

         
RETURN 1

END