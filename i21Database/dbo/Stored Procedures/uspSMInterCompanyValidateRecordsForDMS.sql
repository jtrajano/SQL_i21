CREATE PROCEDURE [uspSMInterCompanyValidateRecordsForDMS]
@intInterCompanyMappingId INT

AS 
BEGIN
    declare @currentTransId INT
	declare @referenceTransId INT
	declare @referenceCompanyId INT


	if(object_id('tempdb..#tempDMS') is null)
	create table #tempDMS
	(
		[intInterCompanyMappingId] INT
	)

if(not exists(select top 1 1 from #tempDMS where intInterCompanyMappingId = @intInterCompanyMappingId) AND isnull(@intInterCompanyMappingId, '') <> '' )
	begin

	   SELECT 
		@currentTransId = intCurrentTransactionId,
		@referenceTransId = intReferenceTransactionId,
		@referenceCompanyId = intReferenceCompanyId
		FROM tblSMInterCompanyMapping WHERE intInterCompanyMappingId = @intInterCompanyMappingId
	
		if(ISNULL(@referenceCompanyId,'') = '')
			begin
				exec [uspSMInterCompanyCopyDMS] @currentTransId, @referenceTransId, @referenceCompanyId
				exec [uspSMInterCompanyCopyDMS] @referenceTransId,@currentTransId, @referenceCompanyId
			end
		else
			exec [uspSMInterCompanyCopyDMS] @currentTransId, @referenceTransId, @referenceCompanyId

			insert into #tempDMS (intInterCompanyMappingId) values (@intInterCompanyMappingId)

			declare @intMappingId int

			--RECURSE region here for same database
			select @intMappingId = intInterCompanyMappingId from tblSMInterCompanyMapping where
			(intCurrentTransactionId = @referenceTransId OR intReferenceTransactionId = @currentTransId) OR -- d nmana pde dobol entry sa current and ref
			(intCurrentTransactionId = @currentTransId OR intReferenceTransactionId = @referenceTransId)
			AND intInterCompanyMappingId NOT IN  (SELECT intInterCompanyMappingId from #tempDMS) -- must select entries that are not present on temp table which are already processed
			AND intInterCompanyMappingId <> @intInterCompanyMappingId AND intReferenceCompanyId IS NULL --for same database
		

			--call recurse sp
			exec [uspSMInterCompanyValidateRecordsForDMS] @intMappingId
			
	end

END