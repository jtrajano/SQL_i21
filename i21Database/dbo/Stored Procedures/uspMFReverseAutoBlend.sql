CREATE PROCEDURE [dbo].[uspMFReverseAutoBlend] @intSalesOrderDetailId INT = 0
	,@intInvoiceDetailId INT = 0
	,@intLoadDistributionDetailId INT = 0
	,@intUserId INT
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intWorkOrderId INT
	DECLARE @strBatchId NVARCHAR(40)
	DECLARE @strWorkOrderNo NVARCHAR(50)
	DECLARE @STARTING_NUMBER_BATCH AS INT = 3
	DECLARE @GLEntries AS RecapTableType
	DECLARE @strOrderType NVARCHAR(50)
	DECLARE @intBatchId INT
	DECLARE @tblWO AS TABLE (intWorkOrderId INT)

	IF (
			ISNULL(@intSalesOrderDetailId, 0) > 0
			AND ISNULL(@intInvoiceDetailId, 0) > 0
			AND ISNULL(@intLoadDistributionDetailId, 0) > 0
			)
		OR (
			ISNULL(@intSalesOrderDetailId, 0) = 0
			AND ISNULL(@intInvoiceDetailId, 0) = 0
			AND ISNULL(@intLoadDistributionDetailId, 0) = 0
			)
		RAISERROR (
				'Supply either Sales Order Detail Id or Invoice Detail Id or Load Distribution Detail Id.'
				,16
				,1
				)

	IF ISNULL(@intSalesOrderDetailId, 0) > 0
		SET @strOrderType = 'SALES ORDER'

	IF ISNULL(@intInvoiceDetailId, 0) > 0
		SET @strOrderType = 'INVOICE'

	IF ISNULL(@intLoadDistributionDetailId, 0) > 0
		SET @strOrderType = 'LOAD DISTRIBUTION'

	IF @strOrderType = 'SALES ORDER'
	BEGIN
		IF ISNULL(@intSalesOrderDetailId, 0) = 0
			OR NOT EXISTS (
				SELECT 1
				FROM tblSOSalesOrderDetail
				WHERE intSalesOrderDetailId = ISNULL(@intSalesOrderDetailId, 0)
				)
			RAISERROR (
					'Sales Order Detail does not exist.'
					,16
					,1
					)

		IF NOT EXISTS (
				SELECT 1
				FROM tblMFWorkOrder
				WHERE intSalesOrderLineItemId = @intSalesOrderDetailId
				)
			RAISERROR (
					'No blends produced using the Sales Order Detail.'
					,16
					,1
					)

		IF NOT EXISTS (
				SELECT 1
				FROM tblMFWorkOrderProducedLot
				WHERE intWorkOrderId IN (
						SELECT intWorkOrderId
						FROM tblMFWorkOrder
						WHERE intSalesOrderLineItemId = @intSalesOrderDetailId
						)
					AND ISNULL(ysnProductionReversed, 0) = 0
				)
			RAISERROR (
					'Sales Order Line is already reversed.'
					,16
					,1
					)
	END

	IF @strOrderType = 'INVOICE'
	BEGIN
		IF ISNULL(@intInvoiceDetailId, 0) = 0
			OR NOT EXISTS (
				SELECT 1
				FROM tblARInvoiceDetail
				WHERE intInvoiceDetailId = ISNULL(@intInvoiceDetailId, 0)
				)
			RAISERROR (
					'Invoice Detail does not exist.'
					,16
					,1
					)

		IF NOT EXISTS (
				SELECT 1
				FROM tblMFWorkOrder
				WHERE intInvoiceDetailId = @intInvoiceDetailId
				)
			RAISERROR (
					'No blends produced using the Invoice Detail.'
					,16
					,1
					)

		IF NOT EXISTS (
				SELECT 1
				FROM tblMFWorkOrderProducedLot
				WHERE intWorkOrderId IN (
						SELECT intWorkOrderId
						FROM tblMFWorkOrder
						WHERE intInvoiceDetailId = @intInvoiceDetailId
						)
					AND ISNULL(ysnProductionReversed, 0) = 0
				)
			RAISERROR (
					'Invoice Line is already reversed.'
					,16
					,1
					)
	END

	IF @strOrderType = 'LOAD DISTRIBUTION'
	BEGIN
		IF ISNULL(@intLoadDistributionDetailId, 0) = 0
			OR NOT EXISTS (
				SELECT 1
				FROM tblTRLoadDistributionDetail
				WHERE intLoadDistributionDetailId = ISNULL(@intLoadDistributionDetailId, 0)
				)
			RAISERROR (
					'Load Distribution Detail does not exist.'
					,16
					,1
					)

		IF NOT EXISTS (
				SELECT 1
				FROM tblMFWorkOrder
				WHERE intLoadDistributionDetailId = @intLoadDistributionDetailId
				)
			RAISERROR (
					'No blends produced using the Load Distribution Detail.'
					,16
					,1
					)

		IF (
				SELECT COUNT(1)
				FROM tblMFWorkOrderConsumedLot wcl
				JOIN tblMFWorkOrder w ON wcl.intWorkOrderId = w.intWorkOrderId
				WHERE intLoadDistributionDetailId = @intLoadDistributionDetailId
				) = 0
			OR (
				SELECT COUNT(1)
				FROM tblMFWorkOrderProducedLot wpl
				JOIN tblMFWorkOrder w ON wpl.intWorkOrderId = w.intWorkOrderId
				WHERE intLoadDistributionDetailId = @intLoadDistributionDetailId
				) = 0
			RAISERROR (
					'There is no Blend Sheet transaction available to unpost.'
					,16
					,1
					)

		IF NOT EXISTS (
				SELECT 1
				FROM tblMFWorkOrderProducedLot
				WHERE intWorkOrderId IN (
						SELECT intWorkOrderId
						FROM tblMFWorkOrder
						WHERE intLoadDistributionDetailId = @intLoadDistributionDetailId
						)
					AND ISNULL(ysnProductionReversed, 0) = 0
				)
		BEGIN
			RETURN
		END
	END

	IF @strOrderType = 'SALES ORDER'
		INSERT INTO @tblWO (intWorkOrderId)
		SELECT intWorkOrderId
		FROM tblMFWorkOrderProducedLot
		WHERE intWorkOrderId IN (
				SELECT intWorkOrderId
				FROM tblMFWorkOrder
				WHERE intSalesOrderLineItemId = @intSalesOrderDetailId
				)
			AND ISNULL(ysnProductionReversed, 0) = 0

	IF @strOrderType = 'INVOICE'
		INSERT INTO @tblWO (intWorkOrderId)
		SELECT intWorkOrderId
		FROM tblMFWorkOrderProducedLot
		WHERE intWorkOrderId IN (
				SELECT intWorkOrderId
				FROM tblMFWorkOrder
				WHERE intInvoiceDetailId = @intInvoiceDetailId
				)
			AND ISNULL(ysnProductionReversed, 0) = 0

	IF @strOrderType = 'LOAD DISTRIBUTION'
		INSERT INTO @tblWO (intWorkOrderId)
		SELECT intWorkOrderId
		FROM tblMFWorkOrderProducedLot
		WHERE intWorkOrderId IN (
				SELECT intWorkOrderId
				FROM tblMFWorkOrder
				WHERE intLoadDistributionDetailId = @intLoadDistributionDetailId
				)
			AND ISNULL(ysnProductionReversed, 0) = 0

	SELECT @intWorkOrderId = MIN(intWorkOrderId)
	FROM @tblWO

	BEGIN TRANSACTION

	WHILE @intWorkOrderId IS NOT NULL
	BEGIN
		SELECT @strWorkOrderNo = strWorkOrderNo
		FROM tblMFWorkOrder
		WHERE intWorkOrderId = @intWorkOrderId

		SELECT TOP 1 @intBatchId = intBatchId
		FROM tblMFWorkOrderProducedLot
		WHERE intWorkOrderId = @intWorkOrderId

		SET @strBatchId = ''

		EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH
			,@strBatchId OUTPUT

		DELETE
		FROM @GLEntries

		INSERT INTO @GLEntries (
			[dtmDate]
			,[strBatchId]
			,[intAccountId]
			,[dblDebit]
			,[dblCredit]
			,[dblDebitUnit]
			,[dblCreditUnit]
			,[strDescription]
			,[strCode]
			,[strReference]
			,[intCurrencyId]
			,[dblExchangeRate]
			,[dtmDateEntered]
			,[dtmTransactionDate]
			,[strJournalLineDescription]
			,[intJournalLineNo]
			,[ysnIsUnposted]
			,[intUserId]
			,[intEntityId]
			,[strTransactionId]
			,[intTransactionId]
			,[strTransactionType]
			,[strTransactionForm]
			,[strModuleName]
			,[intConcurrencyId]
			,[dblDebitForeign]
			,[dblDebitReport]
			,[dblCreditForeign]
			,[dblCreditReport]
			,[dblReportingRate]
			,[dblForeignRate]
			,[strRateType]
			,[intSourceEntityId]
			,[intCommodityId]
			)
		EXEC dbo.uspICUnpostCosting @intBatchId
			,@strWorkOrderNo
			,@strBatchId
			,@intUserId

		EXEC dbo.uspGLBookEntries @GLEntries
			,0

		UPDATE tblMFWorkOrderProducedLot
		SET ysnProductionReversed = 1
		WHERE intWorkOrderId = @intWorkOrderId

		SELECT @intWorkOrderId = MIN(intWorkOrderId)
		FROM @tblWO
		WHERE intWorkOrderId > @intWorkOrderId
	END

	COMMIT TRANSACTION
END TRY

BEGIN CATCH
	IF XACT_STATE() != 0
		AND @@TRANCOUNT > 0
		ROLLBACK TRANSACTION

	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
