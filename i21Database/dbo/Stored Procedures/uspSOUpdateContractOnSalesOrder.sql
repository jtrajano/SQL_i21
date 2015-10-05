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
	--Quantity/UOM Changed
	SELECT
		 I.[intSalesOrderDetailId]
		,D.[intContractDetailId]
		,D.[intItemUOMId]
		,dbo.fnCalculateQtyBetweenUOM(D.[intItemUOMId], CD.[intItemUOMId], (CASE WHEN @ForDelete = 1 THEN D.[dblQtyOrdered] ELSE (D.dblQtyOrdered - TD.dblQtyOrdered) END))
	FROM
		@ItemsFromSalesOrder I
	INNER JOIN
		tblSOSalesOrderDetail D
			ON	I.[intSalesOrderDetailId] = D.[intSalesOrderDetailId]
	INNER JOIN
		tblARTransactionDetail TD
			ON D.intSalesOrderDetailId = TD.intTransactionDetailId 
			AND D.intSalesOrderId = TD.intTransactionId 
			AND TD.strTransactionType = 'Order'
	INNER JOIN
		tblCTContractDetail CD
			ON D.intContractDetailId = CD.intContractDetailId
	WHERE
		D.intContractDetailId IS NOT NULL
		AND D.intContractDetailId = TD.intContractDetailId		
		AND D.intItemId = TD.intItemId		
		AND (D.intItemUOMId <> TD.intItemUOMId OR D.dblQtyOrdered <> TD.dblQtyOrdered)
		
	UNION ALL

	--New Contract Selected
	SELECT
		 I.[intSalesOrderDetailId]
		,D.[intContractDetailId]
		,D.[intItemUOMId]
		,dbo.fnCalculateQtyBetweenUOM(D.[intItemUOMId], CD.[intItemUOMId], D.[dblQtyOrdered])
	FROM
		@ItemsFromSalesOrder I
	INNER JOIN
		tblSOSalesOrderDetail D
			ON	I.[intSalesOrderDetailId] = D.[intSalesOrderDetailId]
	INNER JOIN
		tblARTransactionDetail TD
			ON D.intSalesOrderDetailId = TD.intTransactionDetailId 
			AND D.intSalesOrderId = TD.intTransactionId 
			AND TD.strTransactionType = 'Order'
	INNER JOIN
		tblCTContractDetail CD
			ON D.intContractDetailId = CD.intContractDetailId
	WHERE
		D.intContractDetailId IS NOT NULL
		AND D.intContractDetailId <> TD.intContractDetailId		
		AND D.intItemId = TD.intItemId		
		
	UNION ALL

	--Replaced Contract
	SELECT
		 I.[intSalesOrderDetailId]
		,TD.[intContractDetailId]
		,TD.[intItemUOMId]
		,dbo.fnCalculateQtyBetweenUOM(TD.[intItemUOMId], CD.[intItemUOMId], (TD.[dblQtyOrdered] * -1))
	FROM
		@ItemsFromSalesOrder I
	INNER JOIN
		tblSOSalesOrderDetail D
			ON	I.[intSalesOrderDetailId] = D.[intSalesOrderDetailId]
	INNER JOIN
		tblARTransactionDetail TD
			ON D.intSalesOrderDetailId = TD.intTransactionDetailId 
			AND D.intSalesOrderId = TD.intTransactionId 
			AND TD.strTransactionType = 'Order'
	INNER JOIN
		tblCTContractDetail CD
			ON TD.intContractDetailId = CD.intContractDetailId
	WHERE
		D.intContractDetailId IS NOT NULL
		AND D.intContractDetailId <> TD.intContractDetailId		
		AND D.intItemId = TD.intItemId
		
	UNION ALL
		
	--Removed Contract
	SELECT
		 I.[intSalesOrderDetailId]
		,TD.[intContractDetailId]
		,TD.[intItemUOMId]
		,dbo.fnCalculateQtyBetweenUOM(TD.[intItemUOMId], CD.[intItemUOMId], (TD.[dblQtyOrdered] * -1))
	FROM
		@ItemsFromSalesOrder I
	INNER JOIN
		tblSOSalesOrderDetail D
			ON	I.[intSalesOrderDetailId] = D.[intSalesOrderDetailId]
	INNER JOIN
		tblARTransactionDetail TD
			ON D.intSalesOrderDetailId = TD.intTransactionDetailId 
			AND D.intSalesOrderId = TD.intTransactionId 
			AND TD.strTransactionType = 'Order'
	INNER JOIN
		tblCTContractDetail CD
			ON TD.intContractDetailId = CD.intContractDetailId
	WHERE
		D.intContractDetailId IS NULL
		AND TD.intContractDetailId IS NOT NULL
		
	UNION ALL	

	--Deleted Item
	SELECT
		 TD.intTransactionDetailId
		,TD.[intContractDetailId]
		,TD.[intItemUOMId]
		,dbo.fnCalculateQtyBetweenUOM(TD.[intItemUOMId], CD.[intItemUOMId], (TD.[dblQtyOrdered] * -1))
	FROM
		tblARTransactionDetail TD
	INNER JOIN
		tblCTContractDetail CD
			ON TD.intContractDetailId = CD.intContractDetailId
	WHERE
		TD.intTransactionId = @TransactionId 
		AND TD.strTransactionType = 'Order'
		AND TD.intContractDetailId IS NOT NULL
		AND TD.intTransactionDetailId NOT IN (SELECT intSalesOrderDetailId FROM tblSOSalesOrderDetail WHERE intSalesOrderId = @TransactionId)
		
	UNION ALL
		
	--Added Item
	SELECT
		 Detail.intSalesOrderDetailId
		,Detail.[intContractDetailId]
		,Detail.[intItemUOMId]
		,dbo.fnCalculateQtyBetweenUOM(Detail.[intItemUOMId], CD.[intItemUOMId], Detail.[dblQtyOrdered])
	FROM
		tblSOSalesOrderDetail Detail
	INNER JOIN
		tblSOSalesOrder Header
			ON Detail.intSalesOrderId = Header.intSalesOrderId 
	INNER JOIN
		tblCTContractDetail CD
			ON Detail.intContractDetailId = CD.intContractDetailId
	WHERE
		Detail.intSalesOrderId = @TransactionId 
		AND Header.strTransactionType = 'Order'
		AND Detail.intContractDetailId IS NOT NULL
		AND Detail.intSalesOrderDetailId NOT IN (SELECT intTransactionDetailId FROM tblARTransactionDetail WHERE intTransactionId = @TransactionId AND strTransactionType = 'Order')


	SELECT @intUniqueId = MIN(intUniqueId) FROM @tblToProcess

	WHILE ISNULL(@intUniqueId,0) > 0
	BEGIN
		SELECT	@intContractDetailId			=	NULL,
				@intFromItemUOMId				=	NULL,
				@dblQty							=	NULL,
				@intSalesOrderDetailId			=	NULL

		SELECT	@intContractDetailId			=	[intContractDetailId],
				@intFromItemUOMId				=	[intItemUOMId],
				@dblQty							=	[dblQty] * (CASE WHEN @ForDelete = 1 THEN -1 ELSE 1 END),
				@intSalesOrderDetailId			=	[intSalesOrderDetailId]
		FROM	@tblToProcess 
		WHERE	[intUniqueId]					=	 @intUniqueId

		IF NOT EXISTS(SELECT * FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId)
		BEGIN
			RAISERROR('Contract does not exist.',16,1)
		END

		IF ISNULL(@dblQty,0) = 0
		BEGIN
			RAISERROR('UOM does not exist.',16,1)
		END
					
		EXEC	uspCTUpdateScheduleQuantity
				@intContractDetailId	=	@intContractDetailId,
				@dblQuantityToUpdate	=	@dblQty,
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