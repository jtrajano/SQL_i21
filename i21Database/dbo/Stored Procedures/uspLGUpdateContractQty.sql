CREATE PROCEDURE uspLGUpdateContractQty @intLoadId INT
	,@intLoadDetailId INT = NULL
	,@dblScheduleQtyToUpdate NUMERIC(18, 6) = NULL
AS
BEGIN TRY
	DECLARE @strErrMsg NVARCHAR(100)
	DECLARE @intShipmentType INT
	DECLARE @intPurchaseSale INT
	DECLARE @intPContractDetailId INT
	DECLARE @intSContractDetailId INT
	DECLARE @dblQuantity NUMERIC(18, 6)
	DECLARE @intItemUOMId INT
	DECLARE @dblNet NUMERIC(18, 6)
	DECLARE @intWeightItemUOMId INT
	DECLARE @intMinRecordId INT
	DECLARE @intUserId INT
	DECLARE @tblLoadDetail TABLE (
		intRecordId INT IDENTITY
		,intLoadId INT
		,intLoadDetailId INT
		,intPContractDetailId INT
		,intSContractDetailId INT
		,dblQuantity NUMERIC(18, 6)
		,intItemUOMId INT
		,dblNet NUMERIC(18, 6)
		,intWeightItemUOMId INT
		)

	INSERT INTO @tblLoadDetail (
		intLoadId
		,intLoadDetailId
		,intPContractDetailId
		,intSContractDetailId
		,dblQuantity
		,intItemUOMId
		,dblNet
		,intWeightItemUOMId
		)
	SELECT intLoadId
		,intLoadDetailId
		,intPContractDetailId
		,intSContractDetailId
		,CASE 
			WHEN @intLoadDetailId IS NULL
				THEN dblQuantity
			ELSE @dblScheduleQtyToUpdate
			END
		,intItemUOMId
		,dblNet
		,intWeightItemUOMId
	FROM tblLGLoadDetail
	WHERE intLoadId = @intLoadId
		AND intLoadDetailId = IsNULL(@intLoadDetailId, intLoadDetailId)

	SELECT @intShipmentType = intShipmentType
		,@intPurchaseSale = intPurchaseSale
		,@intUserId = intUserSecurityId
	FROM tblLGLoad
	WHERE intLoadId = @intLoadId

	SELECT @intMinRecordId = MIN(intRecordId)
	FROM @tblLoadDetail

	WHILE ISNULL(@intMinRecordId, 0) > 0
	BEGIN
		SET @intPContractDetailId = NULL
		SET @intSContractDetailId = NULL
		SET @dblQuantity = NULL
		SET @intItemUOMId = NULL
		SET @dblNet = NULL
		SET @intWeightItemUOMId = NULL
		SET @intLoadDetailId = NULL

		SELECT @intPContractDetailId = intPContractDetailId
			,@intSContractDetailId = intSContractDetailId
			,@dblQuantity = dblQuantity
			,@intItemUOMId = intItemUOMId
			,@dblNet = dblNet
			,@intWeightItemUOMId = intWeightItemUOMId
			,@intLoadDetailId = intLoadDetailId
		FROM @tblLoadDetail
		WHERE intRecordId = @intMinRecordId

		IF (@intShipmentType = 2)
		BEGIN
			IF (@intPContractDetailId > 0)
			BEGIN
				EXEC uspLGUpdateContractShippingInstructionQty @intContractDetailId = @intPContractDetailId
					,@dblQuantityToUpdate = @dblQuantity
					,@intUserId = @intUserId
			END

			IF (@intSContractDetailId > 0)
			BEGIN
				EXEC uspLGUpdateContractShippingInstructionQty @intContractDetailId = @intSContractDetailId
					,@dblQuantityToUpdate = @dblQuantity
					,@intUserId = @intUserId
			END
		END
		ELSE
		BEGIN
			IF (@intPContractDetailId > 0)
			BEGIN
				EXEC [uspCTUpdateScheduleQuantityUsingUOM] @intContractDetailId = @intPContractDetailId
					,@dblQuantityToUpdate = @dblQuantity
					,@intUserId = @intUserId
					,@intExternalId = @intLoadDetailId
					,@strScreenName = 'Load Schedule'
					,@intSourceItemUOMId = @intItemUOMId
			END

			IF (@intSContractDetailId > 0)
			BEGIN
				EXEC [uspCTUpdateScheduleQuantityUsingUOM] @intContractDetailId = @intSContractDetailId
					,@dblQuantityToUpdate = @dblQuantity
					,@intUserId = @intUserId
					,@intExternalId = @intLoadDetailId
					,@strScreenName = 'Load Schedule'
					,@intSourceItemUOMId = @intItemUOMId
			END
		END

		SELECT @intMinRecordId = MIN(intRecordId)
		FROM @tblLoadDetail
		WHERE intRecordId > @intMinRecordId
	END
END TRY

BEGIN CATCH
	SET @strErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@strErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
