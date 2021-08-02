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
	--return 
	--Scale Ticket

	declare @strDistributionOption nvarchar(50)
	declare @intDeliverySheetId int
	declare @intContractId int

	select top 1 @strDistributionOption  = strDistributionOption  
		,@intDeliverySheetId = intDeliverySheetId
		,@intContractId = intContractId
		,@strDestTransactionNo = strTicketNumber
		,@strTicketStatus = strTicketStatus
		from tblSCTicket 
			where intTicketId = @intTransactionId

	/*
		@intTransactionType
			1 = Scale distribute / undistribute
			2 = Scale save
			3 = Scale Load Out 

	*/
	--start transaction type 1
	IF @intTransactionType = 1	
	BEGIN
		


		--if @intDeliverySheetId is not null
		--begin
		--	INSERT INTO @TransactionLinks (
		--			intSrcId,
		--			strSrcTransactionNo,
		--			strSrcModuleName,
		--			strSrcTransactionType,
				
		--			intDestId,
		--			strDestTransactionNo,
		--			strDestTransactionType,
		--			strDestModuleName,
		--			strOperation
		--		)
		--		SELECT
		--			--Source
		--			DeliverySheet.intDeliverySheetId,
		--			DeliverySheet.strDeliverySheetNumber,
		--			'Scale',
		--			'Delivery Sheet',

		--			Ticket.intTicketId,
		--			Ticket.strTicketNumber,
		--			'Scale',
		--			'Ticket',
		--			'Create'
		--		from tblSCTicket Ticket		
		--			join tblSCDeliverySheet DeliverySheet
		--				on Ticket.intDeliverySheetId = DeliverySheet.intDeliverySheetId
		--			where Ticket.intTicketId = @intTransactionId


		--end
		--start transaction type 1 and action 1
		IF @intAction = 1
		BEGIN
			--start for split distribution
			if @strDistributionOption = 'SPL'
			BEGIN
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
					'Ticket',
					'Ticket Management',

					Receipt.intInventoryReceiptId,
					Receipt.strReceiptNumber,
					'Inventory',
					'Receipt',
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

				
							
				if(@intContractId is not null)
				begin
					
					BEGIN
						EXEC uspICDeleteTransactionLinks 
							@intTransactionId = @intTransactionId
							,@strTransactionNo = @strDestTransactionNo
							,@strTransactionType = 'Ticket'
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
						'Contract',
						ContractType.strContractType,

						Ticket.intTicketId,
						Ticket.strTicketNumber,
						'Ticket',
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
						'Ticket',

						Receipt.intInventoryReceiptId,
						Receipt.strReceiptNumber,
						'Inventory',
						'Receipt',
						'Create'
					from tblSCTicket Ticket
						join tblICInventoryReceipt Receipt
							on Ticket.intInventoryReceiptId = Receipt.intInventoryReceiptId							
						where Ticket.intTicketId = @intTransactionId

				end

				
				

			END
			--end other distributin		
				
			--select * from @TransactionLinks
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
					,@strTransactionType = 'Ticket'
					,@strModuleName = 'Ticket Management'
			END
			--end delete transaction for ticket undistribute
			-- We need to re add it because the undistribute will also delete the initial linking of the ticket 
			EXEC uspSCAddTransactionLinks 
				@intTransactionType = 2, 
				@intTransactionId = @intTransactionId,
				@intAction = 1
			--INSERT INTO @ID
			--SELECT intID FROM dbo.fnGetRowsFromDelimitedValues(@strTransactionIds)
 
			--WHILE EXISTS(SELECT TOP 1 1 FROM @ID)
			--BEGIN
			--	SELECT TOP 1 @intDestId = B.intBillId, @strDestTransactionNo = B.strBillId
			--	FROM @ID ID
			--		INNER JOIN tblAPBill B ON B.intBillId = ID.intID
 
			--	IF @intDestId IS NULL
			--	BEGIN
			--		RAISERROR('Error occured while updating Voucher Traceability.', 16, 1);
			--		RETURN;
			--	END
			--	ELSE
			--	BEGIN
			--		EXEC uspICDeleteTransactionLinks @intDestId, @strDestTransactionNo, 'Voucher', 'Accounts Payable'
			--		DELETE FROM @ID WHERE intID = @intDestId
			--	END
			--END
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
				,@strTransactionType = 'Ticket'
				,@strModuleName = 'Ticket Management'

			--start - Checking for void status
			if @strTicketStatus <> 'V'
			begin
				--start checking if contract id is not null
				if(@intContractId is not null)
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
						'Contract',
						ContractType.strContractType,

						Ticket.intTicketId,
						Ticket.strTicketNumber,
						'Ticket',
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
				--start checking if contract id is not null

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
				,@strTransactionType = 'Ticket'
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
					'Ticket',
					'Ticket Management',

					Shipment.intInventoryShipmentId,
					Shipment.strShipmentNumber,
					'Inventory',
					'Shipment',
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

				
							
				if(@intContractId is not null)
				begin
					
					BEGIN
						EXEC uspICDeleteTransactionLinks 
							@intTransactionId = @intTransactionId
							,@strTransactionNo = @strDestTransactionNo
							,@strTransactionType = 'Ticket'
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
						'Contract',
						ContractType.strContractType,

						Ticket.intTicketId,
						Ticket.strTicketNumber,
						'Ticket',
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
						'Ticket',

						Shipment.intInventoryShipmentId,
						Shipment.strShipmentNumber,
						'Inventory',
						'Shipment',
						'Create'
					from tblSCTicket Ticket
						join tblICInventoryShipment Shipment
							on Ticket.intInventoryShipmentId = Shipment.intInventoryShipmentId
						where Ticket.intTicketId = @intTransactionId

				end

				
				

			END
			--end other distributin		
				
			--select * from @TransactionLinks
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
					,@strTransactionType = 'Ticket'
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
		
END

