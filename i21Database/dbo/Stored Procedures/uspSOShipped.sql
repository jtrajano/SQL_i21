CREATE PROCEDURE [dbo].[uspSOShipped]
	@ItemsFromInventoryShipment ShipmentItemTableType READONLY 
    ,@ysnPost            BIT = 0

AS

BEGIN	
	DECLARE @intTransactionId	INT,
			@intUserId			INT,
			@isDelete			BIT

	DECLARE @OrderToUpdate TABLE (
		intSalesOrderId INT
		, dblQuantity NUMERIC (18, 6)
	);
	
	SET @isDelete = CASE WHEN @ysnPost = 1 THEN 0 ELSE 1 END

	SELECT	TOP 1 @intTransactionId = intShipmentId 
	FROM	@ItemsFromInventoryShipment
	
	SELECT TOP 1 @intUserId = intEntityId 
	FROM	tblICInventoryShipmentItem ISHI INNER JOIN tblICInventoryShipment ISH 
				ON ISHI.intInventoryShipmentId = ISH.intInventoryShipmentId 
	WHERE	ISHI.intInventoryShipmentId = @intTransactionId

	INSERT INTO @OrderToUpdate(
		intSalesOrderId
		, dblQuantity
	)
    SELECT	intOrderId
			, dblQuantity = dbo.fnCalculateQtyBetweenUOM(si.intItemUOMId, sod.intItemUOMId, si.dblQuantity) -- Convert the uom from shipment to the uom used in the sales order. 
	FROM	tblICInventoryShipmentItem si INNER JOIN tblSOSalesOrderDetail sod
				ON si.intLineNo = sod.intSalesOrderDetailId
				AND si.intOrderId = sod.intSalesOrderId
	WHERE	si.intInventoryShipmentId = @intTransactionId
			AND si.intOrderId IS NOT NULL
	
	WHILE EXISTS(SELECT TOP 1 NULL FROM @OrderToUpdate ORDER BY intSalesOrderId)
	BEGIN				
		DECLARE @intSalesOrderId INT,
				@NewInvoiceId	 INT,
		        @qtyToPost		 NUMERIC (18, 6)
					
		SELECT TOP 1 
				@intSalesOrderId = intSalesOrderId
				, @qtyToPost = dblQuantity 
		FROM	@OrderToUpdate 
		ORDER BY intSalesOrderId        

		EXEC [dbo].[uspSOInsertTransactionDetail] @intSalesOrderId		
		EXEC dbo.[uspSOUpdateCommitted] @intSalesOrderId, @ysnPost ,@qtyToPost

		--Update Contract Balance 
		IF EXISTS(SELECT NULL FROM tblSOSalesOrderDetail SOD INNER JOIN tblCTContractDetail CD 
					ON SOD.intContractDetailId = CD.intContractDetailId AND SOD.intContractHeaderId = CD.intContractHeaderId 
					WHERE SOD.intSalesOrderId = @intSalesOrderId)
			BEGIN
				SET @qtyToPost = CASE WHEN @ysnPost = 1 THEN @qtyToPost * 1 ELSE @qtyToPost * -1 END

				UPDATE CD 
				SET dblBalance = dblBalance - @qtyToPost
				  , dblScheduleQty = dblScheduleQty - @qtyToPost 
				FROM tblCTContractDetail CD
				INNER JOIN tblSOSalesOrderDetail SOD ON 
					SOD.intContractDetailId = CD.intContractDetailId AND SOD.intContractHeaderId = CD.intContractHeaderId 
				WHERE SOD.intSalesOrderId = @intSalesOrderId					
			END

			--UPDATE SO Status 
			DECLARE @dblTotalQtyOrdered AS NUMERIC(18,6) = 0
			DECLARE @dblTotalQtyShipped AS NUMERIC(18,6) = 0
			DECLARE @ysnShipmentPosted AS BIT = 0
			DECLARE @strOrderStatus as VARCHAR(MAX)

			SELECT @dblTotalQtyOrdered = SUM(dblQtyOrdered)
					,@dblTotalQtyShipped = SUM(CASE WHEN dblQtyShipped > dblQtyOrdered THEN dblQtyOrdered ELSE dblQtyShipped END)
					,@ysnShipmentPosted = [IS].ysnPosted
			FROM tblSOSalesOrderDetail [SOD]
			INNER JOIN tblSOSalesOrder [SO]
				ON [SO].intSalesOrderId = [SOD].intSalesOrderId
			LEFT JOIN tblICInventoryShipment [IS]
				ON [IS].strReferenceNumber = SO.strSalesOrderNumber
			WHERE [SO].intSalesOrderId = @intSalesOrderId
			GROUP BY [SO].intSalesOrderId, [IS].ysnPosted

			IF (@dblTotalQtyShipped = 0)
				SET @strOrderStatus = 'Open'
			ELSE IF @dblTotalQtyShipped < @dblTotalQtyOrdered
				SET @strOrderStatus = 'Partial'			
			ELSE IF (@dblTotalQtyShipped = @dblTotalQtyOrdered OR @dblTotalQtyShipped > @dblTotalQtyOrdered)
				SET @strOrderStatus = 'Closed'

			UPDATE tblSOSalesOrder
			SET strOrderStatus = @strOrderStatus
			WHERE intSalesOrderId = @intSalesOrderId
			
		DELETE FROM @OrderToUpdate WHERE intSalesOrderId = @intSalesOrderId
	END

	--IC-2198: Commented the code below. In-Transit Outbound should be updated by IC-Shipment Posting. 
	--EXEC dbo.uspARUpdateInTransit @intTransactionId, @ysnPost, 1

END