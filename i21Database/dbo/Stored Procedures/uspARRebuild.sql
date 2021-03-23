CREATE PROCEDURE [dbo].[uspARRebuild]
	 @DateFrom	DATE
	,@DateTo	DATE
AS
BEGIN TRY
	BEGIN TRANSACTION 
	IF(OBJECT_ID('tempdb..#tblARRebuildLog') IS NOT NULL)
	BEGIN
		DROP TABLE #tblARRebuildLog
	END

	CREATE TABLE #tblARRebuildLog
	(
		[strIssue]			NVARCHAR (50) COLLATE Latin1_General_CI_AS,
		[dtmDate]			DATE,
		[intTransactionId]	INT,
		[strTransactionId]	NVARCHAR (50) COLLATE Latin1_General_CI_AS,
		[strBatchId]		NVARCHAR (50) COLLATE Latin1_General_CI_AS,
		[ysnAllowRebuild]	BIT,
		[ysnFiscalOpen]		BIT
	)

	INSERT INTO #tblARRebuildLog
	SELECT 
		 [strIssue]
		,[dtmDate]
		,[intTransactionId]
		,[strTransactionId]
		,[strBatchId]
		,[ysnAllowRebuild]
		,[ysnFiscalOpen]
	FROM [dbo].[vyuARSearchRebuild]
	WHERE dtmDate BETWEEN @DateFrom AND @DateTo
	AND [ysnAllowRebuild] = 1
	AND [ysnFiscalOpen] = 1

	--Update GL Details
	UPDATE GL
	SET ysnIsUnposted = 1
	FROM tblGLDetail GL
	INNER JOIN #tblARRebuildLog DFL
	ON GL.strTransactionId = DFL.strTransactionId COLLATE Latin1_General_CI_AS
	AND GL.strBatchId = DFL.strBatchId
	AND strIssue IN ('Invoice and GL batch id mismatch', 'Invoice not yet posted or deleted but has posted GL entry')

	--Update Inventory Transaction
	UPDATE IT
	SET ysnIsUnposted = 1
	FROM tblICInventoryTransaction IT
	INNER JOIN #tblARRebuildLog DFL
	ON IT.strTransactionId = DFL.strTransactionId COLLATE Latin1_General_CI_AS
	AND IT.strBatchId = DFL.strBatchId
	AND strIssue = 'Invoice and inventory batch id mismatch'

	--Log the affected records
	INSERT INTO tblARRebuildLog
	(
		[strIssue]
		,[dtmDate]
		,[intTransactionId]
		,[strTransactionId]
		,[strBatchId]
	)
	SELECT 
		[strIssue]
		,[dtmDate]
		,[intTransactionId]
		,[strTransactionId]
		,[strBatchId]
	FROM #tblARRebuildLog

	IF EXISTS(SELECT TOP 1 1 FROM #tblARRebuildLog WHERE strIssue = 'Invoice and inventory batch id mismatch')
	BEGIN
		EXEC uspICRebuildInventoryValuation
			 @dtmStartDate = @DateFrom
			,@isPeriodic = 1
			,@intUserId = 1
	END

	EXEC uspGLSummaryRecalculate

	COMMIT TRANSACTION 
END TRY
BEGIN CATCH 
	ROLLBACK TRANSACTION 
END CATCH 

RETURN 0
