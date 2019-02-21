CREATE VIEW dbo.vyuARItemUOM
AS
SELECT intItemUOMId		= A.intItemUOMId
	 , intUnitMeasureId	= A.intUnitMeasureId
	 , intItemId		= A.intItemId 
	 , strUnitMeasure	= B.strUnitMeasure
	 , strSymbol		= B.strSymbol 
	 , dblUnitQty		= A.dblUnitQty	 
FROM dbo.tblICItemUOM AS A 
INNER JOIN dbo.tblICUnitMeasure AS B ON A.intUnitMeasureId = B.intUnitMeasureId