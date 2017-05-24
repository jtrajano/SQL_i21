CREATE PROCEDURE [dbo].[uspARCreateCustomerInvoices]
	 @InvoiceEntries	InvoiceStagingTable	READONLY
	,@IntegrationLogId	INT					= NULL
	,@GroupingOption	INT					= 0
	,@UserId			INT
	,@RaiseError		BIT					= 0
	,@ErrorMessage		NVARCHAR(250)		= NULL	OUTPUT
AS

BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ZeroDecimal NUMERIC(18, 6) = 0.000000
		,@DateOnly DATETIME = CAST(GETDATE() AS DATE)

DECLARE @InvoicesToGenerate AS InvoiceStagingTable
DELETE FROM @InvoicesToGenerate
INSERT INTO @InvoicesToGenerate (
	 [intId]
	,[strTransactionType]
	,[strType]
	,[strSourceTransaction]
	,[intSourceId]
	,[strSourceId]
	,[intInvoiceId]
	,[intEntityCustomerId]
	,[intEntityContactId]
	,[intCompanyLocationId]
	,[intAccountId]
	,[intCurrencyId]
	,[intTermId]
	,[intPeriodsToAccrue]
	,[dtmDate]
	,[dtmDueDate]
	,[dtmShipDate]
	,[dtmPostDate]
	,[intEntitySalespersonId]
	,[intFreightTermId]
	,[intShipViaId]
	,[intPaymentMethodId]
	,[strInvoiceOriginId]
	,[ysnUseOriginIdAsInvoiceNumber]
	,[strPONumber]
	,[strBOLNumber]
	,[strDeliverPickup]
	,[strComments]
	,[intShipToLocationId]
	,[intBillToLocationId]
	,[ysnTemplate]
	,[ysnForgiven]
	,[ysnCalculated]
	,[ysnSplitted]
	,[intPaymentId]
	,[intSplitId]
	,[intLoadDistributionHeaderId]
	,[strActualCostId]
	,[intShipmentId]
	,[intTransactionId]
	,[intMeterReadingId]
	,[intContractHeaderId]
	,[intLoadId]
	,[intOriginalInvoiceId]
	,[intEntityId]
	,[intTruckDriverId]
	,[intTruckDriverReferenceId]
	,[ysnResetDetails]
	,[ysnRecap]
	,[ysnPost]
	,[ysnUpdateAvailableDiscount]
	,[intInvoiceDetailId]
    ,[intItemId]
	,[intPrepayTypeId]
	,[dblPrepayRate]
    ,[ysnInventory]
	,[strDocumentNumber]
    ,[strItemDescription]
	,[intOrderUOMId]
    ,[dblQtyOrdered]
	,[intItemUOMId]
    ,[dblQtyShipped]
	,[dblDiscount]
	,[dblItemTermDiscount]
	,[strItemTermDiscountBy]
	,[dblItemWeight]
	,[intItemWeightUOMId]
    ,[dblPrice]
    ,[strPricing]
	,[strVFDDocumentNumber]
    ,[ysnRefreshPrice]
	,[strMaintenanceType]
    ,[strFrequency]
    ,[dtmMaintenanceDate]
    ,[dblMaintenanceAmount]
    ,[dblLicenseAmount]
	,[intTaxGroupId]
	,[intStorageLocationId]
	,[intCompanyLocationSubLocationId]
	,[ysnRecomputeTax]
	,[intSCInvoiceId]
	,[strSCInvoiceNumber]
	,[intSCBudgetId]
	,[strSCBudgetDescription]
	,[intInventoryShipmentItemId]
	,[intInventoryShipmentChargeId]
	,[strShipmentNumber]
	,[intRecipeItemId]
	,[intRecipeId]
	,[intSubLocationId]
	,[intCostTypeId]
	,[intMarginById]
	,[intCommentTypeId]
	,[dblMargin]
	,[dblRecipeQuantity]
	,[intSalesOrderDetailId]
	,[strSalesOrderNumber]
	,[intContractDetailId]
	,[intShipmentPurchaseSalesContractId]
	,[dblShipmentGrossWt]
	,[dblShipmentTareWt]
	,[dblShipmentNetWt]
	,[intTicketId]
	,[intTicketHoursWorkedId]
	,[intDocumentMaintenanceId]
	,[intCustomerStorageId]
	,[intSiteDetailId]
	,[intLoadDetailId]
	,[intLotId]
	,[intOriginalInvoiceDetailId]
	,[intSiteId]
	,[strBillingBy]
	,[dblPercentFull]
	,[dblNewMeterReading]
	,[dblPreviousMeterReading]
	,[dblConversionFactor]
	,[intPerformerId]
	,[ysnLeaseBilling]
	,[ysnVirtualMeterReading]
	,[ysnClearDetailTaxes]
	,[intTempDetailIdForTaxes]
	,[intCurrencyExchangeRateTypeId]
	,[intCurrencyExchangeRateId]
	,[dblCurrencyExchangeRate]
	,[intSubCurrencyId]
	,[dblSubCurrencyRate]
	,[ysnBlended]
	,[strImportFormat]
	,[dblCOGSAmount]
    ,[intConversionAccountId]
	,[intSalesAccountId]
	,[intStorageScheduleTypeId]
	,[intDestinationGradeId]
	,[intDestinationWeightId]
)
SELECT
	 [intId]							= [intId]
	,[strTransactionType]				= [strTransactionType]
	,[strType]							= [strType]
	,[strSourceTransaction]				= [strSourceTransaction]
	,[intSourceId]						= [intSourceId]
	,[strSourceId]						= [strSourceId]
	,[intInvoiceId]						= [intInvoiceId]
	,[intEntityCustomerId]				= [intEntityCustomerId]
	,[intEntityContactId]				= [intEntityContactId]
	,[intCompanyLocationId]				= [intCompanyLocationId]
	,[intAccountId]						= [intAccountId]
	,[intCurrencyId]					= [intCurrencyId]
	,[intTermId]						= [intTermId]
	,[intPeriodsToAccrue]				= [intPeriodsToAccrue]
	,[dtmDate]							= [dtmDate]
	,[dtmDueDate]						= [dtmDueDate]
	,[dtmShipDate]						= [dtmShipDate]
	,[dtmPostDate]						= [dtmPostDate]
	,[intEntitySalespersonId]			= [intEntitySalespersonId]
	,[intFreightTermId]					= [intFreightTermId]
	,[intShipViaId]						= [intShipViaId]
	,[intPaymentMethodId]				= [intPaymentMethodId]
	,[strInvoiceOriginId]				= [strInvoiceOriginId]
	,[ysnUseOriginIdAsInvoiceNumber]	= [ysnUseOriginIdAsInvoiceNumber]
	,[strPONumber]						= [strPONumber]
	,[strBOLNumber]						= [strBOLNumber]
	,[strDeliverPickup]					= [strDeliverPickup]
	,[strComments]						= [strComments]
	,[intShipToLocationId]				= [intShipToLocationId]
	,[intBillToLocationId]				= [intBillToLocationId]
	,[ysnTemplate]						= [ysnTemplate]
	,[ysnForgiven]						= [ysnForgiven]
	,[ysnCalculated]					= [ysnCalculated]
	,[ysnSplitted]						= [ysnSplitted]
	,[intPaymentId]						= [intPaymentId]
	,[intSplitId]						= [intSplitId]
	,[intLoadDistributionHeaderId]		= (CASE WHEN ISNULL([strSourceTransaction],'') = 'Transport Load' THEN ISNULL([intLoadDistributionHeaderId], [intSourceId]) ELSE NULL END)
	,[strActualCostId]					= (CASE WHEN ISNULL([strSourceTransaction],'') = 'Transport Load' THEN [strActualCostId] ELSE NULL END)
	,[intShipmentId]					= (CASE WHEN ISNULL([strSourceTransaction],'') = 'Inbound Shipment' THEN ISNULL([intShipmentId], [intSourceId]) ELSE NULL END)
	,[intTransactionId] 				= (CASE WHEN ISNULL([strSourceTransaction],'') IN ('Card Fueling Transaction', 'CF Tran') THEN ISNULL([intTransactionId], [intSourceId]) ELSE NULL END)
	,[intMeterReadingId]				= (CASE WHEN ISNULL([strSourceTransaction],'') = 'Meter Billing' THEN ISNULL([intMeterReadingId], [intSourceId]) ELSE NULL END)
	,[intContractHeaderId]				= (CASE WHEN ISNULL([strSourceTransaction],'') = 'Sales Contract' THEN ISNULL([intContractHeaderId], [intSourceId]) ELSE NULL END)
	,[intLoadId]						= (CASE WHEN ISNULL([strSourceTransaction],'') = 'Load Schedule' THEN ISNULL([intLoadId], [intSourceId]) ELSE NULL END)
	,[intOriginalInvoiceId]				= (CASE WHEN ISNULL([strSourceTransaction],'') = 'Provisional' THEN ISNULL([intOriginalInvoiceId], [intSourceId]) ELSE NULL END)
	,[intEntityId]						= [intEntityId]
	,[intTruckDriverId]					= [intTruckDriverId]
	,[intTruckDriverReferenceId]		= [intTruckDriverReferenceId]
	,[ysnResetDetails]					= [ysnResetDetails]
	,[ysnRecap]							= [ysnRecap]
	,[ysnPost]							= [ysnPost]
	,[ysnUpdateAvailableDiscount]		= [ysnUpdateAvailableDiscount]
	,[intInvoiceDetailId]				= [intInvoiceDetailId]
    ,[intItemId]						= [intItemId]
	,[intPrepayTypeId]					= [intPrepayTypeId]
	,[dblPrepayRate]					= [dblPrepayRate]
    ,[ysnInventory]						= [ysnInventory]
	,[strDocumentNumber]				= [strDocumentNumber]
    ,[strItemDescription]				= [strItemDescription]
	,[intOrderUOMId]					= [intOrderUOMId]
    ,[dblQtyOrdered]					= [dblQtyOrdered]
	,[intItemUOMId]
    ,[dblQtyShipped]
	,[dblDiscount]
	,[dblItemTermDiscount]
	,[strItemTermDiscountBy]
	,[dblItemWeight]
	,[intItemWeightUOMId]
    ,[dblPrice]
    ,[strPricing]
	,[strVFDDocumentNumber]
    ,[ysnRefreshPrice]
	,[strMaintenanceType]
    ,[strFrequency]
    ,[dtmMaintenanceDate]
    ,[dblMaintenanceAmount]
    ,[dblLicenseAmount]
	,[intTaxGroupId]
	,[intStorageLocationId]
	,[intCompanyLocationSubLocationId]
	,[ysnRecomputeTax]
	,[intSCInvoiceId]
	,[strSCInvoiceNumber]
	,[intSCBudgetId]
	,[strSCBudgetDescription]
	,[intInventoryShipmentItemId]
	,[intInventoryShipmentChargeId]
	,[strShipmentNumber]
	,[intRecipeItemId]
	,[intRecipeId]
	,[intSubLocationId]
	,[intCostTypeId]
	,[intMarginById]
	,[intCommentTypeId]
	,[dblMargin]
	,[dblRecipeQuantity]
	,[intSalesOrderDetailId]
	,[strSalesOrderNumber]
	,[intContractDetailId]
	,[intShipmentPurchaseSalesContractId]
	,[dblShipmentGrossWt]
	,[dblShipmentTareWt]
	,[dblShipmentNetWt]
	,[intTicketId]
	,[intTicketHoursWorkedId]
	,[intDocumentMaintenanceId]
	,[intCustomerStorageId]
	,[intSiteDetailId]
	,[intLoadDetailId]
	,[intLotId]
	,[intOriginalInvoiceDetailId]
	,[intSiteId]
	,[strBillingBy]
	,[dblPercentFull]
	,[dblNewMeterReading]
	,[dblPreviousMeterReading]
	,[dblConversionFactor]
	,[intPerformerId]
	,[ysnLeaseBilling]
	,[ysnVirtualMeterReading]
	,[ysnClearDetailTaxes]
	,[intTempDetailIdForTaxes]
	,[intCurrencyExchangeRateTypeId]
	,[intCurrencyExchangeRateId]
	,[dblCurrencyExchangeRate]
	,[intSubCurrencyId]
	,[dblSubCurrencyRate]
	,[ysnBlended]
	,[strImportFormat]
	,[dblCOGSAmount]
    ,[intConversionAccountId]
	,[intSalesAccountId]
	,[intStorageScheduleTypeId]
	,[intDestinationGradeId]
	,[intDestinationWeightId]
