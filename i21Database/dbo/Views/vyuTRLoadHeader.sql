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
	(select top 1 SM.strLocationName from tblSMCompanyLocation SM where SM.intCompanyLocationId = TR.intCompanyLocationId) as strReceiptCompanyLocation,
	(select top 1 IC.strItemNo from vyuICGetItemStock IC where IC.intItemId = TR.intItemId) as strItem,
	dblQuantity     = CASE
						  WHEN SP.strGrossOrNet = 'Gross'
						  THEN TR.dblGross
						  WHEN SP.strGrossOrNet = 'Net'
						  THEN TR.dblNet
						  END,
	NULL as dblPrice,
	TR.dblUnitCost as dblCost,
	NULL as dblMargin,	
	(select  top 1 AR.strName from vyuEMEntity AR where AR.intEntityId = TL.intDriverId) as strDriver,
	TL.dtmLoadDateTime as dtmDateTime,
	TL.ysnPosted,
	(select top 1 IR.strReceiptNumber from tblICInventoryReceipt IR where IR.intInventoryReceiptId = TR.intInventoryReceiptId) as strInventoryReceiptNo,
	(select top 1 IT.strTransferNo from tblICInventoryTransfer IT where IT.intInventoryTransferId = TR.intInventoryTransferId) as strInventoryTransferNo,
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
	(select  top 1 CS.strName from vyuEMEntity CS where CS.intEntityId = DH.intEntityCustomerId) as strCustomer,
	(select  top 1 EL.strLocationName from tblEntityLocation EL where EL.intEntityLocationId = DH.intShipToLocationId) as strCustomerLocation,
	(select top 1 SM.strLocationName from tblSMCompanyLocation SM where SM.intCompanyLocationId = DH.intCompanyLocationId) as strCustomerCompanyLocation,
	NULL as strFuelSupplier,
	NULL as strSupplyPoint,
	NULL as strBOL,
	NULL as strReceiptCompanyLocation,
	(select top 1 IC.strItemNo from vyuICGetItemStock IC where IC.intItemId = DD.intItemId) as strItem,
	DD.dblUnits as dblQuantity,
	DD.dblPrice as dblPrice,
	NULL as dblCost,
	NULL as dblMargin,
	(select  top 1 AR.strName from vyuEMEntity AR where AR.intEntityId = TL.intDriverId) as strDriver,
	DH.dtmInvoiceDateTime as dtmDateTime,
	TL.ysnPosted,
	NULL as strInventoryReceiptNo,
	NULL as strInventoryTransferNo,
	NULL as strInvoiceNo
FROM
	 dbo.tblTRLoadHeader TL
    JOIN dbo.tblTRLoadDistributionHeader DH
	    ON DH.intLoadHeaderId = TL.intLoadHeaderId
	LEFT JOIN dbo.tblTRLoadDistributionDetail DD
	    ON DD.intLoadDistributionHeaderId = DH.intLoadDistributionHeaderId

