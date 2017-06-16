CREATE PROCEDURE [dbo].[uspARUpdateCustomerInvoices]
	 @InvoiceEntries	InvoiceStagingTable	READONLY
	,@IntegrationLogId	INT					= NULL
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

DECLARE @InvoicesToUpdate AS InvoiceStagingTable
DELETE FROM @InvoicesToUpdate
INSERT INTO @InvoicesToUpdate (
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
)
SELECT DISTINCT
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
	,[intLoadDistributionHeaderId]		= [intLoadDistributionHeaderId]
	,[strActualCostId]					= (CASE WHEN ISNULL([strSourceTransaction],'') = 'Transport Load' THEN [strActualCostId] ELSE NULL END)
	,[intShipmentId]					= [intShipmentId]
	,[intTransactionId] 				= [intTransactionId]
	,[intMeterReadingId]				= [intMeterReadingId]
	,[intContractHeaderId]				= [intContractHeaderId]
	,[intLoadId]						= [intLoadId]
	,[intOriginalInvoiceId]				= [intOriginalInvoiceId]
	,[intEntityId]						= [intEntityId]
	,[intTruckDriverId]					= [intTruckDriverId]
	,[intTruckDriverReferenceId]		= [intTruckDriverReferenceId]
	,[ysnResetDetails]					= [ysnResetDetails]
	,[ysnRecap]							= [ysnRecap]
	,[ysnPost]							= [ysnPost]
	,[ysnUpdateAvailableDiscount]		= [ysnUpdateAvailableDiscount]
	
FROM
	@InvoiceEntries 


DECLARE @InvalidRecords AS TABLE (
	 [intId]				INT
	,[strMessage]		NVARCHAR(500)	COLLATE Latin1_General_CI_AS	NULL
	,[strTransactionType]	NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
	,[strType]				NVARCHAR(100)	COLLATE Latin1_General_CI_AS	NULL
	,[strSourceTransaction]	NVARCHAR(250)	COLLATE Latin1_General_CI_AS	NOT NULL
	,[intSourceId]			INT												NULL
	,[strSourceId]			NVARCHAR(250)	COLLATE Latin1_General_CI_AS	NOT NULL
	,[intInvoiceId]			INT												NULL
)

INSERT INTO @InvalidRecords(
	 [intId]
	,[strMessage]		
	,[strTransactionType]
	,[strType]
	,[strSourceTransaction]
	,[intSourceId]
	,[strSourceId]
	,[intInvoiceId]
)
SELECT
	 [intId]				= ITG.[intId]
	,[strMessage]			= ITG.[strSourceTransaction] + ' does not exists!'
	,[strTransactionType]	= ITG.[strTransactionType]
	,[strType]				= ITG.[strType]
	,[strSourceTransaction]	= ITG.[strSourceTransaction]
	,[intSourceId]			= ITG.[intSourceId]
	,[strSourceId]			= ITG.[strSourceId]
	,[intInvoiceId]			= ITG.[intInvoiceId]
FROM
	@InvoicesToUpdate ITG --WITH (NOLOCK)
WHERE
	ISNULL([strSourceTransaction],'') = 'Transport Load'
	AND  NOT EXISTS(SELECT NULL FROM tblTRLoadDistributionHeader TR WITH (NOLOCK) WHERE TR.[intLoadDistributionHeaderId] = ITG.[intLoadDistributionHeaderId])

UNION ALL

SELECT
	 [intId]				= ITG.[intId]
	,[strMessage]			= ITG.[strSourceTransaction] + ' does not exists!'
	,[strTransactionType]	= ITG.[strTransactionType]
	,[strType]				= ITG.[strType]
	,[strSourceTransaction]	= ITG.[strSourceTransaction]
	,[intSourceId]			= ITG.[intSourceId]
	,[strSourceId]			= ITG.[strSourceId]
	,[intInvoiceId]			= ITG.[intInvoiceId]
FROM
	@InvoicesToUpdate ITG --WITH (NOLOCK)
WHERE
	ISNULL([strSourceTransaction],'') = 'Inbound Shipment'
	AND  NOT EXISTS(SELECT NULL FROM tblLGShipment LG WITH (NOLOCK) WHERE LG.[intShipmentId] = ITG.[intShipmentId])

UNION ALL

SELECT
	 [intId]				= ITG.[intId]
	,[strMessage]			= ITG.[strSourceTransaction] + ' does not exists!'
	,[strTransactionType]	= ITG.[strTransactionType]
	,[strType]				= ITG.[strType]
	,[strSourceTransaction]	= ITG.[strSourceTransaction]
	,[intSourceId]			= ITG.[intSourceId]
	,[strSourceId]			= ITG.[strSourceId]
	,[intInvoiceId]			= ITG.[intInvoiceId]
FROM
	@InvoicesToUpdate ITG --WITH (NOLOCK)
WHERE
	(	ISNULL([strSourceTransaction],'') = 'Card Fueling Transaction' 
		OR 
		ISNULL([strSourceTransaction],'') = 'CF Tran')
	AND  NOT EXISTS(SELECT NULL FROM tblCFTransaction CF WITH (NOLOCK) WHERE CF.[intTransactionId] = ITG.[intTransactionId])

UNION ALL

SELECT
	 [intId]				= ITG.[intId]
	,[strMessage]			= ITG.[strSourceTransaction] + ' does not exists!'
	,[strTransactionType]	= ITG.[strTransactionType]
	,[strType]				= ITG.[strType]
	,[strSourceTransaction]	= ITG.[strSourceTransaction]
	,[intSourceId]			= ITG.[intSourceId]
	,[strSourceId]			= ITG.[strSourceId]
	,[intInvoiceId]			= ITG.[intInvoiceId]
FROM
	@InvoicesToUpdate ITG --WITH (NOLOCK)
WHERE
	ISNULL([strSourceTransaction],'') = 'Meter Billing'
	AND  NOT EXISTS(SELECT NULL FROM tblMBMeterReading MB WITH (NOLOCK) WHERE MB.[intMeterReadingId] = ITG.[intMeterReadingId])

UNION ALL

SELECT
	 [intId]				= ITG.[intId]
	,[strMessage]			= ITG.[strSourceTransaction] + ' does not exists!'
	,[strTransactionType]	= ITG.[strTransactionType]
	,[strType]				= ITG.[strType]
	,[strSourceTransaction]	= ITG.[strSourceTransaction]
	,[intSourceId]			= ITG.[intSourceId]
	,[strSourceId]			= ITG.[strSourceId]
	,[intInvoiceId]			= ITG.[intInvoiceId]
FROM
	@InvoicesToUpdate ITG --WITH (NOLOCK)
WHERE
	ISNULL([strSourceTransaction],'') = 'Provisional'
	AND  NOT EXISTS(SELECT NULL FROM tblARInvoice ARI WITH (NOLOCK) WHERE ARI.[intInvoiceId] = ITG.[intInvoiceId])

--UNION ALL

--SELECT
--	 [intId]				= ITG.[intId]
--	,[strMessage]		= ITG.[strSourceTransaction] + ' does not exists!'
--	,[strTransactionType]	= ITG.[strTransactionType]
--	,[strType]				= ITG.[strType]
--	,[strSourceTransaction]	= ITG.[strSourceTransaction]
--	,[intSourceId]			= ITG.[intSourceId]
--	,[strSourceId]			= ITG.[strSourceId]
--	,[intInvoiceId]			= ITG.[intInvoiceId]
--FROM
--	@InvoicesToUpdate ITG --WITH (NOLOCK)
--WHERE
--	ISNULL([strSourceTransaction],'') = 'Inventory Shipment'
--	AND  NOT EXISTS(SELECT NULL FROM tblICInventoryShipment IC WITH (NOLOCK) WHERE IARC.[intInventoryShipmentId] = ITG.[intInventoryShipmentId])

UNION ALL

SELECT
	 [intId]				= ITG.[intId]
	,[strMessage]			= ITG.[strSourceTransaction] + ' does not exists!'
	,[strTransactionType]	= ITG.[strTransactionType]
	,[strType]				= ITG.[strType]
	,[strSourceTransaction]	= ITG.[strSourceTransaction]
	,[intSourceId]			= ITG.[intSourceId]
	,[strSourceId]			= ITG.[strSourceId]
	,[intInvoiceId]			= ITG.[intInvoiceId]
FROM
	@InvoicesToUpdate ITG --WITH (NOLOCK)
WHERE
	ISNULL([strSourceTransaction],'') = 'Sales Contract'
	AND  NOT EXISTS(SELECT NULL FROM tblCTContractHeader CT WITH (NOLOCK) WHERE CT.[intContractHeaderId] = ITG.[intContractHeaderId])

UNION ALL

SELECT
	 [intId]				= ITG.[intId]
	,[strMessage]			= ITG.[strSourceTransaction] + ' does not exists!'
	,[strTransactionType]	= ITG.[strTransactionType]
	,[strType]				= ITG.[strType]
	,[strSourceTransaction]	= ITG.[strSourceTransaction]
	,[intSourceId]			= ITG.[intSourceId]
	,[strSourceId]			= ITG.[strSourceId]
	,[intInvoiceId]			= ITG.[intInvoiceId]
FROM
	@InvoicesToUpdate ITG --WITH (NOLOCK)
WHERE
	ISNULL([strSourceTransaction],'') = 'Load Schedule'
	AND  NOT EXISTS(SELECT NULL FROM tblLGLoad LG WITH (NOLOCK) WHERE LG.[intLoadId] = ITG.[intLoadId])

UNION ALL

SELECT
	 [intId]				= ITG.[intId]
	,[strMessage]			= 'The company location Id provided does not exists!'
	,[strTransactionType]	= ITG.[strTransactionType]
	,[strType]				= ITG.[strType]
	,[strSourceTransaction]	= ITG.[strSourceTransaction]
	,[intSourceId]			= ITG.[intSourceId]
	,[strSourceId]			= ITG.[strSourceId]
	,[intInvoiceId]			= ITG.[intInvoiceId]
FROM
	@InvoicesToUpdate ITG --WITH (NOLOCK)
WHERE
	NOT EXISTS(SELECT NULL FROM tblSMCompanyLocation SMCL WITH (NOLOCK) WHERE SMCL.[intCompanyLocationId] = ITG.[intCompanyLocationId])

UNION ALL

SELECT
	 [intId]				= ITG.[intId]
	,[strMessage]			= 'The company location provided is not active!'
	,[strTransactionType]	= ITG.[strTransactionType]
	,[strType]				= ITG.[strType]
	,[strSourceTransaction]	= ITG.[strSourceTransaction]
	,[intSourceId]			= ITG.[intSourceId]
	,[strSourceId]			= ITG.[strSourceId]
	,[intInvoiceId]			= ITG.[intInvoiceId]
FROM
	@InvoicesToUpdate ITG --WITH (NOLOCK)
WHERE
	NOT EXISTS(SELECT NULL FROM tblSMCompanyLocation SMCL WITH (NOLOCK) WHERE SMCL.[intCompanyLocationId] IS NOT NULL AND SMCL.[intCompanyLocationId] = ITG.[intCompanyLocationId] AND SMCL.[ysnLocationActive] = 1)

UNION ALL

SELECT
	 [intId]				= ITG.[intId]
	,[strMessage]			= ITG.[strTransactionType] + ' is not a valid transaction type!'
	,[strTransactionType]	= ITG.[strTransactionType]
	,[strType]				= ITG.[strType]
	,[strSourceTransaction]	= ITG.[strSourceTransaction]
	,[intSourceId]			= ITG.[intSourceId]
	,[strSourceId]			= ITG.[strSourceId]
	,[intInvoiceId]			= ITG.[intInvoiceId]
FROM
	@InvoicesToUpdate ITG --WITH (NOLOCK)
WHERE
	ISNULL(ITG.[strTransactionType],'') NOT IN ('Invoice', 'Credit Memo', 'Debit Memo', 'Cash', 'Cash Refund', 'Overpayment', 'Customer Prepayment')

UNION ALL

SELECT
	 [intId]				= ITG.[intId]
	,[strMessage]			= ITG.[strType] + ' is not a valid invoice type!'
	,[strTransactionType]	= ITG.[strTransactionType]
	,[strType]				= ITG.[strType]
	,[strSourceTransaction]	= ITG.[strSourceTransaction]
	,[intSourceId]			= ITG.[intSourceId]
	,[strSourceId]			= ITG.[strSourceId]
	,[intInvoiceId]			= ITG.[intInvoiceId]
FROM
	@InvoicesToUpdate ITG --WITH (NOLOCK)
WHERE
	ISNULL(ITG.[strType],'') NOT IN ('Meter Billing', 'Standard', 'Software', 'Tank Delivery', 'Provisional', 'Service Charge', 'Transport Delivery', 'Store', 'Card Fueling', 'CF Tran', 'CF Invoice')

UNION ALL

SELECT
	 [intId]				= ITG.[intId]
	,[strMessage]			= 'The customer Id provided does not exists!'
	,[strTransactionType]	= ITG.[strTransactionType]
	,[strType]				= ITG.[strType]
	,[strSourceTransaction]	= ITG.[strSourceTransaction]
	,[intSourceId]			= ITG.[intSourceId]
	,[strSourceId]			= ITG.[strSourceId]
	,[intInvoiceId]			= ITG.[intInvoiceId]
FROM
	@InvoicesToUpdate ITG --WITH (NOLOCK)
WHERE
	NOT EXISTS(SELECT NULL FROM tblARCustomer ARC WITH (NOLOCK) WHERE ARC.[intEntityCustomerId] = ITG.[intEntityCustomerId])

UNION ALL

SELECT
	 [intId]				= ITG.[intId]
	,[strMessage]			= 'The customer provided is not active!'
	,[strTransactionType]	= ITG.[strTransactionType]
	,[strType]				= ITG.[strType]
	,[strSourceTransaction]	= ITG.[strSourceTransaction]
	,[intSourceId]			= ITG.[intSourceId]
	,[strSourceId]			= ITG.[strSourceId]
	,[intInvoiceId]			= ITG.[intInvoiceId]
FROM
	@InvoicesToUpdate ITG --WITH (NOLOCK)
WHERE
	NOT EXISTS(SELECT NULL FROM tblARCustomer ARC WITH (NOLOCK) WHERE ARC.[intEntityCustomerId] = ITG.[intEntityCustomerId] AND ARC.[ysnActive] = 1)


UNION ALL

SELECT
	 [intId]				= ITG.[intId]
	,[strMessage]			= 'The entity Id provided does not exists!'
	,[strTransactionType]	= ITG.[strTransactionType]
	,[strType]				= ITG.[strType]
	,[strSourceTransaction]	= ITG.[strSourceTransaction]
	,[intSourceId]			= ITG.[intSourceId]
	,[strSourceId]			= ITG.[strSourceId]
	,[intInvoiceId]			= ITG.[intInvoiceId]
FROM
	@InvoicesToUpdate ITG --WITH (NOLOCK)
WHERE
	NOT EXISTS(SELECT NULL FROM tblEMEntity EME WITH (NOLOCK) WHERE EME.[intEntityId] = ITG.[intEntityId])
	
--UNION ALL

--SELECT
--	 [intId]				= ITG.[intId]
--	,[strMessage]			= 'There is no setup for AR Account in the Company Configuration.'
--	,[strTransactionType]	= ITG.[strTransactionType]
--	,[strType]				= ITG.[strType]
--	,[strSourceTransaction]	= ITG.[strSourceTransaction]
--	,[intSourceId]			= ITG.[intSourceId]
--	,[strSourceId]			= ITG.[strSourceId]
--	,[intInvoiceId]			= ITG.[intInvoiceId]
--FROM
--	@InvoicesToUpdate ITG --WITH (NOLOCK)
--WHERE
--	ITG.[intAccountId] IS NULL
--	AND ITG.[strTransactionType] NOT IN ('Customer Prepayment', 'Cash', 'Cash Refund')

--UNION ALL

--SELECT
--	 [intId]				= ITG.[intId]
--	,[strMessage]			= 'The account id provided is not a valid account of category "AR Account".'
--	,[strTransactionType]	= ITG.[strTransactionType]
--	,[strType]				= ITG.[strType]
--	,[strSourceTransaction]	= ITG.[strSourceTransaction]
--	,[intSourceId]			= ITG.[intSourceId]
--	,[strSourceId]			= ITG.[strSourceId]
--	,[intInvoiceId]			= ITG.[intInvoiceId]
--FROM
--	@InvoicesToUpdate ITG --WITH (NOLOCK)
--WHERE
--	ITG.[intAccountId] IS NOT NULL
--	AND ITG.[strTransactionType] NOT IN ('Customer Prepayment', 'Cash', 'Cash Refund')
--	AND NOT EXISTS (SELECT NULL FROM vyuGLAccountDetail GLAD WITH (NOLOCK) WHERE GLAD.[strAccountCategory] = 'AR Account' AND GLAD.[intAccountId] =  ITG.[intAccountId])

--UNION ALL

--SELECT
--	 [intId]				= ITG.[intId]
--	,[strMessage]			= 'There is no Undeposited Funds account setup under Company Location - ' + SMCL.[strLocationName]
--	,[strTransactionType]	= ITG.[strTransactionType]
--	,[strType]				= ITG.[strType]
--	,[strSourceTransaction]	= ITG.[strSourceTransaction]
--	,[intSourceId]			= ITG.[intSourceId]
--	,[strSourceId]			= ITG.[strSourceId]
--	,[intInvoiceId]			= ITG.[intInvoiceId]
--FROM
--	@InvoicesToUpdate ITG --WITH (NOLOCK)
--INNER JOIN
--	(SELECT CL.[intCompanyLocationId], CL.[strLocationName] FROM tblSMCompanyLocation CL WITH (NOLOCK)) SMCL
--		ON SMCL.[intCompanyLocationId] = ITG.[intCompanyLocationId]
--WHERE
--	ITG.[intAccountId] IS NULL
--	AND ITG.[strTransactionType] IN ('Cash', 'Cash Refund')

--UNION ALL

--SELECT
--	 [intId]				= ITG.[intId]
--	,[strMessage]			= 'The account id provided is not a valid account of category "Undeposited Funds".'
--	,[strTransactionType]	= ITG.[strTransactionType]
--	,[strType]				= ITG.[strType]
--	,[strSourceTransaction]	= ITG.[strSourceTransaction]
--	,[intSourceId]			= ITG.[intSourceId]
--	,[strSourceId]			= ITG.[strSourceId]
--	,[intInvoiceId]			= ITG.[intInvoiceId]
--FROM
--	@InvoicesToUpdate ITG --WITH (NOLOCK)
--INNER JOIN
--	(SELECT CL.[intCompanyLocationId], CL.[strLocationName] FROM tblSMCompanyLocation CL WITH (NOLOCK)) SMCL
--		ON SMCL.[intCompanyLocationId] = ITG.[intCompanyLocationId]
--WHERE
--	ITG.[intAccountId] IS NOT NULL
--	AND ITG.[strTransactionType] IN ('Cash', 'Cash Refund')
--	AND NOT EXISTS (SELECT NULL FROM vyuGLAccountDetail GLAD WITH (NOLOCK) WHERE GLAD.[strAccountCategory] = 'Undeposited Funds' AND GLAD.[intAccountId] =  ITG.[intAccountId])

--UNION ALL

--SELECT
--	 [intId]				= ITG.[intId]
--	,[strMessage]			= 'There is no Customer Prepaid account setup under Company Location - ' + SMCL.[strLocationName]
--	,[strTransactionType]	= ITG.[strTransactionType]
--	,[strType]				= ITG.[strType]
--	,[strSourceTransaction]	= ITG.[strSourceTransaction]
--	,[intSourceId]			= ITG.[intSourceId]
--	,[strSourceId]			= ITG.[strSourceId]
--	,[intInvoiceId]			= ITG.[intInvoiceId]
--FROM
--	@InvoicesToUpdate ITG --WITH (NOLOCK)
--INNER JOIN
--	(SELECT CL.[intCompanyLocationId], CL.[strLocationName] FROM tblSMCompanyLocation CL WITH (NOLOCK)) SMCL
--		ON SMCL.[intCompanyLocationId] = ITG.[intCompanyLocationId]
--WHERE
--	ITG.[intAccountId] IS NULL
--	AND ITG.[strTransactionType] = 'Customer Prepayment'

--UNION ALL

--SELECT
--	 [intId]				= ITG.[intId]
--	,[strMessage]			= 'The account id provided is not a valid account of category "Customer Prepayments".'
--	,[strTransactionType]	= ITG.[strTransactionType]
--	,[strType]				= ITG.[strType]
--	,[strSourceTransaction]	= ITG.[strSourceTransaction]
--	,[intSourceId]			= ITG.[intSourceId]
--	,[strSourceId]			= ITG.[strSourceId]
--	,[intInvoiceId]			= ITG.[intInvoiceId]
--FROM
--	@InvoicesToUpdate ITG --WITH (NOLOCK)
--INNER JOIN
--	(SELECT CL.[intCompanyLocationId], CL.[strLocationName] FROM tblSMCompanyLocation CL WITH (NOLOCK)) SMCL
--		ON SMCL.[intCompanyLocationId] = ITG.[intCompanyLocationId]
--WHERE
--	ITG.[intAccountId] IS NOT NULL
--	AND ITG.[strTransactionType] = 'Customer Prepayment'
--	AND NOT EXISTS (SELECT NULL FROM vyuGLAccountDetail GLAD WITH (NOLOCK) WHERE GLAD.[strAccountCategory] = 'Customer Prepayments' AND GLAD.[intAccountId] =  ITG.[intAccountId])

UNION ALL

SELECT
	 [intId]				= ITG.[intId]
	,[strMessage]			= 'The currency Id provided does not exists!'
	,[strTransactionType]	= ITG.[strTransactionType]
	,[strType]				= ITG.[strType]
	,[strSourceTransaction]	= ITG.[strSourceTransaction]
	,[intSourceId]			= ITG.[intSourceId]
	,[strSourceId]			= ITG.[strSourceId]
	,[intInvoiceId]			= ITG.[intInvoiceId]
FROM
	@InvoicesToUpdate ITG --WITH (NOLOCK)
WHERE
	ITG.[intCurrencyId] IS NOT NULL
	AND NOT EXISTS (SELECT NULL FROM tblSMCurrency SMC WITH (NOLOCK) WHERE SMC.[intCurrencyID] = ITG.[intCurrencyId])

UNION ALL

SELECT
	 [intId]				= ITG.[intId]
	,[strMessage]			= 'Currency is required!'
	,[strTransactionType]	= ITG.[strTransactionType]
	,[strType]				= ITG.[strType]
	,[strSourceTransaction]	= ITG.[strSourceTransaction]
	,[intSourceId]			= ITG.[intSourceId]
	,[strSourceId]			= ITG.[strSourceId]
	,[intInvoiceId]			= ITG.[intInvoiceId]
FROM
	@InvoicesToUpdate ITG --WITH (NOLOCK)
WHERE
	ITG.[intCurrencyId] IS NULL

UNION ALL

SELECT
	 [intId]				= ITG.[intId]
	,[strMessage]			= 'Term is required!' 
	,[strTransactionType]	= ITG.[strTransactionType]
	,[strType]				= ITG.[strType]
	,[strSourceTransaction]	= ITG.[strSourceTransaction]
	,[intSourceId]			= ITG.[intSourceId]
	,[strSourceId]			= ITG.[strSourceId]
	,[intInvoiceId]			= ITG.[intInvoiceId]
FROM
	@InvoicesToUpdate ITG --WITH (NOLOCK)
WHERE
	ITG.[intTermId] IS NULL
	
DELETE FROM V
FROM @InvoicesToUpdate V
WHERE EXISTS(SELECT NULL FROM @InvalidRecords I WHERE V.[intId] = I.[intId])


IF ISNULL(@RaiseError,0) = 1 AND EXISTS(SELECT TOP 1 NULL FROM @InvalidRecords)
BEGIN
	SET @ErrorMessage = (SELECT TOP 1 [strMessage] FROM @InvalidRecords ORDER BY [intId])
	RAISERROR(@ErrorMessage, 16, 1);
	RETURN 0;
END


IF ISNULL(@RaiseError,0) = 0	
	BEGIN TRANSACTION

