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
	DECLARE @FeeItemId INT
	DECLARE @strFeeItem NVARCHAR(40)
	DECLARE @intCurrencyId INT
	DECLARE @intDefaultCurrencyId INT
	DECLARE @intItemLocationId INT
	DECLARE @strOrderType NVARCHAR(50)
	DECLARE @dblUnits DECIMAL(24, 10)
	DECLARE @intShipFromId INT
	DECLARE @dblUOMQty NUMERIC(38,20)

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
	
	SET @intCurrencyId = ISNULL((SELECT intCurrencyId FROM tblAPVendor WHERE intEntityVendorId = @EntityId), @intDefaultCurrencyId)
	
	SET @strUpdateType = 'estimate'
	SET @strProcessType = CASE WHEN @strStorageAdjustment IN ('No additional','Override') THEN 'Unpaid' ELSE 'calculate' END

	SELECT @UserName = strUserName
	FROM tblSMUserSecurity
	WHERE intEntityUserSecurityId = @UserKey --Another Hiccup

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
	SELECT TOP 1 @intShipFromId=intShipFromId 
	FROM tblAPVendor 
	WHERE intEntityVendorId =@EntityId
	 
	SELECT @ItemDescription = strItemNo
	FROM tblICItem
	WHERE intItemId = @ItemId
		
	SELECT @FeeItemId=intItemId FROM tblGRCompanyPreference
	SELECT @strFeeItem=strItemNo FROM tblICItem WHERE intItemId=@FeeItemId

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

	SELECT @intSourceItemUOMId = intItemUOMId,@dblUOMQty=UOM.dblUnitQty
	FROM tblICItemUOM UOM
	WHERE intItemId = @ItemId AND intUnitMeasureId = @intUnitMeasureId

	SELECT @SettleStorageKey = MIN(intSettleStorageKey)
	FROM @SettleStorage
	WHERE dblRemainingUnits > 0

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
			,@dblStorageUnits = dblRemainingUnits
			,@dblOpenBalance = dblOpenBalance
			,@strStorageTicketNumber = strStorageTicketNumber
			,@intCompanyLocationId = intCompanyLocationId
			,@intStorageTypeId = intStorageTypeId
			,@intStorageScheduleId = intStorageScheduleId
			,@DPContractHeaderId = CASE WHEN dblStorageUnits = dblRemainingUnits THEN intContractHeaderId ELSE 0 END
		FROM @SettleStorage
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
		
		IF NOT EXISTS (SELECT 1 FROM @SettleVoucherCreate WHERE intCustomerStorageId = @intCustomerStorageId AND intItemId =@FeeItemId AND intItemSort = 4)
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

					UPDATE @SettleStorage
					SET dblRemainingUnits = 0
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
		   ,@ReceiptStagingTable ReceiptStagingTable 
		   ,@OtherCharges ReceiptOtherChargesTableType 
		   ,@intReceiptId AS INT
		   ,@intBillId AS INT 
		   ,@strReceiptNumber AS NVARCHAR(50)
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
		
		SELECT @LocationId = intCompanyLocationId,@intCustomerStorageId=intCustomerStorageId,@strOrderType=strOrderType
		FROM   @SettleVoucherCreate
		WHERE intSettleVoucherKey = @intSettleVoucherKey
		
		SELECT @intItemLocationId=intItemLocationId FROM tblICItemLocation WHERE intItemId=@ItemId AND intLocationId=@LocationId
		
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
		 SV.[intItemId]
		,@intItemLocationId	
		,@intSourceItemUOMId
		,GetDATE()
		,-SV.[dblUnits]
		,SV.[dblUnits]	
		,SV.[dblCashPrice]
		,0.00
		,@intDefaultCurrencyId
		,1
		,1
		,SV.[intCustomerStorageId]
		,@strStorageAdjustment
		,4
		,CS.intCompanyLocationSubLocationId
		,CS.intStorageLocationId
		,1
		FROM @SettleVoucherCreate SV
		JOIN tblGRCustomerStorage CS ON CS.intCustomerStorageId = SV.intCustomerStorageId
		JOIN tblGRStorageType St ON St.intStorageScheduleTypeId=CS.intStorageTypeId AND St.ysnDPOwnedType=0
		WHERE SV.intCustomerStorageId=@intCustomerStorageId AND SV.intItemSort=1 AND SV.IsProcessed = 0 AND SV.strOrderType=@strOrderType   
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
		  intItemId  = SV.[intItemId]
		 ,intItemLocationId	= @intItemLocationId	
		 ,intItemUOMId  = @intSourceItemUOMId
		 ,dtmDate  = GetDATE()
		 ,dblQty  = -SV.[dblUnits]
		 ,dblUOMQty  = @dblUOMQty
		 ,dblCost  = 0
		 ,dblSalesPrice = 0.00
		 ,intCurrencyId  = @intDefaultCurrencyId
		 ,dblExchangeRate  = 1
		 ,intTransactionId  = SV.[intCustomerStorageId]
		 ,intTransactionDetailId = SV.[intCustomerStorageId]
		 ,strTransactionId  = @TicketNo
		 ,intTransactionTypeId = 44
		 ,intSubLocationId  = CS.intCompanyLocationSubLocationId
		 ,intStorageLocationId = CS.intStorageLocationId
		 ,ysnIsStorage = 0 
		FROM @SettleVoucherCreate SV
		JOIN tblGRCustomerStorage CS ON CS.intCustomerStorageId = SV.intCustomerStorageId
		JOIN tblGRStorageType St ON St.intStorageScheduleTypeId=CS.intStorageTypeId AND St.ysnDPOwnedType=1
		WHERE SV.intCustomerStorageId=@intCustomerStorageId AND SV.intItemSort=1 AND SV.IsProcessed = 0 AND SV.strOrderType=@strOrderType     
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

		-- Create the temp table used by uspICAddItemReceipt
		IF NOT EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpAddItemReceiptResult')) 
		BEGIN 
			CREATE TABLE #tmpAddItemReceiptResult (
				intSourceId INT
				,intInventoryReceiptId INT
			)
		END
			
		BEGIN
			DELETE FROM @ReceiptStagingTable
			DELETE FROM @OtherCharges
						
			INSERT INTO @ReceiptStagingTable
			(
				 strReceiptType
				,intEntityVendorId
				,intShipFromId
				,intLocationId
				,intItemId
				,intItemLocationId
				,intItemUOMId
				,strBillOfLadding
				,intContractHeaderId
				,intContractDetailId
				,dtmDate
				,intShipViaId
				,dblQty
				,dblCost
				,intCurrencyId
				,dblExchangeRate
				,intLotId
				,intSubLocationId
				,intStorageLocationId
				,ysnIsStorage
				,dblFreightRate
				,intSourceId	
				,intSourceType		 	
				,dblGross
				,dblNet
				,intInventoryReceiptId
				,dblSurcharge
				,ysnFreightInPrice
				,strActualCostId
				,intTaxGroupId
				,strVendorRefNo
				,strSourceId
				,strSourceScreenName
			)	
			
			SELECT 
				 strReceiptType				= @strOrderType 
				,intEntityVendorId			= @EntityId
				,intShipFromId				= @intShipFromId
				,intLocationId				= SV.intCompanyLocationId
				,intItemId					= SV.[intItemId]
				,intItemLocationId			= @intItemLocationId
				,intItemUOMId				= @intSourceItemUOMId	   
				,strBillOfLadding			= NULL
				,intContractHeaderId		= SV.[intContractHeaderId]
				,intContractDetailId		= SV.[intContractDetailId]
				,dtmDate					= GetDate()
				,intShipViaId				= NULL
				,dblQty						= SV.[dblUnits]
				,dblCost					= SV.[dblCashPrice]
				,intCurrencyId				= @intCurrencyId
				,dblExchangeRate			= 1 
				,intLotId					= NULL
				,intSubLocationId			= NULL
				,intStorageLocationId		= NULL
				,ysnIsStorage				= 0 
				,dblFreightRate				= 0
				,intSourceId				= SV.[intCustomerStorageId]
				,intSourceType		 		= 4
				,dblGross					= SV.[dblUnits]
				,dblNet						= SV.[dblUnits]
				,intInventoryReceiptId		= NULL
				,dblSurcharge				= 0
				,ysnFreightInPrice			= 0
				,strActualCostId			= NULL 											
				,intTaxGroupId				= NULL
				,strVendorRefNo				= NULL
				,strSourceId				= NULL
				,strSourceScreenName		= 'Settle Storage'
			FROM @SettleVoucherCreate SV
			WHERE SV.intCustomerStorageId=@intCustomerStorageId  AND SV.IsProcessed = 0 AND SV.intItemSort=1 AND SV.strOrderType=@strOrderType ORDER BY intSettleVoucherKey 
			
			SELECT @dblUnits=SUM(dblUnits) FROM @SettleVoucherCreate SV
			WHERE SV.intCustomerStorageId=@intCustomerStorageId  AND SV.IsProcessed = 0 AND SV.intItemSort=1 AND SV.strOrderType=@strOrderType
			
			INSERT INTO @OtherCharges
			(
				[intEntityVendorId] 
				,[strBillOfLadding] 
				,[strReceiptType] 
				,[intLocationId] 
				,[intShipViaId] 
				,[intShipFromId] 
				,[intCurrencyId]  	
				,[intChargeId] 
				,[ysnInventoryCost] 
				,[strCostMethod] 
				,[dblRate] 
				,[intCostUOMId] 
				,[intOtherChargeEntityVendorId] 
				,[dblAmount] 
				,[strAllocateCostBy] 
				,[intContractHeaderId]
				,[intContractDetailId] 
				,[ysnAccrue]
				,[ysnPrice]
			) 
		    SELECT	
		     [intEntityVendorId]				= @EntityId
			,[strBillOfLadding]					= NULL
			,[strReceiptType]					= @strOrderType
			,[intLocationId]					= SV.intCompanyLocationId
			,[intShipViaId]						= NULL
			,[intShipFromId]					= @intShipFromId
			,[intCurrencyId]  					= @intCurrencyId
			,[intChargeId]						= SV.[intItemId]
			,[ysnInventoryCost]					= 0
			,[strCostMethod]					= Item.strCostMethod--'Amount'
			,[dblRate]							= ABS(SV.[dblCashPrice])
			,[intCostUOMId]						= Item.intCostUOMId
			,[intOtherChargeEntityVendorId]		= NULL
			,[dblAmount]						= ABS(SV.[dblCashPrice])* CASE 
																		    WHEN SV.intItemSort = 3 THEN dbo.fnGRCalculateDiscountUnit(@intCustomerStorageId,SV.intTicketDiscountId,@dblUnits)
																			ELSE @dblUnits 
																		  END
			,[strAllocateCostBy]				= 'Unit'
			,[intContractHeaderId]				= SV.[intContractHeaderId]
			,[intContractDetailId]				= SV.[intContractDetailId]
			,[ysnAccrue]						= CASE WHEN SV.[dblCashPrice] < 0 THEN 0 ELSE 1 END
			,[ysnPrice]							= CASE WHEN SV.[dblCashPrice] < 0 THEN 1 ELSE 0 END
			FROM @SettleVoucherCreate SV
			JOIN tblICItem Item ON Item.intItemId = SV.[intItemId]
			WHERE SV.intCustomerStorageId=@intCustomerStorageId  AND SV.IsProcessed = 0 AND SV.intItemSort <> 1  ORDER BY intSettleVoucherKey

			EXEC dbo.uspICAddItemReceipt 
				 @ReceiptStagingTable
				,@OtherCharges
				,@UserKey;
			IF @@ERROR <> 0 GOTO SettleStorage_Exit;
		END
		  
		IF EXISTS (SELECT TOP 1 1 FROM #tmpAddItemReceiptResult)
		BEGIN 
			SELECT TOP 1 
					@strReceiptNumber = strReceiptNumber
					,@intReceiptId = r.intInventoryReceiptId
			FROM	#tmpAddItemReceiptResult result INNER JOIN tblICInventoryReceipt r
						ON result.intInventoryReceiptId = r.intInventoryReceiptId
						
			IF @intReceiptId IS NOT NULL 
			BEGIN
									
			EXEC uspICPostInventoryReceipt 
					  @ysnPost = 1
					, @ysnRecap = 0
					, @strTransactionId = @strReceiptNumber
					, @intEntityUserSecurityId = @UserKey
				IF @@ERROR <> 0 GOTO SettleStorage_Exit;

			END
			
			IF @intReceiptId IS NOT NULL 
			BEGIN 
				EXEC uspICProcessToBill 
						@intReceiptId
						, @UserKey
						, @intBillId OUTPUT 
						
				UPDATE tblAPBill SET strVendorOrderNumber=@TicketNo WHERE intBillId=@intBillId
				
				UPDATE SH
				SET  SH.intInventoryReceiptId = @intReceiptId
					,SH.intBillId = @intBillId
				FROM tblGRStorageHistory SH
				JOIN tblICInventoryReceiptItem RL ON RL.intSourceId = SH.intCustomerStorageId
				JOIN tblICInventoryReceipt RH ON RH.intInventoryReceiptId = RL.intInventoryReceiptId AND ISNULL(RL.intOrderId,0)=ISNULL(SH.intContractHeaderId,0)
				WHERE SH.strType = 'Settlement' AND SH.strSettleTicket = @TicketNo AND RH.intInventoryReceiptId = @intReceiptId	
				
				IF @@ERROR <> 0 GOTO SettleStorage_Exit;	
			END 
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

			
			DELETE FROM #tmpAddItemReceiptResult
			WHERE	intInventoryReceiptId = @intReceiptId
		END 
		
		UPDATE @SettleVoucherCreate
		SET IsProcessed = 1
		WHERE intCustomerStorageId=@intCustomerStorageId AND strOrderType=@strOrderType 
		
		SELECT @intSettleVoucherKey = MIN(intSettleVoucherKey)
		FROM @SettleVoucherCreate
		WHERE intSettleVoucherKey > @intSettleVoucherKey AND IsProcessed = 0 AND strOrderType IS NOT NULL
		
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