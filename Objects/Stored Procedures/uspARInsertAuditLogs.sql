CREATE PROCEDURE [dbo].[uspARInsertAuditLogs]
	@LogEntries AuditLogStagingTable	READONLY
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

BEGIN
	
	--INSERT INTO tblSMAuditLog (
	--	[strActionType],
	--	[strDescription],
	--	[strJsonData],
	--	[strRecordNo],
	--	[strTransactionType],
	--	[intEntityId],
	--	[intConcurrencyId],
	--	[dtmDate]
	--) SELECT 
	--	 [strActionType]		= [strActionType]
	--	,[strDescription]		= [strDescription]
	--	,[strJsonData]			= '{"action":"' + [strActionType] + '","change":"Updated - Record: ' + CAST([intKeyValueId] AS NVARCHAR(50)) + '","iconCls":"' + ISNULL([strActionIcon], 'small-menu-maintenance') + '","children":['
	--								+ 
	--									(CASE WHEN ISNULL([strChangeDescription], '') <> '' 
	--											THEN '{"change":"' + [strChangeDescription] + '","iconCls":"small-menu-maintenance","from":"' + [strFromValue] + '","to":"' + [strToValue] + '","leaf":true}'
	--										  WHEN ISNULL([strDetails], '') <> ''
	--											THEN [strDetails]
	--										  ELSE ''
	--									END) 
	--								+']}'
	--	,[strRecordNo]			= CAST([intKeyValueId] AS NVARCHAR(50))
	--	,[strTransactionType]	= [strScreenName]
	--	,[intEntityId]			= [intEntityId]
	--	,[intConcurrencyId]		= 1
	--	,[dtmDate]				= GETUTCDATE()
	--FROM
	--	@LogEntries
	DECLARE @Logs AS AuditLogStagingTable
	INSERT INTO @Logs
		([strScreenName]
		,[intKeyValueId]
		,[intEntityId]
		,[strActionType]
		,[strDescription]
		,[strActionIcon]
		,[strChangeDescription]
		,[strFromValue]
		,[strToValue]
		,[strDetails])
	SELECT 
		 [strScreenName]
		,[intKeyValueId]
		,[intEntityId]
		,[strActionType]
		,[strDescription]
		,[strActionIcon]
		,[strChangeDescription]
		,[strFromValue]
		,[strToValue]
		,[strDetails]
	FROM @LogEntries

	WHILE EXISTS(SELECT TOP 1 NULL FROM @Logs)
	BEGIN
		DECLARE  @ActionType NVARCHAR(50)
				,@SourceScreen NVARCHAR(100)
				,@KeyValueId NVARCHAR(MAX)
				,@EntityId INT

		SELECT TOP 1 
			 @KeyValueId   =  CAST([intKeyValueId] AS NVARCHAR(MAX))
			,@SourceScreen = [strScreenName]
			,@EntityId     = [intEntityId]
			,@ActionType   = [strActionType]
		FROM @Logs
		ORDER BY intKeyValueId

		EXEC dbo.uspSMAuditLog 
			 @screenName		= @SourceScreen	                    -- Screen Namespace
			,@keyValue			= @KeyValueId						-- Primary Key Value of the Invoice. 
			,@entityId			= @EntityId							-- Entity Id.
			,@actionType		= @ActionType						-- Action Type


		DELETE FROM @Logs WHERE intKeyValueId = @KeyValueId
	END

END