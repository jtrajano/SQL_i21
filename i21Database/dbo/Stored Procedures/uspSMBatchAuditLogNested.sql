--=====================================================================================================================================
-- 	CREATE THE STORED PROCEDURE 
---------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[uspSMBatchAuditLogNested]
	@strScreenName		NVARCHAR(255),
	@intEntityId		INT,
	@tblAuditLogParam	BatchAuditLogParamNested READONLY
AS 

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

BEGIN TRY
	--=====================================================================================================================================
	-- 	VARIABLE DECLARATION
	---------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @transCount INT = @@TRANCOUNT
	DECLARE @error NVARCHAR(255)
	DECLARE @intTransactionId	INT  
	DECLARE @intLogId			INT  
	DECLARE @ysnWithDuplicateId	INT = 0
	DECLARE @ysnParentIdNotExists	INT = 0
	DECLARE @insertedPKTable TABLE (intId INT,	intLogId INT, tempKey INT)
	DECLARE @insertedSMLogHeader TABLE (intLogId INT,	intTransactionId INT)
	DECLARE @intRecordId INT

	--=====================================================================================================================================


	IF @transCount = 0 BEGIN TRANSACTION
	--=====================================================================================================================================
	-- 	INSERT TO TRANSACTION TABLES THAT ARE NOT YET EXISTING
	---------------------------------------------------------------------------------------------------------------------------------------
		
	INSERT INTO tblSMTransaction (intScreenId, intRecordId, intConcurrencyId)
	SELECT	b.intScreenId, a.RecordId, 1 
	FROM	@tblAuditLogParam			AS a
			LEFT JOIN tblSMTransaction	AS b 
			ON b.intRecordId = a.RecordId
			LEFT JOIN tblSMScreen		AS c ON
			b.intScreenId = c.intScreenId
	WHERE	ISNULL(b.intTransactionId, 0) = 0 AND
			c.strScreenName = @strScreenName
  
	---------------------------------------------------------------------------------------------------------------------------------------
	-- Validations
	---------------------------------------------------------------------------------------------------------------------------------------
	SELECT	TOP 1 @ysnWithDuplicateId = COUNT(Id)
	FROM	@tblAuditLogParam
	group by RecordId, Id
	having count(Id) > 1

		
	select	@ysnParentIdNotExists = COUNT(*)
	from	@tblAuditLogParam AS childTable
			LEFT JOIN @tblAuditLogParam AS rootTable ON
			-- child.intParentAuditId = root.intAuditId
			childTable.ParentId = rootTable.Id
	WHERE	childTable.ParentId IS NOT NULL AND
			rootTable.Id is null



	IF ISNULL(@ysnWithDuplicateId, 0) = 0 AND @ysnParentIdNotExists = 0
	BEGIN

		----=====================================================================================================================================
		---- INSERT tblSMLog data
		-----------------------------------------------------------------------------------------------------------------------------------------
		INSERT INTO tblSMLog (strType, dtmDate, intEntityId, intTransactionId, intConcurrencyId)   
		OUTPUT		INSERTED.intLogId, INSERTED.intTransactionId INTO @insertedSMLogHeader
		SELECT	'Audit', GETUTCDATE(), @intEntityId, b.intTransactionId, 1
		FROM	(select distinct RecordId from @tblAuditLogParam) AS a
				INNER JOIN tblSMTransaction AS b ON
				a.RecordId = b.intRecordId
				INNER JOIN tblSMScreen AS c ON
				b.intScreenId = c.intScreenId
		WHERE	c.strNamespace = @strScreenName
			
		----=====================================================================================================================================
		---- INSERT tblSMAudit data
		-----------------------------------------------------------------------------------------------------------------------------------------

		INSERT INTO tblSMAudit (intLogId, intKeyValue, strAction, strFrom, strTo, intParentAuditId, intConcurrencyId)
		OUTPUT		INSERTED.intAuditId, INSERTED.intLogId, INSERTED.intKeyValue INTO @insertedPKTable
		SELECT		c.intLogId,
					a.[Id],
					a.[Action],
					a.[From],
					a.[To],
					a.[ParentId],
					1
			FROM	@tblAuditLogParam AS a
					inner join tblSMTransaction AS b ON
					a.RecordId = b.intRecordId
					INNER JOIN @insertedSMLogHeader AS c ON
					b.intTransactionId = c.intTransactionId

		--=====================================================================================================================================
		-- Update Parent Id values with new audit Id inserted
		---------------------------------------------------------------------------------------------------------------------------------------
		UPDATE		a
		SET			a.intParentAuditId = b.intId,
					a.intKeyValue = NULL
		FROM		tblSMAudit AS a
						
					INNER JOIN @insertedPKTable as b ON
					a.intLogId = b.intLogId

		WHERE		a.intAuditId IN(select intId FROM @insertedPKTable)  AND
					a.intParentAuditId = b.tempKey

	END
	ELSE
	BEGIN

		SET @error =  'Error encountered. Please make sure Ids are unique and parent Id provided exists';
		RAISERROR(@error, 16, 1);
		RETURN;
		
	END
	IF @transCount = 0 COMMIT TRANSACTION

END TRY
BEGIN CATCH
	DECLARE @ErrorSeverity INT,
			@ErrorNumber   INT,
			@ErrorMessage nvarchar(4000),
			@ErrorState INT,
			@ErrorLine  INT,
			@ErrorProc nvarchar(200);

	-- Grab error information from SQL functions
	SET @ErrorSeverity = ERROR_SEVERITY()
	SET @ErrorNumber   = ERROR_NUMBER()
	SET @ErrorMessage  = ERROR_MESSAGE()
	SET @ErrorState    = ERROR_STATE()
	SET @ErrorLine     = ERROR_LINE()

	IF @transCount = 0 AND XACT_STATE() <> 0 ROLLBACK TRANSACTION

	SET @error = @ErrorMessage;
	RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
END CATCH

GO