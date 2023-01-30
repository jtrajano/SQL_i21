CREATE VIEW [dbo].[vyuGRSearchUOMRounding]
AS

SELECT 
	A.intUOMRoundingId
	,A.intItemId
	,A.intUnitOfMeasureFromId 
	,A.intUnitOfMeasureToId
	,A.intDecimalAdjustment
	,A.ysnFixRounding
	,A.intConcurrencyId
	,intItemUOMFromId = B.intItemUOMId
	,intItemUOMToId = C.intItemUOMId
FROM tblGRUOMRounding A
LEFT JOIN tblICItemUOM B
	ON A.intItemId = B.intItemId
		AND A.intUnitOfMeasureFromId = B.intUnitMeasureId
LEFT JOIN tblICItemUOM C
	ON A.intItemId = C.intItemId
		AND A.intUnitOfMeasureToId = C.intUnitMeasureId

GO
