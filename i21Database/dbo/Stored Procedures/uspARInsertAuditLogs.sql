CREATE PROCEDURE [dbo].[uspARInsertAuditLogs]
	  @LogEntries AuditLogStagingTable	READONLY
	, @intUserId						INT = 1
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

BEGIN	
	DECLARE @auditLog AS BatchAuditLogParam

	INSERT INTO @auditLog (
		  [Id]
		, [Namespace]
		, [Action]
		, [Description]
		, [From]
		, [To]
		, [EntityId]
	)
	SELECT [Id]				= [intKeyValueId]
		, [Namespace]		= [strScreenName]
		, [Action]			= [strActionType]
		, [Description]		= [strDescription]
		, [From]			= [strFromValue]
		, [To]				= [strToValue]
		, [EntityId]		= [intEntityId]
	FROM @LogEntries

	IF EXISTS (SELECT TOP 1 NULL FROM @auditLog)
		EXEC dbo.uspSMBatchAuditLog @AuditLogParam 	= @auditLog
								  , @EntityId		= @intUserId
END