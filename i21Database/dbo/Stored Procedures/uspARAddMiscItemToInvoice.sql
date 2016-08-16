CREATE PROCEDURE [dbo].[uspARAddMiscItemToInvoice]
	 @InvoiceId						INT
	,@ItemPrepayTypeId				INT				= 0
	,@ItemPrepayRate				NUMERIC(18,6)	= 0.000000
	,@NewInvoiceDetailId			INT				= NULL			OUTPUT 
	,@ErrorMessage					NVARCHAR(250)	= NULL			OUTPUT
	,@RaiseError					BIT				= 0			
	,@ItemDescription				NVARCHAR(500)	= NULL
	,@ItemDocumentNumber			NVARCHAR(100)	= NULL
	,@ItemQtyOrdered				NUMERIC(18,6)	= 0.000000
	,@ItemQtyShipped				NUMERIC(18,6)	= 0.000000
	,@ItemDiscount					NUMERIC(18,6)	= 0.000000
	,@ItemPrice						NUMERIC(18,6)	= 0.000000
	,@ItemSalesOrderDetailId		INT				= NULL	
	,@ItemTaxGroupId				INT				= NULL
	,@EntitySalespersonId			INT				= NULL	
	,@SubCurrency					BIT				= 0
AS

BEGIN


SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ZeroDecimal NUMERIC(18, 6)
		,@EntityCustomerId INT
		,@CompanyLocationId INT
		,@InvoiceDate DATETIME
		,@ServiceChargesAccountId INT
		
SET @ZeroDecimal = 0.000000

IF NOT EXISTS(SELECT NULL FROM tblARInvoice WHERE intInvoiceId = @InvoiceId)
BEGIN	
	RAISERROR(120001, 16, 1);
	GOTO _ExitTransaction
END

SELECT 
	 @EntityCustomerId	= [intEntityCustomerId]
	,@CompanyLocationId = [intCompanyLocationId]
	,@InvoiceDate		= [dtmDate]
FROM
	tblARInvoice
WHERE
	intInvoiceId = @InvoiceId		
	
IF NOT EXISTS(SELECT NULL FROM tblSMCompanyLocation WHERE intCompanyLocationId = @CompanyLocationId)
	BEGIN
		RAISERROR(120003, 16, 1);
		GOTO _ExitTransaction
	END	
	
SET @ServiceChargesAccountId = (SELECT TOP 1 intServiceChargeAccountId FROM tblARCompanyPreference WHERE intServiceChargeAccountId IS NOT NULL AND intServiceChargeAccountId <> 0)	
--IF ISNULL(@ServiceChargesAccountId,0) = 0
--	BEGIN
--		SET @ErrorMessage = 'The Service Charge account in the Company Preferences was not set.'
--		RETURN 0;
--	END	

BEGIN TRANSACTION		

BEGIN TRY
	INSERT INTO [tblARInvoiceDetail]
		([intInvoiceId]
		,[intItemId]
		,[intPrepayTypeId]
		,[dblPrepayRate]
		,[strItemDescription]
		,[strDocumentNumber]
		,[intItemUOMId]
		,[dblQtyOrdered]
		,[dblQtyShipped]
		,[dblDiscount]
		,[dblPrice]
		,[dblTotalTax]
		,[dblTotal]
		,[ysnSubCurrency]
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
		,[strSCInvoiceNumber]
		,[intInventoryShipmentItemId]
		,[strShipmentNumber]
		,[intSalesOrderDetailId]
		,[strSalesOrderNumber]
		,[intContractHeaderId]
		,[intContractDetailId]
		,[intShipmentId]
		,[intShipmentPurchaseSalesContractId]
		,[intTicketId]
		,[intTicketHoursWorkedId]
		,[intSiteId]
		,[strBillingBy]
		,[dblPercentFull]
		,[dblNewMeterReading]
		,[dblPreviousMeterReading]
		,[dblConversionFactor]
		,[intPerformerId]
		,[ysnLeaseBilling]
		,[ysnVirtualMeterReading]
		,[intEntitySalespersonId]
		,[intConcurrencyId])
	SELECT
		 [intInvoiceId]						= @InvoiceId
		,[intItemId]						= NULL
		,[intPrepayTypeId]					= @ItemPrepayTypeId 
		,[dblPrepayRate]					= @ItemPrepayRate 
		,[strItemDescription]				= ISNULL(@ItemDescription, '')
		,[strDocumentNumber]				= @ItemDocumentNumber
		,[intItemUOMId]						= NULL
		,[dblQtyOrdered]					= ISNULL(@ItemQtyOrdered, @ZeroDecimal)
		,[dblQtyShipped]					= ISNULL(@ItemQtyShipped, @ZeroDecimal)
		,[dblDiscount]						= ISNULL(@ItemDiscount, @ZeroDecimal)
		,[dblPrice]							= ISNULL(@ItemPrice, @ZeroDecimal)			
		,[dblTotalTax]						= @ZeroDecimal
		,[dblTotal]							= @ZeroDecimal
		,[ysnSubCurrency]					= @SubCurrency
		,[intAccountId]						= NULL 
		,[intCOGSAccountId]					= NULL
		,[intSalesAccountId]				= NULL
		,[intInventoryAccountId]			= NULL
		,[intServiceChargeAccountId]		= NULL
		,[strMaintenanceType]				= NULL
		,[strFrequency]						= NULL
		,[dtmMaintenanceDate]				= NULL
		,[dblMaintenanceAmount]				= NULL
		,[dblLicenseAmount]					= NULL
		,[intTaxGroupId]					= @ItemTaxGroupId
		,[intSCInvoiceId]					= NULL
		,[strSCInvoiceNumber]				= NULL 
		,[intInventoryShipmentItemId]		= NULL 
		,[strShipmentNumber]				= NULL 
		,[intSalesOrderDetailId]			= @ItemSalesOrderDetailId 
		,[strSalesOrderNumber]				= NULL 
		,[intContractHeaderId]				= NULL
		,[intContractDetailId]				= NULL
		,[intShipmentId]					= NULL
		,[intShipmentPurchaseSalesContractId] =	NULL 
		,[intTicketId]						= NULL
		,[intTicketHoursWorkedId]			= NULL 
		,[intSiteId]						= NULL
		,[strBillingBy]						= NULL
		,[dblPercentFull]					= NULL
		,[dblNewMeterReading]				= NULL
		,[dblPreviousMeterReading]			= NULL
		,[dblConversionFactor]				= NULL
		,[intPerformerId]					= NULL
		,[ysnLeaseBilling]					= NULL
		,[ysnVirtualMeterReading]			= NULL
		,[intEntitySalespersonId]			= @EntitySalespersonId
		,[intConcurrencyId]					= 0
			
END TRY
BEGIN CATCH
	IF @@ERROR <> 0	GOTO _RollBackTransaction
	SET @ErrorMessage = ERROR_MESSAGE()  
	RAISERROR (@ErrorMessage, 16, 1, 'WITH NOWAIT') 
END CATCH
	
DECLARE @NewId INT
SET @NewId = SCOPE_IDENTITY()
		
BEGIN TRY
EXEC dbo.[uspARReComputeInvoiceTaxes] @InvoiceId  

END TRY
BEGIN CATCH
	IF @@ERROR <> 0	GOTO _RollBackTransaction
	SET @ErrorMessage = ERROR_MESSAGE()  
	RAISERROR (@ErrorMessage, 16, 1, 'WITH NOWAIT') 
END CATCH

SET @NewInvoiceDetailId = @NewId

IF @@ERROR = 0 GOTO _CommitTransaction
	
_RollBackTransaction:
ROLLBACK TRANSACTION
GOTO _ExitTransaction

_CommitTransaction: 
COMMIT TRANSACTION
GOTO _ExitTransaction

_ExitTransaction: 
	
END