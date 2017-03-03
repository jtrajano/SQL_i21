CREATE PROCEDURE uspMFGetInventoryAdjustment (
	@dtmFromDate DATETIME
	,@dtmToDate DATETIME
	,@strCustomerName NVARCHAR(50)
	)
AS
DECLARE @intOwnerId INT

IF @dtmFromDate IS NULL
	SELECT @dtmFromDate = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 1, 0) --First day of previous month

IF @dtmToDate IS NULL
	SELECT @dtmToDate = DATEADD(MONTH, DATEDIFF(MONTH, - 1, GETDATE()) - 1, - 1) --Last Day of previous month

SELECT @intOwnerId = E.intEntityId
FROM tblEMEntity E
JOIN tblEMEntityType ET ON E.intEntityId = ET.intEntityId
	AND ET.strType = 'Customer'
WHERE strName = @strCustomerName
	AND strEntityNo <> ''

SELECT E.strName AS [Owner]
	,IT.strName AS [Transaction Type]
	,SL.strName AS [Storage Location]
	,L.strLotNumber AS [Pallet No]
	,I.strItemNo AS [Item No]
	,PL.strParentLotNumber AS [Lot No]
	,IA.dblQty AS Quantity
	,IA.dtmBusinessDate AS [Date]
	,US.strUserName AS [User]
	,IA.strReason AS Reason
	,IA.strNote AS Note
FROM tblMFInventoryAdjustment IA
JOIN dbo.tblICInventoryTransactionType IT ON IT.intTransactionTypeId = IA.intTransactionTypeId
JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = IA.intStorageLocationId
JOIN dbo.tblICLot L ON L.intLotId = IA.intSourceLotId
JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
JOIN dbo.tblICItem I ON I.intItemId = IA.intItemId
LEFT JOIN dbo.tblSMUserSecurity US ON US.intEntityUserSecurityId = IA.intUserId
JOIN dbo.tblMFLotInventory LI ON LI.intLotId = IA.intSourceLotId
LEFT JOIN dbo.tblICItemOwner IO1 ON IO1.intItemOwnerId = LI.intItemOwnerId
LEFT JOIN dbo.tblEMEntity E ON E.intEntityId = IO1.intOwnerId
WHERE IT.intTransactionTypeId = 10
	AND IA.dtmBusinessDate BETWEEN @dtmFromDate
		AND @dtmToDate
			--AND IO1.intOwnerId = @intOwnerId
