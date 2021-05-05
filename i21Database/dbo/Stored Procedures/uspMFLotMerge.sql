﻿CREATE PROCEDURE [uspMFLotMerge] @intLotId INT
	,@intNewLotId INT
	,@dblMergeQty NUMERIC(38, 20)
	,@intMergeItemUOMId INT
	,@intUserId INT
	,@blnValidateLotReservation BIT = 0
	,@dtmDate DATETIME = NULL
	,@strReasonCode NVARCHAR(MAX) = NULL
	,@strNotes NVARCHAR(MAX) = NULL
AS
BEGIN TRY
	DECLARE @intItemId INT
		,@intLocationId INT
		,@intSubLocationId INT
		,@intStorageLocationId INT
		,@strLotNumber NVARCHAR(50)
		,@intSourceId INT
		,@intSourceTransactionTypeId INT
		,@intLotStatusId INT
		,@dblLotWeightPerUnit NUMERIC(38, 20)
		,@intInventoryAdjustmentId INT
		,@TransactionCount INT
		,@ErrMsg NVARCHAR(MAX)
		,@intNewLocationId INT
		,@intNewSubLocationId INT
		,@intNewStorageLocationId INT
		,@intNewItemUOMId INT
		,@intNewLotStatusId INT
		,@dblNewLotWeightPerUnit NUMERIC(38, 20)
		,@strNewLotNumber NVARCHAR(100)
		,@intSourceLotWeightUOM INT
		,@intDestinationLotWeightUOM INT
		,@dblAdjustByQuantity NUMERIC(38, 20)
		,@intWeightUOMId INT
		,@dblLotReservedQty NUMERIC(38, 20)
		,@dblWeight NUMERIC(38, 20)
		,@dblOldDestinationWeight NUMERIC(38, 20)
		,@dblOldSourceWeight NUMERIC(38, 20)
		,@dblMergeWeight NUMERIC(38, 20)
		,@strStorageLocationName NVARCHAR(50)
		,@strItemNumber NVARCHAR(50)
		,@strUnitMeasure NVARCHAR(50)
		,@intItemUOMId INT
		,@dblDefaultResidueQty NUMERIC(38, 20)
		,@intTransactionCount INT
		,@strDescription NVARCHAR(MAX)
		,@dtmSourceLotExpiryDate DATETIME
		,@dtmDestinationLotExpiryDate DATETIME
		,@strSourceCertificate NVARCHAR(50)
		,@intSourceProducerId INT
		,@strSourceCertificateId NVARCHAR(50)
		,@strSourceTrackingNumber NVARCHAR(255)
		,@strDestinationCertificate NVARCHAR(50)
		,@intDestinationProducerId INT
		,@strDestinationCertificateId NVARCHAR(50)
		,@strDestinationTrackingNumber NVARCHAR(255)
		,@intParentLotId INT

	SELECT @strDescription = Ltrim(isNULL(@strReasonCode, '') + ' ' + isNULL(@strNotes, ''))

	SELECT TOP 1 @dblDefaultResidueQty = ISNULL(dblDefaultResidueQty, 0.00001)
	FROM tblMFCompanyPreference

	SELECT @dblMergeWeight = @dblMergeQty

	SELECT @intItemId = intItemId
		,@intLocationId = intLocationId
		,@intSubLocationId = intSubLocationId
		,@intStorageLocationId = intStorageLocationId
		,@strLotNumber = strLotNumber
		,@intLotStatusId = intLotStatusId
		,@intNewLocationId = intLocationId
		,@dblLotWeightPerUnit = dblWeightPerQty
		,@intWeightUOMId = intWeightUOMId
		,@intSourceLotWeightUOM = intWeightUOMId
		,@dblWeight = dblWeight
		,@dblOldSourceWeight = CASE 
			WHEN intWeightUOMId IS NULL
				THEN dblQty
			ELSE dblWeight
			END
		,@intItemUOMId = intItemUOMId
		,@dtmSourceLotExpiryDate = dtmExpiryDate
		,@strSourceCertificate = strCertificate
		,@intSourceProducerId = intProducerId
		,@strSourceCertificateId = strCertificateId
		,@strSourceTrackingNumber = strTrackingNumber
	FROM tblICLot
	WHERE intLotId = @intLotId

	IF (
			CASE 
				WHEN @intItemUOMId = @intMergeItemUOMId
					AND @intWeightUOMId IS NOT NULL
					THEN - @dblMergeQty * @dblLotWeightPerUnit
				ELSE - @dblMergeQty
				END
			) > @dblOldSourceWeight
	BEGIN
		SELECT @strStorageLocationName = strName
		FROM tblICStorageLocation
		WHERE intStorageLocationId = @intStorageLocationId

		SELECT @strItemNumber = strItemNo
		FROM tblICItem
		WHERE intItemId = @intItemId

		SELECT @strUnitMeasure = UM.strUnitMeasure
		FROM tblICItemUOM U
		JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = U.intUnitMeasureId
		WHERE U.intItemUOMId = IsNULL(@intWeightUOMId, @intItemUOMId)

		SET @ErrMsg = 'Merge qty ' + LTRIM(CONVERT(NUMERIC(38, 4), @dblMergeQty)) + ' ' + @strUnitMeasure + ' is not available for lot ''' + @strLotNumber + ''' having item ''' + @strItemNumber + ''' in location ''' + @strStorageLocationName + '''.'

		RAISERROR (
				@ErrMsg
				,11
				,1
				)
	END

	SELECT @dblLotReservedQty = SUM(dbo.fnMFConvertQuantityToTargetItemUOM(intItemUOMId, ISNULL(@intWeightUOMId, @intItemUOMId), ISNULL(dblQty, 0)))
	FROM tblICStockReservation
	WHERE intLotId = @intLotId
		AND ISNULL(ysnPosted, 0) = 0

	IF @blnValidateLotReservation = 1
	BEGIN
		IF (
				@dblOldSourceWeight + (
					CASE 
						WHEN @intItemUOMId = @intMergeItemUOMId
							AND @intWeightUOMId IS NOT NULL
							THEN - @dblMergeQty * @dblLotWeightPerUnit
						ELSE - @dblMergeQty
						END
					)
				) < @dblLotReservedQty
		BEGIN
			RAISERROR (
					'There is reservation against this lot. Cannot proceed.'
					,16
					,1
					)
		END
	END

	SELECT @dblAdjustByQuantity = - @dblMergeQty

	SELECT @intNewLocationId = intLocationId
		,@intNewSubLocationId = intSubLocationId
		,@intNewStorageLocationId = intStorageLocationId
		,@intNewItemUOMId = intItemUOMId
		,@strNewLotNumber = strLotNumber
		,@intNewLotStatusId = intLotStatusId
		,@dblNewLotWeightPerUnit = dblWeightPerQty
		,@intDestinationLotWeightUOM = intWeightUOMId
		,@dblOldDestinationWeight = CASE 
			WHEN intWeightUOMId IS NULL
				THEN dblQty
			ELSE dblWeight
			END
		,@dtmDestinationLotExpiryDate = dtmExpiryDate
		,@strDestinationCertificate = strCertificate
		,@intDestinationProducerId = intProducerId
		,@strDestinationCertificateId = strCertificateId
		,@strDestinationTrackingNumber = strTrackingNumber
		,@intParentLotId = intParentLotId
	FROM tblICLot
	WHERE intLotId = @intNewLotId

	IF @dtmDate IS NULL
		SELECT @dtmDate = GETDATE()

	SELECT @intSourceId = 1
		,@intSourceTransactionTypeId = 8

	IF ISNULL(@strLotNumber, '') = ''
	BEGIN
		RAISERROR (
				'Supplied lot is not available.'
				,11
				,1
				)
	END

	IF @intNewLotStatusId <> @intLotStatusId
	BEGIN
		RAISERROR (
				'The status of the source and the destination lot differs, cannot merge'
				,11
				,1
				)
	END

	IF EXISTS (
			SELECT 1
			FROM tblWHSKU
			WHERE intLotId = @intLotId
			)
	BEGIN
		RAISERROR (
				'This lot is being managed in warehouse. All transactions should be done in warehouse module. You can only change the lot status from inventory view.'
				,11
				,1
				)
	END

	IF @intDestinationLotWeightUOM <> @intSourceLotWeightUOM
	BEGIN
		RAISERROR (
				'Lots with different unit of measure cannot be merged.'
				,11
				,1
				)
	END

	SELECT @intTransactionCount = @@TRANCOUNT

	IF @intSourceProducerId = @intDestinationProducerId
		AND @strSourceCertificate = @strDestinationCertificate
	BEGIN
		IF NOT (@strDestinationCertificateId LIKE '%' + @strSourceCertificateId + '%')
		BEGIN
			SELECT @strDestinationCertificateId = @strDestinationCertificateId + ', ' + @strSourceCertificateId
		END

		IF NOT (@strDestinationTrackingNumber LIKE '%' + @strSourceTrackingNumber + '%')
		BEGIN
			SELECT @strDestinationTrackingNumber = @strDestinationTrackingNumber + ', ' + @strSourceTrackingNumber
		END
	END
	ELSE
	BEGIN
		SELECT @intSourceProducerId = NULL
			,@strSourceCertificate = NULL
			,@strDestinationCertificateId = NULL
			,@strDestinationTrackingNumber = NULL
	END

	IF @intTransactionCount = 0
		BEGIN TRANSACTION

	EXEC uspICInventoryAdjustment_CreatePostLotMerge @intItemId = @intItemId
		,@dtmDate = @dtmDate
		,@intLocationId = @intLocationId
		,@intSubLocationId = @intSubLocationId
		,@intStorageLocationId = @intStorageLocationId
		,@strLotNumber = @strLotNumber
		,@intNewLocationId = @intNewLocationId
		,@intNewSubLocationId = @intNewSubLocationId
		,@intNewStorageLocationId = @intNewStorageLocationId
		,@strNewLotNumber = @strNewLotNumber
		,@dblAdjustByQuantity = @dblAdjustByQuantity
		,@intItemUOMId = @intMergeItemUOMId
		,@dblNewSplitLotQuantity = NULL
		,@dblNewWeight = NULL
		,@intNewItemUOMId = NULL
		,@intNewWeightUOMId = NULL
		,@dblNewUnitCost = NULL
		,@intSourceId = @intSourceId
		,@intSourceTransactionTypeId = @intSourceTransactionTypeId
		,@intEntityUserSecurityId = @intUserId
		,@intInventoryAdjustmentId = @intInventoryAdjustmentId OUTPUT
		,@strDescription = @strDescription

	EXEC dbo.uspMFAdjustInventory @dtmDate = @dtmDate
		,@intTransactionTypeId = 19
		,@intItemId = @intItemId
		,@intSourceLotId = @intLotId
		,@intDestinationLotId = @intNewLotId
		,@dblQty = @dblAdjustByQuantity
		,@intItemUOMId = @intMergeItemUOMId
		,@intOldItemId = NULL
		,@dtmOldExpiryDate = NULL
		,@dtmNewExpiryDate = NULL
		,@intOldLotStatusId = NULL
		,@intNewLotStatusId = NULL
		,@intUserId = @intUserId
		,@strNote = @strNotes
		,@strReason = @strReasonCode
		,@intLocationId = @intLocationId
		,@intInventoryAdjustmentId = @intInventoryAdjustmentId

	DECLARE @intUnitMeasureId INT
		,@strUserName NVARCHAR(50)
		,@strItemNo NVARCHAR(50)
		,@strSubLocationName NVARCHAR(50)
		,@strName NVARCHAR(50)
		,@strNewSubLocationName NVARCHAR(50)
		,@strNewName NVARCHAR(50)
		,@strParentLotNumber NVARCHAR(50)
		,@strLotOrigin NVARCHAR(50)
		,@intStockItemUOMId INT


	SELECT @strUserName = strUserName
	FROM tblSMUserSecurity
	WHERE intEntityId = @intUserId

	SELECT @strItemNo = strItemNo
	FROM tblICItem
	WHERE intItemId = @intItemId

	SELECT @strLotOrigin = strLotOrigin
	FROM tblSMCompanyLocation
	WHERE intCompanyLocationId = @intLocationId

	SELECT @strSubLocationName = strSubLocationName
	FROM tblSMCompanyLocationSubLocation
	WHERE intCompanyLocationSubLocationId = @intSubLocationId

	SELECT @strName = strName
	FROM tblICStorageLocation
	WHERE intStorageLocationId = @intStorageLocationId

	SELECT @strNewSubLocationName = strSubLocationName
	FROM tblSMCompanyLocationSubLocation
	WHERE intCompanyLocationSubLocationId = @intNewSubLocationId

	SELECT @strNewName = strName
	FROM tblICStorageLocation
	WHERE intStorageLocationId = @intNewStorageLocationId

	SELECT @strParentLotNumber = strParentLotNumber
	FROM tblICParentLot
	WHERE intParentLotId = @intParentLotId

	SELECT @intStockItemUOMId = intItemUOMId
	FROM tblICItemUOM
	WHERE intItemId = @intItemId
		AND ysnStockUnit = 1

	IF @intMergeItemUOMId <> @intStockItemUOMId
	BEGIN
		SELECT @dblMergeQty = dbo.fnMFConvertQuantityToTargetItemUOM(@intMergeItemUOMId, @intStockItemUOMId, @dblMergeQty)

		SELECT @intMergeItemUOMId = @intStockItemUOMId
	END

	SELECT @intUnitMeasureId = intUnitMeasureId
	FROM tblICItemUOM
	WHERE intItemUOMId = @intMergeItemUOMId

	SELECT @strUnitMeasure = strUnitMeasure
	FROM tblICUnitMeasure
	WHERE intUnitMeasureId = @intUnitMeasureId

	INSERT INTO tblIPLotMergeFeed (
		strCompanyLocation
		,intActionId
		,dtmCreatedDate
		,strCreatedByUser
		,intTransactionTypeId
		,strStorageLocation
		,strItemNo
		,strMotherLotNo
		,strLotNo
		,strStorageUnit
		,strDestinationStorageLocation
		,strDestinationStorageUnit
		,strDestinationLotNo
		,dblQuantity
		,strQuantityUOM
		,strReasonCode
		,strNotes
		)
	SELECT strCompanyLocation = @strLotOrigin
		,intActionId = 1
		,dtmCreatedDate = @dtmDate
		,strCreatedByUser = @strUserName
		,intTransactionTypeId = 19
		,strStorageLocation = @strSubLocationName
		,strItemNo = @strItemNo
		,strMotherLotNo = @strParentLotNumber
		,strLotNo = @strLotNumber
		,strStorageUnit = @strName
		,strDestinationStorageLocation = @strNewSubLocationName
		,strDestinationStorageUnit = @strNewName
		,strDestinationLotNo = @strNewLotNumber
		,dblQuantity = @dblMergeQty
		,strQuantityUOM = @strUnitMeasure
		,strReasonCode = @strReasonCode
		,strNotes = @strNotes

	UPDATE tblICLot
	SET intProducerId = @intSourceProducerId
		,strCertificate = @strSourceCertificate
		,strCertificateId = @strDestinationCertificateId
		,strTrackingNumber = @strDestinationTrackingNumber
	WHERE intLotId = @intNewLotId

	IF EXISTS (
			SELECT 1
			FROM tblICLot
			WHERE dblQty <> dblWeight
				AND intItemUOMId = intWeightUOMId
				AND intLotId = @intLotId
			)
	BEGIN
		DECLARE @dblLotQty NUMERIC(38, 20)

		SELECT @dblLotQty = dblQty
		FROM tblICLot
		WHERE intLotId = @intLotId

		EXEC dbo.uspMFLotAdjustQty @intLotId = @intLotId
			,@dblNewLotQty = @dblLotQty
			,@intAdjustItemUOMId = @intItemUOMId
			,@intUserId = @intUserId
			,@strReasonCode = 'Weight qty same'
			,@strNotes = 'Weight qty same'
	END

	IF (
			(
				SELECT dblWeight
				FROM dbo.tblICLot
				WHERE intLotId = @intLotId
				) < @dblDefaultResidueQty
			AND (
				SELECT dblWeight
				FROM dbo.tblICLot
				WHERE intLotId = @intLotId
				) > 0
			)
		OR (
			(
				SELECT dblQty
				FROM dbo.tblICLot
				WHERE intLotId = @intLotId
				) < @dblDefaultResidueQty
			AND (
				SELECT dblQty
				FROM dbo.tblICLot
				WHERE intLotId = @intLotId
				) > 0
			)
	BEGIN
		EXEC dbo.uspMFLotAdjustQty @intLotId = @intLotId
			,@dblNewLotQty = 0
			,@intAdjustItemUOMId = @intItemUOMId
			,@intUserId = @intUserId
			,@strReasonCode = 'Residue qty clean up'
			,@strNotes = 'Residue qty clean up'
	END

	IF @dtmDestinationLotExpiryDate > @dtmSourceLotExpiryDate
	BEGIN
		EXEC [uspMFSetLotExpiryDate] @intLotId = @intNewLotId
			,@dtmNewExpiryDate = @dtmSourceLotExpiryDate
			,@intUserId = @intUserId
			,@strReasonCode = NULL
			,@strNotes = NULL
			,@dtmDate = @dtmDate
			,@ysnBulkChange = 0
	END

	IF @intTransactionCount = 0
		COMMIT TRANSACTION
END TRY

BEGIN CATCH
	IF XACT_STATE() != 0
		AND @intTransactionCount = 0
		ROLLBACK TRANSACTION

	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
