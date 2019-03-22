CREATE VIEW [dbo].[vyuSCDeliverySheetView]
AS 
SELECT 
	SCD.intDeliverySheetId
	,SCD.intEntityId
	,SCD.intCompanyLocationId
	,SCD.intItemId
	,SCD.intDiscountId
	,SCD.strDeliverySheetNumber
	,SCD.dtmDeliverySheetDate
	,SCD.dblGross
	,SCD.dblShrink
	,SCD.dblNet
	,SCD.intSplitId
	,SCD.strSplitDescription
	,SCD.strCountyProducer
	,SCD.ysnPost
	,SCD.intTicketTypeId
	,CASE WHEN SCD.intTicketTypeId = 1 THEN 'Load In' ELSE 'Load Out' END COLLATE Latin1_General_CI_AS AS strTicketType

	,EM.strName
	,EML.strLocationName
	,SM.strLocationName as strCompanyLocationName
	,SM.strAddress
	
	,IC.strItemNo
	,IC.intCommodityId
	,ICC.strCommodityCode
	,GR.strDiscountId
	
	,(SELECT COUNT(intTicketId) FROM tblSCTicket SCT WHERE SCT.intDeliverySheetId = SCD.intDeliverySheetId AND SCT.strTicketStatus = 'C') as dblTotalTickets

FROM tblSCDeliverySheet SCD 
LEFT JOIN tblEMEntity EM ON SCD.intEntityId = EM.intEntityId
LEFT JOIN tblSMCompanyLocation SM ON SCD.intCompanyLocationId = SM.intCompanyLocationId
LEFT JOIN tblICItem IC ON SCD.intItemId = IC.intItemId
LEFT JOIN tblICCommodity ICC ON ICC.intCommodityId = IC.intCommodityId
LEFT JOIN tblGRDiscountId GR ON SCD.intDiscountId = GR.intDiscountId
LEFT JOIN tblEMEntityLocation EML ON EML.intEntityLocationId = intFarmFieldId