FROM
	@InvoiceEntries 


DECLARE @InvalidRecords AS TABLE (
	 [intId]				INT
	,[strErrorMessage]		NVARCHAR(500)	COLLATE Latin1_General_CI_AS	NULL
	,[strTransactionType]	NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
	,[strType]				NVARCHAR(100)	COLLATE Latin1_General_CI_AS	NULL
	,[strSourceTransaction]	NVARCHAR(250)	COLLATE Latin1_General_CI_AS	NOT NULL
	,[intSourceId]			INT												NULL
	,[strSourceId]			NVARCHAR(250)	COLLATE Latin1_General_CI_AS	NOT NULL
	,[intInvoiceId]			INT												NULL
)

INSERT INTO @InvalidRecords(
	 [intId]
	,[strErrorMessage]		
	,[strTransactionType]
	,[strType]
	,[strSourceTransaction]
	,[intSourceId]
	,[strSourceId]
	,[intInvoiceId]
)
SELECT
	 [intId]				= ITG.[intId]
	,[strErrorMessage]		= ITG.[strSourceTransaction] + ' does not exists!'
	,[strTransactionType]	= ITG.[strTransactionType]
	,[strType]				= ITG.[strType]
	,[strSourceTransaction]	= ITG.[strSourceTransaction]
	,[intSourceId]			= ITG.[intSourceId]
	,[strSourceId]			= ITG.[strSourceId]
	,[intInvoiceId]			= ITG.[intInvoiceId]
FROM
	@InvoicesToGenerate ITG --WITH (NOLOCK)
WHERE
	ISNULL([strSourceTransaction],'') = 'Transport Load'
	AND  NOT EXISTS(SELECT NULL FROM tblTRLoadDistributionHeader WITH (NOLOCK) WHERE [intLoadDistributionHeaderId] = ITG.[intSourceId])

UNION ALL

SELECT
	 [intId]				= ITG.[intId]
	,[strErrorMessage]		= ITG.[strSourceTransaction] + ' does not exists!'
	,[strTransactionType]	= ITG.[strTransactionType]
	,[strType]				= ITG.[strType]
	,[strSourceTransaction]	= ITG.[strSourceTransaction]
	,[intSourceId]			= ITG.[intSourceId]
	,[strSourceId]			= ITG.[strSourceId]
	,[intInvoiceId]			= ITG.[intInvoiceId]
FROM
	@InvoicesToGenerate ITG --WITH (NOLOCK)
WHERE
	ISNULL([strSourceTransaction],'') = 'Inbound Shipment'
	AND  NOT EXISTS(SELECT NULL FROM tblLGShipment WITH (NOLOCK) WHERE [intShipmentId] = ITG.[intSourceId])

UNION ALL

SELECT
	 [intId]				= ITG.[intId]
	,[strErrorMessage]		= ITG.[strSourceTransaction] + ' does not exists!'
	,[strTransactionType]	= ITG.[strTransactionType]
	,[strType]				= ITG.[strType]
	,[strSourceTransaction]	= ITG.[strSourceTransaction]
	,[intSourceId]			= ITG.[intSourceId]
	,[strSourceId]			= ITG.[strSourceId]
	,[intInvoiceId]			= ITG.[intInvoiceId]
FROM
	@InvoicesToGenerate ITG --WITH (NOLOCK)
WHERE
	(	ISNULL([strSourceTransaction],'') = 'Card Fueling Transaction' 
		OR 
		ISNULL([strSourceTransaction],'') = 'CF Tran')
	AND  NOT EXISTS(SELECT NULL FROM tblCFTransaction WITH (NOLOCK) WHERE [intTransactionId] = ITG.[intSourceId])

UNION ALL

SELECT
	 [intId]				= ITG.[intId]
	,[strErrorMessage]		= ITG.[strSourceTransaction] + ' does not exists!'
	,[strTransactionType]	= ITG.[strTransactionType]
	,[strType]				= ITG.[strType]
	,[strSourceTransaction]	= ITG.[strSourceTransaction]
	,[intSourceId]			= ITG.[intSourceId]
	,[strSourceId]			= ITG.[strSourceId]
	,[intInvoiceId]			= ITG.[intInvoiceId]
FROM
	@InvoicesToGenerate ITG --WITH (NOLOCK)
WHERE
	ISNULL([strSourceTransaction],'') = 'Meter Billing'
	AND  NOT EXISTS(SELECT NULL FROM tblMBMeterReading WITH (NOLOCK) WHERE [intMeterReadingId] = ITG.[intSourceId])

UNION ALL

SELECT
	 [intId]				= ITG.[intId]
	,[strErrorMessage]		= ITG.[strSourceTransaction] + ' does not exists!'
	,[strTransactionType]	= ITG.[strTransactionType]
	,[strType]				= ITG.[strType]
	,[strSourceTransaction]	= ITG.[strSourceTransaction]
	,[intSourceId]			= ITG.[intSourceId]
	,[strSourceId]			= ITG.[strSourceId]
	,[intInvoiceId]			= ITG.[intInvoiceId]
FROM
	@InvoicesToGenerate ITG --WITH (NOLOCK)
WHERE
	ISNULL([strSourceTransaction],'') = 'Provisional'
	AND  NOT EXISTS(SELECT NULL FROM tblARInvoice WITH (NOLOCK) WHERE [intInvoiceId] = ITG.[intSourceId])

UNION ALL

SELECT
	 [intId]				= ITG.[intId]
	,[strErrorMessage]		= ITG.[strSourceTransaction] + ' does not exists!'
	,[strTransactionType]	= ITG.[strTransactionType]
	,[strType]				= ITG.[strType]
	,[strSourceTransaction]	= ITG.[strSourceTransaction]
	,[intSourceId]			= ITG.[intSourceId]
	,[strSourceId]			= ITG.[strSourceId]
	,[intInvoiceId]			= ITG.[intInvoiceId]
FROM
	@InvoicesToGenerate ITG --WITH (NOLOCK)
WHERE
	ISNULL([strSourceTransaction],'') = 'Inventory Shipment'
	AND  NOT EXISTS(SELECT NULL FROM tblICInventoryShipment WITH (NOLOCK) WHERE [intInventoryShipmentId] = ITG.[intSourceId])

UNION ALL

SELECT
	 [intId]				= ITG.[intId]
	,[strErrorMessage]		= ITG.[strSourceTransaction] + ' does not exists!'
	,[strTransactionType]	= ITG.[strTransactionType]
	,[strType]				= ITG.[strType]
	,[strSourceTransaction]	= ITG.[strSourceTransaction]
	,[intSourceId]			= ITG.[intSourceId]
	,[strSourceId]			= ITG.[strSourceId]
	,[intInvoiceId]			= ITG.[intInvoiceId]
FROM
	@InvoicesToGenerate ITG --WITH (NOLOCK)
WHERE
	ISNULL([strSourceTransaction],'') = 'Sales Contract'
	AND  NOT EXISTS(SELECT NULL FROM tblCTContractHeader WITH (NOLOCK) WHERE [intContractHeaderId] = ITG.[intSourceId])

UNION ALL

SELECT
	 [intId]				= ITG.[intId]
	,[strErrorMessage]		= ITG.[strSourceTransaction] + ' does not exists!'
	,[strTransactionType]	= ITG.[strTransactionType]
	,[strType]				= ITG.[strType]
	,[strSourceTransaction]	= ITG.[strSourceTransaction]
	,[intSourceId]			= ITG.[intSourceId]
	,[strSourceId]			= ITG.[strSourceId]
	,[intInvoiceId]			= ITG.[intInvoiceId]
FROM
	@InvoicesToGenerate ITG --WITH (NOLOCK)
WHERE
	ISNULL([strSourceTransaction],'') = 'Load Schedule'
	AND  NOT EXISTS(SELECT NULL FROM tblLGLoad WITH (NOLOCK) WHERE [intLoadId] = ITG.[intSourceId])


DELETE FROM V
FROM @InvoicesToGenerate V
WHERE EXISTS(SELECT NULL FROM @InvalidRecords I WHERE V.[intId] = I.[intId])

UPDATE
	@InvoicesToGenerate
SET
	[strTransactionType] = 'Invoice'
WHERE
	ISNULL([strTransactionType], '') = ''


UPDATE
	@InvoicesToGenerate
SET
	[strType] = 'Standard'
WHERE
	ISNULL([strType], '') = ''

INSERT INTO @InvalidRecords(
	 [intId]
	,[strErrorMessage]		
	,[strTransactionType]
	,[strType]
	,[strSourceTransaction]
	,[intSourceId]
	,[strSourceId]
	,[intInvoiceId]
)
SELECT
	 [intId]				= ITG.[intId]
	,[strErrorMessage]		= 'The company location Id provided does not exists!'
	,[strTransactionType]	= ITG.[strTransactionType]
	,[strType]				= ITG.[strType]
	,[strSourceTransaction]	= ITG.[strSourceTransaction]
	,[intSourceId]			= ITG.[intSourceId]
	,[strSourceId]			= ITG.[strSourceId]
	,[intInvoiceId]			= ITG.[intInvoiceId]
FROM
	@InvoicesToGenerate ITG --WITH (NOLOCK)
WHERE
	NOT EXISTS(SELECT NULL FROM tblSMCompanyLocation SMCL WITH (NOLOCK) WHERE SMCL.[intCompanyLocationId] = ITG.[intCompanyLocationId])

UNION ALL

SELECT
	 [intId]				= ITG.[intId]
	,[strErrorMessage]		= 'The company location provided is not active!'
	,[strTransactionType]	= ITG.[strTransactionType]
	,[strType]				= ITG.[strType]
	,[strSourceTransaction]	= ITG.[strSourceTransaction]
	,[intSourceId]			= ITG.[intSourceId]
	,[strSourceId]			= ITG.[strSourceId]
	,[intInvoiceId]			= ITG.[intInvoiceId]
FROM
	@InvoicesToGenerate ITG --WITH (NOLOCK)
WHERE
	NOT EXISTS(SELECT NULL FROM tblSMCompanyLocation SMCL WITH (NOLOCK) WHERE SMCL.[intCompanyLocationId] IS NOT NULL AND SMCL.[intCompanyLocationId] = ITG.[intCompanyLocationId] AND SMCL.[ysnLocationActive] = 1)

UNION ALL

SELECT
	 [intId]				= ITG.[intId]
	,[strErrorMessage]		= ITG.[strTransactionType] + ' is not a valid transaction type!'
	,[strTransactionType]	= ITG.[strTransactionType]
	,[strType]				= ITG.[strType]
	,[strSourceTransaction]	= ITG.[strSourceTransaction]
	,[intSourceId]			= ITG.[intSourceId]
	,[strSourceId]			= ITG.[strSourceId]
	,[intInvoiceId]			= ITG.[intInvoiceId]
FROM
	@InvoicesToGenerate ITG --WITH (NOLOCK)
WHERE
	ITG.[strTransactionType] NOT IN ('Invoice', 'Credit Memo', 'Debit Memo', 'Cash', 'Cash Refund', 'Overpayment', 'Customer Prepayment')

UNION ALL

SELECT
	 [intId]				= ITG.[intId]
	,[strErrorMessage]		= ITG.[strType] + ' is not a valid invoice type!'
	,[strTransactionType]	= ITG.[strTransactionType]
	,[strType]				= ITG.[strType]
	,[strSourceTransaction]	= ITG.[strSourceTransaction]
	,[intSourceId]			= ITG.[intSourceId]
	,[strSourceId]			= ITG.[strSourceId]
	,[intInvoiceId]			= ITG.[intInvoiceId]
FROM
	@InvoicesToGenerate ITG --WITH (NOLOCK)
WHERE
	ITG.[strType] NOT IN ('Meter Billing', 'Standard', 'Software', 'Tank Delivery', 'Provisional', 'Service Charge', 'Transport Delivery', 'Store', 'Card Fueling', 'CF Tran', 'CF Invoice')

UNION ALL

SELECT
	 [intId]				= ITG.[intId]
	,[strErrorMessage]		= 'The customer Id provided does not exists!'
	,[strTransactionType]	= ITG.[strTransactionType]
	,[strType]				= ITG.[strType]
	,[strSourceTransaction]	= ITG.[strSourceTransaction]
	,[intSourceId]			= ITG.[intSourceId]
	,[strSourceId]			= ITG.[strSourceId]
	,[intInvoiceId]			= ITG.[intInvoiceId]
FROM
	@InvoicesToGenerate ITG --WITH (NOLOCK)
WHERE
	NOT EXISTS(SELECT NULL FROM tblARCustomer ARC WITH (NOLOCK) WHERE ARC.[intEntityCustomerId] = ITG.[intEntityCustomerId])

UNION ALL

SELECT
	 [intId]				= ITG.[intId]
	,[strErrorMessage]		= 'The customer provided is not active!'
	,[strTransactionType]	= ITG.[strTransactionType]
	,[strType]				= ITG.[strType]
	,[strSourceTransaction]	= ITG.[strSourceTransaction]
	,[intSourceId]			= ITG.[intSourceId]
	,[strSourceId]			= ITG.[strSourceId]
	,[intInvoiceId]			= ITG.[intInvoiceId]
FROM
	@InvoicesToGenerate ITG --WITH (NOLOCK)
WHERE
	NOT EXISTS(SELECT NULL FROM tblARCustomer ARC WITH (NOLOCK) WHERE ARC.[intEntityCustomerId] = ITG.[intEntityCustomerId] AND ARC.[ysnActive] = 1)


UNION ALL

SELECT
	 [intId]				= ITG.[intId]
	,[strErrorMessage]		= 'The entity Id provided does not exists!'
	,[strTransactionType]	= ITG.[strTransactionType]
	,[strType]				= ITG.[strType]
	,[strSourceTransaction]	= ITG.[strSourceTransaction]
	,[intSourceId]			= ITG.[intSourceId]
	,[strSourceId]			= ITG.[strSourceId]
	,[intInvoiceId]			= ITG.[intInvoiceId]
FROM
	@InvoicesToGenerate ITG --WITH (NOLOCK)
WHERE
	NOT EXISTS(SELECT NULL FROM tblEMEntity EME WITH (NOLOCK) WHERE EME.[intEntityId] = ITG.[intEntityId])


UNION ALL

SELECT
	 [intId]				= ITG.[intId]
	,[strErrorMessage]		= 'Transaction with Invoice Number - ' + [strInvoiceOriginId] + ' is already existing.'
	,[strTransactionType]	= ITG.[strTransactionType]
	,[strType]				= ITG.[strType]
	,[strSourceTransaction]	= ITG.[strSourceTransaction]
	,[intSourceId]			= ITG.[intSourceId]
	,[strSourceId]			= ITG.[strSourceId]
	,[intInvoiceId]			= ITG.[intInvoiceId]
FROM
	@InvoicesToGenerate ITG --WITH (NOLOCK)
WHERE
	ISNULL(ITG.[ysnUseOriginIdAsInvoiceNumber], 0) = 1
	AND EXISTS (SELECT TOP 1 NULL FROM tblARInvoice WITH (NOLOCK) WHERE tblARInvoice.[strInvoiceNumber] = ITG.[strInvoiceOriginId])

DELETE FROM V
FROM @InvoicesToGenerate V
WHERE EXISTS(SELECT NULL FROM @InvalidRecords I WHERE V.[intId] = I.[intId])


UPDATE
	@InvoicesToGenerate
SET
	[intAccountId] = [dbo].[fnARGetInvoiceTypeAccount](strTransactionType, intCompanyLocationId)
WHERE
	ISNULL([intAccountId], 0) = 0

UPDATE
	@InvoicesToGenerate
SET
	[strDeliverPickup] = ISNULL((SELECT TOP 1 SMCL.strDeliverPickupDefault FROM tblSMCompanyLocation SMCL WHERE SMCL.intCompanyLocationId = [intCompanyLocationId]),'')
WHERE
	[strDeliverPickup] IS NULL 
	OR LTRIM(RTRIM([strDeliverPickup])) = ''

UPDATE
	@InvoicesToGenerate
SET
	[strComments] = [dbo].[fnARGetDefaultComment](intCompanyLocationId, intEntityCustomerId, strTransactionType, strType, intDocumentMaintenanceId)
WHERE
	[strComments] IS NULL 
	OR LTRIM(RTRIM([strComments])) = ''

UPDATE
	@InvoicesToGenerate
SET
	[intEntityContactId] = [dbo].[fnARGetCustomerDefaultContact](intEntityCustomerId)
WHERE
	ISNULL([intEntityContactId], 0) = 0

UPDATE
	@InvoicesToGenerate
SET
	[intCurrencyId] = [dbo].[fnARGetCustomerDefaultCurrency](intEntityCustomerId)
WHERE
	ISNULL([intCurrencyId], 0) = 0


INSERT INTO @InvalidRecords(
	 [intId]
	,[strErrorMessage]		
	,[strTransactionType]
	,[strType]
	,[strSourceTransaction]
	,[intSourceId]
	,[strSourceId]
	,[intInvoiceId]
)
SELECT
	 [intId]				= ITG.[intId]
	,[strErrorMessage]		= 'There is no setup for AR Account in the Company Configuration.'
	,[strTransactionType]	= ITG.[strTransactionType]
	,[strType]				= ITG.[strType]
	,[strSourceTransaction]	= ITG.[strSourceTransaction]
	,[intSourceId]			= ITG.[intSourceId]
	,[strSourceId]			= ITG.[strSourceId]
	,[intInvoiceId]			= ITG.[intInvoiceId]
