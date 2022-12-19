CREATE PROCEDURE [dbo].[uspGLUpdateAccountCurrency]
	@intEntityId INT = 1,
	@intCurrencyId INT = NULL,
	@Id Id READONLY,
	@strMessage NVARCHAR(MAX) = '' OUTPUT
AS
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON

	BEGIN TRANSACTION;

	DECLARE @ysnNoSelection BIT = 0,
			@dtmNow DATETIME = GETDATE(),
			@auditDetails NVARCHAR(MAX);

	SELECT @ysnNoSelection = CASE WHEN COUNT(1) = 0 THEN 1 ELSE 0 END FROM @Id
	
	BEGIN TRY
		IF (@intCurrencyId IS NULL OR @intCurrencyId = 0)
			SELECT TOP 1 @intCurrencyId = intDefaultCurrencyId FROM tblSMCompanyPreference
	
		DECLARE @tblAccounts TABLE (
			intAccountId INT,
			intOldCurrencyId INT NULL,
			intNewCurrencyId INT NULL,
			ysnProcessed BIT DEFAULT 0 NOT NULL
		)

		IF (@ysnNoSelection = 1)
		BEGIN
			INSERT INTO @tblAccounts
			SELECT intAccountId, intCurrencyID, @intCurrencyId, 0 FROM [dbo].[tblGLAccount] WHERE intCurrencyID IS NULL ORDER BY strAccountId
		END
		ELSE
		BEGIN
			INSERT INTO @tblAccounts
			SELECT Id.intId, A.intCurrencyID, @intCurrencyId, 0 FROM @Id Id
			INNER JOIN [dbo].[tblGLAccount] A ON A.intAccountId = Id.intId
		END
		
		-- Update currency
		UPDATE A SET A.intCurrencyID = @intCurrencyId
		FROM [dbo].[tblGLAccount] A
		JOIN @tblAccounts B ON B.intAccountId = A.intAccountId

		-- Add to logging
		WHILE EXISTS(SELECT TOP 1 1 FROM @tblAccounts WHERE ysnProcessed = 0)
		BEGIN
			DECLARE @intCurrentAccountId INT,
					@strOldCurrency NVARCHAR(40),
					@strNewCurrency NVARCHAR(40)

			SELECT TOP 1 
				@intCurrentAccountId = A.intAccountId
				,@strOldCurrency = ISNULL(OldCurrency.strCurrency, '') COLLATE Latin1_General_CI_AS
				,@strNewCurrency = ISNULL(NewCurrency.strCurrency, '') COLLATE Latin1_General_CI_AS
			FROM @tblAccounts A
			LEFT JOIN [dbo].[tblSMCurrency] OldCurrency ON OldCurrency.intCurrencyID = A.intOldCurrencyId
			LEFT JOIN [dbo].[tblSMCurrency] NewCurrency ON NewCurrency.intCurrencyID = A.intNewCurrencyId
			WHERE ysnProcessed = 0

			INSERT INTO [dbo].[tblGLUpdateCurrencyLog](intAccountId, intEntityId, intOldCurrencyId, intNewCurrencyId, dtmDate)
			SELECT intAccountId, @intEntityId, intOldCurrencyId, intNewCurrencyId, @dtmNow FROM @tblAccounts WHERE intAccountId = @intCurrentAccountId

			-- Insert Audit Log
			SET @auditDetails =
				'{
					"action": "Updated"
					,"change": "Updated on"
					,"iconCls": "small-tree-modified"
					,"children": [
						{
							"change": "Update Category"
							,"from": "' + @strOldCurrency + '"
							,"to": "' + @strNewCurrency + '"
							,"leaf": true
							,"iconCls": "small-gear"
						}
					]
				}';
			EXEC uspSMAuditLog
				@screenName = 'GeneralLedger.view.EditAccount',
				@entityId = @intEntityId,
				@actionType = 'Updated',
				@keyValue = @intCurrentAccountId,
				@details = @auditDetails

			UPDATE @tblAccounts SET ysnProcessed = 1 WHERE intAccountId = @intCurrentAccountId
			SET @strOldCurrency = NULL
			SET @strNewCurrency = NULL
			SET @intCurrentAccountId = NULL
		END

		SET @strMessage = 'success';
		GOTO Post_Commit;
	END TRY
	BEGIN CATCH
		SET @strMessage = @@ERROR;
		GOTO Post_Rollback;
	END CATCH

	Post_Commit:
		COMMIT TRANSACTION
		GOTO Post_Exit

	Post_Rollback:
		ROLLBACK TRANSACTION	
		GOTO Post_Exit

	Post_Exit: