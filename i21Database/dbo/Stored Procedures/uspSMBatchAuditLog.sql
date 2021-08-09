--=====================================================================================================================================
-- 	CREATE THE STORED PROCEDURE 
---------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[uspSMBatchAuditLog]
	@AuditLogParam	BatchAuditLogParam READONLY,
	@EntityId INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

--=====================================================================================================================================
-- 	TABLE DECLARATION
---------------------------------------------------------------------------------------------------------------------------------------

DECLARE @tblSMAudit TABLE (
	intLogId			INT,
	intAuditId			INT,
	strAction			NVARCHAR(50),
	strChange			NVARCHAR(255),
	strKeyValue			NVARCHAR(255),
	strFrom				NVARCHAR(MAX),
	strTo				NVARCHAR(MAX)
)

--=====================================================================================================================================
-- 	INSERT TO TRANSACTION TABLES THAT ARE NOT YET EXISTING
---------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO tblSMTransaction (intScreenId, intRecordId, intConcurrencyId)
SELECT B.intScreenId, A.Id, 1 
FROM @AuditLogParam A 
	INNER JOIN tblSMScreen B ON A.[Namespace] COLLATE Latin1_General_CI_AS = B.strNamespace
	LEFT JOIN tblSMTransaction C ON B.intScreenId = C.intScreenId AND C.intRecordId = A.Id
WHERE ISNULL(C.intTransactionId, 0) = 0

--=====================================================================================================================================
-- INSERT to tblSMLog and tblSMAudit for entries that were passed
---------------------------------------------------------------------------------------------------------------------------------------
MERGE INTO tblSMLog USING (
	SELECT 
		A.[Id],
		A.[Action],
		A.[From],
		A.[To],
		C.[intTransactionId], 
		GETUTCDATE(),
		@EntityId				
	FROM @AuditLogParam A 
		INNER JOIN tblSMScreen B ON A.[Namespace] COLLATE Latin1_General_CI_AS = B.strNamespace
		INNER JOIN tblSMTransaction C ON B.intScreenId = C.intScreenId AND C.intRecordId = A.Id
) AS AuditLogParam (intId, strActionType, strFrom, strTo, intTransactionId, dtmDate, intEntityId) ON 1 = 0
WHEN NOT MATCHED THEN
INSERT (strType, dtmDate, intEntityId, intTransactionId, intConcurrencyId)
VALUES ('Audit', AuditLogParam.dtmDate, AuditLogParam.intEntityId, AuditLogParam.intTransactionId, 1)
OUTPUT inserted.intLogId, AuditLogParam.strActionType, AuditLogParam.intId, AuditLogParam.strFrom, AuditLogParam.strTo
INTO @tblSMAudit(intLogId, strAction, strKeyValue, strFrom, strTo); 

INSERT INTO tblSMAudit (intLogId, strAction, strFrom, strTo, intConcurrencyId)
SELECT intLogId, strAction, strFrom, strTo, 1 FROM @tblSMAudit

GO