
CREATE PROCEDURE uspSMUpdateInterCompanyMapping
@currentTransactionId INT,
@referenceTransactionId INT,
@referenceCompanyId INT = NULL --if not exist reverse
AS

BEGIN


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

	/****
		TODO: Call SP#2
		pass @scope_identity(), @type = DMS/comment,
	*****/

		commit tran
	end try
		begin catch
			if @@TRANCOUNT > 0
				rollback transaction;
				PRINT ERROR_MESSAGE()

		end catch
END

