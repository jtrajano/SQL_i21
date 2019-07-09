CREATE PROCEDURE uspSMInterCompanyCopyRecords
@intInterCompanyMappingId INT 

AS 
BEGIN
	IF(ISNULL(@intInterCompanyMappingId,0) = 0)
		BEGIN
			PRINT 'Mapping Id cannot be nullable'
			RETURN;
		END

--call Messaging and DMS SP here
exec us
END