CREATE VIEW [dbo].[vyuICGetInventoryAdjustmentWithApproval]
	AS 

SELECT 
	  approvalStatus.strApprovalStatus
	, approvalStatus.strStatus AS strDocumentStatus
	, approvalStatus.dtmDate AS dtmLastApproved
	, approvalStatus.strApprovedBy AS strLastApprovedBy
	, submissionStatus.dtmDate AS dtmLastSubmitted
	, submissionStatus.strSubmittedBy AS strLastSubmittedBy
	, Adj.intInventoryAdjustmentId
	, Adj.intLocationId
	, Location.strLocationName
	, Adj.dtmAdjustmentDate
	, Adj.intAdjustmentType
	, strAdjustmentType = (
		CASE WHEN Adj.intAdjustmentType = 1 THEN 'Quantity'
			WHEN Adj.intAdjustmentType = 2 THEN 'UOM'
			WHEN Adj.intAdjustmentType = 3 THEN 'Item'
			WHEN Adj.intAdjustmentType = 4 THEN 'Lot Status' 
			WHEN Adj.intAdjustmentType = 5 THEN 'Split Lot'
			WHEN Adj.intAdjustmentType = 6 THEN 'Expiry Date'
			WHEN Adj.intAdjustmentType = 7 THEN 'Lot Merge'
			WHEN Adj.intAdjustmentType = 8 THEN 'Lot Move'
			WHEN Adj.intAdjustmentType = 9 THEN 'Lot Owner'
			WHEN Adj.intAdjustmentType = 10 THEN 'Opening Inventory'
			WHEN Adj.intAdjustmentType = 11 THEN 'Lot Weight'
		END) COLLATE Latin1_General_CI_AS
	, Adj.strAdjustmentNo
	, Adj.strDescription
	, Adj.intSort
	, Adj.ysnPosted
	, Adj.intEntityId
	, strUser = UserEntity.strName
	, Adj.dtmPostedDate
	, Adj.dtmUnpostedDate
	, Adj.intSourceId
	, Adj.intSourceTransactionTypeId
	, Adj.intConcurrencyId
	, Link.strTransactionFrom
	, Link.strSource
	, Link.strTicketNumber
	, Link.strInvoiceNumber
	, Link.strShipmentNumber
	, Link.strReceiptNumber
	, fiscal.strPeriod strAccountingPeriod
FROM tblICInventoryAdjustment Adj
LEFT JOIN vyuICInventoryAdjustmentSourceLink Link
	on Link.intInventoryAdjustmentId = Adj.intInventoryAdjustmentId
LEFT JOIN tblSMCompanyLocation Location ON Location.intCompanyLocationId = Adj.intLocationId
LEFT JOIN tblEMEntity UserEntity ON UserEntity.intEntityId = Adj.intEntityId
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
	WHERE (screen.strNamespace = 'Inventory.view.InventoryAdjustment')
		AND trans.intRecordId = Adj.intInventoryAdjustmentId
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
	WHERE (screen.strNamespace = 'Inventory.view.InventoryAdjustment')
		AND trans.intRecordId = Adj.intInventoryAdjustmentId
	ORDER BY approval.intApprovalId DESC, approval.dtmDate DESC
) submissionStatus
OUTER APPLY (
	SELECT TOP 1 fp.strPeriod
	FROM tblGLFiscalYearPeriod fp
	WHERE Adj.dtmAdjustmentDate BETWEEN fp.dtmStartDate AND fp.dtmEndDate
) fiscal