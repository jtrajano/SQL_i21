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
	, CASE WHEN A.strTransactionSource = 'Transport Delivery' THEN A.strTransportNumber ELSE A.strBillOfLading END strTransactionNumber
    , A.intProductCodeId
    , E.strProductCode
    , E.strDescription strProductCodeDescription
    , A.intItemId
	, F.strItemNo strItemNo
    , A.dblReceived
    , A.dblGross
    , A.dblNet
    , A.dblBillQty
	, A.strVendorName
	, A.strCustomerName
	, A.strTransporterName
	, A.strReason
	, A.intUserEntityId
	, UserEntity.strName strUserEntityName
	, A.dtmCreatedDate
	, A.strTransactionSource
 FROM tblTFException A
INNER JOIN tblTFTaxAuthority B ON B.intTaxAuthorityId = A.intTaxAuthorityId
INNER JOIN tblTFReportingComponent C ON C.intReportingComponentId = A.intReportingComponentId
LEFT JOIN tblTFProductCode E ON E.intProductCodeId = A.intProductCodeId
LEFT JOIN tblICItem F ON F.intItemId = A.intItemId
LEFT JOIN tblEMEntity UserEntity ON UserEntity.intEntityId = A.intUserEntityId