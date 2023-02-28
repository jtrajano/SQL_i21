﻿CREATE PROCEDURE [dbo].[uspGRReverseOnReceiptDelete]
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
	
	SELECT @intEntityVendorId = intEntityVendorId
		,@intLocationId = intLocationId
		,@strReceiptType = strReceiptType
		,@intSourceType = intSourceType
	FROM dbo.tblICInventoryReceipt
	WHERE intInventoryReceiptId = @InventoryReceiptId

	----Receipt Created By Scale Distributuion	
	BEGIN
		  SELECT @intSourceId= ReceiptItem.intSourceId 
		  FROM tblICInventoryReceipt Receipt
		  JOIN tblICInventoryReceiptItem ReceiptItem ON ReceiptItem.intInventoryReceiptId = Receipt.intInventoryReceiptId 
		  WHERE Receipt.intInventoryReceiptId = @InventoryReceiptId

		  IF EXISTS (
				SELECT 1
				FROM tblGRCustomerStorage CS
				JOIN tblGRStorageHistory SH ON SH.intCustomerStorageId = CS.intCustomerStorageId
				WHERE SH.strType IN ('From Scale', 'From Delivery Sheet')
				AND SH.intInventoryReceiptId = @InventoryReceiptId
				)
			BEGIN
				SELECT @intCustomerStorageId = CS.intCustomerStorageId
				FROM tblGRCustomerStorage CS
				JOIN tblGRStorageHistory SH ON SH.intCustomerStorageId = CS.intCustomerStorageId
				WHERE SH.strType IN ('From Scale', 'From Delivery Sheet')
				AND SH.intInventoryReceiptId = @InventoryReceiptId
			
				IF EXISTS(SELECT 1 FROM tblARInvoiceDetail WHERE intCustomerStorageId = @intCustomerStorageId)
				BEGIN
					RAISERROR('Invoice exists for the Grain Ticket for this receipt.',16, 1);
				END
				ELSE IF EXISTS(SELECT 1 
					FROM [tblAPBillDetail] BD
					INNER JOIN tblAPBill AP
						ON AP.intBillId = BD.intBillId
					WHERE [intCustomerStorageId] = @intCustomerStorageId
						AND AP.intTransactionType = 1 --Voucher transaction only
				)
				BEGIN
					RAISERROR('Voucher exists for this Delivery Sheet.',16, 1);
				END
				ELSE IF EXISTS(SELECT 1 
								FROM tblGRStorageHistory SH
								INNER JOIN tblGRTransferStorage TS
									ON TS.intTransferStorageId = SH.intTransferStorageId
								WHERE SH.intCustomerStorageId = @intCustomerStorageId 
									AND SH.strType = 'Transfer')
				BEGIN
					DECLARE @TransferTicketNo VARCHAR(500)

					SELECT @TransferTicketNo = STUFF((
						SELECT ',' + TS.strTransferStorageTicket
						FROM tblGRTransferStorage TS
						INNER JOIN tblGRTransferStorageSourceSplit T_SOURCE
							ON T_SOURCE.intSourceCustomerStorageId = @intCustomerStorageId
								AND T_SOURCE.intTransferStorageId = TS.intTransferStorageId
						FOR XML PATH('')
					),1,1,'')

					IF CHARINDEX(',',@TransferTicketNo) > 0
					BEGIN
						SET @ErrMsg = 'Transfers '+ @TransferTicketNo + ' are already created for this Ticket. Reverse Transfer Storages first.'
					END
					ELSE
					BEGIN
						SET @ErrMsg = 'Transfer '+ @TransferTicketNo + ' is already created for this Ticket. Reverse Transfer Storage first.'
					END
						
					RAISERROR(@ErrMsg,16, 1);
				END
				ELSE IF EXISTS(SELECT 1 FROM [tblGRCustomerStorage] WHERE [intCustomerStorageId] = @intCustomerStorageId AND dblOriginalBalance < > dblOpenBalance)
				BEGIN
					RAISERROR('There is mismatch between the original balance and open balance of the grain ticket of this receipt.',16, 1);
				END

				DELETE
				FROM tblQMTicketDiscount
				WHERE intTicketFileId = @intCustomerStorageId AND strSourceType = 'Storage'

				-- we need to clear the transaction links before deleting the actual customer storage 
				exec uspSCAddTransactionLinks 
					@intTransactionType = 5
					, @intTransactionId = @intCustomerStorageId
					, @intAction = 2

				DELETE
				FROM tblGRCustomerStorage
				WHERE intCustomerStorageId = @intCustomerStorageId
			END		
	END
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH
