CREATE PROCEDURE [dbo].[uspPATProcessVoid]
	@stockIds NVARCHAR(MAX) = '',
	@intUserId INT,
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

BEGIN TRANSACTION

	DECLARE @tmpTransacions TABLE (
		[intTransactionId] [int] PRIMARY KEY,
		UNIQUE (intTransactionId)
	);
	DECLARE @GLEntries AS RecapTableType;
	DECLARE @totalRecords INT = 0;
	DECLARE @error NVARCHAR(MAX);
	DECLARE @batchId NVARCHAR(40);

	INSERT INTO @tmpTransacions SELECT [intID] AS intTransactionId FROM [dbo].fnGetRowsFromDelimitedValues(@stockIds)
	
	IF(@batchId IS NULL)
		EXEC uspSMGetStartingNumber 3, @batchId OUT

	INSERT INTO @GLEntries
	SELECT * FROM [dbo].[fnPATCreateRetireStockGLEntries](@stockIds, 1, @intUserId, @batchId)

	BEGIN TRY
		SELECT * FROM @GLEntries
		EXEC uspGLBookEntries @GLEntries, 1
	END TRY
	BEGIN CATCH
		SET @error = ERROR_MESSAGE()
		RAISERROR(@error, 16, 1);
		GOTO Post_Rollback
	END CATCH

	UPDATE tblPATCustomerStock
		SET strActivityStatus = 'Open',
			dtmRetireDate = null,
			strCheckNumber = null,
			dtmCheckDate = null,
			dblCheckAmount = null
		WHERE intCustomerStockId IN (SELECT [intTransactionId] FROM @tmpTransacions)

	SELECT @totalRecords = COUNT([intTransactionId]) FROM @tmpTransacions

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
Post_Exit:
	
END