CREATE PROCEDURE uspSMInterCompanyCopyRecords
@intInterCompanyMappingId INT,
@strType NVARCHAR(250),
@intReferToDocumentId INT = NULL

AS 
BEGIN
	IF(ISNULL(@intInterCompanyMappingId,0) = 0)
		BEGIN
			PRINT 'Mapping Id cannot be nullable'
			RETURN;
		END

	--call Messaging and DMS SP here
	IF UPPER(@strType) = 'DMS'
	BEGIN
		EXEC dbo.[uspSMInterCompanyValidateRecordsForDMS] @intInterCompanyMappingId, @intReferToDocumentId = @intReferToDocumentId
		PRINT('CALL DMS SP HERE');
	END
	IF UPPER(@strType) = 'COMMENT'
	BEGIN
		EXEC dbo.[uspSMInterCompanyValidateRecordsForMessaging] @intInterCompanyMappingId
	END


--exec us
END