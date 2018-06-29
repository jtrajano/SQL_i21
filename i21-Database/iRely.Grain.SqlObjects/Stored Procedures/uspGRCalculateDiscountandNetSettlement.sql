CREATE PROCEDURE [dbo].[uspGRCalculateDiscountandNetSettlement]
	 @strSettleData NVARCHAR(MAX)
	,@dblTotalDiscountAmount DECIMAL(24, 10) OUTPUT
	,@dblNetSettlement DECIMAL(24, 10) OUTPUT
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @idoc INT
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @SettleStorageKey INT
	DECLARE @dblStorageUnits DECIMAL(24, 10)
	DECLARE @dblDiscountUnPaid DECIMAL(24, 10)
	
	DECLARE @SettleContractKey INT
	DECLARE @intContractDetailId INT
	DECLARE @intPricingTypeId INT
	DECLARE @dblContractUnits DECIMAL(24, 10)
	DECLARE @dblCashPrice DECIMAL(24, 10)
	
	DECLARE @dblSpotUnits DECIMAL(24, 10)
	DECLARE @dblSpotPrice DECIMAL(24, 10)
	DECLARE @dblSpotBasis DECIMAL(24, 10)
	DECLARE @dblSpotCashPrice DECIMAL(24, 10)

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strSettleData

	DECLARE @SettleStorage AS TABLE 
	(
		 intSettleStorageKey INT IDENTITY(1, 1)
		,dblStorageUnits DECIMAL(24, 10)
		,dblRemainingUnits DECIMAL(24, 10)
		,dblDiscountUnPaid DECIMAL(24, 10)
	)

	DECLARE @SettleContract AS TABLE 
	(
		 intSettleContractKey INT IDENTITY(1, 1)
		,intContractDetailId INT
		,intPricingTypeId INT
		,dblContractUnits DECIMAL(24, 10)
		,dblCashPrice DECIMAL(24, 10)
	)
	
	DECLARE @SettleVoucherCreate AS TABLE 
	(
		 intSettleVoucherKey INT IDENTITY(1, 1)
		,intSettleStorageKey INT
		,dblStorageUnits DECIMAL(24, 10)
		,dblDiscountUnPaid DECIMAL(24, 10)
	)

	INSERT INTO @SettleStorage 
	(
		 dblStorageUnits
		,dblRemainingUnits
		,dblDiscountUnPaid
	)
	SELECT 
	 dblUnits
	,dblUnits
	,dblDiscountUnPaid
	FROM OPENXML(@idoc, 'root/SettleStorage', 2) WITH 
	(
	   dblUnits DECIMAL(24, 10)
	  ,dblDiscountUnPaid DECIMAL(24, 10)
	)

	INSERT INTO @SettleContract 
	(
		 intContractDetailId
		,intPricingTypeId
		,dblContractUnits
		,dblCashPrice
	)
	SELECT 
		 intContractDetailId
		,intPricingTypeId
		,dblUnits
		,dblCashPrice
	FROM OPENXML(@idoc, 'root/SettleContract', 2) WITH 
	(
			 intContractDetailId INT
			,intPricingTypeId INT
			,dblUnits DECIMAL(24, 10)
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
		
	SELECT @SettleStorageKey = MIN(intSettleStorageKey)
	FROM @SettleStorage
	WHERE dblRemainingUnits > 0

	SET @dblStorageUnits = NULL
	SET @dblDiscountUnPaid = NULL

	WHILE @SettleStorageKey > 0
	BEGIN
		SELECT 
			 @dblStorageUnits = dblRemainingUnits
			,@dblDiscountUnPaid = dblDiscountUnPaid
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

			WHILE @SettleContractKey > 0
			BEGIN
				SELECT 
					 @intContractDetailId = intContractDetailId
					,@intPricingTypeId = intPricingTypeId
					,@dblContractUnits = dblContractUnits
					,@dblCashPrice = dblCashPrice
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
						 intSettleStorageKey
						,dblStorageUnits
						,dblDiscountUnPaid
					)
					SELECT 
						 @SettleStorageKey
						,@dblStorageUnits
						,CASE 
							WHEN @intPricingTypeId = 1 THEN @dblDiscountUnPaid
							ELSE 0
						 END

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
						 intSettleStorageKey
						,dblStorageUnits
						,dblDiscountUnPaid
					)
					SELECT 
						 @SettleStorageKey
						,@dblContractUnits
						,CASE 
							WHEN @intPricingTypeId = 1 THEN @dblDiscountUnPaid
							ELSE 0
						 END

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
					 intSettleStorageKey
					,dblStorageUnits
					,dblDiscountUnPaid
				)
				SELECT 
					 @SettleStorageKey
					,@dblStorageUnits
					,@dblDiscountUnPaid
			END
			ELSE
			BEGIN
				UPDATE @SettleStorage
				SET dblRemainingUnits = dblRemainingUnits - @dblSpotUnits
				WHERE intSettleStorageKey = @SettleStorageKey

				INSERT INTO @SettleVoucherCreate 
				(
					 intSettleStorageKey
					,dblStorageUnits
					,dblDiscountUnPaid
				)
				SELECT 
					 @SettleStorageKey
					,@dblSpotUnits
					,@dblDiscountUnPaid

				SET @dblSpotUnits = 0
			END

			SELECT @SettleStorageKey = MIN(intSettleStorageKey)
			FROM @SettleStorage
			WHERE intSettleStorageKey >= @SettleStorageKey AND dblRemainingUnits > 0
		END
		ELSE
			BREAK;
	END

	SELECT @dblTotalDiscountAmount = SUM(dblStorageUnits * dblDiscountUnPaid)
	FROM @SettleVoucherCreate

	SELECT @dblNetSettlement = 0

	SELECT 
		   1 AS intSettleDiscountKey
		  ,ISNULL(@dblTotalDiscountAmount, 0) AS dblTotalDiscountAmount
		  ,@dblNetSettlement AS dblNetSettlement

	EXEC sp_xml_removedocument @idoc
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	IF @idoc <> 0
		EXEC sp_xml_removedocument @idoc
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')

END CATCH

