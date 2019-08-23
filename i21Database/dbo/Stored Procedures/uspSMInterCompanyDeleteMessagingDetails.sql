CREATE PROCEDURE uspSMInterCompanyDeleteMessagingDetails
	@intRecordIdToDelete INT,
	@strTableName NVARCHAR(250) = '',
	@strDataDatabaseName NVARCHAR(250) = '',
	@strLogDatabaseName NVARCHAR(250) = '',
	@intDestinationCompanyId INT = 0
AS
BEGIN
	BEGIN TRY
		IF ISNULL(@intRecordIdToDelete, 0) <> 0
		BEGIN
			BEGIN TRANSACTION
				IF OBJECT_ID('tempdb..#TempPrimaryKeys') IS NOT NULL
					DROP TABLE #TempPrimaryKeys

				CREATE TABLE #TempPrimaryKeys
				(
					[intPrimaryKeyId]		INT
				)
			
				DECLARE @sql NVARCHAR(MAX);
				DECLARE @intRecordIdToUse INT;
				DECLARE @strPrimaryKey NVARCHAR(250) = '';
				DECLARE @intNotificationId INT = 0;
				DECLARE @intCommentId INT = 0;
				DECLARE @intActivityAttendeeId INT = 0;
				DECLARE @strCurrentDataDatabaseName NVARCHAR(250) = '';
				DECLARE @strCurrentLogDatabaseName NVARCHAR(250) = '';
				DECLARE @strRecordColumnName NVARCHAR(250) = 'intSourceRecordId';
				DECLARE @strRecordColumnNameReference NVARCHAR(250) = 'intDestinationRecordId';
				DECLARE @strActivityColumnName NVARCHAR(250) = 'intSourceActivityId';
				DECLARE @intCount INT = 0;

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

				IF @strDataDatabaseName = ''
				BEGIN
					SET @strCurrentDataDatabaseName = DB_NAME();
				END
				ELSE
				BEGIN
					SET @strCurrentDataDatabaseName = @strDataDatabaseName;
				END
				IF @strLogDatabaseName = ''
				BEGIN
					SET @strCurrentLogDatabaseName = DB_NAME();
				END
				ELSE
				BEGIN
					SET @strCurrentLogDatabaseName = @strLogDatabaseName;
				END

				--deleting other database (BU1), we need to delete the record in logging database(ZUG)
				--use intDestinationRecordId for referencing table records
				IF @strCurrentDataDatabaseName <> @strCurrentLogDatabaseName
				BEGIN
					SET @strRecordColumnName = 'intDestinationRecordId';
					SET @strRecordColumnNameReference = 'intSourceRecordId';
					SET @strActivityColumnName = 'intDestinationActivityId';
				END

				--CHECK IF RECORD IS STILL EXISITNG IN THE CURRENT SERVER
				DECLARE @ParamDefinition NVARCHAR(250) = N'@paramOut INT OUTPUT';
				SET @sql = N'SELECT @paramOut = ' + @strPrimaryKey + ' FROM [' + @strCurrentDataDatabaseName + '].dbo.[' + @strTableName + ']
							WHERE ' + @strPrimaryKey + ' = ' + CONVERT(NVARCHAR(100), @intRecordIdToDelete)

				EXEC sp_executesql @sql, @ParamDefinition, @paramOut = @intRecordIdToUse OUTPUT;
				
				IF ISNULL(@intRecordIdToUse, 0) <> 0
				BEGIN
					--IF TABLE NAME IS ACTIVITY, DELETE ALL ENTRIES IN tblSMNotification, tblSMComment, and tblSMActivityAttendee in tblSMInterCompanyTransferLogForComment
					IF @strTableName = 'tblSMActivity'
					BEGIN
						----------------------------NOTIFICATION----------------------------
						SET @sql = N'
							INSERT INTO #TempPrimaryKeys
							SELECT intNotificationId FROM [' + @strCurrentDataDatabaseName + '].dbo.tblSMNotification WHERE intActivityId = ' + CONVERT(VARCHAR(250), @intRecordIdToUse) + '
						'
						EXEC sp_executesql @sql

						WHILE EXISTS(SELECT 1 FROM #TempPrimaryKeys)
						BEGIN
							SELECT TOP 1 @intNotificationId = intPrimaryKeyId FROM #TempPrimaryKeys
							
							
							SET @sql = N'
									DELETE FROM [' + @strCurrentLogDatabaseName + '].dbo.tblSMInterCompanyTransferLogForComment
									WHERE strTable = ''tblSMNotification''
									AND ' + @strRecordColumnName + ' = ' + CONVERT(NVARCHAR(250), @intNotificationId) + '
									AND ISNULL(intDestinationCompanyId, 0) = ' + CONVERT(NVARCHAR(250), ISNULL(@intDestinationCompanyId, 0)) + '
							'
							EXEC sp_executesql @sql

							DELETE FROM #TempPrimaryKeys where intPrimaryKeyId = @intNotificationId
						END

						----------------------------COMMENT----------------------------
						SET @sql = N'
							INSERT INTO #TempPrimaryKeys
							SELECT intCommentId FROM [' + @strCurrentDataDatabaseName + '].dbo.tblSMComment WHERE intActivityId = ' + CONVERT(VARCHAR(250), @intRecordIdToUse) + '
						'
						EXEC sp_executesql @sql

						
						WHILE EXISTS(SELECT 1 FROM #TempPrimaryKeys)
						BEGIN
							SELECT TOP 1 @intCommentId = intPrimaryKeyId FROM #TempPrimaryKeys
							
							SET @sql = N'
								DELETE FROM [' + @strCurrentLogDatabaseName + '].dbo.tblSMInterCompanyTransferLogForComment
								WHERE strTable = ''tblSMComment''
								AND ' + @strRecordColumnName + ' = ' + CONVERT(VARCHAR(250), @intCommentId) + '
								AND ISNULL(intDestinationCompanyId, 0) = ' + CONVERT(NVARCHAR(250), ISNULL(@intDestinationCompanyId, 0)) + '
							'
							EXEC sp_executesql @sql

							DELETE FROM #TempPrimaryKeys where intPrimaryKeyId = @intCommentId
						END
						

						----------------------------ATTENDEE----------------------------
						SET @sql = N'
							INSERT INTO #TempPrimaryKeys
							SELECT intActivityAttendeeId FROM [' + @strCurrentDataDatabaseName + '].dbo.tblSMActivityAttendee WHERE intActivityId = ' + CONVERT(VARCHAR(250), @intRecordIdToUse) + '
						'
						EXEC sp_executesql @sql

						
						WHILE EXISTS(SELECT 1 FROM #TempPrimaryKeys)
						BEGIN
							SELECT TOP 1 @intActivityAttendeeId = intPrimaryKeyId FROM #TempPrimaryKeys
							
							SET @sql = N'
								DELETE FROM [' + @strCurrentLogDatabaseName + '].dbo.tblSMInterCompanyTransferLogForComment
								WHERE strTable = ''tblSMActivityAttendee''
								AND ' + @strRecordColumnName + ' = ' + CONVERT(VARCHAR(250), @intActivityAttendeeId) + '
								AND ISNULL(intDestinationCompanyId, 0) = ' + CONVERT(NVARCHAR(250), ISNULL(@intDestinationCompanyId, 0)) + '
							'
							EXEC sp_executesql @sql

							DELETE FROM #TempPrimaryKeys where intPrimaryKeyId = @intActivityAttendeeId
						END
					END
					
					

					--IF TABLE NAME IS COMMENT, DELETE ALL ENTRIES IN tblSMNotification
					IF @strTableName = 'tblSMComment'
					BEGIN
						----------------------------NOTIFICATION----------------------------
						SET @sql = N'
							INSERT INTO #TempPrimaryKeys
							SELECT intNotificationId FROM [' + @strCurrentDataDatabaseName + '].dbo.tblSMNotification WHERE intCommentId = ' + CONVERT(VARCHAR(250), @intRecordIdToUse) + '
						'
						EXEC sp_executesql @sql

						WHILE EXISTS(SELECT 1 FROM #TempPrimaryKeys)
						BEGIN
							SELECT TOP 1 @intNotificationId = intPrimaryKeyId FROM #TempPrimaryKeys
							
							
							SET @sql = N'
									DELETE FROM [' + @strCurrentLogDatabaseName + '].dbo.tblSMInterCompanyTransferLogForComment
									WHERE strTable = ''tblSMNotification''
									AND ' + @strRecordColumnName + ' = ' + CONVERT(NVARCHAR(250), @intNotificationId) + '
									AND ISNULL(intDestinationCompanyId, 0) = ' + CONVERT(NVARCHAR(250), ISNULL(@intDestinationCompanyId, 0)) + '
							'
							EXEC sp_executesql @sql

							DELETE FROM #TempPrimaryKeys where intPrimaryKeyId = @intNotificationId
						END

						
					END

					
					--DELETE THE RECORD
					SET @sql = 'DELETE FROM [' + @strCurrentDataDatabaseName + '].dbo.[' + @strTableName + '] WHERE ' + @strPrimaryKey + ' = ' + CONVERT(NVARCHAR(100), @intRecordIdToUse)
					EXEC sp_executesql @sql
				END
				ELSE
				BEGIN
					--DELETE RECORDS IN tblSMInterCompanyTransferLogForComment for non tblSMActivity(tblSMActivity will use for siblings in sp wise)
					IF @strTableName = 'tblSMActivity'
					BEGIN
						--tblSMActivity
						SET @sql = N'DELETE FROM [' + @strCurrentLogDatabaseName + '].dbo.tblSMInterCompanyTransferLogForComment
									WHERE strTable IN (''tblSMNotification'', ''tblSMComment'', ''tblSMActivityAttendee'')
									AND ' + @strActivityColumnName + ' = ' + CONVERT(NVARCHAR(250), @intRecordIdToDelete) + '
									AND ISNULL(intDestinationCompanyId, 0) = ' + CONVERT(NVARCHAR(250), ISNULL(@intDestinationCompanyId, 0)) + '
									'
						EXEC sp_executesql @sql
					END

					IF @strTableName = 'tblSMComment'
					BEGIN
						--tblSMActivity
						SET @sql = N'DELETE FROM [' + @strCurrentLogDatabaseName + '].dbo.tblSMInterCompanyTransferLogForComment
									WHERE strTable IN (''tblSMNotification'')
									AND ' + @strActivityColumnName + ' = ' + CONVERT(NVARCHAR(250), @intRecordIdToDelete) + '
									AND ISNULL(intDestinationCompanyId, 0) = ' + CONVERT(NVARCHAR(250), ISNULL(@intDestinationCompanyId, 0)) + '
									'
						EXEC sp_executesql @sql
					END
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