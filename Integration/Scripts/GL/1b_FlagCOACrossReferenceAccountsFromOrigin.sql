GO
	EXEC('
		UPDATE tblGLCOACrossReference set ysnOrigin = 0
		IF NOT EXISTS(SELECT top 1 1 FROM sys.tables WHERE tables.name = ''glactmst'') RETURN
		IF NOT EXISTS(SELECT top 1 1 FROM sys.tables WHERE tables.name = ''glactmst_bak'') RETURN
		;WITH c AS (
			SELECT a.A4GLIdentity
			FROM glactmst a JOIN glactmst_bak b ON
			a.glact_acct1_8 = b.glact_acct1_8
			AND a.glact_acct9_16 = b.glact_acct9_16
		)
		UPDATE d
		SET ysnOrigin = 1
		FROM tblGLCOACrossReference d
		JOIN c ON d.intLegacyReferenceId = c.A4GLIdentity')

GO