CREATE VIEW vyuMFGetServiceContract
AS
SELECT intWarehouseRateMatrixHeaderId
	,WRMH.strServiceContractNo
	,E.strName
	,WRMH.dtmContractDate
	,WRMH.dtmValidityFrom
	,WRMH.dtmValidityTo
	,WRMH.ysnActive
	,WRMH.strComments
	,CL.strLocationName
	,CLSL.strSubLocationName
	,Comm.strCommodityCode
	,Curr.strCurrency
FROM dbo.tblLGWarehouseRateMatrixHeader WRMH
JOIN dbo.tblSMCompanyLocation CL ON CL.intCompanyLocationId = WRMH.intCompanyLocationId
JOIN dbo.tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = WRMH.intCompanyLocationSubLocationId
JOIN dbo.tblEMEntity E ON E.intEntityId = WRMH.intVendorEntityId
JOIN dbo.tblICCommodity AS Comm ON Comm.intCommodityId = WRMH.intCommodityId
JOIN dbo.tblSMCurrency AS Curr ON Curr.intCurrencyID = WRMH.intCurrencyId
