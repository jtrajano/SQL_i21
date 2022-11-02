CREATE PROCEDURE [dbo].[uspGRUnpostSettleStorageOutbound]
(
	@intSettleStorageId INT
	,@intUserId INT
)
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @STR_Ids AS Id
	DECLARE @isParentSettleStorage AS BIT
	DECLARE @intId INT
	DECLARE @intInvoiceId INT
	DECLARE @strInvoiceId NVARCHAR(MAX)
	DECLARE @dblSettledUnits DECIMAL(18,6)
	DECLARE @intParentSettleStorageId INT
	DECLARE @intCustomerStorageId INT
	DECLARE @intDPContractDetailId INT	
	DECLARE @intSettleStorageTicketId INT
	DECLARE @intItemUOMId INT
	DECLARE @StorageHistoryStagingTable AS StorageHistoryStagingTable
	DECLARE @intStorageHistoryId INT

	DECLARE @intContractDetailId INT
	DECLARE @dblSettledUnitsInContract DECIMAL(18,6)
	DECLARE @intCnt INT
	DECLARE @ContractDetailIds AS TABLE (
		intCnt INT IDENTITY(1,1)
		,intContractDetailId INT
		,dblUnits DECIMAL(18,6)
	)

	--check first if the settle storage being deleted is the parent, then its children should be deleted first
	SELECT @isParentSettleStorage = CASE WHEN MIN(intSettleStorageId) > 0 THEN 1 ELSE 0 END
	FROM tblGRSettleStorage
	WHERE intParentSettleStorageId = @intSettleStorageId
	
	INSERT INTO @STR_Ids
	SELECT intSettleStorageId
	FROM tblGRSettleStorage
	WHERE (intParentSettleStorageId = @intSettleStorageId AND @isParentSettleStorage = 1)
		OR (intSettleStorageId = @intSettleStorageId AND @isParentSettleStorage = 0)

	SELECT @intId = MIN(intId) FROM @STR_Ids

	WHILE ISNULL(@intId,0) > 0
	BEGIN
		SET @intInvoiceId = NULL
		SET @strInvoiceId = NULL
		SET @dblSettledUnits = NULL
		SET @intParentSettleStorageId = NULL
		SET @intCustomerStorageId = NULL
		SET @intDPContractDetailId = NULL
		SET @intSettleStorageTicketId = NULL
		SET @intItemUOMId = NULL

		SELECT @intInvoiceId = intInvoiceId FROM tblGRStorageHistory WHERE intSettleStorageId = @intId

		IF(SELECT ysnPaid FROM tblARInvoice WHERE intInvoiceId = @intInvoiceId) = 1
		BEGIN
			RAISERROR ('Invoice has already been paid.',16,1,'WITH NOWAIT');
			GOTO Exit_unpost;
		END

		--1. unpost invoice if posted
		IF(SELECT ysnPosted FROM tblARInvoice WHERE intInvoiceId = @intInvoiceId) = 1
		BEGIN
			SET @strInvoiceId = CAST(@intInvoiceId AS NVARCHAR(40))
			EXEC dbo.uspARPostInvoice @param = @strInvoiceId, @post = 0, @recap = 0, @userId = @intUserId, @raiseError = 1
		END

		--2. delete invoice
		IF @intInvoiceId IS NOT NULL
		BEGIN
			--set intInvoiceId to NULL in tblGRStorageHistoryId and tblGRSettleStorage to avoid FK error
			UPDATE tblGRStorageHistory SET intInvoiceId = NULL WHERE intSettleStorageId = @intId
			UPDATE tblGRSettleStorage SET intInvoiceId = NULL WHERE intSettleStorageId = @intId

			EXEC dbo.uspARDeleteInvoice @intInvoiceId, @intUserId
		END

		SELECT @dblSettledUnits			= dblSettleUnits
			,@intParentSettleStorageId	= intParentSettleStorageId
			,@intCustomerStorageId		= SST.intCustomerStorageId
			,@intDPContractDetailId		= DP.intContractDetailId
			,@intSettleStorageTicketId	= SST.intSettleStorageTicketId
			,@intItemUOMId				= ISNULL(SS.intItemUOMId,CS.intItemUOMId)
		FROM tblGRSettleStorage SS
		INNER JOIN tblGRSettleStorageTicket SST
			ON SST.intSettleStorageId = SS.intSettleStorageId
		INNER JOIN tblGRCustomerStorage CS
			ON CS.intCustomerStorageId = SST.intCustomerStorageId
		OUTER APPLY (
			SELECT CD.intContractDetailId
			FROM tblGRStorageHistory SH
			INNER JOIN tblCTContractDetail CD
				ON CD.intContractHeaderId = SH.intContractHeaderId
				AND intTransactionTypeId = 1 --From Scale
			WHERE SH.intCustomerStorageId = CS.intCustomerStorageId
		) DP
		WHERE SS.intSettleStorageId = @intId

		--1.1 return units to storage
		BEGIN
			UPDATE tblGRCustomerStorage SET dblOpenBalance = dblOpenBalance + @dblSettledUnits WHERE intCustomerStorageId = @intCustomerStorageId
		END

		--1.2 return units to DP contract and Price contract (if one is used in the settlement)
		BEGIN
			EXEC uspCTUpdateSequenceQuantityUsingUOM 
				@intContractDetailId = @intDPContractDetailId
				,@dblQuantityToUpdate = @dblSettledUnits
				,@intUserId = @intUserId
				,@intExternalId = @intSettleStorageTicketId
				,@strScreenName = 'Settle Storage'
				,@intSourceItemUOMId = @intItemUOMId
		END

		--1.3 return units to Price contract
		BEGIN
			DELETE FROM @ContractDetailIds
			INSERT INTO @ContractDetailIds
			SELECT intContractDetailId, dblUnits FROM tblGRSettleContract WHERE intSettleStorageId = @intId

			WHILE EXISTS(SELECT 1 FROM @ContractDetailIds)
			BEGIN
				SET @intContractDetailId = NULL
				SET @dblSettledUnitsInContract = NULL

				SELECT TOP 1 @intCnt			= intCnt 
					,@intContractDetailId		= intContractDetailId
					,@dblSettledUnitsInContract	= dblUnits * -1
				FROM @ContractDetailIds
				
				EXEC uspCTUpdateSequenceBalance 
					@intContractDetailId = @intContractDetailId
					,@dblQuantityToUpdate = @dblSettledUnitsInContract
					,@intUserId = @intUserId
					,@intExternalId = @intSettleStorageTicketId
					,@strScreenName = 'Settle Storage'

				DELETE FROM @ContractDetailIds WHERE intCnt = @intCnt
			END
		END

		--2.1 create reversal entry in tblGRStorageHistory
		BEGIN
			INSERT INTO @StorageHistoryStagingTable
			(
				[intCustomerStorageId]
				,[intContractHeaderId]
				,[dblUnits]
				,[dtmHistoryDate]
				,[strType]
				,[intUserId]
				,[strSettleTicket]
				,[strInvoice]
				,[intTransactionTypeId]
				,[dblPaidAmount]
				,[ysnPost]				
			)
			SELECT 
				[intCustomerStorageId] = [intCustomerStorageId]
				,[intContractHeaderId]  = [intContractHeaderId]
				,[dblUnits]				= [dblUnits]
				,[dtmHistoryDate]		= [dtmHistoryDate]
				,[strType]				= 'Reverse Settlement'
				,[intUserId]			= @intUserId
				,[strSettleTicket]		= [strSettleTicket]
				,[strInvoice]			= [strInvoice]
				,[intTransactionTypeId]	= 4
				,[dblPaidAmount]		= [dblPaidAmount]
				,1
			FROM tblGRStorageHistory
			WHERE intSettleStorageId = @intId
		
			EXEC uspGRInsertStorageHistoryRecord @StorageHistoryStagingTable, @intStorageHistoryId OUTPUT

			--2.2 NULL intSettleStorageId in tblGRStorageHistory
			UPDATE tblGRStorageHistory SET intSettleStorageId = NULL WHERE intSettleStorageId = @intId
		END


		--3. reduce units or delete parent id in tblGRSettleStorageTicket
		BEGIN
			UPDATE tblGRSettleStorageTicket SET dblUnits = ROUND(dblUnits,6) - @dblSettledUnits WHERE intSettleStorageId = @intParentSettleStorageId

			--delete if it's already 0
			DELETE FROM tblGRSettleStorageTicket WHERE intSettleStorageId = @intParentSettleStorageId AND dblUnits = 0
		END

		--4. recalculate units in STR-XXXX
		UPDATE SS
		SET dblSpotUnits		= SS.dblSpotUnits - SS2.dblSpotUnits
			,dblStorageDue		= SS.dblStorageDue - SS2.dblStorageDue
			,dblSelectedUnits	= SS.dblSelectedUnits - SS2.dblSelectedUnits
			,dblUnpaidUnits		= SS.dblUnpaidUnits - SS2.dblUnpaidUnits
			,dblSettleUnits		= SS.dblSettleUnits - SS2.dblSettleUnits
			,dblDiscountsDue	= SS.dblDiscountsDue - SS2.dblDiscountsDue
			,dblNetSettlement	= SS.dblNetSettlement - SS2.dblNetSettlement
		FROM tblGRSettleStorage SS
		OUTER APPLY (
			SELECT dblSpotUnits
				,dblStorageDue
				,dblSelectedUnits
				,dblUnpaidUnits
				,dblSettleUnits
				,dblDiscountsDue
				,dblNetSettlement
			FROM tblGRSettleStorage
			WHERE intSettleStorageId = @intId
		) SS2
		WHERE intSettleStorageId = @intParentSettleStorageId

		--5. DELETE SETTLEMENT
		DELETE FROM tblGRSettleStorage WHERE intSettleStorageId = @intId		
		
		--get the next settlement that will be unposted
		SELECT @intId = MIN(intId) FROM @STR_Ids WHERE intId > @intId		
	END

	--DELETE STR-XXXX IF ALL MAIN SETTLEMENT HAVE ALREADY BEEN UNPOSTED
	IF NOT EXISTS(SELECT 1 FROM tblGRSettleStorage WHERE intParentSettleStorageId = @intParentSettleStorageId)
	BEGIN
		DELETE FROM tblGRSettleStorage WHERE intSettleStorageId = @intParentSettleStorageId
	END

	Exit_unpost:
END TRY
BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH