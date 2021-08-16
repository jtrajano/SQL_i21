CREATE PROCEDURE [dbo].[uspSCAddTransactionLinks]
	@intTransactionType INT,
	@intTransactionId INT,
	@intAction INT = 1
AS
BEGIN
	DECLARE @TransactionLinks udtICTransactionLinks
	DECLARE @ID AS TABLE (intID INT)
	DECLARE @intDestId INT
		, @strDestTransactionNo NVARCHAR(100)
		, @strTicketStatus nvarchar(1)
	
	declare @strDistributionOption nvarchar(50)
	declare @intDeliverySheetId int
	declare @intContractId int
	declare @intLoadId int
	
	declare @SCALE_TICKET NVARCHAR(50) = 'Scale Ticket'
		,@INVENTORY_RECEIPT NVARCHAR(50) = 'Inventory Receipt'
		,@INVENTORY_SHIPMENT NVARCHAR(50) = 'Inventory Shipment'
		,@VOUCHER NVARCHAR(50) = 'Voucher'
		,@INVOICE NVARCHAR(50) = 'Invoice'
		,@CONTRACT NVARCHAR(50) = 'Contract'
		,@TRANSPORT_LOAD NVARCHAR(50) = 'Transport Load'
		,@STORAGE_TICKET_NUMBER NVARCHAR(50) = 'Storage Ticket Number'
		,@CUSTOMER_STORAGE NVARCHAR(50) = 'Customer Storage'
		,@CUSTOMER_TRANSFER NVARCHAR(50) = 'Customer Transfer'

	if @intTransactionType in (1, 2, 3)
	begin
	   
		select top 1 @strDistributionOption  = strDistributionOption  
			,@intDeliverySheetId = intDeliverySheetId
			,@intContractId = intContractId
			,@intLoadId = intLoadId
			,@strDestTransactionNo = strTicketNumber
			,@strTicketStatus = strTicketStatus
			from tblSCTicket 
				where intTicketId = @intTransactionId

	end
	/*
		===== Contract explanation =====
			--For contract distribution, we delete the current link saved then re add it again.
			--Contracts assigned in the ticket might be different from the one in the distribution.
			--So we delete the linking first then re add it again using the contract used table.

		===== end contract explanation =====


		===== Explanation for customer storage =====

			--It is aggreed that for customer storage we added CS in the beginning and in the end the actual storage id
			-- the issue with this is that a customer storage does not have its own unique string, it copies where it came from
			-- if a transaction is transferred to multiple entities it will have the same storage ticket number thus breaking the link
			-- for now we added the id to the storage ticket number

		===== end explanation for customer storage =====


	*/



	/*
		@intTransactionType
			1 = Scale distribute / undistribute
			2 = Scale save
			3 = Scale Load Out 
			4 = Settle Storage
			5 = Customer Storage
			6 = Contract Settlement
			7 = Transfer

	*/
	--start transaction type 1
	IF @intTransactionType = 1	
	BEGIN
		--start transaction type 1 and action 1
		IF @intAction = 1
		BEGIN
			--start for split distribution
			if @strDistributionOption = 'SPL'
			BEGIN
				--Get all the receipt involved in the split
				INSERT INTO @TransactionLinks (
					intSrcId,
					strSrcTransactionNo,
					strSrcTransactionType,
					strSrcModuleName,
					
				
					intDestId,
					strDestTransactionNo,
					strDestTransactionType,
					strDestModuleName,
					strOperation
				)
				SELECT
					--Source
					Ticket.intTicketId,
					Ticket.strTicketNumber,
					@SCALE_TICKET,
					'Ticket Management',

					Receipt.intInventoryReceiptId,
					Receipt.strReceiptNumber,
					@INVENTORY_RECEIPT,
					'Inventory',
					'Create'
				from tblSCTicket Ticket		
					join tblSCTicketSplit Split
						on Ticket.intTicketId = Split.intTicketId
					join tblICInventoryReceiptItem ReceiptItem
						on ReceiptItem.intSourceId = Ticket.intTicketId
					join tblICInventoryReceipt Receipt
						on ReceiptItem.intInventoryReceiptId = Receipt.intInventoryReceiptId
							and Receipt.intSourceType = 1
							and Receipt.intEntityVendorId = Split.intCustomerId
					where Ticket.intTicketId = @intTransactionId
			END
			--end split distribution
			ELSE
			--start other distirbution option
			BEGIN		
				--for contract distribution
				if @strDistributionOption = 'CNT' AND (@intContractId is not null)
				begin
					-- see contract explanation
					BEGIN
						EXEC uspICDeleteTransactionLinks 
							@intTransactionId = @intTransactionId
							,@strTransactionNo = @strDestTransactionNo
							,@strTransactionType = @SCALE_TICKET
							,@strModuleName = 'Ticket Management'
					END

					INSERT INTO @TransactionLinks (
						intSrcId,
						strSrcTransactionNo,
						strSrcModuleName,
						strSrcTransactionType,
				
						intDestId,
						strDestTransactionNo,
						strDestTransactionType,
						strDestModuleName,
						strOperation
					)
					SELECT
						--Source
						ContractHeader.intContractHeaderId,
						ContractHeader.strContractNumber,						
						'Contracts',
						@CONTRACT,

						Ticket.intTicketId,
						Ticket.strTicketNumber,
						@SCALE_TICKET,
						'Ticket Management',
						'Create'
					from tblSCTicket Ticket
						join tblSCTicketContractUsed TicketUsed
							on Ticket.intTicketId = TicketUsed.intTicketId
						join tblCTContractDetail ContractDetail
							on TicketUsed.intContractDetailId= ContractDetail.intContractDetailId
						join tblCTContractHeader ContractHeader
							on ContractDetail.intContractHeaderId = ContractHeader.intContractHeaderId
						join tblCTContractType ContractType
							on ContractHeader.intContractTypeId = ContractType.intContractTypeId
						where Ticket.intTicketId = @intTransactionId

				end

				--Links the ticket to receipt
				begin

					INSERT INTO @TransactionLinks (
						intSrcId,
						strSrcTransactionNo,
						strSrcModuleName,
						strSrcTransactionType,
				
						intDestId,
						strDestTransactionNo,
						strDestTransactionType,
						strDestModuleName,
						strOperation
					)
					SELECT
						--Source
						Ticket.intTicketId,
						Ticket.strTicketNumber,
						'Ticket Management',
						@SCALE_TICKET,

						Receipt.intInventoryReceiptId,
						Receipt.strReceiptNumber,
						@INVENTORY_RECEIPT,
						'Inventory',
						'Create'
					from tblSCTicket Ticket
						join tblICInventoryReceipt Receipt
							on Ticket.intInventoryReceiptId = Receipt.intInventoryReceiptId							
						where Ticket.intTicketId = @intTransactionId

				end

				
				

			END
			--end other distribution		
			
			--Call the procedure to add the linking
			EXEC uspICAddTransactionLinks @TransactionLinks
		END
		--end transaction type 1 and action 1
		ELSE
		--start other action type
		BEGIN
			--start delete transaction for ticket undistribute
			BEGIN
				EXEC uspICDeleteTransactionLinks 
					@intTransactionId = @intTransactionId
					,@strTransactionNo = @strDestTransactionNo
					,@strTransactionType = @SCALE_TICKET
					,@strModuleName = 'Ticket Management'
			END
			--end delete transaction for ticket undistribute
			-- We need to re add it because the undistribute will also delete the initial linking of the ticket 
			EXEC uspSCAddTransactionLinks 
				@intTransactionType = 2, 
				@intTransactionId = @intTransactionId,
				@intAction = 1
		END
		--end other action type

	END	
	--end transaction type 1
	   
	--Transaction Type 2
	ELSE IF @intTransactionType = 2
	BEGIN
		--Start Add/Update event for Ticket
		if @intAction = 1
		begin
			-- for now we are deleting the transaction link in every save
			EXEC uspICDeleteTransactionLinks 
				@intTransactionId = @intTransactionId
				,@strTransactionNo = @strDestTransactionNo
				,@strTransactionType = @SCALE_TICKET
				,@strModuleName = 'Ticket Management'

			--start - Checking for void status
			if @strTicketStatus <> 'V'
			begin
				--start checking if contract id is not null
				if @strDistributionOption = 'CNT' AND (@intContractId is not null)
				begin

					INSERT INTO @TransactionLinks (
						intSrcId,
						strSrcTransactionNo,
						strSrcModuleName,
						strSrcTransactionType,
				
						intDestId,
						strDestTransactionNo,
						strDestTransactionType,
						strDestModuleName,
						strOperation
					)
					SELECT
						--Source
						ContractHeader.intContractHeaderId,
						ContractHeader.strContractNumber,						
						'Contracts',
						@CONTRACT,

						Ticket.intTicketId,
						Ticket.strTicketNumber,
						@SCALE_TICKET,
						'Ticket Management',
						'Create'
					from tblSCTicket Ticket				
						join tblCTContractDetail ContractDetail
							on Ticket.intContractId= ContractDetail.intContractDetailId
						join tblCTContractHeader ContractHeader
							on ContractDetail.intContractHeaderId = ContractHeader.intContractHeaderId
						join tblCTContractType ContractType
							on ContractHeader.intContractTypeId = ContractType.intContractTypeId
						where Ticket.intTicketId = @intTransactionId
							
					EXEC uspICAddTransactionLinks @TransactionLinks
				end
				--end checking if contract id is not null
				-- start checking if lod distribution
				else if @strDistributionOption = 'LOD' AND (@intLoadId is not null)
				begin

					INSERT INTO @TransactionLinks (
						intSrcId,
						strSrcTransactionNo,
						strSrcModuleName,
						strSrcTransactionType,
				
						intDestId,
						strDestTransactionNo,
						strDestTransactionType,
						strDestModuleName,
						strOperation
					)
					SELECT
						--Source
						LoadShipment.intLoadId,
						LoadShipment.strLoadNumber,
						'Logistics',
						@TRANSPORT_LOAD,

						Ticket.intTicketId,
						Ticket.strTicketNumber,
						@SCALE_TICKET,
						'Ticket Management',
						'Create'
					from tblSCTicket Ticket				
						join tblLGLoad LoadShipment
							on Ticket.intLoadId = LoadShipment.intLoadId
						where Ticket.intTicketId = @intTransactionId
							
					EXEC uspICAddTransactionLinks @TransactionLinks
				end

				--end checking if lod distribution

			end
			--end checking for void status
			
		end
		--end add/update event for ticket
		else
		--start -- delete event for ticket
		BEGIN
			EXEC uspICDeleteTransactionLinks 
				@intTransactionId = @intTransactionId
				,@strTransactionNo = @strDestTransactionNo
				,@strTransactionType = @SCALE_TICKET
				,@strModuleName = 'Ticket Management'				
		END
		--end delete event for ticket
	END


	--End Transaction Type 2

	--Start Transaction Type 3 -- Load Out
	ELSE IF @intTransactionType = 3
	BEGIN
		--start transaction type 3 and action 1
		IF @intAction = 1
		BEGIN
			--start for split distribution
			if @strDistributionOption = 'SPL'
			BEGIN
				INSERT INTO @TransactionLinks (
					intSrcId,
					strSrcTransactionNo,
					strSrcTransactionType,
					strSrcModuleName,
				
					intDestId,
					strDestTransactionNo,
					strDestTransactionType,
					strDestModuleName,
					strOperation
				)
				SELECT
					--Source
					Ticket.intTicketId,
					Ticket.strTicketNumber,
					@SCALE_TICKET,
					'Ticket Management',

					Shipment.intInventoryShipmentId,
					Shipment.strShipmentNumber,
					@INVENTORY_SHIPMENT,
					'Inventory',
					'Create'
				from tblSCTicket Ticket		
					join tblSCTicketSplit Split
						on Ticket.intTicketId = Split.intTicketId
					join tblICInventoryShipmentItem ShipmentItem
						on ShipmentItem.intSourceId = Ticket.intTicketId
					join tblICInventoryShipment Shipment
						on ShipmentItem.intInventoryShipmentId = Shipment.intInventoryShipmentId
							and Shipment.intSourceType = 1
							and Shipment.intEntityCustomerId = Split.intCustomerId
					where Ticket.intTicketId = @intTransactionId
			END
			--end split distribution
			ELSE
			--start other distirbution option
			BEGIN
				
				-- start cnt distribution			
				-- see contract explanation
				if @strDistributionOption = 'CNT' and (@intContractId is not null)
				begin
					
					BEGIN
						EXEC uspICDeleteTransactionLinks 
							@intTransactionId = @intTransactionId
							,@strTransactionNo = @strDestTransactionNo
							,@strTransactionType = @SCALE_TICKET
							,@strModuleName = 'Ticket Management'
					END

					INSERT INTO @TransactionLinks (
						intSrcId,
						strSrcTransactionNo,
						strSrcModuleName,
						strSrcTransactionType,
				
						intDestId,
						strDestTransactionNo,
						strDestTransactionType,
						strDestModuleName,
						strOperation
					)
					SELECT
						--Source
						ContractHeader.intContractHeaderId,
						ContractHeader.strContractNumber,						
						'Contracts',
						@CONTRACT,

						Ticket.intTicketId,
						Ticket.strTicketNumber,
						@SCALE_TICKET,
						'Ticket Management',
						'Create'
					from tblSCTicket Ticket
						join tblSCTicketContractUsed TicketUsed
							on Ticket.intTicketId = TicketUsed.intTicketId
						join tblCTContractDetail ContractDetail
							on TicketUsed.intContractDetailId= ContractDetail.intContractDetailId
						join tblCTContractHeader ContractHeader
							on ContractDetail.intContractHeaderId = ContractHeader.intContractHeaderId
						join tblCTContractType ContractType
							on ContractHeader.intContractTypeId = ContractType.intContractTypeId
						where Ticket.intTicketId = @intTransactionId

				end


				begin

					INSERT INTO @TransactionLinks (
						intSrcId,
						strSrcTransactionNo,
						strSrcModuleName,
						strSrcTransactionType,
				
						intDestId,
						strDestTransactionNo,
						strDestTransactionType,
						strDestModuleName,
						strOperation
					)
					SELECT
						--Source
						Ticket.intTicketId,
						Ticket.strTicketNumber,
						'Ticket Management',
						@SCALE_TICKET,

						Shipment.intInventoryShipmentId,
						Shipment.strShipmentNumber,
						@INVENTORY_SHIPMENT,
						'Inventory',
						'Create'
					from tblSCTicket Ticket
						join tblICInventoryShipment Shipment
							on Ticket.intInventoryShipmentId = Shipment.intInventoryShipmentId
						where Ticket.intTicketId = @intTransactionId

				end
				--end
			END
			--end other distribution		
				
			EXEC uspICAddTransactionLinks @TransactionLinks
		END
		--end transaction type 3 and action 1
		ELSE
		--start other action type
		BEGIN
			--start delete transaction for ticket undistribute
			BEGIN
				EXEC uspICDeleteTransactionLinks 
					@intTransactionId = @intTransactionId
					,@strTransactionNo = @strDestTransactionNo
					,@strTransactionType = @SCALE_TICKET
					,@strModuleName = 'Ticket Management'
			END
			--end delete transaction for ticket undistribute

			-- We need to re add it because the undistribute will also delete the initial linking of the ticket 
			EXEC uspSCAddTransactionLinks 
				@intTransactionType = 2, 
				@intTransactionId = @intTransactionId,
				@intAction = 1
			
		END
		--end other action type

	END		
	--End Transaction Type 3


	--Start Transaction Type 4	-- Settle Storage
	ELSE IF @intTransactionType = 4
	BEGIN
		--start transaction type 4 and action 1
		IF @intAction = 1
		BEGIN
			-- see explanation for CS storage ticket number
			INSERT INTO @TransactionLinks (
				intSrcId,
				strSrcTransactionNo,
				strSrcModuleName,
				strSrcTransactionType,
				
				intDestId,
				strDestTransactionNo,
				strDestModuleName,
				strDestTransactionType,
				strOperation
			)
			select

			CustomerStorage.intCustomerStorageId
			,case when CustomerStorage.strStorageTicketNumber like 'CS%' then CustomerStorage.strStorageTicketNumber else 'CS-' + CustomerStorage.strStorageTicketNumber end  + '-('+ cast(CustomerStorage.intCustomerStorageId as nvarchar) + ')'
			,'Ticket Management'
			,@CUSTOMER_STORAGE

			,SettleStorage.intSettleStorageId
			,SettleStorage.strStorageTicket
			,'Ticket Management'
			,@STORAGE_TICKET_NUMBER
			,'Create'

	
			from tblGRSettleStorage SettleStorage
				join tblGRSettleStorageTicket StorageTicket
					on SettleStorage.intSettleStorageId = StorageTicket.intSettleStorageId
				join tblGRCustomerStorage CustomerStorage
					on StorageTicket.intCustomerStorageId = CustomerStorage.intCustomerStorageId
		
				where SettleStorage.intParentSettleStorageId = @intTransactionId	
					and CustomerStorage.intTicketId is not null
			
			EXEC uspICAddTransactionLinks @TransactionLinks
		END
		--end transaction type 3 and action 1
		ELSE if @intAction = 2 
		--start other action type
		BEGIN
			--start delete transaction for unposting a storage
			BEGIN
				
				select @strDestTransactionNo = strStorageTicket 
					from tblGRSettleStorage 
						where intSettleStorageId = @intTransactionId	
							

				EXEC uspICDeleteTransactionLinks 
					@intTransactionId = @intTransactionId
					,@strTransactionNo = @strDestTransactionNo
					,@strModuleName = 'Ticket Management'
					,@strTransactionType = @STORAGE_TICKET_NUMBER
			END
			--end delete transaction for ticket undistribute
			
		END
		--end other action type

	END		
	--end transaction type 4
	
	--Start Transaction Type 5	-- Customer storage
	ELSE IF @intTransactionType = 5
	BEGIN
		--start transaction type 5 and action 1
		IF @intAction = 1
		BEGIN
			INSERT INTO @TransactionLinks (
				intSrcId,
				strSrcTransactionNo,
				strSrcModuleName,
				strSrcTransactionType,
				
				intDestId,
				strDestTransactionNo,
				strDestModuleName,
				strDestTransactionType,
				strOperation
			)
			select

			Ticket.intTicketId
			,Ticket.strTicketNumber
			,'Ticket Management'
			,@SCALE_TICKET

			,CustomerStorage.intCustomerStorageId
			,case when CustomerStorage.strStorageTicketNumber like 'CS%' then CustomerStorage.strStorageTicketNumber else 'CS-' + CustomerStorage.strStorageTicketNumber end   + '-('+ cast(CustomerStorage.intCustomerStorageId as nvarchar) + ')'
			,'Ticket Management'
			,@CUSTOMER_STORAGE
			,'Create'

	
			from tblGRCustomerStorage CustomerStorage
				join tblSCTicket Ticket 
					on CustomerStorage.intTicketId = Ticket.intTicketId
		
				where CustomerStorage.intTicketId is not null
					and CustomerStorage.intCustomerStorageId = @intTransactionId
			

			EXEC uspICAddTransactionLinks @TransactionLinks
		END
		--end transaction type 3 and action 1
		ELSE
		--start other action type
		BEGIN
			--start unposting of storage
			select @strDestTransactionNo = case when strStorageTicketNumber like 'CS%' 
												then strStorageTicketNumber 
											else 
												'CS-' + strStorageTicketNumber  
											end   + '-('+ cast(intCustomerStorageId as nvarchar) + ')'
				from tblGRCustomerStorage 
					where intCustomerStorageId = @intTransactionId
			BEGIN
				EXEC uspICDeleteTransactionLinks 
					@intTransactionId = @intTransactionId
					,@strTransactionNo = @strDestTransactionNo
					,@strTransactionType = @CUSTOMER_STORAGE
					,@strModuleName = 'Ticket Management'
			END
			--end delete transaction for ticket undistribute
			
		END
		--end other action type

	END		
	--end transaction type 5

	--Start Transaction Type 6	-- Contract Settlement
	ELSE IF @intTransactionType = 6
	BEGIN
		--start transaction type 6 and action 1
		IF @intAction = 1
		BEGIN
			--The expecation here is 
			-- Customer Storage > Settlement
			-- Contract > Settlement 
			-- so we have two linking
			INSERT INTO @TransactionLinks (
				intSrcId,
				strSrcTransactionNo,
				strSrcModuleName,
				strSrcTransactionType,
				
				intDestId,
				strDestTransactionNo,
				strDestModuleName,
				strDestTransactionType,
				strOperation
			)
			select
				Distinct
				CustomerStorage.intCustomerStorageId
				,case when CustomerStorage.strStorageTicketNumber like 'CS%' then CustomerStorage.strStorageTicketNumber else 'CS-' + CustomerStorage.strStorageTicketNumber end   + '-('+ cast(CustomerStorage.intCustomerStorageId as nvarchar) + ')'
				,'Ticket Management'
				,@CUSTOMER_STORAGE

				,SettleStorage.intSettleStorageId
				,SettleStorage.strStorageTicket
				,'Ticket Management'
				,@STORAGE_TICKET_NUMBER
				,'Create'

	
			from tblGRStorageHistory History
				join tblGRSettleStorage SettleStorage
					on History.intSettleStorageId = SettleStorage.intSettleStorageId
				join tblGRCustomerStorage CustomerStorage
					on CustomerStorage.intCustomerStorageId = History.intCustomerStorageId
				join tblCTContractHeader ContractHeader
					on History.intContractHeaderId = ContractHeader.intContractHeaderId
				where History.intSettleStorageId = @intTransactionId
			union all			
			select
				Distinct
				ContractHeader.intContractHeaderId
				,ContractHeader.strContractNumber
				,'Contracts'
				,@CONTRACT

				,SettleStorage.intSettleStorageId
				,SettleStorage.strStorageTicket
				,'Ticket Management'
				,@STORAGE_TICKET_NUMBER
				,'Create'

	
			from tblGRStorageHistory History
				join tblGRSettleStorage SettleStorage
					on History.intSettleStorageId = SettleStorage.intSettleStorageId
				join tblGRCustomerStorage CustomerStorage
					on CustomerStorage.intCustomerStorageId = History.intCustomerStorageId
				join tblCTContractHeader ContractHeader
					on History.intContractHeaderId = ContractHeader.intContractHeaderId
				where History.intSettleStorageId = @intTransactionId

			
			EXEC uspICAddTransactionLinks @TransactionLinks
		END
		--end transaction type 3 and action 1
		ELSE
		--start other action type
		BEGIN			
			BEGIN
				print 'not yet implemented'				
			END
		END
		--end other action type

	END		
	--end transaction type 6

	--Start Transaction Type 7	-- Transfer
	ELSE IF @intTransactionType = 7
	BEGIN
		--start transaction type 7 and action 1
		IF @intAction = 1
		BEGIN
			--Expectation here is 
			-- From CS - TRA
			-- TRA - To CS
			INSERT INTO @TransactionLinks (
				intSrcId,
				strSrcTransactionNo,
				strSrcModuleName,
				strSrcTransactionType,
				
				intDestId,
				strDestTransactionNo,
				strDestModuleName,
				strDestTransactionType,
				strOperation
			)			
			select 
				CustomerStorage.intCustomerStorageId
				,case when CustomerStorage.strStorageTicketNumber like 'CS%' then CustomerStorage.strStorageTicketNumber else 'CS-' + CustomerStorage.strStorageTicketNumber end   + '-('+ cast(CustomerStorage.intCustomerStorageId as nvarchar) + ')'
				,'Ticket Management'
				,@CUSTOMER_STORAGE

				,TransferStorage.intTransferStorageId
				,TransferStorage.strTransferStorageTicket
				,'Ticket Management'
				,@CUSTOMER_TRANSFER
				,'Create'
	
	
				from tblGRTransferStorage TransferStorage
					join tblGRTransferStorageReference TransferReference
						on TransferStorage.intTransferStorageId = TransferReference.intTransferStorageId
					join tblGRCustomerStorage CustomerStorage
						on TransferReference.intSourceCustomerStorageId = CustomerStorage.intCustomerStorageId
				where TransferStorage.intTransferStorageId = @intTransactionId

			union all
			select 
				TransferStorage.intTransferStorageId
				,TransferStorage.strTransferStorageTicket
				,'Ticket Management'
				,@CUSTOMER_TRANSFER
	
				,CustomerStorage.intCustomerStorageId
				,case when CustomerStorage.strStorageTicketNumber like 'CS%' then CustomerStorage.strStorageTicketNumber else 'CS-' + CustomerStorage.strStorageTicketNumber end   + '-('+ cast(CustomerStorage.intCustomerStorageId as nvarchar) + ')'
				,'Ticket Management'
				,@CUSTOMER_STORAGE
				,'Create'
	
				from tblGRTransferStorage TransferStorage
					join tblGRTransferStorageReference TransferReference
						on TransferStorage.intTransferStorageId = TransferReference.intTransferStorageId
					join tblGRCustomerStorage CustomerStorage
						on TransferReference.intToCustomerStorageId= CustomerStorage.intCustomerStorageId
				where TransferStorage.intTransferStorageId = @intTransactionId


			
			EXEC uspICAddTransactionLinks @TransactionLinks
		END
		--end transaction type 7 and action 1
		ELSE
		--start other action type
		BEGIN
			--start unposting of transfer
			BEGIN
				
				select @strDestTransactionNo = strTransferStorageTicket  
					from tblGRTransferStorage
						where intTransferStorageId = @intTransactionId
			
				BEGIN
					EXEC uspICDeleteTransactionLinks 
						@intTransactionId = @intTransactionId
						,@strTransactionNo = @strDestTransactionNo
						,@strTransactionType = @CUSTOMER_TRANSFER
						,@strModuleName = 'Ticket Management'
				END
			
			END
			--end unposting of transfer
			
		END
		--end other action type

	END		
	--end transaction type 7


		
END

