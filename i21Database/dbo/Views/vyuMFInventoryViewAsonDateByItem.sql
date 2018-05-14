CREATE VIEW vyuMFInventoryViewAsonDateByItem
AS
SELECT
v.dtmSnapshotDate, 
v.intItemId,
v.strItemNo,
v.strItemDescription AS strDescription,
SUM(v.dblQty) AS dblQty,
MAX(v.strQtyUOM) AS strQtyUOM,
SUM(v.dblWeight) AS dblWeight,
MAX(v.strWeightUOM) AS strWeightUOM,
SUM(v.dblReservedNoOfPacks) AS dblReservedNoOfPacks,
SUM(v.dblReservedQty) AS dblReservedQty,
SUM(v.dblAvailableNoOfPacks) AS dblAvailableNoOfPacks,
SUM(v.dblAvailableQty) AS dblAvailableQty,
v.intLocationId,
v.strCompanyLocationName AS strLocationName
FROM vyuMFInventoryViewAsonDate v
Group By v.dtmSnapshotDate,v.intLocationId,v.strCompanyLocationName,v.intItemId,v.strItemNo,v.strItemDescription