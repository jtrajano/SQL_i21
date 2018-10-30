CREATE VIEW [dbo].[vyuGRAccruedStorages]
AS
SELECT 
	intAccountId				= SI.intAccountId
	,strAccountId				= GL.strAccountId --ACCT #
	,intEntityId				= CS.intEntityId
	,strName					= EM.strName --NAME
	,intCompanyLocationId		= CS.intCompanyLocationId
	,intStorageScheduleId		= CS.intStorageScheduleId
	,strStorageScheduleId		= SR.strScheduleId --STORE TYPE
	,intDeliverySheetId			= CS.intDeliverySheetId
	,strSheetNumber				= CASE WHEN CS.intDeliverySheetId IS NOT NULL THEN DS.strDeliverySheetNumber ELSE '' END --SHEET
	,dtmTicketDate				= CASE WHEN CS.intDeliverySheetId IS NOT NULL THEN dbo.fnRemoveTimeOnDate(DS.dtmDeliverySheetDate) ELSE dbo.fnRemoveTimeOnDate(SCT.dtmTicketDateTime) END --TICKET DATE
	,dtmDeliveryDate			= dbo.fnRemoveTimeOnDate(CS.dtmDeliveryDate) --DELIVERY DATE (changed from STORE DATE)
	,intCommodityId				= CS.intCommodityId
	,strCommodityCode			= CO.strCommodityCode --COMM
	,intStorageTypeId			= CS.intStorageTypeId
	,strStorageTypeCode			= ST.strStorageTypeCode --DIST
	,dtmLastStorageAccrueDate	= CS.dtmLastStorageAccrueDate --STORE PD THRU DATE
	,strStorageScheduleDesc		= SR.strScheduleDescription --DESCRIPTION
	,dblAccruedUnits			= SH.dblUnits --UNITS
	,dblAccrualRate				= SH.dblPaidAmount --RATE
	,dblStorageCharge			= ROUND((SH.dblUnits * SH.dblPaidAmount), 6) --STR/SVC CHARGE
FROM tblGRStorageHistory SH
INNER JOIN tblGRCustomerStorage CS
	ON CS.intCustomerStorageId = SH.intCustomerStorageId
INNER JOIN tblGRStorageType ST
	ON ST.intStorageScheduleTypeId = CS.intStorageTypeId
INNER JOIN tblGRStorageScheduleRule SR
	ON SR.intStorageScheduleRuleId = CS.intStorageScheduleId
INNER JOIN tblARInvoice SI
	ON SI.intInvoiceId = SH.intInvoiceId
INNER JOIN tblGLAccount GL
	ON GL.intAccountId = SI.intAccountId
INNER JOIN tblEMEntity EM
	ON EM.intEntityId = CS.intEntityId
INNER JOIN tblICCommodity CO
	ON CO.intCommodityId = CS.intCommodityId
LEFT JOIN tblSCTicket SCT
	ON SCT.intTicketId = CS.intTicketId
LEFT JOIN (tblSCDeliverySheet DS 
			INNER JOIN tblSCDeliverySheetSplit DSS	
				ON DSS.intDeliverySheetId = DS.intDeliverySheetId
		) ON DS.intDeliverySheetId = CS.intDeliverySheetId
				AND DSS.intEntityId = EM.intEntityId