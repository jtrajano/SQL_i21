CREATE PROCEDURE [dbo].[uspMFGetTraceabilityDiagram]
	--@intLotId int,
	@strLotNumber nvarchar(50),
	@intLocationId int,
	@intDirectionId int
AS
SET NOCOUNT ON;

Declare @intLotId int
Declare @intRowCount int
Declare @intMaxRecordCount int
Declare @intId int
Declare @intParentId int
Declare @strType nvarchar(1)

Select TOP 1 @intLotId=intLotId From tblICLot where strLotNumber=@strLotNumber And intLocationId=@intLocationId

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
	strCategoryCode nvarchar(50),
	intParentLotId int,
	strProcessName nvarchar(50),
	strType nvarchar(1),
	strVendor nvarchar(50),
	strCustomer nvarchar(50)
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
	strCategoryCode nvarchar(50),
	intParentLotId int,
	strProcessName nvarchar(50),
	strType nvarchar(1),
	strVendor nvarchar(50),
	strCustomer nvarchar(50)
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
	strCategoryCode nvarchar(50),
	intParentLotId int,
	strProcessName nvarchar(50),
	strType nvarchar(1),
	strVendor nvarchar(50),
	strCustomer nvarchar(50)
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
	--Receipt
	Insert Into @tblNodeData(strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,strCategoryCode,
	dblQuantity,strUOM,dtmTransactionDate,intParentLotId,strVendor,strType)
	Exec uspMFGetTraceabilityLotReceiptDetail @intLotId

	Update @tblNodeData Set intRecordId=1,intParentId=0,strType='L'

	--Lot Detail
	Insert Into @tblNodeData(strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,strCategoryCode,
	dblQuantity,strUOM,dtmTransactionDate,intParentLotId)
	Exec uspMFGetTraceabilityLotDetail @intLotId,@intDirectionId

	Update @tblNodeData Set intRecordId=2,intParentId=1,strType='L' Where intParentId is null

	--Counter Data for the while loop
	SELECT @intMaxRecordCount = Max(intRecordId),@intParentId = Max(intRecordId) FROM @tblNodeData

	Insert Into @tblTemp(intRecordId,intParentId,strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,strCategoryCode,
	dblQuantity,strUOM,dtmTransactionDate,intParentLotId,strType)
	Select TOP 1 intRecordId,intParentId,strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,strCategoryCode,
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

				-- From Lot to WorkOrders
				If @strType='L'
					Insert Into @tblData(strTransactionName,intLotId,strLotNumber,intItemId,strItemNo,strItemDesc,strCategoryCode,
					dblQuantity,strUOM,dtmTransactionDate,strProcessName,strType)
					Exec uspMFGetTraceabilityWorkOrderDetail @intId,@intDirectionId

				-- WorkOrder Output details
				If @strType='W'  			
					Insert Into @tblData(strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,strCategoryCode,
					dblQuantity,strUOM,dtmTransactionDate,intParentLotId,strType)
					Exec uspMFGetTraceabilityWorkOrderOutputDetail @intId
			
				-- Lot Ship
				If @strType='L'
					Insert Into @tblData(strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,strCategoryCode,
					dblQuantity,strUOM,dtmTransactionDate,strCustomer,strType)
					Exec uspMFGetTraceabilityLotShipDetail @intId

				UPDATE @tblData SET intParentId = @intParentId WHERE  intParentId IS NULL        

			FETCH NEXT FROM @FCUR INTO @intId,@intParentId,@strType      
			END

		DELETE FROM @tblTemp      

		Insert Into @tblTemp(intRecordId,intParentId,strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,strCategoryCode,
		dblQuantity,strUOM,dtmTransactionDate,intParentLotId,strVendor,strCustomer,strProcessName,strType)
		Select (@intMaxRecordCount + ROW_NUMBER() OVER (ORDER BY intLotId ASC)) AS intRecordId,intParentId,strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,strCategoryCode,
		SUM(dblQuantity),strUOM,dtmTransactionDate,intParentLotId,strVendor,strCustomer,strProcessName,strType 
		From @tblData Group By intParentId,strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,strCategoryCode,
		strUOM,dtmTransactionDate,intParentLotId,strVendor,strCustomer,strProcessName,strType

		--Node Date
		Insert Into @tblNodeData(intRecordId,intParentId,strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,strCategoryCode,
		dblQuantity,strUOM,dtmTransactionDate,intParentLotId,strVendor,strCustomer,strProcessName,strType)
		Select intRecordId,intParentId,strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,strCategoryCode,
		dblQuantity,strUOM,dtmTransactionDate,intParentLotId,strVendor,strCustomer,strProcessName,strType 
		From @tblTemp

		DELETE FROM @tblData

		SELECT @intMaxRecordCount = Max(intRecordId) FROM @tblTemp     

		Delete From @tblTemp Where strTransactionName='Ship'

		SELECT @intRowCount = COUNT(1) FROM @tblTemp      
	END

	--Insert Into @tblLinkData(intFromRecordId,intToRecordId,strTransactionName)
	--Select intParentId,intRecordId,strTransactionName From @tblNodeData

	--Select intRecordId AS [key],*,
	--Case When strType='L' Then 
	--	Case When strTransactionName='Receipt' Then '../Manufacturing/Images/TraceabilityImages/' + strCategoryCode +'Receipt.png' 
	--	When strTransactionName='Ship' Then '../Manufacturing/Images/TraceabilityImages/' + strCategoryCode +'Ship.png' 
	--	Else '../Manufacturing/Images/TraceabilityImages/' + strCategoryCode +'FG.png' End
	--When strType='W' Then '../Manufacturing/Images/TraceabilityImages/' + strCategoryCode +'WIP.png' End AS strImage 
	--From @tblNodeData

End

--Reverse
If @intDirectionId=2
Begin
	--Ship
	Insert Into @tblNodeData(strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,strCategoryCode,
					dblQuantity,strUOM,dtmTransactionDate,strCustomer,strType)
	Exec uspMFGetTraceabilityLotShipDetail @intLotId

	Update @tblNodeData Set intRecordId=1,intParentId=0,strType='L'

	--Lot Detail
	Insert Into @tblNodeData(strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,strCategoryCode,
	dblQuantity,strUOM,dtmTransactionDate,intParentLotId)
	Exec uspMFGetTraceabilityLotDetail @intLotId,@intDirectionId

	Update @tblNodeData Set intRecordId=2,intParentId=1,strType='L' Where intParentId is null

	--Counter Data for the while loop
	SELECT @intMaxRecordCount = Max(intRecordId),@intParentId = Max(intRecordId) FROM @tblNodeData

	Insert Into @tblTemp(intRecordId,intParentId,strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,strCategoryCode,
	dblQuantity,strUOM,dtmTransactionDate,intParentLotId,strType)
	Select TOP 1 intRecordId,intParentId,strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,strCategoryCode,
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

				-- From Lot to WorkOrders
				If @strType='L'
					Insert Into @tblData(strTransactionName,intLotId,strLotNumber,intItemId,strItemNo,strItemDesc,strCategoryCode,
					dblQuantity,strUOM,dtmTransactionDate,strProcessName,strType)
					Exec uspMFGetTraceabilityWorkOrderDetail @intId,@intDirectionId

				-- WorkOrder Output details
				If @strType='W'  			
					Insert Into @tblData(strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,strCategoryCode,
					dblQuantity,strUOM,dtmTransactionDate,intParentLotId,strType)
					Exec uspMFGetTraceabilityWorkOrderInputDetail @intId
			
				-- Lot Receipt
				If @strType='L'
					Insert Into @tblData(strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,strCategoryCode,
					dblQuantity,strUOM,dtmTransactionDate,intParentLotId,strVendor,strType)
					Exec uspMFGetTraceabilityLotReceiptDetail @intId

				UPDATE @tblData SET intParentId = @intParentId WHERE  intParentId IS NULL        

			FETCH NEXT FROM @RCUR INTO @intId,@intParentId,@strType      
			END

		DELETE FROM @tblTemp      

		Insert Into @tblTemp(intRecordId,intParentId,strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,strCategoryCode,
		dblQuantity,strUOM,dtmTransactionDate,intParentLotId,strVendor,strCustomer,strProcessName,strType)
		Select (@intMaxRecordCount + ROW_NUMBER() OVER (ORDER BY intLotId ASC)) AS intRecordId,intParentId,strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,strCategoryCode,
		SUM(dblQuantity),strUOM,dtmTransactionDate,intParentLotId,strVendor,strCustomer,strProcessName,strType 
		From @tblData Group By intParentId,strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,strCategoryCode,
		strUOM,dtmTransactionDate,intParentLotId,strVendor,strCustomer,strProcessName,strType

		--Node Date
		Insert Into @tblNodeData(intRecordId,intParentId,strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,strCategoryCode,
		dblQuantity,strUOM,dtmTransactionDate,intParentLotId,strVendor,strCustomer,strProcessName,strType)
		Select intRecordId,intParentId,strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,strCategoryCode,
		dblQuantity,strUOM,dtmTransactionDate,intParentLotId,strVendor,strCustomer,strProcessName,strType 
		From @tblTemp

		DELETE FROM @tblData

		SELECT @intMaxRecordCount = Max(intRecordId) FROM @tblTemp     

		Delete From @tblTemp Where strTransactionName='Receipt'

		SELECT @intRowCount = COUNT(1) FROM @tblTemp      
	END

	--Insert Into @tblLinkData(intFromRecordId,intToRecordId,strTransactionName)
	--Select intParentId,intRecordId,strTransactionName From @tblNodeData
End

	Select intRecordId AS [key],*,
	Case When strType='L' Then 
		Case When strTransactionName='Receipt' Then '../Manufacturing/Images/TraceabilityImages/' + strCategoryCode +'Receipt.png' 
		When strTransactionName='Ship' Then '../Manufacturing/Images/TraceabilityImages/' + strCategoryCode +'Ship.png' 
		Else '../Manufacturing/Images/TraceabilityImages/' + strCategoryCode +'FG.png' End
	When strType='W' Then '../Manufacturing/Images/TraceabilityImages/' + strCategoryCode +'WIP.png' End AS strImage,
	'Item No.     : ' + ISNULL(strItemNo,'') + CHAR(13) +
	'Item Desc.   : ' + ISNULL(strItemDesc,'') + CHAR(13) +
	'Quantity     : ' + ISNULL(dbo.fnRemoveTrailingZeroes(dblQuantity),'') + ' ' + ISNULL(strUOM + CHAR(13),'') + CHAR(13) +
	'Process Name : ' + ISNULL(strProcessName,'') + CHAR(13) +  
	'Vendor       : ' + ISNULL(strVendor,'') + CHAR(13) +
	'Customer     : ' + ISNULL(strCustomer,'') AS strToolTip
	From @tblNodeData