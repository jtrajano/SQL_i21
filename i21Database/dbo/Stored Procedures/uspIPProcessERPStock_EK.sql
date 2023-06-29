CREATE PROCEDURE uspIPProcessERPStock_EK @strInfo1 NVARCHAR(MAX) = '' OUT
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
		,@strContainerNo NVARCHAR(50) = NULL
		,@strMarkings NVARCHAR(50) = NULL
		,@intEntityVendorId INT = NULL
		,@strCondition NVARCHAR(50) = NULL
		,@strCertificate NVARCHAR(50) = NULL
		,@strCertificateId NVARCHAR(50) = NULL
		,@intContractHeaderId INT = NULL -- Contract Header Id
		,@intContractDetailId INT = NULL
		,@strLotAlias NVARCHAR(50) = NULL
		,@dtmExpiryDate DATETIME
	DECLARE @intTrxSequenceNo BIGINT
		,@strLocationName NVARCHAR(6)
	DECLARE @intStageLotId INT
		,@strItemNo NVARCHAR(50)
		,@strLotNumber NVARCHAR(50)
		,@strSubLocationName NVARCHAR(50)
		,@strStorageLocationName NVARCHAR(50)
		,@dblQuantity NUMERIC(38, 20)
		,@strQuantityUOM NVARCHAR(50)
		,@dblNetWeight NUMERIC(38, 20)
		,@strNetWeightUOM NVARCHAR(50)
		,@dblCost NUMERIC(38, 20)
		,@strCostUOM NVARCHAR(50)
		,@strCostCurrency NVARCHAR(50)
		,@dblAllocatedQty NUMERIC(38, 20)
		,@stri21SubLocationName NVARCHAR(100)
		,@strLocation NVARCHAR(50)
	DECLARE @intCompanyLocationId INT
		,@intItemId INT
		,@intLotId INT
		,@intSubLocationId INT
		,@intStorageLocationId INT
		,@intNetWeightUnitMeasureId INT
		,@intNetWeightItemUOMId INT
		,@intCostUnitMeasureId INT
		,@intCostItemUOMId INT
		,@intCostCurrencyId INT
		,@intDefaultCurrencyId INT
		,@intStockItemUOMId INT
		,@intQtyItemUOMId INT
		,@intQtyUnitMeasureId INT
		,@intOriginId INT
		,@intItemLocationId INT
		,@intBatchId INT
		,@intInventoryAdjustmentId INT
		,@dblQty NUMERIC(38, 20)
		,@dblUnitQty NUMERIC(38, 20)
		,@dblOrgQty NUMERIC(38, 20)
		,@dblAdjustByQuantity NUMERIC(38, 20)
		,@dblNewCost NUMERIC(38, 20)
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

	SELECT @strInfo2 = @strInfo2 + ISNULL(strSubLocationName, '') + ', '
	FROM (
		SELECT DISTINCT b.strSubLocationName
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
				,@strLocationName = NULL

			SELECT @strItemNo = NULL
				,@strLotNumber = NULL
				,@strSubLocationName = NULL
				,@strStorageLocationName = NULL
				,@dblQuantity = NULL
				,@strQuantityUOM = NULL
				,@dblNetWeight = NULL
				,@strNetWeightUOM = NULL
				,@dblCost = NULL
				,@strCostUOM = NULL
				,@strCostCurrency = NULL
				,@dblAllocatedQty = NULL
				,@stri21SubLocationName = NULL
				,@strLocation = NULL

			SELECT @intCompanyLocationId = NULL
				,@intItemId = NULL
				,@intLotId = NULL
				,@intSubLocationId = NULL
				,@intStorageLocationId = NULL
				,@intNetWeightUnitMeasureId = NULL
				,@intNetWeightItemUOMId = NULL
				,@intCostUnitMeasureId = NULL
				,@intCostItemUOMId = NULL
				,@intCostCurrencyId = NULL
				,@intDefaultCurrencyId = NULL
				,@intStockItemUOMId = NULL
				,@intQtyItemUOMId = NULL
				,@intQtyUnitMeasureId = NULL
				,@intOriginId = NULL
				,@intItemLocationId = NULL
				,@intBatchId = NULL
				,@intInventoryAdjustmentId = NULL
				,@dblQty = NULL
				,@dblUnitQty = NULL
				,@dblOrgQty = NULL
				,@dblAdjustByQuantity = NULL
				,@dblNewCost = NULL

			SELECT @intTrxSequenceNo = intTrxSequenceNo
				,@strLocationName = strLocationName
				,@strSubLocationName = strSubLocationName
				,@strStorageLocationName = strStorageLocationName
				,@strLotNumber = strLotNumber
				,@strItemNo = strItemNo
				,@dblQuantity = ISNULL(dblQuantity, 0)
				,@strQuantityUOM = strQuantityUOM
				,@dblNetWeight = ISNULL(dblNetWeight, 0)
				,@strNetWeightUOM = strNetWeightUOM
				,@dblCost = ISNULL(dblCost, 0)
				,@strCostUOM = strCostUOM
				,@strCostCurrency = strCostCurrency
				,@dblAllocatedQty = dblAllocatedQty
			FROM tblIPLotStage
			WHERE intStageLotId = @intStageLotId

			SELECT @intCompanyLocationId = intCompanyLocationId
				,@strLocation = strLocationName
			FROM dbo.tblSMCompanyLocation WITH (NOLOCK)
			WHERE strVendorRefNoPrefix = @strLocationName
				AND strLocationType = 'Plant'

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

			SELECT @stri21SubLocationName = @strLocation + ' / ' + @strSubLocationName

			SELECT @intSubLocationId = t.intCompanyLocationSubLocationId
			FROM tblSMCompanyLocationSubLocation t WITH (NOLOCK)
			WHERE t.strSubLocationName = @stri21SubLocationName
				AND t.intCompanyLocationId = @intCompanyLocationId

			IF ISNULL(@intSubLocationId, 0) = 0
			BEGIN
				SELECT @intSubLocationId = t.intCompanyLocationSubLocationId
				FROM tblSMCompanyLocationSubLocation t WITH (NOLOCK)
				WHERE t.strSubLocationName = @strSubLocationName
					AND t.intCompanyLocationId = @intCompanyLocationId
			End

			IF ISNULL(@intSubLocationId, 0) = 0
			BEGIN
				RAISERROR (
						'Invalid Storage Location. '
						,16
						,1
						)
			END

			IF ISNULL(@strStorageLocationName, '') <> ''
			BEGIN
				SELECT @intStorageLocationId = t.intStorageLocationId
				FROM tblICStorageLocation t WITH (NOLOCK)
				WHERE t.strName = @strStorageLocationName
					AND t.intSubLocationId = @intSubLocationId

				IF ISNULL(@intStorageLocationId, 0) = 0
				BEGIN
					RAISERROR (
							'Invalid Storage Unit. '
							,16
							,1
							)
				END
			END
			ELSE
			BEGIN
				SELECT TOP 1 @intStorageLocationId = t.intStorageLocationId
				FROM tblICStorageLocation t WITH (NOLOCK)
				WHERE t.intSubLocationId = @intSubLocationId
					AND t.strName = 'SU'

				IF ISNULL(@intStorageLocationId, 0) = 0
				BEGIN
					RAISERROR (
							'Default Storage Unit is not configured. '
							,16
							,1
							)
				END
			END

			SELECT @intQtyUnitMeasureId = t.intUnitMeasureId
			FROM tblICUnitMeasure t WITH (NOLOCK)
			WHERE t.strUnitMeasure = @strQuantityUOM

			IF ISNULL(@intQtyUnitMeasureId, 0) = 0
			BEGIN
				RAISERROR (
						'Invalid Quantity UOM. '
						,16
						,1
						)
			END
			ELSE
			BEGIN
				SELECT @intQtyItemUOMId = intItemUOMId
				FROM tblICItemUOM t WITH (NOLOCK)
				WHERE t.intItemId = @intItemId
					AND t.intUnitMeasureId = @intQtyUnitMeasureId

				IF ISNULL(@intQtyItemUOMId, 0) = 0
				BEGIN
					RAISERROR (
							'Quantity UOM does not belongs to the Item. '
							,16
							,1
							)
				END
			END

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

			SELECT @intCostUnitMeasureId = t.intUnitMeasureId
			FROM tblICUnitMeasure t WITH (NOLOCK)
			WHERE t.strUnitMeasure = @strCostUOM

			IF ISNULL(@intCostUnitMeasureId, 0) = 0
			BEGIN
				RAISERROR (
						'Invalid Cost UOM. '
						,16
						,1
						)
			END
			ELSE
			BEGIN
				SELECT @intCostItemUOMId = intItemUOMId
				FROM tblICItemUOM t WITH (NOLOCK)
				WHERE t.intItemId = @intItemId
					AND t.intUnitMeasureId = @intCostUnitMeasureId

				IF ISNULL(@intCostItemUOMId, 0) = 0
				BEGIN
					RAISERROR (
							'Cost UOM does not belongs to the Item. '
							,16
							,1
							)
				END
			END

			SELECT TOP 1 @intDefaultCurrencyId = intDefaultCurrencyId
			FROM tblSMCompanyPreference t WITH (NOLOCK)

			SELECT @intCostCurrencyId = t.intCurrencyID
			FROM tblSMCurrency t WITH (NOLOCK)
			WHERE t.strCurrency = @strCostCurrency

			IF ISNULL(@intCostCurrencyId, 0) = 0
			BEGIN
				RAISERROR (
						'Invalid Currency. '
						,16
						,1
						)
			END
			-- Cost UOM Conversion

			SELECT @dblNewCost = dbo.fnCTConvertQtyToTargetItemUOM(@intCostItemUOMId, @intStockItemUOMId, @dblCost)

			SELECT @intLotId = L.intLotId
				,@intQtyItemUOMId = L.intItemUOMId
				,@dblOrgQty = L.dblQty
				--,@dblQty = ISNULL(dbo.fnMFConvertQuantityToTargetItemUOM(@intNetWeightItemUOMId, L.intItemUOMId, @dblNetWeight), 0)
				,@dblQty = dbo.[fnDivide]((@dblNetWeight - L.dblWeight), L.dblWeightPerQty)
			FROM tblICLot L WITH (NOLOCK)
			WHERE L.strLotNumber = @strLotNumber
				AND L.intItemId = @intItemId
				AND L.intSubLocationId = @intSubLocationId
				AND L.intStorageLocationId = @intStorageLocationId

			IF ISNULL(@strLotNumber, '') = ''
			BEGIN
				RAISERROR (
						'Invalid Batch Id. '
						,16
						,1
						)
			END

			BEGIN TRAN

			-- Lot Create / Update
			IF ISNULL(@intLotId, 0) = 0
			BEGIN
				IF ISNULL(@dblNetWeight, 0) = 0
				BEGIN
					GOTO NextRec
				END

				-- Take Qty from Batch
				SELECT TOP 1 @dblQty = Round(ISNULL(dbo.fnMFConvertQuantityToTargetItemUOM(@intNetWeightItemUOMId, IUOM.intItemUOMId, @dblNetWeight), 0),0)
					,@intQtyItemUOMId = IUOM.intItemUOMId
				FROM tblMFBatch B WITH (NOLOCK)
				JOIN tblICItemUOM IUOM WITH (NOLOCK) ON IUOM.intItemId = B.intTealingoItemId
					AND IUOM.intUnitMeasureId = B.intPackageUOMId
					AND B.strBatchId = @strLotNumber
					AND B.intTealingoItemId = @intItemId
					AND B.intLocationId = @intCompanyLocationId

				IF ISNULL(@dblQty, 0) = 0
				BEGIN
					SELECT TOP 1 @dblQty = Round(ISNULL(dbo.fnMFConvertQuantityToTargetItemUOM(@intNetWeightItemUOMId, IUOM.intItemUOMId, @dblNetWeight), 0),0)
						,@intQtyItemUOMId = IUOM.intItemUOMId
					FROM tblMFBatch B WITH (NOLOCK)
					JOIN tblICItemUOM IUOM WITH (NOLOCK) ON IUOM.intItemId = B.intTealingoItemId
						AND IUOM.intUnitMeasureId = B.intPackageUOMId
						AND B.strBatchId = @strLotNumber
						AND B.intTealingoItemId = @intItemId
				END

				IF ISNULL(@dblQty, 0) = 0
				BEGIN
					RAISERROR (
							'Batch characteristics does not exists. '
							,16
							,1
							)
				END

				IF ISNULL(@dblQty, 0) = 0
				BEGIN
					SELECT TOP 1 @dblQty = ISNULL(dbo.fnMFConvertQuantityToTargetItemUOM(@intNetWeightItemUOMId, L.intItemUOMId, @dblNetWeight), 0)
						,@intQtyItemUOMId = L.intItemUOMId
					FROM tblICLot L WITH (NOLOCK)
					WHERE L.strLotNumber = @strLotNumber
						AND L.intItemId = @intItemId
						AND L.intSubLocationId = @intSubLocationId
				END

				IF ISNULL(@dblQty, 0) = 0
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

				SELECT @strContainerNo = NULL
					,@strMarkings = NULL
					,@intEntityVendorId = NULL
					,@strCondition = NULL
					,@strCertificate = NULL
					,@strCertificateId = NULL
					,@intContractHeaderId = NULL
					,@intContractDetailId = NULL
					,@strLotAlias = NULL
					,@dtmExpiryDate = NULL

				SELECT @strContainerNo = strContainerNo
					,@strMarkings = strMarkings
					,@intEntityVendorId = intEntityVendorId
					,@strCondition = strCondition
					,@strCertificate = strCertificate
					,@strCertificateId = strCertificateId
					,@intContractHeaderId = intContractHeaderId
					,@intContractDetailId = intContractDetailId
					,@strLotAlias = strLotAlias
					,@dtmExpiryDate = dtmExpiryDate
				FROM tblICLot L WITH (NOLOCK)
				WHERE L.strLotNumber = @strLotNumber

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
					,@strLotAlias
					,NULL
					,@strLotNumber
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,@dblNewCost
					,'Created from external system'
					,1
					,NULL
					,NULL
					,@intOriginId
					,@strContainerNo
					,@strMarkings
					,@intEntityVendorId
					,@strCondition
					,@dtmExpiryDate
					,@strCertificate
					,@strCertificateId
					,@intContractHeaderId
					,@intContractDetailId
			END
			ELSE
			BEGIN
				IF ISNULL(@dblQty, 0) <> 0
				BEGIN
					--SELECT @dblAdjustByQuantity = @dblQty - @dblOrgQty
					SELECT @dblAdjustByQuantity = @dblQty

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

			INSERT INTO tblIPLotArchive (
				intTrxSequenceNo
				,dtmCreatedDate
				,strLocationName
				,strSubLocationName
				,strStorageLocationName
				,strLotNumber
				,strItemNo
				,dblQuantity
				,strQuantityUOM
				,dblNetWeight
				,strNetWeightUOM
				,dblCost
				,strCostUOM
				,strCostCurrency
				,dblAllocatedQty
				,dtmTransactionDate
				,strErrorMessage
				,strImportStatus
				)
			SELECT intTrxSequenceNo
				,dtmCreatedDate
				,strLocationName
				,strSubLocationName
				,strStorageLocationName
				,strLotNumber
				,strItemNo
				,dblQuantity
				,strQuantityUOM
				,dblNetWeight
				,strNetWeightUOM
				,dblCost
				,strCostUOM
				,strCostCurrency
				,dblAllocatedQty
				,dtmTransactionDate
				,''
				,'Success'
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

			INSERT INTO tblIPLotError (
				intTrxSequenceNo
				,dtmCreatedDate
				,strLocationName
				,strSubLocationName
				,strStorageLocationName
				,strLotNumber
				,strItemNo
				,dblQuantity
				,strQuantityUOM
				,dblNetWeight
				,strNetWeightUOM
				,dblCost
				,strCostUOM
				,strCostCurrency
				,dblAllocatedQty
				,dtmTransactionDate
				,strErrorMessage
				,strImportStatus
				)
			SELECT intTrxSequenceNo
				,dtmCreatedDate
				,strLocationName
				,strSubLocationName
				,strStorageLocationName
				,strLotNumber
				,strItemNo
				,dblQuantity
				,strQuantityUOM
				,dblNetWeight
				,strNetWeightUOM
				,dblCost
				,strCostUOM
				,strCostCurrency
				,dblAllocatedQty
				,dtmTransactionDate
				,@ErrMsg
				,'Failed'
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