DECLARE  @IntegrationLog InvoiceIntegrationLogStagingTable
INSERT INTO @IntegrationLog
	([intIntegrationLogId]
	,[dtmDate]
	,[intEntityId]
	,[intGroupingOption]
	,[strMessage]
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
	,[intGroupingOption]					= 0
	,[strMessage]							= [strMessage]
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

DECLARE @UpdatedInvoiceIds InvoiceId	
DELETE FROM @UpdatedInvoiceIds

BEGIN TRY
	UPDATE ARI
	   SET ARI.[strInvoiceNumber]				= ARI.[strInvoiceNumber]
		  ,ARI.[strTransactionType]				= ITG.[strTransactionType]
		  ,ARI.[strType]						= ITG.[strType]
		  ,ARI.[intEntityCustomerId]			= ITG.[intEntityCustomerId]
		  ,ARI.[intCompanyLocationId]			= ITG.[intCompanyLocationId]
		  --,ARI.[intAccountId]					= ITG.[intAccountId]
		  ,ARI.[intCurrencyId]					= ITG.[intCurrencyId]
		  ,ARI.[intTermId]						= ISNULL(ITG.[intTermId], ARC.[intTermsId])
		  ,ARI.[intSourceId]					= dbo.[fnARValidateInvoiceSourceId](ITG.[strSourceTransaction], ITG.[intSourceId])
		  ,ARI.[intPeriodsToAccrue]				= ISNULL(ITG.[intPeriodsToAccrue], 1)
		  ,ARI.[dtmDate]						= ITG.[dtmDate]
		  ,ARI.[dtmDueDate]						= ISNULL(ITG.[dtmDueDate], (CAST(dbo.fnGetDueDateBasedOnTerm(ITG.[dtmDate], ISNULL(ISNULL(ITG.[intTermId], ARC.[intTermsId]),0)) AS DATE)))
		  ,ARI.[dtmShipDate]					= ITG.[dtmShipDate]
		  ,ARI.[dtmPostDate]					= ITG.[dtmPostDate]
		  --,ARI.[dtmCalculated]				= ARI.[dtmCalculated]
		  --,ARI.[dblInvoiceSubtotal]			= ARI.[dblInvoiceSubtotal]
		  --,ARI.[dblBaseInvoiceSubtotal]		= ARI.[dblBaseInvoiceSubtotal]
		  --,ARI.[dblShipping]					= ARI.[dblShipping]
		  --,ARI.[dblBaseShipping]				= ARI.[dblBaseShipping]
		  --,ARI.[dblTax]						= ARI.[dblTax]
		  --,ARI.[dblBaseTax]					= ARI.[dblBaseTax]
		  --,ARI.[dblInvoiceTotal]				= ARI.[dblInvoiceTotal]
		  --,ARI.[dblBaseInvoiceTotal]			= ARI.[dblBaseInvoiceTotal]
		  --,ARI.[dblDiscount]					= ARI.[dblDiscount]
		  --,ARI.[dblBaseDiscount]				= ARI.[dblBaseDiscount]
		  --,ARI.[dblDiscountAvailable]			= ARI.[dblDiscountAvailable]
		  --,ARI.[dblBaseDiscountAvailable]		= ARI.[dblBaseDiscountAvailable]
		  --,ARI.[dblInterest]					= ARI.[dblInterest]
		  --,ARI.[dblBaseInterest]				= ARI.[dblBaseInterest]
		  --,ARI.[dblAmountDue]					= ARI.[dblAmountDue]
		  --,ARI.[dblBaseAmountDue]				= ARI.[dblBaseAmountDue]
		  --,ARI.[dblPayment]					= ARI.[dblPayment]
		  --,ARI.[dblBasePayment]				= ARI.[dblBasePayment]
		  ,ARI.[intEntitySalespersonId]			= ISNULL(ITG.[intEntitySalespersonId], ARC.[intSalespersonId])
		  ,ARI.[intFreightTermId]				= ITG.[intFreightTermId]
		  ,ARI.[intShipViaId]					= ISNULL(ITG.[intShipViaId], EL.[intShipViaId])
		  ,ARI.[intPaymentMethodId]				= ITG.[intPaymentMethodId]
		  ,ARI.[strInvoiceOriginId]				= ITG.[strInvoiceOriginId]
		  ,ARI.[strPONumber]					= ITG.[strPONumber]
		  ,ARI.[strBOLNumber]					= ITG.[strBOLNumber]
		  ,ARI.[strDeliverPickup]				= ITG.[strDeliverPickup]
		  ,ARI.[strComments]					= ITG.[strComments]
		  --,ARI.[strFooterComments]			= ARI.[strFooterComments]
		  ,ARI.[intShipToLocationId]			= ISNULL(ITG.[intShipToLocationId], ISNULL(SL1.[intEntityLocationId], EL.[intEntityLocationId]))
		  ,ARI.[strShipToLocationName]			= ISNULL(SL.[strLocationName], ISNULL(SL1.[strLocationName], EL.[strLocationName]))
		  ,ARI.[strShipToAddress]				= ISNULL(SL.[strAddress], ISNULL(SL1.[strAddress], EL.[strAddress]))
		  ,ARI.[strShipToCity]					= ISNULL(SL.[strCity], ISNULL(SL1.[strCity], EL.[strCity]))
		  ,ARI.[strShipToState]					= ISNULL(SL.[strState], ISNULL(SL1.[strState], EL.[strState]))
		  ,ARI.[strShipToZipCode]				= ISNULL(SL.[strZipCode], ISNULL(SL1.[strZipCode], EL.[strZipCode]))
		  ,ARI.[strShipToCountry]				= ISNULL(SL.[strCountry], ISNULL(SL1.[strCountry], EL.[strCountry]))
		  ,ARI.[intBillToLocationId]			= ISNULL(ITG.[intBillToLocationId], ISNULL(BL1.[intEntityLocationId], EL.[intEntityLocationId]))
		  ,ARI.[strBillToLocationName]			= ISNULL(BL.[strLocationName], ISNULL(BL1.[strLocationName], EL.[strLocationName]))
		  ,ARI.[strBillToAddress]				= ISNULL(BL.[strAddress], ISNULL(BL1.[strAddress], EL.[strAddress]))
		  ,ARI.[strBillToCity]					= ISNULL(BL.[strCity], ISNULL(BL1.[strCity], EL.[strCity]))
		  ,ARI.[strBillToState]					= ISNULL(BL.[strState], ISNULL(BL1.[strState], EL.[strState]))
		  ,ARI.[strBillToZipCode]				= ISNULL(BL.[strZipCode], ISNULL(BL1.[strZipCode], EL.[strZipCode]))
		  ,ARI.[strBillToCountry]				= ISNULL(BL.[strCountry], ISNULL(BL1.[strCountry], EL.[strCountry]))
		  --,ARI.[ysnPosted]					= ARI.[ysnPosted]
		  --,ARI.[ysnPaid]						= ARI.[ysnPaid]
		  --,ARI.[ysnProcessed]					= ARI.[ysnProcessed]
		  --,ARI.[ysnRecurring]					= ARI.[ysnRecurring]
		  ,ARI.[ysnForgiven]					= ISNULL(ITG.[ysnForgiven], 0)
		  ,ARI.[ysnCalculated]					= ISNULL(ITG.[ysnCalculated], 0)
		  ,ARI.[ysnSplitted]					= ISNULL(ITG.[ysnSplitted], 0)
		  --,ARI.[dblSplitPercent]				= ARI.[dblSplitPercent]
		  --,ARI.[ysnImpactInventory]			= ARI.[ysnImpactInventory]
		  --,ARI.[ysnImportedFromOrigin]		= ARI.[ysnImportedFromOrigin]
		  --,ARI.[ysnImportedAsPosted]			= ARI.[ysnImportedAsPosted]
		  ,ARI.[intPaymentId]					= ITG.[intPaymentId]
		  ,ARI.[intSplitId]						= ITG.[intSplitId]
		  ,ARI.[intDistributionHeaderId]		= ARI.[intDistributionHeaderId]
		  ,ARI.[intLoadDistributionHeaderId]	= ITG.[intLoadDistributionHeaderId]
		  ,ARI.[strActualCostId]				= ITG.[strActualCostId]
		  ,ARI.[strImportFormat]				= ITG.[strImportFormat]
		  ,ARI.[intShipmentId]					= ITG.[intShipmentId]
		  ,ARI.[intTransactionId]				= ITG.[intTransactionId]
		  ,ARI.[intMeterReadingId]				= ITG.[intMeterReadingId]
		  ,ARI.[intContractHeaderId]			= ITG.[intContractHeaderId]
		  ,ARI.[intOriginalInvoiceId]			= ITG.[intOriginalInvoiceId]
		  ,ARI.[intLoadId]						= ITG.[intLoadId]
		  ,ARI.[intEntityId]					= ITG.[intEntityId]
		  ,ARI.[intEntityContactId]				= ITG.[intEntityContactId]
		  --,ARI.[dblTotalWeight]				= ARI.[dblTotalWeight]
		  ,ARI.[intDocumentMaintenanceId]		= ITG.[intDocumentMaintenanceId]
		  --,ARI.[dblTotalTermDiscount]			= ARI.[dblTotalTermDiscount]
		  ,ARI.[intTruckDriverId]				= ITG.[intTruckDriverId]
		  ,ARI.[intTruckDriverReferenceId]		= ITG.[intTruckDriverReferenceId]
		  ,ARI.[intConcurrencyId]				= ARI.[intConcurrencyId] + 1
	OUTPUT  
			@IntegrationLogId						--[intIntegrationLogId]
			,@DateOnly								--[dtmDate]
			,@UserId								--[intEntityId]
			,0										--[intGroupingOption]
			,'Invoice was successfully updated.'	--[strErrorMessage]
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
			,ITG.[intInvoiceId]						--[intInvoiceId]
			,ITG.[intEntityCustomerId]				--[intEntityCustomerId]
			,ITG.[intCompanyLocationId]				--[intCompanyLocationId]
			,ITG.[intCurrencyId]					--[intCurrencyId]
			,ITG.[intTermId]						--[intTermId]
			,NULL									--[intInvoiceDetailId]
			,ITG.[intId]							--[intId]
			,ITG.[strTransactionType]				--[strTransactionType]
			,ITG.[strType]							--[strType]
			,ITG.[strSourceTransaction]				--[strSourceTransaction]
			,ITG.[intSourceId]						--[intSourceId]
			,ITG.[strSourceId]						--[strSourceId]
			,ITG.[ysnPost]							--[ysnPost]
			,0										--[ysnInsert]
			,1										--[ysnHeader]
			,1										--[ysnSuccess]
			,ITG.[ysnRecap]							--[ysnRecap]
		INTO @IntegrationLog(
			 [intIntegrationLogId]
			,[dtmDate]
			,[intEntityId]
			,[intGroupingOption]
			,[strMessage]
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
			,[ysnRecap]
		)
	FROM
		tblARInvoice AS ARI
	INNER JOIN			
		@InvoicesToUpdate ITG --WITH (NOLOCK)
			ON ARI.[intInvoiceId] = ITG.[intInvoiceId]
	INNER JOIN tblARCustomer ARC
			ON ARI.[intEntityCustomerId] = ARC.[intEntityCustomerId]
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
							[tblEMEntityLocation]
						WHERE
							ysnDefaultLocation = 1
					) EL
						ON ARC.[intEntityCustomerId] = EL.[intEntityId]
	LEFT OUTER JOIN
		[tblEMEntityLocation] SL
			ON ISNULL(ITG.[intShipToLocationId], 0) <> 0
			AND ITG.[intShipToLocationId] = SL.intEntityLocationId
	LEFT OUTER JOIN
		[tblEMEntityLocation] SL1
			ON ARC.intShipToId = SL1.intEntityLocationId
	LEFT OUTER JOIN
		[tblEMEntityLocation] BL
			ON ISNULL(ITG.[intBillToLocationId], 0) <> 0
			AND ITG.[intBillToLocationId] = BL.intEntityLocationId		
	LEFT OUTER JOIN
		[tblEMEntityLocation] BL1
			ON ARC.intShipToId = BL1.intEntityLocationId		
	WHERE
		ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0
	
	IF ISNULL(@IntegrationLogId, 0) <> 0
		EXEC [uspARInsertInvoiceIntegrationLogDetail] @IntegrationLogEntries = @IntegrationLog

	INSERT INTO @UpdatedInvoiceIds(
		 [intHeaderId]
		,[ysnUpdateAvailableDiscountOnly]
		,[intDetailId]
		,[strTransactionType])
	SELECT 
		 [intHeaderId]						= [intInvoiceId]
		,[ysnUpdateAvailableDiscountOnly]	= [ysnUpdateAvailableDiscount]
		,[intDetailId]						= NULL
		,[strTransactionType]				= [strTransactionType]
	 FROM @IntegrationLog WHERE [ysnSuccess] = 1

	EXEC [dbo].[uspARInsertTransactionDetails] @InvoiceIds = @UpdatedInvoiceIds
	
