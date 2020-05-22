CREATE PROCEDURE [dbo].[uspGRStorageInventoryReceipt]
	@SettleVoucherCreate AS SettleVoucherCreate READONLY --for settlement only
	,@intCustomerStorageId AS INT = NULL
	,@intSettleStorageId AS INT = NULL
	,@intTransferStorageReferenceId INT = NULL
	,@ysnUnpost BIT
AS
BEGIN
	DECLARE @dblTransactionUnits DECIMAL(38,20) --# of units being settled
	DECLARE @dblTransactionRunningUnits DECIMAL(38,20) --remaining units from settlement (taken from previous row)
	DECLARE @dblShrinkage DECIMAL(38,20)
	DECLARE @intSettleVoucherKey INT
	DECLARE @dblOriginalBalance DECIMAL(38,20)
	DECLARE @intId INT
	DECLARE @intTransferToCustomerStorageId INT
	DECLARE @ysnTransferStorage BIT
	DECLARE @SettleVoucher AS TABLE
	(
		intSettleVoucherKey INT IDENTITY(1,1)
		,intContractDetailId INT
		,dblUnits DECIMAL(38,20)
	)

	DECLARE @IR_Units AS TABLE
	(
		intId INT IDENTITY(1,1)
		,intInventoryReceiptId INT
		,intInventoryReceiptItemId INT
		,dblUnits DECIMAL(38,20)
		,ysnExists BIT
	)

	DECLARE @StorageInventoryReceipt AS TABLE
	(
		[intStorageInventoryReceipt] INT IDENTITY(1,1)
		,[intCustomerStorageId] INT NOT NULL
		,[intInventoryReceiptId] INT NOT NULL
		,[intInventoryReceiptItemId] INT NOT NULL
		,[intContractDetailId] INT NULL
		,[dblUnits] DECIMAL(38,20) NOT NULL
		,[dblShrinkage] DECIMAL(38,20)
		,[dblNetUnits] DECIMAL(38,20)
		,[intSettleStorageId] INT NULL
		,[intTransferStorageReferenceId] INT NULL
		,[dblTransactionUnits] DECIMAL(38,20) NULL
		,[dblReceiptRunningUnits] DECIMAL(24,10) NULL		
	)

	IF @intCustomerStorageId IS NULL
	BEGIN
		SELECT @intCustomerStorageId = intSourceCustomerStorageId
			,@intTransferToCustomerStorageId = intToCustomerStorageId 
			,@ysnTransferStorage = CS.ysnTransferStorage
		FROM tblGRTransferStorageReference SR
		INNER JOIN tblGRCustomerStorage CS ON CS.intCustomerStorageId = SR.intSourceCustomerStorageId
		INNER JOIN tblGRStorageType ST
			ON ST.intStorageScheduleTypeId = CS.intStorageTypeId AND ST.ysnDPOwnedType = 1
		WHERE intTransferStorageReferenceId = @intTransferStorageReferenceId
	END
	
	INSERT INTO @IR_Units
	--SETTLEMENT FOR NON-TRANSFER STORAGE
	--ROW COUNT WILL ALWAYS BE 0 IF @ysnUnpost = 1
	SELECT IR.intInventoryReceiptId
		,IR.intInventoryReceiptItemId
		,(CASE WHEN IR.ysnExists = 0 THEN IR.dblUnits ELSE IR.dblUnits + ISNULL(IR_Unposted.dblTransactionUnits,0) END)
		,IR.ysnExists 
	FROM (
		SELECT 
			SH.intInventoryReceiptId
			,IRI.intInventoryReceiptItemId
			,dblUnits = CASE WHEN IR_Used.intInventoryReceiptId IS NULL THEN SH.dblUnits ELSE IR_Used.dblReceiptRunningUnits END
			,ysnExists = CAST(CASE WHEN IR_Used.intInventoryReceiptId IS NULL THEN 0 ELSE 1 END AS BIT)
			,SH.dtmHistoryDate
		FROM tblGRStorageHistory SH
		INNER JOIN tblICInventoryReceiptItem IRI
			ON IRI.intInventoryReceiptId = SH.intInventoryReceiptId
		OUTER APPLY (
			SELECT TOP 1
				intInventoryReceiptId
				,intInventoryReceiptItemId
				,dblReceiptRunningUnits
				,dblTransactionUnits
				,dblShrinkage
			FROM tblGRStorageInventoryReceipt
			WHERE ysnUnposted = 0
				AND intInventoryReceiptId = SH.intInventoryReceiptId
				AND intInventoryReceiptItemId = IRI.intInventoryReceiptItemId
				AND intCustomerStorageId = @intCustomerStorageId
			ORDER BY intStorageInventoryReceipt DESC
		) IR_Used
		WHERE SH.intCustomerStorageId = @intCustomerStorageId
			AND SH.intTransactionTypeId = 5 --From Delivery Sheet/ IR
			AND ((ISNULL(IR_Used.dblTransactionUnits,0) + ABS(ISNULL(dblShrinkage,0))) <> SH.dblUnits OR IR_Used.dblReceiptRunningUnits IS NULL)
			AND ISNULL(@ysnTransferStorage,0) = 0
		--ORDER BY dtmHistoryDate
	) IR
	LEFT JOIN (
		SELECT TOP 1
			intInventoryReceiptId
			,intInventoryReceiptItemId
			,dblTransactionUnits-- = SUM(dblTransactionUnits)
		FROM tblGRStorageInventoryReceipt
		WHERE ysnUnposted = 1 AND intCustomerStorageId = @intCustomerStorageId
		ORDER BY intStorageInventoryReceipt DESC
		--GROUP BY intInventoryReceiptId,intInventoryReceiptItemId
	) IR_Unposted
		ON IR_Unposted.intInventoryReceiptId = IR.intInventoryReceiptId 
			AND IR_Unposted.intInventoryReceiptItemId = IR.intInventoryReceiptItemId
	ORDER BY IR.dtmHistoryDate

	--DP Transferred that will be settled will be pulled from tblGRStorageInventoryReceipt to get the IRs
	IF (@intSettleStorageId IS NOT NULL OR @intTransferToCustomerStorageId IS NOT NULL) AND NOT EXISTS(SELECT TOP 1 1 FROM @IR_Units)
	BEGIN
		INSERT INTO @IR_Units
		--FIRST SETTLEMENT OR TRANSFER OF A DP TRANSFER STORAGE		
		SELECT SIR.intInventoryReceiptId
			,SIR.intInventoryReceiptItemId
			,SIR.dblTransactionUnits
			,0
		FROM tblGRStorageInventoryReceipt SIR
		INNER JOIN tblGRTransferStorageReference TSR ON TSR.intTransferStorageReferenceId = SIR.intTransferStorageReferenceId AND TSR.intToCustomerStorageId = @intCustomerStorageId
		WHERE (CASE WHEN (SELECT TOP 1 1 FROM tblGRStorageInventoryReceipt WHERE intCustomerStorageId = @intId) = 1 THEN 1 ELSE 0 END) = 0
		UNION ALL

		--SUCCEEDING SETTLEMENTS OR TRANSFERS OF DP TRANSFER STORAGES
		SELECT SIR.intInventoryReceiptId
			,SIR.intInventoryReceiptItemId
			,SIR.dblReceiptRunningUnits
			,1
		FROM tblGRStorageInventoryReceipt SIR
		INNER JOIN tblGRTransferStorageReference TSR ON TSR.intTransferStorageReferenceId = SIR.intTransferStorageReferenceId AND TSR.intToCustomerStorageId = @intCustomerStorageId
		WHERE (CASE WHEN (SELECT TOP 1 1 FROM tblGRStorageInventoryReceipt WHERE intCustomerStorageId = @intId) = 1 THEN 1 ELSE 0 END) = 1

	END

	--SELECT 'TEST', SIR.intInventoryReceiptId
	--		,SIR.intInventoryReceiptItemId
	--		,SIR.dblTransactionUnits
	--		,0
	--	FROM tblGRStorageInventoryReceipt SIR
	--	INNER JOIN tblGRTransferStorageReference TSR ON TSR.intTransferStorageReferenceId = SIR.intTransferStorageReferenceId AND TSR.intToCustomerStorageId = @intCustomerStorageId
	--	WHERE (CASE WHEN (SELECT TOP 1 1 FROM tblGRStorageInventoryReceipt WHERE intCustomerStorageId = @intId) = 1 THEN 1 ELSE 0 END) = 0

	--	UNION ALL

	--	--SUCCEEDING SETTLEMENTS OR TRANSFERS OF DP TRANSFER STORAGES
	--	SELECT 'TEST', SIR.intInventoryReceiptId
	--		,SIR.intInventoryReceiptItemId
	--		,SIR.dblReceiptRunningUnits
	--		,1
	--	FROM tblGRStorageInventoryReceipt SIR
	--	INNER JOIN tblGRTransferStorageReference TSR ON TSR.intTransferStorageReferenceId = SIR.intTransferStorageReferenceId AND TSR.intToCustomerStorageId = @intCustomerStorageId
	--	WHERE (CASE WHEN (SELECT TOP 1 1 FROM tblGRStorageInventoryReceipt WHERE intCustomerStorageId = @intId) = 1 THEN 1 ELSE 0 END) = 1

	--SELECT '@IR_Units',* FROM @IR_Units	

	SELECT @dblOriginalBalance = dblOriginalBalance FROM tblGRCustomerStorage WHERE intCustomerStorageId = @intCustomerStorageId
	SELECT @dblShrinkage = dblUnits FROM tblGRStorageHistory WHERE intCustomerStorageId = @intCustomerStorageId AND strPaidDescription = 'Quantity Adjustment From Delivery Sheet' AND intTransactionTypeId = 9
					
	DELETE FROM @SettleVoucher
	INSERT INTO @SettleVoucher
	SELECT intContractDetailId,dblUnits FROM @SettleVoucherCreate WHERE intItemType = 1				

	--SELECT '@SettleVoucher',* FROM @SettleVoucher
	IF (SELECT COUNT(*) FROM @SettleVoucher) > 0 --Settlement
	BEGIN
		WHILE EXISTS(SELECT TOP 1 1 FROM @SettleVoucher)
		BEGIN
			SET @intSettleVoucherKey = NULL
			SET @intId = NULL

			SELECT TOP 1 @intSettleVoucherKey = intSettleVoucherKey FROM @SettleVoucher ORDER BY intSettleVoucherKey

			WHILE EXISTS(SELECT TOP 1 1 FROM @IR_Units)
			BEGIN
				SELECT TOP 1 @intId = intId FROM @IR_Units ORDER BY intId

				IF(@intSettleVoucherKey IS NOT NULL) AND (@intId IS NOT NULL)
				BEGIN
				
					DELETE FROM @StorageInventoryReceipt
					INSERT INTO @StorageInventoryReceipt
					(
						[intCustomerStorageId]
						,[intInventoryReceiptId]
						,[intInventoryReceiptItemId]
						,[intContractDetailId]
						,[dblUnits]
						,[dblShrinkage]
						,[dblNetUnits]
						,[intSettleStorageId]
						,[dblTransactionUnits]
						,[dblReceiptRunningUnits]
					)
					SELECT 
						@intCustomerStorageId
						,intInventoryReceiptId
						,intInventoryReceiptItemId
						,intContractDetailId
						,dblUnits
						,dblShrinkage
						,dblNetUnits
						,@intSettleStorageId
						,dblTransactionUnits = CASE WHEN dblSettledUnits > dblNetUnits THEN dblNetUnits ELSE dblSettledUnits END
						,dblReceiptRunningUnits = dblNetUnits - (CASE WHEN dblSettledUnits > dblNetUnits THEN dblNetUnits ELSE dblSettledUnits END)
					FROM (
						SELECT 
							intInventoryReceiptId
							,intInventoryReceiptItemId
							,intContractDetailId
							,dblUnits = ISNULL(CASE WHEN ISNULL(dblReceiptRunningUnits,0) = 0 THEN dblUnits ELSE dblReceiptRunningUnits END,0)
							,dblShrinkage = ISNULL(CASE WHEN ISNULL(dblReceiptRunningUnits,0) = 0 THEN dblShrinkage ELSE 0 END,0)
							,dblNetUnits = (CASE WHEN ISNULL(dblReceiptRunningUnits,0) = 0 THEN dblUnits ELSE dblReceiptRunningUnits END) - ISNULL(ABS(CASE WHEN ISNULL(dblReceiptRunningUnits,0) = 0 THEN dblShrinkage ELSE 0 END),0)
							,dblSettledUnits
						FROM (
							SELECT 					
								A.intInventoryReceiptId
								,A.intInventoryReceiptItemId
								,B.intContractDetailId
								,A.dblUnits
								,dblShrinkage = CASE WHEN A.ysnExists = 0 THEN (@dblShrinkage / (@dblOriginalBalance + ABS(@dblShrinkage))) * A.dblUnits ELSE NULL END
								,dblSettledUnits = B.dblUnits
								,R.dblReceiptRunningUnits
							FROM (
								SELECT * FROM @IR_Units WHERE intId = @intId
							) A
							OUTER APPLY (
								SELECT * FROM @SettleVoucher WHERE intSettleVoucherKey = @intSettleVoucherKey
							) B
							OUTER APPLY (
								SELECT TOP 1 dblReceiptRunningUnits FROM tblGRStorageInventoryReceipt
								WHERE intInventoryReceiptId = A.intInventoryReceiptId
									AND intInventoryReceiptItemId = A.intInventoryReceiptItemId
									AND ysnUnposted = 0
									AND intCustomerStorageId = @intCustomerStorageId
								ORDER BY intStorageInventoryReceipt DESC
							) R
						) C
					) D					

					IF(SELECT dblUnits FROM @StorageInventoryReceipt) > 0 AND (SELECT dblTransactionUnits FROM @StorageInventoryReceipt) > 0
					BEGIN
						INSERT INTO tblGRStorageInventoryReceipt
						(
							[intCustomerStorageId]
							,[intInventoryReceiptId]
							,[intInventoryReceiptItemId]
							,[intContractDetailId]
							,[dblUnits]
							,[dblShrinkage]
							,[dblNetUnits]
							,[intSettleStorageId]
							,[dblTransactionUnits]
							,[dblReceiptRunningUnits]
						)
						SELECT [intCustomerStorageId]
							,[intInventoryReceiptId]
							,[intInventoryReceiptItemId]
							,[intContractDetailId]
							,[dblUnits]
							,[dblShrinkage]
							,[dblNetUnits]
							,@intSettleStorageId
							,[dblTransactionUnits]
							,[dblReceiptRunningUnits]
						FROM @StorageInventoryReceipt
					END
				END

				UPDATE @SettleVoucher SET dblUnits = dblUnits - (SELECT dblNetUnits FROM @StorageInventoryReceipt) WHERE intSettleVoucherKey = @intSettleVoucherKey

				IF (SELECT dblUnits FROM @SettleVoucher WHERE intSettleVoucherKey = @intSettleVoucherKey) < 0
				BEGIN
					BREAK;
				END							
				IF (SELECT dblReceiptRunningUnits FROM @StorageInventoryReceipt) <= (SELECT dblUnits FROM @IR_Units WHERE intId = @intId)
				BEGIN
					DELETE FROM @IR_Units WHERE intId = @intId
				END
				ELSE 
				BEGIN
					UPDATE @IR_Units SET dblUnits = dblUnits - (SELECT dblUnits FROM @StorageInventoryReceipt) WHERE intId = @intId
				END
			END
						
			DELETE FROM @SettleVoucher WHERE intSettleVoucherKey = @intSettleVoucherKey
		END
	END	
	ELSE
	BEGIN --transfer
		IF EXISTS(SELECT TOP 1 1 FROM @IR_Units) --IF ONLY THE TRANSFER SOURCE IS A NON-TRANSFER STORAGE
		BEGIN
			WHILE EXISTS(SELECT TOP 1 1 FROM @IR_Units)
			BEGIN
				SELECT TOP 1 @intId = intId FROM @IR_Units ORDER BY intId
				--SELECT 'TEST1',ISNULL(SUM(dblTransactionUnits),0) FROM tblGRStorageInventoryReceipt WHERE intTransferStorageReferenceId = @intTransferStorageReferenceId
				--SELECT 'TEST2',dblUnitQty FROM tblGRTransferStorageReference WHERE intTransferStorageReferenceId = @intTransferStorageReferenceId
				IF @intId IS NOT NULL AND (SELECT ISNULL(SUM(dblTransactionUnits),0) FROM tblGRStorageInventoryReceipt WHERE intTransferStorageReferenceId = @intTransferStorageReferenceId) < (SELECT dblUnitQty FROM tblGRTransferStorageReference WHERE intTransferStorageReferenceId = @intTransferStorageReferenceId)
				BEGIN				
					DELETE FROM @StorageInventoryReceipt
					INSERT INTO @StorageInventoryReceipt
					(
						[intCustomerStorageId]
						,[intInventoryReceiptId]
						,[intInventoryReceiptItemId]
						,[dblUnits]
						,[dblShrinkage]
						,[dblNetUnits]
						,[intSettleStorageId]
						,[dblTransactionUnits]
						,[dblReceiptRunningUnits]
					)
					SELECT DISTINCT
						@intCustomerStorageId
						,intInventoryReceiptId
						,intInventoryReceiptItemId
						,dblUnits
						,dblShrinkage
						,dblNetUnits
						,@intSettleStorageId
						,dblTransactionUnits = CASE WHEN dblTransferredUnits > dblNetUnits THEN dblNetUnits ELSE dblTransferredUnits END
						,dblReceiptRunningUnits = dblNetUnits - (CASE WHEN dblTransferredUnits > dblNetUnits THEN dblNetUnits ELSE dblTransferredUnits END)
					FROM (
						SELECT 
							intInventoryReceiptId
							,intInventoryReceiptItemId
							,dblUnits = ISNULL(CASE WHEN ISNULL(dblReceiptRunningUnits,0) = 0 THEN dblUnits ELSE dblReceiptRunningUnits END,0)
							,dblShrinkage = ISNULL(CASE WHEN ISNULL(dblReceiptRunningUnits,0) = 0 THEN dblShrinkage ELSE 0 END,0)
							,dblNetUnits = (CASE WHEN ISNULL(dblReceiptRunningUnits,0) = 0 THEN dblUnits ELSE dblReceiptRunningUnits END) - ISNULL(ABS(CASE WHEN ISNULL(dblReceiptRunningUnits,0) = 0 THEN dblShrinkage ELSE 0 END),0)
							,dblTransferredUnits
						FROM (
							SELECT 					
								A.intInventoryReceiptId
								,A.intInventoryReceiptItemId
								,A.dblUnits
								,dblShrinkage = CASE WHEN A.ysnExists = 0 THEN (@dblShrinkage / (@dblOriginalBalance + ABS(@dblShrinkage))) * A.dblUnits ELSE NULL END
								,dblTransferredUnits = B.dblUnitQty - ISNULL(TotalTransfer.dblTotalTransactionUnits,0)
								,R.dblReceiptRunningUnits
							FROM (
								SELECT * FROM @IR_Units WHERE intId = @intId
							) A
							OUTER APPLY (
								SELECT SR.dblUnitQty FROM tblGRTransferStorageReference SR WHERE intSourceCustomerStorageId = @intCustomerStorageId AND intTransferStorageReferenceId = @intTransferStorageReferenceId
							) B
							OUTER APPLY (
								SELECT TOP 1 dblReceiptRunningUnits FROM tblGRStorageInventoryReceipt
								WHERE intInventoryReceiptId = A.intInventoryReceiptId
									AND intInventoryReceiptItemId = A.intInventoryReceiptItemId
									AND ysnUnposted = 0
									AND intCustomerStorageId = @intCustomerStorageId
								ORDER BY intStorageInventoryReceipt DESC
							) R
							OUTER APPLY (
								SELECT dblTotalTransactionUnits = SUM(dblTransactionUnits) FROM tblGRStorageInventoryReceipt
								WHERE intTransferStorageReferenceId = @intTransferStorageReferenceId
							) TotalTransfer
						) C
					) D

					--SELECT DISTINCT 'TEST2',
					--	@intCustomerStorageId
					--	,intInventoryReceiptId
					--	,intInventoryReceiptItemId
					--	,dblUnits
					--	,dblShrinkage
					--	,dblNetUnits
					--	,@intSettleStorageId
					--	,dblTransactionUnits = CASE WHEN dblTransferredUnits > dblNetUnits THEN dblNetUnits ELSE dblTransferredUnits END
					--	,dblReceiptRunningUnits = dblNetUnits - (CASE WHEN dblTransferredUnits > dblNetUnits THEN dblNetUnits ELSE dblTransferredUnits END)
					--FROM (
					--	SELECT 
					--		intInventoryReceiptId
					--		,intInventoryReceiptItemId
					--		,dblUnits = ISNULL(CASE WHEN ISNULL(dblReceiptRunningUnits,0) = 0 THEN dblUnits ELSE dblReceiptRunningUnits END,0)
					--		,dblShrinkage = ISNULL(CASE WHEN ISNULL(dblReceiptRunningUnits,0) = 0 THEN dblShrinkage ELSE 0 END,0)
					--		,dblNetUnits = (CASE WHEN ISNULL(dblReceiptRunningUnits,0) = 0 THEN dblUnits ELSE dblReceiptRunningUnits END) - ISNULL(ABS(CASE WHEN ISNULL(dblReceiptRunningUnits,0) = 0 THEN dblShrinkage ELSE 0 END),0)
					--		,dblTransferredUnits
					--	FROM (
					--		SELECT 					
					--			A.intInventoryReceiptId
					--			,A.intInventoryReceiptItemId
					--			,A.dblUnits
					--			,dblShrinkage = CASE WHEN A.ysnExists = 0 THEN (@dblShrinkage / (@dblOriginalBalance + ABS(@dblShrinkage))) * A.dblUnits ELSE NULL END
					--			,dblTransferredUnits = B.dblUnitQty - ISNULL(TotalTransfer.dblTotalTransactionUnits,0)
					--			,R.dblReceiptRunningUnits
					--		FROM (
					--			SELECT * FROM @IR_Units WHERE intId = @intId
					--		) A
					--		OUTER APPLY (
					--			SELECT SR.dblUnitQty FROM tblGRTransferStorageReference SR WHERE intSourceCustomerStorageId = @intCustomerStorageId AND intTransferStorageReferenceId = @intTransferStorageReferenceId
					--		) B
					--		OUTER APPLY (
					--			SELECT TOP 1 dblReceiptRunningUnits FROM tblGRStorageInventoryReceipt
					--			WHERE intInventoryReceiptId = A.intInventoryReceiptId
					--				AND intInventoryReceiptItemId = A.intInventoryReceiptItemId
					--				AND ysnUnposted = 0
					--			ORDER BY intStorageInventoryReceipt DESC
					--		) R
					--		OUTER APPLY (
					--			SELECT dblTotalTransactionUnits = SUM(dblTransactionUnits) FROM tblGRStorageInventoryReceipt
					--			WHERE intTransferStorageReferenceId = @intTransferStorageReferenceId
					--		) TotalTransfer
					--	) C
					--) D

					IF(SELECT dblUnits FROM @StorageInventoryReceipt) > 0 AND (SELECT dblTransactionUnits FROM @StorageInventoryReceipt) > 0
					BEGIN
						INSERT INTO tblGRStorageInventoryReceipt
						(
							[intCustomerStorageId]
							,[intInventoryReceiptId]
							,[intInventoryReceiptItemId]
							,[intContractDetailId]
							,[dblUnits]
							,[dblShrinkage]
							,[dblNetUnits]
							,[intTransferStorageReferenceId]
							,[dblTransactionUnits]
							,[dblReceiptRunningUnits]
						)
						SELECT [intCustomerStorageId]
							,[intInventoryReceiptId]
							,[intInventoryReceiptItemId]
							,[intContractDetailId]
							,[dblUnits]
							,[dblShrinkage]
							,[dblNetUnits]
							,@intTransferStorageReferenceId
							,[dblTransactionUnits]
							,[dblReceiptRunningUnits]
						FROM @StorageInventoryReceipt
					END
					--SELECT 'tblGRStorageInventoryReceipt',* FROM tblGRStorageInventoryReceipt
				END
				ELSE
				BEGIN
				DELETE FROM @IR_Units WHERE intId = @intId
				END
				IF (SELECT dblReceiptRunningUnits FROM @StorageInventoryReceipt) <= (SELECT dblUnits FROM @IR_Units WHERE intId = @intId)
				BEGIN
					DELETE FROM @IR_Units WHERE intId = @intId
				END
				ELSE 
				BEGIN
					UPDATE @IR_Units SET dblUnits = dblUnits - (SELECT dblUnits FROM @StorageInventoryReceipt) WHERE intId = @intId
				END
			END
		END		
	END
	--select 'tblGRStorageInventoryReceipt',* from tblGRStorageInventoryReceipt
END