CREATE PROCEDURE [dbo].[uspGRUnpostTransfer]
(
	@intTransferStorageId INT,
	@intUserId INT
)
AS
BEGIN
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF	

	DECLARE @ErrMsg AS NVARCHAR(MAX)
	DECLARE @intTransferContractDetailId INT
	DECLARE @dblTransferUnits NUMERIC(18,6)
	DECLARE @intSourceItemUOMId INT
	DECLARE @intCustomerStorageId INT
	DECLARE @intDecimalPrecision INT		
	SELECT @intDecimalPrecision = intCurrencyDecimal FROM tblSMCompanyPreference

	IF OBJECT_ID (N'tempdb.dbo.#tmpTransferCustomerStorage') IS NOT NULL
		DROP TABLE #tmpTransferCustomerStorage
	CREATE TABLE #tmpTransferCustomerStorage (
		[intCustomerStorageId] INT PRIMARY KEY,
		[dblUnits] DECIMAL(18,6),
		UNIQUE ([intCustomerStorageId])
	);
	INSERT INTO #tmpTransferCustomerStorage
	SELECT 
		intTransferToCustomerStorageId
		,dblUnits
	FROM tblGRTransferStorageSplit
	WHERE intTransferStorageId = @intTransferStorageId

	IF EXISTS(SELECT TOP 1 1 
			FROM tblGRCustomerStorage A 
			INNER JOIN #tmpTransferCustomerStorage B 
				ON B.intCustomerStorageId = A.intCustomerStorageId 
			WHERE B.dblUnits <> A.dblOpenBalance
	)
	BEGIN
		SET @ErrMsg = 'Unable to reverse this transaction. The open balance of one or more customer storage/s no longer match its original balance.'
		
		RAISERROR(@ErrMsg,16,1)
		RETURN;
	END

	IF EXISTS(SELECT TOP 1 1 
			FROM tblGRStorageHistory A 
			INNER JOIN #tmpTransferCustomerStorage B 
				ON B.intCustomerStorageId = A.intCustomerStorageId 
			WHERE A.intInvoiceId IS NOT NULL
	)
	BEGIN
		SET @ErrMsg = 'Unable to reverse this transaction. The storage/discount/fees due of one or more customer storage has been invoiced.'
		
		RAISERROR(@ErrMsg,16,1)
		RETURN;
	END

	BEGIN TRY
	
		DECLARE @transCount INT = @@TRANCOUNT;
		IF @transCount = 0 BEGIN TRANSACTION

		--integration to IC
		DECLARE @cnt INT = 0

		SET @cnt = (SELECT COUNT(*) FROM tblGRTransferStorageSplit WHERE intTransferStorageId = @intTransferStorageId AND intContractDetailId IS NOT NULL)

		DECLARE c CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY
		FOR
		WITH transferStorageDetails (
			intTransferContractDetailId 
			,dblTransferUnits			
			,intSourceItemUOMId			
			,intCustomerStorageId
		) AS (
			SELECT 
				intTransferContractDetailId		= TSplit.intContractDetailId,
				dblTransferUnits				= -(TSplit.dblUnits),
				intSourceItemUOMId				= TransferStorage.intItemUOMId,
				intCustomerStorageId			= TSplit.intTransferToCustomerStorageId
			FROM tblGRTransferStorageSplit TSplit
			INNER JOIN tblGRTransferStorage TransferStorage
				ON TransferStorage.intTransferStorageId = TSplit.intTransferStorageId
			WHERE TSplit.intTransferStorageId = @intTransferStorageId
				AND TSplit.intContractDetailId IS NOT NULL
		)
		SELECT
			intTransferContractDetailId 
			,dblTransferUnits			
			,intSourceItemUOMId			
			,intCustomerStorageId
		FROM ( SELECT * FROM transferStorageDetails ) icParams
		
		OPEN c;

		FETCH c INTO @intTransferContractDetailId, @dblTransferUnits, @intSourceItemUOMId, @intCustomerStorageId

		WHILE @@FETCH_STATUS = 0 AND @cnt > 0
		BEGIN
			EXEC uspCTUpdateSequenceQuantityUsingUOM 
				@intContractDetailId	= @intTransferContractDetailId
				,@dblQuantityToUpdate	= @dblTransferUnits
				,@intUserId				= @intUserId
				,@intExternalId			= @intCustomerStorageId
				,@strScreenName			= 'Transfer Storage'
				,@intSourceItemUOMId	= @intSourceItemUOMId

			FETCH c INTO @intTransferContractDetailId, @dblTransferUnits, @intSourceItemUOMId, @intCustomerStorageId
		END
		CLOSE c; DEALLOCATE c;				
		
		--DELETE HISTORY
		DELETE FROM tblGRStorageHistory WHERE intTransferStorageId = @intTransferStorageId
		DELETE FROM tblGRStorageHistory WHERE intCustomerStorageId IN (SELECT intCustomerStorageId FROM #tmpTransferCustomerStorage)
		--DELETE DISCOUNTS
		DELETE FROM tblQMTicketDiscount WHERE intTicketFileId IN (SELECT intCustomerStorageId FROM #tmpTransferCustomerStorage) AND strSourceType = 'Storage'

		--integration to IC
		SET @cnt = 0

		SET @cnt = (SELECT COUNT(*) FROM tblGRTransferStorageSourceSplit WHERE intTransferStorageId = @intTransferStorageId AND intContractDetailId IS NOT NULL)

		DECLARE c CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY
		FOR
		WITH storageDetails (
			intTransferContractDetailId 
			,dblTransferUnits			
			,intSourceItemUOMId			
			,intCustomerStorageId
		) AS (
			SELECT intTransferContractDetailId	= SSplit.intContractDetailId,
				dblTransferUnits				= SSplit.dblDeductedUnits,
				intSourceItemUOMId				= TransferStorage.intItemUOMId,
				intCustomerStorageId			= SSplit.intSourceCustomerStorageId
			FROM tblGRTransferStorageSourceSplit SSplit
			INNER JOIN tblGRTransferStorage TransferStorage
				ON TransferStorage.intTransferStorageId = SSplit.intTransferStorageId
			WHERE SSplit.intTransferStorageId = @intTransferStorageId
				AND SSplit.intContractDetailId IS NOT NULL
		)
		SELECT
			intTransferContractDetailId 
			,dblTransferUnits			
			,intSourceItemUOMId			
			,intCustomerStorageId
		FROM ( SELECT * FROM storageDetails ) icParams
		
		OPEN c;

		FETCH c INTO @intTransferContractDetailId, @dblTransferUnits, @intSourceItemUOMId, @intCustomerStorageId

		WHILE @@FETCH_STATUS = 0 AND @cnt > 0
		BEGIN
			EXEC uspCTUpdateSequenceQuantityUsingUOM 
				@intContractDetailId	= @intTransferContractDetailId
				,@dblQuantityToUpdate	= @dblTransferUnits
				,@intUserId				= @intUserId
				,@intExternalId			= @intCustomerStorageId
				,@strScreenName			= 'Transfer Storage'
				,@intSourceItemUOMId	= @intSourceItemUOMId

			FETCH c INTO @intTransferContractDetailId, @dblTransferUnits, @intSourceItemUOMId, @intCustomerStorageId
		END
		CLOSE c; DEALLOCATE c;

		--update the source's customer storage open balance
		UPDATE A
		SET A.dblOpenBalance 	= ROUND(A.dblOpenBalance + B.dblDeductedUnits,@intDecimalPrecision)
		FROM tblGRCustomerStorage A 
		INNER JOIN tblGRTransferStorageSourceSplit B 
			ON B.intSourceCustomerStorageId = A.intCustomerStorageId
		WHERE B.intTransferStorageId = @intTransferStorageId

		DELETE FROM tblGRTransferStorage WHERE intTransferStorageId = @intTransferStorageId
		DELETE FROM tblGRCustomerStorage WHERE intCustomerStorageId IN (SELECT intCustomerStorageId FROM #tmpTransferCustomerStorage)

		DONE:
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
		RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
	END CATCH	
END