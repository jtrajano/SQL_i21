CREATE VIEW [dbo].[vyuGRBillStorageSearchView]
AS
SELECT
	CS.intCustomerStorageId
	,CS.strStorageTicketNumber	
	,CS.dtmDeliveryDate
	,CS.intEntityId
	,EM.strName
	,CS.intCompanyLocationId
	,CL.strLocationName
	,CS.intStorageTypeId
	,ST.strStorageTypeDescription
	,CS.intStorageScheduleId
	,SR.strScheduleId
	,CS.intCommodityId
	,CO.strCommodityCode
	,Item.intItemId
	,Item.strItemNo	
	,dblUnits = CAST(dbo.fnCalculateQtyBetweenUOM(CS.intItemUOMId, IU.intItemUOMId,SH.dblUnits) AS DECIMAL(18,6))
	,SH.dblPaidAmount
	,CASE 
							WHEN SH.strType = 'Invoice' OR SH.strType = 'Generated Storage Invoice' THEN 'Bill Storage'
							ELSE 'Accrue'
						END	 COLLATE Latin1_General_CI_AS AS strPaidDescription
	,dtmCalculatedStorageThru = CASE 
									WHEN SH.strType = 'Invoice' OR SH.strType = 'Generated Storage Invoice' THEN SH.dtmDistributionDate
									ELSE SH.dtmHistoryDate
								END
	,SH.intInvoiceId
	,IV.strInvoiceNumber
	,SH.intUserId
	,US.strUserName
	,ysnShowInStorage = CAST(
							CASE
								WHEN ST.ysnCustomerStorage = 0 THEN 1
								WHEN ST.ysnCustomerStorage = 1 AND ST.strOwnedPhysicalStock = 'Customer' THEN 1
								ELSE 0
							END AS BIT
						)
FROM tblGRStorageHistory SH
INNER JOIN tblGRCustomerStorage CS
	ON CS.intCustomerStorageId = SH.intCustomerStorageId
INNER JOIN tblEMEntity EM
	ON EM.intEntityId = CS.intEntityId
INNER JOIN tblSMCompanyLocation CL
	ON CL.intCompanyLocationId = CS.intCompanyLocationId
INNER JOIN tblICItem Item
	ON Item.intItemId = CS.intItemId
INNER JOIN tblICItemUOM IU
	ON IU.intItemId = Item.intItemId
		AND IU.ysnStockUnit = 1
INNER JOIN tblICUnitMeasure UM
	ON UM.intUnitMeasureId = IU.intUnitMeasureId
INNER JOIN tblICCommodity CO
	ON CO.intCommodityId = CS.intCommodityId
INNER JOIN tblGRStorageType ST
	ON ST.intStorageScheduleTypeId = CS.intStorageTypeId
INNER JOIN tblGRStorageScheduleRule SR
	ON SR.intStorageScheduleRuleId = CS.intStorageScheduleId
INNER JOIN tblSMUserSecurity US
	ON US.intEntityId = SH.intUserId
LEFT JOIN tblARInvoice IV
	ON IV.intInvoiceId = SH.intInvoiceId
WHERE (SH.strType = 'Accrue Storage' AND SH.intInvoiceId IS NULL) --Accrued Storage
	OR ((SH.strType = 'Invoice' OR SH.strType = 'Generated Storage Invoice') AND SH.intInvoiceId IS NOT NULL)--Generated Invoice