END TRY
BEGIN CATCH
	IF ISNULL(@RaiseError,0) = 0
		ROLLBACK TRANSACTION
	SET @ErrorMessage = ERROR_MESSAGE();
	IF ISNULL(@RaiseError,0) = 1
		RAISERROR(@ErrorMessage, 16, 1);
	RETURN 0;
END CATCH


DECLARE @AddDetailError NVARCHAR(MAX) = NULL
BEGIN TRY
	DELETE FROM tblARInvoiceDetailTax
	WHERE 
		EXISTS(	SELECT
					NULL
				FROM
					tblARInvoiceDetail ARID 
				INNER JOIN @InvoiceEntries ITG 
					ON ARID.[intInvoiceId] = ITG.[intInvoiceId] 
				INNER JOIN @IntegrationLog IL 
					ON ITG.[intInvoiceId] = IL.[intInvoiceId] 
				WHERE
					ARID.[intInvoiceId] = IL.[intInvoiceId]
					AND IL.[ysnSuccess] = 1
					AND ISNULL(ITG.[ysnResetDetails], 0) = 1
			)

	DELETE FROM tblARInvoiceDetail 
	WHERE 
		EXISTS(	
			SELECT
				NULL
			FROM
				@InvoiceEntries ITG
			INNER JOIN @IntegrationLog IL 
				ON ITG.[intInvoiceId] = IL.[intInvoiceId]
			WHERE
				tblARInvoiceDetail.[intInvoiceId] = IL.[intInvoiceId]
				AND IL.[ysnSuccess] = 1 
				AND ISNULL(ITG.[ysnResetDetails], 0) = 1)

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
		@InvoiceEntries ITG
	INNER JOIN
		@IntegrationLog IL
			ON ITG.[intInvoiceId] = IL.[intInvoiceId]
			
	WHERE
		IL.[ysnSuccess] = 1
		AND ISNULL(ITG.[ysnResetDetails], 0) = 1

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
	UPDATE ARID
	SET 
		 ARID.[strDocumentNumber]					= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[strDocumentNumber] ELSE ARID.[strDocumentNumber] END
		,ARID.[intItemId]							= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[intItemId] ELSE ARID.[intItemId] END
		,ARID.[intPrepayTypeId]						= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[intPrepayTypeId] ELSE ARID.[intPrepayTypeId] END
		,ARID.[dblPrepayRate]						= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[dblPrepayRate] ELSE ARID.[dblPrepayRate] END
		,ARID.[strItemDescription]					= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[strItemDescription] ELSE ARID.[strItemDescription] END
		,ARID.[dblQtyOrdered]						= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[dblQtyOrdered] ELSE ARID.[dblQtyOrdered] END
		,ARID.[intOrderUOMId]						= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[intOrderUOMId] ELSE ARID.[intOrderUOMId] END
		,ARID.[dblQtyShipped]						= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[dblQtyShipped] ELSE ARID.[dblQtyShipped] END
		,ARID.[intItemUOMId]						= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[intItemUOMId] ELSE ARID.[intItemUOMId] END
		,ARID.[dblItemWeight]						= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[dblItemWeight] ELSE ARID.[dblItemWeight] END
		,ARID.[intItemWeightUOMId]					= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[intItemWeightUOMId] ELSE ARID.[intItemWeightUOMId] END
		,ARID.[dblDiscount]							= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[dblDiscount] ELSE ARID.[dblDiscount] END
		,ARID.[dblItemTermDiscount]					= ITG.[dblItemTermDiscount]
		,ARID.[strItemTermDiscountBy]				= ITG.[strItemTermDiscountBy]
		,ARID.[dblPrice]							= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN 
																		(CASE WHEN (ISNULL(ITG.[ysnRefreshPrice], 0) = 1) THEN ITG.[dblPrice] / ISNULL(ITG.[dblSubCurrencyRate], 1) ELSE ITG.[dblPrice] END)
																	ELSE
																		ARID.[dblPrice]
																  END
		,ARID.[dblBasePrice]						= ARID.[dblBasePrice]
		,ARID.[strPricing]							= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[strPricing] ELSE ARID.[strPricing] END
		,ARID.[dblTotalTax]							= ARID.[dblTotalTax]
		,ARID.[dblBaseTotalTax]						= [dblBaseTotalTax]
		--,ARID.[dblTotal]							= ARID.[dblTotal]
		--,ARID.[dblBaseTotal]						= ARID.[dblBaseTotal]
		,ARID.[intCurrencyExchangeRateTypeId]		= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[intCurrencyExchangeRateTypeId] ELSE ARID.[intCurrencyExchangeRateTypeId] END
		,ARID.[intCurrencyExchangeRateId]			= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[intCurrencyExchangeRateId] ELSE ARID.[intCurrencyExchangeRateId] END
		,ARID.[dblCurrencyExchangeRate]				= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[dblCurrencyExchangeRate] ELSE ARID.[dblCurrencyExchangeRate] END
		,ARID.[intSubCurrencyId]					= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[intSubCurrencyId] ELSE ARID.[intSubCurrencyId] END
		,ARID.[dblSubCurrencyRate]					= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[dblSubCurrencyRate] ELSE ARID.[dblSubCurrencyRate] END
		,ARID.[ysnRestricted]						= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[ysnRestricted] ELSE ARID.[ysnRestricted] END
		,ARID.[ysnBlended]							= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[ysnBlended] ELSE ARID.[ysnBlended] END
		,ARID.[intAccountId]						= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[intAccountId] ELSE ARID.[intAccountId] END
		--,ARID.[intCOGSAccountId]					= ARID.[intCOGSAccountId]
		,ARID.[intSalesAccountId]					= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[intSalesAccountId] ELSE ARID.[intSalesAccountId] END
		--,ARID.[intInventoryAccountId]				= ARID.[intInventoryAccountId]
		--,ARID.[intServiceChargeAccountId]			= ARID.[intServiceChargeAccountId]
		,ARID.[intLicenseAccountId]					= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[intLicenseAccountId] ELSE ARID.[intLicenseAccountId] END
		,ARID.[intMaintenanceAccountId]				= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[intMaintenanceAccountId] ELSE ARID.[intMaintenanceAccountId] END
		,ARID.[strMaintenanceType]					= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[strMaintenanceType] ELSE ARID.[strMaintenanceType] END
		,ARID.[strFrequency]						= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[strFrequency] ELSE ARID.[strFrequency] END
		,ARID.[dtmMaintenanceDate]					= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[dtmMaintenanceDate] ELSE ARID.[dtmMaintenanceDate] END
		,ARID.[dblMaintenanceAmount]				= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[dblMaintenanceAmount] ELSE ARID.[dblMaintenanceAmount] END
		--,ARID.[dblBaseMaintenanceAmount]			= ARID.[dblBaseMaintenanceAmount]
		,ARID.[dblLicenseAmount]					= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[dblLicenseAmount] ELSE ARID.[dblLicenseAmount] END
		--,ARID.[dblBaseLicenseAmount]				= ARID.[dblBaseLicenseAmount]
		,ARID.[intTaxGroupId]						= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[intTaxGroupId] ELSE ARID.[intTaxGroupId] END
		,ARID.[intStorageLocationId]				= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[intStorageLocationId] ELSE ARID.[intStorageLocationId] END
		,ARID.[intCompanyLocationSubLocationId]		= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[intCompanyLocationSubLocationId] ELSE ARID.[intCompanyLocationSubLocationId] END
		,ARID.[intSCInvoiceId]						= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[intSCInvoiceId] ELSE ARID.[intSCInvoiceId] END
		,ARID.[intSCBudgetId]						= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[intSCBudgetId] ELSE ARID.[intSCBudgetId] END
		,ARID.[strSCInvoiceNumber]					= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[strSCInvoiceNumber] ELSE ARID.[strSCInvoiceNumber] END
		,ARID.[strSCBudgetDescription]				= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[strSCBudgetDescription] ELSE ARID.[strSCBudgetDescription] END
		,ARID.[intInventoryShipmentItemId]			= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[intInventoryShipmentItemId] ELSE ARID.[intInventoryShipmentItemId] END
		,ARID.[intInventoryShipmentChargeId]		= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[intInventoryShipmentChargeId] ELSE ARID.[intInventoryShipmentChargeId] END
		,ARID.[intRecipeItemId]						= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[intRecipeItemId] ELSE ARID.[intRecipeItemId] END
		,ARID.[strShipmentNumber]					= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[strShipmentNumber] ELSE ARID.[strShipmentNumber] END
		,ARID.[intSalesOrderDetailId]				= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[intSalesOrderDetailId] ELSE ARID.[intSalesOrderDetailId] END
		,ARID.[strSalesOrderNumber]					= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[strSalesOrderNumber] ELSE ARID.[strSalesOrderNumber] END
		,ARID.[strVFDDocumentNumber]				= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[strVFDDocumentNumber] ELSE ARID.[strVFDDocumentNumber] END
		,ARID.[intContractHeaderId]					= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[intContractHeaderId] ELSE ARID.[intContractHeaderId] END
		,ARID.[intContractDetailId]					= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[intContractDetailId] ELSE ARID.[intContractDetailId] END
		--,ARID.[dblContractBalance]				= ARID.[dblContractBalance]
		--,ARID.[dblContractAvailable]				= ARID.[dblContractAvailable]
		,ARID.[intShipmentId]						= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[intShipmentId] ELSE ARID.[intShipmentId] END
		,ARID.[intShipmentPurchaseSalesContractId]	= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[intShipmentPurchaseSalesContractId] ELSE ARID.[intShipmentPurchaseSalesContractId] END
		,ARID.[dblShipmentGrossWt]					= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[dblShipmentGrossWt] ELSE ARID.[dblShipmentGrossWt] END
		,ARID.[dblShipmentTareWt]					= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[dblShipmentTareWt] ELSE ARID.[dblShipmentTareWt] END
		,ARID.[dblShipmentNetWt]					= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[dblShipmentNetWt] ELSE ARID.[dblShipmentNetWt] END
		,ARID.[intTicketId]							= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[intTicketId] ELSE ARID.[intTicketId] END
		,ARID.[intTicketHoursWorkedId]				= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[intTicketHoursWorkedId] ELSE ARID.[intTicketHoursWorkedId] END
		,ARID.[intCustomerStorageId]				= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[intCustomerStorageId] ELSE ARID.[intCustomerStorageId] END
		,ARID.[intSiteDetailId]						= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[intSiteDetailId] ELSE ARID.[intSiteDetailId] END
		,ARID.[intLoadDetailId]						= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[intLoadDetailId] ELSE ARID.[intLoadDetailId] END
		,ARID.[intLotId]							= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[intLotId] ELSE ARID.[intLotId] END
		,ARID.[intOriginalInvoiceDetailId]			= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[intOriginalInvoiceDetailId] ELSE ARID.[intOriginalInvoiceDetailId] END
		,ARID.[intConversionAccountId]				= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[intConversionAccountId] ELSE ARID.[intConversionAccountId] END
		,ARID.[intEntitySalespersonId]				= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[intEntitySalespersonId] ELSE ARID.[intEntitySalespersonId] END
		,ARID.[intSiteId]							= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[intSiteId] ELSE ARID.[intSiteId] END
		,ARID.[strBillingBy]						= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[strBillingBy] ELSE ARID.[strBillingBy] END
		,ARID.[dblPercentFull]						= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[dblPercentFull] ELSE ARID.[dblPercentFull] END
		,ARID.[dblNewMeterReading]					= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[dblNewMeterReading] ELSE ARID.[dblNewMeterReading] END
		,ARID.[dblPreviousMeterReading]				= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[dblPreviousMeterReading] ELSE ARID.[dblPreviousMeterReading] END
		,ARID.[dblConversionFactor]					= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[dblConversionFactor] ELSE ARID.[dblConversionFactor] END
		,ARID.[intPerformerId]						= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[intPerformerId] ELSE ARID.[intPerformerId] END
		,ARID.[ysnLeaseBilling]						= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[ysnLeaseBilling] ELSE ARID.[ysnLeaseBilling] END
		,ARID.[ysnVirtualMeterReading]				= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[ysnVirtualMeterReading] ELSE ARID.[ysnVirtualMeterReading] END
		--,ARID.[dblOriginalItemWeight]				= ARID.[dblOriginalItemWeight]
		,ARID.[intConcurrencyId]					= ARID.[intConcurrencyId] + 1
		,ARID.[intRecipeId]							= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[intRecipeId] ELSE ARID.[intRecipeId] END
		,ARID.[intSubLocationId]					= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[intSubLocationId] ELSE ARID.[intSubLocationId] END
		,ARID.[intCostTypeId]						= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[intCostTypeId] ELSE ARID.[intCostTypeId] END
		,ARID.[intMarginById]						= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[intMarginById] ELSE ARID.[intMarginById] END
		,ARID.[intCommentTypeId]					= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[intCommentTypeId] ELSE ARID.[intCommentTypeId] END
		,ARID.[dblMargin]							= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[dblMargin] ELSE ARID.[dblMargin] END
		,ARID.[dblRecipeQuantity]					= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[dblRecipeQuantity] ELSE ARID.[dblRecipeQuantity] END
		,ARID.[intStorageScheduleTypeId]			= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[intStorageScheduleTypeId] ELSE ARID.[intStorageScheduleTypeId] END
		,ARID.[intDestinationGradeId]				= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[intDestinationGradeId] ELSE ARID.[intDestinationGradeId] END
		,ARID.[intDestinationWeightId]				= CASE WHEN ISNULL(ITG.[ysnUpdateAvailableDiscount], 0) = 0 THEN ITG.[intDestinationWeightId] ELSE ARID.[intDestinationWeightId] END
		OUTPUT  
			@IntegrationLogId						--[intIntegrationLogId]
			,ITG.[intInvoiceId]						--[intInvoiceId]
			,ITG.[intInvoiceDetailId]				--[intInvoiceDetailId]
			,ITG.[intTempDetailIdForTaxes]			--[intTempDetailIdForTaxes]	
			,ITG.[intId]							--[intId]
			,'Line Item was successfully updated.'	--[strErrorMessage]
			,ITG.[strTransactionType]				--[strTransactionType]
			,ITG.[strType]							--[strType]
			,ITG.[strSourceTransaction]				--[strSourceTransaction]
			,ITG.[intSourceId]						--[intSourceId]
			,ITG.[strSourceId]						--[strSourceId]
			,ITG.[ysnPost]							--[ysnPost]
			,0										--[ysnRecap]
			,0										--[ysnInsert]
			,0										--[ysnHeader]
			,1										--[ysnSuccess]
			,NULL									--[ysnPosted]
			,NULL									--[ysnUnPosted]
			,NULL									--[strBatchId]
			,1										--[intConcurrencyId]
		INTO tblARInvoiceIntegrationLogDetail(
			[intIntegrationLogId]
           ,[intInvoiceId]
           ,[intInvoiceDetailId]
           ,[intTemporaryDetailIdForTax]
           ,[intId]
           ,[strMessage]
           ,[strTransactionType]
           ,[strType]
           ,[strSourceTransaction]
           ,[intSourceId]
           ,[strSourceId]
           ,[ysnPost]
           ,[ysnRecap]
           ,[ysnInsert]
           ,[ysnHeader]
           ,[ysnSuccess]
           ,[ysnPosted]
           ,[ysnUnPosted]
           ,[strBatchId]
           ,[intConcurrencyId]
		)
	FROM
		tblARInvoiceDetail AS ARID
	INNER JOIN			
		@InvoiceEntries ITG --WITH (NOLOCK)
			ON ARID.[intInvoiceId] = ITG.[intInvoiceId]
			AND ARID.[intInvoiceDetailId] = ITG.[intInvoiceDetailId]
	INNER JOIN
		@IntegrationLog IL
			ON ITG.[intInvoiceId] = IL.[intInvoiceId]
	WHERE
		IL.[ysnSuccess] = 1
		AND ISNULL(ITG.[ysnResetDetails], 0) = 0
	
	IF ISNULL(@IntegrationLogId, 0) <> 0
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
	EXEC [dbo].[uspARReComputeInvoicesAmounts] @InvoiceIds = @UpdatedInvoiceIds

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
		,[strActionType]			= 'Processed - Update'
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
		IL.[ysnSuccess] = 1 
		AND IL.[ysnInsert] = 0

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
