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
	
	--Storage Charge Variables
	DECLARE @strStorageAdjustment NVARCHAR(50)
	DECLARE @dtmCalculateStorageThrough DATETIME
	DECLARE @dblAdjustPerUnit DECIMAL(24, 10)
	DECLARE @dblStorageDue DECIMAL(24, 10)
	DECLARE @intExternalId INT
	
	
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
	DECLARE @FeeItemId INT
	DECLARE @strFeeItem NVARCHAR(40)
	DECLARE @intCurrencyId INT
	DECLARE @intDefaultCurrencyId INT
	DECLARE @intItemLocationId INT
	DECLARE @strOrderType NVARCHAR(50)
	DECLARE @dblUnits DECIMAL(24, 10)
	DECLARE @intShipFromId INT
	DECLARE @dblUOMQty NUMERIC(38,20)
	DECLARE @detailCreated AS Id

	SET @dtmDate = GETDATE()
	SELECT @intDefaultCurrencyId=intDefaultCurrencyId FROm tblSMCompanyPreference

	EXEC sp_xml_preparedocument @idoc OUTPUT,@strXml

	DECLARE @SettleStorage AS TABLE  
	(
		 intSettleStorageKey INT IDENTITY(1, 1)
		,intCustomerStorageId INT
		,dblStorageUnits DECIMAL(24, 10)
		,dblRemainingUnits DECIMAL(24, 10)
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
		,strOrderType NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		,intCustomerStorageId INT
		,intCompanyLocationId INT
		,intContractHeaderId INT NULL
		,intContractDetailId INT NULL
		,dblUnits DECIMAL(24, 10)
		,dblCashPrice DECIMAL(24, 10)
		,intItemId INT NULL
		,strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		,intItemSort INT NULL
		,IsProcessed BIT
		,intTicketDiscountId INT NULL
	)

	SELECT 
		 @UserKey = intCreatedUserId
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
	
	SET @intCurrencyId = ISNULL((SELECT intCurrencyId FROM tblAPVendor WHERE [intEntityId] = @EntityId), @intDefaultCurrencyId)
	
	SET @strUpdateType = 'estimate'
	SET @strProcessType = CASE WHEN @strStorageAdjustment IN ('No additional','Override') THEN 'Unpaid' ELSE 'calculate' END

	SELECT @UserName = strUserName
	FROM tblSMUserSecurity
	WHERE [intEntityId] = @UserKey --Another Hiccup

	INSERT INTO @SettleStorage 
	(
		 intCustomerStorageId
		,dblStorageUnits
		,dblRemainingUnits
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
	SELECT TOP 1 
			@intShipFromId = intShipFromId 
	FROM	tblAPVendor 
	WHERE	[intEntityId] =@EntityId
	 
	SELECT	@ItemDescription = strItemNo
	FROM	tblICItem
	WHERE	intItemId = @ItemId
		
	SELECT	@FeeItemId = intItemId 
	FROM	tblGRCompanyPreference
	
	SELECT	@strFeeItem = strItemNo 
	FROM	tblICItem 
	WHERE	intItemId = @FeeItemId

	SELECT	@IntCommodityId = a.intCommodityId
			,@intUnitMeasureId = a.intUnitMeasureId
	FROM	tblICCommodityUnitMeasure a 
	JOIN	tblICItem b ON b.intCommodityId = a.intCommodityId
	WHERE	b.intItemId = @ItemId AND a.ysnStockUnit = 1

	IF @intUnitMeasureId IS NULL
	BEGIN
		RAISERROR ('The stock UOM of the commodity must be set for item',16,1);
		RETURN;
	END

	SELECT	TOP 1 
			@intStorageChargeItemId = intItemId
	FROM	tblICItem
	WHERE	strType = 'Other Charge' 
			AND strCostType = 'Storage Charge' 
			AND intCommodityId = @IntCommodityId

	IF @intStorageChargeItemId IS NULL
	BEGIN
		SELECT	TOP 
				1 @intStorageChargeItemId = intItemId
		FROM	tblICItem
		WHERE	strType = 'Other Charge' 
				AND strCostType = 'Storage Charge' 
				AND intCommodityId IS NULL
	END

	SELECT	@StorageChargeItemDescription = strDescription
	FROM	tblICItem
	WHERE	intItemId = @intStorageChargeItemId

	IF NOT EXISTS (SELECT 1 FROM tblICItemUOM WHERE intItemId = @ItemId AND intUnitMeasureId = @intUnitMeasureId)
	BEGIN
		RAISERROR ('The stock UOM of the commodity must exist in the conversion table of the item',16,1);
	END

	SELECT	@intSourceItemUOMId = intItemUOMId
			,@dblUOMQty=UOM.dblUnitQty
	FROM	tblICItemUOM UOM
	WHERE	intItemId = @ItemId 
			AND intUnitMeasureId = @intUnitMeasureId

	SELECT	@SettleStorageKey = MIN(intSettleStorageKey)
	FROM	@SettleStorage
	WHERE	dblRemainingUnits > 0

	SET @intCustomerStorageId = NULL
	SET @dblStorageUnits = NULL
	SET @dblOpenBalance = NULL
	SET @strStorageTicketNumber = NULL
	SET @intCompanyLocationId = NULL
	SET @intStorageTypeId = NULL
	SET @intStorageScheduleId = NULL
	
	SET @dblDPStorageUnits = NULL
	SET @DPContractHeaderId = NULL
	SET @ContractDetailId = NULL

	WHILE @SettleStorageKey > 0
	BEGIN
		SELECT	@intCustomerStorageId = intCustomerStorageId
				,@dblStorageUnits = dblRemainingUnits
				,@dblOpenBalance = dblOpenBalance
				,@strStorageTicketNumber = strStorageTicketNumber
				,@intCompanyLocationId = intCompanyLocationId
				,@intStorageTypeId = intStorageTypeId
				,@intStorageScheduleId = intStorageScheduleId
				,@DPContractHeaderId = CASE WHEN dblStorageUnits = dblRemainingUnits THEN intContractHeaderId ELSE 0 END
		FROM	@SettleStorage
		WHERE	intSettleStorageKey = @SettleStorageKey

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
			,@dblStorageUnits
			,@dtmCalculateStorageThrough
			,@UserKey
			,0
			,NULL	
			,@dblStorageDuePerUnit OUTPUT
			,@dblStorageDueAmount OUTPUT
			,@dblStorageDueTotalPerUnit OUTPUT
			,@dblStorageDueTotalAmount OUTPUT
			,@dblStorageBilledPerUnit OUTPUT
			,@dblStorageBilledAmount OUTPUT

		IF @strStorageAdjustment = 'Override'
			SET @dblTicketStorageDue = @dblAdjustPerUnit+ @dblStorageDuePerUnit + @dblStorageDueTotalPerUnit - @dblStorageBilledPerUnit
		ELSE
			SET @dblTicketStorageDue =  @dblStorageDuePerUnit + @dblStorageDueTotalPerUnit - @dblStorageBilledPerUnit

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
				,intItemSort
				,IsProcessed
			)
			SELECT 
				 @intCustomerStorageId
				,@intCompanyLocationId
				,NULL
				,NULL
				,@dblStorageUnits
				,- @dblTicketStorageDue
				,@intStorageChargeItemId
				,@StorageChargeItemDescription
				,2
				,0
		END	
		
		--Discount
		IF NOT EXISTS ( SELECT 1 FROM @SettleVoucherCreate WHERE intCustomerStorageId = @intCustomerStorageId AND intItemId IN 
						(
							SELECT	DItem.intItemId
							FROM	tblICItem DItem JOIN tblGRDiscountScheduleCode a ON a.intItemId = DItem.intItemId
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
				,intItemSort
				,IsProcessed
				,intTicketDiscountId
			)
			SELECT 
				 CS.intCustomerStorageId
				,CS.intCompanyLocationId
				,NULL intContractHeaderId
				,NULL intContractDetailId
				,@dblStorageUnits dblUnits
				,(ISNULL(QM.dblDiscountPaid, 0) - ISNULL(QM.dblDiscountDue, 0)) AS dblCashPrice
				,DItem.intItemId
				,DItem.strItemNo
				,3
				,0 AS IsProcessed
				,QM.intTicketDiscountId
			FROM tblGRCustomerStorage CS
			LEFT JOIN tblQMTicketDiscount QM ON QM.intTicketFileId = CS.intCustomerStorageId AND QM.strSourceType = 'Storage'
			JOIN tblGRDiscountScheduleCode a ON a.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId
			JOIN tblICItem DItem ON DItem.intItemId = a.intItemId
			WHERE ISNULL(CS.strStorageType, '') <> 'ITR'
				AND (ISNULL(QM.dblDiscountDue, 0) - ISNULL(QM.dblDiscountPaid, 0)) <> 0
				AND QM.intTicketFileId = @intCustomerStorageId
		END

		--Unpaid Fee		
		IF	NOT EXISTS (SELECT 1 FROM @SettleVoucherCreate WHERE intCustomerStorageId = @intCustomerStorageId AND intItemId =@FeeItemId AND intItemSort = 4)
			AND EXISTS(SELECT 1 FROM tblGRCustomerStorage WHERE intCustomerStorageId = @intCustomerStorageId AND ISNULL(dblFeesDue,0)< >ISNULL(dblFeesPaid,0))
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
				,intItemSort
				,IsProcessed
			)
			SELECT 
				 @intCustomerStorageId
				,@intCompanyLocationId
				,NULL intContractHeaderId
				,NULL intContractDetailId
				,@dblStorageUnits dblUnits
				,(ISNULL(dblFeesPaid,0) - ISNULL(dblFeesDue,0)) AS dblCashPrice
				,@FeeItemId
				,@strFeeItem
				,4
				,0 AS IsProcessed
			FROM tblGRCustomerStorage WHERE intCustomerStorageId = @intCustomerStorageId
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
				SELECT 
					 @intContractDetailId = intContractDetailId
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

					UPDATE @SettleStorage
					SET dblRemainingUnits = 0
					WHERE intSettleStorageKey = @SettleStorageKey

					EXEC uspCTUpdateSequenceBalance
						@intContractDetailId	=	@intContractDetailId,
						@dblQuantityToUpdate	=	@dblStorageUnits,
						@intUserId				=	@UserKey,
						@intExternalId			=	@intCustomerStorageId,
						@strScreenName			=	'Settle Storage' 
					
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
						,[intTransactionTypeId]
						,[intInventoryReceiptId]
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
						,4
						,@intContractDetailId
					)

					INSERT INTO @SettleVoucherCreate 
					(
						 intCustomerStorageId
						,strOrderType
						,intCompanyLocationId
						,intContractHeaderId
						,intContractDetailId
						,dblUnits
						,dblCashPrice
						,intItemId
						,strItemNo
						,intItemSort
						,IsProcessed
					)
					SELECT 
						 @intCustomerStorageId
						,'Purchase Contract'
						,@intCompanyLocationId
						,@intContractHeaderId
						,@intContractDetailId
						,@dblStorageUnits
						,@dblCashPrice
						,@ItemId
						,@ItemDescription
						,1
						,0

					BREAK;
				END
				ELSE
				BEGIN
					SET @dblNegativeStorageUnits = - @dblContractUnits

					UPDATE @SettleContract
					SET dblContractUnits = dblContractUnits - @dblContractUnits
					WHERE intSettleContractKey = @SettleContractKey

					UPDATE @SettleStorage
					SET dblRemainingUnits = dblRemainingUnits-@dblContractUnits
					WHERE intSettleStorageKey = @SettleStorageKey

					EXEC uspCTUpdateSequenceBalance
						 @intContractDetailId	=	@intContractDetailId,
						 @dblQuantityToUpdate	=	@dblContractUnits,
						 @intUserId				=	@UserKey,
						 @intExternalId			=	@intCustomerStorageId,
						 @strScreenName			=	'Settle Storage' 

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
						,[intTransactionTypeId]
						,[intInventoryReceiptId]
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
						,4
						,@intContractDetailId
					)

					INSERT INTO @SettleVoucherCreate 
					(
						 intCustomerStorageId
						,strOrderType
						,intCompanyLocationId
						,intContractHeaderId
						,intContractDetailId
						,dblUnits
						,dblCashPrice
						,intItemId
						,strItemNo
						,intItemSort
						,IsProcessed
					)
					SELECT 
						 @intCustomerStorageId
						,'Purchase Contract'
						,@intCompanyLocationId
						,@intContractHeaderId
						,@intContractDetailId
						,@dblContractUnits
						,@dblCashPrice
						,@ItemId
						,@ItemDescription
						,1
						,0				

					BREAK;
				END

				SELECT @SettleContractKey = MIN(intSettleContractKey)
				FROM @SettleContract
				WHERE intSettleContractKey > @SettleContractKey AND dblContractUnits > 0
			END

			SELECT @SettleStorageKey = MIN(intSettleStorageKey)
			FROM @SettleStorage
			WHERE intSettleStorageKey >= @SettleStorageKey AND dblRemainingUnits > 0
		END
		ELSE IF @dblSpotUnits > 0
		BEGIN
			IF @dblStorageUnits <= @dblSpotUnits
			BEGIN

				UPDATE @SettleStorage
				SET dblRemainingUnits = dblRemainingUnits -@dblStorageUnits
				WHERE intSettleStorageKey = @SettleStorageKey

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
					,[intTransactionTypeId]
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
					,4
				)
				
				SET @dblSpotUnits = @dblSpotUnits - @dblStorageUnits

				INSERT INTO @SettleVoucherCreate
				(
					 intCustomerStorageId
					,strOrderType
					,intCompanyLocationId
					,intContractHeaderId
					,intContractDetailId
					,dblUnits
					,dblCashPrice
					,intItemId
					,strItemNo
					,intItemSort
					,IsProcessed
				)
				SELECT 
					 @intCustomerStorageId
					,'Direct'
					,@intCompanyLocationId
					,NULL
					,NULL
					,@dblStorageUnits
					,@dblSpotCashPrice
					,@ItemId
					,@ItemDescription
					,1
					,0
			END
			ELSE
			BEGIN
				
				UPDATE @SettleStorage
				SET dblRemainingUnits = dblRemainingUnits - @dblSpotUnits
				WHERE intSettleStorageKey = @SettleStorageKey

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
					,[intTransactionTypeId]
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
					,4
				)

				SET @dblSpotUnits = 0

				INSERT INTO @SettleVoucherCreate
				(
					 intCustomerStorageId
					,strOrderType
					,intCompanyLocationId
					,intContractHeaderId
					,intContractDetailId
					,dblUnits
					,dblCashPrice
					,intItemId
					,strItemNo
					,intItemSort
					,IsProcessed
				)
				SELECT 
					 @intCustomerStorageId
					,'Direct'
					,@intCompanyLocationId
					,NULL
					,NULL
					,@dblSpotUnits
					,@dblSpotCashPrice
					,@ItemId
					,@ItemDescription
					,1
					,0
			END

			SELECT @SettleStorageKey = MIN(intSettleStorageKey)
			FROM @SettleStorage
			WHERE intSettleStorageKey >= @SettleStorageKey AND dblRemainingUnits > 0

		END
		ELSE
			BREAK;
	END
	
	---Creating Receipt and Voucher.	
	DECLARE @STARTING_NUMBER_BATCH AS INT = 3  	
	DECLARE @ItemsToStorage AS ItemCostingTableType
		   ,@ItemsToPost  AS ItemCostingTableType		   
		   ,@strBatchId AS NVARCHAR(20)		   
		   ,@intReceiptId AS INT
		   ,@intBillId AS INT
		   ,@success AS BIT 
		   
	SELECT @intSettleVoucherKey = MIN(intSettleVoucherKey)
	FROM @SettleVoucherCreate
	WHERE IsProcessed = 0 AND strOrderType IS NOT NULL
	
	WHILE @intSettleVoucherKey > 0
	BEGIN
		SET @LocationId = NULL
		SET @intCustomerStorageId=NULL
		SET @strOrderType=NULL
		SET @dblUnits=NULL
		
		SELECT	@LocationId = intCompanyLocationId
				,@intCustomerStorageId = intCustomerStorageId
				,@strOrderType = strOrderType
				,@dblUnits=dblUnits
		FROM	@SettleVoucherCreate
		WHERE	intSettleVoucherKey = @intSettleVoucherKey
		
		SELECT	@intItemLocationId = intItemLocationId 
		FROM	tblICItemLocation 
		WHERE	intItemId = @ItemId 
				AND intLocationId=@LocationId
		
		BEGIN 
			EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH, @strBatchId OUTPUT  
			IF @@ERROR <> 0 GOTO SettleStorage_Exit;
		END
		
		DELETE FROM @ItemsToStorage
		DELETE FROM @ItemsToPost

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
			intItemId = SV.[intItemId]
			,intItemLocationId = @intItemLocationId	
			,intItemUOMId = @intSourceItemUOMId
			,dtmDate = GETDATE() 
			,dblQty = -SV.[dblUnits]
			,dblUOMQty = SV.[dblUnits]
			,dblCost = SV.[dblCashPrice]
			,dblSalesPrice = 0.00
			,intCurrencyId = @intCurrencyId
			,dblExchangeRate = 1
			,intTransactionId = 1
			,intTransactionDetailId = SV.[intCustomerStorageId]
			,strTransactionId = @strStorageAdjustment
			,intTransactionTypeId = 4
			,intSubLocationId = CS.intCompanyLocationSubLocationId
			,intStorageLocationId = CS.intStorageLocationId
			,ysnIsStorage = 1
		FROM @SettleVoucherCreate SV 
		JOIN tblGRCustomerStorage CS ON CS.intCustomerStorageId = SV.intCustomerStorageId
		JOIN tblGRStorageType St ON St.intStorageScheduleTypeId = CS.intStorageTypeId AND St.ysnDPOwnedType = 0
		WHERE   SV.intCustomerStorageId=@intCustomerStorageId 
				AND SV.intItemSort = 1 
				AND SV.IsProcessed = 0 
				AND SV.strOrderType = @strOrderType   
		ORDER BY SV.intItemSort
				
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
			 intItemId = SV.[intItemId]
			,intItemLocationId = @intItemLocationId	
			,intItemUOMId = @intSourceItemUOMId
			,dtmDate = GETDATE() 
			,dblQty = -SV.[dblUnits]
			,dblUOMQty = SV.[dblUnits]
			,dblCost = SV.[dblCashPrice]
			,dblSalesPrice = 0.00
			,intCurrencyId = @intCurrencyId
			,dblExchangeRate = 1
			,intTransactionId = 1
			,intTransactionDetailId = SV.[intCustomerStorageId]
			,strTransactionId = @strStorageAdjustment
			,intTransactionTypeId = 4
			,intSubLocationId = CS.intCompanyLocationSubLocationId
			,intStorageLocationId = CS.intStorageLocationId
			,ysnIsStorage = 0
		FROM	@SettleVoucherCreate SV 
		JOIN tblGRCustomerStorage CS ON CS.intCustomerStorageId = SV.intCustomerStorageId
		JOIN tblGRStorageType St ON St.intStorageScheduleTypeId = CS.intStorageTypeId  AND St.ysnDPOwnedType = 1
		WHERE	SV.intCustomerStorageId=@intCustomerStorageId 
				AND SV.intItemSort = 1 
				AND SV.IsProcessed = 0 
				AND SV.strOrderType = @strOrderType   
		ORDER BY SV.intItemSort
						
		--Reduce the On-Storage Quantity		
		BEGIN
			 EXEC uspICPostStorage 
				  @ItemsToStorage
				, @strBatchId
				, @UserKey
			IF @@ERROR <> 0 GOTO SettleStorage_Exit;
		END

		BEGIN
			 EXEC uspICPostCosting 
				  @ItemsToPost
				, @strBatchId
				,'Cost of Goods'
				, @UserKey
			IF @@ERROR <> 0 GOTO SettleStorage_Exit;
		END

		-- Do a cost adjustment against the inventory receipt created by the scale ticket. 
		-- Cost adjustment will not require stock qty change. It will only update the cost and the valuation of the stock. 
		/*
		BEGIN 
			DECLARE @adjustCostOfDelayedPricingStock AS ItemCostAdjustmentTableType
			DECLARE @GLEntries AS RecapTableType 

			INSERT INTO @adjustCostOfDelayedPricingStock (
				[intItemId] 
				,[intItemLocationId] 
				,[intItemUOMId] 
				,[dtmDate] 
				,[dblQty] 
				,[dblUOMQty] 
				,[intCostUOMId] 
				,[dblVoucherCost] 
				,[intCurrencyId] 
				,[dblExchangeRate] 
				,[intTransactionId] 
				,[intTransactionDetailId] 
				,[strTransactionId] 
				,[intTransactionTypeId] 
				,[intLotId] 
				,[intSubLocationId] 
				,[intStorageLocationId] 
				,[ysnIsStorage] 
				,[strActualCostId] 
				,[intSourceTransactionId] 
				,[intSourceTransactionDetailId] 
				,[strSourceTransactionId] 
				,[intFobPointId]
				,[intInTransitSourceLocationId]
			)
			SELECT
					[intItemId]							=	SV.[intItemId]
					,[intItemLocationId]				=	@intItemLocationId
					,[intItemUOMId]						=   @intSourceItemUOMId
					,[dtmDate] 							=	GETDATE()
					,[dblQty] 							=	SV.[dblUnits]
					,[dblUOMQty] 						=	@dblUOMQty
					,[intCostUOMId]						=	@intSourceItemUOMId
					,[dblNewCost] 						=	SV.[dblCashPrice]						
															-- NOTE: If Settlement will have multi-currency, it has to convert the foreign amount to functional currency. See commented code below as an example:
															--CASE WHEN [Contract Currency] <> @intFunctionalCurrencyId THEN 
															--		-- Convert the settlement cost to the functional currency. 
															--		SV.[dblCashPrice] * ISNULL([Exchange Rate], 0) 
															--	 ELSE 
															--		SV.[dblCashPrice]
															--END 

					,[intCurrencyId] 					=	@intDefaultCurrencyId -- It is always in functional currency. 
					,[dblExchangeRate] 					=	1 -- Exchange rate is always 1. 
					,[intTransactionId]					=	SV.[intCustomerStorageId]
					,[intTransactionDetailId] 			=	SV.[intCustomerStorageId]
					,[strTransactionId] 				=	@TicketNo
					,[intTransactionTypeId] 			=	transType.intTransactionTypeId
					,[intLotId] 						=	NULL 
					,[intSubLocationId] 				=	NULL 
					,[intStorageLocationId] 			=	NULL 
					,[ysnIsStorage] 					=	0
					,[strActualCostId] 					=	NULL 
					,[intSourceTransactionId] 			=	r.intInventoryReceiptId
					,[intSourceTransactionDetailId] 	=	ri.intInventoryReceiptItemId
					,[strSourceTransactionId] 			=	r.strReceiptNumber
					,[intFobPointId]					=	NULL 
					,[intInTransitSourceLocationId]		=	NULL 
			FROM	@SettleVoucherCreate SV INNER JOIN tblGRCustomerStorage CS 
						ON CS.intCustomerStorageId = SV.intCustomerStorageId
					INNER JOIN tblGRStorageType St 
						ON St.intStorageScheduleTypeId = CS.intStorageTypeId 
						AND St.ysnDPOwnedType = 1
					INNER JOIN tblSCTicket t
						ON t.intTicketId = CS.intTicketId 
					INNER JOIN (
						tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptItem ri
							ON r.intInventoryReceiptId = ri.intInventoryReceiptId
							AND r.strReceiptType = 'Purchase Contract'
							AND r.intSourceType = 1 -- '1 = Scale' 
					)
						ON ri.intSourceId = t.intTicketId
						AND ri.intLineNo = t.intContractId
						AND ri.intItemId = t.intItemId
					LEFT JOIN tblICInventoryTransactionType transType
						ON transType.strName = 'Settle Storage'

			WHERE	SV.intCustomerStorageId = @intCustomerStorageId 
					AND SV.intItemSort = 1 
					AND SV.IsProcessed = 0 
					AND SV.strOrderType = @strOrderType     
			ORDER BY SV.intItemSort						

			-- NOTES: 
			-- tblICInventoryReceiptItem.intSourceId	= Scale Ticket Id
			-- tblICInventoryReceiptItem.intOrderId		= Contract Header Id 
			-- tblICInventoryReceiptItem.intLineNo		= Contract Detail Id
			-- tblSCTicket.intContractId				= Contract Detail Id

			IF EXISTS(SELECT TOP 1 1 FROM @adjustCostOfDelayedPricingStock)
			BEGIN
				INSERT INTO @GLEntries (
					dtmDate						
					,strBatchId					
					,intAccountId				
					,dblDebit					
					,dblCredit					
					,dblDebitUnit				
					,dblCreditUnit				
					,strDescription				
					,strCode					
					,strReference				
					,intCurrencyId				
					,dblExchangeRate			
					,dtmDateEntered				
					,dtmTransactionDate			
					,strJournalLineDescription  
					,intJournalLineNo			
					,ysnIsUnposted				
					,intUserId					
					,intEntityId				
					,strTransactionId			
					,intTransactionId			
					,strTransactionType			
					,strTransactionForm			
					,strModuleName				
					,intConcurrencyId			
					,dblDebitForeign			
					,dblDebitReport				
					,dblCreditForeign			
					,dblCreditReport			
					,dblReportingRate			
					,dblForeignRate						
				)
				EXEC uspICPostCostAdjustment @adjustCostOfDelayedPricingStock, @strBatchId, @UserKey
			END

			IF EXISTS (SELECT TOP 1 1 FROM @GLEntries)
			BEGIN 
				EXEC uspGLBookEntries @GLEntries, 1
			END 			
		END 
		*/
		--Get IR id created from the Scale Ticket
		BEGIN 
			SELECT TOP 1 
			@intReceiptId = r.intInventoryReceiptId
			FROM	tblICInventoryReceipt r  
			JOIN    tblICInventoryReceiptItem ri ON ri.intInventoryReceiptId=r.intInventoryReceiptId
			JOIN	tblSCTicket SC ON SC.intTicketId=ri.intSourceId	
			JOIN    tblGRCustomerStorage CS ON CS.intTicketId=SC.intTicketId					
			WHERE  r.intSourceType=1 AND CS.intCustomerStorageId = @intCustomerStorageId
		END 

		-- Create a new voucher 
		IF @intReceiptId IS NOT NULL 
		BEGIN 
			-- Work-around. Add dummy cost on the IR before converting it to Voucher
			UPDATE	ri
			SET		ri.dblUnitCost = 1
					,ri.dblLineTotal = 1
			FROM	tblICInventoryReceiptItem ri
			WHERE	ri.intInventoryReceiptId = @intReceiptId

			EXEC uspICProcessToBill 
					@intReceiptId
					, @UserKey
					, @intBillId OUTPUT 

			-- Work-around. Put the cost back to zero. 
			UPDATE	ri
			SET		ri.dblUnitCost = 0
					,ri.dblLineTotal = 0
			FROM	tblICInventoryReceiptItem ri
			WHERE	ri.intInventoryReceiptId = @intReceiptId

			-- Update the cost of the voucher detail. 
			UPDATE	bd
			SET		 bd.dblCost = SV.[dblCashPrice]
					,bd.dblQtyOrdered  = CASE WHEN SV.intItemSort = 1 THEN @dblUnits ELSE  CASE WHEN SV.dblCashPrice <0 THEN -1 ELSE 1 END END 
					,bd.dblQtyReceived = CASE WHEN SV.intItemSort = 1 THEN @dblUnits ELSE  CASE WHEN SV.dblCashPrice <0 THEN -1 ELSE 1 END END 
					,bd.dblTotal = ROUND(ISNULL(@dblUnits, 0) * SV.[dblCashPrice], 2) 
					,bd.intInventoryReceiptItemId = NULL -- and disconnect the IR from the Voucher to avoid double cost-adjustment. 					
			FROM	tblAPBill b 
			JOIN tblAPBillDetail bd ON b.intBillId = bd.intBillId
			JOIN @SettleVoucherCreate SV  ON SV.intItemId=bd.intItemId
			JOIN tblGRCustomerStorage CS ON CS.intCustomerStorageId = SV.intCustomerStorageId
			JOIN tblSCTicket SC ON SC.intTicketId=CS.intTicketId		
			WHERE SV.intCustomerStorageId = @intCustomerStorageId AND SV.IsProcessed = 0 AND SV.intItemSort=1
			AND   b.intBillId = @intBillId
			
			UPDATE	bd
			SET  bd.intContractHeaderId= CASE WHEN @strOrderType='Direct' THEN NULL ELSE SV.intContractHeaderId END
				,bd.intContractDetailId=CASE  WHEN @strOrderType='Direct' THEN NULL ELSE SV.intContractDetailId END
			FROM	tblAPBill b 
			JOIN tblAPBillDetail bd ON b.intBillId = bd.intBillId
			JOIN @SettleVoucherCreate SV  ON SV.intItemId=bd.intItemId			
			WHERE SV.intCustomerStorageId = @intCustomerStorageId AND SV.IsProcessed = 0 AND SV.intItemSort=1
			AND   b.intBillId = @intBillId
			
			DELETE tblAPBillDetail WHERE intBillId = @intBillId AND intItemId <> @ItemId  
			DELETE FROM @detailCreated

			-- 1. Adding Other Charges to Voucher Line Item. 
			INSERT INTO tblAPBillDetail
			(
			 intBillId
			,intAccountId
			,intItemId
			,intContractHeaderId
			,intContractDetailId
			,dblTotal
			,dblQtyOrdered
			,dblQtyReceived			
			,dblRate
			,dblCost
			,intCurrencyId
			)			
			SELECT 
			 intBillId = @intBillId 
			,intAccountId = dbo.[fnGetItemGLAccount](SV.intItemId, @intItemLocationId, 'Other Charge Expense')
			,intItemId = SV.intItemId
			,intContractHeaderId = NULL
			,intContractDetailId = NULL
			,dblTotal = @dblUnits * SV.dblCashPrice 					
			,dblQtyOrdered =  CASE WHEN SV.dblCashPrice <0 THEN -1 ELSE 1 END
			,dblQtyReceived = CASE WHEN SV.dblCashPrice <0 THEN -1 ELSE 1 END			
			,dblRate = 0
			,dblCost = @dblUnits * SV.dblCashPrice
			,intCurrencyId = @intCurrencyId
			FROM   @SettleVoucherCreate SV
			WHERE SV.intCustomerStorageId = @intCustomerStorageId AND SV.IsProcessed = 0 AND SV.intItemSort <> 1
			--AND   SV.intItemId NOT IN (SELECT intItemId FROM tblAPBillDetail Where intBillId=@intBillId)
			
			-- 1. Tax recomputation because of the new cost.
			INSERT INTO @detailCreated
			SELECT intBillDetailId FROM tblAPBillDetail WHERE intBillId=@intBillId
			
			EXEC [uspAPUpdateVoucherDetailTax] @detailCreated										
			IF @@ERROR <> 0 GOTO SettleStorage_Exit;
				

			-- Ensure the exchange rate in the voucher has a default value of 1. 
			UPDATE	bd
			SET		bd.dblRate = CASE WHEN ISNULL(bd.dblRate, 0) = 0 THEN 1 ELSE bd.dblRate END 
			FROM	tblAPBillDetail bd
			WHERE	bd.intBillId = @intBillId

			-- Update the vendor order number and voucher total. 
			SET @strStorageTicketNumber=NULL
			SELECT @strStorageTicketNumber= strStorageTicketNumber FROM tblGRCustomerStorage Where intCustomerStorageId=@intCustomerStorageId 			
			
			UPDATE	tblAPBill 
			SET		strVendorOrderNumber = 'STR-'+@strStorageTicketNumber+'/'+strBillId
					,dblTotal = (SELECT SUM(bd.dblTotal) FROM tblAPBillDetail bd WHERE bd.intBillId = @intBillId)
			WHERE	intBillId = @intBillId

			IF @@ERROR <> 0 GOTO SettleStorage_Exit;	
		END 

		-- Auto Post the Voucher 
		IF @intBillId IS NOT NULL 
		BEGIN 
			EXEC [dbo].[uspAPPostBill]
				@post = 1
				,@recap = 0
				,@isBatch = 0
				,@param = @intBillId
				,@userId = @UserKey
				,@success = @success OUTPUT
			IF @@ERROR <> 0 GOTO SettleStorage_Exit;	
		END

		-- Update the grain history. Link the history to the Voucher. 
		BEGIN 
			IF @strOrderType='Direct'
			BEGIN
				UPDATE  SH
				SET		SH.intBillId = @intBillId
				FROM	tblGRStorageHistory SH
				WHERE	SH.strType = 'Settlement' AND SH.intCustomerStorageId = @intCustomerStorageId 
						AND SH.strSettleTicket = @TicketNo
						AND SH.intBillId IS NULL					
						AND SH.intContractHeaderId IS NULL
			END
			ELSE
			BEGIN
				UPDATE  SH
				SET		SH.intBillId = @intBillId
				FROM	tblGRStorageHistory SH 
				JOIN    tblAPBillDetail BD ON BD.intContractHeaderId=SH.intContractHeaderId
				WHERE	SH.strType = 'Settlement' AND SH.intCustomerStorageId = @intCustomerStorageId
						AND SH.strSettleTicket = @TicketNo
						AND SH.intBillId IS NULL
						AND BD.intBillId=@intBillId
						AND SH.intContractHeaderId > 0
					
			END	
			IF @@ERROR <> 0 GOTO SettleStorage_Exit;	
		END 
		
		UPDATE	@SettleVoucherCreate
		SET		IsProcessed = 1
		WHERE	intCustomerStorageId = @intCustomerStorageId 
				AND strOrderType = @strOrderType 
		
		SELECT	@intSettleVoucherKey = MIN(intSettleVoucherKey)
		FROM	@SettleVoucherCreate
		WHERE	intSettleVoucherKey > @intSettleVoucherKey 
				AND IsProcessed = 0 
				AND strOrderType IS NOT NULL		
	END
	
	SettleStorage_Exit: 
	
	EXEC sp_xml_removedocument @idoc
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	IF @idoc <> 0
		EXEC sp_xml_removedocument @idoc
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH