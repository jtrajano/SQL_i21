CREATE VIEW [dbo].[vyuTFException]
	AS 
SELECT A.intExceptionId
	, A.intTransactionNumberId
	, A.intReportingComponentId
	, A.intTaxAuthorityId
	, C.strFormCode
	, C.strScheduleCode
	, C.strScheduleName
	, A.strExceptionType
	, A.strTransactionType
	, A.dtmDate 
	, CASE WHEN A.intTransactionNumberId IS NULL THEN A.strBillOfLading ELSE Trans.strBillOfLading END strTransactionNumber
    , A.intProductCodeId
    , E.strProductCode
    , E.strDescription strProductCodeDescription
    , A.intItemId
	, F.strItemNo strItemNo
    , A.dblReceived
    , A.dblGross
    , A.dblNet
    , A.dblBillQty
	, A.intVendorId
	, Vendor.strName strVendorName
	, A.intCustomerId
	, Customer.strName strCustomerName
	, A.intTransporterId
	, Transporter.strName strTransporterName
	, A.strReason
	, A.intUserEntityId
	, UserEntity.strName strUserEntityName
	, A.dtmCreatedDate	  
 FROM tblTFException A
INNER JOIN tblTFTaxAuthority B ON B.intTaxAuthorityId = A.intTaxAuthorityId
INNER JOIN tblTFReportingComponent C ON C.intReportingComponentId = A.intReportingComponentId
LEFT JOIN tblTFProductCode E ON E.intProductCodeId = A.intProductCodeId
LEFT JOIN tblICItem F ON F.intItemId = A.intItemId
LEFT JOIN tblAPVendor G ON G.intEntityId = A.intVendorId
	LEFT JOIN tblEMEntity Vendor ON Vendor.intEntityId = G.intEntityId
LEFT JOIN tblARCustomer H ON H.intEntityId = A.intCustomerId
	LEFT JOIN tblEMEntity Customer ON Customer.intEntityId = H.intEntityId
LEFT JOIN tblSMShipVia I ON I.intEntityId = A.intTransporterId
	LEFT JOIN tblEMEntity Transporter ON Transporter.intEntityId = I.intEntityId
LEFT JOIN tblEMEntity UserEntity ON UserEntity.intEntityId = A.intUserEntityId
LEFT JOIN tblTFTransaction Trans ON Trans.intTransactionNumberId = A.intTransactionNumberId
