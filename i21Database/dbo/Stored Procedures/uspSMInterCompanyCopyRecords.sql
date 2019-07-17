CREATE PROCEDURE uspSMInterCompanyCopyRecords
@intInterCompanyMappingId INT,
@strType NVARCHAR(250)
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
		PRINT('CALL DMS SP HERE');
	END
	IF UPPER(@strType) = 'COMMENT'
	BEGIN
		EXEC dbo.[uspSMInterCompanyValidateRecordsForMessaging] @intInterCompanyMappingId
	END


--exec us
END