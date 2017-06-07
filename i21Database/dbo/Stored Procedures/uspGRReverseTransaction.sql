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
	
	DECLARE @STARTING_NUMBER_BATCH AS INT = 3
		   ,@strBatchId AS NVARCHAR(20)
	DECLARE @ItemsToStorage AS ItemCostingTableType
	DECLARE @ItemsToPost  AS ItemCostingTableType
	DECLARE @TicketNo NVARCHAR(50)
	DECLARE @intCurrencyId INT	
	DECLARE @LocationId INT
	DECLARE @intItemLocationId INT
	DECLARE @intUnitMeasureId INT
	DECLARE @intSourceItemUOMId INT
	DECLARE @dblUOMQty DECIMAL(24, 10)
	DECLARE @intCompanyLocationSubLocationId INT
	DECLARE @intStorageLocationId INT
	DECLARE @ysnDPOwnedType BIT

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXml

	SELECT @intStorageHistoryId = intStorageHistoryId,@intEntityUserSecurityId=intEntityUserSecurityId
	FROM OPENXML(@idoc, 'root', 2) WITH (intStorageHistoryId INT,intEntityUserSecurityId INT)

	SELECT @StrUserName=strUserName FROM tblSMUserSecurity Where [intEntityId]=@intEntityUserSecurityId
	
	SELECT @intCustomerStorageId = intCustomerStorageId 
		,@intTransactionTypeId = intTransactionTypeId
		,@dblUnits = ISNULL(dblUnits, 0)
		,@NegativeUnits= - ISNULL(dblUnits, 0)
		,@dblAmount = ISNULL(dblPaidAmount, 0)
		,@intBillId=intBillId
		,@ContractId=intInventoryReceiptId
		,@TicketNo=strSettleTicket
	FROM tblGRStorageHistory
	WHERE intStorageHistoryId = @intStorageHistoryId

	SELECT
	 @ItemId = CS.intItemId
	,@intCurrencyId=CS.intCurrencyId 
	,@LocationId=CS.intCompanyLocationId
	,@intCompanyLocationSubLocationId=CS.intCompanyLocationSubLocationId
	,@intStorageLocationId=CS.intStorageLocationId
	,@ysnDPOwnedType=St.ysnDPOwnedType
	FROM tblGRCustomerStorage CS
	JOIN tblGRStorageType St ON St.intStorageScheduleTypeId=CS.intStorageTypeId
	WHERE intCustomerStorageId = @intCustomerStorageId
	
	
	SELECT	@intUnitMeasureId = a.intUnitMeasureId
	FROM	tblICCommodityUnitMeasure a 
	JOIN	tblICItem b ON b.intCommodityId = a.intCommodityId
	WHERE	b.intItemId = @ItemId AND a.ysnStockUnit = 1

	SELECT	@intSourceItemUOMId = intItemUOMId
			,@dblUOMQty=UOM.dblUnitQty
	FROM	tblICItemUOM UOM
	WHERE	intItemId = @ItemId 
			AND intUnitMeasureId = @intUnitMeasureId

	SELECT	@intItemLocationId = intItemLocationId 
		FROM	tblICItemLocation 
		WHERE	intItemId = @ItemId 
				AND intLocationId=@LocationId

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

		EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH, @strBatchId OUTPUT
		
		INSERT INTO @ItemsToStorage
		(
			  intItemId  
			 ,intItemLocationId	
			 ,intItemUOMId  
			 ,dtmDate  
			 ,dblQty  
			 ,dblUOMQty  
			 ,dblCost  
			 ,dblSalesPrice  
			 ,intCurrencyId  
			 ,dblExchangeRate  
			 ,intTransactionId  
			 ,intTransactionDetailId 
			 ,strTransactionId  
			 ,intTransactionTypeId
			 ,intSubLocationId
			 ,intStorageLocationId
			 ,ysnIsStorage
		)
		SELECT  
			 intItemId = @ItemId
			,intItemLocationId = @intItemLocationId	
			,intItemUOMId = @intSourceItemUOMId
			,dtmDate = GETDATE() 
			,dblQty = @dblUnits
			,dblUOMQty = @dblUOMQty
			,dblCost = CASE WHEN @ysnDPOwnedType = 0 THEN @dblAmount ELSE 0 END
			,dblSalesPrice = 0.00
			,intCurrencyId = @intCurrencyId
			,dblExchangeRate = 1
			,intTransactionId = 1
			,intTransactionDetailId = @intCustomerStorageId
			,strTransactionId =  @TicketNo
			,intTransactionTypeId = 4
			,intSubLocationId = @intCompanyLocationSubLocationId
			,intStorageLocationId =@intStorageLocationId
			,ysnIsStorage = 1
			
			EXEC uspICPostStorage 
				  @ItemsToStorage
				, @strBatchId
				, @intEntityUserSecurityId

         
			INSERT INTO @ItemsToPost
			(
				  intItemId  
				 ,intItemLocationId	
				 ,intItemUOMId  
				 ,dtmDate  
				 ,dblQty  
				 ,dblUOMQty  
				 ,dblCost  
				 ,dblSalesPrice  
				 ,intCurrencyId  
				 ,dblExchangeRate  
				 ,intTransactionId  
				 ,intTransactionDetailId 
				 ,strTransactionId  
				 ,intTransactionTypeId
				 ,intSubLocationId
				 ,intStorageLocationId
				 ,ysnIsStorage
			)
			SELECT  
				 intItemId = @ItemId
				,intItemLocationId = @intItemLocationId	
				,intItemUOMId = @intSourceItemUOMId
				,dtmDate = GETDATE() 
				,dblQty = @NegativeUnits
				,dblUOMQty = @dblUOMQty
				,dblCost = CASE WHEN @ysnDPOwnedType = 0 THEN @dblAmount ELSE 0 END
				,dblSalesPrice = 0.00
				,intCurrencyId = @intCurrencyId
				,dblExchangeRate = 1
				,intTransactionId = @intCustomerStorageId
				,intTransactionDetailId = @intCustomerStorageId
				,strTransactionId = @TicketNo
				,intTransactionTypeId = 44
				,intSubLocationId = @intCompanyLocationSubLocationId
				,intStorageLocationId =@intStorageLocationId
				,ysnIsStorage = 0

			 EXEC uspICPostCosting 
				  @ItemsToPost
				, @strBatchId
				,'Cost of Goods'
				, @intEntityUserSecurityId 
		

		-- 4. Delete the Voucher(From User Interface deleting Voucher Should not be allowed)		
		EXEC uspGRDeleteStorageHistory 'Voucher',@intBillId
		EXEC uspAPDeleteVoucher @intBillId,@intEntityUserSecurityId		
		
	END
			
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH