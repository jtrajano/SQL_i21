﻿CREATE PROCEDURE uspQMSampleApprove @strXml NVARCHAR(MAX)
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
	DECLARE @intLastModifiedUserId INT
	DECLARE @dtmLastModified DATETIME
	DECLARE @strLotNumber NVARCHAR(50)
	DECLARE @intItemId INT
	DECLARE @intLocationId INT
	DECLARE @intSubLocationId INT
	DECLARE @intStorageLocationId INT
	DECLARE @intCurrentLotStatusId INT
	DECLARE @intLotId INT
	DECLARE @ysnChangeLotStatusOnApproveforPreSanitizeLot BIT
	DECLARE @intContractDetailId INT
	DECLARE @intLoadDetailContainerLinkId INT
	DECLARE @intSampleStatusId INT
	DECLARE @ysnRejectLGContainer BIT
	DECLARE @intUserSampleApproval INT
	DECLARE @intApproveRejectUserId INT
	DECLARE @intSampleItemId INT
	DECLARE @ysnRequireCustomerApproval BIT
	DECLARE @intSampleControlPointId INT
	DECLARE @intSeqNo INT
	DECLARE @strMainLotNumber NVARCHAR(50)
	DECLARE @strApprovalBase NVARCHAR(50)
	DECLARE @strContainerNumber NVARCHAR(100)
	DECLARE @strLotAlias NVARCHAR(50)

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

	SELECT @ysnChangeLotStatusOnApproveforPreSanitizeLot = ysnChangeLotStatusOnApproveforPreSanitizeLot
	FROM dbo.tblQMCompanyPreference

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

	SELECT @ysnRequireCustomerApproval = ISNULL(ysnRequireCustomerApproval, 0)
	FROM tblICItem
	WHERE intItemId = @intSampleItemId

	IF @ysnRequireCustomerApproval = 1
		AND @intProductTypeId = 6
		AND @intSampleControlPointId = 14
		AND @strApprovalBase = 'Lot'
	BEGIN
		UPDATE tblMFLotInventory
		SET intBondStatusId = @intLotStatusId
		WHERE intLotId = @intProductValueId
	END
	ELSE IF @ysnRequireCustomerApproval = 1
		AND @intProductTypeId = 11
		AND @intSampleControlPointId = 14
		AND @strApprovalBase = 'Parent Lot'
	BEGIN
		UPDATE LI
		SET intBondStatusId = @intLotStatusId
		FROM dbo.tblICParentLot AS PL
		JOIN dbo.tblICLot AS L ON PL.intParentLotId = L.intParentLotId AND L.ysnProduced =0
			AND PL.intParentLotId = @intProductValueId
		JOIN dbo.tblMFLotInventory AS LI ON L.intLotId = LI.intLotId
	END
	ELSE IF @ysnRequireCustomerApproval = 1
		AND @intSampleControlPointId = 14
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

	-- Wholesome Sweetener -- JIRA QC-240
	--IF @ysnRequireCustomerApproval = 1
	--BEGIN
	--	IF (
	--			@intProductTypeId = 6
	--			OR @intProductTypeId = 11
	--			) -- Lot / Parent Lot
	--	BEGIN
	--		DECLARE @intCustomsApprovalSampleCount INT
	--		DECLARE @intOtherControlPointSampleCount INT
	--		DECLARE @intBondedApprovalLotStatusId INT
	--		SELECT @intCustomsApprovalSampleCount = COUNT(intSampleId)
	--		FROM tblQMSample S
	--		JOIN tblQMSampleType ST ON ST.intSampleTypeId = S.intSampleTypeId
	--		WHERE S.intProductTypeId = @intProductTypeId
	--			AND S.intProductValueId = @intProductValueId
	--			AND S.intSampleId <> @intSampleId
	--			AND S.intSampleStatusId IN (
	--				3
	--				,4
	--				)
	--			AND ST.intControlPointId = 14 -- Customs Approval Sample
	--		SELECT @intOtherControlPointSampleCount = COUNT(intSampleId)
	--		FROM tblQMSample S
	--		JOIN tblQMSampleType ST ON ST.intSampleTypeId = S.intSampleTypeId
	--		WHERE S.intProductTypeId = @intProductTypeId
	--			AND S.intProductValueId = @intProductValueId
	--			AND S.intSampleId <> @intSampleId
	--			AND S.intSampleStatusId IN (
	--				3
	--				,4
	--				)
	--			AND ST.intControlPointId <> 14 -- Customs Approval Sample
	--		-- If No Customs approval sample is available and current sample is not customs approval, take lot status from bonded status
	--		-- If Customs approval sample taken on second time (Some other Sample taken), take lot status from bonded status
	--		IF (
	--				@intCustomsApprovalSampleCount = 0
	--				AND @intSampleControlPointId <> 14
	--				)
	--			OR (
	--				@intOtherControlPointSampleCount > 0
	--				AND @intSampleControlPointId = 14
	--				)
	--		BEGIN
	--			DECLARE @intProductId INT
	--			SELECT TOP 1 @intProductId = intProductId
	--			FROM tblQMTestResult
	--			WHERE intSampleId = @intSampleId
	--			SELECT @intBondedApprovalLotStatusId = intBondedApprovalLotStatusId
	--			FROM tblQMProduct
	--			WHERE intProductId = @intProductId
	--			IF @intBondedApprovalLotStatusId IS NULL
	--			BEGIN
	--				RAISERROR (
	--						'Bonded Approval Lot Status is not configured in the quality template.'
	--						,16
	--						,1
	--						)
	--			END
	--			ELSE
	--			BEGIN
	--				SET @intLotStatusId = @intBondedApprovalLotStatusId
	--			END
	--		END
	--	END
	--END
	SELECT TOP 1 @intUserSampleApproval = ISNULL(intUserSampleApproval, 0)
	FROM tblQMCompanyPreference

	IF @intUserSampleApproval <> 0 -- No Check
	BEGIN
		IF @intSampleStatusId = 4 -- Only for Rejected to Approved
		BEGIN
			IF @intApproveRejectUserId <> @intLastModifiedUserId
			BEGIN
				IF @intUserSampleApproval = 1 -- User Check
				BEGIN
					RAISERROR (
							'Sample is %s by different %s. You do not have permission to %s it.'
							,11
							,1
							,'rejected'
							,'user'
							,'approve'
							)
				END
				ELSE IF @intUserSampleApproval = 2 -- User Role Check
				BEGIN
					DECLARE @intApproveRejectUserRoleID INT
					DECLARE @intUserRoleID INT

					SELECT @intApproveRejectUserRoleID = intUserRoleID
					FROM tblSMUserSecurity
					WHERE intEntityUserSecurityId = @intApproveRejectUserId

					SELECT @intUserRoleID = intUserRoleID
					FROM tblSMUserSecurity
					WHERE intEntityUserSecurityId = @intLastModifiedUserId

					IF @intApproveRejectUserRoleID <> @intUserRoleID
					BEGIN
						RAISERROR (
								'Sample is %s by different %s. You do not have permission to %s it.'
								,11
								,1
								,'rejected'
								,'user role'
								,'approve'
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
			AND @intSampleStatusId = 4 -- Only for Rejected to Approved
		BEGIN
			EXEC uspLGRejectContainerFromQuality @intLoadDetailContainerLinkId
				,@intContractDetailId
				,0
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
		END
		ELSE IF @strApprovalBase = 'Container'
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
		ELSE IF @strApprovalBase = 'Work Order'
		BEGIN
			SELECT @strLotAlias = strLotAlias
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
			WHERE strLotAlias = @strLotAlias
		END

		SELECT @intSeqNo = MIN(intSeqNo)
		FROM @LotData

		WHILE (@intSeqNo > 0)
		BEGIN
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

			IF EXISTS (
					SELECT *
					FROM tblQMControlPointLotStatus
					WHERE intCurrentLotStatusId = @intCurrentLotStatusId
						AND intControlPointId = @intSampleControlPointId
						AND ysnApprove = 1
					)
			BEGIN
				SELECT @intLotStatusId = intLotStatusId
				FROM tblQMControlPointLotStatus
				WHERE intCurrentLotStatusId = @intCurrentLotStatusId
					AND intControlPointId = @intSampleControlPointId
					AND ysnApprove = 1
			END

			IF @intCurrentLotStatusId <> @intLotStatusId
				AND @intSampleControlPointId <> 14
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
		,intSampleStatusId = 3 -- Approved
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
