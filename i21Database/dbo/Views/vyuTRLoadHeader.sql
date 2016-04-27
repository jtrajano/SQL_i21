CREATE VIEW [dbo].[vyuTRLoadHeader]
	AS 

SELECT TL.intLoadHeaderId
	, TL.strTransaction
	, strReceiptLink = TR.strReceiptLine
	, strRecordType = (CASE WHEN TR.intLoadReceiptId IS NULL THEN 'Header'
							ELSE 'Receipt' END)
	, NULL AS strCustomer
	, NULL AS strCustomerLocation
	, NULL AS strCustomerCompanyLocation
	, SP.strFuelSupplier
	, SP.strSupplyPoint
	, TR.strBillOfLading AS strBOL
	, (select top 1 SM.strLocationName from dbo.tblSMCompanyLocation SM where SM.intCompanyLocationId = TR.intCompanyLocationId) AS strReceiptCompanyLocation
	, (select top 1 IC.strItemNo from dbo.vyuICGetItemStock IC where IC.intItemId = TR.intItemId) AS strItem
	, dblQuantity = CASE WHEN SP.strGrossOrNet = 'Gross' THEN TR.dblGross
						WHEN SP.strGrossOrNet = 'Net' THEN TR.dblNet END
	, NULL AS dblPrice
	, TR.dblUnitCost AS dblCost
	, NULL AS dblMargin
	, dblTotalFreight = (dblFreightRate * dblPurSurcharge * dblNet)
	, (select  top 1 AR.strName from dbo.vyuEMEntity AR where AR.intEntityId = TL.intDriverId) AS strDriver
	, TL.dtmLoadDateTime AS dtmDateTime
	, TL.ysnPosted
	, (select top 1 IR.strReceiptNumber from dbo.tblICInventoryReceipt IR where IR.intInventoryReceiptId = TR.intInventoryReceiptId) AS strInventoryReceiptNo
	, (select top 1 IT.strTransferNo from dbo.tblICInventoryTransfer IT where IT.intInventoryTransferId = TR.intInventoryTransferId) AS strInventoryTransferNo
	, NULL AS strInvoiceNo
FROM dbo.tblTRLoadHeader TL
LEFT JOIN dbo.tblTRLoadReceipt TR ON TL.intLoadHeaderId = TR.intLoadHeaderId
LEFT JOIN dbo.vyuTRSupplyPointView SP ON SP.intSupplyPointId = TR.intSupplyPointId

UNION ALL
SELECT TL.intLoadHeaderId
	, TL.strTransaction
	, DD.strReceiptLink
	, 'Distribution' AS strRecordType
	, (select  top 1 CS.strName from dbo.vyuEMEntity CS where CS.intEntityId = DH.intEntityCustomerId) AS strCustomer
	, (select  top 1 EL.strLocationName from dbo.tblEntityLocation EL where EL.intEntityLocationId = DH.intShipToLocationId) AS strCustomerLocation
	, (select top 1 SM.strLocationName from dbo.tblSMCompanyLocation SM where SM.intCompanyLocationId = DH.intCompanyLocationId) AS strCustomerCompanyLocation
	, ee.strFuelSupplier
	, ee.strSupplyPoint
	, ee.strBillOfLading AS strBOL
	, ee.strReceiptCompanyLocation
	, (select top 1 IC.strItemNo from dbo.vyuICGetItemStock IC where IC.intItemId = DD.intItemId) AS strItem
	, DD.dblUnits AS dblQuantity
	, DD.dblPrice AS dblPrice
	, ee.dblUnitCost AS dblCost
	, DD.dblPrice - ee.dblUnitCost AS dblMargin
	, dblTotalFreight = (dblFreightRate * dblDistSurcharge * dblUnits)
	, (select  top 1 AR.strName from dbo.vyuEMEntity AR where AR.intEntityId = TL.intDriverId) AS strDriver
	, DH.dtmInvoiceDateTime AS dtmDateTime
	, TL.ysnPosted
	, ee.strReceiptNumber AS strInventoryReceiptNo
	, ee.strTransferNo AS strInventoryTransferNo
	, (select strInvoiceNumber from tblARInvoice ARI where ARI.intInvoiceId = DH.intInvoiceId) AS strInvoiceNo
FROM dbo.tblTRLoadHeader TL
JOIN dbo.tblTRLoadDistributionHeader DH ON DH.intLoadHeaderId = TL.intLoadHeaderId
LEFT JOIN dbo.tblTRLoadDistributionDetail DD ON DD.intLoadDistributionHeaderId = DH.intLoadDistributionHeaderId
LEFT JOIN(
	SELECT DISTINCT intLoadDistributionDetailId
		, STUFF(
				(SELECT	DISTINCT ', ' + CD.strFuelSupplier
				FROM vyuTRLinkedReceipts CD
				WHERE CD.intLoadHeaderId = CH.intLoadHeaderId
					AND CD.intLoadDistributionDetailId = CH.intLoadDistributionDetailId
				FOR XML PATH('')), 1, 2, ''
				) strFuelSupplier
		, STUFF(
				(SELECT	DISTINCT ', ' + CD.strSupplyPoint
				FROM vyuTRLinkedReceipts CD
				WHERE CD.intLoadHeaderId = CH.intLoadHeaderId
				AND CD.intLoadDistributionDetailId = CH.intLoadDistributionDetailId
				FOR XML PATH('')), 1, 2, ''
				) strSupplyPoint
		, STUFF(
				(SELECT	DISTINCT ', ' + CD.strBillOfLading
				FROM vyuTRLinkedReceipts CD
				WHERE CD.intLoadHeaderId = CH.intLoadHeaderId
				AND CD.intLoadDistributionDetailId = CH.intLoadDistributionDetailId
				FOR XML PATH('')), 1, 2, ''
				) strBillOfLading
		, STUFF(
				(SELECT	DISTINCT ', ' + CD.strReceiptCompanyLocation
				FROM vyuTRLinkedReceipts CD
				WHERE CD.intLoadHeaderId = CH.intLoadHeaderId
				AND CD.intLoadDistributionDetailId = CH.intLoadDistributionDetailId
				FOR XML PATH('')), 1, 2, ''
				) strReceiptCompanyLocation
		, STUFF(
				(SELECT	DISTINCT ', ' + CD.strReceiptNumber
				FROM vyuTRLinkedReceipts CD
				WHERE CD.intLoadHeaderId = CH.intLoadHeaderId
				AND CD.intLoadDistributionDetailId = CH.intLoadDistributionDetailId
				FOR XML PATH('')), 1, 2, ''
				) strReceiptNumber
		, STUFF(
				(SELECT	DISTINCT ', ' + CD.strTransferNo
				FROM vyuTRLinkedReceipts CD
				WHERE CD.intLoadHeaderId = CH.intLoadHeaderId
				AND CD.intLoadDistributionDetailId = CH.intLoadDistributionDetailId
				FOR XML PATH('')), 1, 2, ''
				) strTransferNo
		, (SELECT AVG(CD.dblUnitCost)
			FROM vyuTRLinkedReceipts CD
			WHERE CD.intLoadHeaderId = CH.intLoadHeaderId AND CD.intLoadDistributionDetailId = CH.intLoadDistributionDetailId) dblUnitCost
	FROM vyuTRLinkedReceipts CH)ee ON ee.intLoadDistributionDetailId = DD.intLoadDistributionDetailId
