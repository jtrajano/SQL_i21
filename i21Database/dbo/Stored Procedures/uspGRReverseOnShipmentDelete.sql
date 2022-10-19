CREATE PROCEDURE [dbo].[uspGRReverseOnShipmentDelete]
 @InventoryShipmentId INT
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
	
	SELECT @intEntityVendorId = intEntityCustomerId
		,@intLocationId = intShipFromLocationId		
		,@intSourceType = intSourceType
	FROM dbo.tblICInventoryShipment
	WHERE intInventoryShipmentId = @InventoryShipmentId

	----Receipt Created By Scale Distributuion	
	BEGIN
		  SELECT @intSourceId= ShipmentItem.intSourceId 
		  FROM tblICInventoryShipment Shipment
		  JOIN tblICInventoryShipmentItem ShipmentItem 
			ON Shipment.intInventoryShipmentId = ShipmentItem.intInventoryShipmentId
		  WHERE Shipment.intInventoryShipmentId= @InventoryShipmentId

		  IF EXISTS (
				SELECT 1
				FROM tblGRCustomerStorage CS
				JOIN tblGRStorageHistory SH ON SH.intCustomerStorageId = CS.intCustomerStorageId
				WHERE SH.strType IN ('From Scale', 'From Delivery Sheet')
				AND SH.intInventoryShipmentId = @InventoryShipmentId
				)
			BEGIN			
				

				SELECT @intCustomerStorageId = CS.intCustomerStorageId
				FROM tblGRCustomerStorage CS
				JOIN tblGRStorageHistory SH ON SH.intCustomerStorageId = CS.intCustomerStorageId
				WHERE SH.strType IN ('From Scale', 'From Delivery Sheet')
				AND SH.intInventoryShipmentId = @InventoryShipmentId
			
				IF EXISTS(SELECT 1 FROM tblARInvoiceDetail WHERE intCustomerStorageId = @intCustomerStorageId)
				BEGIN
					RAISERROR('Invoice exists for the Grain Ticket for this receipt.',16, 1);
				END
				ELSE IF EXISTS(SELECT 1 FROM [tblAPBillDetail] WHERE [intCustomerStorageId] = @intCustomerStorageId)
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
