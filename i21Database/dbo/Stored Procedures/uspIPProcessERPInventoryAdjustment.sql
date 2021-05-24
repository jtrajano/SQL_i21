﻿CREATE PROCEDURE [dbo].[uspIPProcessERPInventoryAdjustment] @strInfo1 NVARCHAR(MAX) = '' OUT
	,@strInfo2 NVARCHAR(MAX) = '' OUT
	,@intNoOfRowsAffected INT = 0 OUT
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON

	DECLARE @intInventoryAdjustmentStageId INT
	DECLARE @ErrMsg NVARCHAR(max)
	DECLARE @dtmDate DATETIME
	DECLARE @intUserId INT
	DECLARE @strUserName NVARCHAR(100)
	DECLARE @strFinalErrMsg NVARCHAR(MAX) = ''
		,@ItemsForPost AS ItemCostingTableType
		,@intTrxSequenceNo INT
		,@strCompanyLocation NVARCHAR(6)
		,@intActionId INT
		,@dtmCreatedDate DATETIME
		,@strCreatedBy NVARCHAR(50)
		,@intTransactionTypeId INT
		,@strStorageLocation NVARCHAR(50)
		,@strItemNo NVARCHAR(50)
		,@strMotherLotNo NVARCHAR(50)
		,@strLotNo NVARCHAR(50)
		,@strStorageUnit NVARCHAR(50)
		,@dblQuantity NUMERIC(18, 6)
		,@strQuantityUOM NVARCHAR(50)
		,@strReasonCode NVARCHAR(50)
		,@strNotes NVARCHAR(2048)
		,@strError NVARCHAR(MAX)
		,@intCompanyLocationSubLocationId INT
		,@intCompanyLocationId INT
		,@intStorageLocationId INT
		,@intItemId INT
		,@intUnitMeasureId INT
		,@intItemUOMId INT
		,@intLotId INT
		,@strAdjustmentNo NVARCHAR(50)
		,@intAdjustmentId INT
		,@intBatchId INT
		,@intTransactionId INT
		,@dblLastCost NUMERIC(18, 6)
		,@intItemLocationId INT
		,@GLEntries AS RecapTableType
		,@STARTING_NUMBER_BATCH AS INT = 3
		,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY AS NVARCHAR(255) = 'Work In Progress'
		,@strBatchId AS NVARCHAR(40)

	SELECT @intUserId = intEntityId
	FROM tblSMUserSecurity WITH (NOLOCK)
	WHERE strUserName = 'IRELYADMIN'

	SELECT @intInventoryAdjustmentStageId = MIN(intInventoryAdjustmentStageId)
	FROM tblIPInventoryAdjustmentStage

	SELECT @strInfo1 = ''

	SELECT @strInfo1 = @strInfo1 + ISNULL(strLotNo, '') + ', '
	FROM tblIPInventoryAdjustmentStage

	IF Len(@strInfo1) > 0
	BEGIN
		SELECT @strInfo1 = Left(@strInfo1, Len(@strInfo1) - 1)
	END

	WHILE @intInventoryAdjustmentStageId IS NOT NULL
	BEGIN
		BEGIN TRY
			SELECT @intTrxSequenceNo = NULL
				,@strCompanyLocation = NULL
				,@intActionId = NULL
				,@dtmCreatedDate = NULL
				,@strCreatedBy = NULL
				,@intTransactionTypeId = NULL
				,@strStorageLocation = NULL
				,@strItemNo = NULL
				,@strMotherLotNo = NULL
				,@strLotNo = NULL
				,@strStorageUnit = NULL
				,@dblQuantity = NULL
				,@strQuantityUOM = NULL
				,@strReasonCode = NULL
				,@strNotes = NULL

			SELECT @intTrxSequenceNo = intTrxSequenceNo
				,@strCompanyLocation = strCompanyLocation
				,@intActionId = intActionId
				,@dtmCreatedDate = dtmCreatedDate
				,@strCreatedBy = strCreatedBy
				,@intTransactionTypeId = intTransactionTypeId
				,@strStorageLocation = strStorageLocation
				,@strItemNo = strItemNo
				,@strMotherLotNo = strMotherLotNo
				,@strLotNo = strLotNo
				,@strStorageUnit = strStorageUnit
				,@dblQuantity = dblQuantity
				,@strQuantityUOM = strQuantityUOM
				,@strReasonCode = strReasonCode
				,@strNotes = strNotes
			FROM tblIPInventoryAdjustmentStage
			WHERE intInventoryAdjustmentStageId = @intInventoryAdjustmentStageId

			IF EXISTS (
					SELECT 1
					FROM tblIPInventoryAdjustmentArchive
					WHERE intTrxSequenceNo = @intTrxSequenceNo
					)
			BEGIN
				SELECT @strError = 'TrxSequenceNo ' + ltrim(@intTrxSequenceNo) + ' is already processsed in i21.'
				RAISERROR (
						@strError
						,16
						,1
						)
			END

			IF EXISTS (
					SELECT 1
					FROM tblIPInventoryAdjustmentAck
					WHERE intTrxSequenceNo = @intTrxSequenceNo
					)
			BEGIN
				SELECT @strError = 'TrxSequenceNo ' + Ltrim(@intTrxSequenceNo) + ' is exists in i21.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			SELECT @intCompanyLocationId = intCompanyLocationId
			FROM dbo.tblSMCompanyLocation
			WHERE strLotOrigin = @strCompanyLocation

			IF @intCompanyLocationId IS NULL
			BEGIN
				SELECT @strError = 'Company Location ' + @strCompanyLocation + 'is not available.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			IF @strStorageLocation IS NULL
				OR @strStorageLocation = ''
			BEGIN
				SELECT @strError = 'Storage Location cannot be blank.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			SELECT @intCompanyLocationSubLocationId = intCompanyLocationSubLocationId
			FROM dbo.tblSMCompanyLocationSubLocation
			WHERE strSubLocationName = @strStorageLocation
				AND intCompanyLocationId = @intCompanyLocationId

			IF @intCompanyLocationSubLocationId IS NULL
			BEGIN
				SELECT @strError = 'Storage Location ' + @strStorageLocation + ' is not available.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			IF @strStorageUnit IS NULL
				OR @strStorageUnit = ''
			BEGIN
				SELECT @strError = 'Storage Unit cannot be blank.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			SELECT @intStorageLocationId = intStorageLocationId
			FROM dbo.tblICStorageLocation
			WHERE strName = @strStorageUnit
				AND intSubLocationId = @intCompanyLocationSubLocationId

			IF @intStorageLocationId IS NULL
			BEGIN
				SELECT @strError = 'Storage Unit ' + @strStorageUnit + ' is not available.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			IF @strItemNo IS NULL
				OR @strItemNo = ''
			BEGIN
				SELECT @strError = 'Item cannot be blank.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			SELECT @intItemId = intItemId
			FROM dbo.tblICItem
			WHERE strItemNo = @strItemNo

			IF @intItemId IS NULL
			BEGIN
				SELECT @strError = 'Item ' + @strItemNo + ' is not available.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			IF @strQuantityUOM IS NULL
				OR @strQuantityUOM = ''
			BEGIN
				SELECT @strError = 'UOM cannot be blank.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			SELECT @intUnitMeasureId = intUnitMeasureId
			FROM dbo.tblICUnitMeasure
			WHERE strUnitMeasure = @strQuantityUOM

			IF @intUnitMeasureId IS NULL
			BEGIN
				SELECT @strError = 'Unit Measure ' + @strQuantityUOM + ' is not available.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			SELECT @intItemUOMId = intItemUOMId
			FROM tblICItemUOM
			WHERE intItemId = @intItemId
				AND intUnitMeasureId = @intUnitMeasureId

			SELECT @intLotId = intLotId
				,@dblLastCost = dblLastCost
			FROM tblICLot
			WHERE strLotNumber = @strLotNo
				AND intStorageLocationId = @intStorageLocationId

			BEGIN TRAN

			IF @intTransactionTypeId = 10
			BEGIN
				EXEC dbo.uspMFLotAdjustQty @intLotId = @intLotId
					,@dblNewLotQty = @dblQuantity
					,@intAdjustItemUOMId = @intItemUOMId
					,@intUserId = @intUserId
					,@strReasonCode = @strReasonCode
					,@blnValidateLotReservation = 0
					,@strNotes = @strNotes
					,@dtmDate = NULL
					,@ysnBulkChange = 0
					,@strReferenceNo = NULL
					,@intAdjustmentId = @intAdjustmentId OUTPUT

				SELECT @strAdjustmentNo = strAdjustmentNo
				FROM dbo.tblICInventoryAdjustment
				WHERE intInventoryAdjustmentId = @intAdjustmentId
			END
			ELSE IF @intTransactionTypeId = 8
			BEGIN
				EXEC dbo.uspMFGeneratePatternId @intCategoryId = NULL
					,@intItemId = @intItemId
					,@intManufacturingId = NULL
					,@intSubLocationId = NULL
					,@intLocationId = @intCompanyLocationId
					,@intOrderTypeId = NULL
					,@intBlendRequirementId = NULL
					,@intPatternCode = 33
					,@ysnProposed = 0
					,@strPatternString = @intTransactionId OUTPUT

				SELECT @intItemLocationId = intItemLocationId
				FROM tblICItemLocation
				WHERE intItemId = @intItemId
					AND intLocationId = @intCompanyLocationId

				EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH
					,@strBatchId OUTPUT

				SELECT @dtmDate = dbo.fnGetBusinessDate(GETDATE(), @intCompanyLocationId)

				--Lot Tracking
				INSERT INTO @ItemsForPost (
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
					,intLotId
					,intSubLocationId
					,intStorageLocationId
					,intSourceTransactionId
					,strSourceTransactionId
					)
				SELECT intItemId = @intItemId
					,intItemLocationId = @intItemLocationId
					,intItemUOMId = @intItemUOMId
					,dtmDate = @dtmDate
					,dblQty = - @dblQuantity
					,dblUOMQty = @intItemUOMId
					,dblCost = @dblLastCost
					,dblSalesPrice = 0
					,intCurrencyId = NULL
					,dblExchangeRate = 1
					,intTransactionId = @intTransactionId
					,intTransactionDetailId = @intTransactionId
					,strTransactionId = @intTrxSequenceNo
					,intTransactionTypeId = 8
					,intLotId = @intLotId
					,intSubLocationId = @intCompanyLocationSubLocationId
					,intStorageLocationId = @intStorageLocationId
					,intSourceTransactionId = 8
					,strSourceTransactionId = @intTransactionId

				-- Call the post routine 
				INSERT INTO @GLEntries (
					[dtmDate]
					,[strBatchId]
					,[intAccountId]
					,[dblDebit]
					,[dblCredit]
					,[dblDebitUnit]
					,[dblCreditUnit]
					,[strDescription]
					,[strCode]
					,[strReference]
					,[intCurrencyId]
					,[dblExchangeRate]
					,[dtmDateEntered]
					,[dtmTransactionDate]
					,[strJournalLineDescription]
					,[intJournalLineNo]
					,[ysnIsUnposted]
					,[intUserId]
					,[intEntityId]
					,[strTransactionId]
					,[intTransactionId]
					,[strTransactionType]
					,[strTransactionForm]
					,[strModuleName]
					,[intConcurrencyId]
					,[dblDebitForeign]
					,[dblDebitReport]
					,[dblCreditForeign]
					,[dblCreditReport]
					,[dblReportingRate]
					,[dblForeignRate]
					,[strRateType]
					,[intSourceEntityId]
					,[intCommodityId]
					)
				EXEC dbo.uspICPostCosting @ItemsForPost
					,@strBatchId
					,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
					,@intUserId

				EXEC dbo.uspGLBookEntries @GLEntries
					,1
			END

			MOVE_TO_ARCHIVE:

			INSERT INTO dbo.tblIPInitialAck (
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
				,(
					CASE 
						WHEN @intTransactionTypeId = 10
							THEN 15
						WHEN @intTransactionTypeId = 11
							THEN 8
						END
					) AS intMessageTypeId
				,1 AS intStatusId
				,'Success' AS strStatusText

			--Move to Ack
			INSERT INTO tblIPInventoryAdjustmentAck (
				intTrxSequenceNo
				,strCompanyLocation
				,intActionId
				,dtmCreatedDate
				,strCreatedBy
				,intTransactionTypeId
				,strStorageLocation
				,strItemNo
				,strMotherLotNo
				,strLotNo
				,strStorageUnit
				,dblQuantity
				,strQuantityUOM
				,strReasonCode
				,strNotes
				,strAdjustmentNo
				,intStatusId
				,strStatusText
				)
			SELECT intTrxSequenceNo
				,strCompanyLocation
				,intActionId
				,dtmCreatedDate
				,strCreatedBy
				,intTransactionTypeId
				,strStorageLocation
				,strItemNo
				,strMotherLotNo
				,strLotNo
				,strStorageUnit
				,dblQuantity
				,strQuantityUOM
				,strReasonCode
				,strNotes
				,@strAdjustmentNo
				,1 AS intStatusId
				,'Success' AS strStatusText
			FROM tblIPInventoryAdjustmentStage
			WHERE intInventoryAdjustmentStageId = @intInventoryAdjustmentStageId

			DELETE
			FROM tblIPInventoryAdjustmentStage
			WHERE intInventoryAdjustmentStageId = @intInventoryAdjustmentStageId

			COMMIT TRAN
		END TRY

		BEGIN CATCH
			IF XACT_STATE() != 0
				AND @@TRANCOUNT > 0
				ROLLBACK TRANSACTION

			SET @ErrMsg = ERROR_MESSAGE()
			SET @strFinalErrMsg = @strFinalErrMsg + @ErrMsg

			INSERT INTO dbo.tblIPInitialAck (
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
				,15 AS intMessageTypeId
				,0 AS intStatusId
				,@ErrMsg AS strStatusText

			--Move to Error
			INSERT INTO tblIPInventoryAdjustmentError (
				intTrxSequenceNo
				,strCompanyLocation
				,intActionId
				,dtmCreatedDate
				,strCreatedBy
				,intTransactionTypeId
				,strStorageLocation
				,strItemNo
				,strMotherLotNo
				,strLotNo
				,strStorageUnit
				,dblQuantity
				,strQuantityUOM
				,strReasonCode
				,strNotes
				,strErrorMessage
				)
			SELECT intTrxSequenceNo
				,strCompanyLocation
				,intActionId
				,dtmCreatedDate
				,strCreatedBy
				,intTransactionTypeId
				,strStorageLocation
				,strItemNo
				,strMotherLotNo
				,strLotNo
				,strStorageUnit
				,dblQuantity
				,strQuantityUOM
				,strReasonCode
				,strNotes
				,@ErrMsg AS strStatusText
			FROM tblIPInventoryAdjustmentStage
			WHERE intInventoryAdjustmentStageId = @intInventoryAdjustmentStageId

			DELETE
			FROM tblIPInventoryAdjustmentStage
			WHERE intInventoryAdjustmentStageId = @intInventoryAdjustmentStageId
		END CATCH

		SELECT @intInventoryAdjustmentStageId = MIN(intInventoryAdjustmentStageId)
		FROM tblIPInventoryAdjustmentStage
		WHERE intInventoryAdjustmentStageId > @intInventoryAdjustmentStageId
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
