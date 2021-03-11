CREATE PROCEDURE [dbo].[uspGRTranferChecking]
	@TransferStorageTicket nvarchar(100)
	,@Debug bit = 0
as
begin
	--declare @TransferStorageTicket nvarchar(100)
	declare @CustomerStorageIds table
	(
		i int
	)


	--uspGRTranferCheckingselect @TransferStorageTicket = 'TRA-334'
	--'TRA-353'
	--'TRA-309'
	--TRA-334


	declare @TransferUnits decimal(24, 10)
	declare @DP_OS bit
	declare @OS_DP bit
	declare @TransactionReading nvarchar(100)
	select @TransferUnits = TransferUnit
			, @DP_OS = DP_TO_OS
			, @OS_DP = OS_TO_DP
		from dbo.fnGRWhatIsMyTransfer(@TransferStorageTicket, null)
	--DP to OS

	select @TransactionReading = case when @DP_OS = 1 then 'DP to OS'
			when @OS_DP = 1 then 'OS to DP'
		else 'e'
		end
	
	declare @TransferStorageId int
	select @TransferStorageId =  intTransferStorageId 
			from tblGRTransferStorage 
				where strTransferStorageTicket = @TransferStorageTicket		
		



	if @DP_OS = 1
	begin
		
		
		
		declare @TransactionJumper table
		(
			intInventoryReceiptId int
			,intInventoryReceiptItemId int
			,intTransferStorageReferenceId int
			,intSettleStorageId int
			,intCustomerStorageId int 

		)
		


		insert into @CustomerStorageIds ( i ) 
		select distinct 
			intCustomerStorageId
			from tblGRStorageInventoryReceipt 
				where intInventoryReceiptId 
					in (
						select distinct intInventoryReceiptId 
							from vyuGRTransferClearing 
								where strTransferStorageTicket = @TransferStorageTicket
						)
					and intSettleStorageId is null
					
				
		-- we need to check if there are other transfer in the IR 
		insert into @TransactionJumper(intInventoryReceiptId, intInventoryReceiptItemId, intTransferStorageReferenceId, intSettleStorageId, intCustomerStorageId)
		select distinct 

			intInventoryReceiptId
			,intInventoryReceiptItemId
			,intTransferStorageReferenceId
			, intSettleStorageId 
			, intCustomerStorageId			

			from tblGRStorageInventoryReceipt 
				where intInventoryReceiptId 
					in (
						select distinct intInventoryReceiptId 
							from vyuGRTransferClearing 
								where strTransferStorageTicket = @TransferStorageTicket
						)
					and intTransferStorageReferenceId not in 
						( select intTransferStorageReferenceId
							from tblGRTransferStorageReference 
								where intTransferStorageId = @TransferStorageId
						)
					and intSettleStorageId is null
		
		union all 

		select distinct 

			intInventoryReceiptId
			, intInventoryReceiptItemId
			, intTransferStorageReferenceId
			, intSettleStorageId 
			, intCustomerStorageId

			from tblGRStorageInventoryReceipt 
				where intInventoryReceiptId 
					in (
						select distinct intInventoryReceiptId 
							from vyuGRTransferClearing 
								where strTransferStorageTicket = @TransferStorageTicket
						)
					and intSettleStorageId is not null
		
		
		if @Debug = 1 
		begin
			select * from @TransactionJumper		
			select 
					dblTransactionUnits
					,Storage.dblBasis
					,Storage.dblSettlementPrice		
					,Storage.dblBasis + Storage.dblSettlementPrice	as TransferCost
					,dbo.fnGRComputeMyUnitFromShrinkage(Jumper.intInventoryReceiptId, Jumper.intInventoryReceiptItemId, StorageReceipt.dblTransactionUnits) as dblTotalTransactionUnitAndShrinkage
					,dbo.fnGRComputeMyUnitFromShrinkage(Jumper.intInventoryReceiptId, Jumper.intInventoryReceiptItemId, StorageReceipt.dblTransactionUnits) 
						* ( Storage.dblBasis + Storage.dblSettlementPrice )
					,dbo.fnGRComputeMyUnitFromShrinkage(Jumper.intInventoryReceiptId, Jumper.intInventoryReceiptItemId, StorageReceipt.dblTransactionUnits)  
						* InventoryTransaction.dblCost as TotalInventoryAmount
					,@TransferStorageId as TransferStorageId
				from @TransactionJumper Jumper
					join tblGRStorageInventoryReceipt StorageReceipt
						on Jumper.intInventoryReceiptId = StorageReceipt.intInventoryReceiptId
							and Jumper.intTransferStorageReferenceId = StorageReceipt.intTransferStorageReferenceId 
					join tblGRCustomerStorage Storage
						on Storage.intCustomerStorageId = Jumper.intCustomerStorageId
					join tblICInventoryTransaction InventoryTransaction
						on InventoryTransaction.intTransactionId = Jumper.intInventoryReceiptId
							and InventoryTransaction.intTransactionDetailId = Jumper.intInventoryReceiptItemId
		end
		
	
		--select dblCost from tblICInventoryTransaction where intTransactionId = @TransferStorageId and intTransactionTypeId = 56
		/*			
		select * from tblGRStorageHistory StorageHistory
			join @TransactionJumper Jumper
				on Jumper.intCustomerStorageId = StorageHistory.intCustomerStorageId
		select * from tblGRStorageInventoryReceipt InventoryReceipt 
			join @TransactionJumper Jumper
				on Jumper.intCustomerStorageId = InventoryReceipt.intCustomerStorageId
		*/

		--6.01697255429488583263
		--	
	


		/*
			Here are the steps to explain the DP - OS Transfer discrepancies
				We need to know how many units are transferred.
				We need to know the total IR units that are included in the transfer.
				We need to know if there are units adjustment for the delivery sheet before the transfer. We will need those units to calculate how many units of the IR can be used to compare against TRA.
				If there are cost adjustments, we need to take into consideration the cost adjustment and included those in the comparison.
				If the total units of IR are greater than the total units of TRA we need the difference to be included in the comparison. There are instances wherein an IR is split into two TRA. Not to mention if some parts of the IR is in the transfer and others are in the settlement.


		*/
		/*
			V2 
			- we only need to know the total units of the IR involved in the transfer
			- we need to know the total units of the IR
			- we need to know the difference 
			- we need to know the cost of IR and TRA
		*/


		-- Getting total IR Units
		declare @Total_units_IR decimal(24, 10)
		declare @Total_units_Transfer decimal(24,10)
		declare @Total_units_Adjustment decimal(24,10)	
		declare @Total_units_IR_Excess decimal(24,10)	

		declare @Total_count_IR_InCustomerStorage int
		declare @Total_count_IR_InTransfer int
	

		declare @Total_Amount_Per_IR_Based_on_Quantity_Adjustment decimal(24,10)
		declare @Total_Amount_Per_IR decimal(24,10)
		declare @Total_Amount_Excess_IR decimal(24,10)
		declare @Total_Amount_Transfer decimal(24,10)
		declare @Total_Amount_IR_Cost_Adjustment decimal(24,10)
		declare @Total_Amount_Excess_IR_Cost_Adjustment decimal(24,10)

		declare @Cost_Transfer decimal(24,10)
		declare @Cost_IR decimal(24,10)


		declare @Multiplier_IR int
		declare @Multiplier_Cost int


		-- Gettin total transfer units
		select @Total_units_Transfer = sum(dblQty)
				,@Total_Amount_Transfer = sum(dblQty * dblCost)
				,@Cost_Transfer = Avg(dblCost)
		from tblICInventoryTransaction 
			where intTransactionId = @TransferStorageId
				and intTransactionTypeId = 56 
	
	
	
		select @Total_units_IR  = sum(dblQty) 
			, @Total_count_IR_InTransfer = count(intInventoryTransactionId)
			, @Total_Amount_Per_IR = sum(dblQty * dblCost)
			, @Total_Amount_Per_IR_Based_on_Quantity_Adjustment  = sum(dblCost * (@Total_units_Adjustment / @Total_count_IR_InCustomerStorage ) )  --maybe consider moving this computation part 
			, @Cost_IR = Avg(dblCost)
		
				from tblICInventoryTransaction 
				where intTransactionId in ( select distinct intInventoryReceiptId 
						from vyuGRTransferClearing 
							where strTransferStorageTicket = @TransferStorageTicket 
								and strTransactionNumber like 'IR-%')

				and intTransactionTypeId = 4 
	
			if @Debug = 1 
			begin

				select 
					dblCost
					, ( dblQty  * ( (ABS(@Total_units_IR) - abs(@Total_units_Transfer)) / @Total_units_IR)) * dblCost * - 1
					, ( dblQty  ) * abs(@Cost_Transfer - dblCost) * case when dblCost > @Cost_Transfer then -1 else 1 end --as [IR Cost Adjustment]
		
				from tblICInventoryTransaction 
					where intTransactionId in ( select distinct intInventoryReceiptId 
							from vyuGRTransferClearing 
								where strTransferStorageTicket = @TransferStorageTicket and strTransactionNumber like 'IR-%')
					and intTransactionTypeId = 4 				
			end

	

		select 
				@Total_Amount_Excess_IR = sum ( ( dblQty  * ( (ABS(@Total_units_IR) - abs(@Total_units_Transfer)) / @Total_units_IR)) * dblCost * - 1 ) 
			, @Total_Amount_IR_Cost_Adjustment = sum ( ( dblQty  ) * abs(@Cost_Transfer - dblCost) * case when dblCost > @Cost_Transfer then -1 else 1 end )
			, @Total_units_IR_Excess = sum ( ( dblQty  * ( (ABS(@Total_units_IR) - abs(@Total_units_Transfer)) / @Total_units_IR)) * - 1 ) 
			,@Total_Amount_Excess_IR_Cost_Adjustment = sum (             
																(
																	( dblQty  * ( (ABS(@Total_units_IR) - abs(@Total_units_Transfer)) / @Total_units_IR)) * - 1 
																)
																*
																(
																	(abs(@Cost_Transfer - dblCost) * case when dblCost > @Cost_Transfer then -1 else 1 end )
																)

														) 
		from tblICInventoryTransaction 
				where intTransactionId in ( select distinct intInventoryReceiptId 
						from vyuGRTransferClearing 
							where strTransferStorageTicket = @TransferStorageTicket )

				and intTransactionTypeId = 4 
			
			
			select
				'Still need to prove the adjustment',
				@TransferStorageTicket as [Transction Ticket]
				,@TransactionReading as TransactionType
				,'Computation'
				, (@Total_Amount_Per_IR + @Total_Amount_Excess_IR + @Total_Amount_IR_Cost_Adjustment + (@Total_Amount_Excess_IR_Cost_Adjustment)) - abs(@Total_Amount_Transfer) as [REMAINING DIFFERENCE]
				,'Units'
				, @Total_units_IR as Total_Units_IR
				, @Total_units_Transfer as Total_Units_Transfer
				,abs(@Total_units_IR) - abs(@Total_units_Transfer) as Difference_IR_TRA		
				, @Total_units_IR_Excess as Total_Unit_IR_Excess
				,'Amount' 
				, @Total_Amount_Per_IR as Total_Amount_IR		
				, @Total_Amount_Excess_IR as Total_Amount_Excess_IR
				, @Total_Amount_IR_Cost_Adjustment as Total_Amount_IR_Cost_Adjustment
				, @Total_Amount_Excess_IR_Cost_Adjustment as Total_Amount_Excess_IR_Cost_Adjustment
				, @Total_Amount_Transfer as Total_Amount_Transfer	
				,'Cost'
				, @Cost_Transfer as Tranfer
				, @Cost_IR as IR
	end			



	if @OS_DP = 1
	begin
		--@TransferStorageTicket
		
		declare @CashPrice_OS_DP decimal(24,10)
		declare @OS_DP_Total_Amount_Transfer_Settlement decimal(24,10)
		declare @OS_DP_Total_Amount_Transfer_Transferred decimal(24,10)
		declare @OS_DP_Total_Amount_Transfer_Adjustment decimal(24,10)
		declare @OS_DP_Total_Amount_Transfer decimal(24,10)

		declare @OS_DP_Total_Units_Transfer decimal(24, 10)
		declare @OS_DP_Total_Units_Settlement decimal(24, 10)
		declare @OS_DP_Total_Units_Transferred decimal(24, 10)
		
		
		insert into @CustomerStorageIds ( i ) 
		select intToCustomerStorageId 
			from tblGRTransferStorageReference 
				where intTransferStorageId = @TransferStorageId

		--select * from tblGRStorageHistory where intCustomerStorageId in ( select intCustomerStorageId from tblGRStorageHistory where strTransferTicket = @TransferStorageTicket and strType = 'Transfer' )		
		--select * from tblGRStorageHistory where intCustomerStorageId in ( select intCustomerStorageId from tblGRStorageHistory where strTransferTicket = @TransferStorageTicket and strType = 'From Transfer' ) order by intStorageHistoryId	
		/**/
		select @CashPrice_OS_DP = (dblBasis + dblSettlementPrice) 
			from tblGRCustomerStorage where intCustomerStorageId in (
				select i from @CustomerStorageIds
			)
		--select * from vyuGRTransferClearing where strTransactionNumber = 'TRA-282'

		--intTransactionTypeId = 3 strType = 'Transfer'
		--intTransactionTypeId = 4 strType = 'Reverse Settlement' <<< this one should be negative
		--intTransactionTypeId = 4 strType = 'Settlement'
		
		declare @StorageSettlements table
		(
			dblUnits decimal(24,10)
			,dblCost decimal(24,10)
			,intSettleStorageId int
			,strSettleTicket nvarchar(100)
			,intBillId int
			,strVoucher nvarchar(100)		
			,strType nvarchar(100)
		)

		insert into @StorageSettlements
		(
			dblUnits
			, dblCost, intSettleStorageId, strSettleTicket, intBillId, strVoucher, strType
		)
		select 
			isnull(case when strType = 'Reverse Settlement' then abs(dblUnits) * -1 else abs(dblUnits) end, 0)
			, isnull(dblCost,0), intSettleStorageId, strSettleTicket, intBillId, strVoucher, strType
		from tblGRStorageHistory 
			where intCustomerStorageId in ( select intCustomerStorageId 
												from tblGRStorageHistory 
													where strTransferTicket = @TransferStorageTicket 
														and strType = 'From Transfer' ) 
				and intTransactionTypeId = 4
			order by intStorageHistoryId	
		
		select
			@OS_DP_Total_Amount_Transfer_Adjustment = sum ( (case when @CashPrice_OS_DP > dblCost then (@CashPrice_OS_DP - dblCost) * 1 else (dblCost - @CashPrice_OS_DP) * -1 end ) * dblUnits)
			,@OS_DP_Total_Amount_Transfer_Settlement = sum ( dblUnits * dblCost)
			,@OS_DP_Total_Units_Settlement = sum(dblUnits)
			--dblCost
			--, @CashPrice_OS_DP
			--, case when @CashPrice_OS_DP > dblCost then (@CashPrice_OS_DP - dblCost) * 1 else (dblCost - @CashPrice_OS_DP) * -1  end 			
			--, * 
		
		from @StorageSettlements
		/**/

		if @Debug = 1
		begin
			
			select
				( (case when @CashPrice_OS_DP > dblCost then (@CashPrice_OS_DP - dblCost) * 1 else (dblCost - @CashPrice_OS_DP) * -1 end ) * dblUnits)
				,( dblUnits * dblCost)
				,(dblUnits)
				,dblCost
				, @CashPrice_OS_DP
				, case when @CashPrice_OS_DP > dblCost then (@CashPrice_OS_DP - dblCost) * 1 else (dblCost - @CashPrice_OS_DP) * -1  end 			
				, * 		
			from @StorageSettlements

			select 
				strDescription
				,strComments
				,dblDebit
				,dblCredit
				,* 
			from tblGLDetail
				where strTransactionId = @TransferStorageTicket

		end
		--select @CashPrice_OS_DP, dblCost, * from @StorageSettlements


		declare @StorageTransfer table
		(
			dblUnits decimal(24,10)
			,dblCost decimal(24,10)
			,intSettleStorageId int
			,strSettleTicket nvarchar(100)
			,intBillId int
			,strVoucher nvarchar(100)		
			,strType nvarchar(100)
		)

		insert into @StorageTransfer
		(
			dblUnits
			, dblCost, intSettleStorageId, strSettleTicket, intBillId, strVoucher, strType
		)
		select 
			isnull(case when strType = 'Reverse Settlement' then abs(dblUnits) * -1 else abs(dblUnits) end , 0)
			, isnull(@CashPrice_OS_DP, 0), intSettleStorageId, strSettleTicket, intBillId, strVoucher, strType
		from tblGRStorageHistory 
			where intCustomerStorageId in ( select intCustomerStorageId 
												from tblGRStorageHistory 
													where strTransferTicket = @TransferStorageTicket 
														and strType = 'From Transfer' ) 
				and intTransactionTypeId = 3
				and strType = 'Transfer'
			order by intStorageHistoryId	
		
		select			
			@OS_DP_Total_Amount_Transfer_Transferred = sum ( dblUnits * dblCost)					
			,@OS_DP_Total_Units_Transferred = sum(dblUnits)
		from @StorageTransfer
		

		set @OS_DP_Total_Amount_Transfer_Adjustment = isnull(@OS_DP_Total_Amount_Transfer_Adjustment , 0)
		set @OS_DP_Total_Amount_Transfer_Settlement = isnull(@OS_DP_Total_Amount_Transfer_Settlement , 0)
		set @OS_DP_Total_Amount_Transfer_Transferred = isnull(@OS_DP_Total_Amount_Transfer_Transferred , 0)
		
		select @OS_DP_Total_Units_Transfer = sum(dblUnitQty)
			from tblGRTransferStorageReference 
				where intTransferStorageId = @TransferStorageId

		select @OS_DP_Total_Amount_Transfer = @OS_DP_Total_Units_Transfer * @CashPrice_OS_DP
		select
				@TransferStorageTicket as [Transction Ticket]
				,@TransactionReading as TransactionType
				,'Computed'
				,(@OS_DP_Total_Amount_Transfer_Adjustment  + @OS_DP_Total_Amount_Transfer_Settlement + @OS_DP_Total_Amount_Transfer_Transferred)
				 - 	@OS_DP_Total_Amount_Transfer as [Difference]
				,'Amount'
				,@OS_DP_Total_Amount_Transfer_Adjustment as Total_Adjustment
				,@OS_DP_Total_Amount_Transfer_Settlement as Total_Settlement
				,@OS_DP_Total_Amount_Transfer_Transferred as Total_Transferred
				,@OS_DP_Total_Amount_Transfer as Total_Transfer
				,'Units'
				,@OS_DP_Total_Units_Transfer as Total_TransferUnits
				,@OS_DP_Total_Units_Settlement as Total_Settlement
				,@OS_DP_Total_Units_Transferred as Total_Transferred
				,'Cost'
				,@CashPrice_OS_DP as Cost_Transfer


	end
end
go
