CREATE PROCEDURE [dbo].[uspSOUpdateItemContractOnSalesOrder]
	  @intSalesOrderId	INT   
	, @ysnForDelete		BIT = 0
	, @intUserId		INT = NULL     
AS  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF  

BEGIN TRY
	DECLARE @intUniqueId			INT = NULL
	DECLARE @strErrMsg				NVARCHAR(MAX)
	DECLARE @ItemsFromSalesOrder	dbo.[SalesOrderItemTableType]
	DECLARE @tblToProcess TABLE (
		  intUniqueId				INT IDENTITY
		, intSalesOrderDetailId		INT
		, intItemContractDetailId	INT
		, dblQty					NUMERIC(12,4)
	)

	--GET SALES ORDER CONTRACTS
	INSERT INTO @ItemsFromSalesOrder (
		 [intSalesOrderId]
		,[strSalesOrderNumber]
		,[intEntityCustomerId]
		,[dtmDate]
		,[intCurrencyId]
		,[intCompanyLocationId]
		,[intQuoteTemplateId]
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
	EXEC dbo.[uspSOGetItemsFromSalesOrder] @SalesOrderId = @intSalesOrderId

	INSERT INTO @tblToProcess(
		  intSalesOrderDetailId
		, intItemContractDetailId
		, dblQty
	)
	--QTY/UOM CHANGED
	SELECT intSalesOrderDetailId	= SO.intSalesOrderDetailId
		 , intItemContractDetailId	= SOD.intItemContractDetailId
		 , dblQty					= dbo.fnCalculateQtyBetweenUOM(SOD.intItemUOMId, ICD.intItemUOMId, (CASE WHEN @ysnForDelete = 1 THEN SOD.dblQtyOrdered ELSE (SOD.dblQtyOrdered - TD.dblQtyOrdered) END))
	FROM @ItemsFromSalesOrder SO
	INNER JOIN tblSOSalesOrderDetail SOD ON	SO.intSalesOrderDetailId = SOD.intSalesOrderDetailId
	INNER JOIN tblARTransactionDetail TD ON SOD.intSalesOrderDetailId = TD.intTransactionDetailId 
										AND SOD.intSalesOrderId = TD.intTransactionId 
										AND TD.strTransactionType = 'Order'
	INNER JOIN tblCTItemContractDetail ICD ON SOD.intItemContractDetailId = ICD.intItemContractDetailId
	WHERE SOD.intItemContractDetailId IS NOT NULL
	  AND SOD.intItemContractDetailId = TD.intItemContractDetailId		
	  AND SOD.intItemId = TD.intItemId		
	  AND (SOD.intItemUOMId <> TD.intItemUOMId OR SOD.dblQtyOrdered <> TD.dblQtyOrdered)
		
	UNION ALL

	--NEW CONTRACT SELECTED
	SELECT intSalesOrderDetailId	= SO.intSalesOrderDetailId
		 , intItemContractDetailId	= SOD.intItemContractDetailId
		 , dblQty					= dbo.fnCalculateQtyBetweenUOM(SOD.intItemUOMId, ICD.intItemUOMId, SOD.dblQtyOrdered)
	FROM @ItemsFromSalesOrder SO
	INNER JOIN tblSOSalesOrderDetail SOD ON SO.intSalesOrderDetailId = SOD.intSalesOrderDetailId
	INNER JOIN tblARTransactionDetail TD ON SOD.intSalesOrderDetailId = TD.intTransactionDetailId 
										AND SOD.intSalesOrderId = TD.intTransactionId 
										AND TD.strTransactionType = 'Order'
	INNER JOIN tblCTItemContractDetail ICD ON SOD.intItemContractDetailId = ICD.intItemContractDetailId
	WHERE SOD.intItemContractDetailId IS NOT NULL
	  AND SOD.intItemContractDetailId <> TD.intItemContractDetailId		
	  AND SOD.intItemId = TD.intItemId		
		
	UNION ALL

	--REPLACED CONTRACT
	SELECT intSalesOrderDetailId	= SO.intSalesOrderDetailId
		 , intItemContractDetailId	= TD.intItemContractDetailId
		 , dblQty					= dbo.fnCalculateQtyBetweenUOM(TD.intItemUOMId, ICD.intItemUOMId, (TD.dblQtyOrdered * -1))
	FROM @ItemsFromSalesOrder SO
	INNER JOIN tblSOSalesOrderDetail SOD ON SO.intSalesOrderDetailId = SOD.intSalesOrderDetailId
	INNER JOIN tblARTransactionDetail TD ON SOD.intSalesOrderDetailId = TD.intTransactionDetailId 
										AND SOD.intSalesOrderId = TD.intTransactionId 
										AND TD.strTransactionType = 'Order'
	INNER JOIN tblCTItemContractDetail ICD ON TD.intItemContractDetailId = ICD.intItemContractDetailId
	WHERE SOD.intItemContractDetailId IS NOT NULL
	  AND SOD.intItemContractDetailId <> TD.intItemContractDetailId		
	  AND SOD.intItemId = TD.intItemId
		
	UNION ALL
		
	--REMOVED CONTRACT
	SELECT intSalesOrderDetailId	= SO.intSalesOrderDetailId
		 , intItemContractDetailId	= TD.intItemContractDetailId
		 , dblQty					= dbo.fnCalculateQtyBetweenUOM(TD.intItemUOMId, ICD.intItemUOMId, (TD.dblQtyOrdered * -1))
	FROM @ItemsFromSalesOrder SO
	INNER JOIN tblSOSalesOrderDetail SOD ON SO.intSalesOrderDetailId = SOD.intSalesOrderDetailId
	INNER JOIN tblARTransactionDetail TD ON SOD.intSalesOrderDetailId = TD.intTransactionDetailId 
										AND SOD.intSalesOrderId = TD.intTransactionId 
										AND TD.strTransactionType = 'Order'
	INNER JOIN tblCTItemContractDetail ICD ON TD.intItemContractDetailId = ICD.intItemContractDetailId
	WHERE SOD.intItemContractDetailId IS NULL
	  AND TD.intItemContractDetailId IS NOT NULL
		
	UNION ALL	

	--DELETED ITEM
	SELECT intSalesOrderDetailId	= TD.intTransactionDetailId
		 , intItemContractDetailId	= TD.intItemContractDetailId
		 , dblQty					= dbo.fnCalculateQtyBetweenUOM(TD.intItemUOMId, ICD.intItemUOMId, (TD.dblQtyOrdered * -1))
	FROM tblARTransactionDetail TD
	INNER JOIN tblCTItemContractDetail ICD ON TD.intItemContractDetailId = ICD.intItemContractDetailId
	WHERE TD.intTransactionId = @intSalesOrderId 
	  AND TD.strTransactionType = 'Order'
      AND TD.intItemContractDetailId IS NOT NULL
	  AND TD.intTransactionDetailId NOT IN (SELECT intSalesOrderDetailId FROM tblSOSalesOrderDetail WHERE intSalesOrderId = @intSalesOrderId)
		
	UNION ALL
		
	--ADDED ITEM
	SELECT intSalesOrderDetailId	= SOD.intSalesOrderDetailId
		 , intItemContractDetailId	= SOD.intItemContractDetailId
		 , dblQty					= dbo.fnCalculateQtyBetweenUOM(SOD.intItemUOMId, ICD.intItemUOMId, SOD.dblQtyOrdered)
	FROM tblSOSalesOrderDetail SOD
	INNER JOIN tblSOSalesOrder SO ON SOD.intSalesOrderId = SO.intSalesOrderId 
	INNER JOIN tblCTItemContractDetail ICD ON SOD.intItemContractDetailId = ICD.intItemContractDetailId
	WHERE SOD.intSalesOrderId = @intSalesOrderId 
	  AND SO.strTransactionType = 'Order'
	  AND SOD.intItemContractDetailId IS NOT NULL
	  AND SOD.intSalesOrderDetailId NOT IN (SELECT intTransactionDetailId FROM tblARTransactionDetail WHERE intTransactionId = @intSalesOrderId AND strTransactionType = 'Order')

	SELECT @intUniqueId = MIN(intUniqueId) 
	FROM @tblToProcess

	WHILE ISNULL(@intUniqueId,0) > 0
	BEGIN
		DECLARE @intItemContractDetailId	INT = NULL
			  , @intSalesOrderDetailId		INT = NULL
			  , @dblQty						NUMERIC(18, 6) = 0

		SELECT @intItemContractDetailId = P.intItemContractDetailId
			 , @dblQty					= (CASE WHEN P.[dblQty] > ICTD.[dblBalance] THEN ICTD.[dblBalance] ELSE P.[dblQty] END) * (CASE WHEN @ysnForDelete = 1 THEN -1 ELSE 1 END)
			 , @intSalesOrderDetailId	= P.intSalesOrderDetailId
		FROM @tblToProcess P
		INNER JOIN tblCTItemContractDetail ICTD ON P.[intItemContractDetailId] = ICTD.[intItemContractDetailId]
		WHERE [intUniqueId]	= @intUniqueId

		IF NOT EXISTS(SELECT * FROM tblCTItemContractDetail WHERE intItemContractDetailId = @intItemContractDetailId)
		BEGIN
			RAISERROR('Item Contract does not exist.',16,1)
		END

		SET @dblQty = ISNULL(@dblQty,0)
							
		EXEC dbo.uspCTItemContractUpdateScheduleQuantity @intItemContractDetailId	= @intItemContractDetailId
													   , @dblQuantityToUpdate		= @dblQty
													   , @intUserId					= @intUserId
													   , @intTransactionDetailId	= @intSalesOrderDetailId
													   , @strScreenName				= 'Sales Order'

		SELECT @intUniqueId = MIN(intUniqueId) FROM @tblToProcess WHERE intUniqueId > @intUniqueId
	END

END TRY

BEGIN CATCH
	SET @strErrMsg = ERROR_MESSAGE()  
	RAISERROR (@strErrMsg,16,1,'WITH NOWAIT')  
END CATCH
GO