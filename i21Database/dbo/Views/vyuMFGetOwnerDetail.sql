CREATE VIEW vyuMFGetOwnerDetail
AS
SELECT DISTINCT L.strLotNumber
	,I.strItemNo
	,I.strDescription
	,E.strName strOwner
	,(
		CASE 
			WHEN GETDATE() > OD.dtmFromDate
				THEN OD.dtmFromDate
			ELSE OD.dtmFromDate
			END
		) AS dtmFromDate
	,(
		CASE 
			WHEN IsNULL(OD.dtmToDate, IsNULL(GETDATE(), IT.dtmDate)) > OD.dtmFromDate
				THEN OD.dtmFromDate
			ELSE IsNULL(OD.dtmToDate, IsNULL(GETDATE(), IT.dtmDate))
			END
		) AS dtmToDate
	,DateDiff(d, (
			CASE 
				WHEN OD.dtmFromDate > OD.dtmFromDate
					THEN OD.dtmFromDate
				ELSE OD.dtmFromDate
				END
			), (
			CASE 
				WHEN IsNULL(OD.dtmToDate, IsNULL(GETDATE(), IT.dtmDate)) > OD.dtmFromDate
					THEN OD.dtmFromDate
				ELSE IsNULL(OD.dtmToDate, IsNULL(GETDATE(), IT.dtmDate))
				END
			)) + 1 intNoOfDays
FROM dbo.tblMFItemOwnerDetail OD
JOIN dbo.tblICLot L ON L.intLotId = OD.intLotId
JOIN dbo.tblICItem I ON I.intItemId = L.intItemId
JOIN dbo.tblEMEntity E ON E.intEntityId = OD.intOwnerId
JOIN dbo.tblICLot L1 ON L1.strLotNumber = L.strLotNumber
LEFT JOIN dbo.tblICInventoryTransaction IT ON IT.intLotId = L1.intLotId
	AND IT.intTransactionTypeId = 5
