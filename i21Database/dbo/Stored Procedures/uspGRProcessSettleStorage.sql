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
	DECLARE @EntityId INT
	DECLARE @ItemId INT
	DECLARE @intUnitMeasureId INT
	DECLARE @intSourceItemUOMId INT
	DECLARE @TicketNo NVARCHAR(20)
	DECLARE @UserKey INT
	DECLARE @UserName NVARCHAR(100)
	
	--Storage Varibales
	DECLARE @SettleStorageKey INT
	DECLARE @CurrentItemOpenBalance DECIMAL(24, 10)
	DECLARE @intCustomerStorageId INT
	DECLARE @dblStorageUnits DECIMAL(24, 10)
	DECLARE @dblNegativeStorageUnits DECIMAL(24, 10)
	DECLARE @dblOpenBalance DECIMAL(24, 10)
	DECLARE @strStorageTicketNumber NVARCHAR(50)
	DECLARE @intCompanyLocationId INT
	DECLARE @intStorageTypeId INT
	DECLARE @intStorageScheduleId INT
	DECLARE @DPContractHeaderId INT
	DECLARE @ContractHeaderId INT
	DECLARE @ContractDetailId INT
	DECLARE @dblDPStorageUnits DECIMAL(24, 10)
	
	--Contract Varibales
	DECLARE @SettleContractKey INT
	DECLARE @intContractDetailId INT
	DECLARE @intContractHeaderId INT
	DECLARE @dblContractUnits DECIMAL(24, 10)
	DECLARE @dblNegativeContractUnits DECIMAL(24, 10)
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
	DECLARE @dtmCalculateStorageThrough DATETIME
	DECLARE @dblAdjustPerUnit DECIMAL(24, 10)
	DECLARE @dblStorageDue DECIMAL(24, 10)
	DECLARE @intExternalId INT
	DECLARE @voucherDetailStorage AS [VoucherDetailStorage]
	DECLARE @intCreatedBillId INT
	DECLARE @ItemDescription NVARCHAR(100)
	DECLARE @intSettleVoucherKey INT
	DECLARE @LocationId INT
	DECLARE @strProcessType NVARCHAR(30)
	DECLARE @strUpdateType NVARCHAR(30)
	DECLARE @IntCommodityId INT
	DECLARE @intStorageChargeItemId INT
	DECLARE @StorageChargeItemDescription NVARCHAR(100)
	DECLARE @dtmDate AS DATETIME
	DECLARE @dblStorageDuePerUnit DECIMAL(24, 10)
	DECLARE @dblStorageDueAmount DECIMAL(24, 10)
	DECLARE @dblStorageDueTotalPerUnit DECIMAL(24, 10)
	DECLARE @dblStorageDueTotalAmount DECIMAL(24, 10)
	DECLARE @dblStorageBilledPerUnit DECIMAL(24, 10)
	DECLARE @dblStorageBilledAmount DECIMAL(24, 10)
	DECLARE @dblTicketStorageDue DECIMAL(24, 10)

	SET @dtmDate = GETDATE()

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
		,intContractHeaderId INT
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
		,intContractHeaderId INT
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
	
	DECLARE @SettleVoucherCreate AS TABLE 
	(
		intSettleVoucherKey INT IDENTITY(1, 1)
		,intCustomerStorageId INT
		,intCompanyLocationId INT
		,intContractHeaderId INT NULL
		,intContractDetailId INT NULL
		,dblUnits DECIMAL(24, 10)
		,dblCashPrice DECIMAL(24, 10)
		,intItemId INT NULL
		,strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		,IsProcessed BIT
	)

	SELECT @UserKey = intCreatedUserId
		,@EntityId = intEntityId
		,@ItemId = intItemId
		,@TicketNo = strStorageTicket
		,@strStorageAdjustment = strStorageAdjustment
		,@dtmCalculateStorageThrough = dtmCalculateStorageThrough
		,@dblAdjustPerUnit = dblAdjustPerUnit
		,@dblStorageDue = dblStorageDue
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

	SET @strUpdateType = 'estimate'
	SET @strProcessType = CASE WHEN @strStorageAdjustment IN ('No additional','Override') THEN 'Unpaid' ELSE 'calculate' END

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
		,intContractHeaderId
	)
	SELECT 
		 intCustomerStorageId
		,dblUnits
		,dblOpenBalance
		,strStorageTicketNumber
		,intCompanyLocationId
		,intStorageTypeId
		,intStorageScheduleId
		,intContractHeaderId INT
	FROM OPENXML(@idoc, 'root/SettleStorage', 2) WITH 
	(
			intCustomerStorageId INT
			,dblUnits DECIMAL(24, 10)
			,dblOpenBalance DECIMAL(24, 10)
			,strStorageTicketNumber NVARCHAR(40)
			,intCompanyLocationId INT
			,intStorageTypeId INT
			,intStorageScheduleId INT
			,intContractHeaderId INT
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
	SELECT 
		 intContractDetailId
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

	SELECT @ItemDescription = strItemNo
	FROM tblICItem
	WHERE intItemId = @ItemId

	SELECT @IntCommodityId = a.intCommodityId
		,@intUnitMeasureId = a.intUnitMeasureId
	FROM tblICCommodityUnitMeasure a
	JOIN tblICItem b ON b.intCommodityId = a.intCommodityId
	WHERE b.intItemId = @ItemId AND a.ysnStockUnit = 1

	IF @intUnitMeasureId IS NULL
	BEGIN
		RAISERROR ('The stock UOM of the commodity must be set for item',16,1);
		RETURN;
	END

	SELECT TOP 1 @intStorageChargeItemId = intItemId
	FROM tblICItem
	WHERE strType = 'Other Charge' AND strCostType = 'Storage Charge' AND intCommodityId = @IntCommodityId

	IF @intStorageChargeItemId IS NULL
	BEGIN
		SELECT TOP 1 @intStorageChargeItemId = intItemId
		FROM tblICItem
		WHERE strType = 'Other Charge' AND strCostType = 'Storage Charge' AND intCommodityId IS NULL
	END

	SELECT @StorageChargeItemDescription = strDescription
	FROM tblICItem
	WHERE intItemId = @intStorageChargeItemId

	IF NOT EXISTS (SELECT 1 FROM tblICItemUOM WHERE intItemId = @ItemId AND intUnitMeasureId = @intUnitMeasureId)
	BEGIN
		RAISERROR ('The stock UOM of the commodity must exist in the conversion table of the item',16,1);
	END

	SELECT @intSourceItemUOMId = intItemUOMId
	FROM tblICItemUOM UOM
	WHERE intItemId = @ItemId AND intUnitMeasureId = @intUnitMeasureId

	SELECT @SettleStorageKey = MIN(intSettleStorageKey)
	FROM #SettleStorage
	WHERE dblStorageUnits > 0

	SET @intCustomerStorageId = NULL
	SET @dblStorageUnits = NULL
	SET @dblOpenBalance = NULL
	SET @strStorageTicketNumber = NULL
	SET @intCompanyLocationId = NULL
	SET @intStorageTypeId = NULL
	SET @intStorageScheduleId = NULL
	SET @CurrentItemOpenBalance = NULL
	SET @dblDPStorageUnits = NULL
	SET @DPContractHeaderId = NULL
	SET @ContractDetailId = NULL

	WHILE @SettleStorageKey > 0
	BEGIN
		SELECT @intCustomerStorageId = intCustomerStorageId
			,@dblStorageUnits = dblStorageUnits
			,@dblOpenBalance = dblOpenBalance
			,@strStorageTicketNumber = strStorageTicketNumber
			,@intCompanyLocationId = intCompanyLocationId
			,@intStorageTypeId = intStorageTypeId
			,@intStorageScheduleId = intStorageScheduleId
			,@DPContractHeaderId = intContractHeaderId
		FROM #SettleStorage
		WHERE intSettleStorageKey = @SettleStorageKey

		--Storage Due		
		SET @dblStorageDuePerUnit = 0
		SET @dblStorageDueAmount = 0
		SET @dblStorageDueTotalPerUnit = 0
		SET @dblStorageDueTotalAmount = 0
		SET @dblStorageBilledPerUnit = 0
		SET @dblStorageBilledAmount = 0
		SET @dblTicketStorageDue = 0

		EXEC uspGRCalculateStorageCharge 
			 @strProcessType
			,@strUpdateType
			,@intCustomerStorageId
			,NULL
			,NULL
			,NULL
			,@dtmCalculateStorageThrough
			,@UserKey
			,'Process Grain Storage'
			,@dblStorageDuePerUnit OUTPUT
			,@dblStorageDueAmount OUTPUT
			,@dblStorageDueTotalPerUnit OUTPUT
			,@dblStorageDueTotalAmount OUTPUT
			,@dblStorageBilledPerUnit OUTPUT
			,@dblStorageBilledAmount OUTPUT

		IF @strStorageAdjustment = 'Override'
			SET @dblTicketStorageDue = @dblAdjustPerUnit * @dblOpenBalance + @dblStorageDueAmount + @dblStorageDueTotalAmount - @dblStorageBilledAmount
		ELSE
			SET @dblTicketStorageDue = @dblStorageDueAmount + @dblStorageDueTotalAmount - @dblStorageBilledAmount

		IF NOT EXISTS (SELECT 1 FROM @SettleVoucherCreate WHERE intCustomerStorageId = @intCustomerStorageId AND intItemId = @intStorageChargeItemId) AND @dblTicketStorageDue > 0
		BEGIN
			INSERT INTO @SettleVoucherCreate 
			(
				 intCustomerStorageId
				,intCompanyLocationId
				,intContractHeaderId
				,intContractDetailId
				,dblUnits
				,dblCashPrice
				,intItemId
				,strItemNo
				,IsProcessed
			)
			SELECT 
				 @intCustomerStorageId
				,@intCompanyLocationId
				,NULL
				,NULL
				,@dblOpenBalance
				,@dblTicketStorageDue
				,@intStorageChargeItemId
				,@StorageChargeItemDescription
				,0
		END

		--Discount
		IF NOT EXISTS ( SELECT 1 FROM @SettleVoucherCreate WHERE intCustomerStorageId = @intCustomerStorageId AND intItemId IN 
						(
							SELECT DItem.intItemId
							FROM tblICItem DItem
							JOIN tblGRDiscountScheduleCode a ON a.intItemId = DItem.intItemId
						)
				      )
			AND EXISTS 
			 ( 
			   SELECT 1 FROM tblQMTicketDiscount WHERE intTicketFileId = @intCustomerStorageId AND ISNULL(dblDiscountDue, 0) <> ISNULL(dblDiscountPaid, 0) AND strSourceType = 'Storage'
			 )
		BEGIN
			INSERT INTO @SettleVoucherCreate 
			(
				 intCustomerStorageId
				,intCompanyLocationId
				,intContractHeaderId
				,intContractDetailId
				,dblUnits
				,dblCashPrice
				,intItemId
				,strItemNo
				,IsProcessed
			)
			SELECT 
				 CS.intCustomerStorageId
				,CS.intCompanyLocationId
				,NULL intContractHeaderId
				,NULL intContractDetailId
				,@dblOpenBalance dblUnits
				,(ISNULL(QM.dblDiscountPaid, 0) - ISNULL(QM.dblDiscountDue, 0)) AS dblCashPrice
				,DItem.intItemId
				,DItem.strItemNo
				,0 AS IsProcessed
			FROM tblGRCustomerStorage CS
			LEFT JOIN tblQMTicketDiscount QM ON QM.intTicketFileId = CS.intCustomerStorageId AND QM.strSourceType = 'Storage'
			JOIN tblGRDiscountScheduleCode a ON a.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId
			JOIN tblICItem DItem ON DItem.intItemId = a.intItemId
			WHERE ISNULL(CS.strStorageType, '') <> 'ITR'
				AND (ISNULL(QM.dblDiscountDue, 0) - ISNULL(QM.dblDiscountPaid, 0)) <> 0
				AND QM.intTicketFileId = @intCustomerStorageId
		END

		IF ISNULL(@DPContractHeaderId, 0) > 0
		BEGIN
			SELECT @ContractDetailId = intContractDetailId
			FROM vyuCTContractDetailView
			WHERE intContractHeaderId = @DPContractHeaderId

			SET @dblDPStorageUnits = - @dblStorageUnits

			EXEC uspCTUpdateSequenceQuantityUsingUOM 
				 @intContractDetailId = @ContractDetailId
				,@dblQuantityToUpdate = @dblDPStorageUnits
				,@intUserId = @UserKey
				,@intExternalId = @intCustomerStorageId
				,@strScreenName = 'Settle Storage'
				,@intSourceItemUOMId = @intSourceItemUOMId
		END

		IF EXISTS (SELECT 1 FROM @SettleContract WHERE dblContractUnits > 0)
		BEGIN
			SELECT @SettleContractKey = MIN(intSettleContractKey)
			FROM @SettleContract
			WHERE dblContractUnits > 0

			SET @intContractDetailId = NULL
			SET @dblContractUnits = NULL
			SET @strContractNumber = NULL
			SET @ContractEntityId = NULL
			SET @dblAvailableQty = NULL
			SET @strContractType = NULL
			SET @dblCashPrice = NULL
			SET @intContractHeaderId = NULL
			SET @dblNegativeContractUnits = NULL

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

				SELECT @intContractHeaderId = intContractHeaderId
				FROM vyuCTContractDetailView
				WHERE intContractDetailId = @intContractDetailId

				IF @dblStorageUnits <= @dblContractUnits
				BEGIN
					SET @dblNegativeStorageUnits = - @dblStorageUnits

					UPDATE @SettleContract
					SET dblContractUnits = dblContractUnits - @dblStorageUnits
					WHERE intSettleContractKey = @SettleContractKey

					UPDATE #SettleStorage
					SET dblStorageUnits = 0
					WHERE intSettleStorageKey = @SettleStorageKey

					EXEC uspCTUpdateSequenceQuantityUsingUOM 
						 @intContractDetailId = @intContractDetailId
						,@dblQuantityToUpdate = @dblNegativeStorageUnits
						,@intUserId = @UserKey
						,@intExternalId = @intCustomerStorageId
						,@strScreenName = 'Settle Storage'
						,@intSourceItemUOMId = @intSourceItemUOMId

					UPDATE tblGRCustomerStorage
					SET dblOpenBalance = dblOpenBalance - @dblStorageUnits
					WHERE intCustomerStorageId = @intCustomerStorageId

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

					INSERT INTO @SettleVoucherCreate 
					(
						intCustomerStorageId
						,intCompanyLocationId
						,intContractHeaderId
						,intContractDetailId
						,dblUnits
						,dblCashPrice
						,intItemId
						,strItemNo
						,IsProcessed
					)
					SELECT 
						 @intCustomerStorageId
						,@intCompanyLocationId
						,@intContractHeaderId
						,@intContractDetailId
						,@dblStorageUnits
						,@dblCashPrice
						,@ItemId
						,@ItemDescription
						,0

					BREAK;
				END
				ELSE
				BEGIN
					SET @dblNegativeStorageUnits = - @dblContractUnits

					UPDATE @SettleContract
					SET dblContractUnits = dblContractUnits - @dblContractUnits
					WHERE intSettleContractKey = @SettleContractKey

					UPDATE #SettleStorage
					SET dblStorageUnits = 0
					WHERE intSettleStorageKey = @SettleStorageKey

					EXEC uspCTUpdateSequenceQuantityUsingUOM 
						 @intContractDetailId = @intContractDetailId
						,@dblQuantityToUpdate = @dblNegativeStorageUnits
						,@intUserId = @UserKey
						,@intExternalId = @intCustomerStorageId
						,@strScreenName = 'Settle Storage'
						,@intSourceItemUOMId = @intSourceItemUOMId

					UPDATE tblGRCustomerStorage
					SET dblOpenBalance = dblOpenBalance - @dblContractUnits
					WHERE intCustomerStorageId = @intCustomerStorageId

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

					INSERT INTO @SettleVoucherCreate 
					(
						 intCustomerStorageId
						,intCompanyLocationId
						,intContractHeaderId
						,intContractDetailId
						,dblUnits
						,dblCashPrice
						,intItemId
						,strItemNo
						,IsProcessed
					)
					SELECT 
						 @intCustomerStorageId
						,@intCompanyLocationId
						,@intContractHeaderId
						,@intContractDetailId
						,@dblContractUnits
						,@dblCashPrice
						,@ItemId
						,@ItemDescription
						,0

					DELETE
					FROM #SettleStorageCopy

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
						,intContractHeaderId
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
						,intContractHeaderId
					FROM #SettleStorage
					WHERE intSettleStorageKey > @SettleStorageKey

					DELETE
					FROM #SettleStorage
					WHERE intSettleStorageKey > @SettleStorageKey

					SET IDENTITY_INSERT [dbo].[#SettleStorage] ON

					INSERT INTO [#SettleStorage] 
					(
						 intSettleStorageKey
						,intCustomerStorageId
						,dblStorageUnits
						,dblOpenBalance
						,strStorageTicketNumber
						,intCompanyLocationId
						,intStorageTypeId
						,intStorageScheduleId
						,intContractHeaderId
					)
					SELECT 
						 @SettleStorageKey + 1
						,@intCustomerStorageId
						,(@dblStorageUnits - @dblContractUnits)
						,@dblOpenBalance
						,@strStorageTicketNumber
						,@intCompanyLocationId
						,@intStorageTypeId
						,@intStorageScheduleId
						,ISNULL(@DPContractHeaderId, 0)

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
						,intContractHeaderId
					)
					SELECT 
						 intCustomerStorageId
						,dblStorageUnits
						,dblOpenBalance
						,strStorageTicketNumber
						,intCompanyLocationId
						,intStorageTypeId
						,intStorageScheduleId
						,intContractHeaderId
					FROM #SettleStorageCopy

					DELETE
					FROM #SettleStorageCopy

					BREAK;
				END

				SELECT @SettleContractKey = MIN(intSettleContractKey)
				FROM @SettleContract
				WHERE intSettleContractKey > @SettleContractKey AND dblContractUnits > 0
			END

			SELECT @SettleStorageKey = MIN(intSettleStorageKey)
			FROM [#SettleStorage]
			WHERE intSettleStorageKey > @SettleStorageKey AND dblStorageUnits > 0
		END
		ELSE IF @dblSpotUnits > 0
		BEGIN
			IF @dblStorageUnits <= @dblSpotUnits
			BEGIN
				UPDATE tblGRCustomerStorage
				SET dblOpenBalance = dblOpenBalance - @dblStorageUnits
				WHERE intCustomerStorageId = @intCustomerStorageId

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
					,NULL
					,@dblStorageUnits
					,GETDATE()
					,'Settlement'
					,@UserName
					,NULL
					,@TicketNo
				)
				
				SET @dblSpotUnits = @dblSpotUnits - @dblStorageUnits

				INSERT INTO @SettleVoucherCreate
				(
					 intCustomerStorageId
					,intCompanyLocationId
					,intContractHeaderId
					,intContractDetailId
					,dblUnits
					,dblCashPrice
					,intItemId
					,strItemNo
					,IsProcessed
				)
				SELECT 
					 @intCustomerStorageId
					,@intCompanyLocationId
					,NULL
					,NULL
					,@dblStorageUnits
					,@dblSpotCashPrice
					,@ItemId
					,@ItemDescription
					,0
			END
			ELSE
			BEGIN
				UPDATE tblGRCustomerStorage
				SET dblOpenBalance = dblOpenBalance - @dblSpotUnits
				WHERE intCustomerStorageId = @intCustomerStorageId

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
					,NULL
					,@dblSpotUnits
					,GETDATE()
					,'Settlement'
					,@UserName
					,NULL
					,@TicketNo
				)

				SET @dblSpotUnits = 0

				INSERT INTO @SettleVoucherCreate
				(
					 intCustomerStorageId
					,intCompanyLocationId
					,intContractHeaderId
					,intContractDetailId
					,dblUnits
					,dblCashPrice
					,intItemId
					,strItemNo
					,IsProcessed
				)
				SELECT 
					 @intCustomerStorageId
					,@intCompanyLocationId
					,NULL
					,NULL
					,@dblSpotUnits
					,@dblSpotCashPrice
					,@ItemId
					,@ItemDescription
					,0
			END
		END
		ELSE
			BREAK;
	END
	----CREATING VOUCHER
	SELECT @intSettleVoucherKey = MIN(intSettleVoucherKey)
	FROM @SettleVoucherCreate
	WHERE IsProcessed = 0

	WHILE @intSettleVoucherKey > 0
	BEGIN
		SET @LocationId = NULL

		SELECT @LocationId = intCompanyLocationId
		FROM @SettleVoucherCreate
		WHERE intSettleVoucherKey = @intSettleVoucherKey

		BEGIN TRANSACTION

		DELETE
		FROM @voucherDetailStorage

		SET @intCreatedBillId = 0

		INSERT INTO @voucherDetailStorage
		(
			 [intCustomerStorageId]
			,[intItemId]
			,[intAccountId]
			,[dblQtyReceived]
			,[strMiscDescription]
			,[dblCost]
			,[intContractHeaderId]
			,[intContractDetailId]
		)
		SELECT 
			 [intCustomerStorageId]
			,[intItemId]
			, NULL
			,[dblUnits]
			,[strItemNo]
			,[dblCashPrice]
			,[intContractHeaderId]
			,[intContractDetailId]
		FROM @SettleVoucherCreate
		WHERE intCompanyLocationId = @LocationId AND IsProcessed = 0

		EXEC [dbo].[uspAPCreateBillData] 
			 @userId = @UserKey
			,@vendorId = @EntityId
			,@type = 1
			,@voucherDetailStorage = @voucherDetailStorage
			,@shipTo = @LocationId
			,@vendorOrderNumber = NULL
			,@voucherDate = @dtmDate
			,@billId = @intCreatedBillId OUTPUT

		IF @intCreatedBillId > 0
		BEGIN
			COMMIT TRANSACTION
			
			INSERT INTO [dbo].[tblGRStorageHistory] 
			(
				 [intConcurrencyId]
				,[intCustomerStorageId]
				,[intBillId]
				,[dblUnits]
				,[dtmHistoryDate]
				,[dblPaidAmount]
				,[strType]
				,[strUserName]
			 )
			SELECT 
				 [intConcurrencyId] = 1
				,[intCustomerStorageId] = APL.intCustomerStorageId
				,[intBillId] = @intCreatedBillId
				,[dblUnits] = APL.dblQtyReceived
				,[dtmHistoryDate] = GetDATE()
				,[dblPaidAmount] = APL.dblCost * APL.dblQtyReceived
				,[strType] = 'Generated Bill'
				,[strUserName] = (SELECT strUserName FROM tblSMUserSecurity WHERE [intEntityUserSecurityId] = @UserKey)
			FROM tblAPBill AP
			JOIN tblAPBillDetail APL ON APL.intBillId = AP.intBillId
			WHERE APL.intBillId = @intCreatedBillId
		END

		UPDATE @SettleVoucherCreate
		SET IsProcessed = 1
		WHERE intCompanyLocationId = @LocationId

		SELECT @intSettleVoucherKey = MIN(intSettleVoucherKey)
		FROM @SettleVoucherCreate
		WHERE intSettleVoucherKey > @intSettleVoucherKey AND IsProcessed = 0
	END

	---END Voucher.	
	EXEC sp_xml_removedocument @idoc
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	IF @idoc <> 0
		EXEC sp_xml_removedocument @idoc
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH
