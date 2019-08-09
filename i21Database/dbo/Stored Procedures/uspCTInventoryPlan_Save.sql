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

	IF @intInvPlngReportMasterID = 0
	BEGIN
		IF EXISTS (
				SELECT 1
				FROM [tblCTInvPlngReportMaster]
				WHERE [strInvPlngReportName] = @strInvPlngReportName
				)
		BEGIN
			SET @ErrMsg = 'Plan name must be unique.'

			RAISERROR (
					@ErrMsg
					,16
					,1
					)
		END

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
			[strInvPlngReportName]
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
			)
		SELECT [strInvPlngReportName]
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

		INSERT INTO [dbo].[tblCTInvPlngReportAttributeValue]
		SELECT @intInvPlngReportMasterID
			,[intReportAttributeID]
			,[intItemId]
			,[strFieldName]
			,[strValue]
			,[intCreatedUserId]
			,GETDATE()
			,[intLastModifiedUserId]
			,GETDATE()
		FROM OPENXML(@idoc, 'root/InvPlngReportAttributeValue/InvPlngReportAttributeValueRow', 2) WITH (
				intReportAttributeID INT
				,intItemId INT
				,strFieldName NVARCHAR(50)
				,strValue NVARCHAR(100)
				,intCreatedUserId INT
				,intLastModifiedUserId INT
				)
	END
	ELSE
	BEGIN
		IF EXISTS (
				SELECT 1
				FROM [tblCTInvPlngReportMaster]
				WHERE [strInvPlngReportName] = @strInvPlngReportName
					AND [strInvPlngReportName] <> @strInvPlngReportName
				)
		BEGIN
			SET @ErrMsg = 'Plan name must be unique.'

			RAISERROR (
					@ErrMsg
					,16
					,1
					)
		END

		UPDATE tblCTInvPlngReportMaster
		SET [strInvPlngReportName] = x.strInvPlngReportName
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
			,[intLastModifiedUserId] = x.intLastModifiedUserId
			,[dtmLastModified] = GETDATE()
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

		DELETE
		FROM dbo.tblCTInvPlngReportAttributeValue
		WHERE intInvPlngReportMasterID = @intInvPlngReportMasterID

		INSERT INTO [dbo].[tblCTInvPlngReportAttributeValue]
		SELECT @intInvPlngReportMasterID
			,[intReportAttributeID]
			,[intItemId]
			,[strFieldName]
			,[strValue]
			,[intCreatedUserId]
			,GETDATE()
			,[intLastModifiedUserId]
			,GETDATE()
		FROM OPENXML(@idoc, 'root/InvPlngReportAttributeValue/InvPlngReportAttributeValueRow', 2) WITH (
				intReportAttributeID INT
				,intItemId INT
				,strFieldName NVARCHAR(50)
				,strValue NVARCHAR(100)
				,intCreatedUserId INT
				,intLastModifiedUserId INT
				)
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
