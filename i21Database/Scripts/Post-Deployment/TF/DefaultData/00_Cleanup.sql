PRINT ('Cleanup Tax Form tables')

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'tblTFValidOriginState')
BEGIN
	DELETE FROM tblTFValidOriginState
	WHERE ISNULL(strFilter, '') = ''
END

GO

