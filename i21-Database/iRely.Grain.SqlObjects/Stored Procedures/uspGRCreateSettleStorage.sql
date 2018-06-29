CREATE PROCEDURE [dbo].[uspGRCreateSettleStorage]
	 @intSettleStorageId INT	
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intCreatedUserId INT
	DECLARE @EntityId INT
	DECLARE @ItemId INT
	DECLARE @TicketNo NVARCHAR(20)
	DECLARE @SettleStorageKey INT
	DECLARE @SettleContractKey INT
	DECLARE @intSettleStorageTicketId INT
	DECLARE @intCustomerStorageId INT
	DECLARE @dblStorageUnits DECIMAL(24, 10)
	DECLARE @strProcessType NVARCHAR(30)
	DECLARE @strUpdateType NVARCHAR(30)
	DECLARE @strStorageAdjustment NVARCHAR(50)
	DECLARE @dtmCalculateStorageThrough DATETIME
	DECLARE @dblAdjustPerUnit DECIMAL(24, 10)
	DECLARE @dblStorageDuePerUnit DECIMAL(24, 10)
	DECLARE @dblStorageDueAmount DECIMAL(24, 10)
	DECLARE @dblStorageDueTotalPerUnit DECIMAL(24, 10)
	DECLARE @dblStorageDueTotalAmount DECIMAL(24, 10)
	DECLARE @dblStorageBilledPerUnit DECIMAL(24, 10)
	DECLARE @dblStorageBilledAmount DECIMAL(24, 10)
	DECLARE @dblFlatFeeTotal		DECIMAL(24, 10)
	DECLARE @dblTicketStorageDue DECIMAL(24, 10)
	DECLARE @intContractDetailId INT
	DECLARE @dblContractUnits DECIMAL(24, 10)
	DECLARE @intPricingTypeId INT
	DECLARE @dblContractBasis DECIMAL(24, 10)
	DECLARE @dblCashPrice DECIMAL(24, 10)
	DECLARE @dblSpotUnits DECIMAL(24, 10)
	DECLARE @dblSpotCashPrice DECIMAL(24, 10)
	DECLARE @intSettleVoucherKey INT
	DECLARE @strOrderType NVARCHAR(50)
	DECLARE @dblUnits DECIMAL(24, 10)
	DECLARE @dblUnitsByOrderType DECIMAL(24, 10)
	DECLARE @dblDiscountUnpaid DECIMAL(24, 10)
	DECLARE @dblUnpaidUnits DECIMAL(24, 10)
	DECLARE @dblContractAmount DECIMAL(24, 10)
	DECLARE @NewSettleStorageId INT
	DECLARE @Counter INT
	DECLARE @intItemUOMId INT

	SET @Counter = 1 

	SELECT 
		 @intCreatedUserId			 = intCreatedUserId
		,@EntityId					 = intEntityId
		,@ItemId					 = intItemId
		,@TicketNo				     = strStorageTicket
		,@strStorageAdjustment		 = strStorageAdjustment
		,@dtmCalculateStorageThrough = dtmCalculateStorageThrough
		,@dblAdjustPerUnit			 = dblAdjustPerUnit
		,@dblSpotUnits				 = dblSpotUnits
		,@dblSpotCashPrice			 = dblCashPrice
		,@intItemUOMId				 = intItemUOMId
	FROM tblGRSettleStorage
	WHERE intSettleStorageId = @intSettleStorageId

	SET @strUpdateType = 'estimate'
	SET @strProcessType = CASE 
								WHEN @strStorageAdjustment IN ('No additional','Override') THEN 'Unpaid'
								ELSE 'calculate'
						  END

	DECLARE @SettleStorage AS TABLE 
	(
		 intSettleStorageKey INT IDENTITY(1, 1)
		,intSettleStorageTicketId INT
		,intCustomerStorageId INT
		,dblStorageUnits DECIMAL(24, 10)
		,dblRemainingUnits DECIMAL(24, 10)
	)

	DECLARE @SettleContract AS TABLE 
	(
		intSettleContractKey INT IDENTITY(1, 1)
		,intSettleContractId INT
		,intContractDetailId INT
		,dblContractUnits DECIMAL(24, 10)
		,dblCashPrice DECIMAL(24, 10)
		,intPricingTypeId INT
		,dblBasis DECIMAL(24, 10)
	)
	
	DECLARE @SettleVoucherCreate AS TABLE 
	(
		 intSettleVoucherKey INT IDENTITY(1, 1)
		,strOrderType NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		,intCustomerStorageId INT
		,intContractDetailId INT NULL
		,dblUnits DECIMAL(24, 10)
		,dblCashPrice DECIMAL(24, 10)
		,intItemId INT NULL
		,intItemType INT NULL
		,IsProcessed BIT
		,intTicketDiscountId INT NULL
		,intPricingTypeId INT
		,dblBasis DECIMAL(24, 10)
	)

	INSERT INTO @SettleStorage 
	(
		 intSettleStorageTicketId
		,intCustomerStorageId
		,dblStorageUnits
		,dblRemainingUnits
	)
	SELECT 
		 intSettleStorageTicketId = SST.intSettleStorageTicketId
		,intCustomerStorageId	  = SST.intCustomerStorageId
		,dblStorageUnits		  = SST.dblUnits
		,dblRemainingUnits		  = SST.dblUnits
	FROM tblGRSettleStorageTicket SST	
	WHERE SST.intSettleStorageId = @intSettleStorageId AND SST.dblUnits > 0
	ORDER BY SST.intSettleStorageTicketId

	INSERT INTO @SettleContract 
	(
		 intSettleContractId
		,intContractDetailId
		,dblContractUnits
		,dblCashPrice
		,intPricingTypeId
		,dblBasis
	)
	SELECT 
		 intSettleContractId = SSC.intSettleContractId
		,intContractDetailId = SSC.intContractDetailId
		,dblContractUnits	 = SSC.dblUnits
		,dblCashPrice		 = CD.dblCashPriceInCommodityStockUOM
		,intPricingTypeId	 = CD.intPricingTypeId
		,dblBasis			 = CD.dblBasisInCommodityStockUOM
	FROM tblGRSettleContract SSC
	JOIN vyuGRGetContracts CD ON CD.intContractDetailId = SSC.intContractDetailId
	WHERE intSettleStorageId = @intSettleStorageId AND SSC.dblUnits > 0
	ORDER BY SSC.intSettleContractId

	SELECT @SettleStorageKey = MIN(intSettleStorageKey)
	FROM @SettleStorage
	WHERE dblRemainingUnits > 0

	SET @intSettleStorageTicketId = NULL
	SET @intCustomerStorageId = NULL
	SET @dblStorageUnits = NULL

	WHILE @SettleStorageKey > 0
	BEGIN
		SELECT @intSettleStorageTicketId = intSettleStorageTicketId
			  ,@intCustomerStorageId	 = intCustomerStorageId
			  ,@dblStorageUnits			 = dblRemainingUnits
		FROM @SettleStorage
		WHERE intSettleStorageKey = @SettleStorageKey

		IF EXISTS (
				SELECT 1
				FROM @SettleContract
				WHERE dblContractUnits > 0
				)
		BEGIN
			SELECT @SettleContractKey = MIN(intSettleContractKey)
			FROM @SettleContract
			WHERE dblContractUnits > 0

			SET @intContractDetailId = NULL
			SET @dblContractUnits = NULL
			SET @dblCashPrice = NULL
			SET @intPricingTypeId = NULL

			WHILE @SettleContractKey > 0
			BEGIN
				SELECT 
					 @intContractDetailId = intContractDetailId
					,@dblContractUnits	  = dblContractUnits
					,@dblCashPrice		  = dblCashPrice
					,@intPricingTypeId	  = intPricingTypeId
					,@dblContractBasis	  = dblBasis
				FROM @SettleContract
				WHERE intSettleContractKey = @SettleContractKey

				IF @dblStorageUnits <= @dblContractUnits
				BEGIN
					UPDATE @SettleContract
					SET dblContractUnits = dblContractUnits - @dblStorageUnits
					WHERE intSettleContractKey = @SettleContractKey

					UPDATE @SettleStorage
					SET dblRemainingUnits = 0
					WHERE intSettleStorageKey = @SettleStorageKey

					INSERT INTO @SettleVoucherCreate 
					(
						 intCustomerStorageId
						,strOrderType
						,intContractDetailId
						,dblUnits
						,dblCashPrice
						,intItemId
						,intItemType
						,IsProcessed
						,intPricingTypeId
						,dblBasis
					)
					SELECT 
						 intCustomerStorageId = @intCustomerStorageId
						,strOrderType		  = 'Contract'
						,intContractDetailId  = @intContractDetailId
						,dblUnits			  = @dblStorageUnits
						,dblCashPrice		  = @dblCashPrice
						,intItemId			  = @ItemId
						,intItemType		  = 1
						,IsProcessed		  = 0
						,intPricingTypeId	  = @intPricingTypeId
						,dblBasis			  = @dblContractBasis

					BREAK;
				END
				ELSE
				BEGIN
					UPDATE @SettleContract
					SET dblContractUnits = dblContractUnits - @dblContractUnits
					WHERE intSettleContractKey = @SettleContractKey

					UPDATE @SettleStorage
					SET dblRemainingUnits = dblRemainingUnits - @dblContractUnits
					WHERE intSettleStorageKey = @SettleStorageKey

					INSERT INTO @SettleVoucherCreate 
					(
						 intCustomerStorageId
						,strOrderType
						,intContractDetailId
						,dblUnits
						,dblCashPrice
						,intItemId
						,intItemType
						,IsProcessed
						,intPricingTypeId
						,dblBasis
					)
					SELECT 
						 intCustomerStorageId = @intCustomerStorageId
						,strOrderType		  = 'Contract'
						,intContractDetailId  = @intContractDetailId
						,dblUnits			  = @dblContractUnits
						,dblCashPrice		  = @dblCashPrice
						,intItemId			  = @ItemId
						,intItemType		  = 1
						,IsProcessed		  = 0
						,intPricingTypeId	  = @intPricingTypeId
						,dblBasis			  = @dblContractBasis

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
				SET dblRemainingUnits = dblRemainingUnits - @dblStorageUnits
				WHERE intSettleStorageKey = @SettleStorageKey

				SET @dblSpotUnits = @dblSpotUnits - @dblStorageUnits

				INSERT INTO @SettleVoucherCreate 
				(
					 intCustomerStorageId
					,strOrderType
					,intContractDetailId
					,dblUnits
					,dblCashPrice
					,intItemId
					,intItemType
					,IsProcessed
				)
				SELECT 
					 intCustomerStorageId = @intCustomerStorageId
					,strOrderType		  = 'Direct'
					,intContractDetailId  = NULL
					,dblUnits			  = @dblStorageUnits
					,dblCashPrice		  = @dblSpotCashPrice
					,intItemId			  = @ItemId
					,intItemType		  = 1
					,IsProcessed		  = 0
			END
			ELSE
			BEGIN
				UPDATE @SettleStorage
				SET dblRemainingUnits = dblRemainingUnits - @dblSpotUnits
				WHERE intSettleStorageKey = @SettleStorageKey

				INSERT INTO @SettleVoucherCreate 
				(
					 intCustomerStorageId
					,strOrderType
					,intContractDetailId
					,dblUnits
					,dblCashPrice
					,intItemId
					,intItemType
					,IsProcessed
				)
				SELECT 
					 intCustomerStorageId = @intCustomerStorageId
					,strOrderType		  = 'Direct'
					,intContractDetailId  = NULL
					,dblUnits			  = @dblSpotUnits
					,dblCashPrice		  = @dblSpotCashPrice
					,intItemId			  = @ItemId
					,intItemType		  = 1
					,IsProcessed		  = 0

				SET @dblSpotUnits = 0
			END

			SELECT @SettleStorageKey = MIN(intSettleStorageKey)
			FROM @SettleStorage
			WHERE intSettleStorageKey >= @SettleStorageKey AND dblRemainingUnits > 0
		END
		ELSE
			BREAK;
	END

	SELECT @intSettleVoucherKey = MIN(intSettleVoucherKey)
	FROM @SettleVoucherCreate
	WHERE IsProcessed = 0

	WHILE @intSettleVoucherKey > 0
	BEGIN
		SET @intCustomerStorageId = NULL
		SET @strOrderType = NULL
		SET @dblUnits = NULL
		SET @dblDiscountUnpaid = NULL

		SELECT 
			 @intCustomerStorageId = intCustomerStorageId
			,@strOrderType		   = strOrderType
			,@dblUnits			   = dblUnits
		FROM @SettleVoucherCreate
		WHERE intSettleVoucherKey = @intSettleVoucherKey

		SELECT @dblDiscountUnpaid = dblDiscountUnPaid
		FROM vyuGRGetStorageTransferTicket
		WHERE intCustomerStorageId = @intCustomerStorageId

		IF @strOrderType = 'Direct'
		BEGIN
			SET @dblStorageDuePerUnit = 0
			SET @dblStorageDueAmount = 0
			SET @dblStorageDueTotalPerUnit = 0
			SET @dblStorageDueTotalAmount = 0
			SET @dblStorageBilledPerUnit = 0
			SET @dblStorageBilledAmount = 0
			SET @dblFlatFeeTotal = 0
			SET @dblTicketStorageDue = 0

			EXEC uspGRCalculateStorageCharge 
				 @strProcessType
				,@strUpdateType
				,@intCustomerStorageId
				,NULL
				,NULL
				,@dblUnits
				,@dtmCalculateStorageThrough
				,@intCreatedUserId
				,0
				,NULL
				,@dblStorageDuePerUnit OUTPUT
				,@dblStorageDueAmount OUTPUT
				,@dblStorageDueTotalPerUnit OUTPUT
				,@dblStorageDueTotalAmount OUTPUT
				,@dblStorageBilledPerUnit OUTPUT
				,@dblStorageBilledAmount OUTPUT
				,@dblFlatFeeTotal OUTPUT

			IF @strStorageAdjustment = 'Override'
				SET @dblTicketStorageDue = @dblAdjustPerUnit + @dblStorageDuePerUnit + @dblStorageDueTotalPerUnit - @dblStorageBilledPerUnit
			ELSE
				SET @dblTicketStorageDue = @dblStorageDuePerUnit + @dblStorageDueTotalPerUnit - @dblStorageBilledPerUnit

			INSERT INTO tblGRSettleStorage 
			(
				 intConcurrencyId
				,intEntityId
				,intCompanyLocationId
				,intItemId
				,dblSpotUnits
				,dblFuturesPrice
				,dblFuturesBasis
				,dblCashPrice
				,strStorageAdjustment
				,dtmCalculateStorageThrough
				,dblAdjustPerUnit
				,dblStorageDue
				,strStorageTicket
				,dblSelectedUnits
				,dblUnpaidUnits
				,dblSettleUnits
				,dblDiscountsDue
				,dblNetSettlement
				,ysnPosted
				,intCommodityId
				,intCommodityStockUomId
				,intCreatedUserId
				,intBillId
				,dtmCreated
				,intParentSettleStorageId
				,intItemUOMId
			)
			SELECT 
				 intConcurrencyId			= 1
				,intEntityId				= intEntityId
				,intCompanyLocationId		= intCompanyLocationId
				,intItemId					= intItemId
				,dblSpotUnits				= @dblUnits
				,dblFuturesPrice			= dblFuturesPrice
				,dblFuturesBasis			= dblFuturesBasis
				,dblCashPrice				= dblCashPrice
				,strStorageAdjustment		= strStorageAdjustment
				,dtmCalculateStorageThrough = dtmCalculateStorageThrough
				,dblAdjustPerUnit		    = dblAdjustPerUnit
				,dblStorageDue				= @dblTicketStorageDue * @dblUnits + ISNULL(@dblFlatFeeTotal,0)
				,strStorageTicket			= strStorageTicket + '/' + LTRIM(@Counter)
				,dblSelectedUnits			= @dblUnits
				,dblUnpaidUnits				= 0
				,dblSettleUnits				= @dblUnits
				,dblDiscountsDue			= @dblDiscountUnpaid * @dblUnits
				,dblNetSettlement			= (@dblUnits * dblCashPrice) - (@dblTicketStorageDue*@dblUnits) - (@dblDiscountUnpaid * @dblUnits)-ISNULL(@dblFlatFeeTotal,0)
				,ysnPosted					= 0
				,intCommodityId				= intCommodityId
				,intCommodityStockUomId		= intCommodityStockUomId
				,intCreatedUserId			= intCreatedUserId
				,intBillId					= NULL
				,dtmCreated					= dtmCreated
				,intParentSettleStorageId	= @intSettleStorageId
				,intItemUOMId				= @intItemUOMId
			FROM tblGRSettleStorage
			WHERE intSettleStorageId = @intSettleStorageId

			SET @NewSettleStorageId = SCOPE_IDENTITY()

			INSERT INTO tblGRSettleStorageTicket 
			(
				 intConcurrencyId
				,intSettleStorageId
				,intCustomerStorageId
				,dblUnits
			)
			SELECT 
				 intConcurrencyId		= 1
				,intSettleStorageId		= @NewSettleStorageId
				,intCustomerStorageId	= @intCustomerStorageId
				,dblUnits				= @dblUnits
		END
		ELSE IF @strOrderType = 'Contract'
		BEGIN
			
			SELECT @dblUnitsByOrderType = SUM(dblUnits)
			FROM @SettleVoucherCreate
			WHERE intCustomerStorageId = @intCustomerStorageId AND strOrderType = @strOrderType

			SELECT @dblUnpaidUnits = ISNULL(SUM(dblUnits),0)
			FROM @SettleVoucherCreate
			WHERE intCustomerStorageId = @intCustomerStorageId AND strOrderType = @strOrderType AND intPricingTypeId <> 1

			SELECT @dblContractAmount = ISNULL(SUM(dblUnits*dblCashPrice),0)
			FROM @SettleVoucherCreate
			WHERE intCustomerStorageId = @intCustomerStorageId AND strOrderType = @strOrderType AND intPricingTypeId = 1
			

			SET @dblStorageDuePerUnit = 0
			SET @dblStorageDueAmount = 0
			SET @dblStorageDueTotalPerUnit = 0
			SET @dblStorageDueTotalAmount = 0
			SET @dblStorageBilledPerUnit = 0
			SET @dblStorageBilledAmount = 0
			SET @dblFlatFeeTotal = 0
			SET @dblTicketStorageDue = 0

			EXEC uspGRCalculateStorageCharge 
				 @strProcessType
				,@strUpdateType
				,@intCustomerStorageId
				,NULL
				,NULL
				,@dblUnitsByOrderType
				,@dtmCalculateStorageThrough
				,@intCreatedUserId
				,0
				,NULL
				,@dblStorageDuePerUnit OUTPUT
				,@dblStorageDueAmount OUTPUT
				,@dblStorageDueTotalPerUnit OUTPUT
				,@dblStorageDueTotalAmount OUTPUT
				,@dblStorageBilledPerUnit OUTPUT
				,@dblStorageBilledAmount OUTPUT
				,@dblFlatFeeTotal OUTPUT

			IF @strStorageAdjustment = 'Override'
				SET @dblTicketStorageDue = @dblAdjustPerUnit + @dblStorageDuePerUnit + @dblStorageDueTotalPerUnit - @dblStorageBilledPerUnit
			ELSE
				SET @dblTicketStorageDue = @dblStorageDuePerUnit + @dblStorageDueTotalPerUnit - @dblStorageBilledPerUnit

			INSERT INTO tblGRSettleStorage 
			(
				 intConcurrencyId
				,intEntityId
				,intCompanyLocationId
				,intItemId
				,dblSpotUnits
				,dblFuturesPrice
				,dblFuturesBasis
				,dblCashPrice
				,strStorageAdjustment
				,dtmCalculateStorageThrough
				,dblAdjustPerUnit
				,dblStorageDue
				,strStorageTicket
				,dblSelectedUnits
				,dblUnpaidUnits
				,dblSettleUnits
				,dblDiscountsDue
				,dblNetSettlement
				,ysnPosted
				,intCommodityId
				,intCommodityStockUomId
				,intCreatedUserId
				,intBillId
				,dtmCreated
				,intParentSettleStorageId
				,intItemUOMId
				)
			SELECT 
				 intConcurrencyId				= 1
				,intEntityId					= intEntityId
				,intCompanyLocationId			= intCompanyLocationId
				,intItemId						= intItemId
				,dblSpotUnits					= 0
				,dblFuturesPrice				= 0
				,dblFuturesBasis				= 0
				,dblCashPrice					= 0
				,strStorageAdjustment			= strStorageAdjustment
				,dtmCalculateStorageThrough		= dtmCalculateStorageThrough
				,dblAdjustPerUnit				= dblAdjustPerUnit
				,dblStorageDue					= @dblTicketStorageDue*@dblUnitsByOrderType + ISNULL(@dblFlatFeeTotal,0)
				,strStorageTicket				= strStorageTicket + '/' + LTRIM(@Counter)
				,dblSelectedUnits				= @dblUnitsByOrderType
				,dblUnpaidUnits					= @dblUnpaidUnits
				,dblSettleUnits					= @dblUnitsByOrderType - @dblUnpaidUnits
				,dblDiscountsDue				= @dblDiscountUnpaid * (@dblUnitsByOrderType - @dblUnpaidUnits)
				,dblNetSettlement				= @dblContractAmount - (@dblTicketStorageDue*@dblUnitsByOrderType) - (@dblDiscountUnpaid * (@dblUnitsByOrderType - @dblUnpaidUnits)) - ISNULL(@dblFlatFeeTotal,0)
				,ysnPosted						= 0
				,intCommodityId					= intCommodityId
				,intCommodityStockUomId			= intCommodityStockUomId
				,intCreatedUserId				= intCreatedUserId
				,intBillId						= NULL
				,dtmCreated						= dtmCreated
				,intParentSettleStorageId		= @intSettleStorageId
				,intItemUOMId					= @intItemUOMId
			FROM tblGRSettleStorage
			WHERE intSettleStorageId = @intSettleStorageId

			SET @NewSettleStorageId = SCOPE_IDENTITY()

			INSERT INTO tblGRSettleStorageTicket 
			(
				 intConcurrencyId
				,intSettleStorageId
				,intCustomerStorageId
				,dblUnits
			)
			SELECT 
				 intConcurrencyId	    = 1
				,intSettleStorageId		= @NewSettleStorageId
				,intCustomerStorageId   = @intCustomerStorageId
				,dblUnits				= @dblUnitsByOrderType

			INSERT INTO tblGRSettleContract 
			(
				 intConcurrencyId
				,intSettleStorageId
				,intContractDetailId
				,dblUnits
			)
			SELECT 
				 intConcurrencyId	    = 1
				,intSettleStorageId		= @NewSettleStorageId
				,intContractDetailId	= intContractDetailId
				,dblUnits				= dblUnits
			FROM @SettleVoucherCreate
			WHERE intCustomerStorageId = @intCustomerStorageId AND strOrderType = @strOrderType

		END

		SET @Counter = @Counter + 1 
		UPDATE @SettleVoucherCreate
		SET IsProcessed = 1
		WHERE intCustomerStorageId = @intCustomerStorageId AND strOrderType = @strOrderType

		SELECT @intSettleVoucherKey = MIN(intSettleVoucherKey)
		FROM @SettleVoucherCreate
		WHERE intSettleVoucherKey > @intSettleVoucherKey AND IsProcessed = 0

	END
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH
