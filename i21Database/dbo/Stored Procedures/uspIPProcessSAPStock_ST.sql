CREATE PROCEDURE uspIPProcessSAPStock_ST @strInfo1 NVARCHAR(MAX) = '' OUT
	,@strInfo2 NVARCHAR(MAX) = '' OUT
	,@intNoOfRowsAffected INT = 0 OUT
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @intMinRowNo INT
		,@ErrMsg NVARCHAR(MAX)
		,@strFinalErrMsg NVARCHAR(MAX) = ''
		,@intEntityId INT
	DECLARE @strItemNo NVARCHAR(50)
		,@strLocationName NVARCHAR(50)
		,@strSubLocationName NVARCHAR(50)
		,@strStorageLocationName NVARCHAR(50)
		,@dblQuantity NUMERIC(38, 20)
		,@strQuantityUOM NVARCHAR(50)
		,@dblNetWeight NUMERIC(38, 20)
		,@strNetWeightUOM NVARCHAR(50)
		,@strLotNumber NVARCHAR(50)
		,@dblCost NUMERIC(38, 20)
		,@strCostUOM NVARCHAR(50)
		,@strCostCurrency NVARCHAR(50)
		,@strBook NVARCHAR(50)
		,@strSubBook NVARCHAR(50)
	DECLARE @intCompanyLocationId INT
		,@intItemId INT
		,@intSubLocationId INT
		,@intStorageLocationId INT
		,@intQtyUnitMeasureId INT
		,@intQtyItemUOMId INT
		,@intNetWeightUnitMeasureId INT
		,@intNetWeightItemUOMId INT
		,@intCostUnitMeasureId INT
		,@intCostItemUOMId INT
		,@intCostCurrencyId INT
		,@intDefaultCurrencyId INT
		,@intLotId INT
		,@intOriginId INT
		,@intItemLocationId INT
		,@intBatchId INT
		,@dblNewCost NUMERIC(38, 20)
		,@intStockItemUOMId INT
		,@intBookId INT
		,@intSubBookId INT
		,@dblWeightPerQty INT
		,@intInventoryAdjustmentId INT
	DECLARE @tblLotTable TABLE (
		intLotRecordId INT IDENTITY(1, 1)
		,intItemId INT
		,intLocationId INT
		,intSubLocationId INT
		,intStorageLocationId INT
		)
	DECLARE @intMinRecordLotId INT
		,@ysnResetLotQtyOnce BIT = 1

	SELECT @intMinRowNo = Min(intStageLotId)
	FROM tblIPLotStage WITH (NOLOCK)

	WHILE (@intMinRowNo IS NOT NULL)
	BEGIN
		BEGIN TRY
			SET @intNoOfRowsAffected = 1

			SELECT @intEntityId = intEntityId
			FROM tblSMUserSecurity WITH (NOLOCK)
			WHERE strUserName = 'IRELYADMIN'

			-- Resetting all the available lot qty to 0
			IF @ysnResetLotQtyOnce = 1
			BEGIN
				SELECT @ysnResetLotQtyOnce = 0

				DELETE
				FROM @tblLotTable

				INSERT INTO @tblLotTable
				SELECT DISTINCT intItemId
					,intLocationId
					,intSubLocationId
					,intStorageLocationId
				FROM tblICLot WITH (NOLOCK)
				WHERE dblQty > 0
					AND intSubLocationId IS NOT NULL
					AND intStorageLocationId IS NOT NULL

				SELECT @intMinRecordLotId = MIN(intLotRecordId)
				FROM @tblLotTable

				BEGIN TRAN

				WHILE (ISNULL(@intMinRecordLotId, 0) > 0)
				BEGIN
					SELECT @intItemId = NULL
						,@intCompanyLocationId = NULL
						,@intSubLocationId = NULL
						,@intStorageLocationId = NULL

					SELECT @intItemId = intItemId
						,@intCompanyLocationId = intLocationId
						,@intSubLocationId = intSubLocationId
						,@intStorageLocationId = intStorageLocationId
					FROM @tblLotTable
					WHERE intLotRecordId = @intMinRecordLotId

					EXEC uspICAdjustStockFromSAP @dtmQtyChange = NULL
						,@intItemId = @intItemId
						,@strLotNumber = 'FIFO'
						,@intLocationId = @intCompanyLocationId
						,@intSubLocationId = @intSubLocationId
						,@intStorageLocationId = @intStorageLocationId
						,@intItemUOMId = NULL
						,@dblNewQty = 0
						,@dblCost = NULL
						,@intEntityUserId = @intEntityId
						,@intSourceId = 1

					SELECT @intMinRecordLotId = MIN(intLotRecordId)
					FROM @tblLotTable
					WHERE intLotRecordId > @intMinRecordLotId
				END

				COMMIT TRAN
			END

			SELECT @strItemNo = NULL
				,@strLocationName = NULL
				,@strSubLocationName = NULL
				,@strStorageLocationName = NULL
				,@dblQuantity = NULL
				,@strQuantityUOM = NULL
				,@dblNetWeight = NULL
				,@strNetWeightUOM = NULL
				,@strLotNumber = NULL
				,@dblCost = NULL
				,@strCostUOM = NULL
				,@strCostCurrency = NULL
				,@strBook = NULL
				,@strSubBook = NULL

			SELECT @intCompanyLocationId = NULL
				,@intItemId = NULL
				,@intSubLocationId = NULL
				,@intStorageLocationId = NULL
				,@intQtyUnitMeasureId = NULL
				,@intQtyItemUOMId = NULL
				,@intNetWeightUnitMeasureId = NULL
				,@intNetWeightItemUOMId = NULL
				,@intCostUnitMeasureId = NULL
				,@intCostItemUOMId = NULL
				,@intCostCurrencyId = NULL
				,@intDefaultCurrencyId = NULL
				,@intLotId = NULL
				,@intOriginId = NULL
				,@intItemLocationId = NULL
				,@intBatchId = NULL
				,@dblNewCost = NULL
				,@intStockItemUOMId = NULL
				,@intBookId = NULL
				,@intSubBookId = NULL
				,@dblWeightPerQty = NULL
				,@intInventoryAdjustmentId = NULL

			SELECT @strItemNo = strItemNo
				,@strLocationName = strLocationName
				,@strSubLocationName = strSubLocationName
				,@strStorageLocationName = strStorageLocationName
				,@dblQuantity = ISNULL(dblQuantity, 0)
				,@strQuantityUOM = strQuantityUOM
				,@dblNetWeight = ISNULL(dblNetWeight, 0)
				,@strNetWeightUOM = strNetWeightUOM
				,@strLotNumber = ISNULL(strLotNumber, '')
				,@dblCost = ISNULL(dblCost, 0)
				,@strCostUOM = strCostUOM
				,@strCostCurrency = strCostCurrency
				,@strBook = strBook
				,@strSubBook = strSubBook
			FROM tblIPLotStage WITH (NOLOCK)
			WHERE intStageLotId = @intMinRowNo

			SET @strInfo1 = ISNULL(@strItemNo, '') + ' / ' + ISNULL(@strLotNumber, '')
			SET @strInfo2 = ISNULL(@strStorageLocationName, '') + ' / ' + ISNULL(CONVERT(NVARCHAR, dbo.fnRemoveTrailingZeroes(@dblQuantity)), '')

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

			SELECT @intCompanyLocationId = t.intCompanyLocationId
			FROM tblSMCompanyLocation t WITH (NOLOCK)
			WHERE t.strLocationName = @strLocationName

			IF ISNULL(@intCompanyLocationId, 0) = 0
			BEGIN
				SELECT TOP 1 @intCompanyLocationId = t.intCompanyLocationId
				FROM tblSMCompanyLocation t WITH (NOLOCK)
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

			SELECT @intSubLocationId = t.intCompanyLocationSubLocationId
			FROM tblSMCompanyLocationSubLocation t WITH (NOLOCK)
			WHERE t.strSubLocationName = @strSubLocationName

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

			IF ISNULL(@intStorageLocationId, 0) = 0
			BEGIN
				RAISERROR (
						'Invalid Storage Location. '
						,16
						,1
						)
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

			-- Weight Per Qty
			SELECT @dblWeightPerQty = @dblNetWeight / @dblQuantity

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

			IF @intDefaultCurrencyId <> @intCostCurrencyId
			BEGIN
				RAISERROR (
						'Invalid Currency. '
						,16
						,1
						)
			END

			-- Cost UOM Conversion
			SELECT @dblNewCost = dbo.fnCTConvertQtyToTargetItemUOM(@intCostItemUOMId, @intStockItemUOMId, @dblCost)

			SELECT @intBookId = t.intBookId
			FROM tblCTBook t WITH (NOLOCK)
			WHERE t.strBook = @strBook

			IF ISNULL(@intBookId, 0) = 0
			BEGIN
				SELECT @intBookId = dbo.[fnIPGetSAPIDOCTagValue]('STOCK', 'BOOK_ID')

				IF ISNULL(@intBookId, 0) = 0
				BEGIN
					RAISERROR (
							'Invalid Book. '
							,16
							,1
							)
				END
			END

			SELECT @intSubBookId = t.intSubBookId
			FROM tblCTSubBook t WITH (NOLOCK)
			WHERE t.strSubBook = @strSubBook
				AND t.intBookId = @intBookId

			IF ISNULL(@intSubBookId, 0) = 0
			BEGIN
				SELECT @intSubBookId = dbo.[fnIPGetSAPIDOCTagValue]('STOCK', 'SUB_BOOK_ID')

				IF @intSubBookId = 0
					SELECT @intSubBookId = NULL
			END

			SELECT @intLotId = L.intLotId
			FROM tblICLot L WITH (NOLOCK)
			WHERE L.strLotNumber = @strLotNumber
				AND L.intItemId = @intItemId
				AND L.intSubLocationId = @intSubLocationId
				AND L.intStorageLocationId = @intStorageLocationId

			BEGIN TRAN

			-- Lot Create / Update
			IF ISNULL(@intLotId, 0) = 0
			BEGIN
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
					,@intEntityId
					,NULL
					,@intStorageLocationId
					,@dblNetWeight
					,@intNetWeightItemUOMId
					,@dblWeightPerQty
					,@dblQuantity
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
					,@dblNewCost
					,'Created from external system'
					,1
					,@intBookId
					,@intSubBookId
					,@intOriginId
			END
			ELSE
			BEGIN
				-- To adjust Qty as 0
				--EXEC uspICAdjustStockFromSAP @dtmQtyChange = NULL
				--	,@intItemId = @intItemId
				--	,@strLotNumber = @strLotNumber
				--	,@intLocationId = @intCompanyLocationId
				--	,@intSubLocationId = @intSubLocationId
				--	,@intStorageLocationId = @intStorageLocationId
				--	,@intItemUOMId = NULL
				--	,@dblNewQty = 0
				--	,@dblCost = NULL
				--	,@intEntityUserId = @intEntityId
				--	,@intSourceId = 1
				-- Update - To adjust to new Qty. Doing this way (Resetting and Adjusting) to handle the qty and cost correctly
				EXEC uspICInventoryAdjustment_CreatePostQtyChange @intItemId = @intItemId
					,@dtmDate = NULL
					,@intLocationId = @intCompanyLocationId
					,@intSubLocationId = @intSubLocationId
					,@intStorageLocationId = @intStorageLocationId
					,@strLotNumber = @strLotNumber
					,@dblAdjustByQuantity = @dblQuantity
					,@dblNewUnitCost = @dblNewCost
					,@intItemUOMId = @intQtyItemUOMId
					,@intSourceId = 1
					,@intSourceTransactionTypeId = 8
					,@intEntityUserSecurityId = @intEntityId
					,@intInventoryAdjustmentId = @intInventoryAdjustmentId OUTPUT
					,@strDescription = 'Adjusted from external system'
			END

			UPDATE tblICLot
			SET intBookId = @intBookId
				,intSubBookId = @intSubBookId
			WHERE intLotId = @intLotId

			--Move to Archive
			INSERT INTO tblIPLotArchive (
				strItemNo
				,strLocationName
				,strSubLocationName
				,strStorageLocationName
				,dblQuantity
				,strQuantityUOM
				,dblNetWeight
				,strNetWeightUOM
				,strLotNumber
				,dblCost
				,strCostUOM
				,strCostCurrency
				,strBook
				,strSubBook
				,strTransactionType
				,strErrorMessage
				,strImportStatus
				,strSessionId
				)
			SELECT strItemNo
				,strLocationName
				,strSubLocationName
				,strStorageLocationName
				,dblQuantity
				,strQuantityUOM
				,dblNetWeight
				,strNetWeightUOM
				,strLotNumber
				,dblCost
				,strCostUOM
				,strCostCurrency
				,strBook
				,strSubBook
				,strTransactionType
				,''
				,'Success'
				,strSessionId
			FROM tblIPLotStage
			WHERE intStageLotId = @intMinRowNo

			DELETE
			FROM tblIPLotStage
			WHERE intStageLotId = @intMinRowNo

			COMMIT TRAN
		END TRY

		BEGIN CATCH
			IF XACT_STATE() != 0
				AND @@TRANCOUNT > 0
				ROLLBACK TRANSACTION

			SET @ErrMsg = ERROR_MESSAGE()
			SET @strFinalErrMsg = @strFinalErrMsg + @ErrMsg

			--Move to Error
			INSERT INTO tblIPLotError (
				strItemNo
				,strLocationName
				,strSubLocationName
				,strStorageLocationName
				,dblQuantity
				,strQuantityUOM
				,dblNetWeight
				,strNetWeightUOM
				,strLotNumber
				,dblCost
				,strCostUOM
				,strCostCurrency
				,strBook
				,strSubBook
				,strTransactionType
				,strErrorMessage
				,strImportStatus
				,strSessionId
				)
			SELECT strItemNo
				,strLocationName
				,strSubLocationName
				,strStorageLocationName
				,dblQuantity
				,strQuantityUOM
				,dblNetWeight
				,strNetWeightUOM
				,strLotNumber
				,dblCost
				,strCostUOM
				,strCostCurrency
				,strBook
				,strSubBook
				,strTransactionType
				,@ErrMsg
				,'Failed'
				,strSessionId
			FROM tblIPLotStage
			WHERE intStageLotId = @intMinRowNo

			DELETE
			FROM tblIPLotStage
			WHERE intStageLotId = @intMinRowNo
		END CATCH

		SELECT @intMinRowNo = Min(intStageLotId)
		FROM tblIPLotStage WITH (NOLOCK)
		WHERE intStageLotId > @intMinRowNo
	END

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
