
CREATE PROCEDURE [dbo].[uspSMInterCompanyDeleteDMSFromStaging]
@intRecordIdToExclude INT = NULL
AS 
BEGIN

DECLARE @intDeleteId INT;
DECLARE @intSourceId INT;
DECLARE @intDestinationId INT;
DECLARE @strDatabase NVARCHAR(MAX);
DECLARE @sql NVARCHAR(MAX) = N'';
DECLARE @currentDB NVARCHAR(200) = (DB_NAME())

	if(object_id('tempdb.#tmpDeleteDMS') is not null)
		DROP TABLE #TempInterCompanyMapping


		CREATE TABLE #tmpDeleteDMS
		(
			[intDeleteId] INT IDENTITY(1,1),
			[intSourceId] INT NOT NULL,
			[intDestinationId] INT NOT NULL,
			[strDatabaseName] NVARCHAR(MAX) NULL
		)
		
		INSERT INTO #tmpDeleteDMS (intSourceId, intDestinationId, strDatabaseName)
			SELECT DISTINCT intSourceId, intDestinationId, strDatabaseName FROM tblSMInterCompanyStageDelete 
		
		WHILE EXISTS(SELECT TOP 1 1 FROM #tmpDeleteDMS)
		BEGIN
			(SELECT TOP 1 @intDeleteId = intDeleteId,
						  @intSourceId = intSourceId,
						  @intDestinationId = intDestinationId,
						  @strDatabase = strDatabaseName
						 FROM #tmpDeleteDMS)

			IF(UPPER(@strDatabase) = UPPER(@currentDB))
				BEGIN
						SET @sql = N'
						DELETE FROM ['+ @strDatabase +'].dbo.[tblSMDocument] 
						WHERE (intDocumentId = ' + CONVERT(VARCHAR, @intSourceId) + ' OR intDocumentId = '+ CONVERT(VARCHAR, @intDestinationId)  + ') AND intDocumentId NOT IN ('+ CONVERT(VARCHAR,ISNULL(@intRecordIdToExclude,0)) +') ';
				END
			ELSE
				BEGIN
					SET @sql = N'
						DELETE FROM ['+ @strDatabase + '].dbo.[tblSMDocument]
						WHERE (intDocumentId = ' + CONVERT(VARCHAR, @intDestinationId) + ') '
					
				END

			EXEC sp_executesql @sql
			DELETE FROM #tmpDeleteDMS WHERE intDeleteId = @intDeleteId

		END	 
		
				DELETE FROM tblSMInterCompanyStageDelete
			

			
END

