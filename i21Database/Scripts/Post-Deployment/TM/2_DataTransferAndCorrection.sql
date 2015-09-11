print N'BEGIN CONVERSION - i21 TANK MANAGEMENT..'

print N'BEGIN Migration of Data from preference company to lease code'
IF EXISTS(SELECT TOP 1 1 FROM sys.columns WHERE name = N'intLeaseItemId' AND Object_ID = Object_ID(N'tblTMPreferenceCompany'))
BEGIN
	EXEC ('
		UPDATE tblTMLeaseCode
		SET intItemId = (SELECT TOP 1 intLeaseItemId FROM tblTMPreferenceCompany)
		WHERE intItemId IS NOT NULL
	')

	EXEC('
		ALTER TABLE tblTMPreferenceCompany DROP COLUMN intLeaseItemId 
	')
END
print N'END Migration of Data from preference company to lease code'