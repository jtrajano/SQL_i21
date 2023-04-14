CREATE PROCEDURE [dbo].[uspMFGetBlendSheetItemUOMs]
(
	@intItemId		INT
  , @strUnitType	NVARCHAR(50)
  , @intItemUOMId	INT
  , @strUnitMeasure NVARCHAR(50)
)
	
AS

DECLARE @tblItemUOM AS TABLE
(
	intItemId			INT
  , intItemUOMId		INT
  , intUnitMeasureId	INT
  , strUnitMeasure		NVARCHAR(50)
  , dblWeightPerUnit	NUMERIC(18, 6)
)

IF @strUnitType = 'All'
	BEGIN
		SET @strUnitType = NULL;
	END

INSERT INTO @tblItemUOM
(
	intItemId
  , intItemUOMId
  , intUnitMeasureId
  , strUnitMeasure
  , dblWeightPerUnit
)
SELECT Item.intItemId
	 , ItemUOM.intItemUOMId		AS intItemUOMId
	 , ItemUOM.intUnitMeasureId
	 , UOM.strUnitMeasure		AS strUnitMeasure
	 , ItemUOM.dblUnitQty		AS dblWeightPerUnit
FROM tblICItem AS Item 
JOIN tblICItemUOM AS ItemUOM ON Item.intItemId = ItemUOM.intItemId
JOIN tblICUnitMeasure AS UOM ON ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId 
WHERE Item.intItemId = @intItemId AND (@strUnitType IS NULL OR UOM.strUnitType = @strUnitType);


IF @intItemUOMId > 0
	BEGIN
		SELECT TOP 1 * FROM @tblItemUOM WHERE intItemUOMId = @intItemUOMId;
	END
ELSE IF @strUnitMeasure <> ''
	BEGIN
		SELECT TOP 1 * FROM @tblItemUOM WHERE LOWER(strUnitMeasure) = LOWER(@strUnitMeasure);
	END
ELSE
	BEGIN
		SELECT * FROM @tblItemUOM;
	END
