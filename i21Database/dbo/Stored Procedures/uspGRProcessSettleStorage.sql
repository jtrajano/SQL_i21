CREATE PROCEDURE [dbo].[uspGRProcessSettleStorage]
(
	@strXml NVARCHAR(MAX)
)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @idoc INT
			,@ErrMsg NVARCHAR(MAX)
			
	---Header Variables	
	DECLARE @Entityid INT
	DECLARE @ItemId INT
	DECLARE @TicketNo NVARCHAR(20)
	DECLARE @UserKey INT
	DECLARE @UserName NVARCHAR(100)
	
	--Storage Varibales
	DECLARE @SettleStorageKey INT
	DECLARE @CurrentItemOpenBalance DECIMAL(24, 10)
	DECLARE @intCustomerStorageId INT
	DECLARE @dblStorageUnits DECIMAL(24, 10)
	DECLARE @dblOpenBalance DECIMAL(24, 10)
	DECLARE @intStorageTicketNumber INT
	DECLARE @intCompanyLocationId INT
	DECLARE @intStorageTypeId INT
	DECLARE @intStorageScheduleId INT
	
	--Contract Varibales
	DECLARE @SettleContractKey INT
	DECLARE @intContractDetailId INT
	DECLARE @dblContractUnits DECIMAL(24, 10)
	DECLARE @strContractNumber NVARCHAR(50)
	DECLARE @ContractEntityId INT
	DECLARE @dblAvailableQty DECIMAL(24, 10)
	DECLARE @strContractType NVARCHAR(50)
	DECLARE @dblCashPrice DECIMAL(24, 10)
	
	--Spot Variables.
	DECLARE @dblSpotUnits DECIMAL(24, 10)
	DECLARE @dblSpotPrice DECIMAL(24, 10)
	DECLARE @dblSpotBasis DECIMAL(24, 10)
	DECLARE @dblSpotCashPrice DECIMAL(24, 10)
	DECLARE @InventoryStockUOMKey INT
	DECLARE  @InventoryStockUOM NVARCHAR(50)
	--Updating Contract Varibales
		
     DECLARE @InventoryReceiptKey INT 
	,@strSourceType NVARCHAR(50)
	,@StrOutPutTicket NVARCHAR(50)
	,@InventoryContractDetailId INT
	,@dblQuantityToUpdate	NUMERIC(12,4)		
	,@intExternalId			INT
		

	EXEC sp_xml_preparedocument @idoc OUTPUT,@strXml


	IF OBJECT_ID('tempdb..#SettleStorage') IS NOT NULL
		DROP TABLE #SettleStorage

	CREATE TABLE #SettleStorage 
	(
		 intSettleStorageKey INT IDENTITY(1, 1)
		,intCustomerStorageId INT
		,dblStorageUnits DECIMAL(24, 10)
		,dblOpenBalance DECIMAL(24, 10)
		,intStorageTicketNumber INT
		,intCompanyLocationId INT
		,intStorageTypeId INT
		,intStorageScheduleId INT
	)

	CREATE TABLE #SettleStorageCopy 
	(
		intSettleStorageKey INT
		,intCustomerStorageId INT
		,dblStorageUnits DECIMAL(24, 10)
		,dblOpenBalance DECIMAL(24, 10)
		,intStorageTicketNumber INT
		,intCompanyLocationId INT
		,intStorageTypeId INT
		,intStorageScheduleId INT
	)

	DECLARE @SettleContract AS TABLE 
	(
		intSettleContractKey INT IDENTITY(1, 1)
		,intContractDetailId INT
		,dblContractUnits DECIMAL(24, 10)
		,strContractNumber NVARCHAR(50)
		,ContractEntityId INT
		,dblAvailableQty DECIMAL(24, 10)
		,strContractType NVARCHAR(50)
		,dblCashPrice DECIMAL(24, 10)
	)
	
	DECLARE @InventoryReceipt AS TABLE 
	(
		 intInventoryReceiptKey INT IDENTITY(1, 1)
		,strSourceType NVARCHAR(50)
		,StrOutPutTicket NVARCHAR(50)
		,intContractDetailId INT
		,dblIssuedUnits DECIMAL(24, 10)
		,strContractNumber NVARCHAR(50)
		,EntityId INT
		,dblCashPrice DECIMAL(24, 10)
		,intCustomerStorageId INT
		,intStorageTicketNumber INT
		,intLocationId INT
	)

	DECLARE @InventoryReceiptByGroup AS TABLE 
	(
		 intInventoryReceiptByGroupKey INT IDENTITY(1, 1)
		,strSourceType NVARCHAR(50)
		,StrOutPutTicket NVARCHAR(50)
		,intContractDetailId INT
		,dblIssuedUnits DECIMAL(24, 10)
		,strContractNumber NVARCHAR(50)
		,EntityId INT
		,dblCashPrice DECIMAL(24, 10)		
		,intLocationId INT
	)
	
	SELECT @UserKey = intCreatedUserId
		,@Entityid = intEntityId
		,@ItemId = intItemId
		,@TicketNo = strStorageTicket
	FROM OPENXML(@idoc, 'root', 2) WITH 
	(
			intCreatedUserId INT
			,intEntityId INT
			,intItemId INT
			,strStorageTicket NVARCHAR(50)
	)

	SELECT @InventoryStockUOMKey = U.intUnitMeasureId
	FROM tblICCommodity C
	JOIN tblICItem b ON b.intCommodityId = C.intCommodityId
	JOIN tblICCommodityUnitMeasure U ON U.intCommodityId = C.intCommodityId
	WHERE U.ysnStockUnit = 1 AND b.intItemId = @ItemId
	
	SELECT @InventoryStockUOM=strUnitMeasure FROM tblICUnitMeasure Where intUnitMeasureId=@InventoryStockUOMKey

	SELECT @UserName = strUserName
	FROM tblSMUserSecurity
	WHERE intUserSecurityID = @UserKey

	INSERT INTO #SettleStorage
		(
			 intCustomerStorageId
			,dblStorageUnits
			,dblOpenBalance
			,intStorageTicketNumber
			,intCompanyLocationId
			,intStorageTypeId
			,intStorageScheduleId
		)
	SELECT intCustomerStorageId
		,dblUnits
		,dblOpenBalance
		,intStorageTicketNumber
		,intCompanyLocationId
		,intStorageTypeId
		,intStorageScheduleId
	FROM OPENXML(@idoc, 'root/SettleStorage', 2) WITH 
	(
			intCustomerStorageId INT
			,dblUnits DECIMAL(24, 10)
			,dblOpenBalance DECIMAL(24, 10)
			,intStorageTicketNumber INT
			,intCompanyLocationId INT
			,intStorageTypeId INT
			,intStorageScheduleId INT
	)
	
	INSERT INTO @SettleContract 
	(
		intContractDetailId
		,dblContractUnits
		,strContractNumber
		,ContractEntityId
		,dblAvailableQty
		,strContractType
		,dblCashPrice
	)
	SELECT intContractDetailId
		,dblUnits
		,strContractNumber
		,intEntityId
		,dblAvailableQty
		,strContractType
		,dblCashPrice
	FROM OPENXML(@idoc, 'root/SettleContract', 2) WITH 
	(
			 intContractDetailId INT
			,dblUnits DECIMAL(24, 10)
			,strContractNumber NVARCHAR(50)
			,intEntityId INT
			,dblAvailableQty DECIMAL(24, 10)
			,strContractType NVARCHAR(50)
			,dblCashPrice DECIMAL(24, 10)
	)

	SELECT @dblSpotUnits = dblSpotUnits
		,@dblSpotPrice = dblSpotPrice
		,@dblSpotBasis = dblSpotBasis
		,@dblSpotCashPrice = dblSpotCashPrice
	FROM OPENXML(@idoc, 'root/SettleSpot', 2) WITH 
	(
			dblSpotUnits DECIMAL(24, 10)
			,dblSpotPrice DECIMAL(24, 10)
			,dblSpotBasis DECIMAL(24, 10)
			,dblSpotCashPrice DECIMAL(24, 10)
	)	
	
	SELECT @SettleStorageKey = MIN(intSettleStorageKey)	FROM #SettleStorage	WHERE dblStorageUnits > 0

	SET @intCustomerStorageId = NULL
	SET @dblStorageUnits = NULL
	SET @dblOpenBalance = NULL
	SET @intStorageTicketNumber = NULL
	SET @intCompanyLocationId = NULL
	SET @intStorageTypeId = NULL
	SET @intStorageScheduleId = NULL
	SET @CurrentItemOpenBalance = NULL

	WHILE @SettleStorageKey > 0
	BEGIN
		SELECT @intCustomerStorageId = intCustomerStorageId
			,@dblStorageUnits = dblStorageUnits
			,@dblOpenBalance = dblOpenBalance
			,@intStorageTicketNumber = intStorageTicketNumber
			,@intCompanyLocationId = intCompanyLocationId
			,@intStorageTypeId = intStorageTypeId
			,@intStorageScheduleId = intStorageScheduleId		
		FROM #SettleStorage
		WHERE intSettleStorageKey = @SettleStorageKey

		SELECT @CurrentItemOpenBalance = dblOpenBalance
		FROM tblGRCustomerStorage
		WHERE intCustomerStorageId = @intCustomerStorageId

		IF @CurrentItemOpenBalance IS NULL
		BEGIN
			SET @ErrMsg = 'The ticket ' + LTRIM(@intStorageTicketNumber) + ' has been deleted by another user.  Settle Process cannot proceed.'
			RAISERROR (@ErrMsg,16,1)
		END

		IF @CurrentItemOpenBalance <> @dblOpenBalance
		BEGIN
			SET @ErrMsg = 'The Open balance of ticket ' + LTRIM(@intStorageTicketNumber) + ' has been modified by another user.  Settle Process cannot proceed.'
			RAISERROR (@ErrMsg,16,1)
		END

		IF EXISTS (SELECT 1 FROM @SettleContract WHERE dblContractUnits > 0 )
		BEGIN
			SELECT @SettleContractKey = MIN(intSettleContractKey) FROM @SettleContract WHERE dblContractUnits > 0

			SET @intContractDetailId = NULL
			SET @dblContractUnits = NULL
			SET @strContractNumber = NULL
			SET @ContractEntityId = NULL
			SET @dblAvailableQty = NULL
			SET @strContractType = NULL
			SET @dblCashPrice = NULL

			WHILE @SettleContractKey > 0
			BEGIN
				SELECT @intContractDetailId = intContractDetailId
					,@dblContractUnits = dblContractUnits
					,@strContractNumber = strContractNumber
					,@ContractEntityId = ContractEntityId
					,@dblAvailableQty = dblAvailableQty
					,@strContractType = strContractType
					,@dblCashPrice = dblCashPrice
				FROM @SettleContract
				WHERE intSettleContractKey = @SettleContractKey

				IF @dblStorageUnits <= @dblContractUnits
				BEGIN
					INSERT INTO @InventoryReceipt 
					(
						 strSourceType
						,StrOutPutTicket
						,intContractDetailId
						,dblIssuedUnits
						,strContractNumber
						,EntityId
						,dblCashPrice
						,intCustomerStorageId
						,intStorageTicketNumber
						,intLocationId
					 )
					SELECT 
					    'Purchase Contract'
						,@TicketNo
						,@intContractDetailId
						,@dblStorageUnits
						,@strContractNumber
						,@ContractEntityId
						,@dblCashPrice
						,@intCustomerStorageId
						,@intStorageTicketNumber
						,@intCompanyLocationId

					UPDATE @SettleContract SET dblContractUnits = dblContractUnits - @dblStorageUnits WHERE intSettleContractKey = @SettleContractKey
										
					UPDATE #SettleStorage SET dblStorageUnits = 0 WHERE intSettleStorageKey = @SettleStorageKey

					BREAK;
				END
				ELSE
				BEGIN

					INSERT INTO @InventoryReceipt 
					(
						 strSourceType
						,StrOutPutTicket
						,intContractDetailId
						,dblIssuedUnits
						,strContractNumber
						,EntityId
						,dblCashPrice
						,intCustomerStorageId
						,intStorageTicketNumber
						,intLocationId
					)
					SELECT 'Purchase Contract'
						,@TicketNo
						,@intContractDetailId
						,@dblContractUnits
						,@strContractNumber
						,@ContractEntityId
						,@dblCashPrice
						,@intCustomerStorageId
						,@intStorageTicketNumber
						,@intCompanyLocationId

					UPDATE @SettleContract SET dblContractUnits = dblContractUnits - @dblContractUnits WHERE intSettleContractKey = @SettleContractKey

					UPDATE #SettleStorage SET dblStorageUnits = 0 WHERE intSettleStorageKey = @SettleStorageKey

					DELETE FROM #SettleStorageCopy

					INSERT INTO #SettleStorageCopy 
					(
						 intSettleStorageKey
						,intCustomerStorageId
						,dblStorageUnits
						,dblOpenBalance
						,intStorageTicketNumber
						,intCompanyLocationId
						,intStorageTypeId
						,intStorageScheduleId
					)
					SELECT 
						 intSettleStorageKey
						,intCustomerStorageId
						,dblStorageUnits
						,dblOpenBalance
						,intStorageTicketNumber
						,intCompanyLocationId
						,intStorageTypeId
						,intStorageScheduleId
					FROM #SettleStorage WHERE intSettleStorageKey > @SettleStorageKey

					DELETE FROM #SettleStorage WHERE intSettleStorageKey > @SettleStorageKey

					SET IDENTITY_INSERT [dbo].[#SettleStorage] ON

					INSERT INTO [#SettleStorage] (
						intSettleStorageKey
						,intCustomerStorageId
						,dblStorageUnits
						,dblOpenBalance
						,intStorageTicketNumber
						,intCompanyLocationId
						,intStorageTypeId
						,intStorageScheduleId
						)
					SELECT @SettleStorageKey + 1
						,@intCustomerStorageId
						,(@dblStorageUnits - @dblContractUnits)
						,@dblOpenBalance
						,@intStorageTicketNumber
						,@intCompanyLocationId
						,@intStorageTypeId
						,@intStorageScheduleId

					SET IDENTITY_INSERT [dbo].[#SettleStorage] OFF

					INSERT INTO [#SettleStorage] 
					(
						 intCustomerStorageId
						,dblStorageUnits
						,dblOpenBalance
						,intStorageTicketNumber
						,intCompanyLocationId
						,intStorageTypeId
						,intStorageScheduleId
					)
					SELECT intCustomerStorageId
						,dblStorageUnits
						,dblOpenBalance
						,intStorageTicketNumber
						,intCompanyLocationId
						,intStorageTypeId
						,intStorageScheduleId
					FROM #SettleStorageCopy

					DELETE FROM #SettleStorageCopy
					
					BREAK;
				END

				SELECT @SettleContractKey = MIN(intSettleContractKey)FROM @SettleContract WHERE intSettleContractKey > @SettleContractKey AND dblContractUnits > 0
			END
			
			SELECT @SettleStorageKey = MIN(intSettleStorageKey) FROM [#SettleStorage] WHERE intSettleStorageKey > @SettleStorageKey AND dblStorageUnits > 0
		END
		ELSE
		
			BREAK;
	END

	IF EXISTS (SELECT 1 FROM [#SettleStorage] WHERE dblStorageUnits > 0)
	BEGIN
		INSERT INTO @InventoryReceipt 
		(
			 strSourceType
			,StrOutPutTicket
			,dblIssuedUnits
			,EntityId
			,dblCashPrice
			,intCustomerStorageId
			,intStorageTicketNumber
			,intLocationId
		)
		SELECT 'Direct'
			,@TicketNo
			,dblStorageUnits
			,@Entityid
			,@dblSpotCashPrice
			,intCustomerStorageId
			,intStorageTicketNumber
			,intCompanyLocationId
		FROM [#SettleStorage] WHERE dblStorageUnits > 0

		DELETE FROM [#SettleStorage]
	END

	--SELECT * FROM @InventoryReceipt
	
	---Updating Contract Schedule Quantity
	SELECT @InventoryReceiptKey = MIN(intInventoryReceiptKey)	FROM @InventoryReceipt Where strSourceType='Purchase Contract'
	
	SET @strSourceType =NULL
	SET @StrOutPutTicket =NULL
	SET @InventoryContractDetailId =NULL
	SET @dblQuantityToUpdate=NULL
	SET @intExternalId	=NULL
	
	WHILE @InventoryReceiptKey > 0
	BEGIN
	 SELECT 
	  @strSourceType=strSourceType
	 ,@InventoryContractDetailId=intContractDetailId
	 ,@dblQuantityToUpdate=dblIssuedUnits
	 ,@intExternalId=intCustomerStorageId
	  FROM @InventoryReceipt Where intInventoryReceiptKey=@InventoryReceiptKey
	  	
	   EXEC uspCTUpdateScheduleQuantity 
			@intContractDetailId=@InventoryContractDetailId
			,@dblQuantityToUpdate=@dblQuantityToUpdate
			,@intUserId=@UserKey
			,@intExternalId=@intExternalId
			,@strScreenName='Settle Storage'
						
	        SELECT @InventoryReceiptKey = MIN(intInventoryReceiptKey)	FROM @InventoryReceipt Where strSourceType='Purchase Contract' AND intInventoryReceiptKey >@InventoryReceiptKey
	
	END
	
	-------****************--------------------
	--Temporary
	
	 DECLARE
		 @ReceiptContractDetailId INT
		,@dblIssuedUnits DECIMAL(24, 10)		
		,@ReceiptEntityId INT
		,@ReceiptCashPrice DECIMAL(24, 10)
		,@ReceiptCustomerStorageId INT		
		,@ReceiptStorageTicketNumber INT
		,@intLocationId INT
		,@CurrencyID INT
		,@InventoryReceiptId INT
		,@strReceiptNumber Nvarchar(50)
		
	DECLARE @ItemsForItemReceipt AS ItemCostingTableType
	
	SELECT @InventoryReceiptKey = MIN(intInventoryReceiptKey)	FROM @InventoryReceipt
	
	SET @strSourceType =NULL
	SET @ReceiptContractDetailId =NULL
	SET @dblIssuedUnits =NULL
	SET @ReceiptEntityId =NULL
	SET @ReceiptCashPrice	=NULL
	SET @ReceiptCustomerStorageId	=NULL
	SET @ReceiptStorageTicketNumber	=NULL
	SET @intLocationId	=NULL
	SET @CurrencyID	=NULL
	SET @InventoryReceiptId=NULL
	SET @strReceiptNumber=NULL
		
	WHILE @InventoryReceiptKey > 0
	BEGIN
	 
	 SELECT 
		@strSourceType=strSourceType	 
	  ,@ReceiptContractDetailId=intContractDetailId
	 ,@dblIssuedUnits=dblIssuedUnits
	 ,@ReceiptEntityId=EntityId
	 ,@ReceiptCashPrice=dblCashPrice
	 ,@ReceiptCustomerStorageId=intCustomerStorageId
	 ,@ReceiptStorageTicketNumber=intStorageTicketNumber
	 ,@intLocationId=intLocationId	  
	 FROM @InventoryReceipt Where intInventoryReceiptKey=@InventoryReceiptKey
	 
	 SELECT @CurrencyID=intCurrencyId FROM tblGRCustomerStorage Where intCustomerStorageId=@ReceiptCustomerStorageId
		
	  DELETE FROM @ItemsForItemReceipt
	  	
	  INSERT INTO @ItemsForItemReceipt (
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
		,intLotId
		,intSubLocationId
		,intStorageLocationId
		,ysnIsStorage
		)		
		SELECT 
		 @ItemId
		,@intLocationId
		,@InventoryStockUOMKey
		,dbo.fnRemoveTimeOnDate(GETDATE()) 
		,@dblIssuedUnits
		,@dblIssuedUnits
		,@ReceiptCashPrice
		,0
		,@CurrencyID
		,1
		,@ReceiptCustomerStorageId
		,@ReceiptContractDetailId
		,@ReceiptStorageTicketNumber
		,3
		,NUll
		,0
		,@intLocationId
		,0
				
		EXEC dbo.uspICValidateProcessToItemReceipt @ItemsForItemReceipt;
		
		EXEC uspGRCreateInvReceiptBySettle @UserKey,@ItemsForItemReceipt,@ReceiptEntityId,@InventoryStockUOMKey,@strSourceType,@InventoryReceiptId OUTPUT
		
		---Updating On Store in Inventory
		
		------
		
		SELECT @strReceiptNumber=strReceiptNumber FROM  tblICInventoryReceipt Where intInventoryReceiptId=@InventoryReceiptId
		
		Update tblGRCustomerStorage SET dblOpenBalance=dblOpenBalance-@dblIssuedUnits Where intCustomerStorageId=@ReceiptCustomerStorageId

		 DECLARE @StorageTicketHistoryMessage Nvarchar(Max)

		 SET @strContractNumber=''
		 SET @StorageTicketHistoryMessage=''

		 IF @ReceiptContractDetailId >0
		 BEGIN
			 SELECT @strContractNumber=strContractNumber from vyuCTContractDetailView Where intContractDetailId=@ReceiptContractDetailId
			 SET @StorageTicketHistoryMessage='Settled '+Convert(Nvarchar,CAST(@dblIssuedUnits AS FLOAT))+' '+@InventoryStockUOM+' For '+@strReceiptNumber+' On Contract '+@strContractNumber
		 END
		 ELSE
		 BEGIN
			SET @StorageTicketHistoryMessage='Settled '+Convert(Nvarchar,CAST(@dblIssuedUnits AS FLOAT))+' '+@InventoryStockUOM+' For '+@strReceiptNumber+' On Spot Sale'
		 END
		
		INSERT INTO [dbo].[tblGRStorageHistory] (
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
					)
				VALUES (
					1
					,@ReceiptCustomerStorageId
					,NULL
					,NULL
					,NULL
					,NULL
					,-@dblIssuedUnits
					,GETDATE()
					,NULL
					,@StorageTicketHistoryMessage
					,NULL
					,'Reduced By Settle Storage'
					,@UserName
					)
						
								
	    SELECT @InventoryReceiptKey = MIN(intInventoryReceiptKey)	FROM @InventoryReceipt  Where intInventoryReceiptKey >@InventoryReceiptKey
	
	END
		
	EXEC sp_xml_removedocument @idoc
END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()
	IF @idoc <> 0 EXEC sp_xml_removedocument @idoc
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
	
END CATCH