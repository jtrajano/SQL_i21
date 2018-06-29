CREATE VIEW [dbo].[vyuVRProgramItemDetail]
AS  
	---with Item Id query
SELECT 
	intRowId = CAST(ROW_NUMBER() OVER(ORDER BY intProgramId) AS INT)
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
		,strUnitMeasure = I.strUnitMeasure
		,D.dblUnitQty
		,B.strRebateBy
		,B.dblRebateRate
		,B.dtmBeginDate
		,B.dtmEndDate
		,B.intConcurrencyId
		,strCategoryCode = ''
	FROM tblVRProgram A
	LEFT JOIN (
		SELECT 
			AA.*
			,BB.intItemUOMId
		FROM tblVRProgramItem AA
		LEFT JOIN tblICItemUOM BB
			ON AA.intItemId = BB.intItemId
				AND AA.intUnitMeasureId = BB.intUnitMeasureId
	) B
		ON A.intProgramId = B.intProgramId
	INNER JOIN tblICItem C
		ON B.intItemId = C.intItemId
	LEFT JOIN tblICItemUOM D
		ON B.intItemUOMId = D.intItemUOMId
	LEFT JOIN tblICUnitMeasure I
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
		,strItemNumber = ''
		,strItemDescription = ''
		,strUnitMeasure = I.strUnitMeasure
		,0
		,B.strRebateBy
		,B.dblRebateRate
		,B.dtmBeginDate
		,B.dtmEndDate
		,B.intConcurrencyId
		,strCategoryCode = E.strCategoryCode
	FROM tblVRProgram A
	INNER JOIN tblVRProgramItem B
		ON A.intProgramId = B.intProgramId
	INNER JOIN tblICCategory E
		ON B.intCategoryId = E.intCategoryId
	LEFT JOIN tblICUnitMeasure I
		ON B.intUnitMeasureId = I.intUnitMeasureId
	INNER JOIN tblVRVendorSetup F
		ON A.intVendorSetupId = F.intVendorSetupId
	INNER JOIN tblAPVendor G
		ON F.intEntityId = G.intEntityId
	INNER JOIN tblEMEntity H
		ON G.intEntityId = H.intEntityId
	WHERE B.intCategoryId IS NOT NULL

	UNION ALL

	SELECT 
		A.intProgramId
		,strVendorNumber = G.strVendorId
		,strVendorName = H.strName
		,A.strProgram
		,A.strProgramDescription
		,A.strVendorProgram
		,strItemNumber = ''
		,strItemDescription = ''
		,strUnitMeasure = ''
		,dblUnitQty = 0.0
		,B.strRebateBy
		,B.dblRebateRate
		,B.dtmBeginDate
		,B.dtmEndDate
		,intConcurrencyId = 0
		,strCategoryCode = ''
	FROM tblVRProgram A
	LEFT JOIN tblVRProgramItem B
		ON A.intProgramId = B.intProgramId
	INNER JOIN tblVRVendorSetup F
		ON A.intVendorSetupId = F.intVendorSetupId
	INNER JOIN tblAPVendor G
		ON F.intEntityId = G.intEntityId
	INNER JOIN tblEMEntity H
		ON G.intEntityId = H.intEntityId
	WHERE B.intCategoryId IS NULL AND B.intItemId IS NULL


) A
GO

