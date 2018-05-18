GO
EXEC('
ALTER PROCEDURE uspGLInsertOriginCrossReferenceMapping
AS
BEGIN
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[dbo].[glactmst]'') AND type IN (N''U'')) 
BEGIN
	PRINT ''Insert Origin xref mapping  aborted  - Origin table glactmst is not available''
	RETURN
END
IF EXISTS (select inti21Id, count(1) from tblGLCOACrossReference group by inti21Id having count(1) > 1)
BEGIN
PRINT ''Insert Origin xref mapping  aborted - Duplicate entry in tblGLCOACrossReference''
RETURN
END


UPDATE coa
SET strOldId = CAST(CAST(glact_acct1_8 AS INT) AS NVARCHAR(50)) + ''-'' + CAST( CAST(glact_acct9_16 AS INT) AS NVARCHAR(50))
FROM tblGLCOACrossReference coa JOIN glactmst orig ON coa.intLegacyReferenceId = orig.A4GLIdentity

DELETE FROM dbo.tblGLCrossReferenceMapping WHERE intAccountId IS NULL
DECLARE @originId INT
IF NOT EXISTS (SELECT TOP 1 1 FROM tblGLAccountSystem WHERE strAccountSystemDescription = ''Origin'')
BEGIN
		
	INSERT INTO tblGLAccountSystem(strAccountSystemDescription, ysnSystem, intConcurrencyId)
	VALUES(''Origin'',1,1)
	SELECT @originId=SCOPE_IDENTITY()
END
ELSE
BEGIN
	SELECT TOP 1 @originId = intAccountSystemId FROM tblGLAccountSystem WHERE strAccountSystemDescription = ''Origin''
	UPDATE tblGLAccountSystem SET ysnSystem = 1 WHERE intAccountSystemId = @originId
END
	MERGE dbo.tblGLCrossReferenceMapping as map
	USING dbo.tblGLCOACrossReference AS coa
	ON map.intAccountId = coa.inti21Id AND
	 map.strOldAccountId = strOldId
	WHEN NOT MATCHED THEN
		INSERT ([strOldAccountId],[intAccountId],[ysnInbound],[ysnOutbound],[intAccountSystemId],[intConcurrencyId])
		VALUES (strOldId,inti21Id,1,0,@originId,1);
	
IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLCompanyPreferenceOption)
	INSERT INTO tblGLCompanyPreferenceOption(intDefaultVisibleOldAccountSystemId,intConcurrencyId) VALUES(1,1)
	
UPDATE tblGLCompanyPreferenceOption SET intDefaultVisibleOldAccountSystemId = 1 WHERE intDefaultVisibleOldAccountSystemId IS NULL
END')
	
GO
PRINT('Started deleting duplicates in tblGLCrossReferenceMapping')
GO

	;WITH exempt AS
	(
		SELECT MIN(intCrossReferenceMappingId) intCrossReferenceMappingId, strOldAccountId, intAccountId, intAccountSystemId, ysnInbound, ysnOutbound FROM dbo.tblGLCrossReferenceMapping
		GROUP BY strOldAccountId, intAccountId , intAccountSystemId,ysnInbound, ysnOutbound HAVING COUNT(1) > 1  
	)
	,dup AS
	(
		SELECT a.intCrossReferenceMappingId a1, c.intCrossReferenceMappingId  a2 FROM dbo.tblGLCrossReferenceMapping a 
		JOIN exempt b ON a.strOldAccountId = b.strOldAccountId AND a.intAccountId = b.intAccountId
		AND a.intAccountSystemId = b.intAccountSystemId AND a.ysnInbound = b.ysnInbound AND a.ysnOutbound = b.ysnOutbound
		LEFT JOIN exempt c ON c.intCrossReferenceMappingId = a.intCrossReferenceMappingId
	)
	DELETE FROM dbo.tblGLCrossReferenceMapping  WHERE intCrossReferenceMappingId IN(SELECT a1 FROM dup WHERE a2 IS null)
GO
	PRINT('Finished deleting duplicates in tblGLCrossReferenceMapping')
GO
	PRINT('Started generating origin cross reference mapping')
GO
	EXEC dbo.uspGLInsertOriginCrossReferenceMapping
GO
	PRINT('Finished generating origin cross reference mapping')
GO
	PRINT('Started updating old account id in tblGLAccount')
GO
	DECLARE @intDefaultAccountSystemId INT
	SELECT TOP 1 @intDefaultAccountSystemId =intDefaultVisibleOldAccountSystemId FROM tblGLCompanyPreferenceOption 
	IF @intDefaultAccountSystemId IS NOT NULL 
		EXEC dbo.uspGLUpdateOldAccountId @intDefaultAccountSystemId
GO
	PRINT('Finished updating old account id in tblGLAccount')
GO


