CREATE PROCEDURE uspGLInsertAuditLog
(
	@ysnPost BIT,
	@GLEntries RecapTableType READONLY
)
AS

DECLARE @tbl TABLE (intTransactionId NVARCHAR(30),  intEntityId INT)
DECLARE @intTransactionId NVARCHAR(30), @intEntityId INT
DECLARE @strActionTyoe NVARCHAR(10)
SELECT @strActionTyoe = CASE WHEN @ysnPost =1 THEN 'Posted' ELSE 'Unposted' END
INSERT INTO @tbl SELECT CONVERT(NVARCHAR(30), intTransactionId), intEntityId FROM @GLEntries WHERE strModuleName = 'General Ledger'
WHILE EXISTS (SELECT TOP 1 1 FROM @tbl)
BEGIN
	SELECT TOP 1  @intTransactionId = intTransactionId, @intEntityId = intEntityId FROM @tbl
	EXEC uspSMAuditLog
        @keyValue = @intTransactionId,                                          -- Primary Key Value
        @screenName = 'GeneralLedger.view.GeneralJournal',            -- Screen Namespace
        @entityId = @intEntityId,                                              -- Entity Id.
        @actionType = @strActionTyoe                                 -- Action Type (Processed, Posted, Unposted and etc.
	DELETE FROM @tbl WHERE intTransactionId = @intTransactionId
END
