CREATE PROCEDURE uspMFGetItemUPCCode (@strUPCCode NVARCHAR(50))
AS
SELECT IU.intItemId
	,IU.intItemUOMId
	,IU.intUnitMeasureId
	,IsNULL(IUA.strLongUpcCode, IU.strLongUPCCode) strLongUPCCode
	,IsNULL(IUA.strUpcCode, IU.strUpcCode) AS strUpcCode
FROM tblICItemUOM IU
LEFT JOIN tblICItemUomUpc IUA ON IUA.intItemUOMId = IU.intItemUOMId
WHERE IsNULL(IUA.strLongUpcCode, IU.strLongUPCCode) = @strUPCCode