--liquibase formatted sql

-- changeset Von:vyuICGetItemUOMByType.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER VIEW [dbo].[vyuICGetItemUOMByType]
AS

SELECT	intId = CAST(ROW_NUMBER() OVER(ORDER BY um.intUnitMeasureId, uom.intItemId) AS INT)
		, um.intUnitMeasureId
		, um.strUnitMeasure
		, um.strUnitType
		, um.strSymbol
		, uom.intItemId
FROM	tblICUnitMeasure um INNER JOIN tblICItemUOM uom 
			ON uom.intUnitMeasureId = um.intUnitMeasureId



