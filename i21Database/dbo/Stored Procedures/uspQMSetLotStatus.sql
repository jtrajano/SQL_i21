CREATE PROCEDURE uspQMSetLotStatus @intSampleId INT
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intProductTypeId INT
		,@intProductValueId INT
		,@intLotStatusId INT
		,@dtmTestedOn DATETIME
		,@intTestedById INT
		,@dtmLastModified DATETIME
		,@intLastModifiedUserId INT
		,@intCurrentSampleStatusId INT
	DECLARE @intOrgLotStatusId INT
		,@ysnChangeLotStatusOnApproveforPreSanitizeLot BIT
		,@ysnEnableParentLot BIT
	DECLARE @intContractDetailId INT
		,@intLoadDetailContainerLinkId INT
		,@intSampleStatusId INT
		,@intApproveRejectUserId INT
		,@intSampleItemId INT
		,@intSampleControlPointId INT
		,@intCurrentLotStatusId INT
		,@strApprovalBase NVARCHAR(50)
		,@strContainerNumber NVARCHAR(100)
		,@strChildLotNumber NVARCHAR(50)
		,@intSampleTypeId INT
		,@strMarks NVARCHAR(100)
		,@strLotNumber NVARCHAR(50)
		,@strWarehouseRefNo NVARCHAR(50)
		,@intParentLotId INT
		,@strMainLotNumber NVARCHAR(50)
		,@strLotAlias NVARCHAR(50)
	DECLARE @intSeqNo INT
		,@intLotId INT
		,@intItemId INT
		,@intLocationId INT
		,@intSubLocationId INT
		,@intStorageLocationId INT

	SELECT @intProductTypeId = intProductTypeId
		,@intProductValueId = intProductValueId
		,@intLotStatusId = intLotStatusId
		,@dtmTestedOn = dtmTestedOn
		,@intTestedById = intTestedById
		,@dtmLastModified = dtmLastModified
		,@intLastModifiedUserId = intLastModifiedUserId
	FROM tblQMSample S
	WHERE S.intSampleId = @intSampleId

	IF @intTestedById IS NULL
		SELECT @intTestedById = @intLastModifiedUserId

	SELECT @intOrgLotStatusId = @intLotStatusId

	SELECT @ysnChangeLotStatusOnApproveforPreSanitizeLot = ysnChangeLotStatusOnApproveforPreSanitizeLot
	FROM dbo.tblQMCompanyPreference

	SELECT TOP 1 @ysnEnableParentLot = ISNULL(ysnEnableParentLot, 0)
	FROM tblMFCompanyPreference

	BEGIN TRAN

	SELECT @intContractDetailId = S.intContractDetailId
		,@intLoadDetailContainerLinkId = S.intLoadDetailContainerLinkId
		,@intSampleStatusId = S.intSampleStatusId
		,@intApproveRejectUserId = S.intTestedById
		,@intSampleItemId = S.intItemId
		,@intSampleControlPointId = ST.intControlPointId
		,@intCurrentLotStatusId = S.intLotStatusId
		,@strApprovalBase = ISNULL(ST.strApprovalBase, '')
		,@strContainerNumber = S.strContainerNumber
		,@strChildLotNumber = strChildLotNumber
		,@intSampleTypeId = ST.intSampleTypeId
		,@strMarks = S.strMarks
	FROM tblQMSample S
	JOIN tblQMSampleType ST ON ST.intSampleTypeId = S.intSampleTypeId
	WHERE S.intSampleId = @intSampleId

	IF @strApprovalBase = ''
	BEGIN
		IF @intProductTypeId = 11 -- Parent Lot
			SET @strApprovalBase = 'Parent Lot'
		ELSE IF @intProductTypeId = 6 -- Lot
			SET @strApprovalBase = 'Lot'
	END

	SELECT @strLotNumber = strLotNumber
	FROM tblICLot
	WHERE intLotId = @intProductValueId

	IF @intProductTypeId = 11
	BEGIN
		SELECT @strWarehouseRefNo = LI.strWarehouseRefNo
			,@intParentLotId = L.intParentLotId
		FROM dbo.tblICLot L
		JOIN dbo.tblMFLotInventory LI ON LI.intLotId = L.intLotId
		WHERE L.strLotNumber = @strChildLotNumber
	END
	ELSE
	BEGIN
		SELECT @strWarehouseRefNo = LI.strWarehouseRefNo
			,@intParentLotId = L.intParentLotId
		FROM dbo.tblICLot L
		JOIN dbo.tblMFLotInventory LI ON LI.intLotId = L.intLotId
		WHERE L.strLotNumber = @strLotNumber
	END

	IF @intProductTypeId = 6
		AND @intSampleControlPointId = 14
		AND @strApprovalBase = 'Lot'
	BEGIN
		UPDATE tblMFLotInventory
		SET intBondStatusId = @intLotStatusId
		FROM tblMFLotInventory LI
		JOIN tblICLot L ON L.intLotId = LI.intLotId
		WHERE L.strLotNumber = @strLotNumber
	END
	ELSE IF @intProductTypeId = 11
		AND @intSampleControlPointId = 14
		AND @strApprovalBase = 'Parent Lot'
	BEGIN
		UPDATE LI
		SET intBondStatusId = @intLotStatusId
		FROM dbo.tblICParentLot AS PL
		JOIN dbo.tblICLot AS L ON PL.intParentLotId = L.intParentLotId
			AND L.ysnProduced = 0
			AND PL.intParentLotId = @intProductValueId
		JOIN dbo.tblMFLotInventory AS LI ON L.intLotId = LI.intLotId
	END
	ELSE IF @intSampleControlPointId = 14
		AND @strApprovalBase = 'Container'
	BEGIN
		IF IsNULL(@strContainerNumber, '') <> ''
		BEGIN
			UPDATE LI
			SET intBondStatusId = @intLotStatusId
			FROM dbo.tblICLot AS L
			JOIN dbo.tblMFLotInventory AS LI ON L.intLotId = LI.intLotId
			JOIN dbo.tblICInventoryReceiptItemLot RIL ON RIL.strLotNumber = L.strLotNumber
			WHERE RIL.strContainerNo = @strContainerNumber
		END
		ELSE
		BEGIN
			UPDATE tblMFLotInventory
			SET intBondStatusId = @intLotStatusId
			WHERE intLotId = @intProductValueId
		END
	END
	ELSE IF @intSampleControlPointId = 14
		AND @strApprovalBase = 'Warehouse Ref No'
	BEGIN
		IF isNULL(@strWarehouseRefNo, '') <> ''
		BEGIN
			UPDATE LI
			SET intBondStatusId = @intLotStatusId
			FROM dbo.tblICLot AS L
			JOIN tblMFLotInventory LI ON LI.intLotId = L.intLotId
			WHERE LI.strWarehouseRefNo = @strWarehouseRefNo
		END
		ELSE
		BEGIN
			UPDATE tblMFLotInventory
			SET intBondStatusId = @intLotStatusId
			WHERE intLotId = @intProductValueId
		END
	END
	ELSE IF @intSampleControlPointId = 14
		AND @strApprovalBase = 'Warehouse Ref No & Parent Lot'
	BEGIN
		IF isNULL(@strWarehouseRefNo, '') <> ''
		BEGIN
			UPDATE LI
			SET intBondStatusId = @intLotStatusId
			FROM dbo.tblICLot AS L
			JOIN tblMFLotInventory LI ON LI.intLotId = L.intLotId
			WHERE LI.strWarehouseRefNo = @strWarehouseRefNo
				AND L.intParentLotId = @intParentLotId
		END
		ELSE
		BEGIN
			UPDATE tblMFLotInventory
			SET intBondStatusId = @intLotStatusId
			WHERE intLotId = @intProductValueId
		END
	END
	ELSE IF @intSampleControlPointId = 14
		AND @strApprovalBase = 'Item & Parent Lot'
	BEGIN
		UPDATE LI
		SET intBondStatusId = @intLotStatusId
		FROM dbo.tblICLot AS L
		JOIN tblMFLotInventory LI ON LI.intLotId = L.intLotId
		WHERE L.intItemId = @intSampleItemId
			AND L.intParentLotId = @intParentLotId
	END

	-- Sample Approve by Container in Sample Type / Approve by Lot / Parent Lot based on Company Preference
	IF (
			@intProductTypeId = 6
			OR @intProductTypeId = 11
			OR @intProductTypeId = 9
			)
		AND (@strApprovalBase <> '')
	BEGIN
		DECLARE @LotData TABLE (
			intSeqNo INT IDENTITY(1, 1)
			,intLotId INT
			,strLotNumber NVARCHAR(50)
			,intItemId INT
			,intLocationId INT
			,intSubLocationId INT
			,intStorageLocationId INT
			,intLotStatusId INT
			)

		IF @strApprovalBase = 'Lot'
		BEGIN
			IF @ysnEnableParentLot = 0
			BEGIN
				SELECT @strMainLotNumber = strLotNumber
				FROM tblICLot
				WHERE intLotId = @intProductValueId
			END
			ELSE
			BEGIN
				SELECT @strMainLotNumber = @strChildLotNumber
			END

			INSERT INTO @LotData (
				intLotId
				,strLotNumber
				,intItemId
				,intLocationId
				,intSubLocationId
				,intStorageLocationId
				,intLotStatusId
				)
			SELECT intLotId
				,strLotNumber
				,intItemId
				,intLocationId
				,intSubLocationId
				,intStorageLocationId
				,intLotStatusId
			FROM tblICLot
			WHERE strLotNumber = @strMainLotNumber
		END
		ELSE IF @strApprovalBase = 'Parent Lot'
		BEGIN
			INSERT INTO @LotData (
				intLotId
				,strLotNumber
				,intItemId
				,intLocationId
				,intSubLocationId
				,intStorageLocationId
				,intLotStatusId
				)
			SELECT intLotId
				,strLotNumber
				,intItemId
				,intLocationId
				,intSubLocationId
				,intStorageLocationId
				,intLotStatusId
			FROM tblICLot
			WHERE intParentLotId = @intProductValueId
				AND intItemId = @intSampleItemId
		END
		ELSE IF @strApprovalBase = 'Warehouse Ref No'
		BEGIN
			IF @strWarehouseRefNo IS NULL
				OR @strWarehouseRefNo = ''
			BEGIN
				SELECT @strMainLotNumber = strLotNumber
				FROM tblICLot
				WHERE intLotId = @intProductValueId

				INSERT INTO @LotData (
					intLotId
					,strLotNumber
					,intItemId
					,intLocationId
					,intSubLocationId
					,intStorageLocationId
					,intLotStatusId
					)
				SELECT L.intLotId
					,L.strLotNumber
					,L.intItemId
					,L.intLocationId
					,L.intSubLocationId
					,L.intStorageLocationId
					,L.intLotStatusId
				FROM tblICLot L
				WHERE strLotNumber = @strMainLotNumber
			END
			ELSE
			BEGIN
				INSERT INTO @LotData (
					intLotId
					,strLotNumber
					,intItemId
					,intLocationId
					,intSubLocationId
					,intStorageLocationId
					,intLotStatusId
					)
				SELECT L.intLotId
					,L.strLotNumber
					,L.intItemId
					,L.intLocationId
					,L.intSubLocationId
					,L.intStorageLocationId
					,L.intLotStatusId
				FROM tblICLot L
				JOIN tblMFLotInventory LI ON LI.intLotId = L.intLotId
				WHERE LI.strWarehouseRefNo = @strWarehouseRefNo
			END
		END
		ELSE IF @strApprovalBase = 'Warehouse Ref No & Parent Lot'
		BEGIN
			IF @strWarehouseRefNo IS NULL
				OR @strWarehouseRefNo = ''
			BEGIN
				SELECT @strMainLotNumber = strLotNumber
				FROM tblICLot
				WHERE intLotId = @intProductValueId

				INSERT INTO @LotData (
					intLotId
					,strLotNumber
					,intItemId
					,intLocationId
					,intSubLocationId
					,intStorageLocationId
					,intLotStatusId
					)
				SELECT L.intLotId
					,L.strLotNumber
					,L.intItemId
					,L.intLocationId
					,L.intSubLocationId
					,L.intStorageLocationId
					,L.intLotStatusId
				FROM tblICLot L
				WHERE strLotNumber = @strMainLotNumber
			END
			ELSE
			BEGIN
				INSERT INTO @LotData (
					intLotId
					,strLotNumber
					,intItemId
					,intLocationId
					,intSubLocationId
					,intStorageLocationId
					,intLotStatusId
					)
				SELECT L.intLotId
					,L.strLotNumber
					,L.intItemId
					,L.intLocationId
					,L.intSubLocationId
					,L.intStorageLocationId
					,L.intLotStatusId
				FROM tblICLot L
				JOIN tblMFLotInventory LI ON LI.intLotId = L.intLotId
				WHERE LI.strWarehouseRefNo = @strWarehouseRefNo
					AND L.intParentLotId = @intParentLotId
			END
		END
		ELSE IF @strApprovalBase = 'Container'
		BEGIN
			IF @strContainerNumber IS NULL
				OR @strContainerNumber = ''
			BEGIN
				SELECT @strMainLotNumber = strLotNumber
				FROM tblICLot
				WHERE intLotId = @intProductValueId

				INSERT INTO @LotData (
					intLotId
					,strLotNumber
					,intItemId
					,intLocationId
					,intSubLocationId
					,intStorageLocationId
					,intLotStatusId
					)
				SELECT L.intLotId
					,L.strLotNumber
					,L.intItemId
					,L.intLocationId
					,L.intSubLocationId
					,L.intStorageLocationId
					,L.intLotStatusId
				FROM tblICLot L
				WHERE strLotNumber = @strMainLotNumber
			END
			ELSE
			BEGIN
				INSERT INTO @LotData (
					intLotId
					,strLotNumber
					,intItemId
					,intLocationId
					,intSubLocationId
					,intStorageLocationId
					,intLotStatusId
					)
				SELECT L.intLotId
					,L.strLotNumber
					,L.intItemId
					,L.intLocationId
					,L.intSubLocationId
					,L.intStorageLocationId
					,L.intLotStatusId
				FROM tblICLot L
				WHERE L.strContainerNo = @strContainerNumber
					AND IsNULL(L.strMarkings, '') = IsNULL(@strMarks, '')
			END
		END
		ELSE IF @strApprovalBase = 'Work Order'
		BEGIN
			SELECT @strLotAlias = strLotAlias
			FROM tblICLot
			WHERE intLotId = @intProductValueId

			IF @strLotAlias IS NULL
				OR @strLotAlias = ''
			BEGIN
				SELECT @strMainLotNumber = strLotNumber
				FROM tblICLot
				WHERE intLotId = @intProductValueId

				INSERT INTO @LotData (
					intLotId
					,strLotNumber
					,intItemId
					,intLocationId
					,intSubLocationId
					,intStorageLocationId
					,intLotStatusId
					)
				SELECT intLotId
					,strLotNumber
					,intItemId
					,intLocationId
					,intSubLocationId
					,intStorageLocationId
					,intLotStatusId
				FROM tblICLot
				WHERE strLotNumber = @strMainLotNumber
			END
			ELSE
			BEGIN
				INSERT INTO @LotData (
					intLotId
					,strLotNumber
					,intItemId
					,intLocationId
					,intSubLocationId
					,intStorageLocationId
					,intLotStatusId
					)
				SELECT intLotId
					,strLotNumber
					,intItemId
					,intLocationId
					,intSubLocationId
					,intStorageLocationId
					,intLotStatusId
				FROM tblICLot
				WHERE strLotAlias = @strLotAlias
			END
		END
		ELSE IF @strApprovalBase = 'Item & Parent Lot'
		BEGIN
			INSERT INTO @LotData (
				intLotId
				,strLotNumber
				,intItemId
				,intLocationId
				,intSubLocationId
				,intStorageLocationId
				,intLotStatusId
				)
			SELECT intLotId
				,strLotNumber
				,intItemId
				,intLocationId
				,intSubLocationId
				,intStorageLocationId
				,intLotStatusId
			FROM tblICLot
			WHERE intParentLotId = @intParentLotId
				AND intItemId = @intSampleItemId
				AND intStorageLocationId IS NOT NULL
		END

		SELECT @intSeqNo = MIN(intSeqNo)
		FROM @LotData

		WHILE (@intSeqNo > 0)
		BEGIN
			SELECT @intLotStatusId = @intOrgLotStatusId

			SELECT @intLotId = intLotId
				,@strLotNumber = strLotNumber
				,@intItemId = intItemId
				,@intLocationId = intLocationId
				,@intSubLocationId = intSubLocationId
				,@intStorageLocationId = intStorageLocationId
				,@intCurrentLotStatusId = intLotStatusId
			FROM @LotData
			WHERE intSeqNo = @intSeqNo

			IF @intCurrentLotStatusId = 4 -- Pre-Sanitized
			BEGIN
				IF @ysnChangeLotStatusOnApproveforPreSanitizeLot = 0
					SET @intLotStatusId = @intCurrentLotStatusId
			END

			--IF EXISTS (
			--		SELECT *
			--		FROM tblQMControlPointLotStatus
			--		WHERE intCurrentLotStatusId = @intCurrentLotStatusId
			--			AND intControlPointId = @intSampleControlPointId
			--			AND ysnApprove = 1
			--		)
			--BEGIN
			--	SELECT @intLotStatusId = intLotStatusId
			--	FROM tblQMControlPointLotStatus
			--	WHERE intCurrentLotStatusId = @intCurrentLotStatusId
			--		AND intControlPointId = @intSampleControlPointId
			--		AND ysnApprove = 1
			--END

			--IF @intProductTypeId=9
			--BEGIN
			--	SELECT @intLotStatusId = intApprovalLotStatusId
			--	FROM tblQMSampleType
			--	WHERE intSampleTypeId = @intSampleTypeId
			--END

			IF @intCurrentLotStatusId <> @intLotStatusId
				AND @intSampleControlPointId <> 14
				AND IsNULL(@intLotStatusId, 0) <> 0
			BEGIN
				EXEC uspMFSetLotStatus @intLotId = @intLotId
					,@intNewLotStatusId = @intLotStatusId
					,@intUserId = @intLastModifiedUserId
			END

			SELECT @intSeqNo = MIN(intSeqNo)
			FROM @LotData
			WHERE intSeqNo > @intSeqNo
		END
	END

	COMMIT TRAN
END TRY

BEGIN CATCH
	IF XACT_STATE() != 0
		AND @@TRANCOUNT > 0
		ROLLBACK TRANSACTION

	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
