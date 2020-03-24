CREATE PROCEDURE [dbo].[uspGRCreateSettleStorage]
@intSettleStorageId INT	
AS
BEGIN TRY
	SET NOCOUNT ON
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intSettleStorageKey INT
	DECLARE @intCustomerStorageId INT
	DECLARE @dblRemainingUnits DECIMAL(18,6)
	DECLARE @dblRemainingSpotUnits DECIMAL(18,6)
	DECLARE @dblContractRemainingUnits DECIMAL(18,6)
	DECLARE @intContractDetailId INT
	DECLARE @intContractPricingTypeId INT
	DECLARE @dblCashPrice DECIMAL(18,6)
	DECLARE @intCompanyLocationId INT
	DECLARE @intNewSettleStorageId INT
	DECLARE @intSettleContractId INT
	DECLARE @dblFutures DECIMAL(18,6)
	DECLARE @dblBasis DECIMAL(18,6)
	DECLARE @dblSpotCashPrice DECIMAL(18,6)
	DECLARE @dblTotalUnitsForSettle DECIMAL(18,6)
	DECLARE @strType NVARCHAR(20)

	DECLARE @SettleStorageToSave AS TABLE 
	(
		intSettleStorageKey INT IDENTITY(1, 1)
		,intCustomerStorageId INT
		,dblSpotUnits DECIMAL(18,6)
		,dblFutures DECIMAL(18,6)
		,dblBasis DECIMAL(18,6)
		,dblSpotCashPrice DECIMAL(18,6)
		,intContractDetailId INT
		,dblContractUnits DECIMAL(18,6)
		,dblCashPrice DECIMAL(18,6)
		,intContractPricingTypeId INT
		,isSaved BIT
	)

	DECLARE @MainSettleStorageToSave AS TABLE 
	(
		intSettleStorageKey INT IDENTITY(1, 1)
		,intCustomerStorageId INT
		,dblSpotUnits DECIMAL(18,6)
		,dblContractUnits DECIMAL(18,6)
		,intContractDetailId INT --for basis contract only
		,strType NVARCHAR(20)
	)

	DECLARE @SettleStorage AS TABLE 
	(
		intSettleStorageKey INT IDENTITY(1, 1)
		,intSettleStorageTicketId INT
		,intCustomerStorageId INT
		,dblRemainingUnits DECIMAL(18,6)
		,dblRemainingSpotUnits DECIMAL(18,6)
		,dblFutures DECIMAL(18,6)
		,dblBasis DECIMAL(18,6)
		,dblCashPrice DECIMAL(18,6)
	)

	DECLARE @SettleContract AS TABLE 
	(	
		intSettleContractId INT
		,intContractDetailId INT
		,dblContractRemaningUnits DECIMAL(18,6)
		,dblCashPrice DECIMAL(18,6)
		,intPricingTypeId INT
	)

	INSERT INTO @SettleStorage
	(
		 intSettleStorageTicketId
		,intCustomerStorageId
		,dblRemainingUnits
		,dblRemainingSpotUnits
		,dblFutures
		,dblBasis
		,dblCashPrice
	)
	SELECT 
		 intSettleStorageTicketId	= SST.intSettleStorageTicketId
		,intCustomerStorageId		= SST.intCustomerStorageId
		,dblRemainingUnits			= SST.dblUnits
		,dblRemainingSpotUnits		= SS.dblSpotUnits
		,dblFutures					= SS.dblFuturesPrice
		,dblBasis					= SS.dblFuturesBasis
		,dblCashPrice				= SS.dblCashPrice
	FROM tblGRSettleStorageTicket SST
	INNER JOIN tblGRSettleStorage SS
		ON SS.intSettleStorageId = SST.intSettleStorageId
	WHERE SS.intSettleStorageId = @intSettleStorageId

	INSERT INTO @SettleContract 
	(
		intSettleContractId
		,intContractDetailId
		,dblContractRemaningUnits
		,dblCashPrice
		,intPricingTypeId
	)
	SELECT
		intSettleContractId			= intSettleContractId
		,intContractDetailId		= SSC.intContractDetailId
		,dblContractRemaningUnits	= SSC.dblUnits
		,dblCashPrice				= CASE WHEN ISNULL(CD.dblCashPrice,0) > 0 THEN CD.dblCashPrice ELSE ISNULL(CD.dblBasis,0) + ISNULL(CD.dblFutures,0) END
		,intPricingTypeId			= CD.intPricingTypeId
	FROM tblGRSettleContract SSC
	INNER JOIN tblCTContractDetail CD
		ON CD.intContractDetailId = SSC.intContractDetailId
	WHERE intSettleStorageId = @intSettleStorageId

	WHILE EXISTS(SELECT TOP 1 1 FROM @SettleStorage)
	BEGIN
		SET @intSettleStorageKey = NULL
		SET @intCustomerStorageId = NULL
		SET @dblRemainingUnits = NULL
		SET @dblRemainingSpotUnits = NULL		


		SELECT TOP 1
			@intSettleStorageKey		= intSettleStorageKey
			,@intCustomerStorageId		= intCustomerStorageId
			,@dblRemainingUnits			= dblRemainingUnits
			,@dblRemainingSpotUnits		= dblRemainingSpotUnits
			,@dblFutures				= dblFutures
			,@dblBasis					= dblBasis
			,@dblSpotCashPrice			= dblCashPrice
		FROM @SettleStorage
		ORDER BY intSettleStorageKey

		--LOOP THRU CONTRACTS
		WHILE EXISTS(SELECT TOP 1 1 FROM @SettleContract)
		BEGIN 
			SET @dblContractRemainingUnits = NULL
			SET @intContractDetailId = NULL
			SET @intContractPricingTypeId = NULL
			SET @dblCashPrice = NULL

			SELECT @dblRemainingUnits = dblRemainingUnits FROM @SettleStorage WHERE intSettleStorageKey = @intSettleStorageKey

			SELECT TOP 1 
				@intSettleContractId		= intSettleContractId
				,@intContractDetailId		= intContractDetailId
				,@dblContractRemainingUnits	= dblContractRemaningUnits
				,@intContractPricingTypeId	= intPricingTypeId
				,@dblCashPrice				= dblCashPrice
			FROM @SettleContract
			ORDER BY intSettleContractId
			
			IF ISNULL(@dblRemainingUnits,0) > 0
			BEGIN
				IF ISNULL(@dblContractRemainingUnits,0) > 0
				BEGIN
					INSERT INTO @SettleStorageToSave
					(
						intCustomerStorageId
						,dblSpotUnits
						,dblFutures
						,dblBasis
						,dblSpotCashPrice
						,intContractDetailId
						,dblContractUnits
						,dblCashPrice
						,intContractPricingTypeId
						,isSaved
					)
					SELECT
						intCustomerStorageId		= @intCustomerStorageId
						,dblSpotUnits				= 0
						,dblFutures					= 0
						,dblBasis					= 0
						,dblSpotCashPrice			= 0
						,intContractDetailId		= @intContractDetailId
						,dblContractUnits			= CASE 
														WHEN ISNULL(@dblRemainingUnits,0) >= ISNULL(@dblContractRemainingUnits,0) THEN @dblContractRemainingUnits
														ELSE @dblRemainingUnits
													END
						,dblCashPrice				= @dblCashPrice
						,intContractPricingTypeId	= @intContractPricingTypeId
						,0
				END
				UPDATE @SettleStorage
				SET dblRemainingUnits = @dblRemainingUnits - @dblContractRemainingUnits
				WHERE intCustomerStorageId = @intCustomerStorageId

				UPDATE @SettleContract
				SET dblContractRemaningUnits = @dblContractRemainingUnits - (CASE 
													WHEN ISNULL(@dblRemainingUnits,0) >= ISNULL(@dblContractRemainingUnits,0) THEN @dblContractRemainingUnits
													ELSE @dblRemainingUnits
												END)
				WHERE intSettleContractId = @intSettleContractId

				IF @dblContractRemainingUnits = 0
				BEGIN
					DELETE FROM @SettleContract WHERE intSettleContractId = @intSettleContractId
				END
			END
			ELSE
			BEGIN
				BREAK;
			END
		END
		
		--SPOT UNITS
		IF ISNULL(@dblRemainingUnits,0) > 0 AND ISNULL(@dblRemainingSpotUnits,0) > 0
		BEGIN
			SELECT TOP 1 @dblRemainingUnits	= dblRemainingUnits FROM @SettleStorage WHERE intSettleStorageKey = @intSettleStorageKey

			INSERT INTO @SettleStorageToSave
			(
				intCustomerStorageId
				,dblSpotUnits
				,dblFutures
				,dblBasis
				,dblSpotCashPrice
				,intContractDetailId
				,dblContractUnits
				,dblCashPrice
				,intContractPricingTypeId
				,isSaved
			)
			SELECT
				intCustomerStorageId		= @intCustomerStorageId
				,dblSpotUnits				= CASE 
												WHEN @dblRemainingUnits >= @dblRemainingSpotUnits THEN @dblRemainingSpotUnits
												ELSE @dblRemainingUnits
											END
				,dblFutures					= @dblFutures
				,dblBasis					= @dblBasis
				,dblSpotCashPrice			= @dblSpotCashPrice
				,intContractDetailId		= 0
				,dblContractUnits			= 0
				,dblCashPrice				= 0
				,intContractPricingTypeId	= -1
				,0
				
			UPDATE @SettleStorage
			SET dblRemainingUnits = @dblRemainingUnits - @dblRemainingSpotUnits
			WHERE intCustomerStorageId = @intCustomerStorageId
		END

		IF ISNULL(@dblRemainingUnits,0) <= 0 or ISNULL(@dblRemainingUnits,0) <= 0.01
		BEGIN
			DELETE FROM @SettleStorage WHERE intCustomerStorageId = @intCustomerStorageId
		END
	END

	--WILL BE SAVED ONLY IN tblGRSettleStorage
	INSERT INTO @MainSettleStorageToSave
	--PRICED and CASH contracts
	SELECT 
		intCustomerStorageId
		,0
		,dblContractUnits = SUM(dblContractUnits)
		,0
		,'Priced'
	FROM @SettleStorageToSave
	WHERE intContractPricingTypeId IN (1,6)
	GROUP BY intCustomerStorageId
	UNION
	--BASIS CONTRACT
	SELECT 
		intCustomerStorageId
		,0
		,dblContractUnits
		,intContractDetailId
		,'Basis'
	FROM @SettleStorageToSave
	WHERE intContractPricingTypeId = 2
	UNION
	--SPOT
	SELECT 
		intCustomerStorageId
		,dblSpotUnits
		,0
		,0
		,'Spot'
	FROM @SettleStorageToSave
	WHERE intContractPricingTypeId = -1

	--START SAVING THE SETTLEMENTS IN TABLES
	WHILE EXISTS(SELECT TOP 1 1 FROM @MainSettleStorageToSave)
	BEGIN
		SET @intCustomerStorageId = NULL
		SET @dblTotalUnitsForSettle = NULL
		SET @strType = NULL
		SET @intSettleStorageKey = NULL
		SET @intNewSettleStorageId = NULL
		SET @intContractDetailId = NULL

		SELECT TOP 1
			@intSettleStorageKey		= intSettleStorageKey
			,@intCustomerStorageId		= intCustomerStorageId
			,@dblTotalUnitsForSettle	= CASE WHEN dblContractUnits > 0 THEN dblContractUnits ELSE dblSpotUnits END
			,@strType					= strType
			,@intContractDetailId		= intContractDetailId
		FROM @MainSettleStorageToSave
		ORDER BY intSettleStorageKey		

		--ALWAYS GET THE COMPANY LOCATION SINCE IT'S NOT REQUIRED
		SELECT @intCompanyLocationId = intCompanyLocationId FROM tblGRCustomerStorage WHERE intCustomerStorageId = @intCustomerStorageId

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
			,dtmCreated
			,intParentSettleStorageId
			,intItemUOMId
		)
		SELECT 
			intConcurrencyId			= 1
			,intEntityId				= intEntityId
			,intCompanyLocationId		= @intCompanyLocationId
			,intItemId					= intItemId
			,dblSpotUnits				= CASE WHEN @strType = 'Spot' THEN @dblTotalUnitsForSettle ELSE 0 END
			,dblFuturesPrice			= CASE WHEN @strType = 'Spot' THEN dblFuturesPrice ELSE 0 END
			,dblFuturesBasis			= CASE WHEN @strType = 'Spot' THEN dblFuturesBasis ELSE 0 END
			,dblCashPrice				= CASE WHEN @strType = 'Spot' THEN dblCashPrice ELSE 0 END
			,strStorageAdjustment		= strStorageAdjustment
			,dtmCalculateStorageThrough = dtmCalculateStorageThrough
			,dblAdjustPerUnit		    = dblAdjustPerUnit
			,dblStorageDue				= (@dblTotalUnitsForSettle / dblSelectedUnits) * dblStorageDue
			,strStorageTicket			= strStorageTicket + '/' + LTRIM(@intSettleStorageKey)
			,dblSelectedUnits			= @dblTotalUnitsForSettle
			,dblUnpaidUnits				= CASE WHEN @strType = 'Basis' THEN @dblTotalUnitsForSettle ELSE 0 END
			,dblSettleUnits				= CASE WHEN @strType <> 'Basis' THEN @dblTotalUnitsForSettle ELSE 0 END
			,dblDiscountsDue			= (@dblTotalUnitsForSettle / dblSelectedUnits) * dblDiscountsDue
			,dblNetSettlement			= (@dblTotalUnitsForSettle / dblSelectedUnits) * dblNetSettlement
			,ysnPosted					= 0
			,intCommodityId				= intCommodityId
			,intCommodityStockUomId		= intCommodityStockUomId
			,intCreatedUserId			= intCreatedUserId
			,dtmCreated					= dtmCreated
			,intParentSettleStorageId	= @intSettleStorageId
			,intItemUOMId				= intItemUOMId
		FROM tblGRSettleStorage
		WHERE intSettleStorageId = @intSettleStorageId

		SET @intNewSettleStorageId = SCOPE_IDENTITY()

		IF @strType <> 'Spot'
		BEGIN
			IF @intContractDetailId > 0 --BASIS
			BEGIN
				INSERT INTO tblGRSettleContract 
				(
					 intConcurrencyId
					,intSettleStorageId
					,intContractDetailId
					,dblUnits
				)
				SELECT 
					 intConcurrencyId	    = 1
					,intSettleStorageId		= @intNewSettleStorageId
					,intContractDetailId	= @intContractDetailId
					,dblUnits				= @dblTotalUnitsForSettle
				FROM @SettleStorageToSave SS
				WHERE intCustomerStorageId = @intCustomerStorageId 
					AND intContractDetailId = @intContractDetailId
			END
			ELSE --PRICED, CASH
			BEGIN
				INSERT INTO tblGRSettleContract 
				(
					 intConcurrencyId
					,intSettleStorageId
					,intContractDetailId
					,dblUnits
				)
				SELECT 
					 intConcurrencyId	    = 1
					,intSettleStorageId		= @intNewSettleStorageId
					,intContractDetailId	= SS.intContractDetailId
					,dblUnits				= SS.dblContractUnits
				FROM @SettleStorageToSave SS
				WHERE intCustomerStorageId = @intCustomerStorageId 
					AND intContractPricingTypeId IN (1,6)
			END
		END

		INSERT INTO tblGRSettleStorageTicket 
		(
			intConcurrencyId
			,intSettleStorageId
			,intCustomerStorageId
			,dblUnits
		)
		SELECT 
			intConcurrencyId	    = 1
			,intSettleStorageId		= @intNewSettleStorageId
			,intCustomerStorageId   = @intCustomerStorageId
			,dblUnits				= @dblTotalUnitsForSettle

		DELETE FROM @MainSettleStorageToSave WHERE intSettleStorageKey = @intSettleStorageKey
	END

	
	DELETE FROM @MainSettleStorageToSave
	DELETE FROM @SettleStorageToSave
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH