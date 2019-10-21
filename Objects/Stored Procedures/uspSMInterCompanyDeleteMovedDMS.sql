
CREATE PROCEDURE [uspSMInterCompanyDeleteMovedDMS]
@intRecordId INT, 
@referenceCompanyId INT = NULL,
@intRecordIdExcludeDelete INT = NULL


AS 
BEGIN

DECLARE @DBNameToUse NVARCHAR(MAX);
DECLARE @sql NVARCHAR(MAX) = N'';


	IF(ISNULL(@referenceCompanyId,'') = '')
		BEGIN
			SET @DBNameToUse = DB_NAME()
		END
	ELSE
		BEGIN
			SELECT @DBNameToUse = strDatabaseName
			 FROM tblSMInterCompany WHERE intInterCompanyId = @referenceCompanyId
		END

	BEGIN TRY 
	BEGIN TRANSACTION;	
/**********THIS WILL DELETE INDIRECT DOCUMENT ASSOCIATION TO OTHER DB. EQ. A-B, B-C. we delete A so we should delete it also on C**************/
   DECLARE @intReferenceTransactionId INT
   DECLARE @intReferenceCompanyId INT


   select @intReferenceTransactionId = intReferenceTransactionId,
		  @intReferenceCompanyId = intReferenceCompanyId
    from tblSMInterCompanyMapping where intCurrentTransactionId = ( select intTransactionId from tblSMDocument where intDocumentId = @intRecordId) and isnull(intReferenceCompanyId,0) <> 0 

   --on other db
   DECLARE @otherDB nvarchar(20) = (select strDatabaseName from tblSMInterCompany where intInterCompanyId = @intReferenceCompanyId)
   
   if(isnull(@otherDB, '') = '')
   begin
	SET @otherDB = DB_NAME()
   end

   declare @docId INT
   declare @sourceDocId INT
   set @sql = N'SELECT @docId = intDestinationRecordId , @sourceDocId = intSourceRecordId FROM ['+@otherDB +'].dbo.tblSMInterCompanyTransferLogForDMS WHERE intDestinationRecordId = ' +  CAST(ISNULL(@intRecordId,0) AS nvarchar) +' AND ISNULL(intDestinationCompanyId, 0) <> 0 '
   exec sp_executesql @sql, N'@docId INT OUTPUT, @sourceDocId INT OUTPUT', @docId OUTPUT, @sourceDocId OUTPUT

   if(ISNULL(@docId,0) <> 0) 
   begin
		set @sql = N'DELETE FROM ['+@otherDB+'].dbo.tblSMDocument WHERE intDocumentId = '+ CONVERT(VARCHAR,ISNULL(@sourceDocId, 0))
		exec sp_executesql @sql
   end

/***END REGION**/



	SET @sql = N'
	DELETE FROM ['+ @DBNameToUse +'].dbo.[tblSMDocument] 
	WHERE intDocumentId = ' + CONVERT(VARCHAR, @intRecordId) + ' AND intDocumentId NOT IN ('+ CONVERT(VARCHAR,ISNULL(@intRecordIdExcludeDelete, 0)) +') ';

	EXEC sp_executesql @sql
						
		COMMIT TRANSACTION;
   END TRY
   BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRAN
   END CATCH
		
			
END

