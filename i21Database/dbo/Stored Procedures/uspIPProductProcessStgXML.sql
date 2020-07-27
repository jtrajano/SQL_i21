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
		,@ysnActive BIT
	DECLARE @intLastModifiedUserId INT
		,@intNewProductId INT
		,@intProductRefId INT
	DECLARE @strProductControlPointXML NVARCHAR(MAX)
		,@intProductControlPointId INT
	DECLARE @strSampleTypeName NVARCHAR(50)
		,@strControlPointName NVARCHAR(50)
		,@intSampleTypeId INT
		,@intControlPointId INT
	DECLARE @strProductTestXML NVARCHAR(MAX)
		,@intProductTestId INT
	DECLARE @strTestName NVARCHAR(50)
		,@intTestId INT
	DECLARE @strProductPropertyXML NVARCHAR(MAX)
		,@intProductPropertyId INT
	DECLARE @strPPTestName NVARCHAR(50)
		,@strPPPropertyName NVARCHAR(100)
		,@intPPTestId INT
		,@intPPPropertyId INT
	DECLARE @strProductPropertyValidityPeriodXML NVARCHAR(MAX)
		,@intProductPropertyValidityPeriodId INT
	DECLARE @strPPVUnitMeasure NVARCHAR(50)
		,@intPPVUnitMeasureId INT
	DECLARE @strConditionalProductPropertyXML NVARCHAR(MAX)
		,@intConditionalProductPropertyId INT
	DECLARE @strSuccessPropertyName NVARCHAR(100)
		,@strFailurePropertyName NVARCHAR(100)
		,@intOnSuccessPropertyId INT
		,@intOnFailurePropertyId INT
	DECLARE @strProductPropertyFormulaPropertyXML NVARCHAR(MAX)
		,@intProductPropertyFormulaPropertyId INT
	DECLARE @strFormulaTestName NVARCHAR(50)
		,@strFormulaPropertyName NVARCHAR(100)
		,@intFormulaTestId INT
		,@intFormulaPropertyId INT
	-- Using to identify the Product Property Id
	DECLARE @TestName NVARCHAR(50)
		,@PropertyName NVARCHAR(100)
		,@TestId INT
		,@PropertyId INT
		,@ProductPropertyId INT
	DECLARE @tblQMProductStage TABLE (intProductStageId INT)

	INSERT INTO @tblQMProductStage (intProductStageId)
	SELECT intProductStageId
	FROM tblQMProductStage
	WHERE ISNULL(strFeedStatus, '') = ''

	SELECT @intProductStageId = MIN(intProductStageId)
	FROM @tblQMProductStage

	IF @intProductStageId IS NULL
	BEGIN
		RETURN
	END

	UPDATE t
	SET t.strFeedStatus = 'In-Progress'
	FROM tblQMProductStage t
	JOIN @tblQMProductStage pt ON pt.intProductStageId = t.intProductStageId

	WHILE @intProductStageId > 0
	BEGIN
		SELECT @intProductId = NULL
			,@strHeaderXML = NULL
			,@strRowState = NULL
			,@intMultiCompanyId = NULL
			,@strUserName = NULL
			,@strProductControlPointXML = NULL
			,@intProductControlPointId = NULL
			,@strProductTestXML = NULL
			,@intProductTestId = NULL
			,@strProductPropertyXML = NULL
			,@intProductPropertyId = NULL
			,@strProductPropertyValidityPeriodXML = NULL
			,@intProductPropertyValidityPeriodId = NULL
			,@strConditionalProductPropertyXML = NULL
			,@intConditionalProductPropertyId = NULL
			,@strProductPropertyFormulaPropertyXML = NULL
			,@intProductPropertyFormulaPropertyId = NULL

		SELECT @intProductId = intProductId
			,@strHeaderXML = strHeaderXML
			,@strProductControlPointXML = strProductControlPointXML
			,@strProductTestXML = strProductTestXML
			,@strProductPropertyXML = strProductPropertyXML
			,@strProductPropertyValidityPeriodXML = strProductPropertyValidityPeriodXML
			,@strConditionalProductPropertyXML = strConditionalProductPropertyXML
			,@strProductPropertyFormulaPropertyXML = strProductPropertyFormulaPropertyXML
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
				,@ysnActive = NULL

			SELECT @strProductValue = strProductValue
				,@strApprovalLotStatus = strApprovalLotStatus
				,@strRejectionLotStatus = strRejectionLotStatus
				,@strBondedApprovalLotStatus = strBondedApprovalLotStatus
				,@strBondedRejectionLotStatus = strBondedRejectionLotStatus
				,@strUnitMeasure = strUnitMeasure
				,@intProductTypeId = intProductTypeId
				,@ysnActive = ysnActive
			FROM OPENXML(@idoc, 'vyuIPGetProducts/vyuIPGetProduct', 2) WITH (
					strProductValue NVARCHAR(50)
					,strApprovalLotStatus NVARCHAR(50)
					,strRejectionLotStatus NVARCHAR(50)
					,strBondedApprovalLotStatus NVARCHAR(50)
					,strBondedRejectionLotStatus NVARCHAR(50)
					,strUnitMeasure NVARCHAR(50)
					,intProductTypeId INT
					,ysnActive BIT
					) x

			IF @strProductValue IS NULL
				AND @strRowState <> 'Delete'
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

			IF @ysnActive = 1
			BEGIN
				UPDATE P
				SET P.ysnActive = 0
				FROM tblQMProduct P
				JOIN tblQMProductControlPoint PC ON PC.intProductId = P.intProductId
				WHERE P.intProductTypeId = @intProductTypeId
					AND P.intProductValueId = @intProductValueId
					AND P.intProductId <> @intNewProductId
					AND PC.intSampleTypeId IN (
						SELECT PC1.intSampleTypeId
						FROM tblQMProductControlPoint PC1
						WHERE PC1.intProductId = @intNewProductId
						)
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

			EXEC sp_xml_removedocument @idoc

			------------------------------------Product Test--------------------------------------------
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strProductTestXML

			DECLARE @tblQMProductTest TABLE (intProductTestId INT)

			INSERT INTO @tblQMProductTest (intProductTestId)
			SELECT intProductTestId
			FROM OPENXML(@idoc, 'vyuIPGetProductTests/vyuIPGetProductTest', 2) WITH (intProductTestId INT)

			SELECT @intProductTestId = MIN(intProductTestId)
			FROM @tblQMProductTest

			WHILE @intProductTestId IS NOT NULL
			BEGIN
				SELECT @strTestName = NULL
					,@intTestId = NULL

				SELECT @strTestName = strTestName
				FROM OPENXML(@idoc, 'vyuIPGetProductTests/vyuIPGetProductTest', 2) WITH (
						strTestName NVARCHAR(50) Collate Latin1_General_CI_AS
						,intProductTestId INT
						) SD
				WHERE intProductTestId = @intProductTestId

				IF @strTestName IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblQMTest t
						WHERE t.strTestName = @strTestName
						)
				BEGIN
					SELECT @strErrorMessage = 'Test Name ' + @strTestName + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				SELECT @intTestId = t.intTestId
				FROM tblQMTest t
				WHERE t.strTestName = @strTestName

				IF NOT EXISTS (
						SELECT 1
						FROM tblQMProductTest
						WHERE intProductId = @intNewProductId
							AND intProductTestRefId = @intProductTestId
						)
				BEGIN
					INSERT INTO tblQMProductTest (
						intConcurrencyId
						,intProductId
						,intTestId
						,intProductTestRefId
						,intCreatedUserId
						,dtmCreated
						,intLastModifiedUserId
						,dtmLastModified
						)
					SELECT 1
						,@intNewProductId
						,@intTestId
						,@intProductTestId
						,@intLastModifiedUserId
						,dtmCreated
						,@intLastModifiedUserId
						,dtmLastModified
					FROM OPENXML(@idoc, 'vyuIPGetProductTests/vyuIPGetProductTest', 2) WITH (
							dtmCreated DATETIME
							,dtmLastModified DATETIME
							,intProductTestId INT
							) x
					WHERE x.intProductTestId = @intProductTestId
				END
				ELSE
				BEGIN
					UPDATE tblQMProductTest
					SET intConcurrencyId = intConcurrencyId + 1
						,intTestId = @intTestId
						,intLastModifiedUserId = @intLastModifiedUserId
						,dtmLastModified = x.dtmLastModified
					FROM OPENXML(@idoc, 'vyuIPGetProductTests/vyuIPGetProductTest', 2) WITH (
							dtmLastModified DATETIME
							,intProductTestId INT
							) x
					JOIN tblQMProductTest D ON D.intProductTestRefId = x.intProductTestId
						AND D.intProductId = @intNewProductId
					WHERE x.intProductTestId = @intProductTestId
				END

				SELECT @intProductTestId = MIN(intProductTestId)
				FROM @tblQMProductTest
				WHERE intProductTestId > @intProductTestId
			END

			DELETE
			FROM tblQMProductTest
			WHERE intProductId = @intNewProductId
				AND intProductTestRefId NOT IN (
					SELECT intProductTestId
					FROM @tblQMProductTest
					)

			EXEC sp_xml_removedocument @idoc

			------------------------------------Product Property--------------------------------------------
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strProductPropertyXML

			DECLARE @tblQMProductProperty TABLE (intProductPropertyId INT)

			INSERT INTO @tblQMProductProperty (intProductPropertyId)
			SELECT intProductPropertyId
			FROM OPENXML(@idoc, 'vyuIPGetProductPropertys/vyuIPGetProductProperty', 2) WITH (intProductPropertyId INT)

			SELECT @intProductPropertyId = MIN(intProductPropertyId)
			FROM @tblQMProductProperty

			WHILE @intProductPropertyId IS NOT NULL
			BEGIN
				SELECT @strPPTestName = NULL
					,@strPPPropertyName = NULL
					,@intPPTestId = NULL
					,@intPPPropertyId = NULL

				SELECT @strPPTestName = strTestName
					,@strPPPropertyName = strPropertyName
				FROM OPENXML(@idoc, 'vyuIPGetProductPropertys/vyuIPGetProductProperty', 2) WITH (
						strTestName NVARCHAR(50) Collate Latin1_General_CI_AS
						,strPropertyName NVARCHAR(100) Collate Latin1_General_CI_AS
						,intProductPropertyId INT
						) SD
				WHERE intProductPropertyId = @intProductPropertyId

				IF @strPPTestName IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblQMTest t
						WHERE t.strTestName = @strPPTestName
						)
				BEGIN
					SELECT @strErrorMessage = 'PP Test Name ' + @strPPTestName + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				IF @strPPPropertyName IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblQMProperty t
						WHERE t.strPropertyName = @strPPPropertyName
						)
				BEGIN
					SELECT @strErrorMessage = 'PP Property Name ' + @strPPPropertyName + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				SELECT @intPPTestId = t.intTestId
				FROM tblQMTest t
				WHERE t.strTestName = @strPPTestName

				SELECT @intPPPropertyId = t.intPropertyId
				FROM tblQMProperty t
				WHERE t.strPropertyName = @strPPPropertyName

				IF NOT EXISTS (
						SELECT 1
						FROM tblQMProductProperty
						WHERE intProductId = @intNewProductId
							AND intProductPropertyRefId = @intProductPropertyId
						)
				BEGIN
					INSERT INTO tblQMProductProperty (
						intConcurrencyId
						,intProductId
						,intTestId
						,intPropertyId
						,strFormulaParser
						,strComputationMethod
						,intSequenceNo
						,intComputationTypeId
						,strFormulaField
						,strIsMandatory
						,ysnPrintInLabel
						,intProductPropertyRefId
						,intCreatedUserId
						,dtmCreated
						,intLastModifiedUserId
						,dtmLastModified
						)
					SELECT 1
						,@intNewProductId
						,@intPPTestId
						,@intPPPropertyId
						,strFormulaParser
						,strComputationMethod
						,intSequenceNo
						,intComputationTypeId
						,strFormulaField
						,strIsMandatory
						,ysnPrintInLabel
						,@intProductPropertyId
						,@intLastModifiedUserId
						,dtmCreated
						,@intLastModifiedUserId
						,dtmLastModified
					FROM OPENXML(@idoc, 'vyuIPGetProductPropertys/vyuIPGetProductProperty', 2) WITH (
							strFormulaParser NVARCHAR(MAX)
							,strComputationMethod NVARCHAR(30)
							,intSequenceNo INT
							,intComputationTypeId INT
							,strFormulaField NVARCHAR(MAX)
							,strIsMandatory NVARCHAR(20)
							,ysnPrintInLabel BIT
							,dtmCreated DATETIME
							,dtmLastModified DATETIME
							,intProductPropertyId INT
							) x
					WHERE x.intProductPropertyId = @intProductPropertyId
				END
				ELSE
				BEGIN
					UPDATE tblQMProductProperty
					SET intConcurrencyId = intConcurrencyId + 1
						,intTestId = @intPPTestId
						,intPropertyId = @intPPPropertyId
						,strFormulaParser = x.strFormulaParser
						,strComputationMethod = x.strComputationMethod
						,intSequenceNo = x.intSequenceNo
						,intComputationTypeId = x.intComputationTypeId
						,strFormulaField = x.strFormulaField
						,strIsMandatory = x.strIsMandatory
						,ysnPrintInLabel = x.ysnPrintInLabel
						,intLastModifiedUserId = @intLastModifiedUserId
						,dtmLastModified = x.dtmLastModified
					FROM OPENXML(@idoc, 'vyuIPGetProductPropertys/vyuIPGetProductProperty', 2) WITH (
							strFormulaParser NVARCHAR(MAX)
							,strComputationMethod NVARCHAR(30)
							,intSequenceNo INT
							,intComputationTypeId INT
							,strFormulaField NVARCHAR(MAX)
							,strIsMandatory NVARCHAR(20)
							,ysnPrintInLabel BIT
							,dtmLastModified DATETIME
							,intProductPropertyId INT
							) x
					JOIN tblQMProductProperty D ON D.intProductPropertyRefId = x.intProductPropertyId
						AND D.intProductId = @intNewProductId
					WHERE x.intProductPropertyId = @intProductPropertyId
				END

				SELECT @intProductPropertyId = MIN(intProductPropertyId)
				FROM @tblQMProductProperty
				WHERE intProductPropertyId > @intProductPropertyId
			END

			DELETE
			FROM tblQMProductProperty
			WHERE intProductId = @intNewProductId
				AND intProductPropertyRefId NOT IN (
					SELECT intProductPropertyId
					FROM @tblQMProductProperty
					)

			EXEC sp_xml_removedocument @idoc

			------------------------------------Product Property Validity Period--------------------------------------------
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strProductPropertyValidityPeriodXML

			DECLARE @tblQMProductPropertyValidityPeriod TABLE (intProductPropertyValidityPeriodId INT)

			INSERT INTO @tblQMProductPropertyValidityPeriod (intProductPropertyValidityPeriodId)
			SELECT intProductPropertyValidityPeriodId
			FROM OPENXML(@idoc, 'vyuIPGetProductPropertyValidityPeriods/vyuIPGetProductPropertyValidityPeriod', 2) WITH (intProductPropertyValidityPeriodId INT)

			SELECT @intProductPropertyValidityPeriodId = MIN(intProductPropertyValidityPeriodId)
			FROM @tblQMProductPropertyValidityPeriod

			WHILE @intProductPropertyValidityPeriodId IS NOT NULL
			BEGIN
				SELECT @strPPVUnitMeasure = NULL
					,@intPPVUnitMeasureId = NULL
					,@TestName = NULL
					,@PropertyName = NULL
					,@TestId = NULL
					,@PropertyId = NULL
					,@ProductPropertyId = NULL

				SELECT @strPPVUnitMeasure = strUnitMeasure
					,@TestName = strTestName
					,@PropertyName = strPropertyName
				FROM OPENXML(@idoc, 'vyuIPGetProductPropertyValidityPeriods/vyuIPGetProductPropertyValidityPeriod', 2) WITH (
						strUnitMeasure NVARCHAR(50) Collate Latin1_General_CI_AS
						,strTestName NVARCHAR(50) Collate Latin1_General_CI_AS
						,strPropertyName NVARCHAR(100) Collate Latin1_General_CI_AS
						,intProductPropertyValidityPeriodId INT
						) SD
				WHERE intProductPropertyValidityPeriodId = @intProductPropertyValidityPeriodId

				IF @strPPVUnitMeasure IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblICUnitMeasure t
						WHERE t.strUnitMeasure = @strPPVUnitMeasure
						)
				BEGIN
					SELECT @strErrorMessage = 'PPV UOM ' + @strPPVUnitMeasure + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				SELECT @intPPVUnitMeasureId = t.intUnitMeasureId
				FROM tblICUnitMeasure t
				WHERE t.strUnitMeasure = @strPPVUnitMeasure

				SELECT @TestId = t.intTestId
				FROM tblQMTest t
				WHERE t.strTestName = @TestName

				SELECT @PropertyId = t.intPropertyId
				FROM tblQMProperty t
				WHERE t.strPropertyName = @PropertyName

				SELECT @ProductPropertyId = intProductPropertyId
				FROM tblQMProductProperty t
				WHERE t.intProductId = @intNewProductId
					AND t.intTestId = @TestId
					AND t.intPropertyId = @PropertyId

				IF NOT EXISTS (
						SELECT 1
						FROM tblQMProductPropertyValidityPeriod
						WHERE intProductPropertyId = @ProductPropertyId
							AND intProductPropertyValidityPeriodRefId = @intProductPropertyValidityPeriodId
						)
				BEGIN
					INSERT INTO tblQMProductPropertyValidityPeriod (
						intConcurrencyId
						,intProductPropertyId
						,dtmValidFrom
						,dtmValidTo
						,strPropertyRangeText
						,dblMinValue
						,dblMaxValue
						,dblLowValue
						,dblHighValue
						,intUnitMeasureId
						,strFormula
						,strFormulaParser
						,intProductPropertyValidityPeriodRefId
						,intCreatedUserId
						,dtmCreated
						,intLastModifiedUserId
						,dtmLastModified
						)
					SELECT 1
						,@ProductPropertyId
						,dtmValidFrom
						,dtmValidTo
						,strPropertyRangeText
						,dblMinValue
						,dblMaxValue
						,dblLowValue
						,dblHighValue
						,@intPPVUnitMeasureId
						,strFormula
						,strFormulaParser
						,@intProductPropertyValidityPeriodId
						,@intLastModifiedUserId
						,dtmCreated
						,@intLastModifiedUserId
						,dtmLastModified
					FROM OPENXML(@idoc, 'vyuIPGetProductPropertyValidityPeriods/vyuIPGetProductPropertyValidityPeriod', 2) WITH (
							dtmValidFrom DATETIME
							,dtmValidTo DATETIME
							,strPropertyRangeText NVARCHAR(MAX)
							,dblMinValue NUMERIC(18, 6)
							,dblMaxValue NUMERIC(18, 6)
							,dblLowValue NUMERIC(18, 6)
							,dblHighValue NUMERIC(18, 6)
							,strFormula NVARCHAR(MAX)
							,strFormulaParser NVARCHAR(MAX)
							,dtmCreated DATETIME
							,dtmLastModified DATETIME
							,intProductPropertyValidityPeriodId INT
							) x
					WHERE x.intProductPropertyValidityPeriodId = @intProductPropertyValidityPeriodId
				END
				ELSE
				BEGIN
					UPDATE tblQMProductPropertyValidityPeriod
					SET intConcurrencyId = intConcurrencyId + 1
						,dtmValidFrom = x.dtmValidFrom
						,dtmValidTo = x.dtmValidTo
						,strPropertyRangeText = x.strPropertyRangeText
						,dblMinValue = x.dblMinValue
						,dblMaxValue = x.dblMaxValue
						,dblLowValue = x.dblLowValue
						,dblHighValue = x.dblHighValue
						,intUnitMeasureId = @intPPVUnitMeasureId
						,strFormula = x.strFormula
						,strFormulaParser = x.strFormulaParser
						,intLastModifiedUserId = @intLastModifiedUserId
						,dtmLastModified = x.dtmLastModified
					FROM OPENXML(@idoc, 'vyuIPGetProductPropertyValidityPeriods/vyuIPGetProductPropertyValidityPeriod', 2) WITH (
							dtmValidFrom DATETIME
							,dtmValidTo DATETIME
							,strPropertyRangeText NVARCHAR(MAX)
							,dblMinValue NUMERIC(18, 6)
							,dblMaxValue NUMERIC(18, 6)
							,dblLowValue NUMERIC(18, 6)
							,dblHighValue NUMERIC(18, 6)
							,strFormula NVARCHAR(MAX)
							,strFormulaParser NVARCHAR(MAX)
							,dtmLastModified DATETIME
							,intProductPropertyValidityPeriodId INT
							) x
					JOIN tblQMProductPropertyValidityPeriod D ON D.intProductPropertyValidityPeriodRefId = x.intProductPropertyValidityPeriodId
						AND D.intProductPropertyId = @ProductPropertyId
					WHERE x.intProductPropertyValidityPeriodId = @intProductPropertyValidityPeriodId
				END

				SELECT @intProductPropertyValidityPeriodId = MIN(intProductPropertyValidityPeriodId)
				FROM @tblQMProductPropertyValidityPeriod
				WHERE intProductPropertyValidityPeriodId > @intProductPropertyValidityPeriodId
			END

			DELETE
			FROM tblQMProductPropertyValidityPeriod
			WHERE intProductPropertyId = @ProductPropertyId
				AND intProductPropertyValidityPeriodRefId NOT IN (
					SELECT intProductPropertyValidityPeriodId
					FROM @tblQMProductPropertyValidityPeriod
					)

			EXEC sp_xml_removedocument @idoc

			------------------------------------Conditional Product Property--------------------------------------------
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strConditionalProductPropertyXML

			DECLARE @tblQMConditionalProductProperty TABLE (intConditionalProductPropertyId INT)

			INSERT INTO @tblQMConditionalProductProperty (intConditionalProductPropertyId)
			SELECT intConditionalProductPropertyId
			FROM OPENXML(@idoc, 'vyuIPGetConditionalProductPropertys/vyuIPGetConditionalProductProperty', 2) WITH (intConditionalProductPropertyId INT)

			SELECT @intConditionalProductPropertyId = MIN(intConditionalProductPropertyId)
			FROM @tblQMConditionalProductProperty

			WHILE @intConditionalProductPropertyId IS NOT NULL
			BEGIN
				SELECT @strSuccessPropertyName = NULL
					,@strFailurePropertyName = NULL
					,@intOnSuccessPropertyId = NULL
					,@intOnFailurePropertyId = NULL
					,@TestName = NULL
					,@PropertyName = NULL
					,@TestId = NULL
					,@PropertyId = NULL
					,@ProductPropertyId = NULL

				SELECT @strSuccessPropertyName = strSuccessPropertyName
					,@strFailurePropertyName = strFailurePropertyName
					,@TestName = strTestName
					,@PropertyName = strPropertyName
				FROM OPENXML(@idoc, 'vyuIPGetConditionalProductPropertys/vyuIPGetConditionalProductProperty', 2) WITH (
						strSuccessPropertyName NVARCHAR(100) Collate Latin1_General_CI_AS
						,strFailurePropertyName NVARCHAR(100) Collate Latin1_General_CI_AS
						,strTestName NVARCHAR(50) Collate Latin1_General_CI_AS
						,strPropertyName NVARCHAR(100) Collate Latin1_General_CI_AS
						,intConditionalProductPropertyId INT
						) SD
				WHERE intConditionalProductPropertyId = @intConditionalProductPropertyId

				IF @strSuccessPropertyName IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblQMProperty t
						WHERE t.strPropertyName = @strSuccessPropertyName
						)
				BEGIN
					SELECT @strErrorMessage = 'Success Property Name ' + @strSuccessPropertyName + ' is not available.'

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
					SELECT @strErrorMessage = 'Failure Property Name ' + @strFailurePropertyName + ' is not available.'

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

				SELECT @TestId = t.intTestId
				FROM tblQMTest t
				WHERE t.strTestName = @TestName

				SELECT @PropertyId = t.intPropertyId
				FROM tblQMProperty t
				WHERE t.strPropertyName = @PropertyName

				SELECT @ProductPropertyId = intProductPropertyId
				FROM tblQMProductProperty t
				WHERE t.intProductId = @intNewProductId
					AND t.intTestId = @TestId
					AND t.intPropertyId = @PropertyId

				IF NOT EXISTS (
						SELECT 1
						FROM tblQMConditionalProductProperty
						WHERE intProductPropertyId = @ProductPropertyId
							AND intConditionalProductPropertyRefId = @intConditionalProductPropertyId
						)
				BEGIN
					INSERT INTO tblQMConditionalProductProperty (
						intProductPropertyId
						,intConcurrencyId
						,intOnSuccessPropertyId
						,intOnFailurePropertyId
						,intConditionalProductPropertyRefId
						,intCreatedUserId
						,dtmCreated
						,intLastModifiedUserId
						,dtmLastModified
						)
					SELECT @ProductPropertyId
						,1
						,@intOnSuccessPropertyId
						,@intOnFailurePropertyId
						,@intConditionalProductPropertyId
						,@intLastModifiedUserId
						,dtmCreated
						,@intLastModifiedUserId
						,dtmLastModified
					FROM OPENXML(@idoc, 'vyuIPGetConditionalProductPropertys/vyuIPGetConditionalProductProperty', 2) WITH (
							dtmCreated DATETIME
							,dtmLastModified DATETIME
							,intConditionalProductPropertyId INT
							) x
					WHERE x.intConditionalProductPropertyId = @intConditionalProductPropertyId
				END
				ELSE
				BEGIN
					UPDATE tblQMConditionalProductProperty
					SET intConcurrencyId = intConcurrencyId + 1
						,intOnSuccessPropertyId = @intOnSuccessPropertyId
						,intOnFailurePropertyId = @intOnFailurePropertyId
						,intLastModifiedUserId = @intLastModifiedUserId
						,dtmLastModified = x.dtmLastModified
					FROM OPENXML(@idoc, 'vyuIPGetConditionalProductPropertys/vyuIPGetConditionalProductProperty', 2) WITH (
							dtmLastModified DATETIME
							,intConditionalProductPropertyId INT
							) x
					JOIN tblQMConditionalProductProperty D ON D.intConditionalProductPropertyRefId = x.intConditionalProductPropertyId
						AND D.intProductPropertyId = @ProductPropertyId
					WHERE x.intConditionalProductPropertyId = @intConditionalProductPropertyId
				END

				SELECT @intConditionalProductPropertyId = MIN(intConditionalProductPropertyId)
				FROM @tblQMConditionalProductProperty
				WHERE intConditionalProductPropertyId > @intConditionalProductPropertyId
			END

			DELETE
			FROM tblQMConditionalProductProperty
			WHERE intProductPropertyId = @ProductPropertyId
				AND intConditionalProductPropertyRefId NOT IN (
					SELECT intConditionalProductPropertyId
					FROM @tblQMConditionalProductProperty
					)

			EXEC sp_xml_removedocument @idoc

			------------------------------------Product Property Formula Property--------------------------------------------
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strProductPropertyFormulaPropertyXML

			DECLARE @tblQMProductPropertyFormulaProperty TABLE (intProductPropertyFormulaPropertyId INT)

			INSERT INTO @tblQMProductPropertyFormulaProperty (intProductPropertyFormulaPropertyId)
			SELECT intProductPropertyFormulaPropertyId
			FROM OPENXML(@idoc, 'vyuIPGetProductPropertyFormulaPropertys/vyuIPGetProductPropertyFormulaProperty', 2) WITH (intProductPropertyFormulaPropertyId INT)

			SELECT @intProductPropertyFormulaPropertyId = MIN(intProductPropertyFormulaPropertyId)
			FROM @tblQMProductPropertyFormulaProperty

			WHILE @intProductPropertyFormulaPropertyId IS NOT NULL
			BEGIN
				SELECT @strFormulaTestName = NULL
					,@strFormulaPropertyName = NULL
					,@intFormulaTestId = NULL
					,@intFormulaPropertyId = NULL
					,@TestName = NULL
					,@PropertyName = NULL
					,@TestId = NULL
					,@PropertyId = NULL
					,@ProductPropertyId = NULL

				SELECT @strFormulaTestName = strFormulaTestName
					,@strFormulaPropertyName = strFormulaPropertyName
					,@TestName = strTestName
					,@PropertyName = strPropertyName
				FROM OPENXML(@idoc, 'vyuIPGetProductPropertyFormulaPropertys/vyuIPGetProductPropertyFormulaProperty', 2) WITH (
						strFormulaTestName NVARCHAR(50) Collate Latin1_General_CI_AS
						,strFormulaPropertyName NVARCHAR(100) Collate Latin1_General_CI_AS
						,strTestName NVARCHAR(50) Collate Latin1_General_CI_AS
						,strPropertyName NVARCHAR(100) Collate Latin1_General_CI_AS
						,intProductPropertyFormulaPropertyId INT
						) SD
				WHERE intProductPropertyFormulaPropertyId = @intProductPropertyFormulaPropertyId

				IF @strFormulaTestName IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblQMTest t
						WHERE t.strTestName = @strFormulaTestName
						)
				BEGIN
					SELECT @strErrorMessage = 'Formula Test Name ' + @strFormulaTestName + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				IF @strFormulaPropertyName IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblQMProperty t
						WHERE t.strPropertyName = @strFormulaPropertyName
						)
				BEGIN
					SELECT @strErrorMessage = 'Formula Property Name ' + @strFormulaPropertyName + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				SELECT @intFormulaTestId = t.intTestId
				FROM tblQMTest t
				WHERE t.strTestName = @strFormulaTestName

				SELECT @intFormulaPropertyId = t.intPropertyId
				FROM tblQMProperty t
				WHERE t.strPropertyName = @strFormulaPropertyName

				SELECT @TestId = t.intTestId
				FROM tblQMTest t
				WHERE t.strTestName = @TestName

				SELECT @PropertyId = t.intPropertyId
				FROM tblQMProperty t
				WHERE t.strPropertyName = @PropertyName

				SELECT @ProductPropertyId = intProductPropertyId
				FROM tblQMProductProperty t
				WHERE t.intProductId = @intNewProductId
					AND t.intTestId = @TestId
					AND t.intPropertyId = @PropertyId

				IF NOT EXISTS (
						SELECT 1
						FROM tblQMProductPropertyFormulaProperty
						WHERE intProductPropertyId = @ProductPropertyId
							AND intProductPropertyFormulaPropertyRefId = @intProductPropertyFormulaPropertyId
						)
				BEGIN
					INSERT INTO tblQMProductPropertyFormulaProperty (
						intProductPropertyId
						,intConcurrencyId
						,intTestId
						,intPropertyId
						,intProductPropertyFormulaPropertyRefId
						,intCreatedUserId
						,dtmCreated
						,intLastModifiedUserId
						,dtmLastModified
						)
					SELECT @ProductPropertyId
						,1
						,@intFormulaTestId
						,@intFormulaPropertyId
						,@intProductPropertyFormulaPropertyId
						,@intLastModifiedUserId
						,dtmCreated
						,@intLastModifiedUserId
						,dtmLastModified
					FROM OPENXML(@idoc, 'vyuIPGetProductPropertyFormulaPropertys/vyuIPGetProductPropertyFormulaProperty', 2) WITH (
							dtmCreated DATETIME
							,dtmLastModified DATETIME
							,intProductPropertyFormulaPropertyId INT
							) x
					WHERE x.intProductPropertyFormulaPropertyId = @intProductPropertyFormulaPropertyId
				END
				ELSE
				BEGIN
					UPDATE tblQMProductPropertyFormulaProperty
					SET intConcurrencyId = intConcurrencyId + 1
						,intTestId = @intFormulaTestId
						,intPropertyId = @intFormulaPropertyId
						,intLastModifiedUserId = @intLastModifiedUserId
						,dtmLastModified = x.dtmLastModified
					FROM OPENXML(@idoc, 'vyuIPGetProductPropertyFormulaPropertys/vyuIPGetProductPropertyFormulaProperty', 2) WITH (
							dtmLastModified DATETIME
							,intProductPropertyFormulaPropertyId INT
							) x
					JOIN tblQMProductPropertyFormulaProperty D ON D.intProductPropertyFormulaPropertyRefId = x.intProductPropertyFormulaPropertyId
						AND D.intProductPropertyId = @ProductPropertyId
					WHERE x.intProductPropertyFormulaPropertyId = @intProductPropertyFormulaPropertyId
				END

				SELECT @intProductPropertyFormulaPropertyId = MIN(intProductPropertyFormulaPropertyId)
				FROM @tblQMProductPropertyFormulaProperty
				WHERE intProductPropertyFormulaPropertyId > @intProductPropertyFormulaPropertyId
			END

			DELETE
			FROM tblQMProductPropertyFormulaProperty
			WHERE intProductPropertyId = @ProductPropertyId
				AND intProductPropertyFormulaPropertyRefId NOT IN (
					SELECT intProductPropertyFormulaPropertyId
					FROM @tblQMProductPropertyFormulaProperty
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
		FROM @tblQMProductStage
		WHERE intProductStageId > @intProductStageId
			--AND ISNULL(strFeedStatus, '') = ''
	END

	UPDATE t
	SET t.strFeedStatus = NULL
	FROM tblQMProductStage t
	JOIN @tblQMProductStage pt ON pt.intProductStageId = t.intProductStageId
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
