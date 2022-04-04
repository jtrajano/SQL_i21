CREATE PROCEDURE [dbo].[uspSMSingleAuditLog]  
 @screenName		NVARCHAR(100),  
 @recordId			INT,  
 @entityId			INT,
 @AuditLogParam		SingleAuditLogParam READONLY
AS  

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
  
DECLARE @intTransactionId INT  
DECLARE @intParentAuditId INT  
DECLARE @intLogId INT  
DECLARE @intRecordId INT = (SELECT CAST(@recordId AS INT))  
  
IF EXISTS (SELECT 1 FROM @AuditLogParam)
BEGIN  
	EXEC uspSMInsertTransaction @screenNamespace = @screenName, @intKeyValue = @intRecordId, @output = @intTransactionId OUTPUT  
  
	INSERT INTO tblSMLog (strType, dtmDate, intEntityId, intTransactionId, intConcurrencyId)   
	VALUES('Audit', GETUTCDATE(), @entityId, @intTransactionId, 1)  
	SET @intLogId = SCOPE_IDENTITY()  
  
	DECLARE @id INT
	DECLARE @keyValue INT
	DECLARE @action NVARCHAR(MAX)
	DECLARE @change NVARCHAR(MAX)
	DECLARE @from NVARCHAR(MAX)
	DECLARE @to NVARCHAR(MAX)
	DECLARE @alias NVARCHAR(MAX)
	DECLARE @field BIT
	DECLARE @hidden BIT
	DECLARE @parentId INT
	DECLARE @newAuditId INT
	DECLARE @tmpSMAuditIds AS TABLE (
		[intAuditId] INT,
		[intId] INT
	)

	DECLARE @newSingleAuditLogParam SingleAuditLogParam
	INSERT INTO @newSingleAuditLogParam
	SELECT * FROM @AuditLogParam

	WHILE EXISTS(SELECT * FROM @newSingleAuditLogParam)
	BEGIN
		SELECT TOP 1 
				@id = [Id],
				@keyValue = CASE WHEN ISNULL([KeyValue], 0) <> 0 THEN [KeyValue] ELSE @intRecordId END,
				@action = [Action],
				@change = [Change],
				@from = [From],
				@to = [To],
				@alias = [Alias],
				@field = [Field],
				@hidden = [Hidden],
				@parentId = [ParentId]
		FROM @newSingleAuditLogParam

		INSERT INTO dbo.tblSMAudit (intLogId, intKeyValue, strAction, strChange, strFrom, strTo, strAlias, ysnField, ysnHidden, intParentAuditId, intConcurrencyId)
		VALUES (@intLogId, @keyValue, @action, @change, @from, @to, @alias, @field, @hidden, (SELECT [intAuditId] FROM @tmpSMAuditIds WHERE [intId] = @parentId), 1)

		SET @newAuditId = SCOPE_IDENTITY()

		INSERT INTO @tmpSMAuditIds ([intAuditId], [intId])
		VALUES (@newAuditId, @id)

		DELETE FROM @newSingleAuditLogParam 
		WHERE Id = @id
	END
END
GO