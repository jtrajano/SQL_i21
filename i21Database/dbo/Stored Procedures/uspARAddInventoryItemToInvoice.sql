CREATE PROCEDURE [dbo].[uspARAddInventoryItemToInvoice]
	 @InvoiceId						INT	
	,@ItemId						INT
	,@NewInvoiceDetailId			INT				= NULL			OUTPUT 
	,@ErrorMessage					NVARCHAR(250)	= NULL			OUTPUT
	,@RaiseError					BIT				= 0			
	,@ItemDescription				NVARCHAR(500)	= NULL
	,@ItemUOMId						INT				= NULL
	,@ItemQtyOrdered				NUMERIC(18,6)	= 0.000000
	,@ItemQtyShipped				NUMERIC(18,6)	= 0.000000
	,@ItemDiscount					NUMERIC(18,6)	= 0.000000
	,@ItemPrice						NUMERIC(18,6)	= 0.000000	
	,@RefreshPrice					BIT				= 0
	,@ItemMaintenanceType			NVARCHAR(50)	= NULL
	,@ItemFrequency					NVARCHAR(50)	= NULL
	,@ItemMaintenanceDate			DATETIME		= NULL
	,@ItemMaintenanceAmount			NUMERIC(18,6)	= 0.000000
	,@ItemLicenseAmount				NUMERIC(18,6)	= 0.000000
	,@ItemTaxGroupId				INT				= NULL
	,@RecomputeTax					BIT				= 1
	,@ItemSCInvoiceId				INT				= NULL
	,@ItemSCInvoiceNumber			NVARCHAR(50)	= NULL
	,@ItemInventoryShipmentItemId	INT				= NULL
	,@ItemShipmentNumber			NVARCHAR(50)	= NULL
	,@ItemSalesOrderDetailId		INT				= NULL												
	,@ItemSalesOrderNumber			NVARCHAR(50)	= NULL
	,@ItemContractHeaderId			INT				= NULL
	,@ItemContractDetailId			INT				= NULL			
	,@ItemShipmentId				INT				= NULL			
	,@ItemShipmentPurchaseSalesContractId	INT		= NULL			
	,@ItemTicketId					INT				= NULL		
	,@ItemTicketHoursWorkedId		INT				= NULL		
	,@ItemSiteId					INT				= NULL												
	,@ItemBillingBy					NVARCHAR(200)	= NULL
	,@ItemPercentFull				NUMERIC(18,6)	= 0.000000
	,@ItemNewMeterReading			NUMERIC(18,6)	= 0.000000
	,@ItemPreviousMeterReading		NUMERIC(18,6)	= 0.000000
	,@ItemConversionFactor			NUMERIC(18,8)	= 0.00000000
	,@ItemPerformerId				INT				= NULL
	,@ItemLeaseBilling				BIT				= 0
	,@ItemVirtualMeterReading		BIT				= 0
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
	
	
IF NOT EXISTS(SELECT NULL FROM tblICItem IC WHERE IC.[intItemId] = @ItemId)
	BEGIN
		SET @ErrorMessage = 'Item does not exists!'
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR(@ErrorMessage, 16, 1);
		RETURN 0;
	END
	
IF NOT EXISTS(SELECT NULL FROM tblSMCompanyLocation WHERE intCompanyLocationId = @CompanyLocationId)
	BEGIN
		SET @ErrorMessage = 'The company location from the target Invoice does not exists!'
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR(@ErrorMessage, 16, 1);
		RETURN 0;
	END		
	
IF NOT EXISTS(	SELECT NULL 
				FROM tblICItem IC INNER JOIN tblICItemLocation IL ON IC.intItemId = IL.intItemId
				WHERE IC.[intItemId] = @ItemId AND IL.[intLocationId] = @CompanyLocationId)
	BEGIN
		SET @ErrorMessage = 'The item was not set up to be available on the specified location!'
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR(@ErrorMessage, 16, 1);
		RETURN 0;
	END
	
IF ISNULL(@RaiseError,0) = 0	
	BEGIN TRANSACTION
	
	