FROM
	@InvoicesToGenerate ITG --WITH (NOLOCK)
WHERE
	ITG.[intAccountId] IS NULL
	AND ITG.[strTransactionType] NOT IN ('Customer Prepayment', 'Cash', 'Cash Refund')


UNION ALL

SELECT
	 [intId]				= ITG.[intId]
	,[strErrorMessage]		= 'The account id provided is not a valid account of category "AR Account".'
	,[strTransactionType]	= ITG.[strTransactionType]
	,[strType]				= ITG.[strType]
	,[strSourceTransaction]	= ITG.[strSourceTransaction]
	,[intSourceId]			= ITG.[intSourceId]
	,[strSourceId]			= ITG.[strSourceId]
	,[intInvoiceId]			= ITG.[intInvoiceId]
FROM
	@InvoicesToGenerate ITG --WITH (NOLOCK)
WHERE
	ITG.[intAccountId] IS NOT NULL
	AND ITG.[strTransactionType] NOT IN ('Customer Prepayment', 'Cash', 'Cash Refund')
	AND NOT EXISTS (SELECT NULL FROM vyuGLAccountDetail GLAD WITH (NOLOCK) WHERE GLAD.[strAccountCategory] = 'AR Account' AND GLAD.[intAccountId] =  ITG.[intAccountId])

UNION ALL

SELECT
	 [intId]				= ITG.[intId]
	,[strErrorMessage]		= 'There is no Undeposited Funds account setup under Company Location - ' + SMCL.[strLocationName]
	,[strTransactionType]	= ITG.[strTransactionType]
	,[strType]				= ITG.[strType]
	,[strSourceTransaction]	= ITG.[strSourceTransaction]
	,[intSourceId]			= ITG.[intSourceId]
	,[strSourceId]			= ITG.[strSourceId]
	,[intInvoiceId]			= ITG.[intInvoiceId]
FROM
	@InvoicesToGenerate ITG --WITH (NOLOCK)
INNER JOIN
	(SELECT CL.[intCompanyLocationId], CL.[strLocationName] FROM tblSMCompanyLocation CL WITH (NOLOCK)) SMCL
		ON SMCL.[intCompanyLocationId] = ITG.[intCompanyLocationId]
WHERE
	ITG.[intAccountId] IS NULL
	AND ITG.[strTransactionType] IN ('Cash', 'Cash Refund')


UNION ALL

SELECT
	 [intId]				= ITG.[intId]
	,[strErrorMessage]		= 'The account id provided is not a valid account of category "Undeposited Funds".'
	,[strTransactionType]	= ITG.[strTransactionType]
	,[strType]				= ITG.[strType]
	,[strSourceTransaction]	= ITG.[strSourceTransaction]
	,[intSourceId]			= ITG.[intSourceId]
	,[strSourceId]			= ITG.[strSourceId]
	,[intInvoiceId]			= ITG.[intInvoiceId]
FROM
	@InvoicesToGenerate ITG --WITH (NOLOCK)
INNER JOIN
	(SELECT CL.[intCompanyLocationId], CL.[strLocationName] FROM tblSMCompanyLocation CL WITH (NOLOCK)) SMCL
		ON SMCL.[intCompanyLocationId] = ITG.[intCompanyLocationId]
WHERE
	ITG.[intAccountId] IS NOT NULL
	AND ITG.[strTransactionType] IN ('Cash', 'Cash Refund')
	AND NOT EXISTS (SELECT NULL FROM vyuGLAccountDetail GLAD WITH (NOLOCK) WHERE GLAD.[strAccountCategory] = 'Undeposited Funds' AND GLAD.[intAccountId] =  ITG.[intAccountId])

UNION ALL

SELECT
	 [intId]				= ITG.[intId]
	,[strErrorMessage]		= 'There is no Customer Prepaid account setup under Company Location - ' + SMCL.[strLocationName]
	,[strTransactionType]	= ITG.[strTransactionType]
	,[strType]				= ITG.[strType]
	,[strSourceTransaction]	= ITG.[strSourceTransaction]
	,[intSourceId]			= ITG.[intSourceId]
	,[strSourceId]			= ITG.[strSourceId]
	,[intInvoiceId]			= ITG.[intInvoiceId]
FROM
	@InvoicesToGenerate ITG --WITH (NOLOCK)
INNER JOIN
	(SELECT CL.[intCompanyLocationId], CL.[strLocationName] FROM tblSMCompanyLocation CL WITH (NOLOCK)) SMCL
		ON SMCL.[intCompanyLocationId] = ITG.[intCompanyLocationId]
WHERE
	ITG.[intAccountId] IS NULL
	AND ITG.[strTransactionType] = 'Customer Prepayment'

UNION ALL

SELECT
	 [intId]				= ITG.[intId]
	,[strErrorMessage]		= 'The account id provided is not a valid account of category "Customer Prepayments".'
	,[strTransactionType]	= ITG.[strTransactionType]
	,[strType]				= ITG.[strType]
	,[strSourceTransaction]	= ITG.[strSourceTransaction]
	,[intSourceId]			= ITG.[intSourceId]
	,[strSourceId]			= ITG.[strSourceId]
	,[intInvoiceId]			= ITG.[intInvoiceId]
FROM
	@InvoicesToGenerate ITG --WITH (NOLOCK)
INNER JOIN
	(SELECT CL.[intCompanyLocationId], CL.[strLocationName] FROM tblSMCompanyLocation CL WITH (NOLOCK)) SMCL
		ON SMCL.[intCompanyLocationId] = ITG.[intCompanyLocationId]
WHERE
	ITG.[intAccountId] IS NOT NULL
	AND ITG.[strTransactionType] = 'Customer Prepayment'
	AND NOT EXISTS (SELECT NULL FROM vyuGLAccountDetail GLAD WITH (NOLOCK) WHERE GLAD.[strAccountCategory] = 'Customer Prepayments' AND GLAD.[intAccountId] =  ITG.[intAccountId])

UNION ALL

SELECT
	 [intId]				= ITG.[intId]
	,[strErrorMessage]		= 'The currency Id provided does not exists!'
	,[strTransactionType]	= ITG.[strTransactionType]
	,[strType]				= ITG.[strType]
	,[strSourceTransaction]	= ITG.[strSourceTransaction]
	,[intSourceId]			= ITG.[intSourceId]
	,[strSourceId]			= ITG.[strSourceId]
	,[intInvoiceId]			= ITG.[intInvoiceId]
FROM
	@InvoicesToGenerate ITG --WITH (NOLOCK)
WHERE
	ITG.[intCurrencyId] IS NOT NULL
	AND NOT EXISTS (SELECT NULL FROM tblSMCurrency SMC WITH (NOLOCK) WHERE SMC.[intCurrencyID] = ITG.[intCurrencyId])

UNION ALL

SELECT
	 [intId]				= ITG.[intId]
	,[strErrorMessage]		= 'There is no setup for default currency in the Company Configuration.'
	,[strTransactionType]	= ITG.[strTransactionType]
	,[strType]				= ITG.[strType]
	,[strSourceTransaction]	= ITG.[strSourceTransaction]
	,[intSourceId]			= ITG.[intSourceId]
	,[strSourceId]			= ITG.[strSourceId]
	,[intInvoiceId]			= ITG.[intInvoiceId]
FROM
	@InvoicesToGenerate ITG --WITH (NOLOCK)
WHERE
	ITG.[intCurrencyId] IS NULL
	AND NOT EXISTS (SELECT NULL FROM tblSMCompanyPreference WITH (NOLOCK) WHERE intDefaultCurrencyId IS NOT NULL)

UNION ALL

SELECT
	 [intId]				= ITG.[intId]
	,[strErrorMessage]		= 'Customer has no Term setup!' 
	,[strTransactionType]	= ITG.[strTransactionType]
	,[strType]				= ITG.[strType]
	,[strSourceTransaction]	= ITG.[strSourceTransaction]
	,[intSourceId]			= ITG.[intSourceId]
	,[strSourceId]			= ITG.[strSourceId]
	,[intInvoiceId]			= ITG.[intInvoiceId]
FROM
	@InvoicesToGenerate ITG --WITH (NOLOCK)
WHERE
	ITG.[intTermId] IS NULL
	AND NOT EXISTS (SELECT NULL FROM tblARCustomer ARC WITH (NOLOCK) WHERE ARC.[intTermsId] IS NOT NULL AND ARC.[intEntityCustomerId] = ITG.[intEntityCustomerId])
	
DELETE FROM V
FROM @InvoicesToGenerate V
WHERE EXISTS(SELECT NULL FROM @InvalidRecords I WHERE V.[intId] = I.[intId])


IF ISNULL(@RaiseError,0) = 1 AND EXISTS(SELECT TOP 1 NULL FROM @InvalidRecords)
BEGIN
	SET @ErrorMessage = (SELECT TOP 1 [strErrorMessage] FROM @InvalidRecords ORDER BY [intId])
	RAISERROR(@ErrorMessage, 16, 1);
	RETURN 0;
END


IF ISNULL(@RaiseError,0) = 0	
	BEGIN TRANSACTION

DECLARE  @AddDetailError NVARCHAR(MAX)
		,@IntegrationLog InvoiceIntegrationLogStagingTable

INSERT INTO @IntegrationLog
	([intIntegrationLogId]
	,[dtmDate]
	,[intEntityId]
	,[intGroupingOption]
	,[strErrorMessage]
	,[strBatchIdForNewPost]
	,[intPostedNewCount]
	,[strBatchIdForNewPostRecap]
	,[intRecapNewCount]
	,[strBatchIdForExistingPost]
	,[intPostedExistingCount]
	,[strBatchIdForExistingRecap]
	,[intRecapPostExistingCount]
	,[strBatchIdForExistingUnPost]
	,[intUnPostedExistingCount]
	,[strBatchIdForExistingUnPostRecap]
	,[intRecapUnPostedExistingCount]
	,[intIntegrationLogDetailId]
	,[intInvoiceId]
	,[intInvoiceDetailId]
	,[intId]
	,[strTransactionType]
	,[strType]
	,[strSourceTransaction]
	,[intSourceId]
	,[strSourceId]
	,[ysnPost]
	,[ysnInsert]
	,[ysnHeader]
	,[ysnSuccess])
