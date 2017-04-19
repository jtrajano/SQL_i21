CREATE TRIGGER [trgCustomJDESAPReceiptUpdateExportFlag]
ON tblICInventoryReceipt
FOR UPDATE
AS
Begin

Declare @intInventoryReceiptId INT,
		@ysnPosted Bit

If Not Exists(
	Select 1 From tblIPSAPIDOCTag Where strTag='UPDATE_RECEIPT_EXPORT_FLAG_ON_UNPOST' AND strValue='TRUE'
)
return

Select @intInventoryReceiptId=intInventoryReceiptId,@ysnPosted=ISNULL(ysnPosted,0) From inserted

If @ysnPosted=0
	Update tblICInventoryReceiptItem Set ysnExported=null Where intInventoryReceiptId=@intInventoryReceiptId

End
