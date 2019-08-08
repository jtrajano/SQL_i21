CREATE PROCEDURE [dbo].[uspARUpdateItemContractOnInvoice]
	  @intInvoiceId		INT   
	, @ysnForDelete		BIT = 0
	, @intUserId		INT = NULL     
AS  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF  

BEGIN TRY
	DECLARE @intUniqueId		INT = NULL
	DECLARE @strErrMsg			NVARCHAR(MAX)
	DECLARE @ItemsFromInvoice	dbo.[InvoiceItemTableType]
	DECLARE @tblToProcess TABLE (
		  intUniqueId				INT IDENTITY
		, intInvoiceDetailId		INT
		, intItemContractDetailId	INT
		, dblQty					NUMERIC(12,4)
	)

	--GET INVOICE ITEM CONTRACTS
	INSERT INTO @ItemsFromInvoice 
	EXEC dbo.[uspARGetItemsFromInvoice] @intInvoiceId = @intInvoiceId

	--REMOVE OVERPAYMENTS AND CUSTOMER PREPAYMENT ITEM CONTRACTS
	DELETE FROM @ItemsFromInvoice WHERE strTransactionType NOT IN ('Overpayment', 'Customer Prepayment')

	INSERT INTO @tblToProcess (
		  intInvoiceDetailId
		, intItemContractDetailId
		, dblQty
	)
	--QTY/UOM CHANGED
	SELECT intInvoiceDetailId		= ID.intInvoiceDetailId
		 , intItemContractDetailId	= ID.intItemContractDetailId
		 , dblQty					= dbo.fnCalculateQtyBetweenUOM(ID.intItemUOMId, ICD.intItemUOMId, (CASE WHEN @ysnForDelete = 1 THEN ID.dblQtyShipped ELSE (ID.dblQtyShipped - TD.dblQtyShipped) END))
	FROM @ItemsFromInvoice I
	INNER JOIN tblARInvoiceDetail ID ON	I.intInvoiceDetailId = ID.intInvoiceDetailId
	INNER JOIN tblARTransactionDetail TD ON ID.intInvoiceDetailId = TD.intTransactionDetailId 
										AND ID.intInvoiceId = TD.intTransactionId 
										AND TD.strTransactionType = 'Invoice'
	INNER JOIN tblCTItemContractDetail ICD ON ID.intItemContractDetailId = ICD.intItemContractDetailId
	WHERE ID.intItemContractDetailId IS NOT NULL
	  AND ID.intItemContractDetailId = TD.intItemContractDetailId
	  AND ID.intSalesOrderDetailId IS NULL
	  AND ID.intItemId = TD.intItemId
	  AND (ID.intItemUOMId <> TD.intItemUOMId OR ID.dblQtyShipped <> TD.dblQtyShipped)
		
	UNION ALL

	--NEW CONTRACT SELECTED
	SELECT intInvoiceDetailId		= ID.intInvoiceDetailId
		 , intItemContractDetailId	= ID.intItemContractDetailId
		 , dblQty					= dbo.fnCalculateQtyBetweenUOM(ID.intItemUOMId, ICD.intItemUOMId, ID.[dblQtyShipped])
	FROM @ItemsFromInvoice I
	INNER JOIN tblARInvoiceDetail ID ON	I.intInvoiceDetailId = ID.intInvoiceDetailId
	INNER JOIN tblARTransactionDetail TD ON ID.intInvoiceDetailId = TD.intTransactionDetailId 
										AND ID.intInvoiceId = TD.intTransactionId 
										AND TD.strTransactionType = 'Invoice'
	INNER JOIN tblCTItemContractDetail ICD ON ID.intItemContractDetailId = ICD.intItemContractDetailId
	WHERE ID.intItemContractDetailId IS NOT NULL
	  AND ID.intItemContractDetailId <> ISNULL(TD.intItemContractDetailId, 0)	  
	  AND ID.intSalesOrderDetailId IS NULL
	  AND ID.intItemId = TD.intItemId
		
	UNION ALL

	--REPLACE CONTRACT 
	SELECT intInvoiceDetailId		= I.intInvoiceDetailId
		 , intItemContractDetailId	= TD.intItemContractDetailId
		 , dblQty					= dbo.fnCalculateQtyBetweenUOM(TD.intItemUOMId, ICD.intItemUOMId, (TD.dblQtyShipped * -1))
	FROM @ItemsFromInvoice I
	INNER JOIN tblARInvoiceDetail ID ON I.intInvoiceDetailId = ID.intInvoiceDetailId
	INNER JOIN tblARTransactionDetail TD ON ID.intInvoiceDetailId = TD.intTransactionDetailId 
										AND ID.intInvoiceId = TD.intTransactionId 
										AND TD.strTransactionType = 'Invoice'
	INNER JOIN tblCTItemContractDetail ICD ON TD.intItemContractDetailId = ICD.intItemContractDetailId
	WHERE ID.intItemContractDetailId IS NOT NULL
	  AND ID.intItemContractDetailId <> ISNULL(TD.intItemContractDetailId, 0)
	  AND ID.intSalesOrderDetailId IS NULL
	  AND ID.intItemId = TD.intItemId
		
	UNION ALL
		
	--REMOVED CONTRACT
	SELECT intInvoiceDetailId		= I.intInvoiceDetailId
		 , intItemContractDetailId	= TD.intItemContractDetailId
		 , dblQty					= dbo.fnCalculateQtyBetweenUOM(TD.intItemUOMId, ICD.intItemUOMId, (TD.dblQtyShipped * -1))
	FROM @ItemsFromInvoice I
	INNER JOIN tblARInvoiceDetail ID ON	I.intInvoiceDetailId = ID.intInvoiceDetailId
	INNER JOIN tblARTransactionDetail TD ON ID.intInvoiceDetailId = TD.intTransactionDetailId 
										AND ID.intInvoiceId = TD.intTransactionId 
										AND TD.strTransactionType = 'Invoice'
	INNER JOIN tblCTItemContractDetail ICD ON TD.intItemContractDetailId = ICD.intItemContractDetailId
	WHERE ID.intItemContractDetailId IS NULL
	  AND TD.intItemContractDetailId IS NOT NULL
	  AND ID.intSalesOrderDetailId IS NULL
		
	UNION ALL	

	--DELETED ITEM
	SELECT intInvoiceDetailId		= TD.intTransactionDetailId
		 , intItemContractDetailId	= TD.intItemContractDetailId
		 , dblQty					= dbo.fnCalculateQtyBetweenUOM(TD.intItemUOMId, ICD.intItemUOMId, (TD.dblQtyShipped * -1))
	FROM tblARTransactionDetail TD
	INNER JOIN tblCTItemContractDetail ICD ON TD.intItemContractDetailId = ICD.intItemContractDetailId
	WHERE TD.intTransactionId = @intInvoiceId 
	  AND TD.strTransactionType = 'Invoice'
	  AND TD.intItemContractDetailId IS NOT NULL
	  AND TD.intSalesOrderDetailId IS NULL
	  AND TD.intTransactionDetailId NOT IN (SELECT intInvoiceDetailId FROM tblARInvoiceDetail WHERE intInvoiceId = @intInvoiceId)
		
	UNION ALL
		
	--ADDED ITEM
	SELECT intInvoiceDetailId		= ID.intInvoiceDetailId
		 , intItemContractDetailId	= ID.intItemContractDetailId
		 , dblQty					= dbo.fnCalculateQtyBetweenUOM(ID.intItemUOMId, ICD.intItemUOMId, ID.dblQtyShipped)
	FROM tblARInvoiceDetail ID
	INNER JOIN tblARInvoice I ON ID.intInvoiceId = I.intInvoiceId 
	INNER JOIN tblCTItemContractDetail ICD ON ID.intItemContractDetailId = ICD.intItemContractDetailId
	WHERE ID.intInvoiceId = @intInvoiceId 
	  AND I.strTransactionType = 'Invoice'
	  AND ID.intItemContractDetailId IS NOT NULL
	  AND ID.intSalesOrderDetailId IS NULL
	  AND ID.intInvoiceDetailId NOT IN (SELECT intTransactionDetailId FROM tblARTransactionDetail WHERE intTransactionId = @intInvoiceId)

	SELECT @intUniqueId = MIN(intUniqueId) 
	FROM @tblToProcess

	WHILE ISNULL(@intUniqueId,0) > 0
	BEGIN
		DECLARE @intItemContractDetailId	INT = NULL
			  , @intInvoiceDetailId			INT = NULL
			  , @dblQty						NUMERIC(18, 6) = 0

		SELECT @intItemContractDetailId = intItemContractDetailId
			 , @dblQty					= dblQty * (CASE WHEN @ysnForDelete = 1 THEN -1 ELSE 1 END)
			 , @intInvoiceDetailId		= intInvoiceDetailId
		FROM @tblToProcess 
		WHERE [intUniqueId]	= @intUniqueId

		IF NOT EXISTS(SELECT * FROM tblCTItemContractDetail WHERE intItemContractDetailId = @intItemContractDetailId)
		BEGIN
			RAISERROR('Item Contract does not exist.',16,1)
		END

		SET @dblQty = ISNULL(@dblQty,0)

		EXEC dbo.uspCTItemContractUpdateScheduleQuantity @intItemContractDetailId	= @intItemContractDetailId
													   , @dblQuantityToUpdate		= @dblQty
													   , @intUserId					= @intUserId
													   , @intTransactionDetailId	= @intInvoiceDetailId
													   , @strScreenName				= 'Invoice'

		SELECT @intUniqueId = MIN(intUniqueId) FROM @tblToProcess WHERE intUniqueId > @intUniqueId
	END

END TRY

BEGIN CATCH
	SET @strErrMsg = ERROR_MESSAGE()  
	RAISERROR (@strErrMsg, 16, 1,'WITH NOWAIT')  	
END CATCH