SELECT
	 [intIntegrationLogId]					= @IntegrationLogId
	,[dtmDate]								= @DateOnly
	,[intEntityId]							= @UserId
	,[intGroupingOption]					= @GroupingOption
	,[strErrorMessage]						= [strErrorMessage]
	,[strBatchIdForNewPost]					= ''
	,[intPostedNewCount]					= 0
	,[strBatchIdForNewPostRecap]			= ''
	,[intRecapNewCount]						= 0
	,[strBatchIdForExistingPost]			= ''
	,[intPostedExistingCount]				= 0
	,[strBatchIdForExistingRecap]			= ''
	,[intRecapPostExistingCount]			= 0
	,[strBatchIdForExistingUnPost]			= ''
	,[intUnPostedExistingCount]				= 0
	,[strBatchIdForExistingUnPostRecap]		= ''
	,[intRecapUnPostedExistingCount]		= 0
	,[intIntegrationLogDetailId]			= 0
	,[intInvoiceId]							= NULL
	,[intInvoiceDetailId]					= NULL
	,[intId]								= [intId]
	,[strTransactionType]					= [strTransactionType]
	,[strType]								= [strType]
	,[strSourceTransaction]					= [strSourceTransaction]
	,[intSourceId]							= [intSourceId]
	,[strSourceId]							= [strSourceId]
	,[ysnPost]								= NULL
	,[ysnInsert]							= 1
	,[ysnHeader]							= 1
	,[ysnSuccess]							= 0
FROM
	@InvalidRecords

BEGIN TRY
MERGE INTO tblARInvoice AS Target
USING 
	(
	SELECT
		 [intInvoiceId]					= NULL
		,[strInvoiceNumber]				= CASE WHEN ITG.ysnUseOriginIdAsInvoiceNumber = 1 THEN ITG.strInvoiceOriginId ELSE NULL END
		,[strTransactionType]			= ITG.strTransactionType
		,[strType]						= ITG.strType
		,[intEntityCustomerId]			= ARC.[intEntityCustomerId]
		,[intCompanyLocationId]			= ITG.intCompanyLocationId
		,[intAccountId]					= ITG.[intAccountId]
		,[intCurrencyId]				= ITG.intCurrencyId
		,[intTermId]					= ISNULL(ITG.intTermId, ARC.[intTermsId])
		,[intSourceId]					= [dbo].[fnARValidateInvoiceSourceId](ITG.[strSourceTransaction], ITG.[intSourceId])
		,[intPeriodsToAccrue]			= ISNULL(ITG.intPeriodsToAccrue, 1)
		,[dtmDate]						= ISNULL(CAST(ITG.dtmDate AS DATE),@DateOnly)
		,[dtmDueDate]					= ISNULL(ITG.dtmDueDate, (CAST(dbo.fnGetDueDateBasedOnTerm(ISNULL(CAST(ITG.dtmDate AS DATE),@DateOnly), ISNULL(ISNULL(ITG.intTermId, ARC.[intTermsId]),0)) AS DATE)))
		,[dtmShipDate]					= ISNULL(ITG.dtmShipDate, DATEADD(month, 1, ISNULL(CAST(ITG.dtmDate AS DATE),@DateOnly)))
		,[dtmPostDate]					= ISNULL(CAST(ITG.dtmPostDate AS DATE),ISNULL(CAST(ITG.dtmDate AS DATE),@DateOnly))
		,[dtmCalculated]				= NULL
		,[dblInvoiceSubtotal]			= @ZeroDecimal
		,[dblBaseInvoiceSubtotal]		= @ZeroDecimal
		,[dblShipping]					= @ZeroDecimal
		,[dblBaseShipping]				= @ZeroDecimal
		,[dblTax]						= @ZeroDecimal
		,[dblBaseTax]					= @ZeroDecimal
		,[dblInvoiceTotal]				= @ZeroDecimal
		,[dblBaseInvoiceTotal]			= @ZeroDecimal
		,[dblDiscount]					= @ZeroDecimal
		,[dblBaseDiscount]				= @ZeroDecimal
		,[dblDiscountAvailable]			= @ZeroDecimal
		,[dblBaseDiscountAvailable]		= @ZeroDecimal
		,[dblInterest]					= @ZeroDecimal
		,[dblBaseInterest]				= @ZeroDecimal
		,[dblAmountDue]					= @ZeroDecimal
		,[dblBaseAmountDue]				= @ZeroDecimal
		,[dblPayment]					= @ZeroDecimal		
		,[dblBasePayment]				= @ZeroDecimal		
		,[intEntitySalespersonId]		= ISNULL(ITG.intEntitySalespersonId, ARC.[intSalespersonId])		
		,[intFreightTermId]				= ITG.intFreightTermId
		,[intShipViaId]					= ISNULL(ITG.intShipViaId, EL.[intShipViaId])
		,[intPaymentMethodId]			= (SELECT intPaymentMethodID FROM tblSMPaymentMethod WHERE intPaymentMethodID = ITG.intPaymentMethodId)
		,[strInvoiceOriginId]			= ITG.strInvoiceOriginId
		,[strPONumber]					= ITG.strPONumber
		,[strBOLNumber]					= ITG.strBOLNumber
		,[strDeliverPickup]				= ITG.strDeliverPickup
		,[strComments]					= CASE WHEN (ITG.strComments IS NULL OR ITG.strComments = '') THEN (SELECT TOP 1 strMessage FROM tblSMDocumentMaintenanceMessage WHERE intDocumentMaintenanceId = ITG.intDocumentMaintenanceId AND strHeaderFooter NOT IN ('Footer')) ELSE ITG.strComments END
		,[strFooterComments]			= dbo.fnARGetFooterComment(ITG.intCompanyLocationId, ARC.intEntityCustomerId, 'Invoice Footer')
		,[intShipToLocationId]			= ISNULL(ITG.intShipToLocationId, ISNULL(SL1.[intEntityLocationId], EL.[intEntityLocationId]))
		,[strShipToLocationName]		= ISNULL(SL.[strLocationName], ISNULL(SL1.[strLocationName], EL.[strLocationName]))
		,[strShipToAddress]				= ISNULL(SL.[strAddress], ISNULL(SL1.[strAddress], EL.[strAddress]))
		,[strShipToCity]				= ISNULL(SL.[strCity], ISNULL(SL1.[strCity], EL.[strCity]))
		,[strShipToState]				= ISNULL(SL.[strState], ISNULL(SL1.[strState], EL.[strState]))
		,[strShipToZipCode]				= ISNULL(SL.[strZipCode], ISNULL(SL1.[strZipCode], EL.[strZipCode]))
		,[strShipToCountry]				= ISNULL(SL.[strCountry], ISNULL(SL1.[strCountry], EL.[strCountry]))
		,[intBillToLocationId]			= ISNULL(ITG.intBillToLocationId, ISNULL(BL1.[intEntityLocationId], EL.[intEntityLocationId]))
		,[strBillToLocationName]		= ISNULL(BL.[strLocationName], ISNULL(BL1.[strLocationName], EL.[strLocationName]))
		,[strBillToAddress]				= ISNULL(BL.[strAddress], ISNULL(BL1.[strAddress], EL.[strAddress]))
		,[strBillToCity]				= ISNULL(BL.[strCity], ISNULL(BL1.[strCity], EL.[strCity]))
		,[strBillToState]				= ISNULL(BL.[strState], ISNULL(BL1.[strState], EL.[strState]))
		,[strBillToZipCode]				= ISNULL(BL.[strZipCode], ISNULL(BL1.[strZipCode], EL.[strZipCode]))
		,[strBillToCountry]				= ISNULL(BL.[strCountry], ISNULL(BL1.[strCountry], EL.[strCountry]))		
		,[ysnPosted]					= (CASE WHEN ITG.strTransactionType IN ('Overpayment', 'Customer Prepayment') THEN ITG.ysnPost ELSE 0 END)
		,[ysnPaid]						= 0
		,[ysnProcessed]					= 0
		,[ysnRecurring]					= 0
		,[ysnTemplate]					= ISNULL(ITG.ysnTemplate,0)
		,[ysnForgiven]					= ISNULL(ITG.ysnForgiven,0) 
		,[ysnCalculated]				= ISNULL(ITG.ysnCalculated,0)
		,[ysnSplitted]					= ISNULL(ITG.ysnSplitted,0)		
		,[dblSplitPercent]				= 1.000000
		,[ysnImpactInventory]			= 0
		,[ysnImportedFromOrigin]		= 0
		,[ysnImportedAsPosted]			= 0
		,[intPaymentId]					= ITG.intPaymentId 
		,[intSplitId]					= ITG.intSplitId 
		,[intDistributionHeaderId]		= NULL
		,[intLoadDistributionHeaderId]	= ITG.intLoadDistributionHeaderId 
		,[strActualCostId]				= ITG.strActualCostId
		,[strImportFormat]				= ITG.strImportFormat
		,[intShipmentId]				= ITG.intShipmentId 
		,[intTransactionId]				= ITG.intTransactionId
		,[intMeterReadingId]			= ITG.intMeterReadingId
		,[intContractHeaderId]			= ITG.intContractHeaderId
		,[intOriginalInvoiceId]			= ITG.intOriginalInvoiceId
		,[intLoadId]                    = ITG.intLoadId
		,[intEntityId]					= ITG.intEntityId
		,[intEntityContactId]			= ITG.intEntityContactId
		,[intDocumentMaintenanceId]		= NULL
		,[dblTotalWeight]				= @ZeroDecimal
		,[dblTotalTermDiscount]			= @ZeroDecimal
		,[intTruckDriverId]				= ITG.intTruckDriverId
		,[intTruckDriverReferenceId]	= ITG.intTruckDriverReferenceId
		,[intConcurrencyId]				= 0
		,[intId]						= ITG.[intId]
		,[strSourceTransaction]			= ITG.[strSourceTransaction]
		,[intSourceIdTemp]				= ITG.[intSourceId]	
		,[strSourceId]					= ITG.[strSourceId]
		,[ysnPost]						= ITG.[ysnPost]
		,[ysnUpdateAvailableDiscount]	= ITG.[ysnUpdateAvailableDiscount]
	FROM	
		@InvoicesToGenerate ITG --WITH (NOLOCK)
	INNER JOIN
		(SELECT intId FROM @InvoicesToGenerate) ITG2  --WITH (NOLOCK)) ITG2
			ON ITG.[intId] = ITG2.[intId]
	INNER JOIN
		(SELECT [intEntityCustomerId], [intTermsId], [intSalespersonId], [intShipToId], [intBillToId] FROM tblARCustomer WITH (NOLOCK)) ARC
			ON ITG.[intEntityCustomerId] = ARC.[intEntityCustomerId] 
	LEFT OUTER JOIN
		(SELECT [intEntityLocationId], [strLocationName], [strAddress], [intEntityId], [strCountry], [strState], [strCity], [strZipCode], [intTermsId], [intShipViaId]
		FROM 
			[tblEMEntityLocation] WITH (NOLOCK)
		WHERE
			ysnDefaultLocation = 1
		) EL
			ON ARC.[intEntityCustomerId] = EL.[intEntityId]
	LEFT OUTER JOIN
		(SELECT [intEntityLocationId], [strLocationName], [strAddress], [strCity], [strState], [strZipCode], [strCountry] FROM [tblEMEntityLocation] WITH (NOLOCK)) SL
			ON ISNULL(ITG.intShipToLocationId, 0) <> 0
			AND ITG.intShipToLocationId = SL.[intEntityLocationId]
	LEFT OUTER JOIN
		(SELECT [intEntityLocationId], [strLocationName], [strAddress], [strCity], [strState], [strZipCode], [strCountry] FROM [tblEMEntityLocation] WITH (NOLOCK)) SL1
			ON ARC.[intShipToId] = SL1.intEntityLocationId
	LEFT OUTER JOIN
		(SELECT [intEntityLocationId], [strLocationName], [strAddress], [strCity], [strState], [strZipCode], [strCountry] FROM [tblEMEntityLocation] WITH (NOLOCK)) BL
			ON ISNULL(ITG.intBillToLocationId, 0) <> 0
			AND ITG.intBillToLocationId = BL.intEntityLocationId		
	LEFT OUTER JOIN
		(SELECT [intEntityLocationId], [strLocationName], [strAddress], [strCity], [strState], [strZipCode], [strCountry] FROM [tblEMEntityLocation] WITH (NOLOCK)) BL1
			ON ARC.[intBillToId] = BL1.intEntityLocationId		
	)
