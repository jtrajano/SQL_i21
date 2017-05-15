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
		Join tblLGLoadDetail ld on ri.intSourceId=ld.intLoadDetailId
		Where rl.intLotId=@intLotId And rh.strReceiptType='Purchase Contract'

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
					Insert Into @tblData(strTransactionName,intLotId,strLotNumber,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
					dblQuantity,strUOM,dtmTransactionDate,strProcessName,strType,intAttributeTypeId)
					Exec uspMFGetTraceabilityWorkOrderDetail @intId,@intDirectionId,@ysnParentLot

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
					Insert Into @tblData(strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
					dblQuantity,strUOM,dtmTransactionDate,strCustomer,strType)
					Exec uspMFGetTraceabilityLotShipDetail @intId,@ysnParentLot

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

		Delete From @tblTemp Where strTransactionName='Ship'

		SELECT @intRowCount = COUNT(1) FROM @tblTemp      
	END

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

		Update @tblNodeData Set intRecordId=1,intParentId=0

		--Lot Detail
		Insert Into @tblNodeData(strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
		dblQuantity,strUOM,dtmTransactionDate,intParentLotId,intImageTypeId)
		Exec uspMFGetTraceabilityLotDetail @intLotId,@intDirectionId,@ysnParentLot

		Update @tblNodeData Set intRecordId=2,intParentId=1,strType='L' Where intParentId is null
	End

	--Shipment
	If @intObjectTypeId = 7
	Begin
		--Ship
		Insert Into @tblNodeData(strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
						dblQuantity,strUOM,dtmTransactionDate,strCustomer,strType)
		Exec uspMFGetTraceabilityShipmentDetail @intLotId

		Update @tblNodeData Set intRecordId=1,intParentId=0

		--Lots From Shipment
		Insert Into @tblNodeData(strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
		dblQuantity,strUOM,dtmTransactionDate,intParentLotId,strType,intImageTypeId)
		Exec uspMFGetTraceabilityShipmentLots @intLotId,@ysnParentLot

		--Update @tblNodeData Set intRecordId=2,intParentId=1,strType='L' Where intParentId is null

		DECLARE @intRecCounter INT = 1
		Update @tblNodeData Set @intRecCounter = intRecordId = @intRecCounter + 1 ,intParentId=1,strType='L' Where intParentId is null
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
					Insert Into @tblData(strTransactionName,intLotId,strLotNumber,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
					dblQuantity,strUOM,dtmTransactionDate,strProcessName,strType,intAttributeTypeId)
					Exec uspMFGetTraceabilityWorkOrderDetail @intId,@intDirectionId,@ysnParentLot

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
	Select intRecordId AS [key],
	intRecordId,intParentId,strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
	dblQuantity,strUOM,dtmTransactionDate,intParentLotId,strVendor,strCustomer,strProcessName,strType,intAttributeTypeId,intImageTypeId,
	Case When strType='L' Then 
		Case When intImageTypeId = 2 Then '../resources/images/graphics/traceability-raw-material.png' 
			When intImageTypeId = 4 Then '../resources/images/graphics/traceability-wip-material.png' 
			When intImageTypeId = 6 Then '../resources/images/graphics/traceability-finished-goods.png' 
			Else '../resources/images/graphics/traceability-wip-material.png'
		End
	When strType='W' Then 
		Case When intAttributeTypeId=3 Then '../resources/images/graphics/traceability-packaging.png' 
		Else '../resources/images/graphics/traceability-wip-process.png' End
	When strType='R' Then '../resources/images/graphics/traceability-receipt.png'
	When strType='S' Then '../resources/images/graphics/traceability-shipment.png'
	When strType='C' Then '../resources/images/graphics/traceability-wip-process.png'
	When strType='IS' Then '../resources/images/graphics/traceability-shipment.png'
	When strType='CN' Then '../resources/images/graphics/traceability-finished-goods.png'
	End AS strImage,
	CASE When ISNULL(strProcessName,'')='' THEN  strLotNumber Else strLotNumber + CHAR(13) + '(' + strProcessName + ')' End AS strNodeText,
	'Item No.	  : ' + ISNULL(strItemNo,'') + CHAR(13) +
	'Item Desc.   : ' + ISNULL(strItemDesc,'') + CHAR(13) +
	'Quantity     : ' + ISNULL(dbo.fnRemoveTrailingZeroes(dblQuantity),'') + ' ' + ISNULL(strUOM + CHAR(13),'') + CHAR(13) +
	'Tran. Date   : ' + ISNULL(CONVERT(VARCHAR,dtmTransactionDate),'') + CHAR(13) +
	CASE WHEN strType='R' THEN 'Vendor     : ' + ISNULL(strVendor,'') ELSE '' END + 
	CASE WHEN strType='S' THEN 'Customer     : ' + ISNULL(strCustomer,'') ELSE '' END
	AS strToolTip,
	Case When strType='L' Then 
		Case When intImageTypeId = 2 Then 5 
			Else 6
		End
	Else 5 
	End AS intControlPointId
	From @tblNodeData

	--Generate Group Row No
	Update f set f.ysnExcludedNode=1,f.intGroupRowNo=t.intRowNo From @tblNodeDataFinal f Join
	(
	Select ROW_NUMBER() over (partition by (convert(varchar,strTransactionName) + convert(varchar,intLotId)) order by [key]) intRowNo,[key]
	From @tblNodeDataFinal
	) t on f.[key]=t.[key]
	Where intRowNo>1

	--Update Duplicate Rows
	Update f set f.intRecordId=t.intMinRecordId From @tblNodeDataFinal f Join
	(
	Select MIN(intRecordId) intMinRecordId,(convert(varchar,strTransactionName) + convert(varchar,intLotId)) AS strKey
	From @tblNodeDataFinal group by (convert(varchar,strTransactionName) + convert(varchar,intLotId))
	) t on (convert(varchar,f.strTransactionName) + convert(varchar,f.intLotId))=t.strKey
	Where f.intGroupRowNo is not null

	Select * from @tblNodeDataFinal