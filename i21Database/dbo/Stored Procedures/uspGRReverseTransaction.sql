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
	DECLARE @intBillId AS INT	
	DECLARE @ItemId INT
	DECLARE @ContractId INT
	DECLARE @NegativeUnits  DECIMAL(24, 10)

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXml

	SELECT @intStorageHistoryId = intStorageHistoryId,@intEntityUserSecurityId=intEntityUserSecurityId
	FROM OPENXML(@idoc, 'root', 2) WITH (intStorageHistoryId INT,intEntityUserSecurityId INT)

	SELECT @StrUserName=strUserName FROM tblSMUserSecurity Where [intEntityId]=@intEntityUserSecurityId
	
	SELECT @intCustomerStorageId = intCustomerStorageId 
		,@intTransactionTypeId = intTransactionTypeId
		,@dblUnits = ISNULL(dblUnits, 0)
		,@NegativeUnits=- ISNULL(dblUnits, 0)
		,@dblAmount = ISNULL(dblPaidAmount, 0)
		,@intBillId=intBillId
		,@ContractId=intInventoryReceiptId
	FROM tblGRStorageHistory
	WHERE intStorageHistoryId = @intStorageHistoryId

	SELECT @ItemId = intItemId FROM tblGRCustomerStorage WHERE intCustomerStorageId = @intCustomerStorageId
	
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
	ELSE IF @intTransactionTypeId =4 --Settle Storage
	BEGIN
		---1. UnPost Voucher 
		IF EXISTS(SELECT 1 FROM tblAPBill WHERE ISNULL(ysnPosted,0)=1)
		BEGIN
			EXEC uspAPPostBill 
			 @post=0
			,@recap=0
			,@isBatch=0
			,@param=@intBillId			
			,@userId=@intEntityUserSecurityId
		END	
		---2. InCrease DP Contract Qty and Increase Grain Ticket Balance
	   EXEC uspGRReverseSettleStorage
			 @ItemId=@ItemId
			,@SourceNumberId=@intCustomerStorageId
			,@Quantity=@dblUnits
			,@UserKey=@intEntityUserSecurityId

		---3. Increase Purchase Contract Qty
		IF ISNULL(@ContractId,0) >0
		BEGIN		
			EXEC uspCTUpdateSequenceBalance
				@intContractDetailId	=	@ContractId,
				@dblQuantityToUpdate	=	@NegativeUnits,
				@intUserId				=	@intEntityUserSecurityId,
				@intExternalId			=	@intCustomerStorageId,
				@strScreenName			=	'Settle Storage' 
		END					
		-- 4. Delete the Voucher(From User Interface deleting Voucher Should not be allowed)
		--DELETE FROM tblAPBill WHERE intBillId=@intBillId		
		DELETE FROM tblGRStorageHistory WHERE intStorageHistoryId=@intStorageHistoryId
	END
			
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH