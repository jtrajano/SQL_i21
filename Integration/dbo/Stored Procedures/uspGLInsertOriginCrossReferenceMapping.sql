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
	DECLARE @originId INT
	SELECT TOP 1 @originId = intAccountSystemId FROM tblGLAccountSystem WHERE strAccountSystemDescription = 'Origin'
	--DELETE duplicate intAccountId, strOldAccountId in origin Account System where ysnInbound = 1

	;WITH dup AS
	(
		SELECT strOldAccountId, intAccountId FROM dbo.tblGLCrossReferenceMapping WHERE intAccountSystemId =@originId  AND ysnInbound = 1
		GROUP BY strOldAccountId, intAccountId HAVING COUNT(1) > 1
	),
	exempt AS
	(
		SELECT m.intCrossReferenceMappingId, d.strOldAccountId, d.intAccountId FROM dbo.tblGLCrossReferenceMapping m JOIN dup d ON d.strOldAccountId =m.strOldAccountId AND
		 m.intAccountId = d.intAccountId WHERE intAccountSystemId =@originId  AND ysnInbound = 1
	),
	del AS
	(
		SELECT intCrossReferenceMappingId FROM dbo.tblGLCrossReferenceMapping m JOIN dup d ON d.strOldAccountId =m.strOldAccountId AND
		 m.intAccountId = d.intAccountId WHERE intAccountSystemId =@originId  AND ysnInbound = 1
		 AND m.intCrossReferenceMappingId NOT IN (SELECT m.intCrossReferenceMappingId FROM exempt) 
	)
	DELETE FROM dbo.tblGLCrossReferenceMapping WHERE intCrossReferenceMappingId IN (SELECT intCrossReferenceMappingId FROM	del)
GO
	EXEC dbo.uspGLInsertOriginCrossReferenceMapping
GO
	--update strOldAccountId column in tblGLAccount
	EXEC dbo.uspGLUpdateOldAccountId

GO


