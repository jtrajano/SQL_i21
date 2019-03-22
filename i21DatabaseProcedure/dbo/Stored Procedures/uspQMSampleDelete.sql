CREATE PROCEDURE uspQMSampleDelete @intSampleId INT
	,@intUserId INT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(Max)
	DECLARE @ysnEnableParentLot BIT
		,@intSampleTypeId INT
		,@dblSampleQty NUMERIC(18, 6)
		,@intLotId INT
		,@dblQty NUMERIC(18, 6)
		,@intItemUOMId INT
		,@intStorageLocationId INT
		,@strLotNumber NVARCHAR(50)
		,@intSampleUOMId INT
		,@intItemId INT
		,@intSampleItemUOMId INT
		,@strReasonCode NVARCHAR(50)
		,@strSampleNumber NVARCHAR(50)
		,@dtmBusinessDate DATETIME
		,@ysnAdjustInventoryQtyBySampleQty Bit

	SELECT @dtmBusinessDate = GETDATE()

	SELECT TOP 1 @ysnEnableParentLot = ISNULL(ysnEnableParentLot, 0)
	FROM tblQMCompanyPreference

	SELECT @intSampleTypeId = intSampleTypeId
		,@dblSampleQty = dblSampleQty
		,@strLotNumber = strLotNumber
		,@intStorageLocationId = intStorageLocationId
		,@intItemId = intItemId
		,@intSampleUOMId = intSampleUOMId
		,@strSampleNumber = strSampleNumber
		,@ysnAdjustInventoryQtyBySampleQty=IsNULL(ysnAdjustInventoryQtyBySampleQty,0)
	FROM tblQMSample
	WHERE intSampleId = @intSampleId

	IF @ysnEnableParentLot = 1
		RETURN;

	IF @ysnAdjustInventoryQtyBySampleQty=1
		AND ISNULL(@dblSampleQty, 0) > 0
		AND @ysnEnableParentLot = 0 AND ISNULL(@strLotNumber, '') <> '' -- Lot
	BEGIN
		SELECT @intLotId = intLotId
			,@dblQty = dblQty
			,@intItemUOMId = intItemUOMId
		FROM tblICLot
		WHERE strLotNumber = @strLotNumber
			AND intStorageLocationId = @intStorageLocationId

		SELECT @intSampleItemUOMId = intItemUOMId
		FROM tblICItemUOM
		WHERE intItemId = @intItemId
			AND intUnitMeasureId = @intSampleUOMId

		IF @intSampleItemUOMId IS NULL
		BEGIN
			RAISERROR (
					'Sample quantity UOM is not configured for the selected item. '
					,16
					,1
					)
		END

		SELECT @dblSampleQty = dbo.fnMFConvertQuantityToTargetItemUOM(@intSampleItemUOMId, @intItemUOMId, @dblSampleQty)

		IF @dblSampleQty > @dblQty
		BEGIN
			RAISERROR (
					'Sample quantity cannot be greater than lot / pallet quantity. '
					,16
					,1
					)
		END

		SELECT @dblQty = @dblQty + @dblSampleQty

		SELECT @strReasonCode = 'Sample Quantity - ' + @strSampleNumber

		EXEC [uspMFLotAdjustQty] @intLotId = @intLotId
			,@dblNewLotQty = @dblQty
			,@intAdjustItemUOMId = @intItemUOMId
			,@intUserId = @intUserId
			,@strReasonCode = @strReasonCode
			,@blnValidateLotReservation = 0
			,@strNotes = NULL
			,@dtmDate = @dtmBusinessDate
			,@ysnBulkChange = 0
	END
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
