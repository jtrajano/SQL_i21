CREATE PROCEDURE [dbo].[uspGRReverseTicketOpenBalance]
   @strSourceType NVARCHAR(30)
  ,@IntSourceKey INT
  ,@intUserId INT
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @strUserName NVARCHAR(40)
	DECLARE @strType NVARCHAR(100)

	SELECT @strUserName=strUserName
	FROM tblSMUserSecurity
	WHERE [intEntityUserSecurityId] = @intUserId

	SELECT @strType= CASE 
							 WHEN @strSourceType = 'Invoice' THEN 'Reduced By Invoice' 
							 WHEN @strSourceType = 'InventoryShipment' THEN 'Reduced By Inventory Shipment'
							 WHEN @strSourceType = 'Scale'      THEN 'Reduced By Scale'
					 END

    IF @strType='Reduced By Inventory Shipment'
	BEGIN
		UPDATE CS
		SET CS.dblOpenBalance = CS.dblOpenBalance + SH.dblUnits
		FROM tblGRCustomerStorage CS
		JOIN tblGRStorageHistory SH  ON SH.intCustomerStorageId = CS.intCustomerStorageId AND SH.intInventoryShipmentId=@IntSourceKey AND SH.strType=@strType
		
		INSERT INTO [dbo].[tblGRStorageHistory] 
		(
			 [intConcurrencyId]
			,[intCustomerStorageId]
			,[intTicketId]
			,[intInvoiceId]
			,[intInventoryShipmentId]
			,[dblUnits]
			,[dtmHistoryDate]
			,[dblPaidAmount]
			,[strType]
			,[strUserName]
		)
		SELECT 
			 [intConcurrencyId] = 1
			,[intCustomerStorageId] = intCustomerStorageId
			,[intTicketId] = intTicketId
			,[intInvoiceId]=intInvoiceId
			,[intInventoryShipmentId] = intInventoryShipmentId
			,[dblUnits] = dblUnits
			,[dtmHistoryDate] = GetDATE()
			,[dblPaidAmount] = NULL 
			,[strType] = 'Reverse By Inventory Shipment'
			,[strUserName] = @strUserName
		FROM tblGRStorageHistory WHERE intInventoryShipmentId=@IntSourceKey AND strType=@strType

	END
	ELSE IF  @strType='Reduced By Scale'
	BEGIN
		UPDATE CS
		SET CS.dblOpenBalance = CS.dblOpenBalance + SH.dblUnits
		FROM tblGRCustomerStorage CS
		JOIN tblGRStorageHistory SH  ON SH.intCustomerStorageId = CS.intCustomerStorageId AND SH.intTicketId=@IntSourceKey AND SH.strType=@strType

		INSERT INTO [dbo].[tblGRStorageHistory] 
		(
			 [intConcurrencyId]
			,[intCustomerStorageId]
			,[intTicketId]
			,[intInvoiceId]
			,[intInventoryShipmentId]
			,[dblUnits]
			,[dtmHistoryDate]
			,[dblPaidAmount]
			,[strType]
			,[strUserName]
		)
		SELECT 
			 [intConcurrencyId] = 1
			,[intCustomerStorageId] = intCustomerStorageId
			,[intTicketId] = intTicketId
			,[intInvoiceId]=intInvoiceId
			,[intInventoryShipmentId] = intInventoryShipmentId
			,[dblUnits] = dblUnits
			,[dtmHistoryDate] = GetDATE()
			,[dblPaidAmount] = NULL 
			,[strType] = 'Reverse By Scale'
			,[strUserName] = @strUserName
		FROM tblGRStorageHistory WHERE intTicketId=@IntSourceKey AND strType=@strType
	END
	ELSE IF  @strType='Reduced By Invoice'
	BEGIN
		UPDATE CS
		SET CS.dblOpenBalance = CS.dblOpenBalance + SH.dblUnits
		FROM tblGRCustomerStorage CS
		JOIN tblGRStorageHistory SH  ON SH.intCustomerStorageId = CS.intCustomerStorageId AND SH.intInvoiceId=@IntSourceKey AND SH.strType=@strType

		INSERT INTO [dbo].[tblGRStorageHistory] 
		(
			 [intConcurrencyId]
			,[intCustomerStorageId]
			,[intTicketId]
			,[intInvoiceId]
			,[intInventoryShipmentId]
			,[dblUnits]
			,[dtmHistoryDate]
			,[dblPaidAmount]
			,[strType]
			,[strUserName]
		)
		SELECT 
			 [intConcurrencyId] = 1
			,[intCustomerStorageId] = intCustomerStorageId
			,[intTicketId] = intTicketId
			,[intInvoiceId]=intInvoiceId
			,[intInventoryShipmentId] = intInventoryShipmentId
			,[dblUnits] = dblUnits
			,[dtmHistoryDate] = GetDATE()
			,[dblPaidAmount] = NULL 
			,[strType] = 'Reverse By Invoice'
			,[strUserName] = @strUserName
		FROM tblGRStorageHistory WHERE intInvoiceId=@IntSourceKey AND strType=@strType
	END
	 
END TRY
BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH
