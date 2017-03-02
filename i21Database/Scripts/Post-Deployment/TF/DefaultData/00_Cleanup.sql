PRINT ('Cleanup Tax Form tables')

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'tblTFValidOriginState')
BEGIN
	DELETE FROM tblTFValidOriginState
	WHERE ISNULL(strFilter, '') = ''
END

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'tblTFReportingComponentProductCode')
BEGIN
	DELETE FROM tblTFReportingComponentProductCode
	WHERE intProductCodeId IS NULL
END

GO

