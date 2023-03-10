CREATE VIEW [dbo].[vyuTRImportRackPriceDetail]
    AS
SELECT        
	IRD.intImportRackPriceDetailId
	, IR.intImportRackPriceId
	, CAST(IR.dtmImportDate AS DATETIME2) dtmImportDate
	, IR.strFilename
	, IRD.strComments
	, CASE WHEN IRDI.intImportRackPriceDetailItemId IS NOT NULL THEN IRDI.ysnValid ELSE IRD.ysnValid  END ysnValid
	, IRD.strSupplierName
	, IRD.strSupplyPoint
	, IR.strSource
	, IRD.intConcurrencyId
	, IRD.dtmEffectiveDate
	, IRD.ysnDelete
	, CASE WHEN IRDI.intImportRackPriceDetailItemId IS NOT NULL THEN IRDI.strMessage ELSE IRD.strMessage END strMessage
	, IRDI.dblVendorPrice
	, IRDI.strItemNo
FROM            
	dbo.tblTRImportRackPriceDetail AS IRD 
	INNER JOIN dbo.tblTRImportRackPrice AS IR ON IRD.intImportRackPriceId = IR.intImportRackPriceId
	LEFT JOIN dbo.tblTRImportRackPriceDetailItem AS IRDI ON IRDI.intImportRackPriceDetailId = IRD.intImportRackPriceDetailId