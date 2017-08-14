CREATE PROCEDURE [dbo].[uspGRUpdateGrainOpenBalanceByFIFOBatchEntry]
	@Invoices [dbo].[InvoicePostingTable] Readonly
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @strOptionType NVARCHAR(30)
	DECLARE @strSourceType NVARCHAR(30)
	DECLARE @intEntityId INT
	DECLARE @intItemId INT
	DECLARE @intStorageTypeId INT
	DECLARE @dblUnitsConsumed NUMERIC(24, 10) = 0
	DECLARE @IntSourceKey INT
	DECLARE @intUserId INT

	SELECT @IntSourceKey = MIN(intInvoiceId)
	FROM @Invoices

	WHILE @IntSourceKey > 0
	BEGIN
		SET @strOptionType = NULL
		SET @strSourceType = NULL
		SET @intEntityId = NULL
		SET @intItemId = NULL
		SET @intStorageTypeId = NULL
		SET @dblUnitsConsumed = NULL
		SET @intUserId = NULL

		SELECT 
			 @strOptionType = strOptionType
			,@strSourceType = strSourceType
			,@intEntityId = intEntityId
			,@intItemId = intItemId
			,@intStorageTypeId = intStorageScheduleTypeId
			,@dblUnitsConsumed = dblQuantity
			,@intUserId = intUserId
		FROM @Invoices
		WHERE intInvoiceId = @IntSourceKey

		EXEC uspGRUpdateGrainOpenBalanceByFIFO 
			 @strOptionType
			,@strSourceType
			,@intEntityId
			,@intItemId
			,@intStorageTypeId
			,@dblUnitsConsumed
			,@IntSourceKey
			,@intUserId

		SELECT @IntSourceKey = MIN(intInvoiceId)
		FROM @Invoices
		WHERE intInvoiceId > @IntSourceKey
	END

END TRY

BEGIN CATCH
	IF XACT_STATE() != 0 AND @@TRANCOUNT > 0
		ROLLBACK TRANSACTION
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH

