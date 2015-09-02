CREATE VIEW [dbo].[vyuTRSupplyPointView]
	AS 
SELECT 
   
   SP.intSupplyPointId,
   (select top 1 EM.strName from vyuEMEntity EM where EM.intEntityId = SP.intEntityVendorId) as strFuelSupplier,
   (select top 1 EL.strLocationName from tblEntityLocation EL where EL.intEntityLocationId = SP.intEntityLocationId) as strSupplyPoint,
   SP.strTerminalNumber,
   SP.strGrossOrNet,
   SP.intRackPriceSupplyPointId,
   SP.intEntityLocationId,
   SP.intEntityVendorId,
   (select top 1 EZ.strZipCode from tblEntityLocation EZ where EZ.intEntityLocationId = SP.intEntityLocationId) as strZipCode
 	
FROM
    dbo.tblTRSupplyPoint SP	

	