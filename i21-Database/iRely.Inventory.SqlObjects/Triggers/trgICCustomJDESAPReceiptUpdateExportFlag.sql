CREATE TRIGGER [trgICCustomJDESAPReceiptUpdateExportFlag]
ON tblICInventoryReceipt
FOR UPDATE
AS
BEGIN
	IF EXISTS(SELECT TOP 1 1 FROM tblIPSAPIDOCTag WHERE strTag ='UPDATE_RECEIPT_EXPORT_FLAG_ON_UNPOST' AND strValue = 'TRUE')
	BEGIN
		UPDATE	ri	
		SET		ysnExported = NULL 
		FROM	tblICInventoryReceiptItem ri INNER JOIN inserted i
					ON ri.intInventoryReceiptId = i.intInventoryReceiptId
		WHERE	ISNULL(i.ysnPosted, 0) = 0 
	END 
END