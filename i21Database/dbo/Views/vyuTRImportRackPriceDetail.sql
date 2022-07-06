CREATE VIEW [dbo].[vyuTRImportRackPriceDetail]
    AS
SELECT        
	IRD.intImportRackPriceDetailId
	, IR.intImportRackPriceId
	, IR.dtmImportDate
	, IR.strFilename
	, IRD.strComments
	, IRD.ysnValid
	, IRD.strSupplierName
	, IRD.strSupplyPoint
	, IR.strSource
	, IRD.intConcurrencyId
	, IRD.dtmEffectiveDate
	, IRD.ysnDelete
	, IRD.strMessage
FROM            
	dbo.tblTRImportRackPriceDetail AS IRD 
	INNER JOIN dbo.tblTRImportRackPrice AS IR ON IRD.intImportRackPriceId = IR.intImportRackPriceId
