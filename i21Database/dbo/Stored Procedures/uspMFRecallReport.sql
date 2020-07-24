CREATE PROCEDURE [dbo].[uspMFRecallReport] @xmlParam NVARCHAR(MAX) = NULL
AS
SET NOCOUNT ON;

DECLARE @intPickListId INT
	,@idoc INT

IF LTRIM(RTRIM(@xmlParam)) = ''
	SET @xmlParam = NULL

DECLARE @temp_xml_table TABLE (
	[fieldname] NVARCHAR(50)
	,condition NVARCHAR(20)
	,[from] NVARCHAR(50)
	,[to] NVARCHAR(50)
	,[join] NVARCHAR(10)
	,[begingroup] NVARCHAR(50)
	,[endgroup] NVARCHAR(50)
	,[datatype] NVARCHAR(50)
	)

EXEC sp_xml_preparedocument @idoc OUTPUT
	,@xmlParam

INSERT INTO @temp_xml_table
SELECT *
FROM OPENXML(@idoc, 'xmlparam/filters/filter', 2) WITH (
		[fieldname] NVARCHAR(50)
		,condition NVARCHAR(20)
		,[from] NVARCHAR(50)
		,[to] NVARCHAR(50)
		,[join] NVARCHAR(10)
		,[begingroup] NVARCHAR(50)
		,[endgroup] NVARCHAR(50)
		,[datatype] NVARCHAR(50)
		)

DECLARE @intLotId INT
	,@intDirectionId INT
	,@ysnParentLot BIT = 0
	,@intObjectTypeId INT = 4
DECLARE @intRowCount INT
DECLARE @intMaxRecordCount INT
DECLARE @intId INT
DECLARE @intParentId INT
DECLARE @strType NVARCHAR(2)
DECLARE @intContractId INT
DECLARE @intShipmentId INT
DECLARE @intContainerId INT
DECLARE @strLotNumber NVARCHAR(50)
DECLARE @strRecallLotNumber NVARCHAR(50)
		,@intLocationId int

SELECT @intLotId = [from]
FROM @temp_xml_table
WHERE [fieldname] = 'intLotId'

SET @intDirectionId = 2

SELECT @strLotNumber = strLotNumber,@intLocationId=intLocationId
FROM tblICLot
WHERE intLotId = @intLotId

SELECT @strRecallLotNumber = @strLotNumber

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

DECLARE @tblTemp AS TABLE (
	intRecordId INT
	,intParentId INT
	,strTransactionName NVARCHAR(50)
	,intLotId INT
	,strLotNumber NVARCHAR(50)
	,strLotAlias NVARCHAR(50)
	,dblQuantity NUMERIC(18, 6)
	,strUOM NVARCHAR(50)
	,dtmTransactionDate DATETIME
	,intItemId INT
	,strItemNo NVARCHAR(50)
	,strItemDesc NVARCHAR(200)
	,intCategoryId INT
	,strCategoryCode NVARCHAR(50)
	,intParentLotId INT
	,strProcessName NVARCHAR(50)
	,strType NVARCHAR(2)
	,strVendor NVARCHAR(200)
	,strCustomer NVARCHAR(200)
	,intAttributeTypeId INT DEFAULT 0
	,intImageTypeId INT DEFAULT 0
	)
DECLARE @tblData AS TABLE (
	intRecordId INT
	,intParentId INT
	,strTransactionName NVARCHAR(50)
	,intLotId INT
	,strLotNumber NVARCHAR(50)
	,strLotAlias NVARCHAR(50)
	,dblQuantity NUMERIC(18, 6)
	,strUOM NVARCHAR(50)
	,dtmTransactionDate DATETIME
	,intItemId INT
	,strItemNo NVARCHAR(50)
	,strItemDesc NVARCHAR(200)
	,intCategoryId INT
	,strCategoryCode NVARCHAR(50)
	,intParentLotId INT
	,strProcessName NVARCHAR(50)
	,strType NVARCHAR(2)
	,strVendor NVARCHAR(200)
	,strCustomer NVARCHAR(200)
	,intAttributeTypeId INT DEFAULT 0
	,intImageTypeId INT DEFAULT 0
	,strText NVARCHAR(MAX)
	,dblWOQty NUMERIC(18, 6)
	)
DECLARE @tblNodeData AS TABLE (
	intRecordId INT
	,intParentId INT
	,strTransactionName NVARCHAR(50)
	,intLotId INT
	,strLotNumber NVARCHAR(50)
	,strLotAlias NVARCHAR(50)
	,dblQuantity NUMERIC(18, 6)
	,strUOM NVARCHAR(50)
	,dtmTransactionDate DATETIME
	,intItemId INT
	,strItemNo NVARCHAR(50)
	,strItemDesc NVARCHAR(200)
	,intCategoryId INT
	,strCategoryCode NVARCHAR(50)
	,intParentLotId INT
	,strProcessName NVARCHAR(50)
	,strType NVARCHAR(2)
	,strVendor NVARCHAR(200)
	,strCustomer NVARCHAR(200)
	,intAttributeTypeId INT DEFAULT 0
	,intImageTypeId INT DEFAULT 0
	)
DECLARE @tblLinkData AS TABLE (
	intFromRecordId INT
	,intToRecordId INT
	,strTransactionName NVARCHAR(50)
	)
DECLARE @tblMFExlude AS TABLE (
	intId INT
	,strName NVARCHAR(MAX)
	)

--Forward
DIR_FORWARD:

IF @intDirectionId = 1
BEGIN
	----Lot Detail
	--Insert Into @tblNodeData(strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
	--dblQuantity,strUOM,dtmTransactionDate,intParentLotId,intImageTypeId)
	--Exec uspMFGetTraceabilityLotDetail @intLotId,@intDirectionId,@ysnParentLot
	----Update vendor
	--Update @tblNodeData Set strVendor=(Select TOP 1 strName From vyuAPVendor Where intEntityId in (Select intEntityVendorId From tblICLot Where strLotNumber=@strLotNumber))
	--Receipt
	--Insert Into @tblNodeData(strTransactionName,intLotId,strLotNumber,strLotAlias,intItemId,strItemNo,strItemDesc,intCategoryId,strCategoryCode,
	--dblQuantity,strUOM,dtmTransactionDate,intParentLotId,strVendor,strType)
	--Exec uspMFGetTraceabilityLotReceiptDetail @intLotId,@ysnParentLot
	----Update RecordId, ParentId
	--SELECT @intMaxRecordCount = ISNULL(Max(intRecordId),0) + 1,@intParentId = ISNULL(Max(intRecordId),0) FROM @tblNodeData
	--Update @tblNodeData Set intRecordId=@intMaxRecordCount,intParentId=@intParentId Where intParentId is null
	--Lot Detail
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
		,intImageTypeId
		)
	EXEC uspMFGetTraceabilityLotDetail @intLotId
		,@intDirectionId
		,@ysnParentLot
		,@intLocationId

	--Update RecordId, ParentId
	SELECT @intMaxRecordCount = ISNULL(Max(intRecordId), 0) + 1
		,@intParentId = ISNULL(Max(intRecordId), 0)
	FROM @tblNodeData

	UPDATE @tblNodeData
	SET intRecordId = @intMaxRecordCount
		,intParentId = @intParentId
		,strType = 'L'
	WHERE intParentId IS NULL

	--Counter Data for the while loop
	SELECT @intMaxRecordCount = Max(intRecordId)
		,@intParentId = Max(intRecordId)
	FROM @tblNodeData

	INSERT INTO @tblTemp (
		intRecordId
		,intParentId
		,strTransactionName
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
		)
	SELECT TOP 1 intRecordId
		,intParentId
		,strTransactionName
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
	FROM @tblNodeData
	ORDER BY intRecordId DESC

	SET @intRowCount = 1

	WHILE (@intRowCount > 0)
	BEGIN
		DECLARE @FCUR CURSOR SET @FCUR = CURSOR
		FOR
		SELECT DISTINCT intLotId
			,intRecordId
			,strType
		FROM @tblTemp

		OPEN @FCUR

		FETCH NEXT
		FROM @FCUR
		INTO @intId
			,@intParentId
			,@strType

		WHILE @@FETCH_STATUS = 0
		BEGIN
			-- From Lot to WorkOrders
			IF @strType = 'L'
				INSERT INTO @tblData (
					strTransactionName
					,intLotId
					,strLotNumber
					,intItemId
					,strItemNo
					,strItemDesc
					,intCategoryId
					,strCategoryCode
					,dblQuantity
					,strUOM
					,dtmTransactionDate
					,strProcessName
					,strType
					,intAttributeTypeId
					,strText
					,dblWOQty
					)
				EXEC uspMFGetTraceabilityWorkOrderDetail @intId
					,@intDirectionId
					,@ysnParentLot
					,@intLocationId

			-- WorkOrder Output details
			IF @strType = 'W'
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
					,intParentLotId
					,strType
					,intAttributeTypeId
					,intImageTypeId
					)
				EXEC uspMFGetTraceabilityWorkOrderOutputDetail @intId
					,@ysnParentLot
					,@intLocationId

			-- Lot Split
			IF @strType = 'L'
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
					,intParentLotId
					,strType
					,intImageTypeId
					)
				EXEC uspMFGetTraceabilityLotSplitDetail @intId
					,@intDirectionId
					,@ysnParentLot
					,@intLocationId

			-- Lot Ship
			IF @strType = 'L'
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
				EXEC uspMFGetTraceabilityLotShipDetail @intId
					,@ysnParentLot
					,@intLocationId

			UPDATE @tblData
			SET intParentId = @intParentId
			WHERE intParentId IS NULL

			FETCH NEXT
			FROM @FCUR
			INTO @intId
				,@intParentId
				,@strType
		END

		DELETE
		FROM @tblTemp

		INSERT INTO @tblTemp (
			intRecordId
			,intParentId
			,strTransactionName
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
			,strVendor
			,strCustomer
			,strProcessName
			,strType
			,intAttributeTypeId
			,intImageTypeId
			)
		SELECT (
				@intMaxRecordCount + ROW_NUMBER() OVER (
					ORDER BY intLotId ASC
					)
				) AS intRecordId
			,intParentId
			,strTransactionName
			,intLotId
			,strLotNumber
			,strLotAlias
			,intItemId
			,strItemNo
			,strItemDesc
			,intCategoryId
			,strCategoryCode
			,SUM(dblQuantity)
			,strUOM
			,dtmTransactionDate
			,intParentLotId
			,strVendor
			,strCustomer
			,strProcessName
			,strType
			,intAttributeTypeId
			,intImageTypeId
		FROM @tblData
		Where strTransactionName<>'Qty Adjust'
		GROUP BY intParentId
			,strTransactionName
			,intLotId
			,strLotNumber
			,strLotAlias
			,intItemId
			,strItemNo
			,strItemDesc
			,intCategoryId
			,strCategoryCode
			,strUOM
			,dtmTransactionDate
			,intParentLotId
			,strVendor
			,strCustomer
			,strProcessName
			,strType
			,intAttributeTypeId
			,intImageTypeId

		INSERT INTO @tblTemp (
			intRecordId
			,intParentId
			,strTransactionName
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
			,strVendor
			,strCustomer
			,strProcessName
			,strType
			,intAttributeTypeId
			,intImageTypeId
			)
		SELECT (
				@intMaxRecordCount + ROW_NUMBER() OVER (
					ORDER BY intLotId ASC
					)
				) AS intRecordId
			,intParentId
			,strTransactionName
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
			,strVendor
			,strCustomer
			,strProcessName
			,strType
			,intAttributeTypeId
			,intImageTypeId
		FROM @tblData
		Where strTransactionName='Qty Adjust'

		--Node Date
		INSERT INTO @tblNodeData (
			intRecordId
			,intParentId
			,strTransactionName
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
			,strVendor
			,strCustomer
			,strProcessName
			,strType
			,intAttributeTypeId
			,intImageTypeId
			)
		SELECT intRecordId
			,intParentId
			,strTransactionName
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
			,strVendor
			,strCustomer
			,strProcessName
			,strType
			,intAttributeTypeId
			,intImageTypeId
		FROM @tblTemp

		DELETE
		FROM @tblData

		SELECT @intMaxRecordCount = Max(intRecordId)
		FROM @tblTemp

		DELETE
		FROM @tblTemp
		WHERE strTransactionName = 'Ship'

		SELECT @intRowCount = COUNT(1)
		FROM @tblTemp
	END
END

--Reverse
IF @intDirectionId = 2
BEGIN
	--Lot
	IF @intObjectTypeId = 4
	BEGIN
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
		EXEC uspMFGetTraceabilityLotShipDetail @intLotId
			,@ysnParentLot
			,@intLocationId

		UPDATE @tblNodeData
		SET intRecordId = 1
			,intParentId = 0

		--Lot Detail
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
			,intImageTypeId
			)
		EXEC uspMFGetTraceabilityLotDetail @intLotId
			,@intDirectionId
			,@ysnParentLot
			,@intLocationId

		UPDATE @tblNodeData
		SET intRecordId = 2
			,intParentId = 1
			,strType = 'L'
			,strTransactionName = 'Produce'
		WHERE intParentId IS NULL
	END

	--Shipment
	IF @intObjectTypeId = 7
	BEGIN
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
		EXEC uspMFGetTraceabilityShipmentDetail @intLotId,@intLocationId

		UPDATE @tblNodeData
		SET intRecordId = 1
			,intParentId = 0

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
		EXEC uspMFGetTraceabilityShipmentLots @intLotId
			,@ysnParentLot
			,@intLocationId

		--Update @tblNodeData Set intRecordId=2,intParentId=1,strType='L' Where intParentId is null
		DECLARE @intRecCounter INT = 1

		UPDATE @tblNodeData
		SET @intRecCounter = intRecordId = @intRecCounter + 1
			,intParentId = 1
			,strType = 'L'
		WHERE intParentId IS NULL
	END

	--Counter Data for the while loop
	SELECT @intMaxRecordCount = Max(intRecordId)
		,@intParentId = Max(intRecordId)
	FROM @tblNodeData

	INSERT INTO @tblTemp (
		intRecordId
		,intParentId
		,strTransactionName
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
		)
	SELECT TOP 1 intRecordId
		,intParentId
		,strTransactionName
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
	FROM @tblNodeData
	ORDER BY intRecordId DESC

	SET @intRowCount = 1

	WHILE (@intRowCount > 0)
	BEGIN
		DECLARE @RCUR CURSOR SET @RCUR = CURSOR
		FOR
		SELECT DISTINCT intLotId
			,intRecordId
			,strType
			,strLotNumber
		FROM @tblTemp

		OPEN @RCUR

		FETCH NEXT
		FROM @RCUR
		INTO @intId
			,@intParentId
			,@strType
			,@strLotNumber

		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @intContractId = NULL
			SET @intContainerId = NULL
			SET @intShipmentId = NULL

			-- From Lot to WorkOrders
			IF @strType = 'L'
				INSERT INTO @tblData (
					strTransactionName
					,intLotId
					,strLotNumber
					,intItemId
					,strItemNo
					,strItemDesc
					,intCategoryId
					,strCategoryCode
					,dblQuantity
					,strUOM
					,dtmTransactionDate
					,strProcessName
					,strType
					,intAttributeTypeId
					,strText
					,dblWOQty
					)
				EXEC uspMFGetTraceabilityWorkOrderDetail @intId
					,@intDirectionId
					,@ysnParentLot
					,@intLocationId 

			-- WorkOrder Input details
			IF @strType = 'W'
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
					,intParentLotId
					,strType
					,intAttributeTypeId
					,intImageTypeId
					)
				EXEC uspMFGetTraceabilityWorkOrderInputDetail @intId
					,@ysnParentLot
					,@intLocationId 

			IF @strType = 'L'
			BEGIN
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
					,intParentLotId
					,strType
					,intImageTypeId
					,strText
					)
				EXEC uspMFGetTraceabilityLotMergeDetail @intId
					,@intDirectionId
					,@ysnParentLot
					,1
					,@intLocationId

				INSERT INTO @tblMFExlude
				SELECT intLotId
					,strLotNumber
				FROM @tblData
				WHERE strTransactionName = 'Merge'
			END

			IF @strType = 'L'
			BEGIN
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
					,intParentLotId
					,strType
					,intImageTypeId
					,strText
					)
				EXEC uspMFGetTraceabilityLotAdjustDetail @intId
					,@intDirectionId
					,@ysnParentLot
					,1

				INSERT INTO @tblMFExlude
				SELECT intLotId
					,strLotNumber
				FROM @tblData
				WHERE strTransactionName = 'Qty Adjust'
			END

			-- Lot Split
			IF @strType = 'L'
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
					,intParentLotId
					,strType
					,intImageTypeId
					)
				EXEC uspMFGetTraceabilityLotSplitDetail @intId
					,@intDirectionId
					,@ysnParentLot
					,@intLocationId

			-- Lot Receipt
			IF @strType = 'L'
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
					,intParentLotId
					,strVendor
					,strType
					)
				EXEC uspMFGetTraceabilityLotReceiptDetail @intId
					,@ysnParentLot
					,@intLocationId

			UPDATE @tblData
			SET intParentId = @intParentId
			WHERE intParentId IS NULL

			INSERT INTO @tblMFExlude
			SELECT @intId
				,@strLotNumber

			FETCH NEXT
			FROM @RCUR
			INTO @intId
				,@intParentId
				,@strType
				,@strLotNumber
		END

		DELETE
		FROM @tblTemp

		INSERT INTO @tblTemp (
			intRecordId
			,intParentId
			,strTransactionName
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
			,strVendor
			,strCustomer
			,strProcessName
			,strType
			,intAttributeTypeId
			,intImageTypeId
			)
		SELECT (
				@intMaxRecordCount + ROW_NUMBER() OVER (
					ORDER BY intLotId ASC
					)
				) AS intRecordId
			,intParentId
			,strTransactionName
			,intLotId
			,strLotNumber
			,strLotAlias
			,intItemId
			,strItemNo
			,strItemDesc
			,intCategoryId
			,strCategoryCode
			,SUM(dblQuantity)
			,strUOM
			,dtmTransactionDate
			,intParentLotId
			,strVendor
			,strCustomer
			,strProcessName
			,strType
			,intAttributeTypeId
			,intImageTypeId
		FROM @tblData
		Where strTransactionName<>'Qty Adjust'
		GROUP BY intParentId
			,strTransactionName
			,intLotId
			,strLotNumber
			,strLotAlias
			,intItemId
			,strItemNo
			,strItemDesc
			,intCategoryId
			,strCategoryCode
			,strUOM
			,dtmTransactionDate
			,intParentLotId
			,strVendor
			,strCustomer
			,strProcessName
			,strType
			,intAttributeTypeId
			,intImageTypeId

		INSERT INTO @tblTemp (
			intRecordId
			,intParentId
			,strTransactionName
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
			,strVendor
			,strCustomer
			,strProcessName
			,strType
			,intAttributeTypeId
			,intImageTypeId
			)
		SELECT (
				@intMaxRecordCount + ROW_NUMBER() OVER (
					ORDER BY intLotId ASC
					)
				) AS intRecordId
			,intParentId
			,strTransactionName
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
			,strVendor
			,strCustomer
			,strProcessName
			,strType
			,intAttributeTypeId
			,intImageTypeId
		FROM @tblData
		Where strTransactionName='Qty Adjust'

		--Node Date
		INSERT INTO @tblNodeData (
			intRecordId
			,intParentId
			,strTransactionName
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
			,strVendor
			,strCustomer
			,strProcessName
			,strType
			,intAttributeTypeId
			,intImageTypeId
			)
		SELECT intRecordId
			,intParentId
			,strTransactionName
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
			,strVendor
			,strCustomer
			,strProcessName
			,strType
			,intAttributeTypeId
			,intImageTypeId
		FROM @tblTemp

		DELETE
		FROM @tblData

		DELETE
		FROM @tblTemp
		WHERE EXISTS (
				SELECT *
				FROM @tblMFExlude
				WHERE intId = intLotId
					AND strName = strLotNumber
				)

		SELECT @intMaxRecordCount = Max(intRecordId)
		FROM @tblTemp

		--Delete From @tblTemp Where strTransactionName='Receipt'
		SELECT @intRowCount = COUNT(1)
		FROM @tblTemp
	END

	--Insert Into @tblLinkData(intFromRecordId,intToRecordId,strTransactionName)
	--Select intParentId,intRecordId,strTransactionName From @tblNodeData
	IF (
			SELECT COUNT(1)
			FROM @tblNodeData
			) > 0
	BEGIN
		SELECT TOP 1 @intLotId = intLotId
		FROM @tblNodeData
		WHERE strType = 'L'
		ORDER BY intRecordId DESC

		SET @intDirectionId = 1

		GOTO DIR_FORWARD
	END
END

UPDATE @tblNodeData
SET strTransactionName = 'Work Order'
WHERE strType = 'W'

SELECT *
	,@strRecallLotNumber AS strRecallLotNumber
	,@strCompanyName AS strCompanyName
	,@strCompanyAddress AS strCompanyAddress
	,@strCity + ', ' + @strState + ', ' + @strZip + ',' AS strCompanyCityStateZip
	,@strCountry AS strCompanyCountry
	,pl.strParentLotNumber
FROM @tblNodeData n
LEFT JOIN tblICParentLot pl ON n.intParentLotId = pl.intParentLotId
	AND n.strType = 'L'