AS Source
ON Target.[intInvoiceId] = Source.[intInvoiceId]
WHEN NOT MATCHED BY TARGET THEN
INSERT(
	 [strInvoiceNumber]
	,[strTransactionType]
	,[strType]
	,[intEntityCustomerId]
	,[intCompanyLocationId]
	,[intAccountId]
	,[intCurrencyId]
	,[intTermId]
	,[intSourceId]
	,[intPeriodsToAccrue]
	,[dtmDate]
	,[dtmDueDate]
	,[dtmShipDate]
	,[dtmPostDate]
	,[dtmCalculated]
	,[dblInvoiceSubtotal]
	,[dblBaseInvoiceSubtotal]
	,[dblShipping]
	,[dblBaseShipping]
	,[dblTax]
	,[dblBaseTax]
	,[dblInvoiceTotal]
	,[dblBaseInvoiceTotal]
	,[dblDiscount]
	,[dblBaseDiscount]
	,[dblDiscountAvailable]
	,[dblBaseDiscountAvailable]
	,[dblInterest]
	,[dblBaseInterest]
	,[dblAmountDue]
	,[dblBaseAmountDue]
	,[dblPayment]
	,[dblBasePayment]
	,[intEntitySalespersonId]
	,[intFreightTermId]
	,[intShipViaId]
	,[intPaymentMethodId]
	,[strInvoiceOriginId]
	,[strPONumber]
	,[strBOLNumber]
	,[strDeliverPickup]
	,[strComments]
	,[strFooterComments]
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
	,[ysnPosted]
	,[ysnPaid]
	,[ysnProcessed]
	,[ysnRecurring]
	,[ysnForgiven]
	,[ysnCalculated]
	,[ysnSplitted]
	,[dblSplitPercent]
	,[ysnImpactInventory]
	,[ysnImportedFromOrigin]
	,[ysnImportedAsPosted]
	,[intPaymentId]
	,[intSplitId]
	,[intDistributionHeaderId]
	,[intLoadDistributionHeaderId]
	,[strActualCostId]
	,[strImportFormat]
	,[intShipmentId]
	,[intTransactionId]
	,[intMeterReadingId]
	,[intContractHeaderId]
	,[intOriginalInvoiceId]
	,[intLoadId]
	,[intEntityId]
	,[intEntityContactId]
	,[intDocumentMaintenanceId]
	,[dblTotalWeight]
	,[dblTotalTermDiscount]
	,[intTruckDriverId]
	,[intTruckDriverReferenceId]
	,[intConcurrencyId]
	)
VALUES(
	 [strInvoiceNumber]
	,[strTransactionType]
	,[strType]
	,[intEntityCustomerId]
	,[intCompanyLocationId]
	,[intAccountId]
	,[intCurrencyId]
	,[intTermId]
	,[intSourceId]
	,[intPeriodsToAccrue]
	,[dtmDate]
	,[dtmDueDate]
	,[dtmShipDate]
	,[dtmPostDate]
	,[dtmCalculated]
	,[dblInvoiceSubtotal]
	,[dblBaseInvoiceSubtotal]
	,[dblShipping]
	,[dblBaseShipping]
	,[dblTax]
	,[dblBaseTax]
	,[dblInvoiceTotal]
	,[dblBaseInvoiceTotal]
	,[dblDiscount]
	,[dblBaseDiscount]
	,[dblDiscountAvailable]
	,[dblBaseDiscountAvailable]
	,[dblInterest]
	,[dblBaseInterest]
	,[dblAmountDue]
	,[dblBaseAmountDue]
	,[dblPayment]
	,[dblBasePayment]
	,[intEntitySalespersonId]
	,[intFreightTermId]
	,[intShipViaId]
	,[intPaymentMethodId]
	,[strInvoiceOriginId]
	,[strPONumber]
	,[strBOLNumber]
	,[strDeliverPickup]
	,[strComments]
	,[strFooterComments]
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
	,[ysnPosted]
	,[ysnPaid]
	,[ysnProcessed]
	,[ysnRecurring]
	,[ysnForgiven]
	,[ysnCalculated]
	,[ysnSplitted]
	,[dblSplitPercent]
	,[ysnImpactInventory]
	,[ysnImportedFromOrigin]
	,[ysnImportedAsPosted]
	,[intPaymentId]
	,[intSplitId]
	,[intDistributionHeaderId]
	,[intLoadDistributionHeaderId]
	,[strActualCostId]
	,[strImportFormat]
	,[intShipmentId]
	,[intTransactionId]
	,[intMeterReadingId]
	,[intContractHeaderId]
	,[intOriginalInvoiceId]
	,[intLoadId]
	,[intEntityId]
	,[intEntityContactId]
	,[intDocumentMaintenanceId]
	,[dblTotalWeight]
	,[dblTotalTermDiscount]
	,[intTruckDriverId]
	,[intTruckDriverReferenceId]
	,[intConcurrencyId]
)
	OUTPUT  
			@IntegrationLogId						--[intIntegrationLogId]
			,@DateOnly								--[dtmDate]
			,INSERTED.[intEntityId]					--[intEntityId]
			,@GroupingOption						--[intGroupingOption]
			,'Invoice was successfully created.'	--[strErrorMessage]
			,''										--[strBatchIdForNewPost]
			,0										--[intPostedNewCount]
			,''										--[strBatchIdForNewPostRecap]
			,0										--[intRecapNewCount]
			,''										--[strBatchIdForExistingPost]
			,0										--[intPostedExistingCount]
			,''										--[strBatchIdForExistingRecap]
			,0										--[intRecapPostExistingCount]
			,''										--[strBatchIdForExistingUnPost]
			,0										--[intUnPostedExistingCount]
			,''										--[strBatchIdForExistingUnPostRecap]
			,0										--[intRecapUnPostedExistingCount]
			,NULL									--[intIntegrationLogDetailId]
			,INSERTED.[intInvoiceId]				--[intInvoiceId]
			,INSERTED.[intEntityCustomerId]			--[intEntityCustomerId]
			,INSERTED.[intCompanyLocationId]		--[intCompanyLocationId]
			,INSERTED.[intCurrencyId]				--[intCurrencyId]
			,INSERTED.[intTermId]					--[intTermId]
			,NULL									--[intInvoiceDetailId]
			,Source.[intId]							--[intId]
			,INSERTED.[strTransactionType]			--[strTransactionType]
			,INSERTED.[strType]						--[strType]
			,Source.[strSourceTransaction]			--[strSourceTransaction]
			,Source.[intSourceId]					--[intSourceId]
			,Source.[strSourceId]					--[strSourceId]
			,Source.[ysnPost]						--[ysnPost]
			,1										--[ysnInsert]
			,1										--[ysnHeader]
			,1										--[ysnSuccess]
		INTO @IntegrationLog(
			 [intIntegrationLogId]
			,[dtmDate]
			,[intEntityId]
			,[intGroupingOption]
			,[strErrorMessage]
			,[strBatchIdForNewPost]
			,[intPostedNewCount]
			,[strBatchIdForNewPostRecap]
			,[intRecapNewCount]
			,[strBatchIdForExistingPost]
			,[intPostedExistingCount]
			,[strBatchIdForExistingRecap]
			,[intRecapPostExistingCount]
			,[strBatchIdForExistingUnPost]
			,[intUnPostedExistingCount]
			,[strBatchIdForExistingUnPostRecap]
			,[intRecapUnPostedExistingCount]
			,[intIntegrationLogDetailId]
			,[intInvoiceId]
			,[intEntityCustomerId]
			,[intCompanyLocationId]
			,[intCurrencyId]
			,[intTermId]
			,[intInvoiceDetailId]
			,[intId]
			,[strTransactionType]
			,[strType]
			,[strSourceTransaction]
			,[intSourceId]
			,[strSourceId]
			,[ysnPost]
			,[ysnInsert]
			,[ysnHeader]
			,[ysnSuccess]
		);	
	
	IF ISNULL(@IntegrationLogId, 0) <> 0 AND ISNULL(@RaiseError,0) = 0
		EXEC [uspARInsertInvoiceIntegrationLogDetail] @IntegrationLogEntries = @IntegrationLog
	
