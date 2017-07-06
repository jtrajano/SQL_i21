CREATE VIEW [dbo].[vyuSCDeliverySheetView]
AS 
SELECT 
	SCD.intDeliverySheetId,
	SCD.intEntityId,
	SCD.intCompanyLocationId,
	SCD.strDeliverySheetNumber,
	SCD.dtmDeliverySheetDate,
	EM.strName,
	SM.strLocationName,
	SCD.ysnPost
FROM tblSCDeliverySheet SCD 
LEFT JOIN tblEMEntity EM ON SCD.intEntityId = EM.intEntityId
LEFT JOIN tblSMCompanyLocation SM ON SCD.intCompanyLocationId = SM.intCompanyLocationId
