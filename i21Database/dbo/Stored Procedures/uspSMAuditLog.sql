CREATE PROCEDURE [dbo].[uspSMAuditLog]
	@screenName			AS NVARCHAR(100),
	@keyValue			AS NVARCHAR(MAX),
	@entityId			AS INT,
	@actionType			AS NVARCHAR(50),
	@actionIcon			AS NVARCHAR(50) = 'small-menu-maintenance',
	@changeDescription  AS NVARCHAR(255) = '',
	@fromValue			AS NVARCHAR(255) = '',
	@toValue			AS NVARCHAR(255) = '',
	@details			AS NVARCHAR(MAX) = ''
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

DECLARE @intTransactionId INT
DECLARE @intParentAuditId INT
DECLARE @intLogId INT
DECLARE @intKeyValue INT = (SELECT CAST(@keyValue AS INT))

/* Insert Transaction*/

EXEC uspSMInsertTransaction @screenNamespace = @screenName, @intKeyValue = @intKeyValue, @output = @intTransactionId OUTPUT

/* Insert Log */ 

INSERT INTO tblSMLog (strType, dtmDate, intEntityId, intTransactionId, intConcurrencyId) 
VALUES('Audit', GETUTCDATE(), @entityId, @intTransactionId, 1)
SET @intLogId = SCOPE_IDENTITY()

/* Insert Audit Entries */

IF (ISNULL(@details, '') <> '' )
BEGIN
	DECLARE @tblSMAudit AuditLogDetail
	INSERT INTO @tblSMAudit SELECT * FROM fnSMGetAuditsFromDetails(@details)

	INSERT INTO tblSMAudit (intLogId, intKeyValue, strAction, strChange, intConcurrencyId)
	SELECT @intLogId, intKeyValue, @actionType, dbo.fnSMGetParentAuditChangeDescription(strChange, @actionType, intKeyValue), 1 
	FROM @tblSMAudit WHERE ysnParent = 1

	SET @intParentAuditId = SCOPE_IDENTITY()

	INSERT INTO tblSMAudit (intLogId, intKeyValue, strAction, strChange, strFrom, strTo, strAlias, ysnField, ysnHidden, intParentAuditId, intConcurrencyId)
	SELECT @intLogId, intKeyValue, NULL, strChange, strFrom, strTo, strAlias, ysnField, ysnHidden, @intParentAuditId, 1 
	FROM @tblSMAudit WHERE ysnParent IS NULL OR ysnParent = 0
END
ELSE 
BEGIN
	INSERT INTO tblSMAudit (intLogId, intKeyValue, strAction, strChange, intConcurrencyId)
	VALUES (@intLogId, @intKeyValue, @actionType, dbo.fnSMGetParentAuditChangeDescription(NULL, @actionType, @intKeyValue), 1)

	SET @intParentAuditId = SCOPE_IDENTITY()

	IF (ISNULL(@changeDescription, '') <> '')
	BEGIN
		INSERT INTO tblSMAudit (intLogId, intKeyValue, strChange, strFrom, strTo, intParentAuditId, intConcurrencyId)
		VALUES (@intLogId, @intKeyValue, @changeDescription, @fromValue, @toValue, @intParentAuditId, 1)
	END
END

GO