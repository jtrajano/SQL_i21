CREATE VIEW [dbo].[vyuGRTransferSettlements]
AS
SELECT TSH.intTransferSettlementHeaderId
	,TSH.strTransferSettlementNumber
	,TSR.intTransferSettlementReferenceId
	,TSH.intEntityId
	,EM_HEADER.strEntityNo
	,EM_HEADER.strName
	,TSH.intCompanyLocationId
	,CL.strLocationName
	,TSH.intItemId
	,IC.strItemNo
	,TSH.dtmDateTransferred
	,TSH.intUserId
	,US.strUserName
	,TSH.ysnPosted
	,TSH.intConcurrencyId
	--FROM
	,TS_FROM.intTransferFromSettlementId
	,intSourceBillId		= TSR.intBillFromId
	,strSourceBillId 		= AP_FROM.strBillId
	,TSR.intBillDetailFromId
	,intBillId 				= TSR.intBillToId
	,strBillIdFrom 			= AP_FROM_TR.strBillId	
	,TS_FROM.dblSettlementAmountTransferred
	,TS_FROM.dblUnits	
	,AP_FROM.strVendorOrderNumber
	,AP_FROM.dtmDate
	,ysnDMPaid				= AP_FROM.ysnPaid
	--TO
	,intTransferToSettlementId = TS_TO.intTransferToSettlementId
	,intEntityTransferId 	= TS_TO.intEntityId
	,strEntityTransferNo 	= EM_TO.strEntityNo
	,strEntityName 			= EM_TO.strName
	,TSR.dblTransferPercent
	,TSR.dblSettlementAmount
	,dblToUnits 			= TSR.dblUnits
	,intTransferToBillId 	= TSR.intTransferToBillId
	,strTransferToBillId 	= AP_TO.strBillId
	,ysnBLPaid				= AP_TO.ysnPaid
FROM tblGRTransferSettlementsHeader TSH
INNER JOIN tblEMEntity EM_HEADER
	ON EM_HEADER.intEntityId = TSH.intEntityId
INNER JOIN tblSMCompanyLocation CL
	ON CL.intCompanyLocationId = TSH.intCompanyLocationId
INNER JOIN tblICItem IC
	ON IC.intItemId = TSH.intItemId
INNER JOIN tblSMUserSecurity US
	ON US.intEntityId = TSH.intUserId
INNER JOIN tblGRTransferFromSettlements TS_FROM
	ON TS_FROM.intTransferSettlementHeaderId = TSH.intTransferSettlementHeaderId
INNER JOIN tblGRTransferToSettlements TS_TO
	ON TS_TO.intTransferSettlementHeaderId = TSH.intTransferSettlementHeaderId
INNER JOIN tblGRTransferSettlementReference TSR
	ON TSR.intTransferToSettlementId = TS_TO.intTransferToSettlementId
INNER JOIN tblAPBill AP_FROM
	ON AP_FROM.intBillId = TS_FROM.intBillId
INNER JOIN tblAPBill AP_FROM_TR
	ON AP_FROM_TR.intBillId = TSR.intBillToId
INNER JOIN tblEMEntity EM_TO
	ON EM_TO.intEntityId = TS_TO.intEntityId
INNER JOIN tblAPBill AP_TO
	ON AP_TO.intBillId = TSR.intTransferToBillId
GO