CREATE VIEW vyuQMLotStorageLocationNoLotNo
AS
/****************************************************************
    Title: vyuQMLotStorageLocationNoLotNo.sql
    Description: Generate view for cboStorageLocation data
    JIRA: QC-1083
    Created By: Thomas Jason Pamilar
    Date: 04/17/2023
*****************************************************************/
SELECT StorageLocation.intStorageLocationId
    , StorageLocation.strName
    , CompanyLocation.intCompanyLocationSubLocationId
    , CompanyLocation.strSubLocationName
FROM tblICStorageLocation AS StorageLocation
JOIN tblICLot AS Lot ON Lot.intStorageLocationId = StorageLocation.intStorageLocationId
JOIN tblSMCompanyLocationSubLocation AS CompanyLocation ON CompanyLocation.intCompanyLocationSubLocationId = Lot.intSubLocationId
GROUP BY StorageLocation.intStorageLocationId
    , StorageLocation.strName
    , CompanyLocation.intCompanyLocationSubLocationId
    , CompanyLocation.strSubLocationName