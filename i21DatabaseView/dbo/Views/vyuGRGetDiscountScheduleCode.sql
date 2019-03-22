CREATE VIEW [dbo].[vyuGRGetDiscountScheduleCodeItem]
AS SELECT DISTINCT
	GRDSC.intDiscountScheduleId
	,ICI.intItemId
	,ICI.strItemNo
FROM tblGRDiscountScheduleCode GRDSC
INNER JOIN tblICItem ICI ON ICI.intItemId = GRDSC.intItemId