CREATE PROCEDURE uspIPProductProcessStgXML
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @idoc INT
		,@intTransactionCount INT
		,@ErrMsg NVARCHAR(MAX)
		,@strErrorMessage NVARCHAR(MAX)
	DECLARE @intProductStageId INT
		,@intProductId INT
		,@strHeaderXML NVARCHAR(MAX)
		,@strRowState NVARCHAR(MAX)
		,@intMultiCompanyId INT
		,@strUserName NVARCHAR(100)
	DECLARE @strProductValue NVARCHAR(50)
		,@strApprovalLotStatus NVARCHAR(50)
		,@strRejectionLotStatus NVARCHAR(50)
		,@strBondedApprovalLotStatus NVARCHAR(50)
		,@strBondedRejectionLotStatus NVARCHAR(50)
		,@strUnitMeasure NVARCHAR(50)
		,@intProductTypeId INT
		,@intProductValueId INT
		,@intApprovalLotStatusId INT
		,@intRejectionLotStatusId INT
		,@intBondedApprovalLotStatusId INT
		,@intBondedRejectionLotStatusId INT
		,@intUnitMeasureId INT
	DECLARE @intLastModifiedUserId INT
		,@intNewProductId INT
		,@intProductRefId INT
	DECLARE @strProductControlPointXML NVARCHAR(MAX)
		,@intProductControlPointId INT
	DECLARE @strSampleTypeName NVARCHAR(50)
		,@strControlPointName NVARCHAR(50)
		,@intSampleTypeId INT
		,@intControlPointId INT

	SELECT @intProductStageId = MIN(intProductStageId)
	FROM tblQMProductStage
	WHERE ISNULL(strFeedStatus, '') = ''

	WHILE @intProductStageId > 0
	BEGIN
		SELECT @intProductId = NULL
			,@strHeaderXML = NULL
			,@strRowState = NULL
			,@intMultiCompanyId = NULL
			,@strUserName = NULL
			,@strProductControlPointXML = NULL

		SELECT @intProductId = intProductId
			,@strHeaderXML = strHeaderXML
			,@strProductControlPointXML = strProductControlPointXML
			,@strRowState = strRowState
			,@intMultiCompanyId = intMultiCompanyId
			,@strUserName = strUserName
		FROM tblQMProductStage
		WHERE intProductStageId = @intProductStageId

		BEGIN TRY
			SELECT @intProductRefId = @intProductId

			SELECT @intTransactionCount = @@TRANCOUNT

			IF @intTransactionCount = 0
				BEGIN TRANSACTION

			------------------Header------------------------------------------------------
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strHeaderXML

			SELECT @strProductValue = NULL
				,@strApprovalLotStatus = NULL
				,@strRejectionLotStatus = NULL
				,@strBondedApprovalLotStatus = NULL
				,@strBondedRejectionLotStatus = NULL
				,@strUnitMeasure = NULL
				,@intProductTypeId = NULL
				,@intProductValueId = NULL
				,@intApprovalLotStatusId = NULL
				,@intRejectionLotStatusId = NULL
				,@intBondedApprovalLotStatusId = NULL
				,@intBondedRejectionLotStatusId = NULL
				,@intUnitMeasureId = NULL

			SELECT @strProductValue = strProductValue
				,@strApprovalLotStatus = strApprovalLotStatus
				,@strRejectionLotStatus = strRejectionLotStatus
				,@strBondedApprovalLotStatus = strBondedApprovalLotStatus
				,@strBondedRejectionLotStatus = strBondedRejectionLotStatus
				,@strUnitMeasure = strUnitMeasure
				,@intProductTypeId = intProductTypeId
			FROM OPENXML(@idoc, 'vyuIPGetProducts/vyuIPGetProduct', 2) WITH (
					strProductValue NVARCHAR(50)
					,strApprovalLotStatus NVARCHAR(50)
					,strRejectionLotStatus NVARCHAR(50)
					,strBondedApprovalLotStatus NVARCHAR(50)
					,strBondedRejectionLotStatus NVARCHAR(50)
					,strUnitMeasure NVARCHAR(50)
					,intProductTypeId INT
					) x

			IF @strProductValue IS NULL
			BEGIN
				SELECT @strErrorMessage = 'Product Value cannot be empty.'

				RAISERROR (
						@strErrorMessage
						,16
						,1
						)
			END

			IF @intProductTypeId = 1
			BEGIN
				IF @strProductValue IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblICCategory t
						WHERE t.strCategoryCode = @strProductValue
						)
				BEGIN
					SELECT @strErrorMessage = 'Category ' + @strProductValue + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END
			END

			IF @intProductTypeId = 2
			BEGIN
				IF @strProductValue IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblICItem t
						WHERE t.strItemNo = @strProductValue
						)
				BEGIN
					SELECT @strErrorMessage = 'Item No. ' + @strProductValue + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END
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

			IF @strUnitMeasure IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblICUnitMeasure t
					WHERE t.strUnitMeasure = @strUnitMeasure
					)
			BEGIN
				SELECT @strErrorMessage = 'UOM ' + @strUnitMeasure + ' is not available.'

				RAISERROR (
						@strErrorMessage
						,16
						,1
						)
			END

			IF @intProductTypeId = 1
			BEGIN
				SELECT @intProductValueId = t.intCategoryId
				FROM tblICCategory t
				WHERE t.strCategoryCode = @strProductValue
			END

			IF @intProductTypeId = 2
			BEGIN
				SELECT @intProductValueId = t.intItemId
				FROM tblICItem t
				WHERE t.strItemNo = @strProductValue
			END

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

			SELECT @intUnitMeasureId = t.intUnitMeasureId
			FROM tblICUnitMeasure t
			WHERE t.strUnitMeasure = @strUnitMeasure

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
						FROM tblQMProduct
						WHERE intProductRefId = @intProductRefId
						)
					SELECT @strRowState = 'Added'
				ELSE
					SELECT @strRowState = 'Modified'
			END

			IF @strRowState = 'Delete'
			BEGIN
				SELECT @intNewProductId = @intProductRefId
					,@strProductValue = @strProductValue

				DELETE
				FROM tblQMProduct
				WHERE intProductRefId = @intProductRefId

				GOTO ext
			END

			IF @strRowState = 'Added'
			BEGIN
				INSERT INTO tblQMProduct (
					intConcurrencyId
					,intProductTypeId
					,intProductValueId
					,strDirections
					,strNote
					,ysnActive
					,intApprovalLotStatusId
					,intRejectionLotStatusId
					,intBondedApprovalLotStatusId
					,intBondedRejectionLotStatusId
					,intUnitMeasureId
					,intCreatedUserId
					,dtmCreated
					,intLastModifiedUserId
					,dtmLastModified
					,intProductRefId
					)
				SELECT 1
					,intProductTypeId
					,@intProductValueId
					,strDirections
					,strNote
					,ysnActive
					,@intApprovalLotStatusId
					,@intRejectionLotStatusId
					,@intBondedApprovalLotStatusId
					,@intBondedRejectionLotStatusId
					,@intUnitMeasureId
					,@intLastModifiedUserId
					,dtmCreated
					,@intLastModifiedUserId
					,dtmLastModified
					,@intProductRefId
				FROM OPENXML(@idoc, 'vyuIPGetProducts/vyuIPGetProduct', 2) WITH (
						intProductTypeId INT
						,strDirections NVARCHAR(1000)
						,strNote NVARCHAR(500)
						,ysnActive BIT
						,dtmCreated DATETIME
						,dtmLastModified DATETIME
						)

				SELECT @intNewProductId = SCOPE_IDENTITY()
			END

			IF @strRowState = 'Modified'
			BEGIN
				UPDATE tblQMProduct
				SET intConcurrencyId = intConcurrencyId + 1
					,intProductValueId = @intProductValueId
					,strDirections = x.strDirections
					,strNote = x.strNote
					,ysnActive = x.ysnActive
					,intApprovalLotStatusId = @intApprovalLotStatusId
					,intRejectionLotStatusId = @intRejectionLotStatusId
					,intBondedApprovalLotStatusId = @intBondedApprovalLotStatusId
					,intBondedRejectionLotStatusId = @intBondedRejectionLotStatusId
					,intUnitMeasureId = @intUnitMeasureId
					,intLastModifiedUserId = @intLastModifiedUserId
					,dtmLastModified = x.dtmLastModified
				FROM OPENXML(@idoc, 'vyuIPGetProducts/vyuIPGetProduct', 2) WITH (
						strDirections NVARCHAR(1000)
						,strNote NVARCHAR(500)
						,ysnActive BIT
						,dtmLastModified DATETIME
						) x
				WHERE tblQMProduct.intProductRefId = @intProductRefId

				SELECT @intNewProductId = intProductId
				FROM tblQMProduct
				WHERE intProductRefId = @intProductRefId
			END

			EXEC sp_xml_removedocument @idoc

			------------------------------------Product Control Point--------------------------------------------
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strProductControlPointXML

			DECLARE @tblQMProductControlPoint TABLE (intProductControlPointId INT)

			INSERT INTO @tblQMProductControlPoint (intProductControlPointId)
			SELECT intProductControlPointId
			FROM OPENXML(@idoc, 'vyuIPGetProductControlPoints/vyuIPGetProductControlPoint', 2) WITH (intProductControlPointId INT)

			SELECT @intProductControlPointId = MIN(intProductControlPointId)
			FROM @tblQMProductControlPoint

			WHILE @intProductControlPointId IS NOT NULL
			BEGIN
				SELECT @strSampleTypeName = NULL
					,@strControlPointName = NULL
					,@intSampleTypeId = NULL
					,@intControlPointId = NULL

				SELECT @strSampleTypeName = strSampleTypeName
					,@strControlPointName = strControlPointName
				FROM OPENXML(@idoc, 'vyuIPGetProductControlPoints/vyuIPGetProductControlPoint', 2) WITH (
						strSampleTypeName NVARCHAR(50) Collate Latin1_General_CI_AS
						,strControlPointName NVARCHAR(50) Collate Latin1_General_CI_AS
						,intProductControlPointId INT
						) SD
				WHERE intProductControlPointId = @intProductControlPointId

				IF @strSampleTypeName IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblQMSampleType t
						WHERE t.strSampleTypeName = @strSampleTypeName
						)
				BEGIN
					SELECT @strErrorMessage = 'Sample Type ' + @strSampleTypeName + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

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

				SELECT @intSampleTypeId = t.intSampleTypeId
				FROM tblQMSampleType t
				WHERE t.strSampleTypeName = @strSampleTypeName

				SELECT @intControlPointId = t.intControlPointId
				FROM tblQMControlPoint t
				WHERE t.strControlPointName = @strControlPointName

				IF NOT EXISTS (
						SELECT 1
						FROM tblQMProductControlPoint
						WHERE intProductId = @intNewProductId
							AND intProductControlPointRefId = @intProductControlPointId
						)
				BEGIN
					INSERT INTO tblQMProductControlPoint (
						intConcurrencyId
						,intProductId
						,intControlPointId
						,intSampleTypeId
						,intCreatedUserId
						,dtmCreated
						,intLastModifiedUserId
						,dtmLastModified
						,intProductControlPointRefId
						)
					SELECT 1
						,@intNewProductId
						,@intControlPointId
						,@intSampleTypeId
						,@intLastModifiedUserId
						,dtmCreated
						,@intLastModifiedUserId
						,dtmLastModified
						,@intProductControlPointId
					FROM OPENXML(@idoc, 'vyuIPGetProductControlPoints/vyuIPGetProductControlPoint', 2) WITH (
							dtmCreated DATETIME
							,dtmLastModified DATETIME
							,intProductControlPointId INT
							) x
					WHERE x.intProductControlPointId = @intProductControlPointId
				END
				ELSE
				BEGIN
					UPDATE tblQMProductControlPoint
					SET intConcurrencyId = intConcurrencyId + 1
						,intControlPointId = @intControlPointId
						,intSampleTypeId = @intSampleTypeId
						,intLastModifiedUserId = @intLastModifiedUserId
						,dtmLastModified = x.dtmLastModified
					FROM OPENXML(@idoc, 'vyuIPGetProductControlPoints/vyuIPGetProductControlPoint', 2) WITH (
							dtmLastModified DATETIME
							,intProductControlPointId INT
							) x
					JOIN tblQMProductControlPoint D ON D.intProductControlPointRefId = x.intProductControlPointId
						AND D.intProductId = @intNewProductId
					WHERE x.intProductControlPointId = @intProductControlPointId
				END

				SELECT @intProductControlPointId = MIN(intProductControlPointId)
				FROM @tblQMProductControlPoint
				WHERE intProductControlPointId > @intProductControlPointId
			END

			DELETE
			FROM tblQMProductControlPoint
			WHERE intProductId = @intNewProductId
				AND intProductControlPointRefId NOT IN (
					SELECT intProductControlPointId
					FROM @tblQMProductControlPoint
					)

			ext:

			EXEC sp_xml_removedocument @idoc

			UPDATE tblQMProductStage
			SET strFeedStatus = 'Processed'
				,strMessage = 'Success'
			WHERE intProductStageId = @intProductStageId

			-- Audit Log
			IF (@intNewProductId > 0)
			BEGIN
				DECLARE @StrDescription AS NVARCHAR(MAX)

				IF @strRowState = 'Added'
				BEGIN
					SELECT @StrDescription = 'Created '

					EXEC uspSMAuditLog @keyValue = @intNewProductId
						,@screenName = 'Quality.view.QualityTemplate'
						,@entityId = @intLastModifiedUserId
						,@actionType = 'Created'
						,@actionIcon = 'small-new-plus'
						,@changeDescription = @StrDescription
						,@fromValue = ''
						,@toValue = @strProductValue
				END
				ELSE IF @strRowState = 'Modified'
				BEGIN
					SELECT @StrDescription = 'Updated '

					EXEC uspSMAuditLog @keyValue = @intNewProductId
						,@screenName = 'Quality.view.QualityTemplate'
						,@entityId = @intLastModifiedUserId
						,@actionType = 'Updated'
						,@actionIcon = 'small-tree-modified'
						,@changeDescription = @StrDescription
						,@fromValue = ''
						,@toValue = @strProductValue
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

			UPDATE tblQMProductStage
			SET strFeedStatus = 'Failed'
				,strMessage = @ErrMsg
			WHERE intProductStageId = @intProductStageId
		END CATCH

		SELECT @intProductStageId = MIN(intProductStageId)
		FROM tblQMProductStage
		WHERE intProductStageId > @intProductStageId
			AND ISNULL(strFeedStatus, '') = ''
	END
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
