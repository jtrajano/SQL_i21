CREATE PROCEDURE uspGLInsertOriginCrossReferenceMapping
AS
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[glactmst]') AND type IN (N'U'))
BEGIN
	EXEC('
	UPDATE coa
	SET strOldId = CAST(CAST(glact_acct1_8 AS INT) AS NVARCHAR(50)) + ''-'' + CAST( CAST(glact_acct9_16 AS INT) AS NVARCHAR(50))
	FROM tblGLCOACrossReference coa JOIN glactmst orig ON coa.intLegacyReferenceId = orig.A4GLIdentity

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblGLAccountSystem WHERE strAccountSystemDescription = ''Origin'')
	BEGIN
		SET IDENTITY_INSERT tblGLAccountSystem ON
		INSERT INTO tblGLAccountSystem(intAccountSystemId, strAccountSystemDescription, intConcurrencyId)
		VALUES( 1, ''Origin'',1)
		SET IDENTITY_INSERT tblGLAccountSystem OFF
	END
	DELETE FROM dbo.tblGLCrossReferenceMapping WHERE intAccountId IS NULL
	MERGE dbo.tblGLCrossReferenceMapping as map
	USING dbo.tblGLCOACrossReference AS coa
	ON map.intAccountId = coa.inti21Id
	WHEN MATCHED THEN
	UPDATE SET
	--intOldAccountId = coa.intLegacyReferenceId,
	strOldAccountId = coa.strOldId
	WHEN NOT MATCHED THEN

	INSERT (
	--[intOldAccountId],
	[strOldAccountId],
	[intAccountId],
	[ysnInbound],
	[ysnOutbound],
	--[stri21AccountId], 
	[intAccountSystemId],
	[intConcurrencyId]
	)
	VALUES 
	(
	--intLegacyReferenceId,
	strOldId,
	inti21Id,
	1,
	0,
	--stri21Id,
	1,
	1);
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLCompanyPreferenceOption)
		INSERT INTO tblGLCompanyPreferenceOption(intDefaultVisibleOldAccountSystemId,intConcurrencyId) VALUES(1,1)
	
	UPDATE tblGLCompanyPreferenceOption SET intDefaultVisibleOldAccountSystemId = 1 WHERE intDefaultVisibleOldAccountSystemId IS NULL')
END
	



