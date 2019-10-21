CREATE PROCEDURE uspMFRecipeLossesImportValidate @intLoggedOnLocationId INT = NULL
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intRecipeLossesImportId INT
		,@strRecipeName NVARCHAR(250)
		,@strItemNo NVARCHAR(50)
		,@strComponent NVARCHAR(50)
		,@dblLoss1 NUMERIC(18, 6)
		,@dblLoss2 NUMERIC(18, 6)
		,@intCreatedUserId INT
		,@dtmCreated DATETIME
	DECLARE @strPreviousErrMsg NVARCHAR(MAX) = ''
		,@intRecipeId INT
		,@intItemId INT
		,@intBundleItemId INT

	BEGIN TRANSACTION

	DELETE
	FROM tblMFRecipeLossesImportError

	SELECT @intRecipeLossesImportId = MIN(intRecipeLossesImportId)
	FROM tblMFRecipeLossesImport

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
			,@strPreviousErrMsg = ''

		SELECT @strRecipeName = strRecipeName
			,@strItemNo = strItemNo
			,@strComponent = strComponent
			,@dblLoss1 = dblLoss1
			,@dblLoss2 = dblLoss2
			,@intCreatedUserId = intCreatedUserId
			,@dtmCreated = dtmCreated
		FROM tblMFRecipeLossesImport
		WHERE intRecipeLossesImportId = @intRecipeLossesImportId

		-- Recipe Name
		IF ISNULL(@strRecipeName, '') = ''
			SELECT @strPreviousErrMsg += 'Invalid Recipe. '
		ELSE
		BEGIN
			IF NOT EXISTS (
					SELECT 1
					FROM tblMFRecipe
					WHERE strName = @strRecipeName
					)
				SELECT @strPreviousErrMsg += 'Invalid Recipe. '
			ELSE
			BEGIN
				SELECT TOP 1 @intRecipeId = intRecipeId
				FROM tblMFRecipe
				WHERE strName = @strRecipeName
				ORDER BY intRecipeId DESC
			END
		END

		-- Bundle Item
		IF ISNULL(@strItemNo, '') <> ''
		BEGIN
			IF NOT EXISTS (
					SELECT 1
					FROM tblICItem
					WHERE strItemNo = @strItemNo
						AND strType = 'Bundle'
					)
				SELECT @strPreviousErrMsg += 'Invalid Bundle Item No. '
			ELSE
			BEGIN
				SELECT @intItemId = intItemId
				FROM tblICItem
				WHERE strItemNo = @strItemNo
					AND strType = 'Bundle'

				IF ISNULL(@intRecipeId, 0) > 0
				BEGIN
					IF NOT EXISTS (
							SELECT 1
							FROM tblMFRecipeItem RI
							JOIN tblICItem I ON I.intItemId = RI.intItemId
								AND I.intItemId = @intItemId
								AND RI.intRecipeItemTypeId = 1
								AND I.strType = 'Bundle'
							)
						SELECT @strPreviousErrMsg += 'Bundle Item is not available in the Recipe. '
				END
			END
		END

		-- Bundle Item's Item / Recipe Input Item
		IF ISNULL(@strComponent, '') <> ''
		BEGIN
			IF NOT EXISTS (
					SELECT 1
					FROM tblICItem
					WHERE strItemNo = @strComponent
					)
				SELECT @strPreviousErrMsg += 'Invalid Item No. '
			ELSE
			BEGIN
				SELECT @intBundleItemId = intItemId
				FROM tblICItem
				WHERE strItemNo = @strComponent

				IF ISNULL(@intRecipeId, 0) > 0
				BEGIN
					IF ISNULL(@intItemId, 0) > 0
					BEGIN
						IF NOT EXISTS (
								SELECT 1
								FROM tblICItemBundle IB
								WHERE IB.intItemId = @intItemId
									AND IB.intBundleItemId = @intBundleItemId
								)
							SELECT @strPreviousErrMsg += 'Item is not configured in the Bundle Item. '
					END
					ELSE IF NOT EXISTS (
							SELECT 1
							FROM tblMFRecipeItem RI
							JOIN tblICItem I ON I.intItemId = RI.intItemId
								AND I.intItemId = @intBundleItemId
								AND RI.intRecipeItemTypeId = 1
								AND I.strType <> 'Bundle'
							)
						SELECT @strPreviousErrMsg += 'Item is not available in the Recipe. '
				END
			END
		END

		-- Loss 1
		IF ISNULL(@dblLoss1, 0) > 0
		BEGIN
			IF ISNUMERIC(@dblLoss1) = 0
				SELECT @strPreviousErrMsg += 'Invalid Loss 1. '
			ELSE
			BEGIN
				IF @dblLoss1 < 0
					SELECT @strPreviousErrMsg += 'Loss 1 cannot be negative. '
			END
		END

		-- Loss 2
		IF ISNULL(@dblLoss2, 0) > 0
		BEGIN
			IF ISNUMERIC(@dblLoss2) = 0
				SELECT @strPreviousErrMsg += 'Invalid Loss 2. '
			ELSE
			BEGIN
				IF @dblLoss2 < 0
					SELECT @strPreviousErrMsg += 'Loss 2 cannot be negative. '
			END
		END

		-- After all validation, insert / update the error
		IF ISNULL(@strPreviousErrMsg, '') <> ''
		BEGIN
			IF NOT EXISTS (
					SELECT 1
					FROM tblMFRecipeLossesImportError
					WHERE intRecipeLossesImportId = @intRecipeLossesImportId
					)
			BEGIN
				INSERT INTO tblMFRecipeLossesImportError (
					intRecipeLossesImportId
					,intConcurrencyId
					,strRecipeName
					,strItemNo
					,strComponent
					,dblLoss1
					,dblLoss2
					,strErrorMsg
					,intCreatedUserId
					,dtmCreated
					)
				SELECT intRecipeLossesImportId
					,intConcurrencyId
					,strRecipeName
					,strItemNo
					,strComponent
					,dblLoss1
					,dblLoss2
					,@strPreviousErrMsg
					,intCreatedUserId
					,dtmCreated
				FROM tblMFRecipeLossesImport
				WHERE intRecipeLossesImportId = @intRecipeLossesImportId
			END
			ELSE
			BEGIN
				UPDATE tblMFRecipeLossesImportError
				SET strErrorMsg = strErrorMsg + @strPreviousErrMsg
				WHERE intRecipeLossesImportId = @intRecipeLossesImportId
			END
		END

		SELECT @intRecipeLossesImportId = MIN(intRecipeLossesImportId)
		FROM tblMFRecipeLossesImport
		WHERE intRecipeLossesImportId > @intRecipeLossesImportId
	END

	SELECT intRecipeLossesImportErrorId
		,intRecipeLossesImportId
		,intConcurrencyId
		,strRecipeName
		,strItemNo
		,strComponent
		,dblLoss1
		,dblLoss2
		,strErrorMsg
		,intCreatedUserId
		,dtmCreated
	FROM tblMFRecipeLossesImportError

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
