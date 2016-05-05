﻿CREATE PROCEDURE [dbo].[uspARAddMiscItemToInvoice]
	 @InvoiceId						INT	
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
		SET @ErrorMessage = 'Invoice does not exists!'
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR(@ErrorMessage, 16, 1);
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
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR(@ErrorMessage, 16, 1);
		RETURN 0;
	END	
	
SET @ServiceChargesAccountId = (SELECT TOP 1 intServiceChargeAccountId FROM tblARCompanyPreference WHERE intServiceChargeAccountId IS NOT NULL AND intServiceChargeAccountId <> 0)	
--IF ISNULL(@ServiceChargesAccountId,0) = 0
--	BEGIN
--		SET @ErrorMessage = 'The Service Charge account in the Company Preferences was not set.'
--		RETURN 0;
--	END	
		
IF ISNULL(@RaiseError,0) = 0	
	BEGIN TRANSACTION		

BEGIN TRY
	INSERT INTO [tblARInvoiceDetail]
		([intInvoiceId]
		,[intItemId]
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
	IF ISNULL(@RaiseError,0) = 0	
		ROLLBACK TRANSACTION
	SET @ErrorMessage = ERROR_MESSAGE();
	IF ISNULL(@RaiseError,0) = 1
		RAISERROR(@ErrorMessage, 16, 1);
	RETURN 0;
END CATCH
	
DECLARE @NewId INT
SET @NewId = SCOPE_IDENTITY()
		
BEGIN TRY
EXEC dbo.[uspARReComputeInvoiceTaxes] @InvoiceId  

END TRY
BEGIN CATCH
	IF ISNULL(@RaiseError,0) = 0	
		ROLLBACK TRANSACTION
	SET @ErrorMessage = ERROR_MESSAGE();
	IF ISNULL(@RaiseError,0) = 1
		RAISERROR(@ErrorMessage, 16, 1);
	RETURN 0;
END CATCH

SET @NewInvoiceDetailId = @NewId

IF ISNULL(@RaiseError,0) = 0	
	COMMIT TRANSACTION
SET @ErrorMessage = NULL;
RETURN 1;
	
	
END