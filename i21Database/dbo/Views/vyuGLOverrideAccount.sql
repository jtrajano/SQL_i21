CREATE VIEW vyuGLOverrideAccount
AS
WITH q as(
SELECT intAccountId, [Primary Account] ,  [Location],  [LOB], [Company] 
	FROM (
		SELECT 
			A.intAccountId,
			D.strDescription,
			U.strUOMCode,
			B.strCode
			,strStructureName = 
			CASE WHEN (LOWER(C.strStructureName) IN ('lob', 'line of business')) THEN 'LOB'
			WHEN LOWER(C.strStructureName) LIKE 'com%' THEN 'Company' 
			ELSE C.strStructureName END,
			g.strOverrideREArray

		FROM tblGLAccountSegmentMapping A
		INNER JOIN tblGLAccountSegment B ON B.intAccountSegmentId = A.intAccountSegmentId
		INNER JOIN tblGLAccountStructure C ON C.intAccountStructureId = B.intAccountStructureId
		INNER JOIN tblGLAccount D ON A.intAccountId = D.intAccountId
		LEFT JOIN tblGLAccountUnit U on D.intAccountUnitId = U.intAccountUnitId
			OUTER APPLY(
			SELECT top 1 strOverrideREArray From tblGLCompanyPreferenceOption
		)g
	) AS S
	PIVOT
	(
		MAX(strCode)
		FOR [strStructureName] IN ([Primary Account], [Location], [LOB],[Company])
	) AS PVT

)
select 
intAccountId,
CASE WHEN [Primary Account] IS NULL THEN '' ELSE  [Primary Account] END +
CASE WHEN [Location] IS NULL THEN '' ELSE '-'+ CASE  when CHARINDEX('1', O.strOverrideREArray) = 0 THEN   [Location] ELSE REPLICATE ('X' , LEN( [Location] )) END  END +
CASE WHEN [LOB] IS NULL THEN '' ELSE '-'+ CASE  when CHARINDEX('2', O.strOverrideREArray) = 0 THEN   [LOB] ELSE REPLICATE ('X' , LEN( [LOB] )) END  END +
CASE WHEN [Company] IS NULL THEN '' ELSE '-'+ CASE  when CHARINDEX('3', O.strOverrideREArray) = 0 THEN   [Company] ELSE REPLICATE ('X' , LEN( [Company] )) END  END
strOverrideAccount
from q
OUTER APPLY (
	SELECT strOverrideREArray FROM tblGLCompanyPreferenceOption
)O
