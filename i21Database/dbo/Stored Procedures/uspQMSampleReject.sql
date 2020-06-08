CREATE PROCEDURE uspQMSampleReject @strXml NVARCHAR(MAX)
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @idoc INT
	DECLARE @ErrMsg NVARCHAR(MAX)

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXml

	DECLARE @intSampleId INT
	DECLARE @intProductTypeId INT
	DECLARE @intProductValueId INT
	DECLARE @intLotStatusId INT
	DECLARE @intOrgLotStatusId INT
	DECLARE @intLastModifiedUserId INT
	DECLARE @dtmLastModified DATETIME
	DECLARE @strLotNumber NVARCHAR(50)
	DECLARE @intItemId INT
	DECLARE @intLocationId INT
	DECLARE @intSubLocationId INT
	DECLARE @intStorageLocationId INT
	DECLARE @intCurrentLotStatusId INT
	DECLARE @intLotId INT
	DECLARE @intContractDetailId INT
	DECLARE @intLoadDetailContainerLinkId INT
	DECLARE @intSampleStatusId INT
	DECLARE @ysnRejectLGContainer BIT
	DECLARE @intUserSampleApproval INT
	DECLARE @intApproveRejectUserId INT
	DECLARE @intSampleItemId INT
	DECLARE @intSampleControlPointId INT
	DECLARE @intSeqNo INT
	DECLARE @strMainLotNumber NVARCHAR(50)
	DECLARE @strApprovalBase NVARCHAR(50)
	DECLARE @strContainerNumber NVARCHAR(100)
	DECLARE @strLotAlias NVARCHAR(50)
		,@strWarehouseRefNo NVARCHAR(50)
		,@intParentLotId INT
		,@strChildLotNumber NVARCHAR(50)
		,@ysnEnableParentLot BIT

	SELECT @intSampleId = intSampleId
		,@intProductTypeId = intProductTypeId
		,@intProductValueId = intProductValueId
		,@intLotStatusId = intLotStatusId
		,@intLastModifiedUserId = intLastModifiedUserId
		,@dtmLastModified = dtmLastModified
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intSampleId INT
			,intProductTypeId INT
			,intProductValueId INT
			,intLotStatusId INT
			,intLastModifiedUserId INT
			,dtmLastModified DATETIME
			)

	SELECT @intOrgLotStatusId = @intLotStatusId

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

	if @intProductTypeId=11
	Begin
		SELECT @strWarehouseRefNo = LI.strWarehouseRefNo
			,@intParentLotId = L.intParentLotId
		FROM dbo.tblICLot L
		JOIN dbo.tblMFLotInventory LI ON LI.intLotId = L.intLotId
		WHERE L.strLotNumber = @strChildLotNumber
	End
	Else
	Begin
		SELECT @strWarehouseRefNo = LI.strWarehouseRefNo
		,@intParentLotId = L.intParentLotId
		FROM dbo.tblICLot L
		JOIN dbo.tblMFLotInventory LI ON LI.intLotId = L.intLotId
		WHERE L.strLotNumber = @strLotNumber
	End


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
			AND PL.intParentLotId = @intProductValueId
		JOIN dbo.tblMFLotInventory AS LI ON L.intLotId = LI.intLotId
	END
	ELSE IF @intSampleControlPointId = 14
		AND @strApprovalBase = 'Container'
	BEGIN
		IF @strContainerNumber <> ''
		BEGIN
			UPDATE LI
			SET intBondStatusId = @intLotStatusId
			FROM dbo.tblICLot AS L
			JOIN dbo.tblMFLotInventory AS LI ON L.intLotId = LI.intLotId
			JOIN dbo.tblICInventoryReceiptItemLot RIL ON RIL.intLotId = L.intLotId
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
		IF @strWarehouseRefNo <> ''
		BEGIN
			UPDATE LI
			SET intBondStatusId = @intLotStatusId
			FROM dbo.tblICLot AS L
			JOIN dbo.tblMFLotInventory AS LI ON L.intLotId = LI.intLotId
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
		IF @strWarehouseRefNo <> ''
		BEGIN
			UPDATE LI
			SET intBondStatusId = @intLotStatusId
			FROM dbo.tblICLot AS L
			JOIN dbo.tblMFLotInventory AS LI ON L.intLotId = LI.intLotId
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

	SELECT TOP 1 @intUserSampleApproval = ISNULL(intUserSampleApproval, 0)
	FROM tblQMCompanyPreference

	IF @intUserSampleApproval <> 0 -- No Check
	BEGIN
		IF @intSampleStatusId = 3 -- Only for Approved to Rejected
		BEGIN
			IF @intApproveRejectUserId <> @intLastModifiedUserId
			BEGIN
				IF @intUserSampleApproval = 1 -- User Check
				BEGIN
					RAISERROR (
							'Sample is %s by different %s. You do not have permission to %s it.'
							,11
							,1
							,'approved'
							,'user'
							,'reject'
							)
				END
				ELSE IF @intUserSampleApproval = 2 -- User Role Check
				BEGIN
					DECLARE @intApproveRejectUserRoleID INT
					DECLARE @intUserRoleID INT

					SELECT @intApproveRejectUserRoleID = intUserRoleID
					FROM tblSMUserSecurity
					WHERE [intEntityId] = @intApproveRejectUserId

					SELECT @intUserRoleID = intUserRoleID
					FROM tblSMUserSecurity
					WHERE [intEntityId] = @intLastModifiedUserId

					IF @intApproveRejectUserRoleID <> @intUserRoleID
					BEGIN
						RAISERROR (
								'Sample is %s by different %s. You do not have permission to %s it.'
								,11
								,1
								,'approved'
								,'user role'
								,'reject'
								)
					END
				END
			END
		END
	END

	SELECT TOP 1 @ysnRejectLGContainer = ISNULL(ysnRejectLGContainer, 0)
	FROM tblQMCompanyPreference

	IF @ysnRejectLGContainer = 1
	BEGIN
		IF @intContractDetailId IS NOT NULL
			AND @intLoadDetailContainerLinkId IS NOT NULL
		BEGIN
			EXEC uspLGRejectContainerFromQuality @intLoadDetailContainerLinkId
				,@intContractDetailId
				,1
				,@intLastModifiedUserId
		END
	END

	-- Sample Approve by Container in Sample Type / Approve by Lot / Parent Lot based on Company Preference
	IF (
			@intProductTypeId = 6
			OR @intProductTypeId = 11
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
				SELECT L.intLotId
					,L.strLotNumber
					,L.intItemId
					,L.intLocationId
					,L.intSubLocationId
					,L.intStorageLocationId
					,L.intLotStatusId
				FROM tblICLot L
				JOIN tblICInventoryReceiptItemLot RIL ON RIL.intLotId = L.intLotId
				WHERE RIL.strContainerNo = @strContainerNumber
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

			IF EXISTS (
					SELECT *
					FROM tblQMControlPointLotStatus
					WHERE intCurrentLotStatusId = @intCurrentLotStatusId
						AND intControlPointId = @intSampleControlPointId
						AND ysnApprove = 0
					)
			BEGIN
				SELECT @intLotStatusId = intLotStatusId
				FROM tblQMControlPointLotStatus
				WHERE intCurrentLotStatusId = @intCurrentLotStatusId
					AND intControlPointId = @intSampleControlPointId
					AND ysnApprove = 0
			END

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

	UPDATE dbo.tblQMSample
	SET intConcurrencyId = Isnull(intConcurrencyId, 0) + 1
		,intSampleStatusId = 4 -- Rejected
		,intLotStatusId = (
			CASE 
				WHEN @intProductTypeId IN (
						6
						,11
						)
					THEN @intLotStatusId
				ELSE intLotStatusId
				END
			)
		,intTestedById = x.intLastModifiedUserId
		,dtmTestedOn = x.dtmLastModified
		,intLastModifiedUserId = x.intLastModifiedUserId
		,dtmLastModified = x.dtmLastModified
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intLastModifiedUserId INT
			,dtmLastModified DATETIME
			) x
	WHERE dbo.tblQMSample.intSampleId = @intSampleId

	IF (@intSampleId > 0)
	BEGIN
		EXEC uspSMAuditLog @keyValue = @intSampleId
			,@screenName = 'Quality.view.QualitySample'
			,@entityId = @intLastModifiedUserId
			,@actionType = 'Rejected'
			,@changeDescription = ''
			,@fromValue = ''
			,@toValue = ''
	END

	EXEC uspQMInterCompanyPreStageSample @intSampleId

	EXEC sp_xml_removedocument @idoc

	COMMIT TRAN
END TRY

BEGIN CATCH
	IF XACT_STATE() != 0
		AND @@TRANCOUNT > 0
		ROLLBACK TRANSACTION

	SET @ErrMsg = ERROR_MESSAGE()

	IF @idoc <> 0
		EXEC sp_xml_removedocument @idoc

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
