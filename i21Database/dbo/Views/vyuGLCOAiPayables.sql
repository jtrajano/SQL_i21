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
		'01' AS strRecordCode,
		'C0000549' AS strCustomerId,
		'D1' AS strType,
		A.strCode AS strValue,
		B.strDescription
	FROM vyuGLAccountDetail A
	INNER JOIN tblGLAccountSegment B ON A.strCode = B.strCode
	--INNER JOIN vyuGLAccountSegmentPartition B ON A.strCode = B.strPrimary AND A.strLocationSegmentId = B.strLocation
	UNION ALL
	SELECT DISTINCT
		'01' AS strRecordCode,
		'C0000549' AS strCustomerId,
		'D2' AS strType,
		A.strLocationSegmentId AS strValue,
		B.strDescription
	FROM vyuGLAccountDetail A
	INNER JOIN tblGLAccountSegment B ON A.strCode = B.strCode
	--INNER JOIN vyuGLAccountSegmentPartition B ON A.strCode = B.strPrimary AND A.strLocationSegmentId = B.strLocation
	UNION ALL
	SELECT DISTINCT
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
	UNION ALL
	SELECT DISTINCT
		'01' AS strRecordCode,
		'C0000549' AS strCustomerId,
		'D4' AS strType,
		A.strCompanySegmentId AS strValue,
		B.strDescription
	FROM vyuGLAccountDetail A
	INNER JOIN tblGLAccountSegment B ON A.strCode = B.strCode
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
	SELECT 
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