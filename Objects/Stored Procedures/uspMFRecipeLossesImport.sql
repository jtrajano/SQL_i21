CREATE PROCEDURE uspMFRecipeLossesImport @intLoggedOnLocationId INT = NULL
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @ImportHeader TABLE (
		intRowNo INT IDENTITY(1, 1)
		,intRecipeLossesImportId INT
		,strRecipeName NVARCHAR(250)
		,strItemNo NVARCHAR(50)
		,strComponent NVARCHAR(50)
		,dblLoss1 NUMERIC(18, 6)
		,dblLoss2 NUMERIC(18, 6)
		,intCreatedUserId INT
		,dtmCreated DATETIME
		)
	DECLARE @intRecipeLossesImportId INT
		,@strRecipeName NVARCHAR(250)
		,@strItemNo NVARCHAR(50)
		,@strComponent NVARCHAR(50)
		,@dblLoss1 NUMERIC(18, 6)
		,@dblLoss2 NUMERIC(18, 6)
		,@intCreatedUserId INT
		,@dtmCreated DATETIME
	DECLARE @intRecipeId INT
		,@intItemId INT
		,@intBundleItemId INT
		,@intRecipeLossesId INT
	DECLARE @tblMFRecipeLosses TABLE (
		dblOldLoss1 NUMERIC(18, 6)
		,dblOldLoss2 NUMERIC(18, 6)
		,dblNewLoss1 NUMERIC(18, 6)
		,dblNewLoss2 NUMERIC(18, 6)
		)

	INSERT INTO @ImportHeader
	SELECT intRecipeLossesImportId
		,strRecipeName
		,strItemNo
		,strComponent
		,dblLoss1
		,dblLoss2
		,intCreatedUserId
		,dtmCreated
	FROM tblMFRecipeLossesImport
	ORDER BY intRecipeLossesImportId

	SELECT @intRecipeLossesImportId = MIN(intRecipeLossesImportId)
	FROM @ImportHeader

	BEGIN TRANSACTION

	WHILE (ISNULL(@intRecipeLossesImportId, 0) > 0)
	BEGIN
		SELECT @strRecipeName = NULL
			,@strItemNo = NULL
			,@strComponent = NULL
			,@dblLoss1 = NULL
			,@dblLoss2 = NULL
			,@intCreatedUserId = NULL
			,@dtmCreated = NULL
			,@intRecipeId = NULL
			,@intItemId = NULL
			,@intBundleItemId = NULL
			,@intRecipeLossesId = NULL

		SELECT @strRecipeName = strRecipeName
			,@strItemNo = strItemNo
			,@strComponent = strComponent
			,@dblLoss1 = dblLoss1
			,@dblLoss2 = dblLoss2
			,@intCreatedUserId = intCreatedUserId
			,@dtmCreated = dtmCreated
		FROM @ImportHeader
		WHERE intRecipeLossesImportId = @intRecipeLossesImportId

		SELECT TOP 1 @intRecipeId = intRecipeId
		FROM tblMFRecipe
		WHERE strName = @strRecipeName
		ORDER BY intRecipeId DESC

		IF ISNULL(@strItemNo, '') <> ''
		BEGIN
			SELECT @intItemId = intItemId
			FROM tblICItem
			WHERE strItemNo = @strItemNo
				AND strType = 'Bundle'
		END

		IF ISNULL(@strComponent, '') <> ''
		BEGIN
			SELECT @intBundleItemId = intItemId
			FROM tblICItem
			WHERE strItemNo = @strComponent
		END

		IF EXISTS (
				SELECT 1
				FROM tblMFRecipeLosses
				WHERE intRecipeId = @intRecipeId
					AND ISNULL(intItemId, 0) = ISNULL(@intItemId, 0)
					AND ISNULL(intBundleItemId, 0) = ISNULL(@intBundleItemId, 0)
				)
		BEGIN
			SELECT @intRecipeLossesId = intRecipeLossesId
			FROM tblMFRecipeLosses
			WHERE intRecipeId = @intRecipeId
				AND ISNULL(intItemId, 0) = ISNULL(@intItemId, 0)
				AND ISNULL(intBundleItemId, 0) = ISNULL(@intBundleItemId, 0)

			DELETE
			FROM @tblMFRecipeLosses

			UPDATE t
			SET t.intConcurrencyId = (intConcurrencyId + 1)
				,t.dblLoss1 = @dblLoss1
				,t.dblLoss2 = @dblLoss2
				,t.intLastModifiedUserId = @intCreatedUserId
				,t.dtmLastModified = @dtmCreated
			OUTPUT deleted.dblLoss1
				,deleted.dblLoss2
				,inserted.dblLoss1
				,inserted.dblLoss2
			INTO @tblMFRecipeLosses
			FROM tblMFRecipeLosses t
			WHERE t.intRecipeLossesId = @intRecipeLossesId

			--Update Audit Trail Record
			DECLARE @strDetails NVARCHAR(MAX) = ''

			IF EXISTS (
					SELECT 1
					FROM @tblMFRecipeLosses
					WHERE ISNULL(dblOldLoss1, 0) <> ISNULL(dblNewLoss1, 0)
					)
				SELECT @strDetails += '{"change":"dblLoss1","iconCls":"small-gear","from":"' + LTRIM(ISNULL(dblOldLoss1, 0)) + '","to":"' + LTRIM(ISNULL(dblNewLoss1, 0)) + '","leaf":true,"changeDescription":"Loss 1(%)"},'
				FROM @tblMFRecipeLosses

			IF EXISTS (
					SELECT 1
					FROM @tblMFRecipeLosses
					WHERE ISNULL(dblOldLoss2, 0) <> ISNULL(dblNewLoss2, 0)
					)
				SELECT @strDetails += '{"change":"dblLoss2","iconCls":"small-gear","from":"' + LTRIM(ISNULL(dblOldLoss2, 0)) + '","to":"' + LTRIM(ISNULL(dblNewLoss2, 0)) + '","leaf":true,"changeDescription":"Loss 2(%)"},'
				FROM @tblMFRecipeLosses

			IF (LEN(@strDetails) > 1)
			BEGIN
				SET @strDetails = SUBSTRING(@strDetails, 0, LEN(@strDetails))

				EXEC uspSMAuditLog @keyValue = @intRecipeLossesId
					,@screenName = 'Manufacturing.view.RecipeLosses'
					,@entityId = @intCreatedUserId
					,@actionType = 'Updated'
					,@actionIcon = 'small-tree-modified'
					,@details = @strDetails
			END
		END
		ELSE
		BEGIN
			INSERT INTO tblMFRecipeLosses (
				intConcurrencyId
				,intRecipeId
				,intItemId
				,intBundleItemId
				,dblLoss1
				,dblLoss2
				,intCreatedUserId
				,dtmCreated
				,intLastModifiedUserId
				,dtmLastModified
				)
			SELECT 1
				,@intRecipeId
				,@intItemId
				,@intBundleItemId
				,@dblLoss1
				,@dblLoss2
				,@intCreatedUserId
				,@dtmCreated
				,@intCreatedUserId
				,@dtmCreated

			SELECT @intRecipeLossesId = SCOPE_IDENTITY()

			--Add Audit Trail Record
			DECLARE @strJson NVARCHAR(MAX) = ''

			SET @strJson = '{"action":"Created","change":"Created - Record: ' + CONVERT(VARCHAR, @intRecipeLossesId) + '","keyValue":' + CONVERT(VARCHAR, @intRecipeLossesId) + ',"iconCls":"small-new-plus","leaf":true}'

			EXEC uspSMAuditLog @keyValue = @intRecipeLossesId
				,@screenName = 'Manufacturing.view.RecipeLosses'
				,@entityId = @intCreatedUserId
				,@actionType = 'Created'
				,@actionIcon = 'small-new-plus'
				,@details = @strJson
		END

		SELECT @intRecipeLossesImportId = MIN(intRecipeLossesImportId)
		FROM @ImportHeader
		WHERE intRecipeLossesImportId > @intRecipeLossesImportId
	END

	DELETE
	FROM tblMFRecipeLossesImport

	COMMIT TRANSACTION
END TRY

BEGIN CATCH
	IF XACT_STATE() != 0
		AND @@TRANCOUNT > 0
		ROLLBACK TRANSACTION

	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
