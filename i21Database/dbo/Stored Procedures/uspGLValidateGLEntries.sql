﻿CREATE PROCEDURE [dbo].[uspGLValidateGLEntries]
	@GLEntriesToValidate RecapTableType READONLY
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

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

-- Failed. Invalid G/L account id found.
IF EXISTS (SELECT TOP 1 1 FROM #FoundErrors WHERE intErrorCode = 50001)
BEGIN 
	RAISERROR(50001, 11, 1)
	GOTO _Exit
END;

-- Debit and credit amounts are not balanced.
IF EXISTS (SELECT TOP 1 1 FROM #FoundErrors WHERE intErrorCode = 50003)
BEGIN 
	RAISERROR(50003, 11, 1)
	GOTO _Exit
END;

-- Unable to find an open fiscal year period to match the transaction date.
IF EXISTS (SELECT TOP 1 1 FROM #FoundErrors WHERE intErrorCode = 50005)
BEGIN 
	RAISERROR(50005, 11, 1)
	GOTO _Exit
END 

-- G/L entries are expected. Cannot continue because it is missing.
IF EXISTS (SELECT TOP 1 1 FROM #FoundErrors WHERE intErrorCode = 50032)
BEGIN 
	RAISERROR(50032, 11, 1)
	GOTO _Exit
END 

-- Unable to find an open fiscal year period to match the transaction date for a particular module .
IF EXISTS(SELECT TOP 1 1 FROM #FoundErrors WHERE intErrorCode = 51189)
BEGIN 
	DECLARE @strModuleName NVARCHAR(50) = (SELECT TOP 1 strModuleName FROM #FoundErrors WHERE intErrorCode = 51189)
	RAISERROR(51189, 11, 1,@strModuleName)
	GOTO _Exit
END 

_Exit: 
IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#FoundErrors')) 
	DROP TABLE #FoundErrors
