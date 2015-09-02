CREATE VIEW [dbo].[vyuTRRackPriceView]
	AS 
SELECT 
   RH.dtmEffectiveDateTime,  
   RH.intRackPriceHeaderId,
   (select top 1 EM.strName from vyuEMEntity EM where EM.intEntityId = SP.intEntityVendorId) as strFuelSupplier,
   (select strLocationName from tblEntityLocation EL where EL.intEntityLocationId = SP.intEntityLocationId) as strSupplyPoint 
	
FROM
    dbo.tblTRRackPriceHeader RH	
	JOIN dbo.tblTRSupplyPoint SP on SP.intSupplyPointId = RH.intSupplyPointId
	