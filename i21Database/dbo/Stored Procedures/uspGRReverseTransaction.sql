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

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXml

	SELECT @intStorageHistoryId = intStorageHistoryId,@intEntityUserSecurityId=intEntityUserSecurityId
	FROM OPENXML(@idoc, 'root', 2) WITH (intStorageHistoryId INT,intEntityUserSecurityId INT)

	SELECT @StrUserName=strUserName FROM tblSMUserSecurity Where intEntityUserSecurityId=@intEntityUserSecurityId
	
	SELECT @intCustomerStorageId = intCustomerStorageId 
		,@intTransactionTypeId = intTransactionTypeId
		,@dblUnits = ISNULL(dblUnits, 0)
		,@dblAmount = ISNULL(dblPaidAmount, 0)
	FROM tblGRStorageHistory
	WHERE intStorageHistoryId = @intStorageHistoryId

	IF @intTransactionTypeId = 5
	BEGIN
	
		UPDATE tblGRCustomerStorage
		SET dblOriginalBalance = dblOriginalBalance - @dblUnits
		WHERE intCustomerStorageId = @intCustomerStorageId
		
		DELETE
		FROM tblGRStorageHistory
		WHERE intStorageHistoryId = @intStorageHistoryId
		
		
	END	
	ELSE IF @intTransactionTypeId = 6
	BEGIN
	
		UPDATE tblGRCustomerStorage
		SET dblOpenBalance = dblOpenBalance - @dblUnits
		WHERE intCustomerStorageId = @intCustomerStorageId

		INSERT INTO [dbo].[tblGRStorageHistory] 
		(
			[intConcurrencyId]
			,[intCustomerStorageId]
			,[intTicketId]
			,[intInventoryReceiptId]
			,[intInvoiceId]
			,[intContractDetailId]
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
			,15
			,NULL
			,NULL
		)

		DELETE
		FROM tblGRStorageHistory
		WHERE intStorageHistoryId = @intStorageHistoryId
		
	END
	
	ELSE IF @intTransactionTypeId = 7
	BEGIN
		UPDATE tblGRCustomerStorage
		SET dblInsuranceRate = dblInsuranceRate - @dblAmount
		WHERE intCustomerStorageId = @intCustomerStorageId

		DELETE
		FROM tblGRStorageHistory
		WHERE intStorageHistoryId = @intStorageHistoryId
	END	
	
	ELSE IF @intTransactionTypeId = 8
	BEGIN
		UPDATE tblGRCustomerStorage
		SET dblStorageDue = dblStorageDue - @dblAmount
		WHERE intCustomerStorageId = @intCustomerStorageId

		DELETE
		FROM tblGRStorageHistory
		WHERE intStorageHistoryId = @intStorageHistoryId

	END
		
	ELSE IF @intTransactionTypeId = 9
	BEGIN
		UPDATE tblGRCustomerStorage
		SET dblStoragePaid = dblStoragePaid - @dblAmount
		WHERE intCustomerStorageId = @intCustomerStorageId

		DELETE
		FROM tblGRStorageHistory
		WHERE intStorageHistoryId = @intStorageHistoryId

	END	
	ELSE IF @intTransactionTypeId = 10
	BEGIN
		UPDATE tblGRCustomerStorage
		SET dblFeesDue = dblFeesDue - @dblAmount
		WHERE intCustomerStorageId = @intCustomerStorageId

		DELETE
		FROM tblGRStorageHistory
		WHERE intStorageHistoryId = @intStorageHistoryId

	END	
	ELSE IF @intTransactionTypeId = 11
	BEGIN
		UPDATE tblGRCustomerStorage
		SET dblFeesPaid = dblFeesPaid - @dblAmount
		WHERE intCustomerStorageId = @intCustomerStorageId
		
		DELETE
		FROM tblGRStorageHistory
		WHERE intStorageHistoryId = @intStorageHistoryId

    END		
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH