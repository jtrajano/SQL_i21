PRINT 'BEGIN UPDATING TRANSACTION ID IN SETTLE STORAGE REFERENCE TABLE'
GO

IF EXISTS(
			SELECT 1 
			FROM sys.columns 
			WHERE name IN (N'intTransactionId',N'intTransactionId')
				AND object_id = object_id(N'dbo.tblGRSettleVoucherCreateReferenceTable')
		)
BEGIN

IF EXISTS(SELECT TOP 1 1 FROM tblGRSettleVoucherCreateReferenceTable WHERE intTransactionId IS NULL)
BEGIN
	UPDATE SVC
	SET intTransactionId = IT.intTransactionId
	FROM tblGRSettleVoucherCreateReferenceTable SVC
	INNER JOIN tblICInventoryTransaction IT
		ON IT.strBatchId = SVC.strBatchId
	WHERE SVC.intTransactionId IS NULL
END
END

PRINT 'END UPDATING TRANSACTION ID IN SETTLE STORAGE REFERENCE TABLE'
GO