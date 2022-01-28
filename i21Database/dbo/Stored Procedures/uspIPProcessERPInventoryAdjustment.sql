CREATE PROCEDURE [dbo].[uspIPProcessERPInventoryAdjustment] @strInfo1 NVARCHAR(MAX) = '' OUT
	,@strInfo2 NVARCHAR(MAX) = '' OUT
	,@intNoOfRowsAffected INT = 0 OUT
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS ON

	DECLARE @intInventoryAdjustmentStageId INT
	DECLARE @ErrMsg NVARCHAR(max)
	DECLARE @dtmDate DATETIME
	DECLARE @intUserId INT
	DECLARE @strUserName NVARCHAR(100)
	DECLARE @strFinalErrMsg NVARCHAR(MAX) = ''
		,@ItemsForPost AS ItemCostingTableType
		,@intTrxSequenceNo BIGINT
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
		,@dblQuantity NUMERIC(38, 20)
		,@dblQty NUMERIC(38, 20)
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
		,@intInventoryReceiptItemId INT
		,@intInventoryReceiptId INT
		,@intLoadContainerId INT
		,@intLoadId INT
		,@strNewStorageLocation NVARCHAR(50)
		,@strNewStorageUnit NVARCHAR(50)
		,@intCompanyLocationNewSubLocationId INT
		,@intNewStorageLocationId INT
		,@intNewLotId INT
		,@intLotItemUOMId INT
		,@dblWeightPerQty NUMERIC(38, 20)
		,@dblStandardCost NUMERIC(38, 20)
		,@ysnDifferenceQty BIT = 1
		,@intContractHeaderId INT
		,@intContractDetailId INT
		,@intLoadDetailId INT
		,@intParentLotId INT
		,@strParentLotNumber NVARCHAR(50)
		,@dblNoOfPack NUMERIC(38, 20)
		,@dblNetWeight NUMERIC(38, 20)
		,@strContainerNo NVARCHAR(50)
		,@strMarkings NVARCHAR(50)
		,@intEntityVendorId INT
		,@strCondition NVARCHAR(50)

	SELECT @intUserId = intEntityId
	FROM tblSMUserSecurity WITH (NOLOCK)
	WHERE strUserName = 'IRELYADMIN'

	DECLARE @tblIPInventoryAdjustmentStage TABLE (intInventoryAdjustmentStageId INT)

	INSERT INTO @tblIPInventoryAdjustmentStage
	SELECT intInventoryAdjustmentStageId
	FROM tblIPInventoryAdjustmentStage
	WHERE intStatusId IS NULL

	UPDATE tblIPInventoryAdjustmentStage
	SET intStatusId = - 1
	WHERE intInventoryAdjustmentStageId IN (
			SELECT intInventoryAdjustmentStageId
			FROM @tblIPInventoryAdjustmentStage
			)

	SELECT @intInventoryAdjustmentStageId = MIN(intInventoryAdjustmentStageId)
	FROM @tblIPInventoryAdjustmentStage

	SELECT @strInfo1 = ''

	SELECT @strInfo1 = @strInfo1 + ISNULL(b.strLotNo, '') + ', '
	FROM @tblIPInventoryAdjustmentStage a
	JOIN tblIPInventoryAdjustmentStage b ON a.intInventoryAdjustmentStageId = b.intInventoryAdjustmentStageId

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
				,@strNewStorageLocation = NULL
				,@strNewStorageUnit = NULL
				,@intCompanyLocationNewSubLocationId = NULL
				,@intNewStorageLocationId = NULL
				,@dblWeightPerQty = NULL

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
				,@strNewStorageLocation = strNewStorageLocation
				,@strNewStorageUnit = strNewStorageUnit
			FROM tblIPInventoryAdjustmentStage
			WHERE intInventoryAdjustmentStageId = @intInventoryAdjustmentStageId

			IF EXISTS (
					SELECT 1
					FROM tblIPInventoryAdjustmentArchive
					WHERE intTrxSequenceNo = @intTrxSequenceNo
					)
			BEGIN
				SELECT @strError = 'TrxSequenceNo ' + ltrim(@intTrxSequenceNo) + ' is already processed in i21.'

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

			SELECT @intCompanyLocationId = NULL

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

			SELECT @intCompanyLocationSubLocationId = NULL

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

			SELECT @intStorageLocationId = NULL

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

			IF @intTransactionTypeId = 20
			BEGIN
				IF @strNewStorageLocation IS NULL
					OR @strNewStorageLocation = ''
				BEGIN
					SELECT @strError = 'New Storage Location cannot be blank.'

					RAISERROR (
							@strError
							,16
							,1
							)
				END

				SELECT @intCompanyLocationNewSubLocationId = NULL

				SELECT @intCompanyLocationNewSubLocationId = intCompanyLocationSubLocationId
				FROM dbo.tblSMCompanyLocationSubLocation
				WHERE strSubLocationName = @strNewStorageLocation
					AND intCompanyLocationId = @intCompanyLocationId

				IF @intCompanyLocationNewSubLocationId IS NULL
				BEGIN
					SELECT @strError = 'New Storage Location ' + @strNewStorageLocation + ' is not available.'

					RAISERROR (
							@strError
							,16
							,1
							)
				END

				IF @strNewStorageUnit IS NULL
					OR @strNewStorageUnit = ''
				BEGIN
					SELECT @strError = 'New Storage Unit cannot be blank.'

					RAISERROR (
							@strError
							,16
							,1
							)
				END

				SELECT @intNewStorageLocationId = NULL

				SELECT @intNewStorageLocationId = intStorageLocationId
				FROM dbo.tblICStorageLocation
				WHERE strName = @strNewStorageUnit
					AND intSubLocationId = @intCompanyLocationNewSubLocationId

				IF @intNewStorageLocationId IS NULL
				BEGIN
					SELECT @strError = 'New Storage Unit ' + @strNewStorageUnit + ' is not available.'

					RAISERROR (
							@strError
							,16
							,1
							)
				END
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

			SELECT @intItemId = NULL

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

			SELECT @intUnitMeasureId = NULL

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

			SELECT @intItemUOMId = NULL

			SELECT @intItemUOMId = intItemUOMId
			FROM tblICItemUOM
			WHERE intItemId = @intItemId
				AND intUnitMeasureId = @intUnitMeasureId

			SELECT @intLotId = NULL
				,@dblQty = NULL

			SELECT @intLotId = intLotId
				,@dblLastCost = dblLastCost
				,@intLotItemUOMId = intItemUOMId
				,@dblWeightPerQty = dblWeightPerQty
				,@dblQty = dblQty
			FROM tblICLot
			WHERE strLotNumber = @strLotNo
				AND intStorageLocationId = @intStorageLocationId

			IF @intLotId IS NULL
				AND @intTransactionTypeId NOT IN (
					8
					,10
					)
			BEGIN
				SELECT @strError = 'Lot ' + @strLotNo + ' is not available in the storage unit ' + @strStorageUnit + '.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			BEGIN TRAN

			IF @intTransactionTypeId = 20
			BEGIN
				IF @dblWeightPerQty > 0
				BEGIN
					SELECT @dblQuantity = dbo.[fnDivide](@dblQuantity, @dblWeightPerQty)
				END

				SELECT @intItemUOMId = @intLotItemUOMId

				EXEC dbo.uspMFLotMove @intLotId = @intLotId
					,@intNewSubLocationId = @intCompanyLocationNewSubLocationId
					,@intNewStorageLocationId = @intNewStorageLocationId
					,@dblMoveQty = @dblQuantity
					,@intMoveItemUOMId = @intItemUOMId
					,@intUserId = @intUserId
					,@blnValidateLotReservation = 1
					,@blnInventoryMove = 0
					,@dtmDate = NULL
					,@strReasonCode = @strReasonCode
					,@strNotes = @strNotes
					,@ysnBulkChange = 0
					,@ysnSourceLotEmptyOut = 0
					,@ysnDestinationLotEmptyOut = 0
					,@intNewLotId = @intNewLotId OUTPUT
					,@intWorkOrderId = NULL
					,@intAdjustmentId = @intAdjustmentId OUTPUT

				SELECT @strAdjustmentNo = NULL

				SELECT @strAdjustmentNo = strAdjustmentNo
				FROM dbo.tblICInventoryAdjustment
				WHERE intInventoryAdjustmentId = @intAdjustmentId
			END
			ELSE IF @intTransactionTypeId = 10
			BEGIN
				IF @intLotId IS NULL
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

					SELECT @intItemLocationId = NULL

					SELECT @intItemLocationId = intItemLocationId
					FROM tblICItemLocation
					WHERE intItemId = @intItemId
						AND intLocationId = @intCompanyLocationId

					SELECT @dblStandardCost = NULL

					SELECT @dblStandardCost = t.dblStandardCost
					FROM tblICItemPricing t WITH (NOLOCK)
					WHERE t.intItemId = @intItemId
						AND t.intItemLocationId = @intItemLocationId

					SELECT @intParentLotId = NULL
						,@dblWeightPerQty = NULL
						,@intLotItemUOMId = NULL
						,@strParentLotNumber = NULL
						,@strContainerNo = NULL
						,@strMarkings = NULL
						,@intEntityVendorId = NULL
						,@strCondition = NULL
						,@intInventoryReceiptId = NULL

					SELECT TOP 1 @intParentLotId = intParentLotId
						,@dblWeightPerQty = dblWeightPerQty
						,@intLotItemUOMId = intItemUOMId
						,@strContainerNo = strContainerNo
						,@strMarkings = strMarkings
						,@intEntityVendorId = intEntityVendorId
						,@strCondition = strCondition
					FROM tblICLot
					WHERE intItemId = @intItemId
						AND strLotNumber = @strLotNo
					ORDER BY intLotId

					IF @intParentLotId IS NULL
					BEGIN
						SELECT @dblWeightPerQty = 1

						SELECT @dblNoOfPack = @dblQuantity

						SELECT @intLotItemUOMId = @intItemUOMId
					END
					ELSE
					BEGIN
						SELECT @dblNoOfPack = NULL

						SELECT @dblNoOfPack = dbo.[fnDivide](@dblQuantity, @dblWeightPerQty)
					END

					SELECT @strParentLotNumber = strParentLotNumber
					FROM tblICParentLot
					WHERE intParentLotId = @intParentLotId

					EXEC uspMFPostProduction 1
						,0
						,NULL
						,@intItemId
						,@intUserId
						,NULL
						,@intStorageLocationId
						,@dblQuantity
						,@intItemUOMId
						,@dblWeightPerQty
						,@dblNoOfPack
						,@intLotItemUOMId
						,@strLotNo
						,@strLotNo
						,@intBatchId
						,@intLotId OUTPUT
						,NULL
						,NULL
						,@strParentLotNumber --Parent Lot Number
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
						,NULL
						,@strContainerNo
						,@strMarkings
						,@intEntityVendorId
						,@strCondition
				END
				ELSE
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
						,@ysnDifferenceQty = @ysnDifferenceQty

					SELECT @strAdjustmentNo = NULL

					SELECT @strAdjustmentNo = strAdjustmentNo
					FROM dbo.tblICInventoryAdjustment
					WHERE intInventoryAdjustmentId = @intAdjustmentId
				END

				IF @strReasonCode = 30
				BEGIN
					IF NOT EXISTS (
							SELECT *
							FROM tblIPInventoryAdjustment
							WHERE strLotNumber = @strLotNo
							)
					BEGIN
						SELECT @intInventoryReceiptItemId = NULL

						SELECT TOP 1 @intInventoryReceiptItemId = intInventoryReceiptItemId
						FROM tblICInventoryReceiptItemLot
						WHERE strLotNumber = @strLotNo
						ORDER BY intInventoryReceiptItemLotId ASC

						SELECT @intInventoryReceiptId = NULL
							,@intLoadContainerId = NULL
							,@intContractHeaderId = NULL
							,@intContractDetailId = NULL
							,@intLoadDetailId = NULL
							,@dblNetWeight = NULL

						SELECT @intInventoryReceiptId = intInventoryReceiptId
							,@intLoadContainerId = intContainerId
							,@intContractHeaderId = intOrderId
							,@intContractDetailId = intLineNo
							,@intLoadDetailId = intSourceId
							,@dblNetWeight = dblNet
						FROM tblICInventoryReceiptItem
						WHERE intInventoryReceiptItemId = @intInventoryReceiptItemId

						SELECT @intLoadId = NULL

						SELECT @intLoadId = intLoadId
						FROM tblLGLoadContainer
						WHERE intLoadContainerId = @intLoadContainerId

						INSERT INTO tblIPInventoryAdjustment (
							dtmCreatedDate
							,intContractHeaderId
							,intContractDetailId
							,intLoadId
							,intLoadDetailId
							,intLoadContainerId
							,intInventoryReceiptId
							,strLotNumber
							,dblNet
							,dblGross
							)
						SELECT GETDATE() AS dtmCreatedDate
							,@intContractHeaderId
							,@intContractDetailId
							,@intLoadId
							,@intLoadDetailId
							,@intLoadContainerId
							,@intInventoryReceiptId
							,@strLotNo
							,@dblNetWeight + @dblQuantity AS dblNet
							,@dblNetWeight + @dblQuantity AS dblGrossWeight

						EXEC uspIPAddPendingClaim @intLoadId = @intLoadId
							,@intPurchaseSale = 1
							,@intLoadContainerId = @intLoadContainerId
							,@ysnAddClaim = 1
					END
					ELSE
					BEGIN
						SELECT @intInventoryReceiptItemId = NULL

						SELECT TOP 1 @intInventoryReceiptItemId = intInventoryReceiptItemId
						FROM tblICInventoryReceiptItemLot
						WHERE strLotNumber = @strLotNo
						ORDER BY intInventoryReceiptItemLotId ASC

						SELECT @intInventoryReceiptId = NULL
							,@intLoadContainerId = NULL

						SELECT @intInventoryReceiptId = intInventoryReceiptId
							,@intLoadContainerId = intContainerId
						FROM tblICInventoryReceiptItem
						WHERE intInventoryReceiptItemId = @intInventoryReceiptItemId

						UPDATE tblIPInventoryAdjustment
						SET dblNet = dblNet + @dblQuantity
							,dblGross = dblGross + @dblQuantity
						WHERE intInventoryReceiptId = @intInventoryReceiptId
							AND strLotNumber = @strLotNo

						SELECT @intLoadId = NULL

						SELECT @intLoadId = intLoadId
						FROM tblLGLoadContainer
						WHERE intLoadContainerId = @intLoadContainerId

						EXEC uspIPAddPendingClaim @intLoadId = @intLoadId
							,@intPurchaseSale = 1
							,@intLoadContainerId = @intLoadContainerId
							,@ysnAddClaim = 1
					END
				END
			END
			ELSE IF @intTransactionTypeId = 8
			BEGIN
				IF @intLotId IS NULL
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

					SELECT @intItemLocationId = NULL

					SELECT @intItemLocationId = intItemLocationId
					FROM tblICItemLocation
					WHERE intItemId = @intItemId
						AND intLocationId = @intCompanyLocationId

					SELECT @dblStandardCost = NULL

					SELECT @dblStandardCost = t.dblStandardCost
					FROM tblICItemPricing t WITH (NOLOCK)
					WHERE t.intItemId = @intItemId
						AND t.intItemLocationId = @intItemLocationId

					SELECT @intParentLotId = NULL
						,@dblWeightPerQty = NULL
						,@intLotItemUOMId = NULL
						,@strParentLotNumber = NULL
						,@strContainerNo = NULL
						,@strMarkings = NULL
						,@intEntityVendorId = NULL
						,@strCondition = NULL
						,@intInventoryReceiptId = NULL

					SELECT TOP 1 @intParentLotId = intParentLotId
						,@dblWeightPerQty = dblWeightPerQty
						,@intLotItemUOMId = intItemUOMId
						,@strContainerNo = strContainerNo
						,@strMarkings = strMarkings
						,@intEntityVendorId = intEntityVendorId
						,@strCondition = strCondition
					FROM tblICLot
					WHERE intItemId = @intItemId
						AND strLotNumber = @strLotNo
					ORDER BY intLotId

					IF @intParentLotId IS NULL
					BEGIN
						SELECT @dblWeightPerQty = 1

						SELECT @dblNoOfPack = @dblQuantity

						SELECT @intLotItemUOMId = @intItemUOMId
					END
					ELSE
					BEGIN
						SELECT @dblNoOfPack = NULL

						SELECT @dblNoOfPack = dbo.[fnDivide](@dblQuantity, @dblWeightPerQty)
					END

					SELECT @strParentLotNumber = strParentLotNumber
					FROM tblICParentLot
					WHERE intParentLotId = @intParentLotId

					EXEC uspMFPostProduction 1
						,0
						,NULL
						,@intItemId
						,@intUserId
						,NULL
						,@intStorageLocationId
						,@dblQuantity
						,@intItemUOMId
						,@dblWeightPerQty
						,@dblNoOfPack
						,@intLotItemUOMId
						,@strLotNo
						,@strLotNo
						,@intBatchId
						,@intLotId OUTPUT
						,NULL
						,NULL
						,@strParentLotNumber --Parent Lot Number
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
						,NULL
						,@strContainerNo
						,@strMarkings
						,@intEntityVendorId
						,@strCondition

					SELECT @dblLastCost = dblLastCost
						,@intLotItemUOMId = intItemUOMId
						,@dblWeightPerQty = dblWeightPerQty
						,@dblQty = dblQty
					FROM tblICLot
					WHERE intLotId = @intLotId
				END
				ELSE
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

					SELECT @intItemLocationId = NULL

					SELECT @intItemLocationId = intItemLocationId
					FROM tblICItemLocation
					WHERE intItemId = @intItemId
						AND intLocationId = @intCompanyLocationId

					EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH
						,@strBatchId OUTPUT

					SELECT @dtmDate = dbo.fnGetBusinessDate(GETDATE(), @intCompanyLocationId)

					IF @dblLastCost IS NULL
					BEGIN
						SELECT @dblLastCost = t.dblStandardCost
						FROM tblICItemPricing t WITH (NOLOCK)
						WHERE t.intItemId = @intItemId
							AND t.intItemLocationId = @intItemLocationId
					END

					DELETE
					FROM @ItemsForPost

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
						,dblUOMQty = 1
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

					DELETE
					FROM @GLEntries

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
				,strAdjustmentNo
				)
			SELECT @intTrxSequenceNo
				,@strCompanyLocation
				,@dtmCreatedDate
				,@strCreatedBy
				,(
					CASE 
						WHEN @intTransactionTypeId = 8
							THEN 11
						WHEN @intTransactionTypeId = 10
							THEN 15
						WHEN @intTransactionTypeId = 20
							THEN 14
						END
					) AS intMessageTypeId
				,1 AS intStatusId
				,'Success' AS strStatusText
				,@strAdjustmentNo

			--Move to Ack
			INSERT INTO tblIPInventoryAdjustmentArchive (
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

			SET @ErrMsg = NULL
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
				,(
					CASE 
						WHEN @intTransactionTypeId = 8
							THEN 11
						WHEN @intTransactionTypeId = 10
							THEN 15
						WHEN @intTransactionTypeId = 20
							THEN 14
						END
					) AS intMessageTypeId
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
		FROM @tblIPInventoryAdjustmentStage
		WHERE intInventoryAdjustmentStageId > @intInventoryAdjustmentStageId
	END

	UPDATE tblIPInventoryAdjustmentStage
	SET intStatusId = NULL
	WHERE intInventoryAdjustmentStageId IN (
			SELECT intInventoryAdjustmentStageId
			FROM @tblIPInventoryAdjustmentStage
			)
		AND intStatusId = - 1

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
