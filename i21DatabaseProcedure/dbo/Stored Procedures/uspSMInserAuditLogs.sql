CREATE PROCEDURE [dbo].[uspSMInsertAuditLogs]
	@LogEntries AuditLogStagingTable	READONLY
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

BEGIN
	
	INSERT INTO tblSMAuditLog (
		[strActionType],
		[strDescription],
		[strJsonData],
		[strRecordNo],
		[strTransactionType],
		[intEntityId],
		[intConcurrencyId],
		[dtmDate]
	) SELECT 
		 [strActionType]		= [strActionType]
		,[strDescription]		= [strDescription]
		,[strJsonData]			= '{"action":"' + [strActionType] + '","change":"Updated - Record: 1158","iconCls":"' + ISNULL([strActionIcon], 'small-menu-maintenance') + '","children":['
									+ 
										(CASE WHEN ISNULL([strChangeDescription], '') <> '' 
												THEN '{"change":"' + [strChangeDescription] + '","iconCls":"small-menu-maintenance","from":"' + [strFromValue] + '","to":"' + [strToValue] + '","leaf":true}'
											  WHEN ISNULL([strDetails], '') <> ''
												THEN [strDetails]
											  ELSE ''
										END) 
									+']}'
		,[strRecordNo]			= CAST([intKeyValueId] AS NVARCHAR(50))
		,[strTransactionType]	= [strScreenName]
		,[intEntityId]			= [intEntityId]
		,[intConcurrencyId]		= 1
		,[dtmDate]				= GETUTCDATE()
	FROM
		@LogEntries

END