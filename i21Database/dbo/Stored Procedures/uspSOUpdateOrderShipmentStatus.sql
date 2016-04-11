﻿CREATE PROCEDURE [dbo].[uspSOUpdateOrderShipmentStatus]
	@SalesOrderId			INT,
	@ysnOpenStatus			BIT = 0,
	@ForDelete				BIT = 0
AS
BEGIN

DECLARE	@OrderStatus NVARCHAR(50)
SET @OrderStatus = 'Open'

IF @ysnOpenStatus = 1
	BEGIN		
		GOTO SET_ORDER_STATUS;
	END	

DECLARE @IsOpen BIT = 0
SET @IsOpen = (	SELECT COUNT(1) 
					FROM
						tblSOSalesOrderDetail					
					WHERE
						[intSalesOrderId] = @SalesOrderId 
						AND (NOT EXISTS(	SELECT NULL 
											FROM
												tblICInventoryShipmentItem
											WHERE
												intLineNo = tblSOSalesOrderDetail.[intSalesOrderDetailId]
												AND intOrderId = @SalesOrderId
											)
							AND
							EXISTS(			SELECT NULL 
											FROM 
												tblICItem 
											WHERE
												tblICItem.[intItemId] = tblSOSalesOrderDetail.[intSalesOrderDetailId]
												AND ISNULL(tblICItem.strLotTracking, 'No') <> 'No'
											)
						)
						AND (NOT EXISTS(	SELECT NULL 
										FROM
											tblARInvoiceDetail 
										WHERE
											intSalesOrderDetailId = tblSOSalesOrderDetail.intSalesOrderDetailId
										)
							AND
							EXISTS(			SELECT NULL 
											FROM 
												tblICItem 
											WHERE
												tblICItem.[intItemId] = tblSOSalesOrderDetail.[intSalesOrderDetailId]												
												AND ISNULL(tblICItem.strLotTracking, 'No') = 'No'
											)										
						)										
					)
					
IF(NOT EXISTS(SELECT NULL FROM tblICInventoryShipmentItem WHERE intOrderId = @SalesOrderId) 
		AND NOT EXISTS(SELECT NULL FROM tblARInvoiceDetail ISD
		INNER JOIN tblARInvoice ISH
			ON ISD.intInvoiceId = ISH.intInvoiceId
		INNER JOIN tblSOSalesOrderDetail SOD
			ON ISD.intSalesOrderDetailId = SOD.intSalesOrderDetailId
		WHERE (ISD.intInventoryShipmentItemId IS NULL OR ISD.intInventoryShipmentItemId = 0)			
		  AND (ISD.[intSalesOrderDetailId] IS NOT NULL OR ISD.[intSalesOrderDetailId] <> 0)	
		  AND SOD.intSalesOrderId = @SalesOrderId
		GROUP BY
			ISD.[intSalesOrderDetailId]))
	SET @IsOpen = 1
					
IF @IsOpen <> 0
	BEGIN
		SET @OrderStatus = 'Open'
		GOTO SET_ORDER_STATUS;
	END					
	
UPDATE
	tblSOSalesOrderDetail
SET
	dblQtyShipped = dblQtyShipped + ISNULL(SHP.[dblQuantity], 0.00)
FROM
	(
		SELECT
			 ISD.[intOrderId]
			,ISD.[intLineNo]
			,SUM(ISNULL((CASE WHEN @ForDelete = 0 THEN
								CASE WHEN ISH.ysnPosted = 1 THEN dbo.fnCalculateQtyBetweenUOM(ISD.[intItemUOMId], SOD.[intItemUOMId], ISNULL(ISD.[dblQuantity],0)) ELSE SOD.[dblQtyShipped] END
							ELSE 
								CASE WHEN ISH.ysnPosted = 1 THEN dbo.fnCalculateQtyBetweenUOM(ISD.[intItemUOMId], SOD.[intItemUOMId], ISNULL(ISD.[dblQuantity],0)) ELSE SOD.[dblQtyShipped] END * -1 
						  END
			 ), 0.00)) [dblQuantity]
		FROM
			tblICInventoryShipmentItem ISD
		INNER JOIN
			tblICInventoryShipment ISH
				ON ISD.[intInventoryShipmentId] = ISH.[intInventoryShipmentId]
		LEFT JOIN
			tblSOSalesOrderDetail SOD ON ISD.[intLineNo] = SOD.intSalesOrderDetailId
		WHERE
			ISD.[intOrderId] = @SalesOrderId
		GROUP BY
			ISD.[intOrderId]			
			,ISD.[intLineNo]
	) SHP
WHERE
	[intSalesOrderId] = SHP.[intOrderId]
	AND [intSalesOrderDetailId] = SHP.[intLineNo] 

UPDATE
	tblSOSalesOrderDetail
SET
	dblQtyShipped = dblQtyShipped + ISNULL(SHP.[dblQuantity], 0.00)
FROM
	(
		SELECT
			 ID.[intSalesOrderDetailId]
			,SUM(ISNULL((CASE WHEN @ForDelete = 0 THEN 
								CASE WHEN I.ysnPosted = 1 THEN dbo.fnCalculateQtyBetweenUOM(ID.[intItemUOMId], SOD.[intItemUOMId], ISNULL(ID.[dblQtyShipped],0)) ELSE SOD.[dblQtyShipped] END
							  ELSE 
								CASE WHEN I.ysnPosted = 1 THEN dbo.fnCalculateQtyBetweenUOM(ID.[intItemUOMId], SOD.[intItemUOMId], ISNULL(ID.[dblQtyShipped],0)) ELSE SOD.[dblQtyShipped] END * -1 
						  END
			), 0.00)) [dblQuantity]
		FROM
			tblARInvoiceDetail ID
		INNER JOIN
			tblARInvoice I
				ON ID.[intInvoiceId] = I.[intInvoiceId]
		LEFT JOIN
			tblSOSalesOrderDetail SOD ON ID.intSalesOrderDetailId = SOD.intSalesOrderDetailId
		WHERE
			ISNULL(ID.[intSalesOrderDetailId], 0) <> 0
			AND ID.intSalesOrderDetailId NOT IN (SELECT intLineNo FROM tblICInventoryShipmentItem WHERE ISNULL(intLineNo, 0) > 0)
		GROUP BY
			ID.[intSalesOrderDetailId]
	) SHP
WHERE
	[intSalesOrderId] = @SalesOrderId
	AND tblSOSalesOrderDetail.[intSalesOrderDetailId] = SHP.[intSalesOrderDetailId]
	
DECLARE @TotalQtyOrdered	NUMERIC(18,6) = 0,
		@TotalQtyShipped	NUMERIC(18,6) = 0

SELECT @TotalQtyOrdered = SUM(dblQtyOrdered)
     , @TotalQtyShipped = SUM(CASE WHEN dblQtyShipped > dblQtyOrdered THEN dblQtyOrdered ELSE dblQtyShipped END) 
FROM tblSOSalesOrderDetail WHERE intSalesOrderId = @SalesOrderId 
GROUP BY intSalesOrderId

IF (@TotalQtyShipped = 0)
	BEGIN
		SET @OrderStatus = 'Pending'
		GOTO SET_ORDER_STATUS;
	END	

IF (@TotalQtyShipped < @TotalQtyOrdered)
	BEGIN
		SET @OrderStatus = 'Partial'
		GOTO SET_ORDER_STATUS;
	END	
		
SET @OrderStatus = 'Closed'
		
SET_ORDER_STATUS:	
	UPDATE tblSOSalesOrder
	SET [strOrderStatus] = @OrderStatus
	  , [dtmProcessDate] = GETDATE()
	  , [ysnProcessed]   = CASE WHEN @OrderStatus <> 'Open' THEN 1 ELSE 0 END	  
	WHERE [intSalesOrderId] = @SalesOrderId
		
	RETURN;
END