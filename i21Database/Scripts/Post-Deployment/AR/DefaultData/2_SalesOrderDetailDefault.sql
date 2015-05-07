---------------------------------------------------------
-- IMPORTANT NOTE: REMOVE THIS SCRIPT ON 1530
-- Purpose: To default dblQtyShipped to Zero 
---------------------------------------------------------
print('/*******************  BEGIN Update NULL dblQtyShipped in tblSOSalesOrderDetail with zero  *******************/')
GO

UPDATE	dbo.tblSOSalesOrderDetail 
SET		dblQtyShipped = 0.00
WHERE	dblQtyShipped IS NULL 

GO
print('/*******************  END Update NULL dblQtyShipped in tblSOSalesOrderDetail with zero  *******************/')