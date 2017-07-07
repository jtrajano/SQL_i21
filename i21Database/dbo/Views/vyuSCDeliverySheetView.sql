CREATE VIEW [dbo].[vyuSCDeliverySheetView]
AS 
SELECT 
	SCD.intDeliverySheetId,
	SCD.intEntityId,
	SCD.intCompanyLocationId,
	SCD.intItemId,
	SCD.intDiscountId,
	SCD.strDeliverySheetNumber,
	SCD.dtmDeliverySheetDate,
	EM.strName,
	SM.strLocationName,
	IC.strItemNo,
	GR.strDiscountId,
	SCD.ysnPost
FROM tblSCDeliverySheet SCD 
LEFT JOIN tblEMEntity EM ON SCD.intEntityId = EM.intEntityId
LEFT JOIN tblSMCompanyLocation SM ON SCD.intCompanyLocationId = SM.intCompanyLocationId
LEFT JOIN tblICItem IC ON SCD.intItemId = IC.intItemId
LEFT JOIN tblGRDiscountId GR ON SCD.intDiscountId = GR.intDiscountId
