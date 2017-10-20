﻿CREATE VIEW [dbo].[vyuVRProgramItemDetail]
AS  
	---with Item Id query
SELECT 
	intRowId = ROW_NUMBER() OVER(ORDER BY intProgramId)
	,A.*
FROM( 
	SELECT 
		A.intProgramId
		,strVendorNumber = G.strVendorId
		,strVendorName = H.strName
		,A.strProgram
		,A.strProgramDescription
		,A.strVendorProgram
		,strItemNumber = C.strItemNo
		,strItemDescription = C.strDescription
		,strItemUOM = I.strUnitMeasure
		,D.dblUnitQty
		,B.strRebateBy
		,B.dblRebateRate
		,B.dtmBeginDate
		,B.dtmEndDate
		,B.intConcurrencyId
	FROM tblVRProgram A
	INNER JOIN tblVRProgramItem B
		ON A.intProgramId = B.intProgramId
	INNER JOIN tblICItem C
		ON B.intItemId = C.intItemId
	INNER JOIN tblICItemUOM D
		ON C.intItemId = D.intItemId
	INNER JOIN tblICUnitMeasure I
		ON D.intUnitMeasureId = I.intUnitMeasureId
	INNER JOIN tblICCategory E
		ON C.intCategoryId = E.intCategoryId
	INNER JOIN tblVRVendorSetup F
		ON A.intVendorSetupId = F.intVendorSetupId
	INNER JOIN tblAPVendor G
		ON F.intEntityId = G.intEntityId
	INNER JOIN tblEMEntity H
		ON G.intEntityId = H.intEntityId
	WHERE B.intItemId IS NOT NULL

	UNION ALL

	--Category query
	SELECT 
		A.intProgramId
		,strVendorNumber = G.strVendorId
		,strVendorName = H.strName
		,A.strProgram
		,A.strProgramDescription
		,A.strVendorProgram
		,strItemNumber = C.strItemNo
		,strItemDescription = C.strDescription
		,strItemUOM = I.strUnitMeasure
		,D.dblUnitQty
		,B.strRebateBy
		,B.dblRebateRate
		,B.dtmBeginDate
		,B.dtmEndDate
		,B.intConcurrencyId
	FROM tblVRProgram A
	INNER JOIN tblVRProgramItem B
		ON A.intProgramId = B.intProgramId
	INNER JOIN tblICCategory E
		ON B.intCategoryId = E.intCategoryId
	INNER JOIN tblICItem C
		ON E.intCategoryId = C.intCategoryId
	INNER JOIN tblICItemUOM D
		ON C.intItemId = D.intItemId
	INNER JOIN tblICUnitMeasure I
		ON D.intUnitMeasureId = I.intUnitMeasureId
	INNER JOIN tblVRVendorSetup F
		ON A.intVendorSetupId = F.intVendorSetupId
	INNER JOIN tblAPVendor G
		ON F.intEntityId = G.intEntityId
	INNER JOIN tblEMEntity H
		ON G.intEntityId = H.intEntityId
	WHERE B.intCategoryId IS NOT NULL
) A
GO

