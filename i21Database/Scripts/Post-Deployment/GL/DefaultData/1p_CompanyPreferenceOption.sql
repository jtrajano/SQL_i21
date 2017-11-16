IF EXISTS (SELECT TOP 1 1 FROM tblGLCompanyPreferenceOption)
    UPDATE tblGLCompanyPreferenceOption SET intDBVersion = CAST( SUBSTRING( @@version, 29,2) as int)
ELSE 
    INSERT INTO tblGLCompanyPreferenceOption (intConcurrencyId, intDBVersion) SELECT 1, CAST( SUBSTRING( @@version, 29,2) as int)
