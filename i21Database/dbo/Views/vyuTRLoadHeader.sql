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
	ee.strFuelSupplier,
	ee.strSupplyPoint,
	ee.strBillOfLading "strBOL",
	ee.strReceiptCompanyLocation,
	(select top 1 IC.strItemNo from dbo.vyuICGetItemStock IC where IC.intItemId = DD.intItemId) as strItem,
	DD.dblUnits as dblQuantity,
	DD.dblPrice as dblPrice,
	ee.dblUnitCost as dblCost,
	DD.dblPrice - ee.dblUnitCost as dblMargin,
	(select  top 1 AR.strName from dbo.vyuEMEntity AR where AR.intEntityId = TL.intDriverId) as strDriver,
	DH.dtmInvoiceDateTime as dtmDateTime,
	TL.ysnPosted,
	ee.strReceiptNumber "strInventoryReceiptNo",
	ee.strTransferNo "strInventoryTransferNo",
	(select strInvoiceNumber from tblARInvoice ARI where ARI.intInvoiceId = DH.intInvoiceId) as strInvoiceNo
FROM
	 dbo.tblTRLoadHeader TL
    JOIN dbo.tblTRLoadDistributionHeader DH
	    ON DH.intLoadHeaderId = TL.intLoadHeaderId
	LEFT JOIN dbo.tblTRLoadDistributionDetail DD
	    ON DD.intLoadDistributionHeaderId = DH.intLoadDistributionHeaderId
	LEFT JOIN(
		SELECT		DISTINCT intLoadDistributionDetailId,STUFF(															
								   (
										SELECT	DISTINCT												
										', ' + CD.strFuelSupplier 										
										FROM vyuTRLinkedReceipts CD																								
									    WHERE CD.intLoadHeaderId=CH.intLoadHeaderId	 and CD.intLoadDistributionDetailId=CH.intLoadDistributionDetailId																			
										FOR XML PATH('')
								   )											
									,1,2, ''													
								)strFuelSupplier,
								STUFF(															
								   (
										SELECT	DISTINCT												
										', ' + CD.strSupplyPoint 										
										FROM vyuTRLinkedReceipts CD																								
									    WHERE CD.intLoadHeaderId=CH.intLoadHeaderId	 and CD.intLoadDistributionDetailId=CH.intLoadDistributionDetailId																			
										FOR XML PATH('')
								   )											
									,1,2, ''													
								)strSupplyPoint,
								STUFF(															
								   (
										SELECT	DISTINCT												
										', ' + CD.strBillOfLading 										
										FROM vyuTRLinkedReceipts CD																								
									    WHERE CD.intLoadHeaderId=CH.intLoadHeaderId	 and CD.intLoadDistributionDetailId=CH.intLoadDistributionDetailId																			
										FOR XML PATH('')
								   )											
									,1,2, ''													
								)strBillOfLading,	
								STUFF(															
								   (
										SELECT	DISTINCT												
										', ' + CD.strReceiptCompanyLocation 										
										FROM vyuTRLinkedReceipts CD																								
									    WHERE CD.intLoadHeaderId=CH.intLoadHeaderId	 and CD.intLoadDistributionDetailId=CH.intLoadDistributionDetailId																			
										FOR XML PATH('')
								   )											
									,1,2, ''													
								)strReceiptCompanyLocation,		
								STUFF(															
								   (
										SELECT	DISTINCT												
										', ' + CD.strReceiptNumber 										
										FROM vyuTRLinkedReceipts CD																								
									    WHERE CD.intLoadHeaderId=CH.intLoadHeaderId	 and CD.intLoadDistributionDetailId=CH.intLoadDistributionDetailId																			
										FOR XML PATH('')
								   )											
									,1,2, ''													
								)strReceiptNumber,
								STUFF(															
								   (
										SELECT	DISTINCT												
										', ' + CD.strTransferNo 										
										FROM vyuTRLinkedReceipts CD																								
									    WHERE CD.intLoadHeaderId=CH.intLoadHeaderId	 and CD.intLoadDistributionDetailId=CH.intLoadDistributionDetailId																			
										FOR XML PATH('')
								   )											
									,1,2, ''													
								)strTransferNo,														
								(
									SELECT	AVG(CD.dblUnitCost)												 										
									FROM vyuTRLinkedReceipts CD																								
								    WHERE CD.intLoadHeaderId=CH.intLoadHeaderId	 and CD.intLoadDistributionDetailId=CH.intLoadDistributionDetailId																													
								)dblUnitCost											
																				
	FROM vyuTRLinkedReceipts CH		
		)ee ON ee.intLoadDistributionDetailId = DD.intLoadDistributionDetailId 

