CREATE PROCEDURE [dbo].[uspMFRecallReport]
@xmlParam NVARCHAR(MAX) = NULL
AS

SET NOCOUNT ON;

	DECLARE @intPickListId			INT,
			@idoc					INT 
			
	IF	LTRIM(RTRIM(@xmlParam)) = ''   
		SET @xmlParam = NULL   
      
	DECLARE @temp_xml_table TABLE 
	(  
			[fieldname]		NVARCHAR(50),  
			condition		NVARCHAR(20),        
			[from]			NVARCHAR(50), 
			[to]			NVARCHAR(50),  
			[join]			NVARCHAR(10),  
			[begingroup]	NVARCHAR(50),  
			[endgroup]		NVARCHAR(50),  
			[datatype]		NVARCHAR(50) 
	)  
  
	EXEC sp_xml_preparedocument @idoc output, @xmlParam  
  
	INSERT INTO @temp_xml_table  
	SELECT	*  
	FROM	OPENXML(@idoc, 'xmlparam/filters/filter', 2)  
	WITH (  
				[fieldname]		NVARCHAR(50),  
				condition		NVARCHAR(20),        
				[from]			NVARCHAR(50), 
				[to]			NVARCHAR(50),  
				[join]			NVARCHAR(10),  
				[begingroup]	NVARCHAR(50),  
				[endgroup]		NVARCHAR(50),  
				[datatype]		NVARCHAR(50)  
	)  
    
Declare
	@intLotId int,
	@intDirectionId int,
	@ysnParentLot bit=0,
	@intObjectTypeId INT = 4

Declare @intRowCount int
Declare @intMaxRecordCount int
Declare @intId int
Declare @intParentId int
Declare @strType nvarchar(2)
Declare @intContractId int
Declare @intShipmentId int
Declare @intContainerId int
Declare @strLotNumber nvarchar(50)
 
SELECT	@intLotId = [from]
FROM	@temp_xml_table   
WHERE	[fieldname] = 'intLotId'

Set @intDirectionId=2

Select @strLotNumber=strLotNumber From tblICLot Where intLotId=@intLotId

	DECLARE @strCompanyName NVARCHAR(100)
		,@strCompanyAddress NVARCHAR(100)
		,@strCity NVARCHAR(25)
		,@strState NVARCHAR(50)
		,@strZip NVARCHAR(12)
		,@strCountry NVARCHAR(25)

	SELECT TOP 1 @strCompanyName = strCompanyName
		,@strCompanyAddress = strAddress
		,@strCity = strCity
		,@strState = strState
		,@strZip = strZip
		,@strCountry = strCountry
	FROM dbo.tblSMCompanySetup

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

Declare @tblLinkData AS table
(
	intFromRecordId int,
	intToRecordId int,
	strTransactionName nvarchar(50)
)

--Forward
DIR_FORWARD:
If @intDirectionId=1
Begin
	----Lot Detail
	--Insert Into @tblNodeData(strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
	--dblQuantity,strUOM,dtmTransactionDate,intParentLotId,intImageTypeId)
	--Exec uspMFGetTraceabilityLotDetail @intLotId,@intDirectionId,@ysnParentLot

	----Update vendor
	--Update @tblNodeData Set strVendor=(Select TOP 1 strName From vyuAPVendor Where intEntityId in (Select intEntityVendorId From tblICLot Where strLotNumber=@strLotNumber))

	--Receipt
	Insert Into @tblNodeData(strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
	dblQuantity,strUOM,dtmTransactionDate,intParentLotId,strVendor,strType)
	Exec uspMFGetTraceabilityLotReceiptDetail @intLotId,@ysnParentLot

	--Update RecordId, ParentId
	SELECT @intMaxRecordCount = ISNULL(Max(intRecordId),0) + 1,@intParentId = ISNULL(Max(intRecordId),0) FROM @tblNodeData
	Update @tblNodeData Set intRecordId=@intMaxRecordCount,intParentId=@intParentId Where intParentId is null

	--Lot Detail
	Insert Into @tblNodeData(strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
	dblQuantity,strUOM,dtmTransactionDate,intParentLotId,intImageTypeId)
	Exec uspMFGetTraceabilityLotDetail @intLotId,@intDirectionId,@ysnParentLot

	--Update RecordId, ParentId
	SELECT @intMaxRecordCount = ISNULL(Max(intRecordId),0) + 1,@intParentId = ISNULL(Max(intRecordId),0) FROM @tblNodeData
	Update @tblNodeData Set intRecordId=@intMaxRecordCount,intParentId=@intParentId,strType='L' Where intParentId is null

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

		Update @tblNodeData Set intRecordId=2,intParentId=1,strType='L',strTransactionName='Produce' Where intParentId is null
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

	If (Select COUNT(1) From @tblNodeData)=0
	Begin
		Set @intDirectionId=1
		GOTO DIR_FORWARD	
	End
End

Update @tblNodeData Set strTransactionName='Work Order' Where strType='W'

Select * 
		,@strLotNumber AS strRecallLotNumber
		,@strCompanyName AS strCompanyName
		,@strCompanyAddress AS strCompanyAddress
		,@strCity + ', ' + @strState + ', ' + @strZip + ',' AS strCompanyCityStateZip
		,@strCountry AS strCompanyCountry
from @tblNodeData
