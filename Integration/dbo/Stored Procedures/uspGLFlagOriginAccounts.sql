GO
	EXEC (
	'IF EXISTS(select top 1 1 from sys.procedures where name = ''uspGLFlagOriginAccounts'')
		DROP PROCEDURE uspGLFlagOriginAccounts'
	)
	GO
	EXEC('
	CREATE PROCEDURE [dbo].[uspGLFlagOriginAccounts]
	AS
	IF EXISTS(SELECT TOP 1 1 FROM sys.objects T WHERE T.name = ''glactmst_bak'')
	BEGIN
		UPDATE C SET ysnOrigin = CASE WHEN A.A4GLIdentity IS NULL  THEN 0 ELSE 1 END
		FROM glactmst A JOIN glactmst_bak B
		ON CAST(A.glact_acct1_8 AS NVARCHAR(40)) + ''-'' + CAST( A.glact_acct9_16 AS NVARCHAR(40))= 
		CAST(B.glact_acct1_8 AS NVARCHAR(40)) + ''-'' + CAST( B.glact_acct9_16 AS NVARCHAR(40))
		RIGHT JOIN tblGLCOACrossReference C
		ON C.intLegacyReferenceId = A.A4GLIdentity
	END')
	EXEC uspGLFlagOriginAccounts
GO