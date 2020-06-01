CREATE PROCEDURE [dbo].[uspMFGetTraceabilityDiagram] @intLotId INT
	,@intLocationId INT
	,@intDirectionId INT
	,@ysnParentLot BIT = 0
	,@intObjectTypeId INT = 4
AS
SET NOCOUNT ON;

DECLARE @intRowCount INT
DECLARE @intMaxRecordCount INT
DECLARE @intId INT
DECLARE @intParentId INT
DECLARE @strType NVARCHAR(2)
DECLARE @intContractId INT
DECLARE @intShipmentId INT
DECLARE @intContainerId INT
DECLARE @intNoOfShipRecord INT
DECLARE @intNoOfShipRecordCounter INT
DECLARE @intNoOfShipRecordParentCounter INT
DECLARE @strTransactionName NVARCHAR(50)
DECLARE @strLotNumber NVARCHAR(MAX)
Declare @intItemId int
Declare @strType1 nvarchar(50)

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
	,strText NVARCHAR(MAX)
	,dblWOQty NUMERIC(18, 6)
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
	,ysnProcessed BIT DEFAULT 0
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
	,strText NVARCHAR(MAX)
	,dblWOQty NUMERIC(18, 6)
	)
DECLARE @tblNodeDataFinal AS TABLE (
	[key] INT
	,intRecordId INT
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
	,strImage NVARCHAR(max)
	,strNodeText NVARCHAR(max)
	,strToolTip NVARCHAR(max)
	,intControlPointId INT
	,ysnExcludedNode BIT DEFAULT 0
	,intGroupRowNo INT
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
IF @intDirectionId = 1
BEGIN
	--Contract
	IF @intObjectTypeId = 1
	BEGIN
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
			,strVendor
			,intImageTypeId
			,strType
			)
		EXEC uspMFGetTraceabilityContractDetail @intLotId
			,@intDirectionId,NULL,@intLocationId

		UPDATE @tblNodeData
		SET intRecordId = 1
			,intParentId = 0
	END

	--In Shipment
	IF @intObjectTypeId = 2
	BEGIN
		SELECT TOP 1 @intContractId = intPContractHeaderId
		FROM vyuLGLoadContainerReceiptContracts
		WHERE intLoadId = @intLotId

		--Contract
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
			,strVendor
			,intImageTypeId
			,strType
			)
		EXEC uspMFGetTraceabilityContractDetail @intContractId
			,@intDirectionId
			,NULL
			,@intLocationId

		UPDATE @tblNodeData
		SET intRecordId = 1
			,intParentId = 0

		--In Shipment
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
			,strVendor
			,strType
			)
		EXEC uspMFGetTraceabilityInboundShipmentDetail @intLotId
			,@intDirectionId
			,@intLocationId

		UPDATE @tblNodeData
		SET intRecordId = 2
			,intParentId = 1
		WHERE intParentId IS NULL
	END

	--Container
	IF @intObjectTypeId = 3
	BEGIN
		SELECT TOP 1 @intContractId = intPContractHeaderId
			,@intShipmentId = intLoadId
		FROM vyuLGLoadContainerReceiptContracts
		WHERE intLoadContainerId = @intLotId

		--Contract
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
			,strVendor
			,intImageTypeId
			,strType
			)
		EXEC uspMFGetTraceabilityContractDetail @intContractId
			,@intDirectionId
			,NULL
			,@intLocationId

		UPDATE @tblNodeData
		SET intRecordId = 1
			,intParentId = 0

		--In Shipment
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
			,strVendor
			,strType
			)
		EXEC uspMFGetTraceabilityInboundShipmentDetail @intShipmentId
			,@intDirectionId
			,@intLocationId

		UPDATE @tblNodeData
		SET intRecordId = 2
			,intParentId = 1
		WHERE intParentId IS NULL

		--Container
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
			,strVendor
			,strType
			)
		EXEC uspMFGetTraceabilityContainerDetail @intLotId
			,@intDirectionId

		UPDATE @tblNodeData
		SET intRecordId = 3
			,intParentId = 2
		WHERE intParentId IS NULL
	END

	--Lot
	IF @intObjectTypeId = 4
	BEGIN
		--If Lot is received via Contract show contract
		SELECT TOP 1 @intContractId = ISNULL(ri.intOrderId, 0)
			,@intShipmentId = ISNULL(ld.intLoadId, 0)
			,@intContainerId = ISNULL(ri.intContainerId, 0)
			,@intItemId=ri.intItemId
		FROM tblICInventoryReceiptItem ri
		JOIN tblICInventoryReceiptItemLot rl ON ri.intInventoryReceiptItemId = rl.intInventoryReceiptItemId
		JOIN tblICInventoryReceipt rh ON ri.intInventoryReceiptId = rh.intInventoryReceiptId
		LEFT JOIN tblLGLoadDetail ld ON ri.intSourceId = ld.intLoadDetailId
		JOIN tblICLot l ON rl.intLotId = l.intLotId
		WHERE Exists (
				SELECT 1
				FROM tblICLot L1
				WHERE L1.intLotId = @intLotId and L1.strLotNumber=l.strLotNumber
				and L1.intItemId=ri.intItemId
				)
			AND rh.strReceiptType = 'Purchase Contract'

		--Contract
		IF @intContractId > 0
		BEGIN
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
				,strVendor
				,intImageTypeId
				,strType
				)
			EXEC uspMFGetTraceabilityContractDetail @intContractId
				,@intDirectionId
				,@intItemId
				,@intLocationId

			UPDATE @tblNodeData
			SET intRecordId = 1
				,intParentId = 0
		END

		--Shipment
		IF @intShipmentId > 0
		BEGIN
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
				,strVendor
				,strType
				)
			EXEC uspMFGetTraceabilityInboundShipmentDetail @intShipmentId
				,@intDirectionId
				,@intLocationId

			UPDATE @tblNodeData
			SET intRecordId = 2
				,intParentId = 1
			WHERE intParentId IS NULL
		END

		--Container
		IF @intContainerId > 0
		BEGIN
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
				,strVendor
				,strType
				)
			EXEC uspMFGetTraceabilityContainerDetail @intContainerId
				,@intDirectionId

			UPDATE @tblNodeData
			SET intRecordId = 3
				,intParentId = 2
			WHERE intParentId IS NULL
		END

		--Receipt
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
			,strVendor
			,strType
			)
		EXEC uspMFGetTraceabilityLotReceiptDetail @intLotId
			,@ysnParentLot
			,@intLocationId

		--If @intContractId > 0
		--	Update @tblNodeData Set intRecordId=2,intParentId=1,strTransactionName='Contract' Where intParentId is null
		--Else
		--	Update @tblNodeData Set intRecordId=1,intParentId=0 Where intParentId is null
		--Update RecordId, ParentId
		SELECT @intMaxRecordCount = ISNULL(Max(intRecordId), 0) + 1
			,@intParentId = ISNULL(Max(intRecordId), 0)
		FROM @tblNodeData

		UPDATE @tblNodeData
		SET intRecordId = @intMaxRecordCount
			,intParentId = @intParentId
		WHERE intParentId IS NULL

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

		--Update @tblNodeData Set intRecordId=2,intParentId=1,strType='L' Where intParentId is null
		--If @intContractId > 0
		--	Update @tblNodeData Set intRecordId=3,intParentId=2,strType='L' Where intParentId is null
		--Else
		--	Update @tblNodeData Set intRecordId=2,intParentId=1,strType='L' Where intParentId is null
		--Update RecordId, ParentId
		SELECT @intMaxRecordCount = ISNULL(Max(intRecordId), 0) + 1
			,@intParentId = ISNULL(Max(intRecordId), 0)
		FROM @tblNodeData

		UPDATE @tblNodeData
		SET intRecordId = @intMaxRecordCount
			,intParentId = @intParentId
			,strType = 'L'
		WHERE intParentId IS NULL
	END

	--Receipt
	IF @intObjectTypeId = 6
	BEGIN
		SELECT TOP 1 @intContractId = lg.intPContractHeaderId
			,@intShipmentId = lg.intLoadId
			,@intContainerId = lg.intLoadContainerId
		FROM vyuLGLoadContainerReceiptContracts lg
		JOIN tblICInventoryReceiptItem ri ON lg.intLoadContainerId = ri.intContainerId
		WHERE ri.intInventoryReceiptId = @intLotId

		--Contract -> In Shipment -> Container ->Receipt
		IF ISNULL(@intContainerId, 0) > 0
		BEGIN
			--Contract
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
				,strVendor
				,intImageTypeId
				,strType
				)
			EXEC uspMFGetTraceabilityContractDetail @intContractId
				,@intDirectionId
				,NULL
				,@intLocationId

			UPDATE @tblNodeData
			SET intRecordId = 1
				,intParentId = 0

			--In Shipment
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
				,strVendor
				,strType
				)
			EXEC uspMFGetTraceabilityInboundShipmentDetail @intShipmentId
				,@intDirectionId
				,@intLocationId

			UPDATE @tblNodeData
			SET intRecordId = 2
				,intParentId = 1
			WHERE intParentId IS NULL

			--Container
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
				,strVendor
				,strType
				)
			EXEC uspMFGetTraceabilityContainerDetail @intContainerId
				,@intDirectionId

			UPDATE @tblNodeData
			SET intRecordId = 3
				,intParentId = 2
			WHERE intParentId IS NULL
		END

		--Contract -> Receipt
		IF ISNULL(@intContainerId, 0) = 0
		BEGIN
			SELECT TOP 1 @intContractId = ISNULL(ri.intOrderId, 0)
			FROM tblICInventoryReceiptItem ri
			JOIN tblICInventoryReceipt rh ON ri.intInventoryReceiptId = rh.intInventoryReceiptId
			WHERE rh.intInventoryReceiptId = @intLotId
				AND rh.strReceiptType = 'Purchase Contract'

			IF ISNULL(@intContractId, 0) > 0
			BEGIN
				SELECT TOP 1 @intContractId = lg.intPContractHeaderId
					,@intShipmentId = lg.intLoadId
					,@intContainerId = lg.intLoadContainerId
				FROM vyuLGLoadContainerReceiptContracts lg
				JOIN tblICInventoryReceiptItem ri ON lg.intLoadContainerId = ri.intContainerId
				WHERE ri.intInventoryReceiptId = @intLotId

				--Contract
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
					,strVendor
					,intImageTypeId
					,strType
					)
				EXEC uspMFGetTraceabilityContractDetail @intContractId
					,@intDirectionId
					,NULL
					,@intLocationId

				UPDATE @tblNodeData
				SET intRecordId = 1
					,intParentId = 0

				--Receipt
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
					,strVendor
					,strType
					)
				EXEC uspMFGetTraceabilityReceiptDetail @intLotId,@intLocationId

				UPDATE @tblNodeData
				SET intRecordId = 2
					,intParentId = 1
				WHERE intParentId IS NULL
			END
		END

		--Receipt Only
		IF ISNULL(@intContractId, 0) = 0
		BEGIN
			--Receipt
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
				,strVendor
				,strType
				)
			EXEC uspMFGetTraceabilityReceiptDetail @intLotId,@intLocationId

			UPDATE @tblNodeData
			SET intRecordId = 1
				,intParentId = 0
		END
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
			--Inbound Shipment From Contract
			IF @strType = 'C'
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
				EXEC uspMFGetTraceabilityInboundShipmentFromContract @intId,@intLocationId

			--Container From Inbound Shipment
			IF @strType = 'IS'
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
				EXEC uspMFGetTraceabilityContainerFromInboundShipment @intId

			--Receipt From Container
			IF @strType = 'CN'
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
				EXEC uspMFGetTraceabilityReceiptFromContainer @intId,@intLocationId

			--Receipt From Contract
			IF @strType = 'C'
				AND NOT EXISTS (
					SELECT 1
					FROM @tblData
					WHERE strType = 'IS'
					)
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
				EXEC uspMFGetTraceabilityReceiptFromContract @intId,@intLocationId

			--Lots From Receipt
			IF @strType = 'R'
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
				EXEC uspMFGetTraceabilityLotsFromReceipt @intId
					,@ysnParentLot
					,@intLocationId

			-- From Lot to WorkOrders
			IF @strType = 'L'
			BEGIN
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

				--Remove circular Reference, Remove the WO if exists
				IF EXISTS (
						SELECT 1
						FROM @tblData
						WHERE intLotId IN (
								SELECT intLotId
								FROM @tblNodeData
								WHERE strType = 'W'
								)
						)
					DELETE
					FROM @tblData
			END

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
					,strCustomer
					,strType
					)
				EXEC uspMFGetTraceabilityLotShipDetail @intId
					,@ysnParentLot
					,@intLocationId

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
					,@intLocationId
			END

			-- Sales Order & Invoice from Shipment
			IF @strType = 'S'
			BEGIN
				--SO
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
				EXEC uspMFGetTraceabilitySalesOrderFromShipment @intId,@intLocationId

				--Invoice
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
				EXEC uspMFGetTraceabilityInvoiceFromShipment @intId,@intLocationId
			END

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

		--Delete From @tblTemp Where strTransactionName='Ship'
		SELECT @intRowCount = COUNT(1)
		FROM @tblTemp
	END

	--Duplicate Shipments for linking if SO exists
	IF EXISTS (
			SELECT 1
			FROM @tblNodeData
			WHERE strType = 'SO'
			)
	BEGIN
		SELECT @intMaxRecordCount = Max(intRecordId)
		FROM @tblNodeData

		--Get the Corresponding Ship records for the SO and add it again
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
		SELECT (
				@intMaxRecordCount + ROW_NUMBER() OVER (
					ORDER BY n1.intLotId ASC
					)
				) AS intRecordId
			,n2.intRecordId
			,n1.strTransactionName
			,n1.intLotId
			,n1.strLotNumber
			,n1.strLotAlias
			,n1.intItemId
			,n1.strItemNo
			,n1.strItemDesc
			,n1.intCategoryId
			,n1.strCategoryCode
			,n1.dblQuantity
			,n1.strUOM
			,n1.dtmTransactionDate
			,n1.intParentLotId
			,n1.strVendor
			,n1.strCustomer
			,n1.strProcessName
			,n1.strType
			,n1.intAttributeTypeId
			,n1.intImageTypeId
		FROM @tblNodeData n1
		JOIN (
			SELECT *
			FROM @tblNodeData
			WHERE strType = 'SO'
			) n2 ON n1.intRecordId = n2.intParentId

		UPDATE @tblNodeData
		SET intParentId = 0
		WHERE strType = 'SO'
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
			,@intLocationId

		--Generate RecordId for all the Shipments (include multiple shipments)
		UPDATE t
		SET t.intRecordId = t.intRowNo
			,t.intParentId = 0
		FROM (
			SELECT intRecordId
				,intParentId
				,ROW_NUMBER() OVER (
					ORDER BY intLotId
					) AS intRowNo
			FROM @tblNodeData
			) t

		SELECT @intNoOfShipRecord = count(1)
		FROM @tblNodeData

		SET @intNoOfShipRecordCounter = @intNoOfShipRecord
		SET @intNoOfShipRecordParentCounter = 1

		IF Isnull(@intNoOfShipRecordCounter, 0) = 0
			SET @intNoOfShipRecordCounter = 1

		--Lot Detail -- Add one or many depending on no of ship records
		WHILE (@intNoOfShipRecordCounter > 0)
		BEGIN
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
			SET intRecordId = (
					SELECT CASE 
							WHEN count(1) = 1
								THEN 2
							ELSE count(1)
							END
					FROM @tblNodeData
					)
				,intParentId = @intNoOfShipRecordParentCounter
				,strType = 'L'
			WHERE intParentId IS NULL

			-- Invoice from Shipment
			BEGIN
				Select @strType1=''
				--Get ShipmentId to find if invoice exists
				IF @intId IS NULL
					SELECT TOP 1 @intId = intLotId,@strType1=strType
					FROM @tblNodeData
					WHERE strType IN (
							'S'
							,'OS'
							)
					ORDER BY 1
				ELSE
					SELECT TOP 1 @intId = intLotId,@strType1=strType
					FROM @tblNodeData
					WHERE intLotId > @intId
						AND strType IN (
							'S'
							,'OS'
							)

				--Invoice
				if @strType1='S'
				Begin
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
					EXEC uspMFGetTraceabilityInvoiceFromShipment @intId,@intLocationId
				End
				Else
				Begin
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
					EXEC uspMFGetTraceabilityInvoiceFromOutboundShipment @intId,@intLocationId
				End
				--update ShipmentId in intParentLotId for Invoice used in getting ParentId in case Invoice exists
				UPDATE @tblData
				SET intParentLotId = @intId
				WHERE intParentLotId IS NULL

				--update ShipmentId in intAttributeTypeId for Lot used in getting ParentId in case Invoice exists
				UPDATE @tblNodeData
				SET intAttributeTypeId = @intId
				WHERE ISNULL(intAttributeTypeId, 0) = 0
			END

			SET @intNoOfShipRecordCounter = @intNoOfShipRecordCounter - 1
			SET @intNoOfShipRecordParentCounter = @intNoOfShipRecordParentCounter + 1
		END

		--Invoice if exists adjust the sequence
		IF EXISTS (
				SELECT 1
				FROM @tblData
				WHERE strType = 'IN'
				)
		BEGIN
			--Generate RecordId for all the Invoices
			UPDATE t
			SET t.intRecordId = t.intRowNo
				,t.intParentId = 0
			FROM (
				SELECT intRecordId
					,intParentId
					,ROW_NUMBER() OVER (
						ORDER BY intLotId
						) AS intRowNo
				FROM @tblData
				) t

			--Copy the Shipments/Lots to temp
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
				,strCustomer
				,strType
				,intParentLotId
				,intImageTypeId
				,intAttributeTypeId
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
				,strCustomer
				,strType
				,intParentLotId
				,intImageTypeId
				,intAttributeTypeId
			FROM @tblNodeData

			DELETE
			FROM @tblNodeData

			--Insert Invoices to @tblNodeData
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
				,strCustomer
				,strType
				,intParentLotId
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
				,strCustomer
				,strType
				,intParentLotId
			FROM @tblData

			DELETE
			FROM @tblData

			SELECT @intMaxRecordCount = COUNT(1)
			FROM @tblNodeData

			--Adjust the intRecordId, intParentId for Shipments/Lots in @tblTemp
			UPDATE t
			SET t.intRecordId = @intMaxRecordCount + t.intRowNo
			FROM (
				SELECT intRecordId
					,intParentId
					,ROW_NUMBER() OVER (
						ORDER BY intLotId
						) AS intRowNo
				FROM @tblTemp
				) t

			--Update intParentId for Shipments
			UPDATE t
			SET t.intParentId = n.intRecordId
			FROM @tblTemp t
			JOIN @tblNodeData n ON t.intLotId = n.intParentLotId
			WHERE t.strType IN (
					'S'
					,'OS'
					)

			--Update intParentId for Lots 			
			UPDATE t
			SET t.intParentId = n.intRecordId
			FROM @tblTemp t
			JOIN (
				SELECT *
				FROM @tblTemp
				WHERE strType IN (
						'S'
						,'OS'
						)
				) n ON t.intAttributeTypeId = n.intLotId
			WHERE t.strType = 'L'

			--Copy the Shipments/Lots from temp to @tblNodeData
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
				,strCustomer
				,strType
				,intParentLotId
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
				,strCustomer
				,strType
				,intParentLotId
				,intImageTypeId
			FROM @tblTemp

			DELETE
			FROM @tblTemp
		END
	END

	--Shipment
	IF @intObjectTypeId = 7
	BEGIN
		DECLARE @ysnInvoiceExist BIT = 0

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
		EXEC uspMFGetTraceabilityInvoiceFromShipment @intLotId,@intLocationId

		IF EXISTS (
				SELECT 1
				FROM @tblNodeData
				WHERE strType = 'IN'
				)
			SET @ysnInvoiceExist = 1

		IF @ysnInvoiceExist = 1
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
		EXEC uspMFGetTraceabilityShipmentDetail @intLotId,@intLocationId 

		IF @ysnInvoiceExist = 1
			UPDATE @tblNodeData
			SET intRecordId = 2
				,intParentId = 1
			WHERE strType = 'S'
		ELSE
			UPDATE @tblNodeData
			SET intRecordId = 1
				,intParentId = 0
			WHERE strType = 'S'

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
		DECLARE @intRecCounter INT = CASE 
				WHEN @ysnInvoiceExist = 1
					THEN 2
				ELSE 1
				END

		UPDATE @tblNodeData
		SET @intRecCounter = intRecordId = @intRecCounter + 1
			,intParentId = (
				CASE 
					WHEN @ysnInvoiceExist = 1
						THEN 2
					ELSE 1
					END
				)
			,strType = 'L'
		WHERE intParentId IS NULL
	END

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
		EXEC uspMFGetTraceabilityInvoiceFromOutboundShipment @intLotId,@intLocationId

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
		EXEC uspMFGetTraceabilityOutboundShipmentDetail @intLotId,@intLocationId

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
			,@ysnParentLot,@intLocationId

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
	IF EXISTS (
			SELECT 1
			FROM @tblNodeData
			WHERE strType = 'S'
			)
	BEGIN
		SET @intNoOfShipRecordCounter = NULL

		SELECT @intNoOfShipRecordCounter = MIN(intRecordId)
		FROM @tblNodeData
		WHERE strType = 'S'

		WHILE (@intNoOfShipRecordCounter IS NOT NULL)
		BEGIN
			SELECT @intId = intLotId
			FROM @tblNodeData
			WHERE intRecordId = @intNoOfShipRecordCounter

			SELECT @intMaxRecordCount = Max(intRecordId)
			FROM @tblNodeData

			--SO
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
			EXEC uspMFGetTraceabilitySalesOrderFromShipment @intId,@intLocationId 

			UPDATE @tblNodeData
			SET intRecordId = @intMaxRecordCount + 1
				,intParentId = @intNoOfShipRecordCounter
			WHERE intRecordId IS NULL

			SELECT @intNoOfShipRecordCounter = MIN(intRecordId)
			FROM @tblNodeData
			WHERE strType = 'S'
				AND intRecordId > @intNoOfShipRecordCounter
		END
	END

	--Counter Data for the while loop
	SELECT @intMaxRecordCount = Max(intRecordId)
		,@intParentId = Max(intRecordId)
	FROM @tblNodeData

	--Shipment
	IF (
			@intObjectTypeId = 7
			OR @intObjectTypeId = 8
			)
	BEGIN
		--Point the Record Id to the first visible Lot Node depending on no of shipments (multiple shipments) , case statement refers to that
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
		SELECT intRecordId - (
				CASE 
					WHEN @intNoOfShipRecord > 0
						THEN (@intNoOfShipRecord - 1)
					ELSE 0
					END
				)
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
		WHERE strType NOT IN ('SO')
		ORDER BY intRecordId DESC

		SELECT @intRowCount = COUNT(1)
		FROM @tblTemp
	END
	ELSE
	BEGIN
		--Point the Record Id to the first visible Lot Node depending on no of shipments (multiple shipments) , case statement refers to that
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
			,strType
		FROM @tblNodeData
		WHERE strType NOT IN (
				'OS'
				,'SO'
				,'IN'
				,'S'
				)
		ORDER BY intRecordId DESC

		SET @intRowCount = 1
	END

	WHILE (@intRowCount > 0)
	BEGIN
		DECLARE @RCUR CURSOR SET @RCUR = CURSOR
		FOR
		SELECT intLotId
			,intRecordId
			,strType
			,strTransactionName
			,strLotNumber
		FROM @tblTemp
		ORDER BY intRecordId

		OPEN @RCUR

		FETCH NEXT
		FROM @RCUR
		INTO @intId
			,@intParentId
			,@strType
			,@strTransactionName
			,@strLotNumber

		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @intContractId = NULL
			SET @intContainerId = NULL
			SET @intShipmentId = NULL

			-- From Lot to WorkOrders
			IF @strType = 'L'
			BEGIN
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
					--Remove circular Reference, Remove the WO if exists
					--IF EXISTS (
					--		SELECT 1
					--		FROM @tblData
					--		WHERE intLotId IN (
					--				SELECT intLotId
					--				FROM @tblNodeData
					--				WHERE strType = 'W'
					--				)
					--		)
					--	DELETE
					--	FROM @tblData
			END

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

			-- Lot Merge
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
					,0
					,@intLocationId

				IF EXISTS (
						SELECT *
						FROM @tblData
						WHERE strTransactionName = 'Merge'
						)
				BEGIN
					UPDATE @tblNodeData
					SET dblQuantity = IsNULL((
								SELECT SUM(dblQuantity)
								FROM @tblData
								WHERE strTransactionName IN (
										'Merge'
										,'Produce'
										)
									AND ysnProcessed = 0
								), 0)
					WHERE intLotId = @intId
						AND @strTransactionName IN (
							'Ship'
							,'Merge'
							)
				END

				INSERT INTO @tblMFExlude
				SELECT intLotId
					,strLotNumber
				FROM @tblData
				WHERE strText LIKE 'Merge Out%'
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

			--Get Contract/Container if exists for Receipt
			IF @strType = 'R'
			BEGIN
				SELECT TOP 1 @intContractId = ISNULL(ri.intOrderId, 0)
					,@intShipmentId = ISNULL(ri.intSourceId, 0)
					,@intContainerId = ISNULL(ri.intContainerId, 0)
				FROM tblICInventoryReceiptItem ri
				JOIN tblICInventoryReceipt rh ON ri.intInventoryReceiptId = rh.intInventoryReceiptId
				WHERE rh.intInventoryReceiptId = @intId
					AND rh.strReceiptType = 'Purchase Contract'

				--Get Contract
				IF @intContainerId = 0
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
						,strVendor
						,intImageTypeId
						,strType
						)
					EXEC uspMFGetTraceabilityContractDetail @intContractId
						,@intDirectionId
						,NULL
						,@intLocationId
				ELSE
					--Get Container
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
					EXEC uspMFGetTraceabilityContainerDetail @intContainerId
						,@intDirectionId
			END

			--Get In Shipment From Container
			IF @strType = 'CN'
			BEGIN
				SELECT TOP 1 @intShipmentId = intLoadId
				FROM tblLGLoadContainer
				WHERE intLoadContainerId = @intId

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
					,strVendor
					,strType
					)
				EXEC uspMFGetTraceabilityInboundShipmentDetail @intShipmentId
					,@intDirectionId
					,@intLocationId
			END

			--Get Contract From In Shipment
			IF @strType = 'IS'
			BEGIN
				SELECT TOP 1 @intContractId = CD.intContractHeaderId
				FROM tblLGLoadDetail ld
				JOIN tblCTContractDetail CD on CD.intContractDetailId =ld.intPContractDetailId 
				WHERE intLoadId = @intId

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
					,strVendor
					,intImageTypeId
					,strType
					)
				EXEC uspMFGetTraceabilityContractDetail @intContractId
					,@intDirectionId
					,NULL
					,@intLocationId
			END

			UPDATE @tblData
			SET intParentId = @intParentId
				,ysnProcessed = 1
			WHERE intParentId IS NULL

			INSERT INTO @tblMFExlude
			SELECT @intId
				,@strLotNumber

			FETCH NEXT
			FROM @RCUR
			INTO @intId
				,@intParentId
				,@strType
				,@strTransactionName
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
			,strText
			,dblWOQty
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
			,strText
			,dblWOQty
		FROM @tblData
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
			,strText
			,dblWOQty

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
			,strText
			,dblWOQty
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
			,strText
			,dblWOQty
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
END

INSERT INTO @tblNodeDataFinal (
	[key]
	,intRecordId
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
	,strImage
	,strNodeText
	,strToolTip
	,intControlPointId
	)
SELECT intRecordId AS [key]
	,intRecordId
	,intParentId
	,CASE 
		WHEN IsNULL(strText, '') = ''
			THEN strTransactionName
		ELSE strText
		END
	,intLotId
	,strLotNumber
	,strLotAlias
	,intItemId
	,strItemNo
	,strItemDesc
	,intCategoryId
	,strCategoryCode
	,IsNULL(dblWOQty, dblQuantity)
	,strUOM
	,dtmTransactionDate
	,intParentLotId
	,strVendor
	,strCustomer
	,strProcessName
	,strType
	,intAttributeTypeId
	,intImageTypeId
	,CASE 
		WHEN strType IN (
				'L'
				,'IT'
				)
			THEN CASE 
					WHEN intImageTypeId = 2
						THEN './resources/images/graphics/traceability-raw-material.png'
					WHEN intImageTypeId = 4
						THEN './resources/images/graphics/traceability-wip-material.png'
					WHEN intImageTypeId = 6
						THEN './resources/images/graphics/traceability-finished-goods.png'
					ELSE './resources/images/graphics/traceability-wip-material.png'
					END
		WHEN strType = 'W'
			THEN CASE 
					WHEN intAttributeTypeId = 3
						THEN './resources/images/graphics/traceability-packaging.png'
					ELSE './resources/images/graphics/traceability-wip-process.png'
					END
		WHEN strType = 'R'
			THEN './resources/images/graphics/traceability-receipt.png'
		WHEN strType = 'S'
			OR strType = 'OS'
			THEN './resources/images/graphics/traceability-shipment.png'
		WHEN strType = 'C'
			THEN './resources/images/graphics/contract.png'
		WHEN strType = 'IS'
			THEN './resources/images/graphics/traceability-shipment.png'
		WHEN strType = 'CN'
			THEN './resources/images/graphics/container.png'
		WHEN strType = 'SO'
			THEN './resources/images/graphics/sales-order.png'
		WHEN strType = 'IN'
			THEN './resources/images/graphics/invoice.png'
		END AS strImage
	,CASE 
		WHEN ISNULL(strProcessName, '') = ''
			THEN strLotNumber
		ELSE strLotNumber + CHAR(13) + '(' + strProcessName + ')'
		END AS strNodeText
	,'Item No.	  : ' + ISNULL(strItemNo, '') + CHAR(13) + 'Item Desc.   : ' + rtrim(Ltrim(ISNULL(strItemDesc, ''))) + CHAR(13) + 'Quantity     : ' + ISNULL(dbo.fnRemoveTrailingZeroes(IsNULL(dblWOQty, dblQuantity)), '') + ' ' + ISNULL(strUOM, '') + CHAR(13) + 'Tran. Date   : ' + ISNULL(CONVERT(VARCHAR, dtmTransactionDate), '') + CHAR(13) + CASE 
		WHEN strType = 'R'
			THEN 'Vendor     : ' + ISNULL(strVendor, '')
		ELSE ''
		END + CASE 
		WHEN strType = 'S'
			THEN 'Customer     : ' + ISNULL(strCustomer, '')
		ELSE ''
		END AS strToolTip
	,CASE 
		WHEN strType = 'L'
			THEN CASE 
					WHEN intImageTypeId = 2
						THEN 5
					ELSE 6
					END
		ELSE 5
		END AS intControlPointId
FROM @tblNodeData

--Generate Group Row No
UPDATE f
SET f.ysnExcludedNode = 1
	,f.intGroupRowNo = t.intRowNo
FROM @tblNodeDataFinal f
JOIN (
	SELECT ROW_NUMBER() OVER (
			PARTITION BY (convert(VARCHAR, strType) + convert(VARCHAR, strTransactionName) + convert(VARCHAR, intLotId)) ORDER BY [key]
			) intRowNo
		,[key]
	FROM @tblNodeDataFinal
	) t ON f.[key] = t.[key]
WHERE intRowNo > 1

--Update Duplicate Rows
UPDATE f
SET f.intRecordId = t.intMinRecordId
FROM @tblNodeDataFinal f
JOIN (
	SELECT MIN(intRecordId) intMinRecordId
		,(convert(VARCHAR, strType) + convert(VARCHAR, strTransactionName) + convert(VARCHAR, intLotId)) AS strKey
	FROM @tblNodeDataFinal
	GROUP BY (convert(VARCHAR, strType) + convert(VARCHAR, strTransactionName) + convert(VARCHAR, intLotId))
	) t ON (convert(VARCHAR, strType) + convert(VARCHAR, f.strTransactionName) + convert(VARCHAR, f.intLotId)) = t.strKey
WHERE f.intGroupRowNo IS NOT NULL

--Update the transaction for SO Link for forward
IF @intDirectionId = 1
	UPDATE @tblNodeDataFinal
	SET strTransactionName = 'Sales Order'
	WHERE strType = 'S'
		AND ysnExcludedNode = 1

--Update the transaction for Shipment Link for reverse
IF @intDirectionId = 2
	AND EXISTS (
		SELECT 1
		FROM @tblNodeDataFinal
		WHERE strType = 'IN'
		)
	UPDATE @tblNodeDataFinal
	SET strTransactionName = 'Invoice'
	WHERE strType = 'S'

SELECT *
FROM @tblNodeDataFinal
