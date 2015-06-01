---------------------------------------------------------
-- IMPORTANT NOTE: REMOVE THIS SCRIPT ON 1530
---------------------------------------------------------
print('/*******************  BEGIN - Change tblSOSalesOrder strOrderStatus ''Complete'' to ''Closed''  *******************/')
GO

UPDATE tblSOSalesOrder SET strOrderStatus = 'Closed' WHERE strOrderStatus = 'Complete' AND strTransactionType = 'Order'

GO
print('/*******************  END - Change tblSOSalesOrder strOrderStatus ''Complete'' to ''Closed''  *******************/')



print('/*******************  BEGIN - Update tblSOSalesOrder strOrderStatus NOT IN (''Closed'',''Complete'')  *******************/')
GO

DECLARE @OrderToUpdate TABLE (intSalesOrderId INT);
			
INSERT INTO @OrderToUpdate(intSalesOrderId)
SELECT DISTINCT
		SO.intSalesOrderId
FROM
	tblSOSalesOrder SO
WHERE 
	SO.strOrderStatus NOT IN ('Closed','Complete')
	 AND strTransactionType = 'Order'
				

WHILE EXISTS(SELECT TOP 1 NULL FROM @OrderToUpdate ORDER BY intSalesOrderId)
	BEGIN
				
		DECLARE @intSalesOrderId INT;
					
		SELECT TOP 1 @intSalesOrderId = intSalesOrderId FROM @OrderToUpdate ORDER BY intSalesOrderId

		EXEC dbo.uspSOUpdateOrderShipmentStatus @intSalesOrderId
									
		DELETE FROM @OrderToUpdate WHERE intSalesOrderId = @intSalesOrderId AND intSalesOrderId = @intSalesOrderId 
												
	END 

GO
print('/*******************  BEGIN - Update tblSOSalesOrder strOrderStatus NOT IN (''Closed'',''Complete'')  *******************/')