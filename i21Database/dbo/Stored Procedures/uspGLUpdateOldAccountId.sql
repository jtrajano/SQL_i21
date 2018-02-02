CREATE PROCEDURE [dbo].[uspGLUpdateOldAccountId]
AS
BEGIN
;WITH XREF AS
(
	SELECT  MAX(m.intCrossReferenceMappingId) intCrossReferenceMappingId 
	FROM dbo.tblGLCrossReferenceMapping m 
	JOIN dbo.tblGLCompanyPreferenceOption op ON op.intDefaultVisibleOldAccountSystemId = m. intAccountSystemId
	GROUP BY m.intAccountId,m.strOldAccountId
)
UPDATE account  
SET strOldAccountId = b.strOldAccountId
FROM dbo.tblGLAccount account 
LEFT JOIN
(SELECT map.intAccountId,map.strOldAccountId FROM
 dbo.tblGLCrossReferenceMapping map
JOIN XREF x ON x.intCrossReferenceMappingId = map.intCrossReferenceMappingId
) b
ON b.intAccountId = account.intAccountId
END

