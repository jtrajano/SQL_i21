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
	DECLARE @strStorageTicketNumber NVARCHAR(50)
	DECLARE @intCompanyLocationId INT
	DECLARE @intStorageTypeId INT
	DECLARE @intStorageScheduleId INT
	
	--Contract Varibales
	DECLARE @SettleContractKey INT
	DECLARE @intContractDetailId INT
	DECLARE @intContractHeaderId INT
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
	DECLARE @InventoryStockUOM NVARCHAR(50)

	--Storage Charge Variables
	DECLARE @strStorageAdjustment NVARCHAR(50)
	DECLARE @dtmCalculateStorageThrough DateTime
	DECLARE @dblAdjustPerUnit DECIMAL(24, 10)
	DECLARE @dblStorageDue DECIMAL(24, 10)
	DECLARE @intExternalId			INT

	EXEC sp_xml_preparedocument @idoc OUTPUT,@strXml


	IF OBJECT_ID('tempdb..#SettleStorage') IS NOT NULL
		DROP TABLE #SettleStorage

	CREATE TABLE #SettleStorage 
	(
		 intSettleStorageKey INT IDENTITY(1, 1)
		,intCustomerStorageId INT
		,dblStorageUnits DECIMAL(24, 10)
		,dblOpenBalance DECIMAL(24, 10)
		,strStorageTicketNumber NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
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
		,strStorageTicketNumber NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
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
	
	
	SELECT @UserKey = intCreatedUserId
		,@Entityid = intEntityId
		,@ItemId = intItemId
		,@TicketNo = strStorageTicket
		,@strStorageAdjustment=strStorageAdjustment
		,@dtmCalculateStorageThrough=dtmCalculateStorageThrough
		,@dblAdjustPerUnit=dblAdjustPerUnit
		,@dblStorageDue=dblStorageDue
	FROM OPENXML(@idoc, 'root', 2) WITH 
	(
			intCreatedUserId INT
			,intEntityId INT
			,intItemId INT
			,strStorageTicket NVARCHAR(50)
			,strStorageAdjustment NVARCHAR(50)
			,dtmCalculateStorageThrough DATETIME
			,dblAdjustPerUnit DECIMAL(24, 10)
			,dblStorageDue DECIMAL(24, 10)
	)

	SELECT @UserName = strUserName
	FROM tblSMUserSecurity
	WHERE intEntityUserSecurityId = @UserKey --Another Hiccup

	INSERT INTO #SettleStorage
		(
			 intCustomerStorageId
			,dblStorageUnits
			,dblOpenBalance
			,strStorageTicketNumber
			,intCompanyLocationId
			,intStorageTypeId
			,intStorageScheduleId
		)
	SELECT intCustomerStorageId
		,dblUnits
		,dblOpenBalance
		,strStorageTicketNumber
		,intCompanyLocationId
		,intStorageTypeId
		,intStorageScheduleId
	FROM OPENXML(@idoc, 'root/SettleStorage', 2) WITH 
	(
			intCustomerStorageId INT
			,dblUnits DECIMAL(24, 10)
			,dblOpenBalance DECIMAL(24, 10)
			,strStorageTicketNumber Nvarchar(40)
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
	SET @strStorageTicketNumber = NULL
	SET @intCompanyLocationId = NULL
	SET @intStorageTypeId = NULL
	SET @intStorageScheduleId = NULL
	SET @CurrentItemOpenBalance = NULL
	
		--SELECT @CurrentItemOpenBalance = dblOpenBalance
		--FROM tblGRCustomerStorage
		--WHERE intCustomerStorageId = @intCustomerStorageId
		
		--SELECT @intCustomerStorageId
	
		--IF @CurrentItemOpenBalance IS NULL
		--BEGIN
		--	SET @ErrMsg = 'The ticket ' + LTRIM(@strStorageTicketNumber) + ' has been deleted by another user.  Settle Process cannot proceed.'
		--	RAISERROR (@ErrMsg,16,1)
		--END
		
		--IF @CurrentItemOpenBalance <> @dblOpenBalance
		--BEGIN
		--	SET @ErrMsg = 'The Open balance of ticket ' + LTRIM(@strStorageTicketNumber) + ' has been modified by another user.  Settle Process cannot proceed.'
		--	RAISERROR (@ErrMsg,16,1)
		--END
		
		
	WHILE @SettleStorageKey > 0
	BEGIN
		SELECT @intCustomerStorageId = intCustomerStorageId
			,@dblStorageUnits = dblStorageUnits
			,@dblOpenBalance = dblOpenBalance
			,@strStorageTicketNumber = strStorageTicketNumber
			,@intCompanyLocationId = intCompanyLocationId
			,@intStorageTypeId = intStorageTypeId
			,@intStorageScheduleId = intStorageScheduleId		
		FROM #SettleStorage
		WHERE intSettleStorageKey = @SettleStorageKey	
		
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
			SET @intContractHeaderId = NULL
			
			

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

				SELECT @intContractHeaderId=intContractHeaderId from vyuCTContractDetailView Where intContractDetailId=@intContractDetailId

				IF @dblStorageUnits <= @dblContractUnits
				BEGIN
					

					UPDATE @SettleContract SET dblContractUnits = dblContractUnits - @dblStorageUnits WHERE intSettleContractKey = @SettleContractKey
															
					UPDATE #SettleStorage SET dblStorageUnits = 0 WHERE intSettleStorageKey = @SettleStorageKey
					
					EXEC uspCTUpdateScheduleQuantity 
						 @intContractDetailId=@intContractDetailId
						,@dblQuantityToUpdate=@dblStorageUnits
						,@intUserId=@UserKey
						,@intExternalId=@intCustomerStorageId
						,@strScreenName='Settle Storage'
										
					Update tblGRCustomerStorage SET dblOpenBalance=dblOpenBalance-@dblStorageUnits Where intCustomerStorageId=@intCustomerStorageId

					--CREATE History For Storage Ticket
					INSERT INTO [dbo].[tblGRStorageHistory] 
					(
					 [intConcurrencyId]
					,[intCustomerStorageId]	
					,[intInvoiceId]
					,[intContractHeaderId]
					,[dblUnits]
					,[dtmHistoryDate]					
					,[strType]
					,[strUserName]					
					,[intEntityId]
					,[strSettleTicket]					
					)
				VALUES 
				   (
					1
					,@intCustomerStorageId
					,NULL
					,@intContractHeaderId
					,@dblStorageUnits				
					,GETDATE()					
					,'Settlement'
					,@UserName				
					,@ContractEntityId
					,@TicketNo
					)


					BREAK;
				END
				ELSE
				BEGIN

					
						
					UPDATE @SettleContract SET dblContractUnits = dblContractUnits - @dblContractUnits WHERE intSettleContractKey = @SettleContractKey

					UPDATE #SettleStorage SET dblStorageUnits = 0 WHERE intSettleStorageKey = @SettleStorageKey

					EXEC uspCTUpdateScheduleQuantity 
						 @intContractDetailId=@intContractDetailId
						,@dblQuantityToUpdate=@dblContractUnits
						,@intUserId=@UserKey
						,@intExternalId=@intCustomerStorageId
						,@strScreenName='Settle Storage'
						
					Update tblGRCustomerStorage SET dblOpenBalance=dblOpenBalance-@dblContractUnits Where intCustomerStorageId=@intCustomerStorageId
						
						INSERT INTO [dbo].[tblGRStorageHistory] 
						(
						 [intConcurrencyId]
						,[intCustomerStorageId]	
						,[intInvoiceId]
						,[intContractHeaderId]
						,[dblUnits]
						,[dtmHistoryDate]					
						,[strType]
						,[strUserName]					
						,[intEntityId]
						,[strSettleTicket]					
						)
					VALUES 
					   (
						1
						,@intCustomerStorageId
						,NULL
						,@intContractHeaderId
						,@dblContractUnits				
						,GETDATE()					
						,'Settlement'
						,@UserName				
						,@ContractEntityId
						,@TicketNo
						)
					

					DELETE FROM #SettleStorageCopy

					INSERT INTO #SettleStorageCopy 
					(
						 intSettleStorageKey
						,intCustomerStorageId
						,dblStorageUnits
						,dblOpenBalance
						,strStorageTicketNumber
						,intCompanyLocationId
						,intStorageTypeId
						,intStorageScheduleId
					)
					SELECT 
						 intSettleStorageKey
						,intCustomerStorageId
						,dblStorageUnits
						,dblOpenBalance
						,strStorageTicketNumber
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
						,strStorageTicketNumber
						,intCompanyLocationId
						,intStorageTypeId
						,intStorageScheduleId
						)
					SELECT @SettleStorageKey + 1
						,@intCustomerStorageId
						,(@dblStorageUnits - @dblContractUnits)
						,@dblOpenBalance
						,@strStorageTicketNumber
						,@intCompanyLocationId
						,@intStorageTypeId
						,@intStorageScheduleId

					SET IDENTITY_INSERT [dbo].[#SettleStorage] OFF

					INSERT INTO [#SettleStorage] 
					(
						 intCustomerStorageId
						,dblStorageUnits
						,dblOpenBalance
						,strStorageTicketNumber
						,intCompanyLocationId
						,intStorageTypeId
						,intStorageScheduleId
					)
					SELECT intCustomerStorageId
						,dblStorageUnits
						,dblOpenBalance
						,strStorageTicketNumber
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
		
			
	EXEC sp_xml_removedocument @idoc
END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()
	IF @idoc <> 0 EXEC sp_xml_removedocument @idoc
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
	
END CATCH