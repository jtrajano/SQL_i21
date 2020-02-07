CREATE PROCEDURE dbo.uspMFPopulateRecipePreStage (
	@intRecipeId INT
	,@intRecipeItemId INT
	,@strRecipeRowState NVARCHAR(50)
	,@strRecipeItemRowState NVARCHAR(50)
	,@intUserId INT
	)
AS
BEGIN
	IF NOT EXISTS (
			SELECT *
			FROM tblMFRecipePreStage
			WHERE intRecipeId = @intRecipeId
				AND IsNULL(intRecipeItemId, 0) = IsNULL(@intRecipeItemId, 0)
				AND strRecipeRowState = @strRecipeRowState
				AND IsNULL(strRecipeItemRowState, '') = IsNULL(@strRecipeItemRowState, '')
				AND intUserId = @intUserId
				AND strFeedStatus IS NULL
			)
	BEGIN
		INSERT INTO tblMFRecipePreStage (
			intRecipeId
			,intRecipeItemId
			,strRecipeRowState
			,strRecipeItemRowState
			,intUserId
			)
		SELECT @intRecipeId
			,@intRecipeItemId
			,@strRecipeRowState
			,@strRecipeItemRowState
			,@intUserId

		IF @strRecipeRowState = 'Delete'
			OR @strRecipeItemRowState = 'Delete'
		BEGIN
			EXEC dbo.uspMFProcessPreStageRecipe @intRecipeId = @intRecipeId
				,@intRecipeItemId = @intRecipeItemId
				,@ysnDeleteFeed = 1
		END
	END
END
