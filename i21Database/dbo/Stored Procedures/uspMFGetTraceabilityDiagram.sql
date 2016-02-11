CREATE PROCEDURE [dbo].[uspMFGetTraceabilityDiagram]
	--@intLotId int,
	@strLotNumber nvarchar(50),
	@intLocationId int,
	@intDirectionId int,
	@ysnParentLot bit=0
AS
SET NOCOUNT ON;

Declare @intLotId int
Declare @intRowCount int
Declare @intMaxRecordCount int
Declare @intId int
Declare @intParentId int
Declare @strType nvarchar(1)

If @ysnParentLot=0
	Select TOP 1 @intLotId=intLotId From tblICLot where strLotNumber=@strLotNumber And intLocationId=@intLocationId
Else
	Select TOP 1 @intLotId=intParentLotId From tblICParentLot where strParentLotNumber=@strLotNumber

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
	strType nvarchar(1),
	strVendor nvarchar(50),
	strCustomer nvarchar(50),
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
	strType nvarchar(1),
	strVendor nvarchar(50),
	strCustomer nvarchar(50),
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
	strType nvarchar(1),
	strVendor nvarchar(50),
	strCustomer nvarchar(50),
	intAttributeTypeId int Default 0,
	intImageTypeId int Default 0
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
	Insert Into @tblNodeData(strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
	dblQuantity,strUOM,dtmTransactionDate,intParentLotId,strVendor,strType)
	Exec uspMFGetTraceabilityLotReceiptDetail @intLotId,@ysnParentLot

	Update @tblNodeData Set intRecordId=1,intParentId=0

	--Lot Detail
	Insert Into @tblNodeData(strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
	dblQuantity,strUOM,dtmTransactionDate,intParentLotId,intImageTypeId)
	Exec uspMFGetTraceabilityLotDetail @intLotId,@intDirectionId,@ysnParentLot

	Update @tblNodeData Set intRecordId=2,intParentId=1,strType='L' Where intParentId is null

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
			
				-- Lot Receipt
				If @strType='L'
					Insert Into @tblData(strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
					dblQuantity,strUOM,dtmTransactionDate,intParentLotId,strVendor,strType)
					Exec uspMFGetTraceabilityLotReceiptDetail @intId,@ysnParentLot

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

		Delete From @tblTemp Where strTransactionName='Receipt'

		SELECT @intRowCount = COUNT(1) FROM @tblTemp      
	END

	--Insert Into @tblLinkData(intFromRecordId,intToRecordId,strTransactionName)
	--Select intParentId,intRecordId,strTransactionName From @tblNodeData
End

	Select intRecordId AS [key],*,
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