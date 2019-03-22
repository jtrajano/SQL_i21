GO
PRINT 'Begin updating db version int tblGLCompanyPreferenceOption'
GO
IF EXISTS (SELECT TOP 1 1 FROM tblGLCompanyPreferenceOption)
    UPDATE tblGLCompanyPreferenceOption SET intDBVersion = CAST( SUBSTRING( @@version, 22,4) as int)
ELSE 
    INSERT INTO tblGLCompanyPreferenceOption (intConcurrencyId, intDBVersion) SELECT 1, CAST( SUBSTRING( @@version, 22,4) as int)
GO
PRINT 'Finished updating db version int tblGLCompanyPreferenceOption'
GO