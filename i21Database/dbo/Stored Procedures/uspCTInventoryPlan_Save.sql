CREATE PROCEDURE [dbo].[uspCTInventoryPlan_Save] @strXML NVARCHAR(MAX)
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @idoc INT
		,@ErrMsg NVARCHAR(MAX)
	DECLARE @intReportMasterID INT
		,@strReportName NVARCHAR(50)
		,@intInvPlngReportMasterID INT
		,@strInvPlngReportName NVARCHAR(150)
		,@strPlanNo NVARCHAR(50)
		,@intConcurrencyId INT
		,@intOldConcurrencyId INT
		,@strDetails NVARCHAR(MAX)
		,@intLastModifiedUserId INT
		,@ysnAllItem BIT
	DECLARE @tblIPAuditLog TABLE (
		strColumnName NVARCHAR(50)
		,strColumnDescription NVARCHAR(50)
		,strOldValue NVARCHAR(MAX)
		,strNewValue NVARCHAR(MAX)
		)

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	SELECT @strReportName = strReportName
	FROM OPENXML(@idoc, 'root', 2) WITH (strReportName NVARCHAR(50))

	SELECT @intReportMasterID = intReportMasterID
	FROM dbo.tblCTReportMaster
	WHERE strReportName = @strReportName

	SELECT @intInvPlngReportMasterID = intInvPlngReportMasterID
	FROM OPENXML(@idoc, 'root/InvPlngReportMaster', 2) WITH (intInvPlngReportMasterID INT)

	SELECT @strInvPlngReportName = strInvPlngReportName
	FROM OPENXML(@idoc, 'root/InvPlngReportMaster', 2) WITH (strInvPlngReportName NVARCHAR(150))

	SELECT @intConcurrencyId = intConcurrencyId
		,@intLastModifiedUserId = intLastModifiedUserId
		,@ysnAllItem=ysnAllItem
	FROM OPENXML(@idoc, 'root/InvPlngReportMaster', 2) WITH (
			intConcurrencyId INT
			,intLastModifiedUserId INT
			,ysnAllItem BIT
			)
	IF IsNULL(@ysnAllItem, 0) = 0
		AND NOT EXISTS (
			SELECT *
			FROM OPENXML(@idoc, 'root/InvPlngReportMaterial/MaterialKeyList', 2) WITH (intItemId INT)
			)
	BEGIN
		SET @ErrMsg = 'Item cannot be empty.'

		RAISERROR (
				@ErrMsg
				,16
				,1
				)
	END
	
	IF @intInvPlngReportMasterID = 0
	BEGIN
		--IF EXISTS (
		--		SELECT 1
		--		FROM [tblCTInvPlngReportMaster]
		--		WHERE [strInvPlngReportName] = @strInvPlngReportName
		--		)
		--BEGIN
		--	SET @ErrMsg = 'Plan Name must be unique.'
		--	RAISERROR (
		--			@ErrMsg
		--			,16
		--			,1
		--			)
		--END
		EXEC dbo.uspMFGeneratePatternId @intCategoryId = NULL
			,@intItemId = NULL
			,@intManufacturingId = NULL
			,@intSubLocationId = NULL
			,@intLocationId = NULL
			,@intOrderTypeId = NULL
			,@intBlendRequirementId = NULL
			,@intPatternCode = 147
			,@ysnProposed = 0
			,@strPatternString = @strPlanNo OUTPUT
			,@intShiftId = NULL
			,@dtmDate = NULL

		IF ISNULL(@strPlanNo, '') = ''
		BEGIN
			SET @ErrMsg = 'Plan No cannot be empty.'

			RAISERROR (
					@ErrMsg
					,16
					,1
					)
		END

		IF EXISTS (
				SELECT 1
				FROM tblCTInvPlngReportMaster
				WHERE strPlanNo = @strPlanNo
				)
		BEGIN
			SET @ErrMsg = 'Plan No must be unique.'

			RAISERROR (
					@ErrMsg
					,16
					,1
					)
		END

		INSERT INTO [dbo].[tblCTInvPlngReportMaster] (
			intConcurrencyId
			,[strInvPlngReportName]
			,[intReportMasterID]
			,[intNoOfMonths]
			,[ysnIncludeInventory]
			,[intCategoryId]
			,[intCompanyLocationId]
			,[intUnitMeasureId]
			,intDemandHeaderId
			,dtmDate
			,intBookId
			,intSubBookId
			,ysnTest
			,strPlanNo
			,ysnAllItem
			,strComment
			,ysnPost
			,[intCreatedUserId]
			,[dtmCreated]
			,[intLastModifiedUserId]
			,[dtmLastModified]
			,strExternalGroup
			,intDayLeftInMonth
			)
		SELECT 1
			,[strInvPlngReportName]
			,@intReportMasterID
			,[intNoOfMonths]
			,[ysnIncludeInventory]
			,[intCategoryId]
			,intCompanyLocationId
			,intUnitMeasureId
			,intDemandHeaderId
			,GETDATE()
			,intBookId
			,intSubBookId
			,ysnTest
			,@strPlanNo
			,ysnAllItem
			,strComment
			,ysnPost
			,[intCreatedUserId]
			,GETDATE()
			,[intLastModifiedUserId]
			,GETDATE()
			,strExternalGroup
			,intDayLeftInMonth
		FROM OPENXML(@idoc, 'root/InvPlngReportMaster', 2) WITH (
				strInvPlngReportName NVARCHAR(150)
				,intNoOfMonths INT
				,ysnIncludeInventory BIT
				,intCategoryId INT
				,intCompanyLocationId INT
				,intUnitMeasureId INT
				,intDemandHeaderId INT
				,intBookId INT
				,intSubBookId INT
				,ysnTest BIT
				,ysnAllItem BIT
				,strComment NVARCHAR(MAX)
				,ysnPost BIT
				,intCreatedUserId INT
				,intLastModifiedUserId INT
				,strExternalGroup NVARCHAR(50)
				,intDayLeftInMonth int
				)

		SET @intInvPlngReportMasterID = SCOPE_IDENTITY()

		INSERT INTO [dbo].[tblCTInvPlngReportMaterial]
		SELECT @intInvPlngReportMasterID
			,[intItemId]
			,[intCreatedUserId]
			,GETDATE()
			,[intLastModifiedUserId]
			,GETDATE()
		FROM OPENXML(@idoc, 'root/InvPlngReportMaterial/MaterialKeyList', 2) WITH (
				intItemId INT
				,intCreatedUserId INT
				,intLastModifiedUserId INT
				)

		INSERT INTO [dbo].[tblCTInvPlngReportAttributeValue](intInvPlngReportMasterID,
				intReportAttributeID,
				intItemId,
				strFieldName,
				strValue,
				intCreatedUserId,
				dtmCreated,
				intLastModifiedUserId,
				dtmLastModified,
				intMainItemId,
				intLocationId)
		SELECT @intInvPlngReportMasterID
			,[intReportAttributeID]
			,[intItemId]
			,[strFieldName]
			,[strValue]
			,[intCreatedUserId]
			,GETDATE()
			,[intLastModifiedUserId]
			,GETDATE()
			,intMainItemId
			,intLocationId
		FROM OPENXML(@idoc, 'root/InvPlngReportAttributeValue/InvPlngReportAttributeValueRow', 2) WITH (
				intReportAttributeID INT
				,intItemId INT
				,strFieldName NVARCHAR(50)
				,strValue NVARCHAR(100)
				,intCreatedUserId INT
				,intLastModifiedUserId INT
				,intMainItemId INT
				,intLocationId INT
				)
	END
	ELSE
	BEGIN
		--IF EXISTS (
		--		SELECT 1
		--		FROM [tblCTInvPlngReportMaster]
		--		WHERE [strInvPlngReportName] = @strInvPlngReportName
		--			AND intInvPlngReportMasterID <> @intInvPlngReportMasterID
		--		)
		--BEGIN
		--	SET @ErrMsg = 'Plan Name must be unique.'
		--	RAISERROR (
		--			@ErrMsg
		--			,16
		--			,1
		--			)
		--END
		SELECT @intOldConcurrencyId = intConcurrencyId
		FROM tblCTInvPlngReportMaster
		WHERE intInvPlngReportMasterID = @intInvPlngReportMasterID

		IF @intConcurrencyId < @intOldConcurrencyId
		BEGIN
			SET @ErrMsg = 'Demand data is already modified by other user. Please refresh.'

			RAISERROR (
					@ErrMsg
					,16
					,1
					)
		END

		UPDATE tblCTInvPlngReportMaster
		SET intConcurrencyId = (intConcurrencyId + 1)
			,[strInvPlngReportName] = x.strInvPlngReportName
			,[intNoOfMonths] = x.intNoOfMonths
			,[ysnIncludeInventory] = x.ysnIncludeInventory
			,[intCategoryId] = x.intCategoryId
			,intCompanyLocationId = x.intCompanyLocationId
			,intUnitMeasureId = x.intUnitMeasureId
			,intDemandHeaderId = x.intDemandHeaderId
			,intBookId = x.intBookId
			,intSubBookId = x.intSubBookId
			,ysnTest = x.ysnTest
			,ysnAllItem = x.ysnAllItem
			,strComment = x.strComment
			,ysnPost = x.ysnPost
			,dtmPostDate = (
				CASE 
					WHEN x.ysnPost = 1
						THEN GETDATE()
					ELSE tblCTInvPlngReportMaster.dtmPostDate
					END
				)
			,[intLastModifiedUserId] = x.intLastModifiedUserId
			,[dtmLastModified] = GETDATE()
			,strExternalGroup=x.strExternalGroup
			,intDayLeftInMonth=x.intDayLeftInMonth
		FROM OPENXML(@idoc, 'root/InvPlngReportMaster', 2) WITH (
				strInvPlngReportName NVARCHAR(150)
				,intNoOfMonths INT
				,ysnIncludeInventory BIT
				,intCategoryId INT
				,intCompanyLocationId INT
				,intUnitMeasureId INT
				,intDemandHeaderId INT
				,intBookId INT
				,intSubBookId INT
				,ysnTest BIT
				,ysnAllItem BIT
				,strComment NVARCHAR(MAX)
				,ysnPost BIT
				,intLastModifiedUserId INT
				,strExternalGroup NVARCHAR(50)
				,intDayLeftInMonth int
				) x
		WHERE intInvPlngReportMasterID = @intInvPlngReportMasterID

		DELETE
		FROM dbo.tblCTInvPlngReportMaterial
		WHERE intInvPlngReportMasterID = @intInvPlngReportMasterID

		INSERT INTO [dbo].[tblCTInvPlngReportMaterial]
		SELECT @intInvPlngReportMasterID
			,[intItemId]
			,[intCreatedUserId]
			,GETDATE()
			,[intLastModifiedUserId]
			,GETDATE()
		FROM OPENXML(@idoc, 'root/InvPlngReportMaterial/MaterialKeyList', 2) WITH (
				intItemId INT
				,intCreatedUserId INT
				,intLastModifiedUserId INT
				)

		INSERT INTO @tblIPAuditLog
		SELECT (
				SELECT TOP 1 RAV.strValue
				FROM tblCTInvPlngReportAttributeValue RAV
				WHERE RAV.intInvPlngReportMasterID = @intInvPlngReportMasterID
					AND RAV.intReportAttributeID = 1
					AND RAV.strFieldName = x.strFieldName
				)
			,IsNULL(L.strLocationName, 'All')+' - '+I.strItemNo + IsNULL(' - [ ' + MI.strItemNo + ' ] ', '') + ' - ' + RA.strAttributeName
			,AV.strValue
			,x.strValue
		FROM OPENXML(@idoc, 'root/InvPlngReportAttributeValue/InvPlngReportAttributeValueRow', 2) WITH (
				intReportAttributeID INT
				,intItemId INT
				,strFieldName NVARCHAR(50) Collate Latin1_General_CI_AS
				,strValue NVARCHAR(100)Collate Latin1_General_CI_AS
				,intCreatedUserId INT
				,intLastModifiedUserId INT
				,intMainItemId INT
				,intLocationId int
				) x
		JOIN tblCTInvPlngReportAttributeValue AV ON x.intReportAttributeID = AV.intReportAttributeID
			AND x.intItemId = AV.intItemId
			AND x.strFieldName = AV.strFieldName
			AND IsNULL(x.intMainItemId,0) = IsNULL(AV.intMainItemId,0)
		JOIN tblICItem I ON I.intItemId = x.intItemId
		LEFT JOIN tblICItem MI ON MI.intItemId = x.intMainItemId
		JOIN tblCTReportAttribute RA ON RA.intReportAttributeID = x.intReportAttributeID
		LEFT JOIN dbo.tblSMCompanyLocation L ON L.intCompanyLocationId = x.intLocationId
		WHERE x.strValue <> AV.strValue
			AND AV.intInvPlngReportMasterID = @intInvPlngReportMasterID
			AND AV.intReportAttributeID IN (
				5
				,8
				,9
				,11
				,13
				)

		DELETE
		FROM dbo.tblCTInvPlngReportAttributeValue
		WHERE intInvPlngReportMasterID = @intInvPlngReportMasterID

		INSERT INTO [dbo].[tblCTInvPlngReportAttributeValue](intInvPlngReportMasterID,
				intReportAttributeID,
				intItemId,
				strFieldName,
				strValue,
				intCreatedUserId,
				dtmCreated,
				intLastModifiedUserId,
				dtmLastModified,
				intMainItemId,
				intLocationId)
		SELECT @intInvPlngReportMasterID
			,[intReportAttributeID]
			,[intItemId]
			,[strFieldName]
			,[strValue]
			,[intCreatedUserId]
			,GETDATE()
			,[intLastModifiedUserId]
			,GETDATE()
			,intMainItemId
			,intLocationId
		FROM OPENXML(@idoc, 'root/InvPlngReportAttributeValue/InvPlngReportAttributeValueRow', 2) WITH (
				intReportAttributeID INT
				,intItemId INT
				,strFieldName NVARCHAR(50)
				,strValue NVARCHAR(100)
				,intCreatedUserId INT
				,intLastModifiedUserId INT
				,intMainItemId INT
				,intLocationId INT
				)

		IF EXISTS (
				SELECT *
				FROM @tblIPAuditLog
				)
		BEGIN
			SELECT @strDetails = ''

			SELECT @strDetails += '{"change":"' + strColumnName + '","iconCls":"small-gear","from":"' + Ltrim(isNULL(strOldValue, '')) + '","to":"' + Ltrim(IsNULL(strNewValue, '')) + '","leaf":true,"changeDescription":"' + strColumnDescription + '"},'
			FROM @tblIPAuditLog
			WHERE IsNULL(strOldValue, '') <> IsNULL(strNewValue, '')
		END

		IF (LEN(@strDetails) > 1)
		BEGIN
			SET @strDetails = SUBSTRING(@strDetails, 0, LEN(@strDetails))

			EXEC uspSMAuditLog @keyValue = @intInvPlngReportMasterID
				,@screenName = 'Manufacturing.view.DemandAnalysisView'
				,@entityId = @intLastModifiedUserId
				,@actionType = 'Updated'
				,@actionIcon = 'small-tree-modified'
				,@details = @strDetails

			BEGIN TRY
			DECLARE @SingleAuditLogParam SingleAuditLogParam
			INSERT INTO @SingleAuditLogParam ([Id], [KeyValue], [Action], [Change], [From], [To], [Alias], [Field], [Hidden], [ParentId])
					SELECT 1, '', 'Updated', 'Updated - Record: ' + CAST(@intInvPlngReportMasterID AS VARCHAR(MAX)), NULL, NULL, NULL, NULL, NULL, NULL
					UNION ALL
					SELECT 2, '', '', strColumnName, Ltrim(isNULL(strOldValue, '')), Ltrim(IsNULL(strNewValue, '')), strColumnDescription, NULL, NULL, 1 from @tblIPAuditLog

			EXEC uspSMSingleAuditLog 
				@screenName     = 'Manufacturing.view.DemandAnalysisView',
				@recordId       = @intInvPlngReportMasterID,
				@entityId       = @intLastModifiedUserId,
				@AuditLogParam  = @SingleAuditLogParam
			END TRY
			BEGIN CATCH
			END CATCH
		END
	END

	IF EXISTS (
			SELECT *
			FROM tblCTInvPlngReportMaster
			WHERE intInvPlngReportMasterID = @intInvPlngReportMasterID
				AND ysnPost = 1
			)
	BEGIN
		IF NOT EXISTS (
				SELECT *
				FROM tblMFDemandPreStage
				WHERE intInvPlngReportMasterID = @intInvPlngReportMasterID
				)
		BEGIN
			INSERT INTO tblMFDemandPreStage (
				intInvPlngReportMasterID
				,strRowState
				)
			SELECT @intInvPlngReportMasterID
				,'Added'
		END
		ELSE
		BEGIN
			INSERT INTO tblMFDemandPreStage (
				intInvPlngReportMasterID
				,strRowState
				)
			SELECT @intInvPlngReportMasterID
				,'Modified'
		END
	END

	EXEC sp_xml_removedocument @idoc

	SELECT @intInvPlngReportMasterID AS intInvPlngReportMasterID
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
