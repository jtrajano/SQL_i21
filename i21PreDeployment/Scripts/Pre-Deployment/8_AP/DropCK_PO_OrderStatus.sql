
PRINT 'BEGIN Drop CK_PO_OrderStatus'

IF EXISTS(SELECT TOP 1 1 FROM sys.objects WHERE name = 'CK_PO_OrderStatus' AND type = 'C' AND parent_object_id = OBJECT_ID('tblPOPurchase', 'U'))
BEGIN
	EXEC('
		ALTER TABLE tblPOPurchase
		DROP CONSTRAINT CK_PO_OrderStatus		
	');
END

GO
PRINT 'END Drop CK_PO_OrderStatus'