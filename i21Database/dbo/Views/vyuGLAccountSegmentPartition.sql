	CREATE VIEW vyuGLAccountSegmentPartition
	AS
	SELECT [Primary Account] strPrimary,  [Location] strLocation,  [LOB] strLOB, ISNULL(strDescription,'')strDescription,ISNULL(strUOMCode,'')strUOMCode
	FROM (
		SELECT 
			A.intAccountId,
			D.strDescription,
			U.strUOMCode,
			B.strCode
			,strStructureName = CASE WHEN (LOWER(C.strStructureName) IN ('lob', 'line of business')) THEN 'LOB' ELSE C.strStructureName END

		FROM tblGLAccountSegmentMapping A
		INNER JOIN tblGLAccountSegment B ON B.intAccountSegmentId = A.intAccountSegmentId
		INNER JOIN tblGLAccountStructure C ON C.intAccountStructureId = B.intAccountStructureId
		INNER JOIN tblGLAccount D ON A.intAccountId = D.intAccountId
		LEFT JOIN tblGLAccountUnit U on D.intAccountUnitId = U.intAccountUnitId
	) AS S
	PIVOT
	(
		MAX(strCode)
		FOR [strStructureName] IN ([Primary Account], [Location], [LOB])
	) AS PVT
	