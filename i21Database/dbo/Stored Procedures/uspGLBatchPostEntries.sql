CREATE PROCEDURE [dbo].[uspGLBatchPostEntries]
	@GLEntries RecapTableType READONLY
	,@strBatchId AS NVARCHAR(100)	= ''
	,@intEntityId AS INT
	,@ysnPost AS BIT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

--=====================================================================================================================================
-- 	VALIDATION
------------------------------------------------------------------------------------------------------------------------------------
BEGIN 
	DELETE tblGLPostResult WHERE dtmDate < DATEADD(day, -1, GETDATE())
	DECLARE @GLEntriesNoError RecapTableType;
	DECLARE  @FoundErrors TABLE (
		strTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS
		,strText NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
		,intErrorCode INT
	)
	INSERT INTO @FoundErrors
	SELECT	Errors.strTransactionId
		,Errors.strText
		,Errors.intErrorCode
	FROM dbo.fnGetGLEntriesErrors(@GLEntries, @ysnPost) Errors

	INSERT INTO tblGLPostResult (strBatchId,intTransactionId,strTransactionId,strDescription,dtmDate,intEntityId,strTransactionType)
			SELECT DISTINCT @strBatchId AS strBatchId,A.intTransactionId AS intTransactionId,A.strTransactionId as strTransactionId, B.strText AS strDescription,
			GETDATE() AS dtmDate,@intEntityId,A.strTransactionType
			FROM @GLEntries A  JOIN @FoundErrors B ON A.strTransactionId = B.strTransactionId


	INSERT INTO @GLEntriesNoError
	SELECT * FROM @GLEntries 
	WHERE strTransactionId 
	NOT IN (SELECT strTransactionId FROM @FoundErrors)

	EXEC uspGLBookEntries @GLEntriesNoError, @ysnPost, 1
	
END ;