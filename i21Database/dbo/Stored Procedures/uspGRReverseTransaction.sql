CREATE PROCEDURE [dbo].[uspGRReverseTransaction]
(
	@strXml NVARCHAR(MAX)
)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @idoc INT
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intStorageHistoryId INT
	DECLARE @intEntityUserSecurityId INT
	DECLARE @StrUserName Nvarchar(50)
	DECLARE @intCustomerStorageId INT
	DECLARE @intTransactionTypeId INT
	DECLARE @dblUnits DECIMAL(24, 10)
	DECLARE @dblAmount DECIMAL(24, 10)
	DECLARE @dblOpenBalance DECIMAL(24, 10)

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXml

	SELECT @intStorageHistoryId = intStorageHistoryId,@intEntityUserSecurityId=intEntityUserSecurityId
	FROM OPENXML(@idoc, 'root', 2) WITH (intStorageHistoryId INT,intEntityUserSecurityId INT)

	SELECT @StrUserName=strUserName FROM tblSMUserSecurity Where [intEntityId]=@intEntityUserSecurityId
	
	SELECT @intCustomerStorageId = intCustomerStorageId 
		,@intTransactionTypeId = intTransactionTypeId
		,@dblUnits = ISNULL(dblUnits, 0)
		,@dblAmount = ISNULL(dblPaidAmount, 0)
	FROM tblGRStorageHistory
	WHERE intStorageHistoryId = @intStorageHistoryId
	
	IF @intTransactionTypeId =2
	BEGIN

		IF EXISTS(SELECT 1 FROM tblGRCustomerStorage WHERE intCustomerStorageId = @intCustomerStorageId AND (dblOpenBalance - @dblUnits)<0)
		BEGIN
			 SET @ErrMsg='This transaction cannot reversed because open balance will be negative.'
			 RAISERROR(@ErrMsg,16,1)		 
		END
		
		SELECT @dblOpenBalance=dblOpenBalance FROM tblGRCustomerStorage Where intCustomerStorageId=@intCustomerStorageId
		
		UPDATE tblGRCustomerStorage
		SET dblOpenBalance = dblOpenBalance - @dblUnits
		WHERE intCustomerStorageId = @intCustomerStorageId
		
		EXEC [uspGRUpdateOnStoreInventory] @intCustomerStorageId,@dblOpenBalance

		INSERT INTO [dbo].[tblGRStorageHistory] 
		(
			 [intConcurrencyId]
			,[intCustomerStorageId]
			,[intTicketId]
			,[intInventoryReceiptId]
			,[intInvoiceId]
			,[intContractHeaderId]
			,[dblUnits]
			,[dtmHistoryDate]
			,[dblPaidAmount]
			,[strPaidDescription]
			,[dblCurrencyRate]
			,[strType]
			,[strUserName]
			,[intTransactionTypeId]
			,[intEntityId]
			,[intCompanyLocationId]
		)
		VALUES 
		(
			 1
			,@intCustomerStorageId
			,NULL
			,NULL
			,NULL
			,NULL
			,- @dblUnits
			,GETDATE()
			,NULL
			,NULL
			,NULL
			,'Reverse Adjustment'
			,@StrUserName
			,2
			,NULL
			,NULL
		)

	END
			
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH