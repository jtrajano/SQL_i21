CREATE VIEW [dbo].[vyuTRLoadHeader]
	AS 
SELECT    
	TL.intLoadHeaderId,	
	TL.strTransaction,
	TR.strReceiptLine "strReceiptLink",
	'Receipt' as strRecordType,
	NULL as strCustomer,
	NULL as strCustomerLocation,
	NULL as strCustomerCompanyLocation,
	SP.strFuelSupplier,
	SP.strSupplyPoint,
	TR.strBillOfLading as strBOL,
	(select top 1 SM.strLocationName from dbo.tblSMCompanyLocation SM where SM.intCompanyLocationId = TR.intCompanyLocationId) as strReceiptCompanyLocation,
	(select top 1 IC.strItemNo from dbo.vyuICGetItemStock IC where IC.intItemId = TR.intItemId) as strItem,
	dblQuantity     = CASE
						  WHEN SP.strGrossOrNet = 'Gross'
						  THEN TR.dblGross
						  WHEN SP.strGrossOrNet = 'Net'
						  THEN TR.dblNet
						  END,
	NULL as dblPrice,
	TR.dblUnitCost as dblCost,
	NULL as dblMargin,	
	(select  top 1 AR.strName from dbo.vyuEMEntity AR where AR.intEntityId = TL.intDriverId) as strDriver,
	TL.dtmLoadDateTime as dtmDateTime,
	TL.ysnPosted,
	(select top 1 IR.strReceiptNumber from dbo.tblICInventoryReceipt IR where IR.intInventoryReceiptId = TR.intInventoryReceiptId) as strInventoryReceiptNo,
	(select top 1 IT.strTransferNo from dbo.tblICInventoryTransfer IT where IT.intInventoryTransferId = TR.intInventoryTransferId) as strInventoryTransferNo,
	NULL as strInvoiceNo

FROM
	 dbo.tblTRLoadHeader TL
	JOIN dbo.tblTRLoadReceipt TR
		ON TL.intLoadHeaderId = TR.intLoadHeaderId 
    LEFT JOIN dbo.vyuTRSupplyPointView SP
	     ON SP.intSupplyPointId = TR.intSupplyPointId
UNION ALL
SELECT    
	TL.intLoadHeaderId,	
	TL.strTransaction,
	DD.strReceiptLink,
	'Distribution' as strRecordType,
	(select  top 1 CS.strName from dbo.vyuEMEntity CS where CS.intEntityId = DH.intEntityCustomerId) as strCustomer,
	(select  top 1 EL.strLocationName from dbo.tblEntityLocation EL where EL.intEntityLocationId = DH.intShipToLocationId) as strCustomerLocation,
	(select top 1 SM.strLocationName from dbo.tblSMCompanyLocation SM where SM.intCompanyLocationId = DH.intCompanyLocationId) as strCustomerCompanyLocation,
	(select dbo.fnTRConcatString(DD.strReceiptLink,DH.intLoadHeaderId,',','strFuelSupplier')) as strFuelSupplier,
	(select dbo.fnTRConcatString(DD.strReceiptLink,DH.intLoadHeaderId,',','strSupplyPoint')) as strSupplyPoint,
	(select dbo.fnTRConcatString(DD.strReceiptLink,DH.intLoadHeaderId,',','strBillOfLading')) as strBOL,
	(select dbo.fnTRConcatString(DD.strReceiptLink,DH.intLoadHeaderId,',','strReceiptCompanyLocation'))  as strReceiptCompanyLocation,
	(select top 1 IC.strItemNo from dbo.vyuICGetItemStock IC where IC.intItemId = DD.intItemId) as strItem,
	DD.dblUnits as dblQuantity,
	DD.dblPrice as dblPrice,
	(select AVG(dblUnitCost) from dbo.fnTRLinkedReceipt(DD.strReceiptLink,DH.intLoadHeaderId)) as dblCost,
	(select AVG(dblUnitCost) from dbo.fnTRLinkedReceipt(DD.strReceiptLink,DH.intLoadHeaderId)) - DD.dblPrice as dblMargin,
	(select  top 1 AR.strName from dbo.vyuEMEntity AR where AR.intEntityId = TL.intDriverId) as strDriver,
	DH.dtmInvoiceDateTime as dtmDateTime,
	TL.ysnPosted,
	(select dbo.fnTRConcatString(DD.strReceiptLink,DH.intLoadHeaderId,',','strReceiptNumber')) as strInventoryReceiptNo,
	(select dbo.fnTRConcatString(DD.strReceiptLink,DH.intLoadHeaderId,',','strTransferNo')) as strInventoryTransferNo,
	(select strInvoiceNumber from tblARInvoice ARI where ARI.intInvoiceId = DH.intInvoiceId) as strInvoiceNo
FROM
	 dbo.tblTRLoadHeader TL
    JOIN dbo.tblTRLoadDistributionHeader DH
	    ON DH.intLoadHeaderId = TL.intLoadHeaderId
	LEFT JOIN dbo.tblTRLoadDistributionDetail DD
	    ON DD.intLoadDistributionHeaderId = DH.intLoadDistributionHeaderId

