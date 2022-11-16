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
	DECLARE @intOrgLotStatusId INT
	DECLARE @intLastModifiedUserId INT
		,@intTestedById INT
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
	DECLARE @intSampleControlPointId INT
	DECLARE @intSeqNo INT
	DECLARE @strMainLotNumber NVARCHAR(50)
	DECLARE @strApprovalBase NVARCHAR(50)
	DECLARE @strContainerNumber NVARCHAR(100)
	DECLARE @strLotAlias NVARCHAR(50)
		,@strWarehouseRefNo NVARCHAR(50)
		,@intParentLotId INT
	DECLARE @ysnEnableParentLot BIT = 0
		,@strChildLotNumber NVARCHAR(50)
		,@intSampleTypeId INT
		,@strMarks NVARCHAR(100)

	SELECT @intSampleId = intSampleId
		,@intProductTypeId = intProductTypeId
		,@intProductValueId = intProductValueId
		,@intLotStatusId = intLotStatusId
		,@intLastModifiedUserId = intLastModifiedUserId
		,@dtmLastModified = dtmLastModified
		,@intTestedById = intTestedById
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intSampleId INT
			,intProductTypeId INT
			,intProductValueId INT
			,intLotStatusId INT
			,intLastModifiedUserId INT
			,dtmLastModified DATETIME
			,intTestedById INT
			)

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
		,@strMarks=S.strMarks 
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

	-- Call IC SP to monitor the rejected samples at lot level
	IF @intProductTypeId = 6
		OR @intProductTypeId = 11
	BEGIN
		DECLARE @intLotLocationId INT
		DECLARE @LotRecords TABLE (
			intSeqNo INT IDENTITY(1, 1)
			,intLotId INT
			,strLotNumber NVARCHAR(50)
			)

		DELETE
		FROM @LotRecords

		IF @intProductTypeId = 11
		BEGIN
			INSERT INTO @LotRecords (
				intLotId
				,strLotNumber
				)
			SELECT intLotId
				,strLotNumber
			FROM tblICLot
			WHERE intParentLotId = @intProductValueId
				AND dblQty > 0
		END
		ELSE
		BEGIN
			SELECT @strLotNumber = strLotNumber
				,@intLotLocationId = intLocationId
			FROM tblICLot
			WHERE intLotId = @intProductValueId

			INSERT INTO @LotRecords (
				intLotId
				,strLotNumber
				)
			SELECT intLotId
				,strLotNumber
			FROM tblICLot
			WHERE strLotNumber = @strLotNumber
				AND dblQty > 0
				--AND intLocationId = @intLotLocationId
		END

		SELECT @intSeqNo = MIN(intSeqNo)
		FROM @LotRecords

		WHILE (@intSeqNo > 0)
		BEGIN
			SELECT @intLotId = NULL

			SELECT @intLotId = intLotId
			FROM @LotRecords
			WHERE intSeqNo = @intSeqNo

			EXEC uspICRejectLot @intLotId = @intLotId
				,@intEntityId = @intLastModifiedUserId
				,@ysnAdd = 0

			SELECT @intSeqNo = MIN(intSeqNo)
			FROM @LotRecords
			WHERE intSeqNo > @intSeqNo
		END
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
				AND IsNULL(L.strMarkings,'')=IsNULL(@strMarks,'')
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

		SELECT @intSeqNo = NULL

		SELECT @intSeqNo = MIN(intSeqNo)
		FROM @LotData

		WHILE (@intSeqNo > 0)
		BEGIN
			SELECT @intLotStatusId = @intOrgLotStatusId

			SELECT @intLotId = NULL

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

			IF @intProductTypeId=9
			BEGIN
				SELECT @intLotStatusId = intApprovalLotStatusId
				FROM tblQMSampleType
				WHERE intSampleTypeId = @intSampleTypeId
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
		,intSampleStatusId = 3 -- Approved
		,intLotStatusId = (
			CASE 
				WHEN @intProductTypeId IN (
						6
						,9
						,11
						)
					THEN @intLotStatusId
				ELSE intLotStatusId
				END
			)
		,intTestedById = x.intTestedById
		,dtmTestedOn = x.dtmTestedOn
		,intLastModifiedUserId = x.intLastModifiedUserId
		,dtmLastModified = x.dtmLastModified
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intTestedById INT
			,dtmTestedOn DATETIME
			,intLastModifiedUserId INT
			,dtmLastModified DATETIME
			) x
	WHERE dbo.tblQMSample.intSampleId = @intSampleId

	/* Verify if the Sample Product Type is for Batch. */
	IF (SELECT intProductTypeId FROM tblQMSample WHERE intSampleId = @intSampleId) = 13
		BEGIN
			DECLARE @dblTeaAppearance NUMERIC(18, 6)
				  ,	@dblTeaTaste	  NUMERIC(18, 6)
				  ,	@dblTeaMouthFeel  NUMERIC(18, 6)
				  ,	@dblTeaHue		  NUMERIC(18, 6)
				  ,	@dblTeaIntensity  NUMERIC(18, 6)
				  ,	@dblTeaMoisture   NUMERIC(18, 6)
				  ,	@dblTeaVolume     NUMERIC(18, 6)

			/* Get Test Result of Sample. */
			SELECT @dblTeaAppearance = CASE WHEN QualityProperty.strPropertyName = 'Appearance' THEN CAST(ISNULL(NULLIF(TestResult.strPropertyValue, ''), '0') AS NUMERIC(18, 6)) ELSE @dblTeaAppearance END
				 , @dblTeaTaste		 = CASE WHEN QualityProperty.strPropertyName = 'Taste'		THEN CAST(ISNULL(NULLIF(TestResult.strPropertyValue, ''), '0') AS NUMERIC(18, 6)) ELSE @dblTeaTaste		 END	
				 , @dblTeaMouthFeel	 = CASE WHEN QualityProperty.strPropertyName = 'Mouth Feel' THEN CAST(ISNULL(NULLIF(TestResult.strPropertyValue, ''), '0') AS NUMERIC(18, 6)) ELSE @dblTeaMouthFeel  END	
				 , @dblTeaHue		 = CASE WHEN QualityProperty.strPropertyName = 'Hue'		THEN CAST(ISNULL(NULLIF(TestResult.strPropertyValue, ''), '0') AS NUMERIC(18, 6)) ELSE @dblTeaHue		 END	
				 , @dblTeaIntensity  = CASE WHEN QualityProperty.strPropertyName = 'Intensity'	THEN CAST(ISNULL(NULLIF(TestResult.strPropertyValue, ''), '0') AS NUMERIC(18, 6)) ELSE @dblTeaIntensity  END	
				 , @dblTeaMoisture   = CASE WHEN QualityProperty.strPropertyName = 'Moisture'	THEN CAST(ISNULL(NULLIF(TestResult.strPropertyValue, ''), '0') AS NUMERIC(18, 6)) ELSE @dblTeaMoisture	 END	
				 , @dblTeaVolume	 = CASE WHEN QualityProperty.strPropertyName = 'Volume'		THEN CAST(ISNULL(NULLIF(TestResult.strPropertyValue, ''), '0') AS NUMERIC(18, 6)) ELSE @dblTeaVolume	 END	
			FROM tblQMTestResult AS TestResult 
			JOIN tblQMProperty AS QualityProperty ON TestResult.intPropertyId = QualityProperty.intPropertyId
			JOIN tblQMTest AS Test ON Test.intTestId = TestResult.intTestId
			JOIN tblQMSample AS QualitySample ON TestResult.intSampleId = QualitySample.intSampleId
			WHERE QualitySample.intSampleId = @intSampleId AND Test.strTestName = 'Tea Tasting';

			/* Update Batch Tea Characteristics. */
			UPDATE Batch
			SET dblTeaAppearance = @dblTeaAppearance
			  , dblTeaTaste		 = @dblTeaTaste
			  , dblTeaMouthFeel  = @dblTeaMouthFeel
			  , dblTeaHue		 = @dblTeaHue
			  , dblTeaIntensity  = @dblTeaIntensity
			  , dblTeaMoisture	 = @dblTeaMoisture
			  , dblTeaVolume	 = @dblTeaVolume
			FROM tblMFBatch AS Batch
			WHERE intBatchId = (SELECT TOP 1 intProductValueId
								FROM tblQMSample
								WHERE intSampleId = @intSampleId);
		END

	

	IF (@intSampleId > 0)
	BEGIN
		EXEC uspSMAuditLog @keyValue = @intSampleId
			,@screenName = 'Quality.view.QualitySample'
			,@entityId = @intTestedById
			,@actionType = 'Approved'
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