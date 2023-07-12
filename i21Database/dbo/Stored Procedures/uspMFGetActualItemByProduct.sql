﻿CREATE PROCEDURE uspMFGetActualItemByProduct 
(
	@intItemId				INT
  , @intRecipeItemTypeId	INT
  , @intLocationId			INT
  , @strItemNo				NVARCHAR(MAX) = ''
  , @intWorkOrderId			INT
  , @intActualItemId		INT = 0
  , @intCategoryId			INT = 0
)
AS
BEGIN
	DECLARE @intManufacturingProcessId	INT
		  , @strDefaultConsumptionUOM	NVARCHAR(50)
		  , @intRecipeTypeId			INT

	SELECT @intManufacturingProcessId	= intManufacturingProcessId
		 , @intRecipeTypeId				= intRecipeTypeId
	FROM tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	SELECT @strDefaultConsumptionUOM = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND intAttributeId = 99

	IF ISNULL(@strDefaultConsumptionUOM, '') = ''
		BEGIN
			SELECT @strDefaultConsumptionUOM = '1'
		END


	/**/
	IF @intRecipeTypeId = 3
		BEGIN
			SELECT DISTINCT I.intItemId
				 , I.strItemNo
				 , I.strDescription
				 , CASE WHEN @strDefaultConsumptionUOM = 3 THEN SIU.intItemUOMId
						ELSE PIU.intItemUOMId
				   END AS intItemUOMId
				 , CASE WHEN @strDefaultConsumptionUOM = 3 THEN SU.intUnitMeasureId
						ELSE PU.intUnitMeasureId
				   END AS intUnitMeasureId
				 , CASE WHEN @strDefaultConsumptionUOM = 3 THEN SU.strUnitMeasure
						ELSE PU.strUnitMeasure
				   END AS strUnitMeasure
				 , I.intLayerPerPallet
				 , I.intUnitPerLayer
				 , WO.dblQuantity
				 , WO.dblProducedQuantity
				 , I.intCategoryId
				 , I.strLotTracking
				 , 0 As intMainItemId
				 , '' As strMainItemNo
				 , '' As strMainItemDescription
				 , (SELECT TOP 1 intCertificationId FROM vyuCTItemCertification WHERE intItemId = I.intItemId ORDER BY intItemCertificationId) AS intCertificationId
				 , (SELECT TOP 1 strCertificationName FROM vyuCTItemCertification WHERE intItemId = I.intItemId ORDER BY intItemCertificationId) AS strCertificationName
				 , ItemLocation.intAllowNegativeInventory
			FROM dbo.tblMFWorkOrderRecipe R
			LEFT JOIN dbo.tblMFWorkOrderRecipeCategory RC ON RC.intRecipeId = R.intRecipeId AND RC.intWorkOrderId = R.intWorkOrderId AND RC.intRecipeItemTypeId = @intRecipeItemTypeId
			JOIN tblMFWorkOrder WO ON WO.intWorkOrderId = R.intWorkOrderId AND R.intWorkOrderId = @intWorkOrderId
			JOIN dbo.tblICItem I ON I.intCategoryId = IsNULL(RC.intCategoryId, I.intCategoryId) AND I.strType NOT IN ('Other Charge'
																													, 'Service')
			LEFT JOIN dbo.tblICItemUOM PIU ON PIU.intItemId = I.intItemId AND PIU.intUnitMeasureId = I.intMaterialPackTypeId
			LEFT JOIN dbo.tblICUnitMeasure PU ON PU.intUnitMeasureId = PIU.intUnitMeasureId
			JOIN dbo.tblICItemUOM SIU ON SIU.intItemId = I.intItemId AND SIU.ysnStockUnit = 1
			JOIN dbo.tblICUnitMeasure SU ON SU.intUnitMeasureId = SIU.intUnitMeasureId
										AND R.intLocationId = @intLocationId
										AND R.ysnActive = 1
										AND R.intItemId = @intItemId
										AND 
										(
											I.strItemNo LIKE '%' + @strItemNo + '%'
										 OR I.strDescription LIKE '%' + @strItemNo + '%'
										)
										AND I.intItemId = 
										(
											CASE WHEN @intActualItemId > 0 THEN @intActualItemId
												 ELSE I.intItemId
											END
										)
										AND ISNULL(I.intCategoryId, 0) <> 
										(
											CASE WHEN @intCategoryId > 0 THEN @intCategoryId
												 ELSE - 1
											END
										)
			OUTER APPLY (SELECT intAllowNegativeInventory
						 FROM tblICItemLocation AS ICItemLocation
						 WHERE ICItemLocation.intItemId = I.intItemId AND ICItemLocation.intLocationId = @intLocationId) AS ItemLocation
			ORDER BY I.strItemNo
		END
	ELSE
		BEGIN
			SELECT DISTINCT I.intItemId
				 , I.strItemNo
				 , I.strDescription
				 , CASE WHEN @strDefaultConsumptionUOM = 3 THEN SIU.intItemUOMId
						ELSE ISNULL(IU.intItemUOMId, IU1.intItemUOMId)
				   END AS intItemUOMId
				 , CASE WHEN @strDefaultConsumptionUOM = 3 THEN SU.intUnitMeasureId
						ELSE U.intUnitMeasureId
				   END AS intUnitMeasureId
				 , CASE WHEN @strDefaultConsumptionUOM = 3 THEN SU.strUnitMeasure
						ELSE U.strUnitMeasure
				   END AS strUnitMeasure
				 , I.intLayerPerPallet
				 , I.intUnitPerLayer
				 , WO.dblQuantity
				 , WO.dblProducedQuantity
				 , I.intCategoryId
				 , I.strLotTracking
				 , I1.intItemId As intMainItemId
				 , I1.strItemNo As strMainItemNo
				 , I1.strDescription As strMainItemDescription
				 , ItemLocation.intAllowNegativeInventory
			FROM dbo.tblMFWorkOrderRecipe R
			JOIN dbo.tblMFWorkOrderRecipeItem RI ON RI.intRecipeId = R.intRecipeId
												AND RI.intWorkOrderId = R.intWorkOrderId
												AND RI.intRecipeItemTypeId = @intRecipeItemTypeId
												AND R.intWorkOrderId = @intWorkOrderId
			JOIN tblMFWorkOrder WO ON WO.intWorkOrderId = R.intWorkOrderId
			LEFT JOIN dbo.tblMFWorkOrderRecipeSubstituteItem SI ON SI.intRecipeItemId = RI.intRecipeItemId AND SI.intWorkOrderId = RI.intWorkOrderId
			JOIN dbo.tblICItem I ON 
			(
				I.intItemId = RI.intItemId
			 OR I.intItemId = SI.intSubstituteItemId
			)
			AND I.strType NOT IN 
			(
				'Other Charge'
			  , 'Service'
			)
			LEFT JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = RI.intItemUOMId AND IU.intItemId = I.intItemId
			LEFT JOIN dbo.tblICItemUOM IU1 ON IU1.intItemUOMId = SI.intItemUOMId AND IU1.intItemId = I.intItemId
			JOIN dbo.tblICUnitMeasure U ON U.intUnitMeasureId = ISNULL(IU.intUnitMeasureId, IU1.intUnitMeasureId)
			JOIN dbo.tblICItemUOM SIU ON SIU.intItemId = I.intItemId AND SIU.ysnStockUnit = 1
			JOIN dbo.tblICUnitMeasure SU ON SU.intUnitMeasureId = SIU.intUnitMeasureId
			JOIN dbo.tblICItem I1 ON I1.intItemId = RI.intItemId
								 AND R.intLocationId = @intLocationId
								 AND R.ysnActive = 1
								 AND R.intItemId = @intItemId
								 AND 
								 (
									I.strItemNo LIKE '%' + @strItemNo + '%'
								 OR I.strDescription LIKE '%' + @strItemNo + '%'
								 )
								AND I.intItemId = (CASE WHEN @intActualItemId > 0 THEN @intActualItemId
														ELSE I.intItemId
												   END)
								AND ISNULL(I.intCategoryId, 0) <> (CASE WHEN @intCategoryId > 0 THEN @intCategoryId
																		ELSE - 1
																   END)
			OUTER APPLY (SELECT intAllowNegativeInventory
						 FROM tblICItemLocation AS ICItemLocation
						 WHERE ICItemLocation.intItemId = I.intItemId AND ICItemLocation.intLocationId = @intLocationId) AS ItemLocation
			ORDER BY I.strItemNo
		END
END
