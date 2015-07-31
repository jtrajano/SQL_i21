CREATE PROCEDURE [dbo].[uspARUpdateContractOnInvoice]  
	 @TransactionId	INT   
	,@ForDelete		BIT = 0
	,@UserId		INT = NULL     
AS  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF  



-- Get the details from the invoice 
BEGIN TRY
	DECLARE @ItemsFromInvoice AS dbo.[InvoiceItemTableType]
	INSERT INTO @ItemsFromInvoice (
		-- Header
		 [intInvoiceId]
		,[strInvoiceNumber]
		,[intEntityCustomerId]
		,[dtmDate]
		,[intCurrencyId]
		,[intCompanyLocationId]
		,[intDistributionHeaderId]

		-- Detail 
		,[intInvoiceDetailId]
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
		,[intServiceChargeAccountId]
		,[intInventoryShipmentItemId]
		,[intSalesOrderDetailId]
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
	)
	EXEC dbo.[uspARGetItemsFromInvoice]
			@intInvoiceId = @TransactionId

	DECLARE		@intInvoiceDetailId				INT,
				@intContractDetailId			INT,
				@intFromItemUOMId				INT,
				@intToItemUOMId					INT,
				@intUniqueId					INT,
				@dblQty							NUMERIC(12,4),
				@dblConvertedQty				NUMERIC(12,4),
				@ErrMsg							NVARCHAR(MAX),
				@dblSchQuantityToUpdate			NUMERIC(12,4)


	DECLARE @tblToProcess TABLE
	(
		intUniqueId					INT IDENTITY,
		intInvoiceDetailId			INT,
		intContractDetailId			INT,
		intItemUOMId				INT,
		dblQty						NUMERIC(12,4)	
	)

	INSERT INTO @tblToProcess(
		 [intInvoiceDetailId]
		,[intContractDetailId]
		,[intItemUOMId]
		,[dblQty])
	SELECT
		 I.[intInvoiceDetailId]
		,D.[intContractDetailId]
		,D.[intItemUOMId]
		,D.[dblQtyShipped]
	FROM
		@ItemsFromInvoice I
	INNER JOIN
		tblARInvoiceDetail D
			ON	I.[intInvoiceDetailId] = D.[intInvoiceDetailId]
	WHERE
		D.intContractDetailId IS NOT NULL
		AND D.[intInventoryShipmentItemId] IS NULL


	SELECT @intUniqueId = MIN(intUniqueId) FROM @tblToProcess

	WHILE ISNULL(@intUniqueId,0) > 0
	BEGIN
		SELECT	@intContractDetailId			=	NULL,
				@intFromItemUOMId				=	NULL,
				@dblQty							=	NULL,
				@intInvoiceDetailId	=	NULL

		SELECT	@intContractDetailId			=	[intContractDetailId],
				@intFromItemUOMId				=	[intItemUOMId],
				@dblQty							=	[dblQty],
				@intInvoiceDetailId				=	[intInvoiceDetailId]
		FROM	@tblToProcess 
		WHERE	[intUniqueId]					=	 @intUniqueId

		IF NOT EXISTS(SELECT * FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId)
		BEGIN
			RAISERROR('Contract does not exist.',16,1)
		END

		SELECT @intToItemUOMId	=	intItemUOMId FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId

		SELECT @dblConvertedQty =	dbo.fnCalculateQtyBetweenUOM(@intFromItemUOMId,@intToItemUOMId,@dblQty)
		
		SET @dblConvertedQty = @dblConvertedQty * (CASE WHEN @ForDelete = 1 THEN -1 ELSE 1 END)

		IF ISNULL(@dblConvertedQty,0) = 0
		BEGIN
			RAISERROR('UOM does not exist.',16,1)
		END
					
		EXEC	uspCTUpdateScheduleQuantity
				@intContractDetailId	=	@intContractDetailId,
				@dblQuantityToUpdate	=	@dblConvertedQty

		SELECT @intUniqueId = MIN(intUniqueId) FROM @tblToProcess WHERE intUniqueId > @intUniqueId
	END

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')  
	
END CATCH
GO


