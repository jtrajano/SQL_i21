CREATE VIEW [dbo].[vyuLGCustomerConsumptionSite]
AS  
	SELECT 
		TMS.intSiteID
		,strSiteID = RIGHT('000'+ CAST(TMS.intSiteNumber AS NVARCHAR(4)),4)  COLLATE Latin1_General_CI_AS
		,TMS.strDescription
		,intDeviceId = SD.intDeviceId
		,strSerialNumber = SD.strSerialNumber
		,intCustomerID = E.intEntityId
		,E.strName
		,E.strEntityNo
		,ELCS.intEntityLocationId
		,EL.strLocationName
		,TMC.intCurrentSiteNumber
		,intItemId = TMS.intProduct
		,strItemNo = I.strItemNo
		,strItemDescription = I.strDescription
		,intItemUOMId = UOM.intItemUOMId
		,strUnitMeasure = UOM.strUnitMeasure
		,intCompanyLocationId = TMS.intLocationId
		,strCompanyLocation = CL.strLocationName
		,intSubLocationId = IL.intSubLocationId
		,strSubLocation = CLSL.strSubLocationName
		,intStorageLocationId = IL.intStorageLocationId
		,strStorageLocation = SL.strName
		,ysnLocationActive = EL.ysnActive
		,ysnSiteActive = TMS.ysnActive 
		,TMS.intConcurrencyId
	FROM 
		tblEMEntityLocationConsumptionSite ELCS
		INNER JOIN tblEMEntityLocation EL ON EL.intEntityLocationId = ELCS.intEntityLocationId
		INNER JOIN tblEMEntity E ON E.intEntityId = EL.intEntityId 
		INNER JOIN tblTMSite TMS ON TMS.intSiteID = ELCS.intSiteID
		LEFT JOIN tblTMCustomer TMC ON TMC.intCustomerNumber = E.intEntityId 
		LEFT JOIN tblICItem I ON I.intItemId = TMS.intProduct
		LEFT JOIN tblICItemLocation IL ON IL.intItemId = I.intItemId AND IL.intLocationId IS NOT NULL AND IL.intLocationId = TMS.intLocationId
		LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = IL.intLocationId
		LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = IL.intSubLocationId
		LEFT JOIN tblICStorageLocation SL ON SL.intStorageLocationId = IL.intStorageLocationId
		OUTER APPLY (SELECT TOP 1 sd.intDeviceId, d.strSerialNumber FROM tblTMSiteDevice sd 
			INNER JOIN tblTMDevice d ON d.intDeviceId = sd.intDeviceId WHERE sd.intSiteID = TMS.intSiteID) SD
		OUTER APPLY (SELECT TOP 1 uom.intItemUOMId, um.intUnitMeasureId, um.strUnitMeasure FROM tblICItemUOM uom
			LEFT JOIN tblICUnitMeasure um on um.intUnitMeasureId = uom.intUnitMeasureId
			WHERE intItemId = I.intItemId AND ysnStockUnit = 1) UOM
GO