END TRY
BEGIN CATCH
	IF ISNULL(@RaiseError,0) = 0
		ROLLBACK TRANSACTION
	SET @ErrorMessage = ERROR_MESSAGE();
	IF ISNULL(@RaiseError,0) = 1
		RAISERROR(@ErrorMessage, 16, 1);
	RETURN 0;
END CATCH



BEGIN TRY
	DECLARE @LineItems InvoiceStagingTable
	DELETE FROM @LineItems
	INSERT INTO @LineItems
		([intId]
		,[strTransactionType]
		,[strType]
		,[strSourceTransaction]
		,[strSourceId]
		,[intInvoiceId]
		,[intEntityCustomerId]
		,[intEntityContactId]
		,[intCompanyLocationId]
		,[intAccountId]
		,[intCurrencyId]
		,[intTermId]
		,[intPeriodsToAccrue]
		,[dtmDate]
		,[dtmDueDate]
		,[dtmShipDate]
		,[dtmPostDate]
		,[intEntitySalespersonId]
		,[intFreightTermId]
		,[intShipViaId]
		,[intPaymentMethodId]
		,[strInvoiceOriginId]
		,[ysnUseOriginIdAsInvoiceNumber]
		,[strPONumber]
		,[strBOLNumber]
		,[strDeliverPickup]
		,[strComments]
		,[intShipToLocationId]
		,[intBillToLocationId]
		,[ysnTemplate]
		,[ysnForgiven]
		,[ysnCalculated]
		,[ysnSplitted]
		,[intPaymentId]
		,[intSplitId]
		,[intLoadDistributionHeaderId]
		,[strActualCostId]
		,[intShipmentId]
		,[intTransactionId]
		,[intMeterReadingId]
		,[intContractHeaderId]
		,[intLoadId]
		,[intOriginalInvoiceId]
		,[intEntityId]
		,[intTruckDriverId]
		,[intTruckDriverReferenceId]
		,[ysnResetDetails]
		,[ysnRecap]
		,[ysnPost]
		,[ysnUpdateAvailableDiscount]
		,[ysnInsertDetail]
		,[intInvoiceDetailId]
		,[intItemId]
		,[intPrepayTypeId]
		,[ysnRestricted]
		,[ysnInventory]
		,[strDocumentNumber]
		,[strItemDescription]
		,[intOrderUOMId]
		,[dblQtyOrdered]
		,[intItemUOMId]
		,[dblQtyShipped]
		,[dblDiscount]
		,[dblItemTermDiscount]
		,[strItemTermDiscountBy]
		,[dblItemWeight]
		,[intItemWeightUOMId]
		,[dblPrice]
		,[strPricing]
		,[strVFDDocumentNumber]
		,[ysnRefreshPrice]
		,[strMaintenanceType]
		,[strFrequency]
		,[intMaintenanceAccountId]
		,[dtmMaintenanceDate]
		,[dblMaintenanceAmount]
		,[intLicenseAccountId]
		,[dblLicenseAmount]
		,[intTaxGroupId]
		,[intStorageLocationId]
		,[intCompanyLocationSubLocationId]
		,[ysnRecomputeTax]
		,[intSCInvoiceId]
		,[strSCInvoiceNumber]
		,[intSCBudgetId]
		,[strSCBudgetDescription]
		,[intInventoryShipmentItemId]
		,[intInventoryShipmentChargeId]
		,[strShipmentNumber]
		,[intRecipeItemId]
		,[intRecipeId]
		,[intSubLocationId]
		,[intCostTypeId]
		,[intMarginById]
		,[intCommentTypeId]
		,[dblMargin]
		,[dblRecipeQuantity]
		,[intSalesOrderDetailId]
		,[strSalesOrderNumber]
		,[intContractDetailId]
		,[intShipmentPurchaseSalesContractId]
		,[dblShipmentGrossWt]
		,[dblShipmentTareWt]
		,[dblShipmentNetWt]
		,[intTicketId]
		,[intTicketHoursWorkedId]
		,[intDocumentMaintenanceId]
		,[intCustomerStorageId]
		,[intSiteDetailId]
		,[intLoadDetailId]
		,[intLotId]
		,[intOriginalInvoiceDetailId]
		,[intSiteId]
		,[strBillingBy]
		,[dblPercentFull]
		,[dblNewMeterReading]
		,[dblPreviousMeterReading]
		,[dblConversionFactor]
		,[intPerformerId]
		,[ysnLeaseBilling]
		,[ysnVirtualMeterReading]
		,[ysnClearDetailTaxes]
		,[intTempDetailIdForTaxes]
		,[intCurrencyExchangeRateTypeId]
		,[intCurrencyExchangeRateId]
		,[dblCurrencyExchangeRate]
		,[intSubCurrencyId]
		,[dblSubCurrencyRate]
		,[ysnBlended]
		,[strImportFormat]
		,[dblCOGSAmount]
		,[intConversionAccountId]
		,[intSalesAccountId]
		,[intStorageScheduleTypeId]
		,[intDestinationGradeId]
		,[intDestinationWeightId])
	SELECT
		 [intId]								= IL.[intId]
		,[strTransactionType]					= ITG.[strTransactionType]
		,[strType]								= ITG.[strType]
		,[strSourceTransaction]					= ITG.[strSourceTransaction]
		,[strSourceId]							= ITG.[strSourceId]
		,[intInvoiceId]							= IL.[intInvoiceId]
		,[intEntityCustomerId]					= IL.[intEntityCustomerId]
		,[intEntityContactId]					= ITG.[intEntityContactId]
		,[intCompanyLocationId]					= IL.[intCompanyLocationId]
		,[intAccountId]							= ITG.[intAccountId]
		,[intCurrencyId]						= IL.[intCurrencyId]
		,[intTermId]							= IL.[intTermId]
		,[intPeriodsToAccrue]					= ITG.[intPeriodsToAccrue]
		,[dtmDate]								= ITG.[dtmDate]
		,[dtmDueDate]							= ITG.[dtmDueDate]
		,[dtmShipDate]							= ITG.[dtmShipDate]
		,[dtmPostDate]							= ITG.[dtmPostDate]
		,[intEntitySalespersonId]				= ITG.[intEntitySalespersonId]
		,[intFreightTermId]						= ITG.[intFreightTermId]
		,[intShipViaId]							= ITG.[intShipViaId]
		,[intPaymentMethodId]					= ITG.[intPaymentMethodId]
		,[strInvoiceOriginId]					= ITG.[strInvoiceOriginId]
		,[ysnUseOriginIdAsInvoiceNumber]		= ITG.[ysnUseOriginIdAsInvoiceNumber]
		,[strPONumber]							= ITG.[strPONumber]
		,[strBOLNumber]							= ITG.[strBOLNumber]
		,[strDeliverPickup]						= ITG.[strDeliverPickup]
		,[strComments]							= ITG.[strComments]
		,[intShipToLocationId]					= ITG.[intShipToLocationId]
		,[intBillToLocationId]					= ITG.[intBillToLocationId]
		,[ysnTemplate]							= ITG.[ysnTemplate]
		,[ysnForgiven]							= ITG.[ysnForgiven]
		,[ysnCalculated]						= ITG.[ysnCalculated]
		,[ysnSplitted]							= ITG.[ysnSplitted]
		,[intPaymentId]							= ITG.[intPaymentId]
		,[intSplitId]							= ITG.[intSplitId]
		,[intLoadDistributionHeaderId]			= ITG.[intLoadDistributionHeaderId]
		,[strActualCostId]						= ITG.[strActualCostId]
		,[intShipmentId]						= ITG.[intShipmentId]
		,[intTransactionId]						= ITG.[intTransactionId]
		,[intMeterReadingId]					= ITG.[intMeterReadingId]
		,[intContractHeaderId]					= ITG.[intContractHeaderId]
		,[intLoadId]							= ITG.[intLoadId]
		,[intOriginalInvoiceId]					= ITG.[intOriginalInvoiceId]
		,[intEntityId]							= ITG.[intEntityId]
		,[intTruckDriverId]						= ITG.[intTruckDriverId]
		,[intTruckDriverReferenceId]			= ITG.[intTruckDriverReferenceId]
		,[ysnResetDetails]						= ITG.[ysnResetDetails]
		,[ysnRecap]								= ITG.[ysnRecap]
		,[ysnPost]								= ITG.[ysnPost]
		,[ysnUpdateAvailableDiscount]			= ITG.[ysnUpdateAvailableDiscount]
		,[ysnInsertDetail]						= ITG.[ysnInsertDetail]
		,[intInvoiceDetailId]					= ITG.[intInvoiceDetailId]
		,[intItemId]							= ITG.[intItemId]
		,[intPrepayTypeId]						= ITG.[intPrepayTypeId]
		,[ysnRestricted]						= ITG.[ysnRestricted]
		,[ysnInventory]							= ITG.[ysnInventory]
		,[strDocumentNumber]					= ITG.[strDocumentNumber]
		,[strItemDescription]					= ITG.[strItemDescription]
		,[intOrderUOMId]						= ITG.[intOrderUOMId]
		,[dblQtyOrdered]						= ITG.[dblQtyOrdered]
		,[intItemUOMId]							= ITG.[intItemUOMId]
		,[dblQtyShipped]						= ITG.[dblQtyShipped]
		,[dblDiscount]							= ITG.[dblDiscount]
		,[dblItemTermDiscount]					= ITG.[dblItemTermDiscount]
		,[strItemTermDiscountBy]				= ITG.[strItemTermDiscountBy]
		,[dblItemWeight]						= ITG.[dblItemWeight]
		,[intItemWeightUOMId]					= ITG.[intItemWeightUOMId]
		,[dblPrice]								= ITG.[dblPrice]
		,[strPricing]							= ITG.[strPricing]
		,[strVFDDocumentNumber]					= ITG.[strVFDDocumentNumber]
		,[ysnRefreshPrice]						= ITG.[ysnRefreshPrice]
		,[strMaintenanceType]					= ITG.[strMaintenanceType]
		,[strFrequency]							= ITG.[strFrequency]
		,[intMaintenanceAccountId]				= ITG.[intMaintenanceAccountId]
		,[dtmMaintenanceDate]					= ITG.[dtmMaintenanceDate]
		,[dblMaintenanceAmount]					= ITG.[dblMaintenanceAmount]
		,[intLicenseAccountId]					= ITG.[intLicenseAccountId]
		,[dblLicenseAmount]						= ITG.[dblLicenseAmount]
		,[intTaxGroupId]						= ITG.[intTaxGroupId]
		,[intStorageLocationId]					= ITG.[intStorageLocationId]
		,[intCompanyLocationSubLocationId]		= ITG.[intCompanyLocationSubLocationId]
		,[ysnRecomputeTax]						= ITG.[ysnRecomputeTax]
		,[intSCInvoiceId]						= ITG.[intSCInvoiceId]
		,[strSCInvoiceNumber]					= ITG.[strSCInvoiceNumber]
		,[intSCBudgetId]						= ITG.[intSCBudgetId]
		,[strSCBudgetDescription]				= ITG.[strSCBudgetDescription]
		,[intInventoryShipmentItemId]			= ITG.[intInventoryShipmentItemId]
		,[intInventoryShipmentChargeId]			= ITG.[intInventoryShipmentChargeId]
		,[strShipmentNumber]					= ITG.[strShipmentNumber]
		,[intRecipeItemId]						= ITG.[intRecipeItemId]
		,[intRecipeId]							= ITG.[intRecipeId]
		,[intSubLocationId]						= ITG.[intSubLocationId]
		,[intCostTypeId]						= ITG.[intCostTypeId]
		,[intMarginById]						= ITG.[intMarginById]
		,[intCommentTypeId]						= ITG.[intCommentTypeId]
		,[dblMargin]							= ITG.[dblMargin]
		,[dblRecipeQuantity]					= ITG.[dblRecipeQuantity]
		,[intSalesOrderDetailId]				= ITG.[intSalesOrderDetailId]
		,[strSalesOrderNumber]					= ITG.[strSalesOrderNumber]
		,[intContractDetailId]					= ITG.[intContractDetailId]
		,[intShipmentPurchaseSalesContractId]	= ITG.[intShipmentPurchaseSalesContractId]
		,[dblShipmentGrossWt]					= ITG.[dblShipmentGrossWt]
		,[dblShipmentTareWt]					= ITG.[dblShipmentTareWt]
		,[dblShipmentNetWt]						= ITG.[dblShipmentNetWt]
		,[intTicketId]							= ITG.[intTicketId]
		,[intTicketHoursWorkedId]				= ITG.[intTicketHoursWorkedId]
		,[intDocumentMaintenanceId]				= ITG.[intDocumentMaintenanceId]
		,[intCustomerStorageId]					= ITG.[intCustomerStorageId]
		,[intSiteDetailId]						= ITG.[intSiteDetailId]
		,[intLoadDetailId]						= ITG.[intLoadDetailId]
		,[intLotId]								= ITG.[intLotId]
		,[intOriginalInvoiceDetailId]			= ITG.[intOriginalInvoiceDetailId]
		,[intSiteId]							= ITG.[intSiteId]
		,[strBillingBy]							= ITG.[strBillingBy]
		,[dblPercentFull]						= ITG.[dblPercentFull]
		,[dblNewMeterReading]					= ITG.[dblNewMeterReading]
		,[dblPreviousMeterReading]				= ITG.[dblPreviousMeterReading]
		,[dblConversionFactor]					= ITG.[dblConversionFactor]
		,[intPerformerId]						= ITG.[intPerformerId]
		,[ysnLeaseBilling]						= ITG.[ysnLeaseBilling]
		,[ysnVirtualMeterReading]				= ITG.[ysnVirtualMeterReading]
		,[ysnClearDetailTaxes]					= ITG.[ysnClearDetailTaxes]
		,[intTempDetailIdForTaxes]				= ITG.[intTempDetailIdForTaxes]
		,[intCurrencyExchangeRateTypeId]		= ITG.[intCurrencyExchangeRateTypeId]
		,[intCurrencyExchangeRateId]			= ITG.[intCurrencyExchangeRateId]
		,[dblCurrencyExchangeRate]				= ITG.[dblCurrencyExchangeRate]
		,[intSubCurrencyId]						= ITG.[intSubCurrencyId]
		,[dblSubCurrencyRate]					= ITG.[dblSubCurrencyRate]
		,[ysnBlended]							= ITG.[ysnBlended]
		,[strImportFormat]						= ITG.[strImportFormat]
		,[dblCOGSAmount]						= ITG.[dblCOGSAmount]
		,[intConversionAccountId]				= ITG.[intConversionAccountId]
		,[intSalesAccountId]					= ITG.[intSalesAccountId]
		,[intStorageScheduleTypeId]				= ITG.[intStorageScheduleTypeId]
		,[intDestinationGradeId]				= ITG.[intDestinationGradeId]
		,[intDestinationWeightId]				= ITG.[intDestinationWeightId]
	FROM
		@InvoicesToGenerate ITG
	INNER JOIN
		@IntegrationLog IL
			ON ITG.[intId] = IL.[intId]
			AND IL.[ysnSuccess] = 1

	EXEC [dbo].[uspARAddItemToInvoices]
		 @InvoiceEntries	= @LineItems
		,@IntegrationLogId	= @IntegrationLogId
		,@UserId			= @UserId
		,@RaiseError		= @RaiseError
		,@ErrorMessage		= @AddDetailError	OUTPUT

		IF LEN(ISNULL(@AddDetailError,'')) > 0
			BEGIN
				IF ISNULL(@RaiseError,0) = 0
					ROLLBACK TRANSACTION
				SET @ErrorMessage = @AddDetailError;
				IF ISNULL(@RaiseError,0) = 1
					RAISERROR(@ErrorMessage, 16, 1);
				RETURN 0;
			END
