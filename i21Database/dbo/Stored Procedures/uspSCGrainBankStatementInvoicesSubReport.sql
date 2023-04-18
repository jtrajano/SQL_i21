CREATE PROCEDURE [dbo].[uspSCGrainBankStatementInvoicesSubReport]
	@ENTITY_ID INT = NULL
	,@STORAGE_TYPE INT = NULL
	,@STORAGE_SCHEDULE_ID INT = NULL
	,@ITEM_ID INT = NULL
	,@START_DATE DATETIME = NULL
	,@END_DATE DATETIME = NULL
AS

BEGIN
	IF @ENTITY_ID IS NULL
	BEGIN
		SELECT
		TOP 0 *
		FROM
		vyuSCGrainBankInvoiceTransaction

		RETURN 
	END
	SELECT
	*
	FROM
	vyuSCGrainBankInvoiceTransaction
	WHERE intEntityId = @ENTITY_ID
		AND intStorageTypeId = @STORAGE_TYPE
		AND intStorageScheduleId = @STORAGE_SCHEDULE_ID
		AND intItemId = @ITEM_ID
		AND (dtmTransactionDate >= @START_DATE AND  dtmTransactionDate <= @END_DATE)

END