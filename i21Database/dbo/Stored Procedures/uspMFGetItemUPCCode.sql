CREATE PROCEDURE uspMFGetItemUPCCode (@strUPCCode NVARCHAR(50))
AS
IF EXISTS (
		SELECT 1
		FROM tblICItemUomUpc IUA
		WHERE IUA.strLongUpcCode = @strUPCCode
		)
BEGIN
	SELECT IU.intItemId
		,IU.intItemUOMId
		,IU.intUnitMeasureId
		,IUA.strLongUpcCode AS strLongUPCCode
		,IUA.strUpcCode
	FROM tblICItemUOM IU
	JOIN tblICItemUomUpc IUA ON IUA.intItemUOMId = IU.intItemUOMId
	WHERE IUA.strLongUpcCode = @strUPCCode
END
ELSE
BEGIN
	SELECT IU.intItemId
		,IU.intItemUOMId
		,IU.intUnitMeasureId
		,IU.strLongUPCCode
		,IU.strUpcCode
	FROM tblICItemUOM IU
	WHERE IU.strLongUPCCode = @strUPCCode
END
