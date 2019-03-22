CREATE VIEW vyuMFGetOwnerDetail
AS
SELECT DISTINCT L.strLotNumber
	,I.strItemNo
	,I.strDescription
	,E.strName strOwner
	,OD.dtmFromDate
	,IsNULL(OD.dtmToDate, GETDATE()) AS dtmToDate
	,DateDiff(d, OD.dtmFromDate, IsNULL(OD.dtmToDate, GETDATE())) + 1 intNoOfDays
FROM dbo.tblMFItemOwnerDetail OD
JOIN dbo.tblICLot L ON L.intLotId = OD.intLotId
JOIN dbo.tblICItem I ON I.intItemId = L.intItemId
JOIN dbo.tblEMEntity E ON E.intEntityId = OD.intOwnerId
