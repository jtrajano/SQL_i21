CREATE PROCEDURE [dbo].[uspPATPostIssueStock]
	@intCustomerStockId INT = NULL,
	@ysnPosted BIT = NULL,
	@ysnVoting BIT = NULL,
	@ysnRetired BIT = NULL,
	@intUserId INT = NULL,
	@successfulCount INT = 0 OUTPUT,
	@invalidCount INT = 0 OUTPUT,
	@success BIT = 0 OUTPUT
AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRANSACTION -- START TRANSACTION

DECLARE @dateToday AS DATETIME = GETDATE();
DECLARE @GLEntries AS RecapTableType;
DECLARE @totalRecords INT;
DECLARE @error NVARCHAR(200);

IF (@ysnRetired = 1)
BEGIN
	IF(@ysnPosted = 1)
	BEGIN

	------------------------CREATE GL ENTRIES---------------------
		INSERT INTO @GLEntries
		SELECT * FROM [dbo].[fnPATCreateRetireStockGLEntries](@intCustomerStockId, 0, @intUserId)

	END
	ELSE
	BEGIN
	------------------------REVERSE GL ENTRIES---------------------
		INSERT INTO @GLEntries
		SELECT * FROM [dbo].[fnPATReverseRetireStockGLEntries](@intCustomerStockId, @dateToday, @intUserId)

		UPDATE tblGLDetail SET ysnIsUnposted = 1
		WHERE intTransactionId = @intCustomerStockId 
			AND strModuleName = N'Patronage' AND strTransactionForm = N'Retire Stock'
	END
END
ELSE
BEGIN
	IF(@ysnVoting = 1)
	BEGIN
		IF(@ysnPosted = 1)
		BEGIN

		------------------------CREATE GL ENTRIES---------------------
			INSERT INTO @GLEntries
			SELECT * FROM [dbo].[fnPATCreateIssueStockGLEntries](@intCustomerStockId, @ysnVoting, @intUserId)

		END
		ELSE
		BEGIN

		------------------------REVERSE GL ENTRIES---------------------
			INSERT INTO @GLEntries
			SELECT * FROM [dbo].[fnPATReverseIssueStockGLEntries](@intCustomerStockId, @dateToday, @intUserId)

			UPDATE tblGLDetail SET ysnIsUnposted = 1
			WHERE intTransactionId = @intCustomerStockId 
				AND strModuleName = N'Patronage' AND strTransactionForm = N'Issue Stock'
		END
	END
END
BEGIN TRY
	SELECT * FROM @GLEntries
	EXEC uspGLBookEntries @GLEntries, @ysnPosted
END TRY
BEGIN CATCH
	SET @error = ERROR_MESSAGE()
	RAISERROR(@error, 16, 1);
	GOTO Post_Rollback
END CATCH


------------UPDATE CUSTOMER STOCK TABLE---------------

	UPDATE tblPATCustomerStock SET ysnPosted = @ysnPosted WHERE intCustomerStockId = @intCustomerStockId

---------------------------------------------------------------------------------------------------------------------------------------
IF @@ERROR <> 0	GOTO Post_Rollback;

GOTO Post_Commit;

Post_Commit:
	COMMIT TRANSACTION
	SET @success = 1
	SET @successfulCount = @totalRecords
	
	GOTO Post_Exit

Post_Rollback:
	ROLLBACK TRANSACTION	
	SET @success = 0
	GOTO Post_Exit

Post_Exit:

END