PRINT ('Cleanup Tax Form tables')

DELETE FROM tblTFValidOriginState
WHERE ISNULL(strFilter, '') = ''


DELETE FROM tblTFValidDestinationState
WHERE ISNULL(strStatus, '') = ''

GO