END TRY
BEGIN CATCH
	IF ISNULL(@RaiseError,0) = 0
		ROLLBACK TRANSACTION
	SET @ErrorMessage = ERROR_MESSAGE();
	IF ISNULL(@RaiseError,0) = 1
		RAISERROR(@ErrorMessage, 16, 1);
	RETURN 0;
END CATCH

	
BEGIN TRY
	DECLARE @CreatedInvoiceIds InvoiceId	
	DELETE FROM @CreatedInvoiceIds

	INSERT INTO @CreatedInvoiceIds(
		 [intHeaderId]
		,[ysnUpdateAvailableDiscountOnly]
		,[intDetailId])
	SELECT 
		 [intHeaderId]						= [intInvoiceId]
		,[ysnUpdateAvailableDiscountOnly]	= [ysnUpdateAvailableDiscount]
		,[intDetailId]						= NULL
	 FROM @IntegrationLog WHERE [ysnSuccess] = 1

	EXEC [dbo].[uspARReComputeInvoicesAmounts] @InvoiceIds = @CreatedInvoiceIds

	DECLARE @InvoiceLog AuditLogStagingTable	
	DELETE FROM @InvoiceLog

	INSERT INTO @InvoiceLog(
		 [strScreenName]
		,[intKeyValueId]
		,[intEntityId]
		,[strActionType]
		,[strDescription]
		,[strActionIcon]
		,[strChangeDescription]
		,[strFromValue]
		,[strToValue]
		,[strDetails]
	)
	SELECT 
		 [strScreenName]			= 'AccountsReceivable.view.Invoice'
		,[intKeyValueId]			= ARI.[intInvoiceId]
		,[intEntityId]				= IL.[intEntityId]
		,[strActionType]			= 'Processed'
		,[strDescription]			= IL.[strSourceTransaction] + ' to Invoice'
		,[strActionIcon]			= NULL
		,[strChangeDescription]		= IL.[strSourceTransaction] + ' to Invoice'
		,[strFromValue]				= IL.[strSourceId]
		,[strToValue]				= ARI.[strInvoiceNumber]
		,[strDetails]				= NULL
	 FROM @IntegrationLog IL
	INNER JOIN
		(SELECT [intInvoiceId], [strInvoiceNumber] FROM tblARInvoice) ARI
			ON IL.[intInvoiceId] = ARI.[intInvoiceId]
	 WHERE
		[ysnSuccess] = 1 
		AND [ysnInsert] = 1

	EXEC [dbo].[uspSMInsertAuditLogs] @LogEntries = @InvoiceLog

END TRY
BEGIN CATCH
	IF ISNULL(@RaiseError,0) = 0
		ROLLBACK TRANSACTION
	SET @ErrorMessage = ERROR_MESSAGE();
	IF ISNULL(@RaiseError,0) = 1
		RAISERROR(@ErrorMessage, 16, 1);
	RETURN 0;
END CATCH

IF ISNULL(@RaiseError,0) = 0
	COMMIT TRANSACTION
SET @ErrorMessage = NULL;
RETURN 1;
	
END
GO