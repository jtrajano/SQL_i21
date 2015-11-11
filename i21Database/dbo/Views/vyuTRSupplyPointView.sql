CREATE VIEW [dbo].[vyuTRSupplyPointView]
	AS 
SELECT 
   
   SP.intSupplyPointId,
   (select top 1 EM.strName from dbo.vyuEMEntity EM where EM.intEntityId = SP.intEntityVendorId) as strFuelSupplier,
   (select top 1 EL.strLocationName from dbo.tblEntityLocation EL where EL.intEntityLocationId = SP.intEntityLocationId) as strSupplyPoint,
   (select top 1 TF.strTerminalControlNumber from dbo.tblTFTerminalControlNumber TF where TF.intTerminalControlNumberId = SP.intTerminalControlNumberId ) as strTerminalNumber,
   SP.strGrossOrNet,
   SP.intRackPriceSupplyPointId,
   SP.intEntityLocationId,
   SP.intEntityVendorId,
   (select top 1 EZ.strZipCode from dbo.tblEntityLocation EZ where EZ.intEntityLocationId = SP.intEntityLocationId) as strZipCode,
   SP.intTaxGroupId,
   TX.strTaxGroup
    	
FROM
    dbo.tblTRSupplyPoint SP	
	LEFT JOIN tblSMTaxGroup TX on SP.intTaxGroupId = TX.intTaxGroupId
	