IF (ISNULL(@RefreshPrice,0) = 1)
	BEGIN
		DECLARE @Pricing			NVARCHAR(250)				
				,@ContractNumber	INT
				,@ContractSeq		INT
		BEGIN TRY
		EXEC dbo.[uspARGetItemPrice]  
				 @ItemId  
				,@EntityCustomerId
				,@CompanyLocationId
				,@ItemUOMId
				,@InvoiceDate
				,@ItemQtyShipped
				,@ItemPrice				OUTPUT
				,@Pricing				OUTPUT
				,@ItemContractHeaderId	OUTPUT
				,@ItemContractDetailId	OUTPUT
				,@ContractNumber		OUTPUT
				,@ContractSeq			OUTPUT
		END TRY
		BEGIN CATCH
			SET @ErrorMessage = ERROR_MESSAGE();
			IF ISNULL(@RaiseError,0) = 1
				RAISERROR(@ErrorMessage, 16, 1);
			RETURN 0;
		END CATCH
	END	

BEGIN TRY
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
		,[intConcurrencyId])
	SELECT
		 [intInvoiceId]						= @InvoiceId
		,[intItemId]						= IC.[intItemId] 
		,[strItemDescription]				= ISNULL(@ItemDescription, IC.[strDescription])
		,[intItemUOMId]						= ISNULL(@ItemUOMId, IL.intIssueUOMId)
		,[dblQtyOrdered]					= ISNULL(@ItemQtyOrdered, ISNULL(@ItemQtyShipped,@ZeroDecimal))
		,[dblQtyShipped]					= ISNULL(@ItemQtyShipped, @ZeroDecimal)
		,[dblDiscount]						= ISNULL(@ItemDiscount, @ZeroDecimal)
		,[dblPrice]							= ISNULL(@ItemPrice, @ZeroDecimal)			
		,[dblTotalTax]						= @ZeroDecimal
		,[dblTotal]							= @ZeroDecimal
		,[intAccountId]						= Acct.[intAccountId] 
		,[intCOGSAccountId]					= Acct.[intCOGSAccountId] 
		,[intSalesAccountId]				= Acct.[intSalesAccountId]
		,[intInventoryAccountId]			= Acct.[intInventoryAccountId]
		,[intServiceChargeAccountId]		= Acct.[intAccountId]
		,[strMaintenanceType]				= @ItemMaintenanceType
		,[strFrequency]						= @ItemFrequency
		,[dtmMaintenanceDate]				= @ItemMaintenanceDate
		,[dblMaintenanceAmount]				= @ItemMaintenanceAmount
		,[dblLicenseAmount]					= @ItemLicenseAmount
		,[intTaxGroupId]					= @ItemTaxGroupId
		,[intSCInvoiceId]					= @ItemSCInvoiceId
		,[strSCInvoiceNumber]				= @ItemSCInvoiceNumber 
		,[intInventoryShipmentItemId]		= @ItemInventoryShipmentItemId 
		,[strShipmentNumber]				= @ItemShipmentNumber 
		,[intSalesOrderDetailId]			= @ItemSalesOrderDetailId 
		,[strSalesOrderNumber]				= @ItemSalesOrderNumber 
		,[intContractHeaderId]				= @ItemContractHeaderId
		,[intContractDetailId]				= @ItemContractDetailId
		,[intShipmentId]					= @ItemShipmentId
		,[intShipmentPurchaseSalesContractId] =	@ItemShipmentPurchaseSalesContractId 
		,[intTicketId]						= @ItemTicketId
		,[intTicketHoursWorkedId]			= @ItemTicketHoursWorkedId 
		,[intSiteId]						= @ItemSiteId
		,[strBillingBy]						= @ItemBillingBy
		,[dblPercentFull]					= @ItemPercentFull
		,[dblNewMeterReading]				= @ItemNewMeterReading
		,[dblPreviousMeterReading]			= @ItemPreviousMeterReading
		,[dblConversionFactor]				= @ItemConversionFactor
		,[intPerformerId]					= @ItemPerformerId
		,[ysnLeaseBilling]					= @ItemLeaseBilling
		,[ysnVirtualMeterReading]			= @ItemVirtualMeterReading
		,[intConcurrencyId]					= 0
	FROM
		tblICItem IC
	INNER JOIN
		tblICItemLocation IL
			ON IC.intItemId = IL.intItemId
	LEFT OUTER JOIN
		vyuARGetItemAccount Acct
			ON IC.[intItemId] = Acct.[intItemId]
			AND IL.[intLocationId] = Acct.[intLocationId]
	WHERE
		IC.[intItemId] = @ItemId
		AND IL.[intLocationId] = @CompanyLocationId
			
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