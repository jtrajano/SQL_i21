CREATE VIEW [dbo].[vyuSCDeliverySheetView]
AS 
SELECT 
	SCD.intDeliverySheetId,
	SCD.intEntityId,
	SCD.intCompanyLocationId,
	SCD.strDeliverySheetNumber,
	SCD.dtmDeliverySheetDate,
	EM.strName,
	SM.strLocationName
FROM tblSCDeliverySheet SCD 
LEFT JOIN tblSCTicket SC ON SCD.intDeliverySheetId = SC.intDeliverySheetId
LEFT JOIN tblEMEntity EM ON SCD.intEntityId = EM.intEntityId
LEFT JOIN tblSMCompanyLocation SM ON SCD.intCompanyLocationId = SM.intCompanyLocationId
