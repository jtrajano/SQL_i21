CREATE VIEW [dbo].[vyuSMCompanyLocationSubLocation]
AS 
SELECT intCompanyLocationSubLocationId
,SubLocation.intCompanyLocationId AS intCompanyLocationId
,strSubLocationName
,strSubLocationDescription
,intVendorId
,Entity.strName AS strVendor
,strClassification
,ysnExternal
,intNewLotBin
,intAuditBin
,SubLocation.strAddress AS strAddress
,ZipCode.strCity AS strCity
,ZipCode.strState AS strState
,ZipCode.strZipCode AS strZipCode
,ZipCode.strCountry AS strCountry
,Country.intCountryID AS intCountryId
,SubLocation.dblLatitude
,SubLocation.dblLongitude
,StorageLocationNew.strName AS strNewLotBin
,StorageLocationAudit.strName AS strAuditBin
,CompanyLocation.strLocationName AS strLocationName
,SubLocation.intConcurrencyId
FROM [tblSMCompanyLocationSubLocation] SubLocation
LEFT JOIN tblEMEntity Entity ON SubLocation.intVendorId = Entity.intEntityId
LEFT JOIN tblICStorageLocation StorageLocationNew ON SubLocation.intNewLotBin = StorageLocationNew.intStorageLocationId
LEFT JOIN tblICStorageLocation StorageLocationAudit ON SubLocation.intNewLotBin = StorageLocationAudit.intStorageLocationId
INNER JOIN tblSMCompanyLocation CompanyLocation ON SubLocation.intCompanyLocationId = CompanyLocation.intCompanyLocationId
LEFT JOIN tblSMZipCode ZipCode ON NULLIF(SubLocation.strZipCode, '') = ZipCode.strZipCode
LEFT JOIN tblSMCountry Country ON ZipCode.strCountry = Country.strCountry