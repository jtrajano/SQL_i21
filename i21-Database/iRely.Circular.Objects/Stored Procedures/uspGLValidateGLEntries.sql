CREATE PROCEDURE [dbo].[uspGLValidateGLEntries]
	@GLEntriesToValidate RecapTableType READONLY,
	@XACT_ABORT_ON BIT = 1
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
IF (@XACT_ABORT_ON = 1) SET XACT_ABORT ON -- DEFAULT IS OFF

IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#FoundErrors'))
	DROP TABLE #FoundErrors

CREATE TABLE #FoundErrors (
	strTransactionId NVARCHAR(40)
	,strText NVARCHAR(MAX)
	,intErrorCode INT
	,strModuleName NVARCHAR(50)
);

INSERT INTO #FoundErrors
SELECT	Errors.strTransactionId
		,Errors.strText
		,Errors.intErrorCode
		,Errors.strModuleName
FROM	dbo.fnGetGLEntriesErrors(@GLEntriesToValidate) Errors;

DECLARE @intErrorCode INT = 0
IF EXISTS (SELECT TOP 1 1 FROM #FoundErrors)
BEGIN
	DECLARE @strMessage NVARCHAR(100)
	SELECT TOP 1 @strMessage = strText , @intErrorCode = intErrorCode FROM #FoundErrors
	RAISERROR(@strMessage, 11, 1)
END;

IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#FoundErrors')) 
	DROP TABLE #FoundErrors
RETURN @intErrorCode