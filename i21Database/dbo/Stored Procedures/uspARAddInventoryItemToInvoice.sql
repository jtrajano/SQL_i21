﻿CREATE PROCEDURE [dbo].[uspARAddInventoryItemToInvoice]
	 @InvoiceId						INT	
	,@ItemId						INT
	,@NewInvoiceDetailId			INT				= NULL			OUTPUT 
	,@ErrorMessage					NVARCHAR(50)	= NULL			OUTPUT
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
		,@EntityCustomerId INT
		,@CompanyLocationId INT
		,@InvoiceDate DATETIME

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
	
	
IF NOT EXISTS(SELECT NULL FROM tblICItem IC WHERE IC.[intItemId] = @ItemId)
	BEGIN
		SET @ErrorMessage = 'Item does not exists!'
		RETURN 0;
	END
	
IF NOT EXISTS(SELECT NULL FROM tblSMCompanyLocation WHERE intCompanyLocationId = @CompanyLocationId)
	BEGIN
		SET @ErrorMessage = 'The company location Id provided does not exists!'
		RETURN 0;
	END		
	
IF NOT EXISTS(	SELECT NULL 
				FROM tblICItem IC INNER JOIN tblICItemLocation IL ON IC.intItemId = IL.intItemId
				WHERE IC.[intItemId] = @ItemId AND IL.[intLocationId] = @CompanyLocationId)
	BEGIN
		SET @ErrorMessage = 'The item was not set up to be available on the specified location!'
		RETURN 0;
	END
	
BEGIN TRANSACTION
	
	
IF ((@ItemId IS NOT NULL OR @ItemId <> 0) AND (@ItemPrice IS NULL OR @ItemPrice = @ZeroDecimal) )
	BEGIN
		BEGIN TRY
		EXEC dbo.[uspARGetItemPrice]  
				 @ItemId  
				,@EntityCustomerId
				,@CompanyLocationId
				,@ItemUOMId
				,@InvoiceDate
				,@ItemQtyShipped
				,@ItemPrice OUTPUT
		END TRY
		BEGIN CATCH
			SET @ErrorMessage = ERROR_MESSAGE();
			RETURN 0;
		END CATCH
	END	

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
		,[intConcurrencyId])
	SELECT
			[intInvoiceId]						= @InvoiceId
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