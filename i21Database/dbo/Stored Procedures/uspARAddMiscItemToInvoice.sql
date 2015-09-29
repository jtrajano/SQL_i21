CREATE PROCEDURE [dbo].[uspARAddMiscItemToInvoice]
	 @InvoiceId						INT	
	,@NewInvoiceDetailId			INT				= NULL			OUTPUT 
	,@ErrorMessage					NVARCHAR(250)	= NULL			OUTPUT
	,@ItemQtyShipped				NUMERIC(18,6)	= 0.000000
	,@ItemPrice						NUMERIC(18,6)	= 0.000000
	,@ItemDescription				NVARCHAR(500)	= NULL
	,@TaxMasterId					INT				= NULL
	,@ItemTaxGroupId				INT				= NULL
	,@ItemDiscount					NUMERIC(18,6)	= 0.000000
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
		SET @ErrorMessage = 'Invoice does not exists!'
		RETURN 0;
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
		SET @ErrorMessage = 'The company location from the target Invoice does not exists!'
		RETURN 0;
	END	
	
--SET @ServiceChargesAccountId = (SELECT TOP 1 intServiceChargeAccountId FROM tblARCompanyPreference WHERE intServiceChargeAccountId IS NOT NULL AND intServiceChargeAccountId <> 0)	
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
		,[intTaxGroupId] 
		,[intConcurrencyId])
	SELECT
		 [intInvoiceId]						= @InvoiceId
		,[intItemId]						= NULL 
		,[strItemDescription]				= ISNULL(@ItemDescription, '')
		,[intSCInvoiceId]					= NULL
		,[strSCInvoiceNumber]				= NULL 
		,[intItemUOMId]						= NULL
		,[dblQtyOrdered]					= ISNULL(@ItemQtyShipped, @ZeroDecimal)
		,[dblQtyShipped]					= ISNULL(@ItemQtyShipped, @ZeroDecimal)
		,[dblDiscount]						= ISNULL(@ItemDiscount, @ZeroDecimal)
		,[dblPrice]							= ISNULL(@ItemPrice, @ZeroDecimal)
		,[dblTotalTax]						= @ZeroDecimal
		,[dblTotal]							= @ZeroDecimal
		,[intAccountId]						= @ServiceChargesAccountId 
		,[intCOGSAccountId]					= NULL 
		,[intSalesAccountId]				= NULL
		,[intInventoryAccountId]			= NULL
		,[intServiceChargeAccountId]		= NULL
		,[intInventoryShipmentItemId]		= NULL
		,[strShipmentNumber]				= NULL
		,[intSalesOrderDetailId]			= NULL
		,[strSalesOrderNumber]				= NULL
		,[intSiteId]						= NULL												
		,[strBillingBy]						= NULL		
		,[dblPercentFull]					= @ZeroDecimal
		,[dblNewMeterReading]				= @ZeroDecimal
		,[dblPreviousMeterReading]			= @ZeroDecimal
		,[dblConversionFactor]				= @ZeroDecimal
		,[intPerformerId]					= NULL
		,[intContractHeaderId]				= NULL
		,[strMaintenanceType]				= NULL
		,[strFrequency]						= NULL
		,[dtmMaintenanceDate]				= NULL
		,[dblMaintenanceAmount]				= @ZeroDecimal
		,[dblLicenseAmount]					= @ZeroDecimal
		,[intContractDetailId]				= NULL
		,[intTicketId]						= NULL
		,[ysnLeaseBilling]					= 0
		,[intTaxGroupId]					= @ItemTaxGroupId
		,1		
			
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	SET @ErrorMessage = ERROR_MESSAGE();
	RETURN 0;
END CATCH
	
DECLARE @NewId INT
SET @NewId = SCOPE_IDENTITY()
		
BEGIN TRY
EXEC dbo.[uspARReComputeInvoiceTaxes]  
		 @InvoiceId  
		,@TaxMasterId
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	SET @ErrorMessage = ERROR_MESSAGE();
	RETURN 0;
END CATCH

SET @NewInvoiceDetailId = @NewId

COMMIT TRANSACTION
SET @ErrorMessage = NULL;
RETURN 1;
	
	
END