IF NOT EXISTS (SELECT 1 FROM tblMBILCompanyPreference)
BEGIN
INSERT INTO tblMBILCompanyPreference(ysnShowLogo) values(1)
END