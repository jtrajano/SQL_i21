CREATE  PROCEDURE [dbo].[uspMFGetProductByProcess] 
(
	@intManufacturingProcessId	INT
  , @intLocationID				INT
  , @strItemNo					NVARCHAR(50) = '%'
  , @intItemId					INT = 0
)
AS
BEGIN
	SELECT I.intItemId
		 , I.strItemNo
		 , I.strDescription
		 , IU.intItemUOMId
		 , U.intUnitMeasureId
		 , U.strUnitMeasure
		 , I.strLotTracking
		 , CONVERT(BIT, (CASE WHEN EXISTS (SELECT *
										   FROM tblMFRecipeItem RI
										   WHERE RI.intRecipeId = R.intRecipeId AND RI.intConsumptionMethodId = 1) THEN 1
							  ELSE 0
						 END)) AS ysnInputItemEnabled
		 , I.intCategoryId
		 , 0 AS dblProducedQuantity
		 , 0 AS intMainItemId
		 , '' AS strMainItemNo
		 , 0 AS intCertificationId
		 , '' AS strCertificationName
		 , I.intLayerPerPallet
		 , I.intUnitPerLayer
		 , 0 AS dblQuantity
		 , '' AS strMainItemDescription
	FROM dbo.tblMFRecipe R
	JOIN dbo.tblICItem I ON I.intItemId = R.intItemId
	JOIN dbo.tblICItemUOM IU ON IU.intItemId = I.intItemId AND IU.intUnitMeasureId = I.intWeightUOMId
	JOIN dbo.tblICUnitMeasure U ON U.intUnitMeasureId = IU.intUnitMeasureId
							   AND R.intLocationId = @intLocationID
							   AND R.ysnActive = 1
							   AND R.intManufacturingProcessId = @intManufacturingProcessId
							   AND I.strStatus = 'Active'
							   AND I.strItemNo LIKE @strItemNo + '%'
							   AND I.intItemId = (CASE WHEN @intItemId > 0 THEN @intItemId
													   ELSE I.intItemId
												  END)
	ORDER BY I.strItemNo
END