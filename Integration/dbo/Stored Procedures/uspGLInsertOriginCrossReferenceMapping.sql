CREATE PROCEDURE uspGLInsertOriginCrossReferenceMapping
AS
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[glactmst]') AND type IN (N'U'))
BEGIN
	EXEC('
	UPDATE coa
	SET strOldId = CAST(CAST(glact_acct1_8 AS INT) AS NVARCHAR(50)) + ''-'' + CAST( CAST(glact_acct9_16 AS INT) AS NVARCHAR(50))
	FROM tblGLCOACrossReference coa JOIN glactmst orig ON coa.intLegacyReferenceId = orig.A4GLIdentity

	SET IDENTITY_INSERT tblGLAccountSystem ON
	MERGE tblGLAccountSystem A
	USING (
	SELECT id =1 , name = ''Origin'', parent =NULL UNION ALL
	SELECT id = 2, name = ''i21'', parent =1
	) AS B
	ON A.intAccountSystemId = B.id
	WHEN MATCHED THEN UPDATE
	SET strAccountSystemDescription  = name,intParentAccountSystemId = parent

	WHEN NOT MATCHED THEN
	INSERT(intAccountSystemId,strAccountSystemDescription, intParentAccountSystemId,intConcurrencyId)
	VALUES(id,name,parent,1);
	SET IDENTITY_INSERT tblGLAccountSystem OFF

	MERGE dbo.tblGLCrossReferenceMapping as map
	USING dbo.tblGLCOACrossReference AS coa
	ON map.inti21AccountId = coa.inti21Id
	WHEN MATCHED THEN
	UPDATE SET
	intOldAccountId = coa.intLegacyReferenceId,
	strOldAccountId = coa.strOldId
	WHEN NOT MATCHED THEN

	INSERT (
	[intOldAccountId],
	[strOldAccountId],
	[inti21AccountId],
	[stri21AccountId], 
	[intAccountSystemId],
	[intConcurrencyId]
	)
	VALUES 
	(intLegacyReferenceId,
	strOldId,
	inti21Id,
	stri21Id,
	1,
	1);
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLCompanyPreferenceOption)
		INSERT INTO tblGLCompanyPreferenceOption(intDefaultVisibleOldAccountSystemId,intConcurrencyId) VALUES(1,1)
	
	UPDATE tblGLCompanyPreferenceOption SET intDefaultVisibleOldAccountSystemId = 1 WHERE intDefaultVisibleOldAccountSystemId IS NULL')
END
	



