GO
	PRINT N'START REMOVE DUPLICATE SCREENS & TRANSACTIONS'
	BEGIN
		IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblSMScreen]')) 
		BEGIN 
			RETURN
		END

		SET NOCOUNT ON

		DECLARE @DuplicateScreen TABLE (
			strNamespace NVARCHAR(MAX)
		)

		DECLARE @DuplicateControl TABLE (
			strControlId NVARCHAR(MAX)
		)

		DECLARE @DuplicateRecord TABLE (
			intRecordId	INT
		)

		DECLARE @strNamespace AS NVARCHAR(MAX)
		DECLARE @strControlId AS NVARCHAR(MAX)
		DECLARE @intRecordId AS INT
		DECLARE @rowsAffected AS INT

		-- Get all duplicated screens
		INSERT INTO @DuplicateScreen (strNamespace)
			SELECT strNamespace 
			FROM tblSMScreen
				GROUP BY strNamespace
				HAVING COUNT(*) > 1

		DECLARE @screenCount AS INT = (SELECT COUNT(*) FROM @DuplicateScreen)
		PRINT 'Duplicate Screens:' + '(' + CAST(@screenCount AS NVARCHAR(50)) + ')'

		DECLARE @screenCounter AS INT = 1

		WHILE EXISTS(SELECT * FROM @DuplicateScreen)
		BEGIN
			SELECT TOP 1 @strNamespace = strNamespace FROM @DuplicateScreen
			PRINT 'Namespace (' + @strNamespace + '): ' + CAST(@screenCounter AS NVARCHAR(50)) + ' of ' + CAST(@screenCount AS NVARCHAR(50)) 

			-- Winner Screen Id (This means that other duplicated Screen Id will be deleted)
			DECLARE @intScreenId AS INT = (SELECT TOP 1 intScreenId FROM tblSMScreen WHERE strNamespace = @strNamespace ORDER BY intScreenId ASC)
			PRINT 'Winner Screen Id: ' + CAST(@intScreenId AS NVARCHAR(50))

			-- Get all duplicated record id on tblSMTransaction 
			INSERT INTO @DuplicateRecord (intRecordId)
				SELECT intRecordId 
				FROM tblSMTransaction
				WHERE intScreenId IN (
					SELECT intScreenId FROM tblSMScreen WHERE strNamespace = @strNamespace
				) GROUP BY intRecordId 
				HAVING COUNT(*) > 1
				ORDER BY intRecordId

			DECLARE @recordCount AS INT = (SELECT COUNT(*) FROM @DuplicateRecord)
			PRINT 'Duplicate Records:' + '(' + CAST(@recordCount AS NVARCHAR(50)) + ')'

			DECLARE @recordCounter AS INT = 1

			WHILE EXISTS(SELECT * FROM @DuplicateRecord)
			BEGIN
				SELECT TOP 1 @intRecordId = intRecordId FROM @DuplicateRecord
				PRINT 'Record (' + CAST(@intRecordId AS NVARCHAR(50)) + '): ' + CAST(@recordCounter AS NVARCHAR(50)) + ' of ' + CAST(@recordCount AS NVARCHAR(50)) 

				-- Winner Transaction Id (This means other duplicated Transaction Id will be deleted)
				DECLARE @intTransactionId AS INT = (SELECT TOP 1 intTransactionId 
													FROM tblSMTransaction A 
														INNER JOIN tblSMScreen B ON A.intScreenId = B.intScreenId 
													WHERE B.strNamespace = @strNamespace AND intRecordId = @intRecordId
													ORDER BY intTransactionId ASC)

				PRINT 'Winner Transaction Id: ' + + CAST(@intTransactionId AS NVARCHAR(50))

				-- Correct intTransactionId of tblSMApproval from the duplicated one into the Winner Transaction Id
				UPDATE tblSMApproval
				SET intTransactionId = @intTransactionId
				FROM tblSMApproval 
				WHERE intTransactionId IN (
					SELECT intTransactionId 
					FROM tblSMTransaction 
					WHERE intRecordId = @intRecordId AND 
						  intScreenId IN (SELECT intScreenId FROM tblSMScreen WHERE strNamespace = @strNamespace) AND 
						  intTransactionId <> @intTransactionId
				)
				
				SET @rowsAffected = @@ROWCOUNT
				IF @rowsAffected > 0
					BEGIN 
						PRINT 'Updated tblSMApproval: ' + '(' + CAST(@rowsAffected AS NVARCHAR(50)) + ')'
					END

				-- Correct intTransactionId of tblSMLog from the duplicated one into the Winner Transaction Id
				UPDATE tblSMLog
				SET intTransactionId = @intTransactionId
				FROM tblSMLog 
				WHERE intTransactionId IN (
					SELECT intTransactionId 
					FROM tblSMTransaction 
					WHERE intRecordId = @intRecordId AND 
						  intScreenId IN (SELECT intScreenId FROM tblSMScreen WHERE strNamespace = @strNamespace) AND 
						  intTransactionId <> @intTransactionId
				)

				SET @rowsAffected = @@ROWCOUNT
				IF @rowsAffected > 0
					BEGIN 
						PRINT 'Updated tblSMLog: ' + '(' + CAST(@rowsAffected AS NVARCHAR(50)) + ')'
					END

				-- Correct intTransactionId of tblSMActivity from the duplicated one into the Winner Transaction Id
				UPDATE tblSMActivity
				SET intTransactionId = @intTransactionId
				FROM tblSMActivity 
				WHERE intTransactionId IN (
					SELECT intTransactionId 
					FROM tblSMTransaction 
					WHERE intRecordId = @intRecordId AND 
						  intScreenId IN (SELECT intScreenId FROM tblSMScreen WHERE strNamespace = @strNamespace) AND 
						  intTransactionId <> @intTransactionId
				)

				SET @rowsAffected = @@ROWCOUNT
				IF @rowsAffected > 0
					BEGIN 
						PRINT 'tblSMActivity: ' + '(' + CAST(@rowsAffected AS NVARCHAR(50)) + ')'
					END

				-- Correct intTransactionId of tblSMCustomGridRow from the duplicated one into the Winner Transaction Id
				UPDATE tblSMCustomGridRow
				SET intTransactionId = @intTransactionId
				FROM tblSMCustomGridRow WHERE intTransactionId IN (
					SELECT intTransactionId 
					FROM tblSMTransaction 
					WHERE intRecordId = @intRecordId AND 
						  intScreenId IN (SELECT intScreenId FROM tblSMScreen WHERE strNamespace = @strNamespace) AND 
						  intTransactionId <> @intTransactionId
				)

				SET @rowsAffected = @@ROWCOUNT
				IF @rowsAffected > 0
					BEGIN 
						PRINT 'Updated tblSMCustomGridRow: ' + '(' + CAST(@rowsAffected AS NVARCHAR(50)) + ')'
					END

				-- Correct intTransactionId of tblSMTabRow from the duplicated one into the Winner Transaction Id
				UPDATE tblSMTabRow
				SET intTransactionId = @intTransactionId
				FROM tblSMTabRow WHERE intTransactionId IN (
					SELECT intTransactionId 
					FROM tblSMTransaction 
					WHERE intRecordId = @intRecordId AND 
						  intScreenId IN (SELECT intScreenId FROM tblSMScreen WHERE strNamespace = @strNamespace) AND 
						  intTransactionId <> @intTransactionId
				)

				SET @rowsAffected = @@ROWCOUNT
				IF @rowsAffected > 0
					BEGIN 
						PRINT 'Updated tblSMTabRow: ' + '(' + CAST(@rowsAffected AS NVARCHAR(50)) + ')'
					END

				-- Correct intTransactionId of tblSMGridRow from the duplicated one into the Winner Transaction Id
				UPDATE tblSMGridRow
				SET intTransactionId = @intTransactionId
				FROM tblSMGridRow WHERE intTransactionId IN (
					SELECT intTransactionId 
					FROM tblSMTransaction 
					WHERE intRecordId = @intRecordId AND 
						  intScreenId IN (SELECT intScreenId FROM tblSMScreen WHERE strNamespace = @strNamespace) AND 
						  intTransactionId <> @intTransactionId
				)

				SET @rowsAffected = @@ROWCOUNT
				IF @rowsAffected > 0
					BEGIN 
						PRINT 'Updated tblSMGridRow: ' + '(' + CAST(@rowsAffected AS NVARCHAR(50)) + ')'
					END

				-- Correct intTransactionId of tblSMComment from the duplicated one into the Winner Transaction Id
				UPDATE tblSMComment
				SET intTransactionId = @intTransactionId
				FROM tblSMComment WHERE intTransactionId IN (
					SELECT intTransactionId 
					FROM tblSMTransaction 
					WHERE intRecordId = @intRecordId AND 
						  intScreenId IN (SELECT intScreenId FROM tblSMScreen WHERE strNamespace = @strNamespace) AND 
						  intTransactionId <> @intTransactionId
				)

				SET @rowsAffected = @@ROWCOUNT
				IF @rowsAffected > 0
					BEGIN 
						PRINT 'Updated tblSMComment: ' + '(' + CAST(@rowsAffected AS NVARCHAR(50)) + ')'
					END

				-- Correct intTransactionId of tblSMCommentWatcher from the duplicated one into the Winner Transaction Id
				UPDATE tblSMCommentWatcher
				SET intTransactionId = @intTransactionId
				FROM tblSMCommentWatcher WHERE intTransactionId IN (
					SELECT intTransactionId 
					FROM tblSMTransaction 
					WHERE intRecordId = @intRecordId AND 
						  intScreenId IN (SELECT intScreenId FROM tblSMScreen WHERE strNamespace = @strNamespace) AND 
						  intTransactionId <> @intTransactionId
				)

				SET @rowsAffected = @@ROWCOUNT
				IF @rowsAffected > 0
					BEGIN 
						PRINT 'Updated tblSMCommentWatcher: ' + '(' + CAST(@rowsAffected AS NVARCHAR(50)) + ')'
					END

				-- Correct intTransactionId of tblSMTransactionLockHistory from the duplicated one into the Winner Transaction Id
				UPDATE tblSMTransactionLockHistory
				SET intTransactionId = @intTransactionId
				FROM tblSMTransactionLockHistory WHERE intTransactionId IN (
					SELECT intTransactionId 
					FROM tblSMTransaction 
					WHERE intRecordId = @intRecordId AND 
						  intScreenId IN (SELECT intScreenId FROM tblSMScreen WHERE strNamespace = @strNamespace) AND 
						  intTransactionId <> @intTransactionId
				)

				SET @rowsAffected = @@ROWCOUNT
				IF @rowsAffected > 0
					BEGIN 
						PRINT 'Updated tblSMTransactionLockHistory: ' + '(' + CAST(@rowsAffected AS NVARCHAR(50)) + ')'
					END

				-- Correct intTransactionId of tblSMApprovalAmendmentLog from the duplicated one into the Winner Transaction Id
				UPDATE tblSMApprovalAmendmentLog
				SET intTransactionId = @intTransactionId
				FROM tblSMApprovalAmendmentLog WHERE intTransactionId IN (
					SELECT intTransactionId 
					FROM tblSMTransaction 
					WHERE intRecordId = @intRecordId AND 
						  intScreenId IN (SELECT intScreenId FROM tblSMScreen WHERE strNamespace = @strNamespace) AND 
						  intTransactionId <> @intTransactionId
				)

				SET @rowsAffected = @@ROWCOUNT
				IF @rowsAffected > 0
					BEGIN 
						PRINT 'Updated tblSMApprovalAmendmentLog: ' + '(' + CAST(@rowsAffected AS NVARCHAR(50)) + ')'
					END

				-- Correct intTransactionId of tblSMDocument from the duplicated one into the Winner Transaction Id
				UPDATE tblSMDocument
				SET intTransactionId = @intTransactionId
				FROM tblSMDocument WHERE intTransactionId IN (
					SELECT intTransactionId 
					FROM tblSMTransaction 
					WHERE intRecordId = @intRecordId AND 
						  intScreenId IN (SELECT intScreenId FROM tblSMScreen WHERE strNamespace = @strNamespace) AND 
						  intTransactionId <> @intTransactionId
				)

				SET @rowsAffected = @@ROWCOUNT
				IF @rowsAffected > 0
					BEGIN 
						PRINT 'Updated tblSMDocument: ' + '(' + CAST(@rowsAffected AS NVARCHAR(50)) + ')'
					END

				-- Correct intTransactionId of tblSMReportTranslation from the duplicated one into the Winner Transaction Id
				UPDATE tblSMReportTranslation
				SET intTransactionId = @intTransactionId
				FROM tblSMReportTranslation WHERE intTransactionId IN (
					SELECT intTransactionId 
					FROM tblSMTransaction 
					WHERE intRecordId = @intRecordId AND intScreenId IN (SELECT intScreenId FROM tblSMScreen WHERE strNamespace = @strNamespace) AND 
					intTransactionId <> @intTransactionId
				)

				SET @rowsAffected = @@ROWCOUNT
				IF @rowsAffected > 0
					BEGIN 
						PRINT 'Updated tblSMReportTranslation: ' + '(' + CAST(@rowsAffected AS NVARCHAR(50)) + ')'
					END

				-- Delete duplicated tblSMTransaction
				DELETE FROM tblSMTransaction 
				WHERE intRecordId = @intRecordId AND intScreenId IN (SELECT intScreenId FROM tblSMScreen WHERE strNamespace = @strNamespace) AND intTransactionId <> @intTransactionId

				SET @rowsAffected = @@ROWCOUNT
				IF @rowsAffected > 0
				BEGIN 
					PRINT 'Deleted tblSMTransaction: ' + '(' + CAST(@rowsAffected AS NVARCHAR(50)) + ')'
				END

				SET @recordCounter = @recordCounter + 1

				DELETE FROM @DuplicateRecord WHERE intRecordId = @intRecordId
			END

			-- Set the intScreenId of other tblSMTransaction that doesn't have duplicates into the winner Screen Id
			UPDATE tblSMTransaction
			SET intScreenId = @intScreenId
			WHERE intScreenId IN (
				SELECT intScreenId 
				FROM tblSMScreen 
				WHERE strNamespace = @strNamespace
			) AND intScreenId <> @intScreenId 
			
			SET @rowsAffected = @@ROWCOUNT
			IF @rowsAffected > 0
			BEGIN 
				PRINT 'Updated tblSMTransaction (Single): ' + '(' + CAST(@rowsAffected AS NVARCHAR(50)) + ')'
			END

			-- User Approval Configuration
			UPDATE tblSMUserSecurityRequireApprovalFor
			SET intScreenId = @intScreenId
			FROM tblSMUserSecurityRequireApprovalFor 
			WHERE intScreenId IN (SELECT intScreenId FROM tblSMScreen WHERE strNamespace = @strNamespace AND intScreenId <> @intScreenId)

			SET @rowsAffected = @@ROWCOUNT
			IF @rowsAffected > 0
				BEGIN 
					PRINT 'Updated tblSMUserSecurityRequireApprovalFor: ' + '(' + CAST(@rowsAffected AS NVARCHAR(50)) + ')'
				END

			-- Company Location Approval Configuration
			UPDATE tblSMCompanyLocationRequireApprovalFor
			SET intScreenId = @intScreenId
			FROM tblSMCompanyLocationRequireApprovalFor 
			WHERE intScreenId IN (SELECT intScreenId FROM tblSMScreen WHERE strNamespace = @strNamespace AND intScreenId <> @intScreenId)

			SET @rowsAffected = @@ROWCOUNT
			IF @rowsAffected > 0
				BEGIN 
					PRINT 'Updated tblSMCompanyLocationRequireApprovalFor: ' + '(' + CAST(@rowsAffected AS NVARCHAR(50)) + ')'
				END

			-- Entity Approval Configuration
			UPDATE tblEMEntityRequireApprovalFor
			SET intScreenId = @intScreenId
			FROM tblEMEntityRequireApprovalFor 
			WHERE intScreenId IN (SELECT intScreenId FROM tblSMScreen WHERE strNamespace = @strNamespace AND intScreenId <> @intScreenId)

			SET @rowsAffected = @@ROWCOUNT
			IF @rowsAffected > 0
				BEGIN 
					PRINT 'Updated tblEMEntityRequireApprovalFor: ' + '(' + CAST(@rowsAffected AS NVARCHAR(50)) + ')'
				END

			-- Custom Grid
			UPDATE tblSMCustomGrid
			SET intScreenId = @intScreenId
			FROM tblSMCustomGrid 
			WHERE intScreenId IN (SELECT intScreenId FROM tblSMScreen WHERE strNamespace = @strNamespace AND intScreenId <> @intScreenId)

			SET @rowsAffected = @@ROWCOUNT
			IF @rowsAffected > 0
				BEGIN 
					PRINT 'Updated tblSMCustomGrid: ' + '(' + CAST(@rowsAffected AS NVARCHAR(50)) + ')'
				END

			-- Custom Tab
			UPDATE tblSMCustomTab
			SET intScreenId = @intScreenId
			FROM tblSMCustomTab 
			WHERE intScreenId IN (SELECT intScreenId FROM tblSMScreen WHERE strNamespace = @strNamespace AND intScreenId <> @intScreenId)

			SET @rowsAffected = @@ROWCOUNT
			IF @rowsAffected > 0
				BEGIN 
					PRINT 'Updated tblSMCustomTab: ' + '(' + CAST(@rowsAffected AS NVARCHAR(50)) + ')'
				END

			-- Document Source Folder
			UPDATE tblSMDocumentSourceFolder
			SET intScreenId = @intScreenId
			FROM tblSMDocumentSourceFolder 
			WHERE intScreenId IN (SELECT intScreenId FROM tblSMScreen WHERE strNamespace = @strNamespace AND intScreenId <> @intScreenId)

			SET @rowsAffected = @@ROWCOUNT
			IF @rowsAffected > 0
				BEGIN 
					PRINT 'Updated tblSMDocumentSourceFolder: ' + '(' + CAST(@rowsAffected AS NVARCHAR(50)) + ')'
				END

			-- Document Configuration
			UPDATE tblSMDocumentConfiguration
			SET intScreenId = @intScreenId
			FROM tblSMDocumentConfiguration 
			WHERE intScreenId IN (SELECT intScreenId FROM tblSMScreen WHERE strNamespace = @strNamespace AND intScreenId <> @intScreenId)

			SET @rowsAffected = @@ROWCOUNT
			IF @rowsAffected > 0
				BEGIN 
					PRINT 'Updated tblSMDocumentConfiguration: ' + '(' + CAST(@rowsAffected AS NVARCHAR(50)) + ')'
				END

			-- Screen Report
			UPDATE tblSMScreenReport
			SET intScreenId = @intScreenId
			FROM tblSMScreenReport 
			WHERE intScreenId IN (SELECT intScreenId FROM tblSMScreen WHERE strNamespace = @strNamespace AND intScreenId <> @intScreenId)

			SET @rowsAffected = @@ROWCOUNT
			IF @rowsAffected > 0
				BEGIN 
					PRINT 'Updated tblSMScreenReport: ' + '(' + CAST(@rowsAffected AS NVARCHAR(50)) + ')'
				END

			-- Screen Permission
			UPDATE tblSMUserRoleScreenPermission
			SET intScreenId = @intScreenId
			FROM tblSMUserRoleScreenPermission 
			WHERE intScreenId IN (SELECT intScreenId FROM tblSMScreen WHERE strNamespace = @strNamespace AND intScreenId <> @intScreenId)

			SET @rowsAffected = @@ROWCOUNT
			IF @rowsAffected > 0
				BEGIN 
					PRINT 'Updated tblSMUserRoleScreenPermission: ' + '(' + CAST(@rowsAffected AS NVARCHAR(50)) + ')'
				END

			-- Controls
			UPDATE tblSMControl
			SET intScreenId = @intScreenId
			FROM tblSMControl 
			WHERE intScreenId IN (SELECT intScreenId FROM tblSMScreen WHERE strNamespace = @strNamespace AND intScreenId <> @intScreenId)

			SET @rowsAffected = @@ROWCOUNT
			IF @rowsAffected > 0
				BEGIN 
					PRINT 'Updated tblSMControl: ' + '(' + CAST(@rowsAffected AS NVARCHAR(50)) + ')'
				END

			-- Get all duplicated controls
			INSERT INTO @DuplicateControl (strControlId)
				SELECT strControlId 
				FROM tblSMControl A INNER JOIN tblSMScreen B ON A.intScreenId = B.intScreenId
				WHERE A.intScreenId = @intScreenId
				GROUP BY A.strControlId, B.strNamespace
				HAVING COUNT(*) > 1

			DECLARE @controlCount AS INT = (SELECT COUNT(*) FROM @DuplicateControl)
			PRINT 'Duplicate Controls:' + CAST(@controlCount AS NVARCHAR(50))

			DECLARE @controlCounter AS INT = 1

			WHILE EXISTS(SELECT * FROM @DuplicateControl)
			BEGIN
				SELECT TOP 1 @strControlId = strControlId FROM @DuplicateControl
				PRINT 'Control (' + @strControlId + '): ' + CAST(@controlCounter AS NVARCHAR(50)) + ' of ' + CAST(@controlCount AS NVARCHAR(50)) 

				-- Winner Control Id (This means that other duplicated controls will be deleted)
				DECLARE @intControlId AS INT = (SELECT TOP 1 intControlId FROM tblSMControl WHERE intScreenId = @intScreenId AND strControlId = @strControlId ORDER BY intControlId ASC)
				PRINT 'Winner Control Id: ' + CAST(@intControlId AS NVARCHAR(50))

				-- User Role Control Permission
				UPDATE tblSMUserRoleControlPermission
				SET intControlId = @intControlId
				FROM tblSMUserRoleControlPermission
				WHERE intControlId IN (SELECT intControlId FROM tblSMControl WHERE intScreenId = @intScreenId AND strControlId = @strControlId AND intControlId <> @intControlId)

				SET @rowsAffected = @@ROWCOUNT
				IF @rowsAffected > 0
				BEGIN 
					PRINT 'Updated tblSMUserRoleControlPermission: ' + '(' + CAST(@rowsAffected AS NVARCHAR(50)) + ')'
				END

				-- User Role Control Permission
				UPDATE tblSMUserSecurityControlPermission
				SET intControlId = @intControlId
				FROM tblSMUserSecurityControlPermission
				WHERE intControlId IN (SELECT intControlId FROM tblSMControl WHERE intScreenId = @intScreenId AND strControlId = @strControlId AND intControlId <> @intControlId)

				SET @rowsAffected = @@ROWCOUNT
				IF @rowsAffected > 0
				BEGIN 
					PRINT 'Updated tblSMUserSecurityControlPermission: ' + '(' + CAST(@rowsAffected AS NVARCHAR(50)) + ')'
				END

				SET @controlCounter = @controlCounter + 1

				DELETE FROM tblSMControl WHERE intScreenId = @intScreenId AND strControlId = @strControlId AND strControlId = @strControlId AND intControlId <> @intControlId

				SET @rowsAffected = @@ROWCOUNT
				IF @rowsAffected > 0
				BEGIN 
					PRINT 'Deleted tblSMControl: ' + '(' + CAST(@rowsAffected AS NVARCHAR(50)) + ')'
				END

				DELETE FROM @DuplicateControl WHERE strControlId = @strControlId
			END

			-- Delete duplicated tblSMScreen
			DELETE FROM tblSMScreen WHERE strNamespace = @strNamespace AND intScreenId <> @intScreenId

			SET @rowsAffected = @@ROWCOUNT
			IF @rowsAffected > 0
			BEGIN 
				PRINT 'Deleted tblSMScreen: ' + '(' + @strNamespace + '): ' + CAST(@screenCounter AS NVARCHAR(50)) + ' of ' + CAST(@screenCount AS NVARCHAR(50))
			END

			DELETE FROM @DuplicateScreen WHERE strNamespace = @strNamespace
			SET @screenCounter = @screenCounter + 1
		END
	END

	SET NOCOUNT OFF

	PRINT N'END REMOVE DUPLICATE SCREENS & TRANSACTIONS'
GO
