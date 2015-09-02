CREATE PROCEDURE [dbo].[uspSOUpdateContractOnSalesOrder]  
	 @TransactionId	INT   
	,@ForDelete		BIT = 0
	,@UserId		INT = NULL     
AS  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF  



-- Get the details from the SalesOrder 
BEGIN TRY
	DECLARE @ItemsFromSalesOrder AS dbo.[SalesOrderItemTableType]
	INSERT INTO @ItemsFromSalesOrder (
		-- Header
		 [intSalesOrderId]
		,[strSalesOrderNumber]
		,[intEntityCustomerId]
		,[dtmDate]
		,[intCurrencyId]
		,[intCompanyLocationId]
		,[intQuoteTemplateId]

		-- Detail 
		,[intSalesOrderDetailId]
		,[intItemId]
		,[strItemDescription]
		,[intItemUOMId]
		,[dblQtyOrdered]
		,[dblQtyAllocated]
		,[dblQtyShipped]
		,[dblDiscount]
		,[intTaxId]
		,[dblPrice]
		,[dblTotalTax]
		,[dblTotal]
		,[strComments]
		,[strMaintenanceType]
		,[strFrequency]
		,[dtmMaintenanceDate]
		,[dblMaintenanceAmount]
		,[dblLicenseAmount]
		,[intContractHeaderId]
		,[intContractDetailId]
		,[intStorageLocationId]
	)
	EXEC dbo.[uspSOGetItemsFromSalesOrder]
			@SalesOrderId = @TransactionId

	DECLARE		@intSalesOrderDetailId				INT,
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
		intSalesOrderDetailId			INT,
		intContractDetailId			INT,
		intItemUOMId				INT,
		dblQty						NUMERIC(12,4)	
	)

	INSERT INTO @tblToProcess(
		 [intSalesOrderDetailId]
		,[intContractDetailId]
		,[intItemUOMId]
		,[dblQty])
	SELECT
		 I.[intSalesOrderDetailId]
		,D.[intContractDetailId]
		,D.[intItemUOMId]
		,D.[dblQtyOrdered] 
	FROM
		@ItemsFromSalesOrder I
	INNER JOIN
		tblSOSalesOrderDetail D
			ON	I.[intSalesOrderDetailId] = D.[intSalesOrderDetailId]
	WHERE
		D.intContractDetailId IS NOT NULL


	SELECT @intUniqueId = MIN(intUniqueId) FROM @tblToProcess

	WHILE ISNULL(@intUniqueId,0) > 0
	BEGIN
		SELECT	@intContractDetailId			=	NULL,
				@intFromItemUOMId				=	NULL,
				@dblQty							=	NULL,
				@intSalesOrderDetailId			=	NULL

		SELECT	@intContractDetailId			=	[intContractDetailId],
				@intFromItemUOMId				=	[intItemUOMId],
				@dblQty							=	[dblQty],
				@intSalesOrderDetailId			=	[intSalesOrderDetailId]
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
				@dblQuantityToUpdate	=	@dblConvertedQty,
				@intUserId				=	@UserId,
				@intExternalId			=	@intSalesOrderDetailId,
				@strScreenName			=	'Sales Order'

		SELECT @intUniqueId = MIN(intUniqueId) FROM @tblToProcess WHERE intUniqueId > @intUniqueId
	END

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')  
	
END CATCH
GO