CREATE VIEW [dbo].[vyuICGetInventoryReceiptSearchWithApproval]
AS
SELECT
	  approvalStatus.strApprovalStatus
	, approvalStatus.strStatus AS strDocumentStatus
	, approvalStatus.dtmDate AS dtmLastApproved
	, approvalStatus.strApprovedBy AS strLastApprovedBy
	, submissionStatus.dtmDate AS dtmLastSubmitted
	, submissionStatus.strSubmittedBy AS strLastSubmittedBy
	, Receipt.intInventoryReceiptId
	, Receipt.strReceiptType
	, Receipt.intSourceType
	, strSourceType = (
		CASE 
			WHEN Receipt.intSourceType = 0 THEN 'None'
			WHEN Receipt.intSourceType = 1 THEN 'Scale'
			WHEN Receipt.intSourceType = 2 THEN 'Inbound Shipment'
			WHEN Receipt.intSourceType = 3 THEN 'Transport'
			WHEN Receipt.intSourceType = 5 THEN 'Delivery Sheet'
			WHEN Receipt.intSourceType = 6 THEN 'Purchase Order'
			WHEN Receipt.intSourceType = 7 THEN 'Store'
			WHEN Receipt.intSourceType = 9 THEN 'Transfer Shipment'
		END) COLLATE Latin1_General_CI_AS
	, Receipt.intEntityVendorId
	, Vendor.strVendorId
	, strVendorName = Vendor.strName
	, Receipt.intTransferorId
	, strTransferor = Transferor.strLocationName
	, Receipt.intLocationId
	, Location.strLocationName
	, Receipt.strReceiptNumber
	, Receipt.dtmReceiptDate
	, Receipt.intCurrencyId
	, Currency.strCurrency
	, Receipt.intSubCurrencyCents 
	, Receipt.intBlanketRelease
	, Receipt.strVendorRefNo
	, Receipt.strBillOfLading
	, Receipt.intShipViaId
	, ShipVia.strShipVia
	, Receipt.intShipFromId
	, strShipFrom = ShipFrom.strLocationName
	, strShipFromEntity = ShipFromEntity.strName
	, Receipt.intReceiverId
	, strReceiver = Receiver.strUserName
	, Receipt.strVessel
	, Receipt.intFreightTermId
	, FreightTerm.strFreightTerm
	, FreightTerm.strFobPoint
	, Receipt.intShiftNumber
	, Receipt.dblInvoiceAmount
	, Receipt.ysnPrepaid
	, Receipt.ysnInvoicePaid
	, Receipt.intCheckNo
	, Receipt.dtmCheckDate
	, Receipt.intTrailerTypeId
	, Receipt.dtmTrailerArrivalDate
	, Receipt.dtmTrailerArrivalTime
	, Receipt.strSealNo
	, Receipt.strSealStatus
	, Receipt.dtmReceiveTime
	, Receipt.dblActualTempReading
	, Receipt.intShipmentId
	, Receipt.intTaxGroupId
	, TaxGroup.strTaxGroup
	, Receipt.ysnPosted
	, Receipt.ysnCostOutdated
	, Receipt.intEntityId
	, strEntityName = Entity.strName
	, Receipt.strActualCostId
	, Receipt.strWarehouseRefNo
	, Book.strBook
	, SubBook.strSubBook
	, Receipt.dblSubTotal
	, Receipt.dblTotalTax
	, Receipt.dblTotalCharges
	, Receipt.dblTotalGross
	, Receipt.dblTotalNet
	, Receipt.dblGrandTotal
	, Receipt.dtmCreated 
	, Receipt.strRemarks
	, fiscal.strPeriod strAccountingPeriod
	--, WeightLoss.dblClaimableWt
FROM tblICInventoryReceipt Receipt
	LEFT JOIN vyuAPVendor Vendor ON Vendor.[intEntityId] = Receipt.intEntityVendorId
	LEFT JOIN vyuAPVendor ShipFromEntity ON ShipFromEntity.[intEntityId] = Receipt.intShipFromEntityId
	LEFT JOIN tblSMCompanyLocation Transferor ON Transferor.intCompanyLocationId = Receipt.intTransferorId
	LEFT JOIN tblSMCompanyLocation Location ON Location.intCompanyLocationId = Receipt.intLocationId
	LEFT JOIN tblSMCurrency Currency ON Currency.intCurrencyID = Receipt.intCurrencyId
	LEFT JOIN tblSMFreightTerms FreightTerm ON FreightTerm.intFreightTermId = Receipt.intFreightTermId
	LEFT JOIN tblSMShipVia ShipVia ON ShipVia.[intEntityId] = Receipt.intShipViaId
	LEFT JOIN tblSMUserSecurity Receiver ON Receiver.[intEntityId] = Receipt.intReceiverId
	LEFT JOIN vyuEMEntity Entity ON Entity.intEntityId = Receipt.intEntityId AND Entity.strType = 'User'
	LEFT JOIN [tblEMEntityLocation] ShipFrom ON ShipFrom.intEntityLocationId = Receipt.intShipFromId
	LEFT JOIN tblSMTaxGroup TaxGroup ON TaxGroup.intTaxGroupId = Receipt.intTaxGroupId
	LEFT JOIN tblCTBook Book ON Book.intBookId = Receipt.intBookId
	LEFT JOIN tblCTSubBook SubBook ON SubBook.intSubBookId = Receipt.intSubBookId
	CROSS APPLY (
		SELECT TOP 1
			  trans.intRecordId
			, trans.strApprovalStatus
			, approval.strStatus
			, approval.dtmDate
			, approval.intApprovalId
			, entity.strName strApprovedBy
		FROM tblSMApproval approval
			INNER JOIN tblSMTransaction trans ON trans.intTransactionId = approval.intTransactionId
			INNER JOIN tblSMScreen screen ON screen.intScreenId = trans.intScreenId
			INNER JOIN tblEMEntity entity ON entity.intEntityId = approval.intApproverId
		WHERE (screen.strNamespace = 'Inventory.view.InventoryReceipt' OR screen.strNamespace = 'Inventory.view.InventoryReceipt.TransferOrders')
			AND trans.intRecordId = Receipt.intInventoryReceiptId
		ORDER BY approval.intApprovalId DESC, approval.dtmDate DESC
	) approvalStatus
	CROSS APPLY (
		SELECT TOP 1
			  trans.intRecordId
			, trans.strApprovalStatus
			, entity.strName strSubmittedBy
			, approval.intSubmittedById
			, approval.strStatus
			, approval.dtmDate
			, approval.intApprovalId
		FROM tblSMApproval approval
			INNER JOIN tblSMTransaction trans ON trans.intTransactionId = approval.intTransactionId
			INNER JOIN tblSMScreen screen ON screen.intScreenId = trans.intScreenId
			INNER JOIN tblEMEntity entity ON entity.intEntityId = approval.intSubmittedById
		WHERE (screen.strNamespace = 'Inventory.view.InventoryReceipt' OR screen.strNamespace = 'Inventory.view.InventoryReceipt.TransferOrders')
			AND trans.intRecordId = Receipt.intInventoryReceiptId
		ORDER BY approval.intApprovalId DESC, approval.dtmDate DESC
	) submissionStatus
	OUTER APPLY (
		SELECT TOP 1 fp.strPeriod
		FROM tblGLFiscalYearPeriod fp
		WHERE Receipt.dtmReceiptDate BETWEEN fp.dtmStartDate AND fp.dtmEndDate
	) fiscal