CREATE VIEW vyuLGWarehouseRateMatrixSearch
AS
SELECT WRMH.*
	,CL.strLocationName
	,CLSL.strSubLocationName
FROM tblLGWarehouseRateMatrixHeader WRMH
JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = WRMH.intCompanyLocationId
JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = WRMH.intCompanyLocationSubLocationId
JOIN tblEMEntity E ON E.intEntityId = WRMH.intVendorEntityId