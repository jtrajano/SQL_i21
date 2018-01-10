﻿CREATE PROCEDURE uspGLInsertOriginCrossReferenceMapping
AS
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[glactmst]') AND type IN (N'U'))

BEGIN
EXEC('
IF EXISTS (select inti21Id, count(1) from tblGLCOACrossReference group by inti21Id having count(1) > 1)
BEGIN
PRINT ''Inserting in cross reference mapping table was aborted due to duplicate entry in tblGLCOACrossReference''
RETURN
END


UPDATE coa
SET strOldId = CAST(CAST(glact_acct1_8 AS INT) AS NVARCHAR(50)) + ''-'' + CAST( CAST(glact_acct9_16 AS INT) AS NVARCHAR(50))
FROM tblGLCOACrossReference coa JOIN glactmst orig ON coa.intLegacyReferenceId = orig.A4GLIdentity

DELETE FROM dbo.tblGLCrossReferenceMapping WHERE intAccountId IS NULL
DECLARE @originId INT
IF NOT EXISTS (SELECT TOP 1 1 FROM tblGLAccountSystem WHERE strAccountSystemDescription = ''Origin'')
BEGIN
		
	INSERT INTO tblGLAccountSystem(strAccountSystemDescription, intConcurrencyId)
	VALUES(''Origin'',1)
	SELECT @originId=SCOPE_IDENTITY()
END
ELSE
BEGIN
	SELECT TOP 1 @originId = intAccountSystemId FROM tblGLAccountSystem WHERE strAccountSystemDescription = ''Origin''
END
	MERGE dbo.tblGLCrossReferenceMapping as map
	USING dbo.tblGLCOACrossReference AS coa
	ON map.intAccountId = coa.inti21Id 
	AND map.intAccountSystemId = @originId
	AND coa.ysnOrigin =1
	WHEN MATCHED THEN
		UPDATE SET strOldAccountId = coa.strOldId
	WHEN NOT MATCHED THEN
		INSERT (
			[strOldAccountId],[intAccountId],[ysnInbound],[ysnOutbound],[intAccountSystemId],[intConcurrencyId])
		VALUES (
			strOldId,inti21Id,1,0,@originId,1);
	
	
IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLCompanyPreferenceOption)
	INSERT INTO tblGLCompanyPreferenceOption(intDefaultVisibleOldAccountSystemId,intConcurrencyId) VALUES(1,1)
	
UPDATE tblGLCompanyPreferenceOption SET intDefaultVisibleOldAccountSystemId = 1 WHERE intDefaultVisibleOldAccountSystemId IS NULL')
END
	



