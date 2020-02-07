CREATE PROCEDURE dbo.uspMFProcessPreStageRecipe (
	@intRecipeId INT = NULL
	,@intRecipeItemId INT = NULL
	,@ysnDeleteFeed BIT = 0
	)
AS
BEGIN TRY
	DECLARE @intRecipePreStageId INT
		,@strRecipeRowState NVARCHAR(50)
		,@strSessionId UNIQUEIDENTIFIER
		,@strErrMsg NVARCHAR(MAX)
		,@strRecipeItemRowState NVARCHAR(50)

	IF @ysnDeleteFeed = 0
		SELECT @intRecipePreStageId = min(intRecipePreStageId)
		FROM tblMFRecipePreStage
		WHERE strFeedStatus IS NULL
	ELSE
		SELECT @intRecipePreStageId = min(intRecipePreStageId)
		FROM tblMFRecipePreStage
		WHERE strFeedStatus IS NULL
			AND intRecipeId = @intRecipeId
			and (strRecipeRowState='Delete' or strRecipeItemRowState='Delete')

	WHILE @intRecipePreStageId IS NOT NULL
	BEGIN
		SELECT @intRecipeId = NULL
			,@strRecipeRowState = NULL
			,@intRecipeItemId = NULL
			,@strSessionId = NULL
			,@strRecipeItemRowState = NULL

		SELECT @intRecipeId = intRecipeId
			,@intRecipeItemId = intRecipeItemId
			,@strRecipeRowState = strRecipeRowState
			,@strRecipeItemRowState = strRecipeItemRowState
		FROM tblMFRecipePreStage
		WHERE intRecipePreStageId = @intRecipePreStageId

		IF EXISTS (
				SELECT *
				FROM tblMFRecipeStage
				WHERE intRecipeId = @intRecipeId
					AND strRecipeRowState = @strRecipeRowState
					AND strMessage IS NULL
				)
		BEGIN
			SELECT @strSessionId = strSessionId
			FROM tblMFRecipeStage
			WHERE intRecipeId = @intRecipeId
				AND strRecipeRowState = @strRecipeRowState
				AND strMessage IS NULL
		END
		ELSE
		BEGIN
			SELECT @strSessionId = NEWID()
		END

		INSERT INTO tblMFRecipeStage (
			strRecipeName
			,strLocationName
			,strItemNo
			,strQuantity
			,strUOM
			,strVersionNo
			,strValidFrom
			,strValidTo
			,strManufacturingProcess
			,dtmCreated
			,strSessionId
			,strRecipeType
			,strTransactionType
			,intRecipeId
			,strRecipeRowState
			,ysnImport
			)
		SELECT R.strName
			,CL.strLocationName
			,I.strItemNo
			,R.dblQuantity
			,UM.strUnitMeasure
			,R.intVersionNo
			,R.dtmValidFrom
			,R.dtmValidTo
			,P.strProcessName
			,R.dtmCreated
			,@strSessionId
			,RT.strName
			,CASE 
				WHEN @strRecipeRowState = 'Added'
					THEN 'RECIPE_CREATE'
				WHEN @strRecipeRowState = 'Modified'
					THEN 'RECIPE_UPDATE'
				ELSE 'RECIPE_DELETE'
				END
			,@intRecipeId
			,@strRecipeRowState
			,0 AS ysnImport
		FROM tblMFRecipe R
		JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = R.intLocationId
		JOIN tblICItem I ON I.intItemId = R.intItemId
		JOIN tblICItemUOM IU ON IU.intItemUOMId = R.intItemUOMId
		JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
		JOIN tblMFManufacturingProcess P ON P.intManufacturingProcessId = R.intManufacturingProcessId
		JOIN tblMFRecipeType RT ON RT.intRecipeTypeId = R.intRecipeTypeId
		WHERE R.intRecipeId = @intRecipeId

		INSERT INTO tblMFRecipeItemStage (
			[strRecipeName]
			,[strLocationName]
			,[strVersionNo]
			,strRecipeItemNo
			,strQuantity
			,strUOM
			,strRecipeItemType
			,strLowerTolerance
			,strUpperTolerance
			,strValidFrom
			,strValidTo
			,strYearValidationRequired
			,strConsumptionMethod
			,strStorageLocation
			,strSessionId
			,strRowState
			,strItemGroupName
			,intRecipeItemId
			)
		SELECT R.strName
			,CL.strLocationName
			,R.intVersionNo
			,I.strItemNo
			,RI.dblQuantity
			,UM.strUnitMeasure
			,RT.strName
			,RI.dblLowerTolerance
			,RI.dblUpperTolerance
			,Convert(CHAR, RI.dtmValidFrom, 112)
			,Convert(CHAR, RI.dtmValidTo, 112)
			,RI.ysnYearValidationRequired
			,CM.strName
			,IsNULL(SL.strName, '')
			,@strSessionId
			,CASE 
				WHEN @strRecipeRowState = 'Added'
					THEN 'C'
				WHEN @strRecipeRowState = 'Delete'
					THEN 'D'
				ELSE (
						CASE 
							WHEN @strRecipeItemRowState = 'Added'
								THEN 'C'
							WHEN @strRecipeItemRowState = 'Modified'
								THEN 'U'
							ELSE 'D'
							END
						)
				END
			,RI.strItemGroupName
			,RI.intRecipeItemId
		FROM tblMFRecipe R
		JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = R.intLocationId
		JOIN tblMFRecipeItem RI ON RI.intRecipeId = R.intRecipeId
		JOIN tblICItem I ON I.intItemId = RI.intItemId
		JOIN tblICItemUOM IU ON IU.intItemUOMId = RI.intItemUOMId
		JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
		JOIN tblMFManufacturingProcess P ON P.intManufacturingProcessId = R.intManufacturingProcessId
		JOIN tblMFRecipeItemType RT ON RT.intRecipeItemTypeId = RI.intRecipeItemTypeId
		LEFT JOIN tblMFConsumptionMethod CM ON CM.intConsumptionMethodId = RI.intConsumptionMethodId
		LEFT JOIN tblICStorageLocation SL ON SL.intStorageLocationId = RI.intStorageLocationId
		WHERE R.intRecipeId = @intRecipeId
			AND RI.intRecipeItemId =IsNULL(@intRecipeItemId,RI.intRecipeItemId )

		UPDATE tblMFRecipePreStage
		SET strFeedStatus = 'Processed'
		WHERE intRecipePreStageId = @intRecipePreStageId

		IF @ysnDeleteFeed = 0
		BEGIN
			SELECT @intRecipePreStageId = min(intRecipePreStageId)
			FROM tblMFRecipePreStage
			WHERE strFeedStatus IS NULL
				AND intRecipePreStageId > @intRecipePreStageId
		END
		ELSE
		BEGIN
			SELECT @intRecipePreStageId = NULL

			BREAK
		END
	END
END TRY

BEGIN CATCH
	SET @strErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@strErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH