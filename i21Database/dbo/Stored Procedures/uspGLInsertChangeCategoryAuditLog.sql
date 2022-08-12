CREATE PROCEDURE [dbo].[uspGLInsertChangeCategoryAuditLog]
	@strTransactionId NVARCHAR (20)
AS
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON

	BEGIN TRANSACTION;

	DECLARE 
		@intEntityId INT
		,@intTransactionId INT
		,@intAccountId INT
		,@intAccountCategoryId INT
		,@intNewAccountCategoryId INT
		,@strAccountCategory NVARCHAR(50)
		,@strNewAccountCategory NVARCHAR(50)
		,@ErrorMessage NVARCHAR(MAX)

	SELECT
		@intTransactionId = intTransactionId
		,@intAccountId = intAccountId
		,@intAccountCategoryId = intAccountCategoryId
		,@intNewAccountCategoryId = intNewAccountCategoryId
		,@intEntityId = intEntityId
		,@strAccountCategory = strAccountCategory COLLATE Latin1_General_CI_AS
		,@strNewAccountCategory = strNewAccountCategory COLLATE Latin1_General_CI_AS
	FROM vyuGLChangeAccountCategory WHERE strTransactionId = @strTransactionId

	DECLARE @strCode NVARCHAR(20)

	-- Get Primary Segment Account Code
	SELECT @strCode = AccountSegment.strCode
	FROM [dbo].[tblGLAccountSegment] AccountSegment
	JOIN [dbo].[tblGLAccountSegmentMapping] Mapping
		ON Mapping.intAccountSegmentId = AccountSegment.intAccountSegmentId
	JOIN dbo.tblGLAccountStructure Structure 
		ON Structure.intAccountStructureId = AccountSegment.intAccountStructureId AND Structure.strType = 'Primary'
	WHERE
		Mapping.intAccountId = @intAccountId

	DECLARE @tbl TABLE(
		intRowId INT,
		intAccountId INT,
		intAccountCategoryId INT,
		intAccountSegmentId INT,
		ysnProcessed BIT
	)

	-- Get all affected accounts
	INSERT INTO @tbl
	SELECT
		ROW_NUMBER() OVER(ORDER BY Mapping.intAccountId ASC), Mapping.intAccountId, AccountSegment.intAccountCategoryId, AccountSegment.intAccountSegmentId, 0
	FROM [dbo].[tblGLAccountSegment] AccountSegment
	JOIN [dbo].[tblGLAccountSegmentMapping] Mapping
		ON Mapping.intAccountSegmentId = AccountSegment.intAccountSegmentId
	WHERE AccountSegment.strCode = @strCode

	-- Update category in account segment
	UPDATE AccountSegment
	SET
		intAccountCategoryId = @intNewAccountCategoryId
	FROM [dbo].[tblGLAccountSegment] AccountSegment
	JOIN @tbl Accounts
		ON Accounts.intAccountSegmentId = AccountSegment.intAccountSegmentId
	WHERE AccountSegment.strCode = @strCode

	DECLARE
		@intCurrentRowId INT,
		@intCurrentAccountId INT,
		@intCurrentAccountSegmentId INT,
		@intCurrentAccountCategoryId INT,
		@strCurrentAccountCategory NVARCHAR(50),
		@auditDetails NVARCHAR(MAX)
	
	-- Insert change log for each account
	WHILE EXISTS(SELECT TOP 1 1 FROM @tbl WHERE ysnProcessed = 0)
	BEGIN
		SELECT TOP 1 
			@intCurrentRowId = A.intRowId
			,@intCurrentAccountId = A.intAccountId
			,@intCurrentAccountSegmentId = A.intAccountSegmentId
			,@intCurrentAccountCategoryId = A.intAccountCategoryId
			,@strCurrentAccountCategory = C.strAccountCategory
		FROM @tbl A
		JOIN [dbo].[tblGLAccountCategory] C
			ON C.intAccountCategoryId = A.intAccountCategoryId
		WHERE A.ysnProcessed = 0

		INSERT INTO [dbo].[tblGLChangeAccountCategoryDetail] (
			intTransactionId
			,intAccountId
			,intAccountCategoryId
			,intNewAccountCategoryId
			,intEntityId
			,dtmDate
			,dblGLBalance
		) 
		SELECT
			@intTransactionId
			,@intCurrentAccountId
			,@intCurrentAccountCategoryId
			,@intNewAccountCategoryId
			,@intEntityId
			,GETDATE()
			,ISNULL(BeginningBalance.beginBalance, 0)
		FROM [dbo].[tblGLAccount] A
		OUTER APPLY (
			SELECT beginBalance FROM [dbo].[fnGLGetBeginningBalanceAndUnitTB](A.strAccountId, GETDATE(), -1)
		) BeginningBalance
		WHERE A.intAccountId = @intCurrentAccountId

		UPDATE @tbl set ysnProcessed = 1 WHERE intRowId = @intCurrentRowId

		-- Insert Audit Log
		SET @auditDetails =
			'{
				"action": "Updated"
				,"change": "Updated on"
				,"iconCls": "small-tree-modified"
				,"children": [
					{
						"change": "Account Category"
						,"from": "' + @strCurrentAccountCategory + '"
						,"to": "' + @strNewAccountCategory + '"
						,"leaf": true
						,"iconCls": "small-gear"
					}
				]
			}';

		BEGIN TRY
		EXEC uspSMAuditLog
			@screenName = 'GeneralLedger.view.EditAccount',
			@entityId = @intEntityId,
			@actionType = 'Updated',
			@keyValue = @intCurrentAccountId,
			@details = @auditDetails
		END TRY
		BEGIN CATCH		
			SET @ErrorMessage  = ERROR_MESSAGE()
			RAISERROR(@ErrorMessage, 11, 1)

			IF @@ERROR <> 0	GOTO Post_Rollback;
		END CATCH

	END

	IF @@ERROR <> 0	GOTO Post_Rollback;
	

	-- Update status
	UPDATE [dbo].[tblGLChangeAccountCategory]
	SET ysnChanged = 1
	WHERE strTransactionId = @strTransactionId

	Post_Commit:
		COMMIT TRANSACTION
		GOTO Post_Exit

	Post_Rollback:
		ROLLBACK TRANSACTION	
		GOTO Post_Exit

	Post_Exit:

