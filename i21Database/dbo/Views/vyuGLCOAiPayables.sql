CREATE VIEW [dbo].[vyuGLCOAiPayables]
AS

WITH COA (
	strRecordCode,
	strCustomerId,
	strType,
	strValue,
	strDescription
) AS (
	SELECT DISTINCT
	TOP 100 PERCENT
		'01' AS strRecordCode,
		'C0000549' AS strCustomerId,
		'D1' AS strType,
		A.strCode AS strValue,
		B.strDescription
	FROM vyuGLAccountDetail A
	INNER JOIN tblGLAccountSegment B ON A.strCode = B.strCode
	--INNER JOIN vyuGLAccountSegmentPartition B ON A.strCode = B.strPrimary AND A.strLocationSegmentId = B.strLocation
	ORDER BY A.strCode
	UNION ALL
	SELECT TOP 100 PERCENT
		locSegment.*,
		B.strDescription
	FROM (
		SELECT DISTINCT
			'01' AS strRecordCode,
			'C0000549' AS strCustomerId,
			'D2' AS strType,
			A.strLocationSegmentId AS strValue
		FROM vyuGLAccountDetail A
	) locSegment
	INNER JOIN tblGLAccountSegment B ON locSegment.strValue = B.strCode
	ORDER BY locSegment.strValue
	--INNER JOIN vyuGLAccountSegmentPartition B ON A.strCode = B.strPrimary AND A.strLocationSegmentId = B.strLocation
	UNION ALL
	SELECT DISTINCT
	TOP 100 PERCENT
		'01' AS strRecordCode,
		'C0000549' AS strCustomerId,
		'D3' AS strType,
		B.strCode AS strValue,
		B.strDescription
	FROM vyuGLAccountDetail A
	INNER JOIN (
		SELECT 
			A.intAccountId,
			B.strDescription,
			B.strCode
			--,strStructureName = CASE WHEN (LOWER(C.strStructureName) IN ('lob', 'line of business')) THEN 'LOB' ELSE C.strStructureName END
		FROM tblGLAccountSegmentMapping A
		INNER JOIN tblGLAccountSegment B ON B.intAccountSegmentId = A.intAccountSegmentId
		INNER JOIN tblGLAccountStructure C ON C.intAccountStructureId = B.intAccountStructureId
		INNER JOIN tblGLAccount D ON A.intAccountId = D.intAccountId
		LEFT JOIN tblGLAccountUnit U on D.intAccountUnitId = U.intAccountUnitId
		WHERE 
			(LOWER(C.strStructureName) IN ('lob', 'line of business'))
	) B
	ON
		A.intAccountId = B.intAccountId
	ORDER BY strValue
	UNION ALL
	SELECT TOP 100 PERCENT
		 comp.*,
		 B.strDescription
	FROM (
		SELECT DISTINCT
			'01' AS strRecordCode,
			'C0000549' AS strCustomerId,
			'D4' AS strType,
			A.strCompanySegmentId AS strValue
		FROM vyuGLAccountDetail A
	) comp
	INNER JOIN tblGLAccountSegment B ON comp.strValue = B.strCode
	ORDER BY comp.strValue
),

csvData (
	strRecordCode,
	strCustomerId,
	strData
) AS (
	SELECT
		'01' AS strRecordCode,
		'C0000549' AS strCustomerId,
		'H11' + '|' + strLocationNumber + '|' + strLocationName + '|' AS strData
	FROM tblSMCompanyLocation
	UNION ALL
	SELECT TOP 100 PERCENT
		strRecordCode, strCustomerId,
		+ strType + '|' 
		+ strValue + '|' 
		+ strDescription + '|'
		AS strData
	FROM COA A
	UNION ALL
	SELECT
		'01' AS strRecordCode,
		'C0000549' AS strCustomerId,
		'D5' + '|' + strLedgerName + '|'
	FROM tblGLLedger
	UNION ALL
	SELECT
		'01' AS strRecordCode,
		'C0000549' AS strCustomerId,
		'D6' + '|' + strLedgerName + '|'
	FROM tblGLLedgerDetail
)


SELECT
	strRecordCode,
	strCustomerId,
	strData
FROM csvData
UNION ALL
SELECT
	'99', strCustomerId, CAST(COUNT(*) AS NVARCHAR(100)) + '|'
FROM csvData
GROUP BY strCustomerId