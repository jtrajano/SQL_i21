CREATE PROCEDURE uspSMInterCompanyDeleteMessagingDetails
	@intRecordIdToDelete INT,
	@strTableName NVARCHAR(250) = ''
AS
BEGIN
	BEGIN TRY
		IF ISNULL(@intRecordIdToDelete, 0) <> 0
		BEGIN
			BEGIN TRANSACTION
			
			
				DECLARE @sql NVARCHAR(MAX);
				DECLARE @intRecordIdToUse INT;
				DECLARE @strPrimaryKey NVARCHAR(250) = '';

				--SET PRIMARY COLUMN
				IF @strTableName = 'tblSMActivity'
				BEGIN
					SET @strPrimaryKey = 'intActivityId';
				END
				IF @strTableName = 'tblSMActivityAttendee'
				BEGIN
					SET @strPrimaryKey = 'intActivityAttendeeId';
				END
				IF @strTableName = 'tblSMComment'
				BEGIN
					SET @strPrimaryKey = 'intCommentId';
				END

				--CHECK IF RECORD IS STILL EXISITNG
				DECLARE @ParamDefinition NVARCHAR(250) = N'@paramOut INT OUTPUT';
				SET @sql = N'SELECT @paramOut = ' + @strPrimaryKey + ' FROM dbo.[' + @strTableName + ']
							WHERE ' + @strPrimaryKey + ' = ' + CONVERT(NVARCHAR(100), @intRecordIdToDelete)

				EXEC sp_executesql @sql, @ParamDefinition, @paramOut = @intRecordIdToUse OUTPUT;
				
				IF ISNULL(@intRecordIdToUse, 0) <> 0
				BEGIN
					SET @sql = 'DELETE FROM dbo.[' + @strTableName + '] WHERE ' + @strPrimaryKey + ' = ' + CONVERT(NVARCHAR(100), @intRecordIdToUse)
					EXEC sp_executesql @sql
				END
			
			COMMIT TRANSACTION
		END
	END TRY

	BEGIN CATCH	
		IF @@TRANCOUNT > 0 
			ROLLBACK TRANSACTION  


		DECLARE @ErrorMerssage NVARCHAR(MAX)
		SELECT @ErrorMerssage = ERROR_MESSAGE()									
		RAISERROR(@ErrorMerssage, 11, 1);
		RETURN 0	

	END CATCH	

	RETURN 1
END