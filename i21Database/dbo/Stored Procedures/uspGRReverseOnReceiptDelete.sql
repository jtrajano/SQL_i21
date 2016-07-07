CREATE PROCEDURE [dbo].[uspGRReverseOnReceiptDelete]
 @InventoryReceiptId INT
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intEntityVendorId INT
	DECLARE @intLocationId INT
	DECLARE @strReceiptType NVARCHAR(50)
	DECLARE @intCustomerStorageId INT
	DECLARE @intSourceType INT
	DECLARE @intSourceId INT
	DECLARE @TotalReceiptsForScaleTicketNumber INT
	
	SELECT @intEntityVendorId = intEntityVendorId
		,@intLocationId = intLocationId
		,@strReceiptType = strReceiptType
		,@intSourceType = intSourceType
	FROM dbo.tblICInventoryReceipt
	WHERE intInventoryReceiptId = @InventoryReceiptId

	IF @intSourceType = 1
	BEGIN
	  SELECT @intSourceId= ReceiptItem.intSourceId 
	  FROM tblICInventoryReceipt Receipt
	  JOIN tblICInventoryReceiptItem ReceiptItem ON ReceiptItem.intInventoryReceiptId = Receipt.intInventoryReceiptId 
	  WHERE Receipt.intInventoryReceiptId = @InventoryReceiptId
	  
	  SELECT @TotalReceiptsForScaleTicketNumber=COUNT(*)
	  FROM tblICInventoryReceipt Receipt 
	  JOIN tblICInventoryReceiptItem ReceiptItem ON ReceiptItem.intInventoryReceiptId = Receipt.intInventoryReceiptId
	  WHERE Receipt.intSourceType=1 AND ReceiptItem.intSourceId=@intSourceId
			
		--1. IF Original Balance NOT EQUAL to OPEN BALANCE??
		---Receipt With Grain Storage Ticket------
		IF EXISTS (
				SELECT 1
				FROM tblGRCustomerStorage CS
				JOIN tblGRStorageHistory SH ON SH.intCustomerStorageId = CS.intCustomerStorageId
				WHERE SH.strType = 'From Scale' AND SH.intInventoryReceiptId = @InventoryReceiptId
				)
		BEGIN
			SELECT @intCustomerStorageId = CS.intCustomerStorageId
			FROM tblGRCustomerStorage CS
			JOIN tblGRStorageHistory SH ON SH.intCustomerStorageId = CS.intCustomerStorageId
			WHERE SH.strType = 'From Scale' AND SH.intInventoryReceiptId = @InventoryReceiptId
			
			IF EXISTS(SELECT 1 FROM tblARInvoiceDetail WHERE intCustomerStorageId = @intCustomerStorageId)
			BEGIN
				RAISERROR('Invoice Exists for the Grain Ticket for this receipt.',16, 1);
			END
			ELSE IF EXISTS(SELECT 1 FROM [tblAPBillDetail] WHERE [intCustomerStorageId] = @intCustomerStorageId)
			BEGIN
				RAISERROR('Voucher Exists for the Grain Ticket for this receipt.',16, 1);
			END
			ELSE IF EXISTS(SELECT 1 FROM [tblGRStorageHistory] WHERE [intCustomerStorageId] = @intCustomerStorageId AND strType = 'Transfer')
			BEGIN
				RAISERROR('The Grain Ticket of this receipt has transferred.',16, 1);
			END
			ELSE IF EXISTS(SELECT 1 FROM [tblGRCustomerStorage] WHERE [intCustomerStorageId] = @intCustomerStorageId AND dblOriginalBalance < > dblOpenBalance)
			BEGIN
				RAISERROR('There is mismatch between the original balance and open balance of the grain ticket of this receipt.',16, 1);
			END

			--2. IF Ticket is Transfered or Invoiced Or Billed,Show Error. 
			DELETE
			FROM tblQMTicketDiscount
			WHERE intTicketFileId = @intCustomerStorageId AND strSourceType = 'Storage'

			DELETE
			FROM tblGRCustomerStorage
			WHERE intCustomerStorageId = @intCustomerStorageId
		END
		---END Receipt With Grain Storage Ticket---
		--Suppose a Scale Ticket has mutiple Receipts then the Scale Ticket Status should be changed when all Receipts Will be deleted .
		
		IF @TotalReceiptsForScaleTicketNumber=1
		BEGIN
			UPDATE tblSCTicket SET strTicketStatus='O' WHERE intTicketId=@intSourceId
		END
		
	END
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH
