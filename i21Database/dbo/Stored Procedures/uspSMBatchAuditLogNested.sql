--=====================================================================================================================================
-- 	CREATE THE STORED PROCEDURE 
---------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[uspSMBatchAuditLogNested]
	@strScreenName		NVARCHAR(255),
	@intRecordId		INT,
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
	DECLARE @ysnWithDuplicateId	TINYINT = 0
	DECLARE @ysnParentIdNotExists	TINYINT = 0
	DECLARE @insertedPKTable TABLE (intId INT,	tempKey INT)
	--=====================================================================================================================================


	IF @transCount = 0 BEGIN TRANSACTION
	--=====================================================================================================================================
	-- 	INSERT TO TRANSACTION TABLES THAT ARE NOT YET EXISTING
	---------------------------------------------------------------------------------------------------------------------------------------
		EXEC uspSMInsertTransaction @screenNamespace = @strScreenName, @intKeyValue = @intRecordId, @output = @intTransactionId OUTPUT  
  
		INSERT INTO tblSMLog (strType, dtmDate, intEntityId, intTransactionId, intConcurrencyId)   
		VALUES('Audit', GETUTCDATE(), @intEntityId, @intTransactionId, 1)  

		SET @intLogId = SCOPE_IDENTITY()  
		---------------------------------------------------------------------------------------------------------------------------------------
		-- Validations
		---------------------------------------------------------------------------------------------------------------------------------------
		SELECT	TOP 1 @ysnWithDuplicateId = COUNT(Id)
		FROM	@tblAuditLogParam 
		group by Id
		having count(Id) > 1

		select	@ysnParentIdNotExists = COUNT(Id)
		from	@tblAuditLogParam
		WHERE	ParentId NOT IN (SELECT Id FROM @tblAuditLogParam)


		IF ISNULL(@ysnWithDuplicateId, 0) = 0 AND @ysnParentIdNotExists = 0
		BEGIN

			--=====================================================================================================================================
			-- INSERT tblSMAudit data
			---------------------------------------------------------------------------------------------------------------------------------------

			INSERT INTO dbo.tblSMAudit (intLogId, intKeyValue, strAction, strChange, strFrom, strTo,  
										intParentAuditId, intConcurrencyId)
			OUTPUT		INSERTED.intAuditId, INSERTED.intKeyValue INTO @insertedPKTable
			SELECT		@intLogId, [Id], [Action], [Description], [From], [To], [ParentId], 1
			FROM		@tblAuditLogParam

			--=====================================================================================================================================
			-- Update Parent Id values with new audit Id inserted
			---------------------------------------------------------------------------------------------------------------------------------------
			UPDATE		a
			SET			a.intParentAuditId = b.intId,
						a.intKeyValue = @intRecordId
			FROM		tblSMAudit AS a
						INNER JOIN @insertedPKTable AS b ON
						a.intParentAuditId = b.tempKey AND
						a.intAuditId IN(select intId FROM @insertedPKTable)

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