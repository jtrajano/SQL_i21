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
							 WHEN @strSourceType = 'SalesOrder' THEN 'Reduced By Sales Order'
							 WHEN @strSourceType = 'Scale'      THEN 'Reduced By Scale'
					 END

    IF @strType='Reduced By Sales Order'
	BEGIN
		UPDATE CS
		SET CS.dblOpenBalance = CS.dblOpenBalance + SH.dblUnits
		FROM tblGRCustomerStorage CS
		JOIN tblGRStorageHistory SH  ON SH.intCustomerStorageId = CS.intCustomerStorageId AND SH.intSalesOrderId=@IntSourceKey AND SH.strType=@strType
		
		INSERT INTO [dbo].[tblGRStorageHistory] 
		(
			 [intConcurrencyId]
			,[intCustomerStorageId]
			,[intTicketId]
			,[intSalesOrderId]
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
			,[intSalesOrderId] = intSalesOrderId
			,[dblUnits] = dblUnits
			,[dtmHistoryDate] = GetDATE()
			,[dblPaidAmount] = NULL 
			,[strType] = 'Reverse By Sales Order'
			,[strUserName] = @strUserName
		FROM tblGRStorageHistory WHERE intSalesOrderId=@IntSourceKey AND strType=@strType

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
			,[intSalesOrderId]
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
			,[intSalesOrderId] = intSalesOrderId
			,[dblUnits] = dblUnits
			,[dtmHistoryDate] = GetDATE()
			,[dblPaidAmount] = NULL 
			,[strType] = 'Reverse By Scale'
			,[strUserName] = @strUserName
		FROM tblGRStorageHistory WHERE intTicketId=@IntSourceKey AND strType=@strType
	END
	 
END TRY
BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH
