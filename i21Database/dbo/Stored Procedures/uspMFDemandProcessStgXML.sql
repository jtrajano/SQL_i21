CREATE PROCEDURE [dbo].[uspMFDemandProcessStgXML]
	--@intToCompanyId INT
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
		,@intInvPlngReportMasterID INT
		,@strReportMasterXML NVARCHAR(MAX)
		,@strReportMaterialXML NVARCHAR(MAX)
		,@strReportAttributeValueXML NVARCHAR(MAX)
		,@strRowState NVARCHAR(50)
		,@intInvPlngReportMasterRefID INT
		,@intTransactionCount INT
		,@strInvPlngReportName NVARCHAR(50)
		,@strReportName NVARCHAR(50)
		,@intNoOfMonths INT
		,@ysnIncludeInventory BIT
		,@strCategoryCode NVARCHAR(50)
		,@strLocationName NVARCHAR(50)
		,@strUnitMeasure NVARCHAR(50)
		,@strDemandName VARCHAR(50)
		,@dtmDate DATETIME
		,@strBook NVARCHAR(50)
		,@strSubBook NVARCHAR(50)
		,@ysnTest BIT
		,@strPlanNo NVARCHAR(50)
		,@ysnAllItem BIT
		,@strComment NVARCHAR(50)
		,@ysnPost BIT
		,@dtmCreated DATETIME
		,@dtmLastModified DATETIME
		,@strCreatedBy NVARCHAR(50)
		,@strModifiedBy NVARCHAR(50)
		,@strErrorMessage NVARCHAR(MAX)
		,@intCategoryId INT
		,@intUnitMeasureId INT
		,@intUserId INT
		,@intBookId INT
		,@intSubBookId INT
		,@idoc INT
		,@intDemandStageId INT
		,@intLocationId INT
		,@intReportMasterID INT
		,@strItemList NVARCHAR(MAX)
		,@intTransactionId INT
		,@intCompanyId INT
		,@intLoadScreenId INT
		,@intTransactionRefId INT
		,@intCompanyRefId INT
		,@strDescription NVARCHAR(50)
		,@intItemScreenId INT
		,@intDemandScreenId INT
		,@intNewInvPlngReportMasterID INT
		,@strItemSupplyTargetXML NVARCHAR(MAX)
		,@dtmPostDate DATETIME

	SELECT @intDemandStageId = MIN(intDemandStageId)
	FROM tblMFDemandStage
	WHERE strFeedStatus is null

	WHILE @intDemandStageId > 0
	BEGIN
		SELECT @intInvPlngReportMasterID = NULL
			,@strReportMasterXML = NULL
			,@strReportMaterialXML = NULL
			,@strReportAttributeValueXML = NULL
			,@strRowState = NULL
			,@intTransactionId = NULL
			,@intCompanyId = NULL
			,@strItemSupplyTargetXML = NULL
			,@strErrorMessage = ''
			,@dtmPostDate = NULL

		SELECT @intInvPlngReportMasterID = intInvPlngReportMasterID
			,@strReportMasterXML = strReportMasterXML
			,@strReportMaterialXML = strReportMaterialXML
			,@strReportAttributeValueXML = strReportAttributeValueXML
			,@strRowState = strRowState
			,@intTransactionId = intTransactionId
			,@intCompanyId = intCompanyId
			,@strItemSupplyTargetXML = strItemSupplyTarget
		FROM tblMFDemandStage
		WHERE intDemandStageId = @intDemandStageId

		BEGIN TRY
			SELECT @intTransactionCount = @@TRANCOUNT

			IF @intTransactionCount = 0
				BEGIN TRANSACTION

			------------------Header------------------------------------------------------
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strReportMasterXML

			SELECT @intInvPlngReportMasterID = intInvPlngReportMasterID
				,@strInvPlngReportName = strInvPlngReportName
				,@strReportName = strReportName
				,@intNoOfMonths = intNoOfMonths
				,@ysnIncludeInventory = ysnIncludeInventory
				,@strCategoryCode = strCategoryCode
				,@strLocationName = strLocationName
				,@strUnitMeasure = strUnitMeasure
				,@strDemandName = strDemandName
				,@dtmDate = dtmDate
				,@strBook = strBook
				,@strSubBook = strSubBook
				,@ysnTest = ysnTest
				,@strPlanNo = strPlanNo
				,@ysnAllItem = ysnAllItem
				,@strComment = strComment
				,@ysnPost = ysnPost
				,@dtmCreated = dtmCreated
				,@dtmLastModified = dtmLastModified
				,@strCreatedBy = strCreatedBy
				,@strModifiedBy = strModifiedBy
				,@dtmPostDate = dtmPostDate
			FROM OPENXML(@idoc, 'vyuMFInvPlngReportMasters/vyuMFInvPlngReportMaster', 2) WITH (
					intInvPlngReportMasterID INT
					,strInvPlngReportName NVARCHAR(50) Collate Latin1_General_CI_AS
					,strReportName NVARCHAR(50) Collate Latin1_General_CI_AS
					,intNoOfMonths INT
					,ysnIncludeInventory BIT
					,strCategoryCode NVARCHAR(50) Collate Latin1_General_CI_AS
					,strLocationName NVARCHAR(50) Collate Latin1_General_CI_AS
					,strUnitMeasure NVARCHAR(50) Collate Latin1_General_CI_AS
					,strDemandName VARCHAR(50) Collate Latin1_General_CI_AS
					,dtmDate DATETIME
					,strBook NVARCHAR(50) Collate Latin1_General_CI_AS
					,strSubBook NVARCHAR(50) Collate Latin1_General_CI_AS
					,ysnTest BIT
					,strPlanNo NVARCHAR(50) Collate Latin1_General_CI_AS
					,ysnAllItem BIT
					,strComment NVARCHAR(50) Collate Latin1_General_CI_AS
					,ysnPost BIT
					,dtmCreated DATETIME
					,dtmLastModified DATETIME
					,strCreatedBy NVARCHAR(50) Collate Latin1_General_CI_AS
					,strModifiedBy NVARCHAR(50) Collate Latin1_General_CI_AS
					,dtmPostDate DATETIME
					) x

			IF @strReportName IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblCTReportMaster
					WHERE strReportName = @strReportName
					)
			BEGIN
				IF @strErrorMessage <> ''
				BEGIN
					SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'ReportName ' + @strReportName + ' is not available.'
				END
				ELSE
				BEGIN
					SELECT @strErrorMessage = 'ReportName ' + @strReportName + ' is not available.'
				END
			END

			IF @strCategoryCode IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblICCategory C
					WHERE C.strCategoryCode = @strCategoryCode
					)
			BEGIN
				IF @strErrorMessage <> ''
				BEGIN
					SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'CategoryCode ' + @strCategoryCode + ' is not available.'
				END
				ELSE
				BEGIN
					SELECT @strErrorMessage = 'CategoryCode ' + @strCategoryCode + ' is not available.'
				END
			END

			IF @strUnitMeasure IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblICUnitMeasure U2
					WHERE U2.strUnitMeasure = @strUnitMeasure
					)
			BEGIN
				IF @strErrorMessage <> ''
				BEGIN
					SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Unit Measure ' + @strUnitMeasure + ' is not available.'
				END
				ELSE
				BEGIN
					SELECT @strErrorMessage = 'Unit Measure ' + @strUnitMeasure + ' is not available.'
				END
			END

			IF @strLocationName IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblSMCompanyLocation CL
					WHERE CL.strLocationName = @strLocationName
					)
			BEGIN
				IF @strErrorMessage <> ''
				BEGIN
					SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Location Name ' + @strLocationName + ' is not available.'
				END
				ELSE
				BEGIN
					SELECT @strErrorMessage = 'Location Name ' + @strLocationName + ' is not available.'
				END
			END

			IF @strBook IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblCTBook B
					WHERE B.strBook = @strBook
					)
			BEGIN
				IF @strErrorMessage <> ''
				BEGIN
					SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Book ' + @strBook + ' is not available.'
				END
				ELSE
				BEGIN
					SELECT @strErrorMessage = 'Book ' + @strBook + ' is not available.'
				END
			END

			IF @strSubBook IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblCTSubBook SB
					WHERE SB.strSubBook = @strSubBook
					)
			BEGIN
				IF @strErrorMessage <> ''
				BEGIN
					SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Sub Book ' + @strSubBook + ' is not available.'
				END
				ELSE
				BEGIN
					SELECT @strErrorMessage = 'Sub Book ' + @strSubBook + ' is not available.'
				END
			END

			SELECT @intCategoryId = NULL

			SELECT @intUnitMeasureId = NULL

			SELECT @intBookId = NULL

			SELECT @intSubBookId = NULL

			SELECT @intCategoryId = intCategoryId
			FROM tblICCategory
			WHERE strCategoryCode = @strCategoryCode

			SELECT @intUnitMeasureId = intUnitMeasureId
			FROM tblICUnitMeasure U2
			WHERE U2.strUnitMeasure = @strUnitMeasure

			SELECT @intBookId = intBookId
			FROM tblCTBook
			WHERE strBook = @strBook

			SELECT @intSubBookId = intSubBookId
			FROM tblCTSubBook SB
			WHERE strSubBook = @strSubBook
				AND intBookId = @intBookId

			IF EXISTS (
					SELECT *
					FROM tblCTInvPlngReportMaster RM
					JOIN tblMFInvPlngSummaryBatch SB ON SB.intInvPlngReportMasterID = RM.intInvPlngReportMasterID
					WHERE RM.intInvPlngReportMasterRefID = @intInvPlngReportMasterID
						AND RM.intBookId = @intBookId
						AND IsNULL(RM.intSubBookId, 0) = IsNULL(@intSubBookId, 0)
					)
			BEGIN
				IF @strErrorMessage <> ''
				BEGIN
					SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Demand summary exists.'
				END
				ELSE
				BEGIN
					SELECT @strErrorMessage = 'Demand summary exists.'
				END
			END

			IF @strErrorMessage <> ''
			BEGIN
				RAISERROR (
						@strErrorMessage
						,16
						,1
						)
			END

			IF @strRowState = 'Delete'
			BEGIN
				DELETE
				FROM tblCTInvPlngReportMaster
				WHERE intInvPlngReportMasterRefID = @intInvPlngReportMasterID
					AND intBookId = @intBookId
					AND IsNULL(intSubBookId, 0) = IsNULL(@intSubBookId, 0)

				GOTO ext
			END

			SELECT @intReportMasterID = NULL

			SELECT @intReportMasterID = intReportMasterID
			FROM tblCTReportMaster
			WHERE strReportName = @strReportName

			SELECT @intLocationId = NULL

			SELECT @intLocationId = intCompanyLocationId
			FROM tblSMCompanyLocation
			WHERE strLocationName = @strLocationName

			SELECT @intUserId = CE.intEntityId
			FROM tblEMEntity CE
			JOIN tblEMEntityType ET1 ON ET1.intEntityId = CE.intEntityId
			WHERE ET1.strType = 'User'
				AND CE.strName = @strCreatedBy
				AND CE.strEntityNo <> ''

			IF @intUserId IS NULL
			BEGIN
				IF EXISTS (
						SELECT 1
						FROM tblSMUserSecurity
						WHERE strUserName = 'irelyadmin'
						)
					SELECT TOP 1 @intUserId = intEntityId
					FROM tblSMUserSecurity
					WHERE strUserName = 'irelyadmin'
				ELSE
					SELECT TOP 1 @intUserId = intEntityId
					FROM tblSMUserSecurity
			END

			IF EXISTS (
					SELECT *
					FROM tblCTInvPlngReportMaster
					WHERE intInvPlngReportMasterRefID = @intInvPlngReportMasterID
						AND intBookId = @intBookId
						AND IsNULL(intSubBookId, 0) = IsNULL(@intSubBookId, 0)
					)
			BEGIN
				DELETE
				FROM tblCTInvPlngReportMaster
				WHERE intInvPlngReportMasterRefID = @intInvPlngReportMasterID
					AND intBookId = @intBookId
					AND IsNULL(intSubBookId, 0) = IsNULL(@intSubBookId, 0)
			END

			INSERT INTO tblCTInvPlngReportMaster (
				intConcurrencyId
				,strInvPlngReportName
				,intReportMasterID
				,intNoOfMonths
				,ysnIncludeInventory
				,intCategoryId
				,intCompanyLocationId
				,intUnitMeasureId
				,intDemandHeaderId
				,dtmDate
				,intBookId
				,intSubBookId
				,ysnTest
				,strPlanNo
				,ysnAllItem
				,strComment
				,ysnPost
				,intCreatedUserId
				,dtmCreated
				,intLastModifiedUserId
				,dtmLastModified
				,intInvPlngReportMasterRefID
				,dtmPostDate
				)
			SELECT 1 intConcurrencyId
				,@strInvPlngReportName
				,@intReportMasterID
				,@intNoOfMonths
				,@ysnIncludeInventory
				,@intCategoryId
				,@intLocationId
				,@intUnitMeasureId
				,NULL AS intDemandHeaderId
				,@dtmDate
				,@intBookId
				,@intSubBookId
				,@ysnTest
				,@strPlanNo
				,@ysnAllItem
				,@strComment
				,@ysnPost
				,@intUserId
				,@dtmCreated
				,@intUserId
				,@dtmLastModified
				,@intInvPlngReportMasterID
				,@dtmPostDate

			SELECT @intNewInvPlngReportMasterID = SCOPE_IDENTITY()

			EXEC sp_xml_removedocument @idoc

			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strReportMaterialXML

			IF EXISTS (
					SELECT *
					FROM OPENXML(@idoc, 'vyuMFInvPlngReportMaterials/vyuMFInvPlngReportMaterial', 2) WITH (
							intInvPlngReportMasterID INT
							,strItemNo NVARCHAR(50) Collate Latin1_General_CI_AS
							) x
					LEFT JOIN tblICItem I ON I.strItemNo = x.strItemNo
					WHERE I.intItemId IS NULL
					)
			BEGIN
				SELECT @strItemList = ''

				SELECT @strItemList = @strItemList + x.strItemNo + ', '
				FROM OPENXML(@idoc, 'vyuMFInvPlngReportMaterials/vyuMFInvPlngReportMaterial', 2) WITH (
						intInvPlngReportMasterID INT
						,strItemNo NVARCHAR(50) Collate Latin1_General_CI_AS
						) x
				LEFT JOIN tblICItem I ON I.strItemNo = x.strItemNo
				WHERE I.intItemId IS NULL

				IF len(@strItemList) > 0
				BEGIN
					SELECT @strItemList = Left(@strItemList, Len(@strItemList) - 2)
				END

				SELECT @strErrorMessage = 'Item(s) ' + @strItemList + ' are not available.'

				RAISERROR (
						@strErrorMessage
						,16
						,1
						)
			END

			INSERT INTO tblCTInvPlngReportMaterial (
				intInvPlngReportMasterID
				,intItemId
				)
			SELECT @intNewInvPlngReportMasterID
				,I.intItemId
			FROM OPENXML(@idoc, 'vyuMFInvPlngReportMaterials/vyuMFInvPlngReportMaterial', 2) WITH (
					intInvPlngReportMasterID INT
					,strItemNo NVARCHAR(50) Collate Latin1_General_CI_AS
					) x
			JOIN tblICItem I ON I.strItemNo = x.strItemNo

			EXEC sp_xml_removedocument @idoc

			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strReportAttributeValueXML

			SELECT @strErrorMessage = ''

			IF EXISTS (
					SELECT *
					FROM OPENXML(@idoc, 'vyuMFInvPlngReportAttributeValues/vyuMFInvPlngReportAttributeValue', 2) WITH (
							intInvPlngReportMasterID INT
							,strItemNo NVARCHAR(50) Collate Latin1_General_CI_AS
							) x
					LEFT JOIN tblICItem I ON I.strItemNo = x.strItemNo
					WHERE I.intItemId IS NULL
					)
			BEGIN
				SELECT @strItemList = ''

				SELECT @strItemList = @strItemList + x.strItemNo + ', '
				FROM OPENXML(@idoc, 'vyuMFInvPlngReportAttributeValues/vyuMFInvPlngReportAttributeValue', 2) WITH (
						intInvPlngReportMasterID INT
						,strItemNo NVARCHAR(50) Collate Latin1_General_CI_AS
						) x
				LEFT JOIN tblICItem I ON I.strItemNo = x.strItemNo
				WHERE I.intItemId IS NULL

				IF len(@strItemList) > 0
				BEGIN
					SELECT @strItemList = Left(@strItemList, Len(@strItemList) - 2)
				END

				IF @strErrorMessage <> ''
				BEGIN
					SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Item(s) ' + @strItemList + ' are not available.'
				END
				ELSE
				BEGIN
					SELECT @strErrorMessage = 'Item(s) ' + @strItemList + ' are not available.'
				END
			END

			IF EXISTS (
					SELECT *
					FROM OPENXML(@idoc, 'vyuMFInvPlngReportAttributeValues/vyuMFInvPlngReportAttributeValue', 2) WITH (
							intInvPlngReportMasterID INT
							,strMainItemNo NVARCHAR(50) Collate Latin1_General_CI_AS
							) x
					LEFT JOIN tblICItem I ON I.strItemNo = x.strMainItemNo
					WHERE I.intItemId IS NULL
						AND x.strMainItemNo IS NOT NULL
					)
			BEGIN
				SELECT @strItemList = ''

				SELECT @strItemList = @strItemList + x.strMainItemNo + ', '
				FROM OPENXML(@idoc, 'vyuMFInvPlngReportAttributeValues/vyuMFInvPlngReportAttributeValue', 2) WITH (
						intInvPlngReportMasterID INT
						,strMainItemNo NVARCHAR(50) Collate Latin1_General_CI_AS
						) x
				LEFT JOIN tblICItem I ON I.strItemNo = x.strMainItemNo
				WHERE I.intItemId IS NULL
					AND x.strMainItemNo IS NOT NULL

				IF len(@strItemList) > 0
				BEGIN
					SELECT @strItemList = Left(@strItemList, Len(@strItemList) - 2)
				END

				IF @strErrorMessage <> ''
				BEGIN
					SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Bundle Item(s) ' + @strItemList + ' are not available.'
				END
				ELSE
				BEGIN
					SELECT @strErrorMessage = 'Bundle Item(s) ' + @strItemList + ' are not available.'
				END
			END

			INSERT INTO tblCTInvPlngReportAttributeValue (
				intInvPlngReportMasterID
				,intReportAttributeID
				,intItemId
				,strFieldName
				,strValue
				,intMainItemId
				,dtmCreated
				,dtmLastModified
				,intCreatedUserId
				,intLastModifiedUserId
				)
			SELECT @intNewInvPlngReportMasterID
				,intReportAttributeID
				,I.intItemId
				,strFieldName
				,strValue
				,MI.intItemId
				,dtmCreated
				,dtmLastModified
				,US.intEntityId
				,US1.intEntityId
			FROM OPENXML(@idoc, 'vyuMFInvPlngReportAttributeValues/vyuMFInvPlngReportAttributeValue', 2) WITH (
					intReportAttributeID INT
					,strItemNo NVARCHAR(50) Collate Latin1_General_CI_AS
					,strFieldName NVARCHAR(50) Collate Latin1_General_CI_AS
					,strValue NVARCHAR(50) Collate Latin1_General_CI_AS
					,strMainItemNo NVARCHAR(50) Collate Latin1_General_CI_AS
					,dtmCreated DATETIME
					,dtmLastModified DATETIME
					,strCreatedBy NVARCHAR(50) Collate Latin1_General_CI_AS
					,strModifiedBy NVARCHAR(50) Collate Latin1_General_CI_AS
					) x
			JOIN tblICItem I ON I.strItemNo = x.strItemNo
			LEFT JOIN tblICItem MI ON MI.strItemNo = x.strMainItemNo
			LEFT JOIN tblSMUserSecurity US ON US.strUserName = x.strCreatedBy
			LEFT JOIN tblSMUserSecurity US1 ON US1.strUserName = x.strModifiedBy

			EXEC sp_xml_removedocument @idoc

			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strItemSupplyTargetXML

			SELECT @strBook = strBook
				,@strSubBook = strSubBook
			FROM OPENXML(@idoc, 'vyuMFGetItemSupplyTargets', 2) WITH (
					strBook NVARCHAR(50) Collate Latin1_General_CI_AS
					,strSubBook NVARCHAR(50) Collate Latin1_General_CI_AS
					) x

			--Declare @intBookId int
			SELECT @intBookId = intBookId
			FROM tblCTBook
			WHERE strBook = @strBook

			SELECT @intSubBookId = intSubBookId
			FROM tblCTSubBook
			WHERE strSubBook = @strSubBook
				AND intBookId = @intBookId

			IF @intSubBookId IS NULL
				SELECT @intSubBookId = 0

			DELETE
			FROM tblIPItemSupplyTarget
			WHERE intBookId = @intBookId
				AND IsNULL(intSubBookId, @intSubBookId) = @intSubBookId

			INSERT INTO tblIPItemSupplyTarget (
				intItemId
				,dblSupplyTarget
				,intBookId
				,intSubBookId
				,intCompanyId
				)
			SELECT I.intItemId
				,x.dblSupplyTarget
				,@intBookId
				,@intSubBookId
				,NULL AS intCompanyId
			FROM OPENXML(@idoc, 'vyuMFGetItemSupplyTargets/vyuMFGetItemSupplyTarget', 2) WITH (
					strItemNo NVARCHAR(50) Collate Latin1_General_CI_AS
					,strCompanyName NVARCHAR(50) Collate Latin1_General_CI_AS
					,dblSupplyTarget NUMERIC(18, 6)
					) x
			JOIN tblICItem I ON I.strItemNo = x.strItemNo

			ext:

			EXEC sp_xml_removedocument @idoc

			UPDATE tblMFDemandStage
			SET strFeedStatus = 'Processed'
			WHERE intDemandStageId = @intDemandStageId

			SELECT @intDemandScreenId = intScreenId
			FROM tblSMScreen
			WHERE strNamespace = 'Manufacturing.view.DemandAnalysisView'

			SELECT @intTransactionRefId = intTransactionId
			FROM tblSMTransaction
			WHERE intRecordId = @intInvPlngReportMasterID
				AND intScreenId = @intDemandScreenId

			EXECUTE dbo.uspSMInterCompanyUpdateMapping @currentTransactionId = @intTransactionRefId
				,@referenceTransactionId = @intTransactionId
				,@referenceCompanyId = @intCompanyId

			INSERT INTO tblMFDemandAcknowledgementStage (
				intInvPlngReportMasterId
				,strInvPlngReportName
				,intInvPlngReportMasterRefId
				,strMessage
				,intTransactionId
				,intCompanyId
				,intTransactionRefId
				,intCompanyRefId
				)
			SELECT @intNewInvPlngReportMasterID
				,@strInvPlngReportName
				,@intInvPlngReportMasterID
				,'Success'
				,@intTransactionId
				,@intCompanyId
				,@intTransactionRefId
				,@intCompanyRefId

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

			UPDATE tblMFDemandStage
			SET strFeedStatus = 'Failed'
				,strMessage = @ErrMsg
			WHERE intDemandStageId = @intDemandStageId
		END CATCH

		SELECT @intDemandStageId = MIN(intDemandStageId)
		FROM tblMFDemandStage
		WHERE intDemandStageId > @intDemandStageId
			AND strFeedStatus is null
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
