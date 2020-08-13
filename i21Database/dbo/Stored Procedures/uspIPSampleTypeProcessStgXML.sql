CREATE PROCEDURE uspIPSampleTypeProcessStgXML
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @idoc INT
		,@intTransactionCount INT
		,@ErrMsg NVARCHAR(MAX)
		,@strErrorMessage NVARCHAR(MAX)
	DECLARE @intSampleTypeStageId INT
		,@intSampleTypeId INT
		,@strHeaderXML NVARCHAR(MAX)
		,@strRowState NVARCHAR(MAX)
		,@intMultiCompanyId INT
		,@strUserName NVARCHAR(100)
	DECLARE @strSampleTypeName NVARCHAR(50)
		,@strControlPointName NVARCHAR(50)
		,@strSampleLabelName NVARCHAR(100)
		,@strApprovalLotStatus NVARCHAR(50)
		,@strRejectionLotStatus NVARCHAR(50)
		,@strBondedApprovalLotStatus NVARCHAR(50)
		,@strBondedRejectionLotStatus NVARCHAR(50)
		,@intControlPointId INT
		,@intSampleLabelId INT
		,@intApprovalLotStatusId INT
		,@intRejectionLotStatusId INT
		,@intBondedApprovalLotStatusId INT
		,@intBondedRejectionLotStatusId INT
	DECLARE @intLastModifiedUserId INT
		,@intNewSampleTypeId INT
		,@intSampleTypeRefId INT
	DECLARE @strSampleTypeDetailXML NVARCHAR(MAX)
		,@intSampleTypeDetailId INT
	DECLARE @strAttributeName NVARCHAR(50)
		,@intAttributeId INT
	DECLARE @strSampleTypeUserRoleXML NVARCHAR(MAX)
		,@intSampleTypeUserRoleId INT
	DECLARE @strName NVARCHAR(100)
		,@intUserRoleID INT
	DECLARE @tblQMSampleTypeStage TABLE (intSampleTypeStageId INT)

	INSERT INTO @tblQMSampleTypeStage (intSampleTypeStageId)
	SELECT intSampleTypeStageId
	FROM tblQMSampleTypeStage
	WHERE ISNULL(strFeedStatus, '') = ''

	SELECT @intSampleTypeStageId = MIN(intSampleTypeStageId)
	FROM @tblQMSampleTypeStage

	IF @intSampleTypeStageId IS NULL
	BEGIN
		RETURN
	END

	UPDATE t
	SET t.strFeedStatus = 'In-Progress'
	FROM tblQMSampleTypeStage t
	JOIN @tblQMSampleTypeStage pt ON pt.intSampleTypeStageId = t.intSampleTypeStageId

	WHILE @intSampleTypeStageId > 0
	BEGIN
		SELECT @intSampleTypeId = NULL
			,@strHeaderXML = NULL
			,@strRowState = NULL
			,@intMultiCompanyId = NULL
			,@strUserName = NULL
			,@strSampleTypeDetailXML = NULL
			,@strSampleTypeUserRoleXML = NULL

		SELECT @intSampleTypeId = intSampleTypeId
			,@strHeaderXML = strHeaderXML
			,@strSampleTypeDetailXML = strSampleTypeDetailXML
			,@strSampleTypeUserRoleXML = strSampleTypeUserRoleXML
			,@strRowState = strRowState
			,@intMultiCompanyId = intMultiCompanyId
			,@strUserName = strUserName
		FROM tblQMSampleTypeStage
		WHERE intSampleTypeStageId = @intSampleTypeStageId

		BEGIN TRY
			SELECT @intSampleTypeRefId = @intSampleTypeId

			SELECT @intTransactionCount = @@TRANCOUNT

			IF @intTransactionCount = 0
				BEGIN TRANSACTION

			------------------Header------------------------------------------------------
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strHeaderXML

			SELECT @strSampleTypeName = NULL
				,@strControlPointName = NULL
				,@strSampleLabelName = NULL
				,@strApprovalLotStatus = NULL
				,@strRejectionLotStatus = NULL
				,@strBondedApprovalLotStatus = NULL
				,@strBondedRejectionLotStatus = NULL
				,@intControlPointId = NULL
				,@intSampleLabelId = NULL
				,@intApprovalLotStatusId = NULL
				,@intRejectionLotStatusId = NULL
				,@intBondedApprovalLotStatusId = NULL
				,@intBondedRejectionLotStatusId = NULL

			SELECT @strSampleTypeName = strSampleTypeName
				,@strControlPointName = strControlPointName
				,@strSampleLabelName = strSampleLabelName
				,@strApprovalLotStatus = strApprovalLotStatus
				,@strRejectionLotStatus = strRejectionLotStatus
				,@strBondedApprovalLotStatus = strBondedApprovalLotStatus
				,@strBondedRejectionLotStatus = strBondedRejectionLotStatus
			FROM OPENXML(@idoc, 'vyuIPGetSampleTypes/vyuIPGetSampleType', 2) WITH (
					strSampleTypeName NVARCHAR(50)
					,strControlPointName NVARCHAR(50)
					,strSampleLabelName NVARCHAR(100)
					,strApprovalLotStatus NVARCHAR(50)
					,strRejectionLotStatus NVARCHAR(50)
					,strBondedApprovalLotStatus NVARCHAR(50)
					,strBondedRejectionLotStatus NVARCHAR(50)
					) x

			IF @strControlPointName IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblQMControlPoint t
					WHERE t.strControlPointName = @strControlPointName
					)
			BEGIN
				SELECT @strErrorMessage = 'Control Point ' + @strControlPointName + ' is not available.'

				RAISERROR (
						@strErrorMessage
						,16
						,1
						)
			END

			IF @strSampleLabelName IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblQMSampleLabel t
					WHERE t.strSampleLabelName = @strSampleLabelName
					)
			BEGIN
				SELECT @strErrorMessage = 'Sample Label ' + @strSampleLabelName + ' is not available.'

				RAISERROR (
						@strErrorMessage
						,16
						,1
						)
			END

			IF @strApprovalLotStatus IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblICLotStatus t
					WHERE t.strSecondaryStatus = @strApprovalLotStatus
					)
			BEGIN
				SELECT @strErrorMessage = 'Approval Lot Status ' + @strApprovalLotStatus + ' is not available.'

				RAISERROR (
						@strErrorMessage
						,16
						,1
						)
			END

			IF @strRejectionLotStatus IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblICLotStatus t
					WHERE t.strSecondaryStatus = @strRejectionLotStatus
					)
			BEGIN
				SELECT @strErrorMessage = 'Rejection Lot Status ' + @strRejectionLotStatus + ' is not available.'

				RAISERROR (
						@strErrorMessage
						,16
						,1
						)
			END

			IF @strBondedApprovalLotStatus IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblICLotStatus t
					WHERE t.strSecondaryStatus = @strBondedApprovalLotStatus
					)
			BEGIN
				SELECT @strErrorMessage = 'Bonded Approval Lot Status ' + @strBondedApprovalLotStatus + ' is not available.'

				RAISERROR (
						@strErrorMessage
						,16
						,1
						)
			END

			IF @strBondedRejectionLotStatus IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblICLotStatus t
					WHERE t.strSecondaryStatus = @strBondedRejectionLotStatus
					)
			BEGIN
				SELECT @strErrorMessage = 'Bonded Rejection Lot Status ' + @strBondedRejectionLotStatus + ' is not available.'

				RAISERROR (
						@strErrorMessage
						,16
						,1
						)
			END

			SELECT @intControlPointId = t.intControlPointId
			FROM tblQMControlPoint t
			WHERE t.strControlPointName = @strControlPointName

			SELECT @intSampleLabelId = t.intSampleLabelId
			FROM tblQMSampleLabel t
			WHERE t.strSampleLabelName = @strSampleLabelName

			SELECT @intApprovalLotStatusId = t.intLotStatusId
			FROM tblICLotStatus t
			WHERE t.strSecondaryStatus = @strApprovalLotStatus

			SELECT @intRejectionLotStatusId = t.intLotStatusId
			FROM tblICLotStatus t
			WHERE t.strSecondaryStatus = @strRejectionLotStatus

			SELECT @intBondedApprovalLotStatusId = t.intLotStatusId
			FROM tblICLotStatus t
			WHERE t.strSecondaryStatus = @strBondedApprovalLotStatus

			SELECT @intBondedRejectionLotStatusId = t.intLotStatusId
			FROM tblICLotStatus t
			WHERE t.strSecondaryStatus = @strBondedRejectionLotStatus

			SELECT @intLastModifiedUserId = t.intEntityId
			FROM tblEMEntity t
			JOIN tblEMEntityType ET ON ET.intEntityId = t.intEntityId
			WHERE ET.strType = 'User'
				AND t.strName = @strUserName
				AND t.strEntityNo <> ''

			IF @intLastModifiedUserId IS NULL
			BEGIN
				IF EXISTS (
						SELECT 1
						FROM tblSMUserSecurity
						WHERE strUserName = 'irelyadmin'
						)
					SELECT TOP 1 @intLastModifiedUserId = intEntityId
					FROM tblSMUserSecurity
					WHERE strUserName = 'irelyadmin'
				ELSE
					SELECT TOP 1 @intLastModifiedUserId = intEntityId
					FROM tblSMUserSecurity
			END

			IF @strRowState <> 'Delete'
			BEGIN
				IF NOT EXISTS (
						SELECT 1
						FROM tblQMSampleType
						WHERE intSampleTypeRefId = @intSampleTypeRefId
						)
					SELECT @strRowState = 'Added'
				ELSE
					SELECT @strRowState = 'Modified'
			END

			IF @strRowState = 'Delete'
			BEGIN
				SELECT @intNewSampleTypeId = @intSampleTypeRefId
					,@strSampleTypeName = @strSampleTypeName

				DELETE
				FROM tblQMSampleType
				WHERE intSampleTypeRefId = @intSampleTypeRefId

				GOTO ext
			END

			IF @strRowState = 'Added'
			BEGIN
				INSERT INTO tblQMSampleType (
					intConcurrencyId
					,strSampleTypeName
					,strDescription
					,intControlPointId
					,ysnFinalApproval
					,strApprovalBase
					,intSampleLabelId
					,ysnAdjustInventoryQtyBySampleQty
					,intApprovalLotStatusId
					,intRejectionLotStatusId
					,intBondedApprovalLotStatusId
					,intBondedRejectionLotStatusId
					,intCreatedUserId
					,dtmCreated
					,intLastModifiedUserId
					,dtmLastModified
					,intSampleTypeRefId
					)
				SELECT 1
					,strSampleTypeName
					,strDescription
					,@intControlPointId
					,ysnFinalApproval
					,strApprovalBase
					,@intSampleLabelId
					,ysnAdjustInventoryQtyBySampleQty
					,@intApprovalLotStatusId
					,@intRejectionLotStatusId
					,@intBondedApprovalLotStatusId
					,@intBondedRejectionLotStatusId
					,@intLastModifiedUserId
					,dtmCreated
					,@intLastModifiedUserId
					,dtmLastModified
					,@intSampleTypeRefId
				FROM OPENXML(@idoc, 'vyuIPGetSampleTypes/vyuIPGetSampleType', 2) WITH (
						strSampleTypeName NVARCHAR(50)
						,strDescription NVARCHAR(100)
						,ysnFinalApproval BIT
						,strApprovalBase NVARCHAR(50)
						,ysnAdjustInventoryQtyBySampleQty BIT
						,dtmCreated DATETIME
						,dtmLastModified DATETIME
						)

				SELECT @intNewSampleTypeId = SCOPE_IDENTITY()
			END

			IF @strRowState = 'Modified'
			BEGIN
				UPDATE tblQMSampleType
				SET intConcurrencyId = intConcurrencyId + 1
					,strSampleTypeName = x.strSampleTypeName
					,strDescription = x.strDescription
					,intControlPointId = @intControlPointId
					,ysnFinalApproval = x.ysnFinalApproval
					,strApprovalBase = x.strApprovalBase
					,intSampleLabelId = @intSampleLabelId
					,ysnAdjustInventoryQtyBySampleQty = x.ysnAdjustInventoryQtyBySampleQty
					,intApprovalLotStatusId = @intApprovalLotStatusId
					,intRejectionLotStatusId = @intRejectionLotStatusId
					,intBondedApprovalLotStatusId = @intBondedApprovalLotStatusId
					,intBondedRejectionLotStatusId = @intBondedRejectionLotStatusId
					,intLastModifiedUserId = @intLastModifiedUserId
					,dtmLastModified = x.dtmLastModified
				FROM OPENXML(@idoc, 'vyuIPGetSampleTypes/vyuIPGetSampleType', 2) WITH (
						strSampleTypeName NVARCHAR(50)
						,strDescription NVARCHAR(100)
						,ysnFinalApproval BIT
						,strApprovalBase NVARCHAR(50)
						,ysnAdjustInventoryQtyBySampleQty BIT
						,dtmLastModified DATETIME
						) x
				WHERE tblQMSampleType.intSampleTypeRefId = @intSampleTypeRefId

				SELECT @intNewSampleTypeId = intSampleTypeId
				FROM tblQMSampleType
				WHERE intSampleTypeRefId = @intSampleTypeRefId
			END

			EXEC sp_xml_removedocument @idoc

			------------------------------------Sample Type Detail--------------------------------------------
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strSampleTypeDetailXML

			DECLARE @tblQMSampleTypeDetail TABLE (intSampleTypeDetailId INT)

			INSERT INTO @tblQMSampleTypeDetail (intSampleTypeDetailId)
			SELECT intSampleTypeDetailId
			FROM OPENXML(@idoc, 'vyuIPGetSampleTypeDetails/vyuIPGetSampleTypeDetail', 2) WITH (intSampleTypeDetailId INT)

			SELECT @intSampleTypeDetailId = MIN(intSampleTypeDetailId)
			FROM @tblQMSampleTypeDetail

			WHILE @intSampleTypeDetailId IS NOT NULL
			BEGIN
				SELECT @strAttributeName = NULL
					,@intAttributeId = NULL

				SELECT @strAttributeName = strAttributeName
				FROM OPENXML(@idoc, 'vyuIPGetSampleTypeDetails/vyuIPGetSampleTypeDetail', 2) WITH (
						strAttributeName NVARCHAR(50) Collate Latin1_General_CI_AS
						,intSampleTypeDetailId INT
						) SD
				WHERE intSampleTypeDetailId = @intSampleTypeDetailId

				IF @strAttributeName IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblQMAttribute t
						WHERE t.strAttributeName = @strAttributeName
						)
				BEGIN
					SELECT @strErrorMessage = 'Attribute Name ' + @strAttributeName + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				SELECT @intAttributeId = t.intAttributeId
				FROM tblQMAttribute t
				WHERE t.strAttributeName = @strAttributeName

				IF NOT EXISTS (
						SELECT 1
						FROM tblQMSampleTypeDetail
						WHERE intSampleTypeId = @intNewSampleTypeId
							AND intSampleTypeDetailRefId = @intSampleTypeDetailId
						)
				BEGIN
					INSERT INTO tblQMSampleTypeDetail (
						intSampleTypeId
						,intAttributeId
						,intConcurrencyId
						,ysnIsMandatory
						,intCreatedUserId
						,dtmCreated
						,intLastModifiedUserId
						,dtmLastModified
						,intSampleTypeDetailRefId
						)
					SELECT @intNewSampleTypeId
						,@intAttributeId
						,1
						,ysnIsMandatory
						,@intLastModifiedUserId
						,dtmCreated
						,@intLastModifiedUserId
						,dtmLastModified
						,@intSampleTypeDetailId
					FROM OPENXML(@idoc, 'vyuIPGetSampleTypeDetails/vyuIPGetSampleTypeDetail', 2) WITH (
							ysnIsMandatory BIT
							,dtmCreated DATETIME
							,dtmLastModified DATETIME
							,intSampleTypeDetailId INT
							) x
					WHERE x.intSampleTypeDetailId = @intSampleTypeDetailId
				END
				ELSE
				BEGIN
					UPDATE tblQMSampleTypeDetail
					SET intConcurrencyId = intConcurrencyId + 1
						,intAttributeId = @intAttributeId
						,ysnIsMandatory = x.ysnIsMandatory
						,intLastModifiedUserId = @intLastModifiedUserId
						,dtmLastModified = x.dtmLastModified
					FROM OPENXML(@idoc, 'vyuIPGetSampleTypeDetails/vyuIPGetSampleTypeDetail', 2) WITH (
							ysnIsMandatory BIT
							,dtmLastModified DATETIME
							,intSampleTypeDetailId INT
							) x
					JOIN tblQMSampleTypeDetail D ON D.intSampleTypeDetailRefId = x.intSampleTypeDetailId
						AND D.intSampleTypeId = @intNewSampleTypeId
					WHERE x.intSampleTypeDetailId = @intSampleTypeDetailId
				END

				SELECT @intSampleTypeDetailId = MIN(intSampleTypeDetailId)
				FROM @tblQMSampleTypeDetail
				WHERE intSampleTypeDetailId > @intSampleTypeDetailId
			END

			DELETE
			FROM tblQMSampleTypeDetail
			WHERE intSampleTypeId = @intNewSampleTypeId
				AND intSampleTypeDetailRefId NOT IN (
					SELECT intSampleTypeDetailId
					FROM @tblQMSampleTypeDetail
					)

			EXEC sp_xml_removedocument @idoc

			------------------------------------Sample Type User Role--------------------------------------------
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strSampleTypeUserRoleXML

			DECLARE @tblQMSampleTypeUserRole TABLE (intSampleTypeUserRoleId INT)

			INSERT INTO @tblQMSampleTypeUserRole (intSampleTypeUserRoleId)
			SELECT intSampleTypeUserRoleId
			FROM OPENXML(@idoc, 'vyuIPGetSampleTypeUserRoles/vyuIPGetSampleTypeUserRole', 2) WITH (intSampleTypeUserRoleId INT)

			SELECT @intSampleTypeUserRoleId = MIN(intSampleTypeUserRoleId)
			FROM @tblQMSampleTypeUserRole

			WHILE @intSampleTypeUserRoleId IS NOT NULL
			BEGIN
				SELECT @strName = NULL
					,@intUserRoleID = NULL

				SELECT @strName = strName
				FROM OPENXML(@idoc, 'vyuIPGetSampleTypeUserRoles/vyuIPGetSampleTypeUserRole', 2) WITH (
						strName NVARCHAR(100) Collate Latin1_General_CI_AS
						,intSampleTypeUserRoleId INT
						) SD
				WHERE intSampleTypeUserRoleId = @intSampleTypeUserRoleId

				IF @strName IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblSMUserRole t
						WHERE t.strName = @strName
						)
				BEGIN
					SELECT @strErrorMessage = 'User Role ' + @strName + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				SELECT @intUserRoleID = t.intUserRoleID
				FROM tblSMUserRole t
				WHERE t.strName = @strName

				IF NOT EXISTS (
						SELECT 1
						FROM tblQMSampleTypeUserRole
						WHERE intSampleTypeId = @intNewSampleTypeId
							AND intSampleTypeUserRoleRefId = @intSampleTypeUserRoleId
						)
				BEGIN
					INSERT INTO tblQMSampleTypeUserRole (
						intSampleTypeId
						,intUserRoleID
						,intConcurrencyId
						,intCreatedUserId
						,dtmCreated
						,intLastModifiedUserId
						,dtmLastModified
						,intSampleTypeUserRoleRefId
						)
					SELECT @intNewSampleTypeId
						,@intUserRoleID
						,1
						,@intLastModifiedUserId
						,dtmCreated
						,@intLastModifiedUserId
						,dtmLastModified
						,@intSampleTypeUserRoleId
					FROM OPENXML(@idoc, 'vyuIPGetSampleTypeUserRoles/vyuIPGetSampleTypeUserRole', 2) WITH (
							dtmCreated DATETIME
							,dtmLastModified DATETIME
							,intSampleTypeUserRoleId INT
							) x
					WHERE x.intSampleTypeUserRoleId = @intSampleTypeUserRoleId
				END
				ELSE
				BEGIN
					UPDATE tblQMSampleTypeUserRole
					SET intConcurrencyId = intConcurrencyId + 1
						,intUserRoleID = @intUserRoleID
						,intLastModifiedUserId = @intLastModifiedUserId
						,dtmLastModified = x.dtmLastModified
					FROM OPENXML(@idoc, 'vyuIPGetSampleTypeUserRoles/vyuIPGetSampleTypeUserRole', 2) WITH (
							dtmLastModified DATETIME
							,intSampleTypeUserRoleId INT
							) x
					JOIN tblQMSampleTypeUserRole D ON D.intSampleTypeUserRoleRefId = x.intSampleTypeUserRoleId
						AND D.intSampleTypeId = @intNewSampleTypeId
					WHERE x.intSampleTypeUserRoleId = @intSampleTypeUserRoleId
				END

				SELECT @intSampleTypeUserRoleId = MIN(intSampleTypeUserRoleId)
				FROM @tblQMSampleTypeUserRole
				WHERE intSampleTypeUserRoleId > @intSampleTypeUserRoleId
			END

			DELETE
			FROM tblQMSampleTypeUserRole
			WHERE intSampleTypeId = @intNewSampleTypeId
				AND intSampleTypeUserRoleRefId NOT IN (
					SELECT intSampleTypeUserRoleId
					FROM @tblQMSampleTypeUserRole
					)

			ext:

			EXEC sp_xml_removedocument @idoc

			UPDATE tblQMSampleTypeStage
			SET strFeedStatus = 'Processed'
				,strMessage = 'Success'
				,intStatusId = 1
			WHERE intSampleTypeStageId = @intSampleTypeStageId

			-- Audit Log
			IF (@intNewSampleTypeId > 0)
			BEGIN
				DECLARE @StrDescription AS NVARCHAR(MAX)

				IF @strRowState = 'Added'
				BEGIN
					SELECT @StrDescription = 'Created '

					EXEC uspSMAuditLog @keyValue = @intNewSampleTypeId
						,@screenName = 'Quality.view.SampleType'
						,@entityId = @intLastModifiedUserId
						,@actionType = 'Created'
						,@actionIcon = 'small-new-plus'
						,@changeDescription = @StrDescription
						,@fromValue = ''
						,@toValue = @strSampleTypeName
				END
				ELSE IF @strRowState = 'Modified'
				BEGIN
					SELECT @StrDescription = 'Updated '

					EXEC uspSMAuditLog @keyValue = @intNewSampleTypeId
						,@screenName = 'Quality.view.SampleType'
						,@entityId = @intLastModifiedUserId
						,@actionType = 'Updated'
						,@actionIcon = 'small-tree-modified'
						,@changeDescription = @StrDescription
						,@fromValue = ''
						,@toValue = @strSampleTypeName
				END
			END

			IF @intTransactionCount = 0
				COMMIT TRANSACTION
		END TRY

		BEGIN CATCH
			SET @ErrMsg = ERROR_MESSAGE()

			IF @idoc <> 0
				EXEC sp_xml_removedocument @idoc

			IF XACT_STATE() != 0
				AND @intTransactionCount = 0
				ROLLBACK TRANSACTION

			UPDATE tblQMSampleTypeStage
			SET strFeedStatus = 'Failed'
				,strMessage = @ErrMsg
				,intStatusId = 2
			WHERE intSampleTypeStageId = @intSampleTypeStageId
		END CATCH

		SELECT @intSampleTypeStageId = MIN(intSampleTypeStageId)
		FROM @tblQMSampleTypeStage
		WHERE intSampleTypeStageId > @intSampleTypeStageId
			--AND ISNULL(strFeedStatus, '') = ''
	END

	UPDATE t
	SET t.strFeedStatus = NULL
	FROM tblQMSampleTypeStage t
	JOIN @tblQMSampleTypeStage pt ON pt.intSampleTypeStageId = t.intSampleTypeStageId
		AND t.strFeedStatus = 'In-Progress'
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
