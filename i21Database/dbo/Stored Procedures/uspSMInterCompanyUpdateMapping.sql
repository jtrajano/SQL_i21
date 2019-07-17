
CREATE PROCEDURE uspSMInterCompanyUpdateMapping
@currentTransactionId INT,
@referenceTransactionId INT,
@referenceCompanyId INT = NULL --if not exist reverse
AS

BEGIN

DECLARE @intInterCompanyMappingId INT;

/*** Validations *****/
if(isnull(@currentTransactionId,'') = '' and isnull(@referenceTransactionId,'') = '')										
	begin
		RAISERROR('Source and Destination Transaction Id must not be null.',16,1);
		return;
	end
if(exists(select top 1 1 from tblSMInterCompanyMapping where intCurrentTransactionId = @currentTransactionId 
		and intReferenceTransactionId = @referenceTransactionId 
		and intReferenceCompanyId= @referenceCompanyId))
	begin
		print 'Entry already exists'
		return;
	end
/***** End Validations *****/


begin try 
	begin transaction;
	if(isnull(@referenceCompanyId,'') = '')
	begin
		if (not exists(select * from tblSMInterCompanyMapping where intCurrentTransactionId = @currentTransactionId and intReferenceTransactionId = @referenceTransactionId))
		begin
				insert into tblSMInterCompanyMapping (intCurrentTransactionId, intReferenceTransactionId)
					values(@currentTransactionId, @referenceTransactionId)
					
			end
	end
	else --insert C
		begin
			if(isnull(@currentTransactionId,'') <> '' and isnull(@referenceTransactionId,'') <> '')
				begin
					insert into tblSMInterCompanyMapping (intCurrentTransactionId, intReferenceTransactionId, intReferenceCompanyId)
								values (@currentTransactionId, @referenceTransactionId, @referenceCompanyId)
				end
		end

		commit tran




		DECLARE @intCurrentCompanyId INT;
		SELECT @intCurrentCompanyId = intInterCompanyId FROM tblSMInterCompany WHERE UPPER(strDatabaseName) = UPPER(DB_NAME()) AND UPPER(strServerName) = UPPER(@@SERVERNAME);

		IF ISNULL(@intCurrentCompanyId, 0) <> 0
		BEGIN
			--always get the first entry in tblSMInterCompanyMapping to prevent looping in A-B,B-C,C-A scenario
			SELECT TOP 1 @intInterCompanyMappingId = intInterCompanyMappingId 
			FROM tblSMInterCompanyMapping
			WHERE ((intCurrentTransactionId = @currentTransactionId OR 
					intReferenceTransactionId = @currentTransactionId) AND
					(ISNULL(intReferenceCompanyId, 0) = 0 OR ISNULL(intReferenceCompanyId, 0) = @intCurrentCompanyId))
				  OR 
				  (intCurrentTransactionId = @currentTransactionId AND ISNULL(intReferenceCompanyId, 0) <> 0)
			ORDER BY intCurrentTransactionId

			IF ISNULL(@intInterCompanyMappingId, 0) <> 0
			BEGIN
				EXEC dbo.[uspSMInterCompanyCopyRecords] @intInterCompanyMappingId, 'DMS';
				EXEC dbo.[uspSMInterCompanyCopyRecords] @intInterCompanyMappingId, 'COMMENT';
			END
		END

	end try
		begin catch
			if @@TRANCOUNT > 0
				rollback transaction;
				PRINT ERROR_MESSAGE()

		end catch
END

