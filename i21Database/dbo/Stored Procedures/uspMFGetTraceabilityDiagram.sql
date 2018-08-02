CREATE PROCEDURE [dbo].[uspMFGetTraceabilityDiagram]
	@intLotId int,
	@intLocationId int,
	@intDirectionId int,
	@ysnParentLot bit=0,
	@intObjectTypeId INT = 4
AS
SET NOCOUNT ON;

Declare @intRowCount int
Declare @intMaxRecordCount int
Declare @intId int
Declare @intParentId int
Declare @strType nvarchar(2)
Declare @intContractId int
Declare @intShipmentId int
Declare @intContainerId int
Declare @intNoOfShipRecord int
Declare @intNoOfShipRecordCounter int
Declare @intNoOfShipRecordParentCounter int
		 
Declare @tblTemp AS table
(
	intRecordId int,
	intParentId int,
	strTransactionName nvarchar(50),
	intLotId int,
	strLotNumber nvarchar(50),
	strLotAlias nvarchar(50),
	dblQuantity numeric(18,6),
	strUOM nvarchar(50),
	dtmTransactionDate DateTime,
	intItemId int,
	strItemNo nvarchar(50),
	strItemDesc nvarchar(200),
	intCategoryId int,
	strCategoryCode nvarchar(50),
	intParentLotId int,
	strProcessName nvarchar(50),
	strType nvarchar(2),
	strVendor nvarchar(200),
	strCustomer nvarchar(200),
	intAttributeTypeId int Default 0,
	intImageTypeId int Default 0
)

Declare @tblData AS table
(
	intRecordId int,
	intParentId int,
	strTransactionName nvarchar(50),
	intLotId int,
	strLotNumber nvarchar(50),
	strLotAlias nvarchar(50),
	dblQuantity numeric(18,6),
	strUOM nvarchar(50),
	dtmTransactionDate DateTime,
	intItemId int,
	strItemNo nvarchar(50),
	strItemDesc nvarchar(200),
	intCategoryId int,
	strCategoryCode nvarchar(50),
	intParentLotId int,
	strProcessName nvarchar(50),
	strType nvarchar(2),
	strVendor nvarchar(200),
	strCustomer nvarchar(200),
	intAttributeTypeId int Default 0,
	intImageTypeId int Default 0
)

Declare @tblNodeData AS table
(
	intRecordId int,
	intParentId int,
	strTransactionName nvarchar(50),
	intLotId int,
	strLotNumber nvarchar(50),
	strLotAlias nvarchar(50),
	dblQuantity numeric(18,6),
	strUOM nvarchar(50),
	dtmTransactionDate DateTime,
	intItemId int,
	strItemNo nvarchar(50),
	strItemDesc nvarchar(200),
	intCategoryId int,
	strCategoryCode nvarchar(50),
	intParentLotId int,
	strProcessName nvarchar(50),
	strType nvarchar(2),
	strVendor nvarchar(200),
	strCustomer nvarchar(200),
	intAttributeTypeId int Default 0,
	intImageTypeId int Default 0
)

Declare @tblNodeDataFinal AS table
(
	[key] int,
	intRecordId int,
	intParentId int,
	strTransactionName nvarchar(50),
	intLotId int,
	strLotNumber nvarchar(50),
	strLotAlias nvarchar(50),
	dblQuantity numeric(18,6),
	strUOM nvarchar(50),
	dtmTransactionDate DateTime,
	intItemId int,
	strItemNo nvarchar(50),
	strItemDesc nvarchar(200),
	intCategoryId int,
	strCategoryCode nvarchar(50),
	intParentLotId int,
	strProcessName nvarchar(50),
	strType nvarchar(2),
	strVendor nvarchar(200),
	strCustomer nvarchar(200),
	intAttributeTypeId int Default 0,
	intImageTypeId int Default 0,
	strImage nvarchar(max),
	strNodeText nvarchar(max),
	strToolTip nvarchar(max),
	intControlPointId int,
	ysnExcludedNode bit default 0,
	intGroupRowNo int
)

Declare @tblLinkData AS table
(
	intFromRecordId int,
	intToRecordId int,
	strTransactionName nvarchar(50)
)

--Forward
If @intDirectionId=1
Begin
	--Contract
	If @intObjectTypeId=1
	Begin
		Insert Into @tblNodeData(strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
		dblQuantity,strUOM,dtmTransactionDate,strVendor,intImageTypeId,strType)
		Exec uspMFGetTraceabilityContractDetail @intLotId,@intDirectionId

		Update @tblNodeData Set intRecordId=1,intParentId=0
	End

	--In Shipment
	If @intObjectTypeId=2
	Begin
		Select TOP 1 @intContractId=intPContractHeaderId From vyuLGLoadContainerReceiptContracts Where intLoadId=@intLotId

		--Contract
		Insert Into @tblNodeData(strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
		dblQuantity,strUOM,dtmTransactionDate,strVendor,intImageTypeId,strType)
		Exec uspMFGetTraceabilityContractDetail @intContractId,@intDirectionId

		Update @tblNodeData Set intRecordId=1,intParentId=0

		--In Shipment
		Insert Into @tblNodeData(strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
		dblQuantity,strUOM,dtmTransactionDate,strVendor,strType)
		Exec uspMFGetTraceabilityInboundShipmentDetail @intLotId,@intDirectionId

		Update @tblNodeData Set intRecordId=2,intParentId=1 Where intParentId is null
	End

	--Container
	If @intObjectTypeId=3
	Begin
		Select TOP 1 @intContractId=intPContractHeaderId,@intShipmentId=intLoadId From vyuLGLoadContainerReceiptContracts Where intLoadContainerId=@intLotId

		--Contract
		Insert Into @tblNodeData(strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
		dblQuantity,strUOM,dtmTransactionDate,strVendor,intImageTypeId,strType)
		Exec uspMFGetTraceabilityContractDetail @intContractId,@intDirectionId

		Update @tblNodeData Set intRecordId=1,intParentId=0

		--In Shipment
		Insert Into @tblNodeData(strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
		dblQuantity,strUOM,dtmTransactionDate,strVendor,strType)
		Exec uspMFGetTraceabilityInboundShipmentDetail @intShipmentId,@intDirectionId

		Update @tblNodeData Set intRecordId=2,intParentId=1 Where intParentId is null

		--Container
		Insert Into @tblNodeData(strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
		dblQuantity,strUOM,dtmTransactionDate,intParentLotId,strVendor,strType)
		Exec uspMFGetTraceabilityContainerDetail @intLotId,@intDirectionId

		Update @tblNodeData Set intRecordId=3,intParentId=2 Where intParentId is null
	End

	--Lot
	If @intObjectTypeId=4
	Begin
		--If Lot is received via Contract show contract
		Select TOP 1 @intContractId=ISNULL(ri.intOrderId,0),@intShipmentId=ISNULL(ld.intLoadId,0),@intContainerId=ISNULL(ri.intContainerId,0)  
		From tblICInventoryReceiptItem ri Join tblICInventoryReceiptItemLot rl on ri.intInventoryReceiptItemId=rl.intInventoryReceiptItemId 
		Join tblICInventoryReceipt rh on ri.intInventoryReceiptId=rh.intInventoryReceiptId 
		Left Join tblLGLoadDetail ld on ri.intSourceId=ld.intLoadDetailId
		join tblICLot l on rl.intLotId=l.intLotId
		Where l.strLotNumber=(select top 1 strLotNumber from tblICLot where intLotId=@intLotId) And rh.strReceiptType='Purchase Contract'

		--Contract
		If @intContractId > 0
			Begin
				Insert Into @tblNodeData(strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
				dblQuantity,strUOM,dtmTransactionDate,strVendor,intImageTypeId,strType)
				Exec uspMFGetTraceabilityContractDetail @intContractId,@intDirectionId

				Update @tblNodeData Set intRecordId=1,intParentId=0
			End

		--Shipment
		If @intShipmentId > 0
			Begin
				Insert Into @tblNodeData(strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
				dblQuantity,strUOM,dtmTransactionDate,strVendor,strType)
				Exec uspMFGetTraceabilityInboundShipmentDetail @intShipmentId,@intDirectionId

				Update @tblNodeData Set intRecordId=2,intParentId=1 Where intParentId is null
			End

		--Container
		If @intContainerId > 0
			Begin
				Insert Into @tblNodeData(strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
				dblQuantity,strUOM,dtmTransactionDate,intParentLotId,strVendor,strType)
				Exec uspMFGetTraceabilityContainerDetail @intContainerId,@intDirectionId

				Update @tblNodeData Set intRecordId=3,intParentId=2 Where intParentId is null
			End

		--Receipt
		Insert Into @tblNodeData(strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
		dblQuantity,strUOM,dtmTransactionDate,intParentLotId,strVendor,strType)
		Exec uspMFGetTraceabilityLotReceiptDetail @intLotId,@ysnParentLot

		--If @intContractId > 0
		--	Update @tblNodeData Set intRecordId=2,intParentId=1,strTransactionName='Contract' Where intParentId is null
		--Else
		--	Update @tblNodeData Set intRecordId=1,intParentId=0 Where intParentId is null

		--Update RecordId, ParentId
		SELECT @intMaxRecordCount = ISNULL(Max(intRecordId),0) + 1,@intParentId = ISNULL(Max(intRecordId),0) FROM @tblNodeData
		Update @tblNodeData Set intRecordId=@intMaxRecordCount,intParentId=@intParentId Where intParentId is null

		--Lot Detail
		Insert Into @tblNodeData(strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
		dblQuantity,strUOM,dtmTransactionDate,intParentLotId,intImageTypeId)
		Exec uspMFGetTraceabilityLotDetail @intLotId,@intDirectionId,@ysnParentLot

		--Update @tblNodeData Set intRecordId=2,intParentId=1,strType='L' Where intParentId is null
		--If @intContractId > 0
		--	Update @tblNodeData Set intRecordId=3,intParentId=2,strType='L' Where intParentId is null
		--Else
		--	Update @tblNodeData Set intRecordId=2,intParentId=1,strType='L' Where intParentId is null

		--Update RecordId, ParentId
		SELECT @intMaxRecordCount = ISNULL(Max(intRecordId),0) + 1,@intParentId = ISNULL(Max(intRecordId),0) FROM @tblNodeData
		Update @tblNodeData Set intRecordId=@intMaxRecordCount,intParentId=@intParentId,strType='L' Where intParentId is null

	End

	--Receipt
	If @intObjectTypeId=6
	Begin
		Select TOP 1 @intContractId=lg.intPContractHeaderId,@intShipmentId=lg.intLoadId,@intContainerId=lg.intLoadContainerId 
		From vyuLGLoadContainerReceiptContracts lg Join tblICInventoryReceiptItem ri on lg.intLoadContainerId=ri.intContainerId 
		Where ri.intInventoryReceiptId=@intLotId

		--Contract -> In Shipment -> Container ->Receipt
		If ISNULL(@intContainerId,0)>0
		Begin

			--Contract
			Insert Into @tblNodeData(strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
			dblQuantity,strUOM,dtmTransactionDate,strVendor,intImageTypeId,strType)
			Exec uspMFGetTraceabilityContractDetail @intContractId,@intDirectionId

			Update @tblNodeData Set intRecordId=1,intParentId=0

			--In Shipment
			Insert Into @tblNodeData(strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
			dblQuantity,strUOM,dtmTransactionDate,strVendor,strType)
			Exec uspMFGetTraceabilityInboundShipmentDetail @intShipmentId,@intDirectionId

			Update @tblNodeData Set intRecordId=2,intParentId=1 Where intParentId is null

			--Container
			Insert Into @tblNodeData(strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
			dblQuantity,strUOM,dtmTransactionDate,intParentLotId,strVendor,strType)
			Exec uspMFGetTraceabilityContainerDetail @intContainerId,@intDirectionId

			Update @tblNodeData Set intRecordId=3,intParentId=2 Where intParentId is null

		End
		
		--Contract -> Receipt
		If ISNULL(@intContainerId,0)=0
		Begin

			Select TOP 1 @intContractId = ISNULL(ri.intOrderId,0)
			From tblICInventoryReceiptItem ri 
			Join tblICInventoryReceipt rh on ri.intInventoryReceiptId=rh.intInventoryReceiptId 
			Where rh.intInventoryReceiptId=@intLotId And rh.strReceiptType='Purchase Contract'

			If ISNULL(@intContractId,0)>0
			Begin
				Select TOP 1 @intContractId=lg.intPContractHeaderId,@intShipmentId=lg.intLoadId,@intContainerId=lg.intLoadContainerId 
				From vyuLGLoadContainerReceiptContracts lg Join tblICInventoryReceiptItem ri on lg.intLoadContainerId=ri.intContainerId 
				Where ri.intInventoryReceiptId=@intLotId

				--Contract
				Insert Into @tblNodeData(strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
				dblQuantity,strUOM,dtmTransactionDate,strVendor,intImageTypeId,strType)
				Exec uspMFGetTraceabilityContractDetail @intContractId,@intDirectionId

				Update @tblNodeData Set intRecordId=1,intParentId=0

				--Receipt
				Insert Into @tblNodeData(strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
				dblQuantity,strUOM,dtmTransactionDate,strVendor,strType)
				Exec uspMFGetTraceabilityReceiptDetail @intLotId

				Update @tblNodeData Set intRecordId=2,intParentId=1 Where intParentId is null
			End
		End

		--Receipt Only
		If ISNULL(@intContractId,0)=0
		Begin
			--Receipt
			Insert Into @tblNodeData(strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
			dblQuantity,strUOM,dtmTransactionDate,strVendor,strType)
			Exec uspMFGetTraceabilityReceiptDetail @intLotId

			Update @tblNodeData Set intRecordId=1,intParentId=0

		End
	End

	--Counter Data for the while loop
	SELECT @intMaxRecordCount = Max(intRecordId),@intParentId = Max(intRecordId) FROM @tblNodeData

	Insert Into @tblTemp(intRecordId,intParentId,strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
	dblQuantity,strUOM,dtmTransactionDate,intParentLotId,strType)
	Select TOP 1 intRecordId,intParentId,strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
	dblQuantity,strUOM,dtmTransactionDate,intParentLotId,strType From @tblNodeData Order By intRecordId Desc

	Set @intRowCount=1

	WHILE (@intRowCount > 0)
	BEGIN    
		DECLARE @FCUR CURSOR       
		SET @FCUR = CURSOR FOR SELECT DISTINCT intLotId,intRecordId,strType FROM @tblTemp      

		OPEN @FCUR      
		FETCH NEXT FROM @FCUR INTO @intId,@intParentId,@strType
			WHILE @@FETCH_STATUS = 0      
			BEGIN     

				--Inbound Shipment From Contract
				If @strType='C'
					Insert Into @tblData(strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
					dblQuantity,strUOM,dtmTransactionDate,intParentLotId,strVendor,strType)
					Exec uspMFGetTraceabilityInboundShipmentFromContract @intId

				--Container From Inbound Shipment
				If @strType='IS'
					Insert Into @tblData(strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
					dblQuantity,strUOM,dtmTransactionDate,intParentLotId,strVendor,strType)
					Exec uspMFGetTraceabilityContainerFromInboundShipment @intId

				--Receipt From Container
				If @strType='CN'
					Insert Into @tblData(strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
					dblQuantity,strUOM,dtmTransactionDate,intParentLotId,strVendor,strType)
					Exec uspMFGetTraceabilityReceiptFromContainer @intId

				--Receipt From Contract
				If @strType='C' AND NOT EXISTS (Select 1 From @tblData Where strType='IS')
					Insert Into @tblData(strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
					dblQuantity,strUOM,dtmTransactionDate,intParentLotId,strVendor,strType)
					Exec uspMFGetTraceabilityReceiptFromContract @intId

				--Lots From Receipt
				If @strType='R'
					Insert Into @tblData(strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
					dblQuantity,strUOM,dtmTransactionDate,intParentLotId,strVendor,strType)
					Exec uspMFGetTraceabilityLotsFromReceipt @intId,@ysnParentLot

				-- From Lot to WorkOrders
				If @strType='L'
					Begin
						Insert Into @tblData(strTransactionName,intLotId,strLotNumber,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
						dblQuantity,strUOM,dtmTransactionDate,strProcessName,strType,intAttributeTypeId)
						Exec uspMFGetTraceabilityWorkOrderDetail @intId,@intDirectionId,@ysnParentLot

						--Remove circular Reference, Remove the WO if exists
						If Exists (Select 1 from @tblData Where  intLotId in (Select intLotId from @tblNodeData Where strType='W'))
							Delete From @tblData
					End

				-- WorkOrder Output details
				If @strType='W'  			
					Insert Into @tblData(strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
					dblQuantity,strUOM,dtmTransactionDate,intParentLotId,strType,intAttributeTypeId,intImageTypeId)
					Exec uspMFGetTraceabilityWorkOrderOutputDetail @intId,@ysnParentLot
			
				-- Lot Split
				If @strType='L'
					Insert Into @tblData(strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
					dblQuantity,strUOM,dtmTransactionDate,intParentLotId,strType,intImageTypeId)
					Exec uspMFGetTraceabilityLotSplitDetail @intId,@intDirectionId,@ysnParentLot

				-- Lot Ship
				If @strType='L'
				Begin
					Insert Into @tblData(strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
					dblQuantity,strUOM,dtmTransactionDate,strCustomer,strType)
					Exec uspMFGetTraceabilityLotShipDetail @intId,@ysnParentLot

					INSERT INTO @tblData (
						strTransactionName
						,intLotId
						,strLotNumber
						,strLotAlias
						,intItemId
						,strItemNo
						,strItemDesc
						,intCategoryId
						,strCategoryCode
						,dblQuantity
						,strUOM
						,dtmTransactionDate
						,strCustomer
						,strType
						)
					EXEC uspMFGetTraceabilityLotOutboundShipDetail @intId
						,@ysnParentLot
				End
				-- Sales Order & Invoice from Shipment
				If @strType='S'
					Begin
						--SO
						Insert Into @tblData(strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
						dblQuantity,strUOM,dtmTransactionDate,strCustomer,strType)
						Exec uspMFGetTraceabilitySalesOrderFromShipment @intId

						--Invoice
						Insert Into @tblData(strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
						dblQuantity,strUOM,dtmTransactionDate,strCustomer,strType)
						Exec uspMFGetTraceabilityInvoiceFromShipment @intId
					End

				UPDATE @tblData SET intParentId = @intParentId WHERE  intParentId IS NULL        

			FETCH NEXT FROM @FCUR INTO @intId,@intParentId,@strType      
			END

		DELETE FROM @tblTemp      

		Insert Into @tblTemp(intRecordId,intParentId,strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
		dblQuantity,strUOM,dtmTransactionDate,intParentLotId,strVendor,strCustomer,strProcessName,strType,intAttributeTypeId,intImageTypeId)
		Select (@intMaxRecordCount + ROW_NUMBER() OVER (ORDER BY intLotId ASC)) AS intRecordId,intParentId,strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
		SUM(dblQuantity),strUOM,dtmTransactionDate,intParentLotId,strVendor,strCustomer,strProcessName,strType,intAttributeTypeId,intImageTypeId 
		From @tblData Group By intParentId,strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
		strUOM,dtmTransactionDate,intParentLotId,strVendor,strCustomer,strProcessName,strType,intAttributeTypeId,intImageTypeId

		--Node Date
		Insert Into @tblNodeData(intRecordId,intParentId,strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
		dblQuantity,strUOM,dtmTransactionDate,intParentLotId,strVendor,strCustomer,strProcessName,strType,intAttributeTypeId,intImageTypeId)
		Select intRecordId,intParentId,strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
		dblQuantity,strUOM,dtmTransactionDate,intParentLotId,strVendor,strCustomer,strProcessName,strType,intAttributeTypeId,intImageTypeId 
		From @tblTemp

		DELETE FROM @tblData

		SELECT @intMaxRecordCount = Max(intRecordId) FROM @tblTemp     

		--Delete From @tblTemp Where strTransactionName='Ship'

		SELECT @intRowCount = COUNT(1) FROM @tblTemp      
	END

	--Duplicate Shipments for linking if SO exists
	If Exists (Select 1 From @tblNodeData Where strType='SO')
	Begin
		SELECT @intMaxRecordCount = Max(intRecordId) FROM @tblNodeData 

		--Get the Corresponding Ship records for the SO and add it again
		Insert Into @tblNodeData(intRecordId,intParentId,strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
		dblQuantity,strUOM,dtmTransactionDate,intParentLotId,strVendor,strCustomer,strProcessName,strType,intAttributeTypeId,intImageTypeId)
		Select (@intMaxRecordCount + ROW_NUMBER() OVER (ORDER BY n1.intLotId ASC)) AS intRecordId,n2.intRecordId,n1.strTransactionName,n1.intLotId,n1.strLotNumber,n1.strLotAlias,n1.intItemId,n1.strItemNo,n1.strItemDesc,n1.intCategoryId,n1.strCategoryCode,
		n1.dblQuantity,n1.strUOM,n1.dtmTransactionDate,n1.intParentLotId,n1.strVendor,n1.strCustomer,n1.strProcessName,n1.strType,n1.intAttributeTypeId,n1.intImageTypeId 
		From @tblNodeData n1 Join (Select * From @tblNodeData Where strType='SO') n2 on n1.intRecordId=n2.intParentId

		Update @tblNodeData Set intParentId=0 Where strType='SO'
	End
End

--Reverse
If @intDirectionId=2
Begin
	--Lot
	If @intObjectTypeId = 4
	Begin
		--Ship
		Insert Into @tblNodeData(strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
						dblQuantity,strUOM,dtmTransactionDate,strCustomer,strType)
		Exec uspMFGetTraceabilityLotShipDetail @intLotId,@ysnParentLot

		INSERT INTO @tblNodeData (
			strTransactionName
			,intLotId
			,strLotNumber
			,strLotAlias
			,intItemId
			,strItemNo
			,strItemDesc
			,intCategoryId
			,strCategoryCode
			,dblQuantity
			,strUOM
			,dtmTransactionDate
			,strCustomer
			,strType
			)
		EXEC uspMFGetTraceabilityLotOutboundShipDetail @intLotId
			,@ysnParentLot

		--Generate RecordId for all the Shipments (include multiple shipments)
		UPDATE t
			SET t.intRecordId = t.intRowNo,t.intParentId=0
			FROM (
				  SELECT intRecordId,intParentId,ROW_NUMBER() OVER (ORDER BY intLotId) AS intRowNo
				  FROM @tblNodeData
				  ) t

		Select @intNoOfShipRecord=count(1) From @tblNodeData
		Set @intNoOfShipRecordCounter=@intNoOfShipRecord
		Set @intNoOfShipRecordParentCounter=1
		
		If Isnull(@intNoOfShipRecordCounter,0)=0 Set @intNoOfShipRecordCounter=1

		--Lot Detail -- Add one or many depending on no of ship records
		While (@intNoOfShipRecordCounter>0)
		Begin
			Insert Into @tblNodeData(strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
			dblQuantity,strUOM,dtmTransactionDate,intParentLotId,intImageTypeId)
			Exec uspMFGetTraceabilityLotDetail @intLotId,@intDirectionId,@ysnParentLot

			Update @tblNodeData Set intRecordId=(Select case when count(1)=1 then 2 else count(1) end from @tblNodeData),intParentId=@intNoOfShipRecordParentCounter,strType='L' Where intParentId is null

			-- Invoice from Shipment
			Begin
				--Get ShipmentId to find if invoice exists
				If @intId is null
					Select TOP 1 @intId=intLotId From @tblNodeData
				Else
					Select TOP 1 @intId=intLotId From @tblNodeData Where intLotId<>@intId

				--Invoice
				Insert Into @tblData(strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
				dblQuantity,strUOM,dtmTransactionDate,strCustomer,strType)
				Exec uspMFGetTraceabilityInvoiceFromShipment @intId
			
				--update ShipmentId in intParentLotId for Invoice used in getting ParentId in case Invoice exists
				Update @tblData Set intParentLotId=@intId Where intParentLotId is null

				--update ShipmentId in intAttributeTypeId for Lot used in getting ParentId in case Invoice exists
				Update @tblNodeData Set intAttributeTypeId=@intId Where ISNULL(intAttributeTypeId,0)=0
			End

			Set @intNoOfShipRecordCounter=@intNoOfShipRecordCounter-1
			Set @intNoOfShipRecordParentCounter=@intNoOfShipRecordParentCounter+1
		End

		--Invoice if exists adjust the sequence
		If Exists (Select 1 From @tblData Where strType='IN')
		Begin
			--Generate RecordId for all the Invoices
			UPDATE t
				SET t.intRecordId = t.intRowNo,t.intParentId=0
				FROM (
					  SELECT intRecordId,intParentId,ROW_NUMBER() OVER (ORDER BY intLotId) AS intRowNo
					  FROM @tblData
					  ) t	
				  
			--Copy the Shipments/Lots to temp
			Insert Into @tblTemp(intRecordId,intParentId,strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
							dblQuantity,strUOM,dtmTransactionDate,strCustomer,strType,intParentLotId,intImageTypeId,intAttributeTypeId)
			Select intRecordId,intParentId,strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
							dblQuantity,strUOM,dtmTransactionDate,strCustomer,strType,intParentLotId,intImageTypeId,intAttributeTypeId From @tblNodeData

			Delete From @tblNodeData
		
			--Insert Invoices to @tblNodeData
			Insert Into @tblNodeData(intRecordId,intParentId,strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
			dblQuantity,strUOM,dtmTransactionDate,strCustomer,strType,intParentLotId)
			Select intRecordId,intParentId,strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
			dblQuantity,strUOM,dtmTransactionDate,strCustomer,strType,intParentLotId From @tblData

			Delete From @tblData

			Select @intMaxRecordCount=COUNT(1) From @tblNodeData

			--Adjust the intRecordId, intParentId for Shipments/Lots in @tblTemp
			UPDATE t
				SET t.intRecordId = @intMaxRecordCount + t.intRowNo
				FROM (
					  SELECT intRecordId,intParentId,ROW_NUMBER() OVER (ORDER BY intLotId) AS intRowNo
					  FROM @tblTemp
					  ) t	

			--Update intParentId for Shipments
			Update t Set t.intParentId=n.intRecordId
				From @tblTemp t	Join @tblNodeData n on t.intLotId=n.intParentLotId
				Where t.strType='S'			  

			--Update intParentId for Lots 			
			Update t Set t.intParentId=n.intRecordId
				From @tblTemp t	Join (Select * from @tblTemp Where strType='S') n on t.intAttributeTypeId=n.intLotId
				Where t.strType='L'	
			
			--Copy the Shipments/Lots from temp to @tblNodeData
			Insert Into @tblNodeData(intRecordId,intParentId,strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
							dblQuantity,strUOM,dtmTransactionDate,strCustomer,strType,intParentLotId,intImageTypeId)
			Select intRecordId,intParentId,strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
							dblQuantity,strUOM,dtmTransactionDate,strCustomer,strType,intParentLotId,intImageTypeId From @tblTemp		
						
			Delete From @tblTemp						
		End
	End

	--Shipment
	If @intObjectTypeId = 7
	Begin
		Declare @ysnInvoiceExist bit=0

		--Invoice if exists
		Insert Into @tblNodeData(strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
		dblQuantity,strUOM,dtmTransactionDate,strCustomer,strType)
		Exec uspMFGetTraceabilityInvoiceFromShipment @intLotId

		If Exists (Select 1 From @tblNodeData Where strType='IN')
			Set @ysnInvoiceExist=1

		If @ysnInvoiceExist=1
			Update @tblNodeData Set intRecordId=1,intParentId=0

		--Ship
		Insert Into @tblNodeData(strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
						dblQuantity,strUOM,dtmTransactionDate,strCustomer,strType)
		Exec uspMFGetTraceabilityShipmentDetail @intLotId

		If @ysnInvoiceExist=1
			Update @tblNodeData Set intRecordId=2,intParentId=1 Where strType='S'
		Else
			Update @tblNodeData Set intRecordId=1,intParentId=0 Where strType='S'

		--Lots From Shipment
		Insert Into @tblNodeData(strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
		dblQuantity,strUOM,dtmTransactionDate,intParentLotId,strType,intImageTypeId)
		Exec uspMFGetTraceabilityShipmentLots @intLotId,@ysnParentLot

		--Update @tblNodeData Set intRecordId=2,intParentId=1,strType='L' Where intParentId is null

		DECLARE @intRecCounter INT = CASE WHEN @ysnInvoiceExist=1 THEN 2 ELSE 1 END
		Update @tblNodeData Set @intRecCounter = intRecordId = @intRecCounter + 1 ,intParentId=(CASE WHEN @ysnInvoiceExist=1 THEN 2 ELSE 1 END),strType='L' Where intParentId is null
	End

	--Outbound Shipment
	IF @intObjectTypeId = 8
	BEGIN
		DECLARE @ysnInvoiceExist1 BIT = 0

		--Invoice if exists
		INSERT INTO @tblNodeData (
			strTransactionName
			,intLotId
			,strLotNumber
			,strLotAlias
			,intItemId
			,strItemNo
			,strItemDesc
			,intCategoryId
			,strCategoryCode
			,dblQuantity
			,strUOM
			,dtmTransactionDate
			,strCustomer
			,strType
			)
		EXEC uspMFGetTraceabilityInvoiceFromOutboundShipment @intLotId

		IF EXISTS (
				SELECT 1
				FROM @tblNodeData
				WHERE strType = 'IN'
				)
			SET @ysnInvoiceExist1 = 1

		IF @ysnInvoiceExist1 = 1
			UPDATE @tblNodeData
			SET intRecordId = 1
				,intParentId = 0

		--Ship
		INSERT INTO @tblNodeData (
			strTransactionName
			,intLotId
			,strLotNumber
			,strLotAlias
			,intItemId
			,strItemNo
			,strItemDesc
			,intCategoryId
			,strCategoryCode
			,dblQuantity
			,strUOM
			,dtmTransactionDate
			,strCustomer
			,strType
			)
		EXEC uspMFGetTraceabilityOutboundShipmentDetail @intLotId

		IF @ysnInvoiceExist1 = 1
			UPDATE @tblNodeData
			SET intRecordId = 2
				,intParentId = 1
			WHERE strType = 'OS'
		ELSE
			UPDATE @tblNodeData
			SET intRecordId = 1
				,intParentId = 0
			WHERE strType = 'OS'

		--Lots From Shipment
		INSERT INTO @tblNodeData (
			strTransactionName
			,intLotId
			,strLotNumber
			,strLotAlias
			,intItemId
			,strItemNo
			,strItemDesc
			,intCategoryId
			,strCategoryCode
			,dblQuantity
			,strUOM
			,dtmTransactionDate
			,intParentLotId
			,strType
			,intImageTypeId
			)
		EXEC uspMFGetTraceabilityOutboundShipmentLots @intLotId
			,@ysnParentLot

		--Update @tblNodeData Set intRecordId=2,intParentId=1,strType='L' Where intParentId is null
		DECLARE @intRecCounter1 INT = CASE 
				WHEN @ysnInvoiceExist1 = 1
					THEN 2
				ELSE 1
				END

		UPDATE @tblNodeData
		SET @intRecCounter1 = intRecordId = @intRecCounter1 + 1
			,intParentId = (
				CASE 
					WHEN @ysnInvoiceExist1 = 1
						THEN 2
					ELSE 1
					END
				)
			,strType = 'L'
		WHERE intParentId IS NULL
	END
	-- Sales Order from Shipment if exists
	If Exists (Select 1 From @tblNodeData Where strType='S')
		Begin
			Set @intNoOfShipRecordCounter=null

			Select @intNoOfShipRecordCounter=MIN(intRecordId) From @tblNodeData Where strType='S'

			While (@intNoOfShipRecordCounter is not null)
			Begin
				Select @intId=intLotId From @tblNodeData Where intRecordId=@intNoOfShipRecordCounter

				SELECT @intMaxRecordCount = Max(intRecordId) FROM @tblNodeData

				--SO
				Insert Into @tblNodeData(strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
				dblQuantity,strUOM,dtmTransactionDate,strCustomer,strType)
				Exec uspMFGetTraceabilitySalesOrderFromShipment @intId

				Update @tblNodeData Set intRecordId=@intMaxRecordCount+1,intParentId=@intNoOfShipRecordCounter Where intRecordId is null

				Select @intNoOfShipRecordCounter=MIN(intRecordId) From @tblNodeData Where strType='S' And intRecordId>@intNoOfShipRecordCounter
			End
		End

	--Counter Data for the while loop
	SELECT @intMaxRecordCount = Max(intRecordId),@intParentId = Max(intRecordId) FROM @tblNodeData

	--Shipment
	If @intObjectTypeId = 7 or @intObjectTypeId = 8
	Begin
		--Point the Record Id to the first visible Lot Node depending on no of shipments (multiple shipments) , case statement refers to that
		Insert Into @tblTemp(intRecordId,intParentId,strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
		dblQuantity,strUOM,dtmTransactionDate,intParentLotId,strType)
		Select intRecordId-(Case When @intNoOfShipRecord>0 Then (@intNoOfShipRecord-1) Else 0 End),intParentId,strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
		dblQuantity,strUOM,dtmTransactionDate,intParentLotId,strType From @tblNodeData Where strType not in ('SO') Order By intRecordId Desc

		Select @intRowCount=COUNT(1) From @tblTemp
	End
	Else
	Begin
		--Point the Record Id to the first visible Lot Node depending on no of shipments (multiple shipments) , case statement refers to that
		Insert Into @tblTemp(intRecordId,intParentId,strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
		dblQuantity,strUOM,dtmTransactionDate,intParentLotId,strType)
		Select TOP 1 intRecordId-(Case When @intNoOfShipRecord>0 Then (@intNoOfShipRecord-1) Else 0 End),intParentId,strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
		dblQuantity,strUOM,dtmTransactionDate,intParentLotId,strType From @tblNodeData Where strType not in ('SO') Order By intRecordId Desc

		Set @intRowCount=1
	End

	WHILE (@intRowCount > 0)
	BEGIN    
		DECLARE @RCUR CURSOR       
		SET @RCUR = CURSOR FOR SELECT DISTINCT intLotId,intRecordId,strType FROM @tblTemp      

		OPEN @RCUR      
		FETCH NEXT FROM @RCUR INTO @intId,@intParentId,@strType
			WHILE @@FETCH_STATUS = 0      
			BEGIN     

				Set @intContractId=NULL
				Set @intContainerId=NULL
				Set @intShipmentId=NULL

				-- From Lot to WorkOrders
				If @strType='L'
					Begin
						Insert Into @tblData(strTransactionName,intLotId,strLotNumber,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
						dblQuantity,strUOM,dtmTransactionDate,strProcessName,strType,intAttributeTypeId)
						Exec uspMFGetTraceabilityWorkOrderDetail @intId,@intDirectionId,@ysnParentLot

						--Remove circular Reference, Remove the WO if exists
						If Exists (Select 1 from @tblData Where  intLotId in (Select intLotId from @tblNodeData Where strType='W'))
							Delete From @tblData
					End

				-- WorkOrder Input details
				If @strType='W'  			
					Insert Into @tblData(strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
					dblQuantity,strUOM,dtmTransactionDate,intParentLotId,strType,intAttributeTypeId,intImageTypeId)
					Exec uspMFGetTraceabilityWorkOrderInputDetail @intId,@ysnParentLot
			
				-- Lot Split
				If @strType='L'
					Insert Into @tblData(strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
					dblQuantity,strUOM,dtmTransactionDate,intParentLotId,strType,intImageTypeId)
					Exec uspMFGetTraceabilityLotSplitDetail @intId,@intDirectionId,@ysnParentLot

				-- Lot Receipt
				If @strType='L'
					Insert Into @tblData(strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
					dblQuantity,strUOM,dtmTransactionDate,intParentLotId,strVendor,strType)
					Exec uspMFGetTraceabilityLotReceiptDetail @intId,@ysnParentLot

			--Get Contract/Container if exists for Receipt
			if @strType='R'
				Begin
			
					Select TOP 1 @intContractId=ISNULL(ri.intOrderId,0),@intShipmentId=ISNULL(ri.intSourceId,0),@intContainerId=ISNULL(ri.intContainerId,0) 
					From tblICInventoryReceiptItem ri 
					Join tblICInventoryReceipt rh on ri.intInventoryReceiptId=rh.intInventoryReceiptId 
					Where rh.intInventoryReceiptId=@intId And rh.strReceiptType='Purchase Contract'

					--Get Contract
					if @intContainerId=0
						Insert Into @tblData(strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
						dblQuantity,strUOM,dtmTransactionDate,strVendor,intImageTypeId,strType)
						Exec uspMFGetTraceabilityContractDetail @intContractId,@intDirectionId
					Else
						--Get Container
						Insert Into @tblData(strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
						dblQuantity,strUOM,dtmTransactionDate,intParentLotId,strVendor,strType)
						Exec uspMFGetTraceabilityContainerDetail @intContainerId,@intDirectionId
				End

				--Get In Shipment From Container
				if @strType='CN'
				Begin
					Select TOP 1 @intShipmentId=intLoadId From vyuLGLoadContainerReceiptContracts where intLoadContainerId=@intId

					Insert Into @tblData(strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
					dblQuantity,strUOM,dtmTransactionDate,strVendor,strType)
					Exec uspMFGetTraceabilityInboundShipmentDetail @intShipmentId,@intDirectionId
				End

				--Get Contract From In Shipment
				if @strType='IS'
				Begin
					Select TOP 1 @intContractId=intPContractHeaderId From vyuLGLoadContainerReceiptContracts where intLoadId=@intId

					Insert Into @tblData(strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
					dblQuantity,strUOM,dtmTransactionDate,strVendor,intImageTypeId,strType)
					Exec uspMFGetTraceabilityContractDetail @intContractId,@intDirectionId
				End

				UPDATE @tblData SET intParentId = @intParentId WHERE  intParentId IS NULL        

			FETCH NEXT FROM @RCUR INTO @intId,@intParentId,@strType      
			END

		DELETE FROM @tblTemp      

		Insert Into @tblTemp(intRecordId,intParentId,strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
		dblQuantity,strUOM,dtmTransactionDate,intParentLotId,strVendor,strCustomer,strProcessName,strType,intAttributeTypeId,intImageTypeId)
		Select (@intMaxRecordCount + ROW_NUMBER() OVER (ORDER BY intLotId ASC)) AS intRecordId,intParentId,strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
		SUM(dblQuantity),strUOM,dtmTransactionDate,intParentLotId,strVendor,strCustomer,strProcessName,strType,intAttributeTypeId,intImageTypeId 
		From @tblData Group By intParentId,strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
		strUOM,dtmTransactionDate,intParentLotId,strVendor,strCustomer,strProcessName,strType,intAttributeTypeId,intImageTypeId

		--Node Date
		Insert Into @tblNodeData(intRecordId,intParentId,strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
		dblQuantity,strUOM,dtmTransactionDate,intParentLotId,strVendor,strCustomer,strProcessName,strType,intAttributeTypeId,intImageTypeId)
		Select intRecordId,intParentId,strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
		dblQuantity,strUOM,dtmTransactionDate,intParentLotId,strVendor,strCustomer,strProcessName,strType,intAttributeTypeId,intImageTypeId 
		From @tblTemp

		DELETE FROM @tblData

		SELECT @intMaxRecordCount = Max(intRecordId) FROM @tblTemp     

		--Delete From @tblTemp Where strTransactionName='Receipt'

		SELECT @intRowCount = COUNT(1) FROM @tblTemp      
	END

	--Insert Into @tblLinkData(intFromRecordId,intToRecordId,strTransactionName)
	--Select intParentId,intRecordId,strTransactionName From @tblNodeData
