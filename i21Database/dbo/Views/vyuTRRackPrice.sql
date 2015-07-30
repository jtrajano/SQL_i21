CREATE VIEW [dbo].[vyuTRRackPrice]
	AS 
SELECT 
   RH.dtmEffectiveDateTime,
   RH.intSupplyPointId,
   RD.intItemId,
   RD.dblJobberRack,
   RD.dblVendorRack
	
FROM
    dbo.tblTRRackPriceHeader RH
	JOIN dbo.tblTRRackPriceDetail RD on RH.intRackPriceHeaderId = RD.intRackPriceHeaderId
