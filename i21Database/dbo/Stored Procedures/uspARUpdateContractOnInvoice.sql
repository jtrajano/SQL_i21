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
	INSERT INTO @ItemsFromInvoice 
	--(
	--	-- Header
	--	 [intInvoiceId]
	--	,[strInvoiceNumber]
	--	,[intEntityCustomerId]
	--	,[dtmDate]
	--	,[intCurrencyId]
	--	,[intCompanyLocationId]
	--	,[intDistributionHeaderId]

	--	-- Detail 
	--	,[intInvoiceDetailId]
	--	,[intItemId]
	--	,[strItemNo]
	--	,[strItemDescription]
	--	,[intSCInvoiceId]
	--	,[strSCInvoiceNumber]
	--	,[intItemUOMId]
	--	,[dblQtyOrdered]
	--	,[dblQtyShipped]
	--	,[dblDiscount]
	--	,[dblPrice]
	--	,[dblTotalTax]
	--	,[dblTotal]
	--	,[intServiceChargeAccountId]
	--	,[intInventoryShipmentItemId]
	--	,[intSalesOrderDetailId]
	--	,[intShipmentPurchaseSalesContractId]
	--	,[intSiteId]
	--	,[strBillingBy]
	--	,[dblPercentFull]
	--	,[dblNewMeterReading]
	--	,[dblPreviousMeterReading]
	--	,[dblConversionFactor]
	--	,[intPerformerId]
	--	,[intContractHeaderId]
	--	,[strContractNumber]
	--	,[strMaintenanceType]
	--	,[strFrequency]
	--	,[dtmMaintenanceDate]
	--	,[dblMaintenanceAmount]
	--	,[dblLicenseAmount]
	--	,[intContractDetailId]
	--	,[intTicketId]
	--	,[ysnLeaseBilling]
	--)
	EXEC dbo.[uspARGetItemsFromInvoice]
			@intInvoiceId = @TransactionId

	DECLARE		@intInvoiceDetailId				INT,
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

	--Quantity/UOM Changed
	SELECT
		 I.[intInvoiceDetailId]
		,D.[intContractDetailId]
		,D.[intItemUOMId]
		,dbo.fnCalculateQtyBetweenUOM(D.[intItemUOMId], CD.[intItemUOMId], (CASE WHEN @ForDelete = 1 THEN D.[dblQtyShipped] ELSE (D.dblQtyShipped - TD.dblQtyShipped) END))
	FROM
		@ItemsFromInvoice I
	INNER JOIN
		tblARInvoiceDetail D
			ON	I.[intInvoiceDetailId] = D.[intInvoiceDetailId]
	INNER JOIN
		tblARInvoice H
			ON	D.[intInvoiceId] = H.[intInvoiceId]			
	INNER JOIN
		tblARTransactionDetail TD
			ON D.intInvoiceDetailId = TD.intTransactionDetailId 
			AND D.intInvoiceId = TD.intTransactionId 
			AND TD.strTransactionType = 'Invoice'
	INNER JOIN
		tblCTContractDetail CD
			ON D.intContractDetailId = CD.intContractDetailId
	WHERE
		D.intContractDetailId IS NOT NULL
		AND D.intContractDetailId = TD.intContractDetailId		
		AND D.[intInventoryShipmentItemId] IS NULL
		AND D.[intSalesOrderDetailId] IS NULL
		AND D.[intShipmentPurchaseSalesContractId] IS NULL 
		AND D.[intItemId] = TD.[intItemId]
		AND (D.intItemUOMId <> TD.intItemUOMId OR D.dblQtyShipped <> TD.dblQtyShipped)
		AND (ISNULL(H.intDistributionHeaderId, 0) = 0 AND ISNULL(H.intLoadDistributionHeaderId, 0) = 0)
		AND (ISNULL(D.intLoadDetailId, 0) = 0 AND ISNULL(H.intLoadId, 0) = 0)
		
	UNION ALL

	--New Contract Selected
	SELECT
		 I.[intInvoiceDetailId]
		,D.[intContractDetailId]
		,D.[intItemUOMId]
		,dbo.fnCalculateQtyBetweenUOM(D.[intItemUOMId], CD.[intItemUOMId], D.[dblQtyShipped])
	FROM
		@ItemsFromInvoice I
	INNER JOIN
		tblARInvoiceDetail D
			ON	I.[intInvoiceDetailId] = D.[intInvoiceDetailId]
	INNER JOIN
		tblARInvoice H
			ON	D.[intInvoiceId] = H.[intInvoiceId]				
	INNER JOIN
		tblARTransactionDetail TD
			ON D.intInvoiceDetailId = TD.intTransactionDetailId 
			AND D.intInvoiceId = TD.intTransactionId 
			AND TD.strTransactionType = 'Invoice'
	INNER JOIN
		tblCTContractDetail CD
			ON D.intContractDetailId = CD.intContractDetailId
	WHERE
		D.intContractDetailId IS NOT NULL
		AND D.intContractDetailId <> TD.intContractDetailId		
		AND D.[intInventoryShipmentItemId] IS NULL
		AND D.[intSalesOrderDetailId] IS NULL
		AND D.[intShipmentPurchaseSalesContractId] IS NULL 
		AND D.intItemId = TD.intItemId
		AND (ISNULL(H.intDistributionHeaderId, 0) = 0 AND ISNULL(H.intLoadDistributionHeaderId, 0) = 0)
		AND (ISNULL(D.intLoadDetailId, 0) = 0 AND ISNULL(H.intLoadId, 0) = 0)
		
	UNION ALL

	--Replaced Contract
	SELECT
		 I.[intInvoiceDetailId]
		,TD.[intContractDetailId]
		,TD.[intItemUOMId]
		,dbo.fnCalculateQtyBetweenUOM(TD.[intItemUOMId], CD.[intItemUOMId], (TD.[dblQtyShipped] * -1))
	FROM
		@ItemsFromInvoice I
	INNER JOIN
		tblARInvoiceDetail D
			ON	I.[intInvoiceDetailId] = D.[intInvoiceDetailId]
	INNER JOIN
		tblARInvoice H
			ON	D.[intInvoiceId] = H.[intInvoiceId]				
	INNER JOIN
		tblARTransactionDetail TD
			ON D.intInvoiceDetailId = TD.intTransactionDetailId 
			AND D.intInvoiceId = TD.intTransactionId 
			AND TD.strTransactionType = 'Invoice'
	INNER JOIN
		tblCTContractDetail CD
			ON TD.intContractDetailId = CD.intContractDetailId
	WHERE
		D.intContractDetailId IS NOT NULL
		AND D.intContractDetailId <> TD.intContractDetailId		
		AND D.[intInventoryShipmentItemId] IS NULL
		AND D.[intSalesOrderDetailId] IS NULL
		AND D.[intShipmentPurchaseSalesContractId] IS NULL 
		AND D.intItemId = TD.intItemId
		AND (ISNULL(H.intDistributionHeaderId, 0) = 0 AND ISNULL(H.intLoadDistributionHeaderId, 0) = 0)
		AND (ISNULL(D.intLoadDetailId, 0) = 0 AND ISNULL(H.intLoadId, 0) = 0)
		
	UNION ALL
		
	--Removed Contract
	SELECT
		 I.[intInvoiceDetailId]
		,TD.[intContractDetailId]
		,TD.[intItemUOMId]
		,dbo.fnCalculateQtyBetweenUOM(TD.[intItemUOMId], CD.[intItemUOMId], (TD.[dblQtyShipped] * -1))
	FROM
		@ItemsFromInvoice I
	INNER JOIN
		tblARInvoiceDetail D
			ON	I.[intInvoiceDetailId] = D.[intInvoiceDetailId]
	INNER JOIN
		tblARInvoice H
			ON	D.[intInvoiceId] = H.[intInvoiceId]				
	INNER JOIN
		tblARTransactionDetail TD
			ON D.intInvoiceDetailId = TD.intTransactionDetailId 
			AND D.intInvoiceId = TD.intTransactionId 
			AND TD.strTransactionType = 'Invoice'
	INNER JOIN
		tblCTContractDetail CD
			ON TD.intContractDetailId = CD.intContractDetailId
	WHERE
		D.intContractDetailId IS NULL
		AND TD.intContractDetailId IS NOT NULL
		AND D.[intInventoryShipmentItemId] IS NULL
		AND D.[intSalesOrderDetailId] IS NULL
		AND D.[intShipmentPurchaseSalesContractId] IS NULL 
		AND (ISNULL(H.intDistributionHeaderId, 0) = 0 AND ISNULL(H.intLoadDistributionHeaderId, 0) = 0)
		AND (ISNULL(D.intLoadDetailId, 0) = 0 AND ISNULL(H.intLoadId, 0) = 0)
		
	UNION ALL	

	--Deleted Item
	SELECT
		 TD.intTransactionDetailId
		,TD.[intContractDetailId]
		,TD.[intItemUOMId]
		,dbo.fnCalculateQtyBetweenUOM(TD.[intItemUOMId], CD.[intItemUOMId], (TD.[dblQtyShipped] * -1))
	FROM
		tblARTransactionDetail TD
	INNER JOIN
		tblARInvoice H
			ON	TD.[intTransactionId] = H.[intInvoiceId]		
	INNER JOIN
		tblCTContractDetail CD
			ON TD.intContractDetailId = CD.intContractDetailId
	WHERE
		TD.intTransactionId = @TransactionId 
		AND TD.strTransactionType = 'Invoice'
		AND TD.intContractDetailId IS NOT NULL
		AND TD.[intInventoryShipmentItemId] IS NULL
		AND TD.[intSalesOrderDetailId] IS NULL
		AND TD.[intShipmentPurchaseSalesContractId] IS NULL 
		AND TD.intTransactionDetailId NOT IN (SELECT intInvoiceDetailId FROM tblARInvoiceDetail WHERE intInvoiceId = @TransactionId)
		AND (ISNULL(H.intDistributionHeaderId, 0) = 0 AND ISNULL(H.intLoadDistributionHeaderId, 0) = 0)
		AND ISNULL(H.intLoadId, 0) = 0
		
	UNION ALL
		
	--Added Item
	SELECT
		 Detail.intInvoiceDetailId
		,Detail.[intContractDetailId]
		,Detail.[intItemUOMId]
		,dbo.fnCalculateQtyBetweenUOM(Detail.[intItemUOMId], CD.[intItemUOMId], Detail.[dblQtyShipped])
	FROM
		tblARInvoiceDetail Detail
	INNER JOIN
		tblARInvoice Header
			ON Detail.intInvoiceId = Header.intInvoiceId 
	INNER JOIN
		tblCTContractDetail CD
			ON Detail.intContractDetailId = CD.intContractDetailId
	WHERE
		Detail.intInvoiceId = @TransactionId 
		AND Header.strTransactionType = 'Invoice'
		AND Detail.intContractDetailId IS NOT NULL
		AND Detail.[intInventoryShipmentItemId] IS NULL
		AND Detail.[intSalesOrderDetailId] IS NULL
		AND Detail.[intShipmentPurchaseSalesContractId] IS NULL 
		AND Detail.intInvoiceDetailId NOT IN (SELECT intTransactionDetailId FROM tblARTransactionDetail WHERE intTransactionId = @TransactionId)
		AND (ISNULL(Header.intDistributionHeaderId, 0) = 0 AND ISNULL(Header.intLoadDistributionHeaderId, 0) = 0)
		AND (ISNULL(Detail.intLoadDetailId, 0) = 0 AND ISNULL(Header.intLoadId, 0) = 0)


	SELECT @intUniqueId = MIN(intUniqueId) FROM @tblToProcess

	WHILE ISNULL(@intUniqueId,0) > 0
	BEGIN
		SELECT	@intContractDetailId			=	NULL,
				@intFromItemUOMId				=	NULL,
				@dblQty							=	NULL,
				@intInvoiceDetailId	=	NULL

		SELECT	@intContractDetailId			=	[intContractDetailId],
				@intFromItemUOMId				=	[intItemUOMId],
				@dblQty							=	[dblQty] * (CASE WHEN @ForDelete = 1 THEN -1 ELSE 1 END),
				@intInvoiceDetailId				=	[intInvoiceDetailId]
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
				@intExternalId			=	@intInvoiceDetailId,
				@strScreenName			=	'Invoice'

		SELECT @intUniqueId = MIN(intUniqueId) FROM @tblToProcess WHERE intUniqueId > @intUniqueId
	END

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')  
	
END CATCH
GO
