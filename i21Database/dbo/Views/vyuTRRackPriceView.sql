CREATE VIEW [dbo].[vyuTRRackPriceView]
	AS 
SELECT 
     vyuTRRackPrice.intRackPriceHeaderId 
     ,tblEntity.strName 
    , tblEntityLocation.strLocationName 
    , tblICItem.strItemNo 
    , tblICItem.strDescription 
    ,vyuTRRackPrice.dtmEffectiveDateTime
    , vyuTRRackPrice.dblVendorRack
	,vyuTRRackPrice.dblJobberRack
from vyuTRRackPrice
    inner join tblICItem on vyuTRRackPrice.intItemId=tblICItem.intItemId
    inner join tblTRSupplyPoint on vyuTRRackPrice.intSupplyPointId = tblTRSupplyPoint.intSupplyPointId
    inner join tblEntity on tblTRSupplyPoint.intEntityVendorId=tblEntity.intEntityId
    inner join tblEntityLocation on tblTRSupplyPoint.intEntityLocationId=tblEntityLocation.intEntityLocationId
	