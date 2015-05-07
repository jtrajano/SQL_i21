CREATE PROCEDURE [dbo].[uspSOUpdateOrderShipmentStatus]
	@SalesOrderId			INT
AS
BEGIN

	UPDATE
		tblSOSalesOrderDetail
	SET
		dblQtyShipped = SHP.[dblQuantity]
	FROM
		(
			SELECT
				 ISD.[intSourceId]
				,ISD.[intLineNo]
				,SUM(ISNULL(ISD.[dblQuantity], 0.00))	[dblQuantity]
			FROM
				tblICInventoryShipmentItem ISD
			INNER JOIN
				tblICInventoryShipment ISH
					ON ISD.[intInventoryShipmentId] = ISH.[intInventoryShipmentId]
					AND ISH.[ysnPosted]  = 1
			WHERE
				ISD.[intSourceId] = @SalesOrderId
			GROUP BY
				ISD.[intSourceId]			
				,ISD.[intLineNo]
		) SHP
	WHERE
		[intSalesOrderId] = SHP.[intSourceId]
		
		

	DECLARE	@QuantityShipped	NUMERIC(18,6)
			,@QuantityOrdered	NUMERIC(18,6)
			,@OrderStatus		NVARCHAR(50)
			,@HasPartial		BIT
		
	SELECT	@QuantityShipped	= 0.00
			,@QuantityOrdered	= 0.00
			,@OrderStatus		= 'Pending'
			,@HasPartial		= 0
			

	SELECT 
		 @QuantityShipped = SUM(ISNULL([dblQtyShipped],0.00))
		,@QuantityOrdered = SUM(ISNULL([dblQtyOrdered],0.00))
	FROM
		tblSOSalesOrderDetail
	WHERE
		[intSalesOrderId] = @SalesOrderId

	SET @HasPartial = (SELECT COUNT(1) FROM tblSOSalesOrderDetail WHERE [intSalesOrderId] = @SalesOrderId AND ISNULL([dblQtyShipped],0.00) < ISNULL([dblQtyOrdered],0.00))		
		
	IF (@QuantityShipped = 0.00)
		SET @OrderStatus = 'Pending'
		
	IF (@QuantityShipped > 0.00 AND @HasPartial = 1)
		SET @OrderStatus = 'In Process'
		
	IF (@QuantityShipped > 0.00 AND @HasPartial = 0)	
		SET @OrderStatus = 'Complete'

		
	UPDATE
		tblSOSalesOrder
	SET
		[strOrderStatus] = @OrderStatus
	WHERE
		[intSalesOrderId] = @SalesOrderId
	

END