End

	Insert Into @tblNodeDataFinal([key],intRecordId,intParentId,strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
	dblQuantity,strUOM,dtmTransactionDate,intParentLotId,strVendor,strCustomer,strProcessName,strType,intAttributeTypeId,intImageTypeId,strImage,strNodeText,strToolTip,
	intControlPointId)
	Select n.intRecordId AS [key],
	n.intRecordId,n.intParentId,n.strTransactionName,n.intLotId,n.strLotNumber,n.strLotAlias,n.intItemId,n.strItemNo,n.strItemDesc,n.intCategoryId,n.strCategoryCode,
	n.dblQuantity,n.strUOM,n.dtmTransactionDate,n.intParentLotId,n.strVendor,n.strCustomer,n.strProcessName,n.strType,n.intAttributeTypeId,n.intImageTypeId,
	Case When n.strType IN ('L','IT') Then 
		Case When n.intImageTypeId = 2 Then './resources/images/graphics/traceability-raw-material.png' 
			When n.intImageTypeId = 4 Then './resources/images/graphics/traceability-wip-material.png' 
			When n.intImageTypeId = 6 Then './resources/images/graphics/traceability-finished-goods.png' 
			Else './resources/images/graphics/traceability-wip-material.png'
		End
	When n.strType='W' Then 
		Case When n.intAttributeTypeId=3 Then './resources/images/graphics/traceability-packaging.png' 
		Else './resources/images/graphics/traceability-wip-process.png' End
	When n.strType='R' Then './resources/images/graphics/traceability-receipt.png'
	When n.strType in ('S','OS') Then './resources/images/graphics/traceability-shipment.png'
	When n.strType='C' Then './resources/images/graphics/contract.png'
	When n.strType='IS' Then './resources/images/graphics/traceability-shipment.png'
	When n.strType='CN' Then './resources/images/graphics/container.png'
	When n.strType='SO' Then './resources/images/graphics/sales-order.png'
	When n.strType='IN' Then './resources/images/graphics/invoice.png'
	End AS strImage,
	CASE When ISNULL(n.strProcessName,'')='' THEN  n.strLotNumber Else n.strLotNumber + CHAR(13) + '(' + n.strProcessName + ')' End AS strNodeText,
	'Item No.           : ' + ISNULL(n.strItemNo,'') + CHAR(13) +
	'Item Desc.        : ' + ISNULL(n.strItemDesc,'') + CHAR(13) +
	'Quantity           : ' + ISNULL(dbo.fnRemoveTrailingZeroes(n.dblQuantity),'') + ' ' + ISNULL(n.strUOM,'') + CHAR(13) +
	'Tran. Date        : ' + ISNULL(CONVERT(VARCHAR,n.dtmTransactionDate),'') + CHAR(13) +
	CASE WHEN n.strType='R' THEN 'Vendor            : ' + ISNULL(n.strVendor,'') ELSE '' END + 
	CASE WHEN n.strType='S' THEN 'Customer          : ' + ISNULL(n.strCustomer,'') ELSE '' END + 
	CASE WHEN n.strType='L' AND ISNULL(CONVERT(VARCHAR(100),l.intSeasonCropYear),'')<>'' THEN 'Crop Year         : ' + ISNULL(CONVERT(VARCHAR(100),l.intSeasonCropYear),'') + CHAR(13) ELSE '' END +
	CASE WHEN n.strType='L' AND ISNULL(e.strName,'')<>'' THEN 'Producer           : ' + ISNULL(e.strName,'') + CHAR(13) ELSE '' END +
	CASE WHEN n.strType='L' AND ISNULL(l.strCertificate,'')<>'' THEN 'Certification      : ' + ISNULL(l.strCertificate,'') + CHAR(13) ELSE '' END + 
	CASE WHEN n.strType='L' AND ISNULL(l.strCertificateId,'')<>'' THEN 'Certification Id  : ' + ISNULL(l.strCertificateId,'') + CHAR(13) ELSE '' END + 
	CASE WHEN n.strType='L' AND ISNULL(l.strTrackingNumber,'')<>'' THEN 'Tracking No      : ' + ISNULL(l.strTrackingNumber,'') ELSE '' END
	AS strToolTip,
	Case When n.strType='L' Then 
		Case When n.intImageTypeId = 2 Then 5 
			Else 6
		End
	Else 5 
	End AS intControlPointId
	From @tblNodeData n 
	Left Join tblICLot l on n.intLotId=l.intLotId AND n.strType='L'
	Left Join tblEMEntity e on l.intProducerId=e.intEntityId

	--Generate Group Row No
	Update f set f.ysnExcludedNode=1,f.intGroupRowNo=t.intRowNo From @tblNodeDataFinal f Join
	(
	Select ROW_NUMBER() over (partition by (convert(varchar,strType) + convert(varchar,strTransactionName) + convert(varchar,intLotId)) order by [key]) intRowNo,[key]
	From @tblNodeDataFinal
	) t on f.[key]=t.[key]
	Where intRowNo>1

	--Update Duplicate Rows
	Update f set f.intRecordId=t.intMinRecordId From @tblNodeDataFinal f Join
	(
	Select MIN(intRecordId) intMinRecordId,(convert(varchar,strType) + convert(varchar,strTransactionName) + convert(varchar,intLotId)) AS strKey
	From @tblNodeDataFinal group by (convert(varchar,strType) + convert(varchar,strTransactionName) + convert(varchar,intLotId))
	) t on (convert(varchar,strType) + convert(varchar,f.strTransactionName) + convert(varchar,f.intLotId))=t.strKey
	Where f.intGroupRowNo is not null

	--Update the transaction for SO Link for forward
	If @intDirectionId=1
		Update @tblNodeDataFinal set strTransactionName='Sales Order' Where strType='S' and ysnExcludedNode=1

	--Update the transaction for Shipment Link for reverse
	If @intDirectionId=2 And Exists (Select 1 From @tblNodeDataFinal Where strType='IN')
		Update @tblNodeDataFinal set strTransactionName='Invoice' Where strType='S'

	Select * from @tblNodeDataFinal