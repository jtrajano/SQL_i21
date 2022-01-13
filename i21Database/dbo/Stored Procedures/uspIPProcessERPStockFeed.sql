CREATE PROCEDURE uspIPProcessERPStockFeed @strInfo1 NVARCHAR(MAX) = '' OUT
	,@strInfo2 NVARCHAR(MAX) = '' OUT
	,@intNoOfRowsAffected INT = 0 OUT
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
		,@strFinalErrMsg NVARCHAR(MAX) = ''
		,@intUserId INT
		,@strError NVARCHAR(MAX)
	DECLARE @intTrxSequenceNo BIGINT
		,@strCompanyLocation NVARCHAR(6)
		,@dtmCreatedDate DATETIME
		,@strCreatedBy NVARCHAR(50)
	DECLARE @intStageLotId INT
		,@strItemNo NVARCHAR(50)
		,@strLotNumber NVARCHAR(50)
		,@strSubLocationName NVARCHAR(50)
		,@strStorageLocationName NVARCHAR(50)
		,@dblNetWeight NUMERIC(38, 20)
		,@strNetWeightUOM NVARCHAR(50)
	DECLARE @intCompanyLocationId INT
		,@intItemId INT
		,@intLotId INT
		,@intSubLocationId INT
		,@intStorageLocationId INT
		,@intNetWeightUnitMeasureId INT
		,@intNetWeightItemUOMId INT
		,@intStockItemUOMId INT
		,@intQtyItemUOMId INT
		,@intOriginId INT
		,@intItemLocationId INT
		,@dblStandardCost NUMERIC(38, 20)
		,@intBatchId INT
		,@intInventoryAdjustmentId INT
		,@dblQty NUMERIC(38, 20)
		,@dblUnitQty NUMERIC(38, 20)
		,@dblOrgQty NUMERIC(38, 20)
		,@dblAdjustByQuantity NUMERIC(38, 20)
	DECLARE @tblLotTable TABLE (
		intLotRecordId INT IDENTITY(1, 1)
		,intItemId INT
		,intLocationId INT
		,intSubLocationId INT
		,intStorageLocationId INT
		)
	DECLARE @tblIPLotStage TABLE (intStageLotId INT)

	INSERT INTO @tblIPLotStage (intStageLotId)
	SELECT intStageLotId
	FROM tblIPLotStage
	WHERE intStatusId IS NULL

	SELECT @intStageLotId = MIN(intStageLotId)
	FROM @tblIPLotStage

	IF @intStageLotId IS NULL
	BEGIN
		RETURN
	END

	UPDATE S
	SET S.intStatusId = - 1
	FROM tblIPLotStage S
	JOIN @tblIPLotStage TS ON TS.intStageLotId = S.intStageLotId

	SELECT @intUserId = intEntityId
	FROM tblSMUserSecurity WITH (NOLOCK)
	WHERE strUserName = 'IRELYADMIN'

	SELECT @strInfo1 = ''
		,@strInfo2 = ''

	SELECT @strInfo1 = @strInfo1 + ISNULL(b.strLotNumber, '') + ', '
	FROM @tblIPLotStage a
	JOIN tblIPLotStage b ON a.intStageLotId = b.intStageLotId

	IF Len(@strInfo1) > 0
	BEGIN
		SELECT @strInfo1 = Left(@strInfo1, Len(@strInfo1) - 1)
	END

	SELECT @strInfo2 = @strInfo2 + ISNULL(strStorageLocationName, '') + ', '
	FROM (
		SELECT DISTINCT b.strStorageLocationName
		FROM @tblIPLotStage a
		JOIN tblIPLotStage b ON a.intStageLotId = b.intStageLotId
		) AS DT

	IF Len(@strInfo2) > 0
	BEGIN
		SELECT @strInfo2 = Left(@strInfo2, Len(@strInfo2) - 1)
	END

	WHILE (@intStageLotId IS NOT NULL)
	BEGIN
		BEGIN TRY
			SELECT @intTrxSequenceNo = NULL
				,@strCompanyLocation = NULL
				,@dtmCreatedDate = NULL
				,@strCreatedBy = NULL

			SELECT @strItemNo = NULL
				,@strLotNumber = NULL
				,@strSubLocationName = NULL
				,@strStorageLocationName = NULL
				,@dblNetWeight = NULL
				,@strNetWeightUOM = NULL

			SELECT @intCompanyLocationId = NULL
				,@intItemId = NULL
				,@intLotId = NULL
				,@intSubLocationId = NULL
				,@intStorageLocationId = NULL
				,@intNetWeightUnitMeasureId = NULL
				,@intNetWeightItemUOMId = NULL
				,@intStockItemUOMId = NULL
				,@intQtyItemUOMId = NULL
				,@intOriginId = NULL
				,@intItemLocationId = NULL
				,@dblStandardCost = NULL
				,@intBatchId = NULL
				,@intInventoryAdjustmentId = NULL
				,@dblQty = NULL
				,@dblUnitQty = NULL
				,@dblOrgQty = NULL
				,@dblAdjustByQuantity = NULL

			SELECT @intTrxSequenceNo = intTrxSequenceNo
				,@strCompanyLocation = strCompanyLocation
				,@dtmCreatedDate = dtmCreatedDate
				,@strCreatedBy = strCreatedBy
				,@strItemNo = strItemNo
				,@strLotNumber = strLotNumber
				,@strSubLocationName = strSubLocationName
				,@strStorageLocationName = strStorageLocationName
				,@dblNetWeight = ISNULL(dblNetWeight, 0)
				,@strNetWeightUOM = strNetWeightUOM
			FROM tblIPLotStage
			WHERE intStageLotId = @intStageLotId

			IF EXISTS (
					SELECT 1
					FROM tblIPLotArchive
					WHERE intTrxSequenceNo = @intTrxSequenceNo
					)
			BEGIN
				SELECT @strError = 'TrxSequenceNo ' + LTRIM(@intTrxSequenceNo) + ' is already processed in i21.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			SELECT @intCompanyLocationId = intCompanyLocationId
			FROM dbo.tblSMCompanyLocation
			WHERE strLotOrigin = @strCompanyLocation

			IF ISNULL(@intCompanyLocationId, 0) = 0
			BEGIN
				RAISERROR (
						'Company Location not found.'
						,16
						,1
						)
			END

			SELECT @intItemId = t.intItemId
				,@intOriginId = t.intOriginId
			FROM tblICItem t WITH (NOLOCK)
			WHERE t.strItemNo = @strItemNo

			IF ISNULL(@intItemId, 0) = 0
			BEGIN
				RAISERROR (
						'Invalid Item No. '
						,16
						,1
						)
			END

			SELECT @intStockItemUOMId = t.intItemUOMId
			FROM tblICItemUOM t WITH (NOLOCK)
			WHERE t.intItemId = @intItemId
				AND t.ysnStockUnit = 1

			SELECT @intItemLocationId = t.intItemLocationId
			FROM tblICItemLocation t WITH (NOLOCK)
			WHERE t.intItemId = @intItemId
				AND t.intLocationId = @intCompanyLocationId

			IF ISNULL(@intItemLocationId, 0) = 0
			BEGIN
				RAISERROR (
						'Invalid Item Location. '
						,16
						,1
						)
			END

			SELECT @dblStandardCost = t.dblStandardCost
			FROM tblICItemPricing t WITH (NOLOCK)
			WHERE t.intItemId = @intItemId
				AND t.intItemLocationId = @intItemLocationId

			IF @dblStandardCost IS NULL
				SELECT @dblStandardCost = 0

			SELECT @intSubLocationId = t.intCompanyLocationSubLocationId
			FROM tblSMCompanyLocationSubLocation t WITH (NOLOCK)
			WHERE t.strSubLocationName = @strSubLocationName
				AND t.intCompanyLocationId = @intCompanyLocationId

			IF ISNULL(@intSubLocationId, 0) = 0
			BEGIN
				RAISERROR (
						'Invalid Sub Location. '
						,16
						,1
						)
			END

			SELECT @intStorageLocationId = t.intStorageLocationId
			FROM tblICStorageLocation t WITH (NOLOCK)
			WHERE t.strName = @strStorageLocationName
				AND t.intSubLocationId = @intSubLocationId

			IF ISNULL(@intStorageLocationId, 0) = 0
			BEGIN
				RAISERROR (
						'Invalid Storage Location. '
						,16
						,1
						)
			END

			--IF @dblNetWeight < 0
			--BEGIN
			--	RAISERROR (
			--			'Invalid Net Weight. '
			--			,16
			--			,1
			--			)
			--END

			SELECT @intNetWeightUnitMeasureId = t.intUnitMeasureId
			FROM tblICUnitMeasure t WITH (NOLOCK)
			WHERE t.strUnitMeasure = @strNetWeightUOM

			IF ISNULL(@intNetWeightUnitMeasureId, 0) = 0
			BEGIN
				RAISERROR (
						'Invalid Net Weight UOM. '
						,16
						,1
						)
			END
			ELSE
			BEGIN
				SELECT @intNetWeightItemUOMId = intItemUOMId
				FROM tblICItemUOM t WITH (NOLOCK)
				WHERE t.intItemId = @intItemId
					AND t.intUnitMeasureId = @intNetWeightUnitMeasureId

				IF ISNULL(@intNetWeightItemUOMId, 0) = 0
				BEGIN
					RAISERROR (
							'Net Weight UOM does not belongs to the Item. '
							,16
							,1
							)
				END
			END

			SELECT @intLotId = L.intLotId
				,@dblOrgQty = L.dblQty
				,@dblQty = ISNULL(dbo.fnMFConvertQuantityToTargetItemUOM(@intNetWeightItemUOMId, L.intItemUOMId, @dblNetWeight), 0)
				,@intQtyItemUOMId = L.intItemUOMId
			FROM tblICLot L WITH (NOLOCK)
			WHERE L.strLotNumber = @strLotNumber
				AND L.intItemId = @intItemId
				AND L.intSubLocationId = @intSubLocationId
				AND L.intStorageLocationId = @intStorageLocationId

			--IF ISNULL(@intLotId, 0) = 0
			--BEGIN
			--	IF @dblNetWeight <= 0
			--	BEGIN
			--		RAISERROR (
			--				'Net Weight cannot be 0. '
			--				,16
			--				,1
			--				)
			--	END
			--END

			BEGIN TRAN

			-- Lot Create / Update
			IF ISNULL(@intLotId, 0) = 0
			BEGIN
				IF ISNULL(@dblNetWeight, 0) = 0
				BEGIN
					GOTO NextRec
				END

				SELECT TOP 1 @dblQty = ISNULL(dbo.fnMFConvertQuantityToTargetItemUOM(@intNetWeightItemUOMId, L.intItemUOMId, @dblNetWeight), 0)
					,@intQtyItemUOMId = L.intItemUOMId
				FROM tblICLot L WITH (NOLOCK)
				WHERE L.strLotNumber = @strLotNumber
					AND L.intItemId = @intItemId
					AND L.intSubLocationId = @intSubLocationId

				IF @dblQty IS NULL
				BEGIN
					SELECT @dblQty = @dblNetWeight
						,@intQtyItemUOMId = @intNetWeightItemUOMId
				END
				
				IF ISNULL(@dblNetWeight, 0) = 0
				BEGIN
					SELECT @dblUnitQty = 0
				END
				ELSE
				BEGIN
					SELECT @dblUnitQty = @dblNetWeight / @dblQty
				END
				
				EXEC uspMFGeneratePatternId @intCategoryId = NULL
					,@intItemId = NULL
					,@intManufacturingId = NULL
					,@intSubLocationId = NULL
					,@intLocationId = @intCompanyLocationId
					,@intOrderTypeId = NULL
					,@intBlendRequirementId = NULL
					,@intPatternCode = 33 -- Transaction Batch Id
					,@ysnProposed = 0
					,@strPatternString = @intBatchId OUTPUT

				EXEC uspMFPostProduction 1
					,0
					,NULL
					,@intItemId
					,@intUserId
					,NULL
					,@intStorageLocationId
					,@dblNetWeight
					,@intNetWeightItemUOMId
					,@dblUnitQty
					,@dblQty
					,@intQtyItemUOMId
					,@strLotNumber
					,@strLotNumber
					,@intBatchId
					,@intLotId OUTPUT
					,NULL
					,NULL
					,@strLotNumber
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,@dblStandardCost
					,'Created from external system'
					,1
					,NULL
					,NULL
					,@intOriginId
			END
			ELSE
			BEGIN
				IF @dblOrgQty <> @dblQty
				BEGIN
					SELECT @dblAdjustByQuantity = @dblQty - @dblOrgQty

					EXEC uspICInventoryAdjustment_CreatePostQtyChange @intItemId = @intItemId
						,@dtmDate = NULL
						,@intLocationId = @intCompanyLocationId
						,@intSubLocationId = @intSubLocationId
						,@intStorageLocationId = @intStorageLocationId
						,@strLotNumber = @strLotNumber
						,@dblAdjustByQuantity = @dblAdjustByQuantity
						,@dblNewUnitCost = NULL
						,@intItemUOMId = @intQtyItemUOMId
						,@intSourceId = 1
						,@intSourceTransactionTypeId = 8
						,@intEntityUserSecurityId = @intUserId
						,@intInventoryAdjustmentId = @intInventoryAdjustmentId OUTPUT
						,@strDescription = 'Adjusted from external system'
				END
			END

			NextRec:

			INSERT INTO tblIPInitialAck (
				intTrxSequenceNo
				,strCompanyLocation
				,dtmCreatedDate
				,strCreatedBy
				,intMessageTypeId
				,intStatusId
				,strStatusText
				)
			SELECT @intTrxSequenceNo
				,@strCompanyLocation
				,@dtmCreatedDate
				,@strCreatedBy
				,16
				,1
				,'Success'

			INSERT INTO tblIPLotArchive (
				intTrxSequenceNo
				,strCompanyLocation
				,dtmCreatedDate
				,strCreatedBy
				,strSubLocationName
				,strItemNo
				,strLotNumber
				,strStorageLocationName
				,dblNetWeight
				,strNetWeightUOM
				)
			SELECT intTrxSequenceNo
				,strCompanyLocation
				,dtmCreatedDate
				,strCreatedBy
				,strSubLocationName
				,strItemNo
				,strLotNumber
				,strStorageLocationName
				,dblNetWeight
				,strNetWeightUOM
			FROM tblIPLotStage
			WHERE intStageLotId = @intStageLotId

			DELETE
			FROM tblIPLotStage
			WHERE intStageLotId = @intStageLotId

			COMMIT TRAN
		END TRY

		BEGIN CATCH
			IF XACT_STATE() != 0
				AND @@TRANCOUNT > 0
				ROLLBACK TRANSACTION

			SET @ErrMsg = ERROR_MESSAGE()
			SET @strFinalErrMsg = @strFinalErrMsg + @ErrMsg

			INSERT INTO tblIPInitialAck (
				intTrxSequenceNo
				,strCompanyLocation
				,dtmCreatedDate
				,strCreatedBy
				,intMessageTypeId
				,intStatusId
				,strStatusText
				)
			SELECT @intTrxSequenceNo
				,@strCompanyLocation
				,@dtmCreatedDate
				,@strCreatedBy
				,16
				,0
				,@ErrMsg

			INSERT INTO tblIPLotError (
				intTrxSequenceNo
				,strCompanyLocation
				,dtmCreatedDate
				,strCreatedBy
				,strSubLocationName
				,strItemNo
				,strLotNumber
				,strStorageLocationName
				,dblNetWeight
				,strNetWeightUOM
				,strErrorMessage
				)
			SELECT intTrxSequenceNo
				,strCompanyLocation
				,dtmCreatedDate
				,strCreatedBy
				,strSubLocationName
				,strItemNo
				,strLotNumber
				,strStorageLocationName
				,dblNetWeight
				,strNetWeightUOM
				,@ErrMsg
			FROM tblIPLotStage
			WHERE intStageLotId = @intStageLotId

			DELETE
			FROM tblIPLotStage
			WHERE intStageLotId = @intStageLotId
		END CATCH

		SELECT @intStageLotId = MIN(intStageLotId)
		FROM @tblIPLotStage
		WHERE intStageLotId > @intStageLotId
	END

	UPDATE S
	SET intStatusId = NULL
	FROM tblIPLotStage S
	JOIN @tblIPLotStage TS ON TS.intStageLotId = S.intStageLotId
	WHERE S.intStatusId = - 1

	IF ISNULL(@strFinalErrMsg, '') <> ''
		RAISERROR (
				@strFinalErrMsg
				,16
				,1
				)
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
