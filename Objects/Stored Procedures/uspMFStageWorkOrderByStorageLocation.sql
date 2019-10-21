Create PROCEDURE uspMFStageWorkOrderByStorageLocation (
	@strXML NVARCHAR(MAX)
	,@intWorkOrderInputLotId INT = NULL OUTPUT
	)
AS
BEGIN TRY
	DECLARE @idoc INT
		,@ErrMsg NVARCHAR(MAX)
		,@intTransactionCount INT
		,@intLocationId INT
		,@intWorkOrderId INT
		,@intStorageLocationId INT
		,@intInputItemId INT
		,@dblRequiredQty NUMERIC(18, 6)
		,@intRequiredItemUOMId INT
		,@dtmCurrentDateTime DATETIME
		,@intLotRecordId INT
		,@ysnPickByLotCode BIT
		,@intLotCodeStartingPosition INT
		,@intLotCodeNoOfDigits INT
		,@intLotId INT
		,@dblQty NUMERIC(18, 6)
		,@intItemUOMId INT
		,@strInputXML NVARCHAR(MAX)

	SELECT @dtmCurrentDateTime = GETDATE()

	DECLARE @tblLot TABLE (
		intLotRecordId INT Identity(1, 1)
		,intLotId INT
		,dblQty NUMERIC(38, 20)
		,intItemUOMId INT
		)

	SELECT @ysnPickByLotCode = ysnPickByLotCode
		,@intLotCodeStartingPosition = intLotCodeStartingPosition
		,@intLotCodeNoOfDigits = intLotCodeNoOfDigits
	FROM tblMFCompanyPreference

	SELECT @intTransactionCount = @@TRANCOUNT

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	SELECT @intLocationId = intLocationId
		,@intStorageLocationId = intStorageLocationId
		,@intInputItemId = intInputItemId
		,@dblRequiredQty = dblQty
		,@intRequiredItemUOMId = intItemUOMId
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intLocationId INT
			,intStorageLocationId INT
			,intInputItemId INT
			,dblQty NUMERIC(38, 20)
			,intItemUOMId INT
			)

	INSERT INTO @tblLot (
		intLotId
		,dblQty
		,intItemUOMId
		)
	SELECT L.intLotId
		,(
			CASE 
				WHEN L.intWeightUOMId IS NOT NULL
					THEN L.dblWeight
				ELSE L.dblQty
				END
			) - ISNULL((
				SELECT SUM(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, ISNULL(L1.intWeightUOMId, L1.intItemUOMId), ISNULL(SR.dblQty, 0)))
				FROM tblICStockReservation SR
				JOIN dbo.tblICLot L1 ON SR.intLotId = L1.intLotId
				WHERE SR.intLotId = L.intLotId
					AND ISNULL(ysnPosted, 0) = 0
				), 0)
		,ISNULL(L.intWeightUOMId, L.intItemUOMId)
	FROM dbo.tblICLot L
	JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId
		AND SL.ysnAllowConsume = 1
		AND L.intItemId = @intInputItemId
		AND L.dblQty > 0
	JOIN dbo.tblICRestriction R ON R.intRestrictionId = IsNULL(SL.intRestrictionId, R.intRestrictionId)
		AND R.strInternalCode = 'STOCK'
	JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
	JOIN dbo.tblMFLotInventory LI ON LI.intLotId = L.intLotId
	JOIN dbo.tblICLotStatus BS ON BS.intLotStatusId = ISNULL(LI.intBondStatusId, 1)
		AND BS.strPrimaryStatus = 'Active'
	JOIN dbo.tblICLotStatus LS ON LS.intLotStatusId = L.intLotStatusId
	JOIN dbo.tblICItem I ON I.intItemId = L.intItemId
	WHERE L.intItemId = @intInputItemId
		AND L.intLocationId = @intLocationId
		AND LS.strPrimaryStatus = 'Active'
		AND ISNULL(L.dtmExpiryDate, @dtmCurrentDateTime) >= @dtmCurrentDateTime
		AND L.intStorageLocationId = @intStorageLocationId
		AND L.dblQty > 0
	ORDER BY CASE 
			WHEN @ysnPickByLotCode = 0
				THEN ISNULL(L.dtmManufacturedDate, L.dtmDateCreated)
			ELSE CONVERT(INT, Substring(PL.strParentLotNumber, @intLotCodeStartingPosition, @intLotCodeNoOfDigits))
			END ASC

	IF @intTransactionCount = 0
		BEGIN TRANSACTION

	SELECT @intLotRecordId = Min(intLotRecordId)
	FROM @tblLot
	WHERE dblQty > 0

	WHILE (@intLotRecordId IS NOT NULL)
		AND @dblRequiredQty > 0
	BEGIN
		SELECT @intLotId = NULL
			,@dblQty = NULL
			,@intItemUOMId = NULL

		SELECT @intLotId = intLotId
			,@dblQty = dblQty
			,@intItemUOMId = intItemUOMId
		FROM @tblLot
		WHERE intLotRecordId = @intLotRecordId

		IF (@dblQty >= [dbo].[fnMFConvertQuantityToTargetItemUOM](@intRequiredItemUOMId, @intItemUOMId, @dblRequiredQty))
		BEGIN
			SELECT @strInputXML = Replace(@strXML, '</root>', '<intInputLotId>' + Ltrim(@intLotId) + '</intInputLotId><dblInputWeight>' + Ltrim(@dblQty) + '</dblInputWeight><intInputWeightUOMId>' + Ltrim(@intItemUOMId) + '</intInputWeightUOMId></root>')

			EXEC [dbo].[uspMFStageWorkOrderByLot] @strXML = @strInputXML
				,@intWorkOrderInputLotId = @intWorkOrderInputLotId OUTPUT

			UPDATE @tblLot
			SET dblQty = dblQty - [dbo].[fnMFConvertQuantityToTargetItemUOM](@intRequiredItemUOMId, @intItemUOMId, @dblRequiredQty)
			WHERE intLotRecordId = @intLotRecordId

			BREAK
		END
		ELSE
		BEGIN
			SELECT @strInputXML = Replace(@strXML, '</root>', '<intInputLotId>' + Ltrim(@intLotId) + '</intInputLotId><dblInputWeight>' + Ltrim(@dblQty) + '</dblInputWeight><intInputWeightUOMId>' + Ltrim(@intItemUOMId) + '</intInputWeightUOMId></root>')

			EXEC [dbo].[uspMFStageWorkOrderByLot] @strXML = @strInputXML
				,@intWorkOrderInputLotId = @intWorkOrderInputLotId OUTPUT

			UPDATE @tblLot
			SET dblQty = 0
			WHERE intLotRecordId = @intLotRecordId

			SELECT @dblRequiredQty = @dblRequiredQty - [dbo].[fnMFConvertQuantityToTargetItemUOM](@intItemUOMId, @intRequiredItemUOMId, @dblQty)
		END

		SELECT @intLotRecordId = Min(intLotRecordId)
		FROM @tblLot
		WHERE dblQty > 0
			AND intLotRecordId > @intLotRecordId
	END

	IF @intTransactionCount = 0
		COMMIT TRANSACTION

	EXEC sp_xml_removedocument @idoc
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	IF XACT_STATE() != 0
		AND @intTransactionCount = 0
		ROLLBACK TRANSACTION

	IF @idoc <> 0
		EXEC sp_xml_removedocument @idoc

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
