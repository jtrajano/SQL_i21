CREATE PROCEDURE uspIPPropertyProcessStgXML
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @idoc INT
		,@intTransactionCount INT
		,@ErrMsg NVARCHAR(MAX)
		,@strErrorMessage NVARCHAR(MAX)
	DECLARE @intPropertyStageId INT
		,@intPropertyId INT
		,@strHeaderXML NVARCHAR(MAX)
		,@strRowState NVARCHAR(MAX)
		,@intMultiCompanyId INT
		,@strUserName NVARCHAR(100)
	DECLARE @strPropertyName NVARCHAR(100)
		,@strListName NVARCHAR(50)
		,@strItemNo NVARCHAR(50)
		,@intListId INT
		,@intItemId INT
	DECLARE @intLastModifiedUserId INT
		,@intNewPropertyId INT
		,@intPropertyRefId INT
	DECLARE @strPropertyValidityPeriodXML NVARCHAR(MAX)
		,@intPropertyValidityPeriodId INT
	DECLARE @strUnitMeasure NVARCHAR(50)
		,@intUnitMeasureId INT
	DECLARE @strConditionalPropertyXML NVARCHAR(MAX)
		,@intConditionalPropertyId INT
	DECLARE @strSuccessPropertyName NVARCHAR(100)
		,@strFailurePropertyName NVARCHAR(100)
		,@intOnSuccessPropertyId INT
		,@intOnFailurePropertyId INT
	DECLARE @tblQMPropertyStage TABLE (intPropertyStageId INT)

	INSERT INTO @tblQMPropertyStage (intPropertyStageId)
	SELECT intPropertyStageId
	FROM tblQMPropertyStage
	WHERE ISNULL(strFeedStatus, '') = ''

	SELECT @intPropertyStageId = MIN(intPropertyStageId)
	FROM @tblQMPropertyStage

	IF @intPropertyStageId IS NULL
	BEGIN
		RETURN
	END

	UPDATE t
	SET t.strFeedStatus = 'In-Progress'
	FROM tblQMPropertyStage t
	JOIN @tblQMPropertyStage pt ON pt.intPropertyStageId = t.intPropertyStageId

	WHILE @intPropertyStageId > 0
	BEGIN
		SELECT @intPropertyId = NULL
			,@strHeaderXML = NULL
			,@strRowState = NULL
			,@intMultiCompanyId = NULL
			,@strUserName = NULL
			,@strPropertyValidityPeriodXML = NULL
			,@strConditionalPropertyXML = NULL

		SELECT @intPropertyId = intPropertyId
			,@strHeaderXML = strHeaderXML
			,@strPropertyValidityPeriodXML = strPropertyValidityPeriodXML
			,@strConditionalPropertyXML = strConditionalPropertyXML
			,@strRowState = strRowState
			,@intMultiCompanyId = intMultiCompanyId
			,@strUserName = strUserName
		FROM tblQMPropertyStage
		WHERE intPropertyStageId = @intPropertyStageId

		BEGIN TRY
			SELECT @intPropertyRefId = @intPropertyId

			SELECT @intTransactionCount = @@TRANCOUNT

			IF @intTransactionCount = 0
				BEGIN TRANSACTION

			------------------Header------------------------------------------------------
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strHeaderXML

			SELECT @strPropertyName = NULL
				,@strListName = NULL
				,@strItemNo = NULL
				,@intListId = NULL
				,@intItemId = NULL

			SELECT @strPropertyName = strPropertyName
				,@strListName = strListName
				,@strItemNo = strItemNo
			FROM OPENXML(@idoc, 'vyuIPGetPropertys/vyuIPGetProperty', 2) WITH (
					strPropertyName NVARCHAR(100)
					,strListName NVARCHAR(50)
					,strItemNo NVARCHAR(50)
					) x

			IF @strListName IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblQMList t
					WHERE t.strListName = @strListName
					)
			BEGIN
				SELECT @strErrorMessage = 'List ' + @strListName + ' is not available.'

				RAISERROR (
						@strErrorMessage
						,16
						,1
						)
			END

			IF @strItemNo IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblICItem t
					WHERE t.strItemNo = @strItemNo
					)
			BEGIN
				SELECT @strErrorMessage = 'Item No ' + @strItemNo + ' is not available.'

				RAISERROR (
						@strErrorMessage
						,16
						,1
						)
			END

			SELECT @intListId = t.intListId
			FROM tblQMList t
			WHERE t.strListName = @strListName

			SELECT @intItemId = t.intItemId
			FROM tblICItem t
			WHERE t.strItemNo = @strItemNo

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
						FROM tblQMProperty
						WHERE intPropertyRefId = @intPropertyRefId
						)
					SELECT @strRowState = 'Added'
				ELSE
					SELECT @strRowState = 'Modified'
			END

			IF @strRowState = 'Delete'
			BEGIN
				SELECT @intNewPropertyId = @intPropertyRefId
					,@strPropertyName = @strPropertyName

				DELETE
				FROM tblQMProperty
				WHERE intPropertyRefId = @intPropertyRefId

				GOTO ext
			END

			IF @strRowState = 'Added'
			BEGIN
				INSERT INTO tblQMProperty (
					intAnalysisTypeId
					,intConcurrencyId
					,strPropertyName
					,strDescription
					,intDataTypeId
					,intListId
					,intDecimalPlaces
					,strIsMandatory
					,ysnActive
					,strFormula
					,strFormulaParser
					,strDefaultValue
					,ysnNotify
					,intItemId
					,intCreatedUserId
					,dtmCreated
					,intLastModifiedUserId
					,dtmLastModified
					,intPropertyRefId
					)
				SELECT intAnalysisTypeId
					,1
					,strPropertyName
					,strDescription
					,intDataTypeId
					,@intListId
					,intDecimalPlaces
					,strIsMandatory
					,ysnActive
					,strFormula
					,strFormulaParser
					,strDefaultValue
					,ysnNotify
					,@intItemId
					,@intLastModifiedUserId
					,dtmCreated
					,@intLastModifiedUserId
					,dtmLastModified
					,@intPropertyRefId
				FROM OPENXML(@idoc, 'vyuIPGetPropertys/vyuIPGetProperty', 2) WITH (
						intAnalysisTypeId INT
						,strPropertyName NVARCHAR(100)
						,strDescription NVARCHAR(500)
						,intDataTypeId INT
						,intDecimalPlaces INT
						,strIsMandatory NVARCHAR(20)
						,ysnActive BIT
						,strFormula NVARCHAR(MAX)
						,strFormulaParser NVARCHAR(MAX)
						,strDefaultValue NVARCHAR(50)
						,ysnNotify BIT
						,dtmCreated DATETIME
						,dtmLastModified DATETIME
						)

				SELECT @intNewPropertyId = SCOPE_IDENTITY()
			END

			IF @strRowState = 'Modified'
			BEGIN
				UPDATE tblQMProperty
				SET intConcurrencyId = intConcurrencyId + 1
					,intAnalysisTypeId = x.intAnalysisTypeId
					,strPropertyName = x.strPropertyName
					,strDescription = x.strDescription
					,intDataTypeId = x.intDataTypeId
					,intListId = @intListId
					,intDecimalPlaces = x.intDecimalPlaces
					,strIsMandatory = x.strIsMandatory
					,ysnActive = x.ysnActive
					,strFormula = x.strFormula
					,strFormulaParser = x.strFormulaParser
					,strDefaultValue = x.strDefaultValue
					,ysnNotify = x.ysnNotify
					,intItemId = @intItemId
					,intLastModifiedUserId = @intLastModifiedUserId
					,dtmLastModified = x.dtmLastModified
				FROM OPENXML(@idoc, 'vyuIPGetPropertys/vyuIPGetProperty', 2) WITH (
						intAnalysisTypeId INT
						,strPropertyName NVARCHAR(100)
						,strDescription NVARCHAR(500)
						,intDataTypeId INT
						,intDecimalPlaces INT
						,strIsMandatory NVARCHAR(20)
						,ysnActive BIT
						,strFormula NVARCHAR(MAX)
						,strFormulaParser NVARCHAR(MAX)
						,strDefaultValue NVARCHAR(50)
						,ysnNotify BIT
						,dtmLastModified DATETIME
						) x
				WHERE tblQMProperty.intPropertyRefId = @intPropertyRefId

				SELECT @intNewPropertyId = intPropertyId
				FROM tblQMProperty
				WHERE intPropertyRefId = @intPropertyRefId
			END

			EXEC sp_xml_removedocument @idoc

			------------------------------------Property Validity Period--------------------------------------------
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strPropertyValidityPeriodXML

			DECLARE @tblQMPropertyValidityPeriod TABLE (intPropertyValidityPeriodId INT)

			INSERT INTO @tblQMPropertyValidityPeriod (intPropertyValidityPeriodId)
			SELECT intPropertyValidityPeriodId
			FROM OPENXML(@idoc, 'vyuIPGetPropertyValidityPeriods/vyuIPGetPropertyValidityPeriod', 2) WITH (intPropertyValidityPeriodId INT)

			SELECT @intPropertyValidityPeriodId = MIN(intPropertyValidityPeriodId)
			FROM @tblQMPropertyValidityPeriod

			WHILE @intPropertyValidityPeriodId IS NOT NULL
			BEGIN
				SELECT @strUnitMeasure = NULL
					,@intUnitMeasureId = NULL

				SELECT @strUnitMeasure = strUnitMeasure
				FROM OPENXML(@idoc, 'vyuIPGetPropertyValidityPeriods/vyuIPGetPropertyValidityPeriod', 2) WITH (
						strUnitMeasure NVARCHAR(50) Collate Latin1_General_CI_AS
						,intPropertyValidityPeriodId INT
						) SD
				WHERE intPropertyValidityPeriodId = @intPropertyValidityPeriodId

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

				SELECT @intUnitMeasureId = t.intUnitMeasureId
				FROM tblICUnitMeasure t
				WHERE t.strUnitMeasure = @strUnitMeasure

				IF NOT EXISTS (
						SELECT 1
						FROM tblQMPropertyValidityPeriod
						WHERE intPropertyId = @intNewPropertyId
							AND intPropertyValidityPeriodRefId = @intPropertyValidityPeriodId
						)
				BEGIN
					INSERT INTO tblQMPropertyValidityPeriod (
						intPropertyId
						,intConcurrencyId
						,dtmValidFrom
						,dtmValidTo
						,strPropertyRangeText
						,dblMinValue
						,dblMaxValue
						,dblLowValue
						,dblHighValue
						,intUnitMeasureId
						,intCreatedUserId
						,dtmCreated
						,intLastModifiedUserId
						,dtmLastModified
						,intPropertyValidityPeriodRefId
						)
					SELECT @intNewPropertyId
						,1
						,dtmValidFrom
						,dtmValidTo
						,strPropertyRangeText
						,dblMinValue
						,dblMaxValue
						,dblLowValue
						,dblHighValue
						,@intUnitMeasureId
						,@intLastModifiedUserId
						,dtmCreated
						,@intLastModifiedUserId
						,dtmLastModified
						,@intPropertyValidityPeriodId
					FROM OPENXML(@idoc, 'vyuIPGetPropertyValidityPeriods/vyuIPGetPropertyValidityPeriod', 2) WITH (
							dtmValidFrom DATETIME
							,dtmValidTo DATETIME
							,strPropertyRangeText NVARCHAR(MAX)
							,dblMinValue NUMERIC(18, 6)
							,dblMaxValue NUMERIC(18, 6)
							,dblLowValue NUMERIC(18, 6)
							,dblHighValue NUMERIC(18, 6)
							,dtmCreated DATETIME
							,dtmLastModified DATETIME
							,intPropertyValidityPeriodId INT
							) x
					WHERE x.intPropertyValidityPeriodId = @intPropertyValidityPeriodId
				END
				ELSE
				BEGIN
					UPDATE tblQMPropertyValidityPeriod
					SET intConcurrencyId = intConcurrencyId + 1
						,dtmValidFrom = x.dtmValidFrom
						,dtmValidTo = x.dtmValidTo
						,strPropertyRangeText = x.strPropertyRangeText
						,dblMinValue = x.dblMinValue
						,dblMaxValue = x.dblMaxValue
						,dblLowValue = x.dblLowValue
						,dblHighValue = x.dblHighValue
						,intUnitMeasureId = @intUnitMeasureId
						,intLastModifiedUserId = @intLastModifiedUserId
						,dtmLastModified = x.dtmLastModified
					FROM OPENXML(@idoc, 'vyuIPGetPropertyValidityPeriods/vyuIPGetPropertyValidityPeriod', 2) WITH (
							dtmValidFrom DATETIME
							,dtmValidTo DATETIME
							,strPropertyRangeText NVARCHAR(MAX)
							,dblMinValue NUMERIC(18, 6)
							,dblMaxValue NUMERIC(18, 6)
							,dblLowValue NUMERIC(18, 6)
							,dblHighValue NUMERIC(18, 6)
							,dtmLastModified DATETIME
							,intPropertyValidityPeriodId INT
							) x
					JOIN tblQMPropertyValidityPeriod D ON D.intPropertyValidityPeriodRefId = x.intPropertyValidityPeriodId
						AND D.intPropertyId = @intNewPropertyId
					WHERE x.intPropertyValidityPeriodId = @intPropertyValidityPeriodId
				END

				SELECT @intPropertyValidityPeriodId = MIN(intPropertyValidityPeriodId)
				FROM @tblQMPropertyValidityPeriod
				WHERE intPropertyValidityPeriodId > @intPropertyValidityPeriodId
			END

			DELETE
			FROM tblQMPropertyValidityPeriod
			WHERE intPropertyId = @intNewPropertyId
				AND intPropertyValidityPeriodRefId NOT IN (
					SELECT intPropertyValidityPeriodId
					FROM @tblQMPropertyValidityPeriod
					)

			EXEC sp_xml_removedocument @idoc

			------------------------------------Conditional Property--------------------------------------------
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strConditionalPropertyXML

			DECLARE @tblQMConditionalProperty TABLE (intConditionalPropertyId INT)

			INSERT INTO @tblQMConditionalProperty (intConditionalPropertyId)
			SELECT intConditionalPropertyId
			FROM OPENXML(@idoc, 'vyuIPGetConditionalPropertys/vyuIPGetConditionalProperty', 2) WITH (intConditionalPropertyId INT)

			SELECT @intConditionalPropertyId = MIN(intConditionalPropertyId)
			FROM @tblQMConditionalProperty

			WHILE @intConditionalPropertyId IS NOT NULL
			BEGIN
				SELECT @strSuccessPropertyName = NULL
					,@strFailurePropertyName = NULL
					,@intOnSuccessPropertyId = NULL
					,@intOnFailurePropertyId = NULL

				SELECT @strSuccessPropertyName = strSuccessPropertyName
					,@strFailurePropertyName = strFailurePropertyName
				FROM OPENXML(@idoc, 'vyuIPGetConditionalPropertys/vyuIPGetConditionalProperty', 2) WITH (
						strSuccessPropertyName NVARCHAR(100) Collate Latin1_General_CI_AS
						,strFailurePropertyName NVARCHAR(100) Collate Latin1_General_CI_AS
						,intConditionalPropertyId INT
						) SD
				WHERE intConditionalPropertyId = @intConditionalPropertyId

				IF @strSuccessPropertyName IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblQMProperty t
						WHERE t.strPropertyName = @strSuccessPropertyName
						)
				BEGIN
					SELECT @strErrorMessage = 'Success Property ' + @strSuccessPropertyName + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				IF @strFailurePropertyName IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblQMProperty t
						WHERE t.strPropertyName = @strFailurePropertyName
						)
				BEGIN
					SELECT @strErrorMessage = 'Failure Property ' + @strFailurePropertyName + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				SELECT @intOnSuccessPropertyId = t.intPropertyId
				FROM tblQMProperty t
				WHERE t.strPropertyName = @strSuccessPropertyName

				SELECT @intOnFailurePropertyId = t.intPropertyId
				FROM tblQMProperty t
				WHERE t.strPropertyName = @strFailurePropertyName

				IF NOT EXISTS (
						SELECT 1
						FROM tblQMConditionalProperty
						WHERE intConditionalPropertyRefId = @intConditionalPropertyId
						)
				BEGIN
					INSERT INTO tblQMConditionalProperty (
						intPropertyId
						,intConcurrencyId
						,intOnSuccessPropertyId
						,intOnFailurePropertyId
						,intCreatedUserId
						,dtmCreated
						,intLastModifiedUserId
						,dtmLastModified
						,intConditionalPropertyRefId
						)
					SELECT @intNewPropertyId
						,1
						,@intOnSuccessPropertyId
						,@intOnFailurePropertyId
						,@intLastModifiedUserId
						,dtmCreated
						,@intLastModifiedUserId
						,dtmLastModified
						,@intConditionalPropertyId
					FROM OPENXML(@idoc, 'vyuIPGetConditionalPropertys/vyuIPGetConditionalProperty', 2) WITH (
							dtmCreated DATETIME
							,dtmLastModified DATETIME
							,intConditionalPropertyId INT
							) x
					WHERE x.intConditionalPropertyId = @intConditionalPropertyId
				END
				ELSE
				BEGIN
					UPDATE tblQMConditionalProperty
					SET intConcurrencyId = intConcurrencyId + 1
						,intOnSuccessPropertyId = @intOnSuccessPropertyId
						,intOnFailurePropertyId = @intOnFailurePropertyId
						,intLastModifiedUserId = @intLastModifiedUserId
						,dtmLastModified = x.dtmLastModified
					FROM OPENXML(@idoc, 'vyuIPGetConditionalPropertys/vyuIPGetConditionalProperty', 2) WITH (
							dtmLastModified DATETIME
							,intConditionalPropertyId INT
							) x
					JOIN tblQMConditionalProperty D ON D.intConditionalPropertyRefId = x.intConditionalPropertyId
						AND D.intPropertyId = @intNewPropertyId
					WHERE x.intConditionalPropertyId = @intConditionalPropertyId
				END

				SELECT @intConditionalPropertyId = MIN(intConditionalPropertyId)
				FROM @tblQMConditionalProperty
				WHERE intConditionalPropertyId > @intConditionalPropertyId
			END

			DELETE
			FROM tblQMConditionalProperty
			WHERE intPropertyId = @intNewPropertyId
				AND intConditionalPropertyRefId NOT IN (
					SELECT intConditionalPropertyId
					FROM @tblQMConditionalProperty
					)

			ext:

			EXEC sp_xml_removedocument @idoc

			UPDATE tblQMPropertyStage
			SET strFeedStatus = 'Processed'
				,strMessage = 'Success'
			WHERE intPropertyStageId = @intPropertyStageId

			-- Audit Log
			IF (@intNewPropertyId > 0)
			BEGIN
				DECLARE @StrDescription AS NVARCHAR(MAX)

				IF @strRowState = 'Added'
				BEGIN
					SELECT @StrDescription = 'Created '

					EXEC uspSMAuditLog @keyValue = @intNewPropertyId
						,@screenName = 'Quality.view.Property'
						,@entityId = @intLastModifiedUserId
						,@actionType = 'Created'
						,@actionIcon = 'small-new-plus'
						,@changeDescription = @StrDescription
						,@fromValue = ''
						,@toValue = @strPropertyName
				END
				ELSE IF @strRowState = 'Modified'
				BEGIN
					SELECT @StrDescription = 'Updated '

					EXEC uspSMAuditLog @keyValue = @intNewPropertyId
						,@screenName = 'Quality.view.Property'
						,@entityId = @intLastModifiedUserId
						,@actionType = 'Updated'
						,@actionIcon = 'small-tree-modified'
						,@changeDescription = @StrDescription
						,@fromValue = ''
						,@toValue = @strPropertyName
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

			UPDATE tblQMPropertyStage
			SET strFeedStatus = 'Failed'
				,strMessage = @ErrMsg
			WHERE intPropertyStageId = @intPropertyStageId
		END CATCH

		SELECT @intPropertyStageId = MIN(intPropertyStageId)
		FROM @tblQMPropertyStage
		WHERE intPropertyStageId > @intPropertyStageId
			--AND ISNULL(strFeedStatus, '') = ''
	END

	UPDATE t
	SET t.strFeedStatus = NULL
	FROM tblQMPropertyStage t
	JOIN @tblQMPropertyStage pt ON pt.intPropertyStageId = t.intPropertyStageId
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
