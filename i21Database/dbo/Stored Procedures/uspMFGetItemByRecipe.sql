CREATE PROCEDURE uspMFGetItemByRecipe (
	@intProductId INT
	,@intLocationId INT
	)
AS
BEGIN
	DECLARE @intCategoryId INT

	SELECT @intCategoryId = RC.intCategoryId
	FROM tblMFRecipe R
	JOIN tblMFRecipeCategory RC ON R.intRecipeId = RC.intRecipeId
	WHERE R.intItemId = @intProductId
		AND R.ysnActive = 1
		AND R.intLocationId = @intLocationId
		AND RC.intRecipeItemTypeId = 1

	IF @intCategoryId IS NOT NULL
	BEGIN
		SELECT intItemId
			,strItemNo
			,strDescription
			,intMaterialPackTypeId
			,intWeightUOMId
			,intLayerPerPallet
			,intUnitPerLayer
		FROM tblICItem
		WHERE intCategoryId IN (
				SELECT RC.intCategoryId
				FROM tblMFRecipe R
				JOIN tblMFRecipeCategory RC ON R.intRecipeId = RC.intRecipeId
				WHERE R.intItemId = @intProductId
					AND R.ysnActive = 1
					AND R.intLocationId = @intLocationId
					AND RC.intRecipeItemTypeId = 1
				)
	END
	ELSE
	BEGIN
		SELECT intItemId
			,strItemNo
			,strDescription
			,intMaterialPackTypeId
			,intWeightUOMId
			,intLayerPerPallet
			,intUnitPerLayer
		FROM tblICItem
	END
END
