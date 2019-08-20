
CREATE PROCEDURE [uspSMInterCompanyDeleteMovedDMS]
@intRecordId INT, 
@referenceCompanyId INT = NULL,
@intRecordIdExcludeDelete INT = NULL


AS 
BEGIN

DECLARE @DBNameToUse NVARCHAR(MAX);


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
	DECLARE @sql NVARCHAR(MAX) = N'';

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

