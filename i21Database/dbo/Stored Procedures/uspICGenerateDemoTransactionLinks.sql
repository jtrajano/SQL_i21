CREATE PROCEDURE [dbo].[uspICGenerateDemoTransactionLinks]
AS

BEGIN

DELETE FROM tblICTransactionLinks
DELETE FROM tblICTransactionNodes
DECLARE @ContractType NVARCHAR(100) = 'Contract'--'Purchase Contract'
DECLARE @TransactionLinks udtICTransactionLinks

DECLARE @intSrcId INT
DECLARE @strSrcNo NVARCHAR(100)
DECLARE @intDestId INT
DECLARE @strDestNo NVARCHAR(100)

-- Contract → Scale Ticket
DECLARE cur_ct_sc CURSOR FOR   
SELECT ch.intContractHeaderId, ch.strContractNumber, t.intTicketId, t.strTicketNumber
FROM tblICInventoryReceipt r
INNER JOIN tblICInventoryReceiptItem ri ON ri.intInventoryReceiptId = r.intInventoryReceiptId
INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = ri.intOrderId
INNER JOIN tblSCTicket t ON t.intTicketId = ri.intSourceId
WHERE r.strReceiptType = 'Purchase Contract'
	AND r.intSourceType = 1 --Scale

OPEN cur_ct_sc

FETCH NEXT FROM cur_ct_sc   
INTO @intSrcId, @strSrcNo, @intDestId, @strDestNo

WHILE @@FETCH_STATUS = 0  
BEGIN 
	DELETE FROM @TransactionLinks
	INSERT INTO @TransactionLinks (
		strOperation, -- Operation
		intSrcId, strSrcTransactionNo, strSrcModuleName, strSrcTransactionType, -- Source Transaction
		intDestId, strDestTransactionNo, strDestModuleName, strDestTransactionType	-- Destination Transaction
	)
	SELECT 'Create',
		@intSrcId, @strSrcNo, 'Contracts', @ContractType,
		@intDestId, @strDestNo, 'Ticket Management', 'Scale Ticket'
	EXEC dbo.uspICAddTransactionLinks @TransactionLinks

	FETCH NEXT FROM cur_ct_sc   
	INTO @intSrcId, @strSrcNo, @intDestId, @strDestNo
END

CLOSE cur_ct_sc
DEALLOCATE cur_ct_sc

------------------------------------------------------------------------------------
-- Scale Ticket → Inventory Receipt
DECLARE cur_sc_ir CURSOR FOR 
SELECT
	t.intTicketId, t.strTicketNumber,
	r.intInventoryReceiptId, r.strReceiptNumber
FROM tblICInventoryReceipt r
INNER JOIN tblICInventoryReceiptItem ri ON ri.intInventoryReceiptId = r.intInventoryReceiptId
INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = ri.intOrderId
INNER JOIN tblSCTicket t ON t.intTicketId = ri.intSourceId
WHERE r.strReceiptType = 'Purchase Contract'
	AND r.intSourceType = 1 --Scale

OPEN cur_sc_ir

FETCH NEXT FROM cur_sc_ir   
INTO @intSrcId, @strSrcNo, @intDestId, @strDestNo

WHILE @@FETCH_STATUS = 0  
BEGIN 
	DELETE FROM @TransactionLinks
	INSERT INTO @TransactionLinks (
		strOperation, -- Operation
		intSrcId, strSrcTransactionNo, strSrcModuleName, strSrcTransactionType, -- Source Transaction
		intDestId, strDestTransactionNo, strDestModuleName, strDestTransactionType	-- Destination Transaction
	)
	SELECT 'Create',
		@intSrcId, @strSrcNo, 'Ticket Management', 'Scale Ticket',
		@intDestId, @strDestNo, 'Inventory', 'Inventory Receipt'
	EXEC dbo.uspICAddTransactionLinks @TransactionLinks

	FETCH NEXT FROM cur_sc_ir   
	INTO @intSrcId, @strSrcNo, @intDestId, @strDestNo
END

CLOSE cur_sc_ir
DEALLOCATE cur_sc_ir

---------------------------------------------------------------------------------
-- Purchase Contract → Transport Load
DECLARE cur_ct_tr CURSOR FOR
SELECT
	ch.intContractHeaderId, ch.strContractNumber,
	tr.intLoadHeaderId, th.strTransaction
FROM tblICInventoryReceipt r
INNER JOIN tblICInventoryReceiptItem ri ON ri.intInventoryReceiptId = r.intInventoryReceiptId
INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = ri.intOrderId
INNER JOIN tblTRLoadReceipt tr ON tr.intInventoryReceiptId = r.intInventoryReceiptId
INNER JOIN tblTRLoadHeader th ON th.intLoadHeaderId = tr.intLoadHeaderId
WHERE r.strReceiptType = 'Purchase Contract'
	AND r.intSourceType = 3 --Transport

OPEN cur_ct_tr

FETCH NEXT FROM cur_ct_tr   
INTO @intSrcId, @strSrcNo, @intDestId, @strDestNo

WHILE @@FETCH_STATUS = 0  
BEGIN 
	DELETE FROM @TransactionLinks
	INSERT INTO @TransactionLinks (
		strOperation, -- Operation
		intSrcId, strSrcTransactionNo, strSrcModuleName, strSrcTransactionType, -- Source Transaction
		intDestId, strDestTransactionNo, strDestModuleName, strDestTransactionType	-- Destination Transaction
	)
	SELECT 'Create',
		@intSrcId, @strSrcNo, 'Contracts', @ContractType,
		@intDestId, @strDestNo, 'Transport', 'Transport Load'
	EXEC dbo.uspICAddTransactionLinks @TransactionLinks

	FETCH NEXT FROM cur_ct_tr   
	INTO @intSrcId, @strSrcNo, @intDestId, @strDestNo
END

CLOSE cur_ct_tr
DEALLOCATE cur_ct_tr
--------------------------------------------------------------------------------------------
-- Transport Load → Inventory Receipt
DECLARE cur_tr_ir CURSOR FOR
SELECT
	tr.intLoadHeaderId, th.strTransaction,
	r.intInventoryReceiptId, r.strReceiptNumber
FROM tblICInventoryReceipt r
INNER JOIN tblICInventoryReceiptItem ri ON ri.intInventoryReceiptId = r.intInventoryReceiptId
INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = ri.intOrderId
INNER JOIN tblTRLoadReceipt tr ON tr.intInventoryReceiptId = r.intInventoryReceiptId
INNER JOIN tblTRLoadHeader th ON th.intLoadHeaderId = tr.intLoadHeaderId
WHERE r.strReceiptType = 'Purchase Contract'
	AND r.intSourceType = 3 --Transport

OPEN cur_tr_ir

FETCH NEXT FROM cur_tr_ir   
INTO @intSrcId, @strSrcNo, @intDestId, @strDestNo

WHILE @@FETCH_STATUS = 0  
BEGIN 
	DELETE FROM @TransactionLinks
	INSERT INTO @TransactionLinks (
		strOperation, -- Operation
		intSrcId, strSrcTransactionNo, strSrcModuleName, strSrcTransactionType, -- Source Transaction
		intDestId, strDestTransactionNo, strDestModuleName, strDestTransactionType	-- Destination Transaction
	)
	SELECT 'Create',
		@intSrcId, @strSrcNo, 'Transport', 'Transport Load',
		@intDestId, @strDestNo, 'Inventory', 'Inventory Receipt'
	EXEC dbo.uspICAddTransactionLinks @TransactionLinks

	FETCH NEXT FROM cur_tr_ir   
	INTO @intSrcId, @strSrcNo, @intDestId, @strDestNo
END

CLOSE cur_tr_ir
DEALLOCATE cur_tr_ir
--------------------------------------------------------------------------------------------
-- Contract → Purchase Order
DECLARE cur_ct_po CURSOR FOR
SELECT 
	ch.intContractHeaderId, ch.strContractNumber,
	po.intPurchaseId, po.strPurchaseOrderNumber
FROM tblICInventoryReceipt r
INNER JOIN tblICInventoryReceiptItem ri ON ri.intInventoryReceiptId = r.intInventoryReceiptId
INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = ri.intOrderId
INNER JOIN tblPOPurchase po ON po.intPurchaseId = ri.intOrderId
WHERE r.strReceiptType = 'Purchase Order'
	AND r.intSourceType = 0 --Add Orders

OPEN cur_ct_po

FETCH NEXT FROM cur_ct_po   
INTO @intSrcId, @strSrcNo, @intDestId, @strDestNo

WHILE @@FETCH_STATUS = 0  
BEGIN 
	DELETE FROM @TransactionLinks
	INSERT INTO @TransactionLinks (
		strOperation, -- Operation
		intSrcId, strSrcTransactionNo, strSrcModuleName, strSrcTransactionType, -- Source Transaction
		intDestId, strDestTransactionNo, strDestModuleName, strDestTransactionType	-- Destination Transaction
	)
	SELECT 'Create',
		@intSrcId, @strSrcNo, 'Inventory', @ContractType,
		@intDestId, @strDestNo, 'Accounts Payable', 'Purchase Order'
	EXEC dbo.uspICAddTransactionLinks @TransactionLinks

	FETCH NEXT FROM cur_ct_po   
	INTO @intSrcId, @strSrcNo, @intDestId, @strDestNo
END

CLOSE cur_ct_po
DEALLOCATE cur_ct_po
--------------------------------------------------------------------------------------------
-- Purchase Order → Inventory Receipt
DECLARE cur_po_ir CURSOR FOR
SELECT
	po.intPurchaseId, po.strPurchaseOrderNumber,
	r.intInventoryReceiptId, r.strReceiptNumber
FROM tblICInventoryReceipt r
INNER JOIN tblICInventoryReceiptItem ri ON ri.intInventoryReceiptId = r.intInventoryReceiptId
INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = ri.intOrderId
INNER JOIN tblPOPurchase po ON po.intPurchaseId = ri.intOrderId
WHERE r.strReceiptType = 'Purchase Order'
	AND r.intSourceType = 0 --Add Orders

OPEN cur_po_ir

FETCH NEXT FROM cur_po_ir   
INTO @intSrcId, @strSrcNo, @intDestId, @strDestNo

WHILE @@FETCH_STATUS = 0  
BEGIN 
	DELETE FROM @TransactionLinks
	INSERT INTO @TransactionLinks (
		strOperation, -- Operation
		intSrcId, strSrcTransactionNo, strSrcModuleName, strSrcTransactionType, -- Source Transaction
		intDestId, strDestTransactionNo, strDestModuleName, strDestTransactionType	-- Destination Transaction
	)
	SELECT 'Create',
		@intSrcId, @strSrcNo, 'Accounts Payable', 'Purchase Order',
		@intDestId, @strDestNo, 'Inventory', 'Inventory Receipt'
	EXEC dbo.uspICAddTransactionLinks @TransactionLinks

	FETCH NEXT FROM cur_po_ir   
	INTO @intSrcId, @strSrcNo, @intDestId, @strDestNo
END

CLOSE cur_po_ir
DEALLOCATE cur_po_ir
--------------------------------------------------------------------------------------------
-- Inventory Receipt → Bill
DECLARE cur_ir_bill CURSOR FOR
SELECT DISTINCT vp.intInventoryReceiptId, vp.strReceiptNumber, vp.intBillId, vp.strBillId
FROM vyuICGetInventoryReceiptVoucher vp
WHERE vp.intBillId IS NOT NULL

OPEN cur_ir_bill

FETCH NEXT FROM cur_ir_bill   
INTO @intSrcId, @strSrcNo, @intDestId, @strDestNo

WHILE @@FETCH_STATUS = 0  
BEGIN 
	DELETE FROM @TransactionLinks
	INSERT INTO @TransactionLinks (
		strOperation, -- Operation
		intSrcId, strSrcTransactionNo, strSrcModuleName, strSrcTransactionType, -- Source Transaction
		intDestId, strDestTransactionNo, strDestModuleName, strDestTransactionType	-- Destination Transaction
	)
	SELECT 'Process',
		@intSrcId, @strSrcNo, 'Inventory', 'Inventory Receipt',
		@intDestId, @strDestNo, 'Accounts Payable', 'Bill'
	EXEC dbo.uspICAddTransactionLinks @TransactionLinks

	FETCH NEXT FROM cur_ir_bill   
	INTO @intSrcId, @strSrcNo, @intDestId, @strDestNo
END

CLOSE cur_ir_bill
DEALLOCATE cur_ir_bill
--------------------------------------------------------------------------------------------
-- Bill → Bill Payments
DECLARE cur_bill_pay CURSOR FOR
SELECT DISTINCT b.intBillId, pd.strBillId, p.intPaymentId, pd.strPaymentRecordNum
FROM vyuAPPaymentDetail pd
INNER JOIN tblAPBill b ON b.strBillId = pd.strBillId
INNER JOIN tblAPPaymentDetail ppd ON ppd.intPaymentDetailId = pd.intPaymentDetailId
INNER JOIN tblAPPayment p ON p.intPaymentId = ppd.intPaymentId

OPEN cur_bill_pay

FETCH NEXT FROM cur_bill_pay   
INTO @intSrcId, @strSrcNo, @intDestId, @strDestNo

WHILE @@FETCH_STATUS = 0  
BEGIN 
	DELETE FROM @TransactionLinks
	INSERT INTO @TransactionLinks (
		strOperation, -- Operation
		intSrcId, strSrcTransactionNo, strSrcModuleName, strSrcTransactionType, -- Source Transaction
		intDestId, strDestTransactionNo, strDestModuleName, strDestTransactionType	-- Destination Transaction
	)
	SELECT 'Process',
		@intSrcId, @strSrcNo, 'Accounts Payable', 'Bill',
		@intDestId, @strDestNo, 'Accounts Payable', 'Bill Payment'
	EXEC dbo.uspICAddTransactionLinks @TransactionLinks

	FETCH NEXT FROM cur_bill_pay   
	INTO @intSrcId, @strSrcNo, @intDestId, @strDestNo
END

CLOSE cur_bill_pay
DEALLOCATE cur_bill_pay

--------------------------------------------------------------------------------------------
--Invoice → Receive Payment
DECLARE cur_invoice_rcvpay CURSOR FOR
SELECT DISTINCT i.intInvoiceId, i.strInvoiceNumber, p.intPaymentId, p.strRecordNumber
FROM tblARPaymentDetail pd
INNER JOIN tblARPayment p ON p.intPaymentId = pd.intPaymentId
INNER JOIN tblARInvoice i ON i.intInvoiceId = pd.intInvoiceId

OPEN cur_invoice_rcvpay

FETCH NEXT FROM cur_invoice_rcvpay   
INTO @intSrcId, @strSrcNo, @intDestId, @strDestNo

WHILE @@FETCH_STATUS = 0  
BEGIN 
	DELETE FROM @TransactionLinks
	INSERT INTO @TransactionLinks (
		strOperation, -- Operation
		intSrcId, strSrcTransactionNo, strSrcModuleName, strSrcTransactionType, -- Source Transaction
		intDestId, strDestTransactionNo, strDestModuleName, strDestTransactionType	-- Destination Transaction
	)
	SELECT 'Process',
		@intSrcId, @strSrcNo, 'Accounts Receivable', 'Invoice',
		@intDestId, @strDestNo, 'Accounts Receivable', 'Receive Payment'
	EXEC dbo.uspICAddTransactionLinks @TransactionLinks

	FETCH NEXT FROM cur_invoice_rcvpay   
	INTO @intSrcId, @strSrcNo, @intDestId, @strDestNo
END

CLOSE cur_invoice_rcvpay
DEALLOCATE cur_invoice_rcvpay
--------------------------------------------------------------------------------------------
-- Transport Load → Inventory Transfer
DECLARE cur_tr_it CURSOR FOR
SELECT DISTINCT trl.intLoadHeaderId, trl.strTransaction, t.intInventoryTransferId, t.strTransferNo
FROM tblTRLoadHeader trl
INNER JOIN tblTRLoadReceipt trlr ON trlr.intLoadHeaderId = trl.intLoadHeaderId
INNER JOIN tblICInventoryTransfer t ON t.intInventoryTransferId = trlr.intInventoryTransferId

OPEN cur_tr_it

FETCH NEXT FROM cur_tr_it   
INTO @intSrcId, @strSrcNo, @intDestId, @strDestNo

WHILE @@FETCH_STATUS = 0  
BEGIN 
	DELETE FROM @TransactionLinks
	INSERT INTO @TransactionLinks (
		strOperation, -- Operation
		intSrcId, strSrcTransactionNo, strSrcModuleName, strSrcTransactionType, -- Source Transaction
		intDestId, strDestTransactionNo, strDestModuleName, strDestTransactionType	-- Destination Transaction
	)
	SELECT 'Process',
		@intSrcId, @strSrcNo, 'Transports', 'Transport Load',
		@intDestId, @strDestNo, 'Inventory', 'Inventory Transfer'
	EXEC dbo.uspICAddTransactionLinks @TransactionLinks

	FETCH NEXT FROM cur_tr_it   
	INTO @intSrcId, @strSrcNo, @intDestId, @strDestNo
END

CLOSE cur_tr_it
DEALLOCATE cur_tr_it

--------------------------------------------------------------------------------------------
DECLARE cur_tr_receipt CURSOR FOR
-- Transport Load → Inventory Receipt
SELECT DISTINCT trl.intLoadHeaderId, trl.strTransaction, r.intInventoryReceiptId, r.strReceiptNumber
FROM tblTRLoadHeader trl
INNER JOIN tblTRLoadReceipt trlr ON trlr.intLoadHeaderId = trl.intLoadHeaderId
INNER JOIN tblICInventoryReceipt r ON r.intInventoryReceiptId = trlr.intInventoryReceiptId

OPEN cur_tr_receipt

FETCH NEXT FROM cur_tr_receipt   
INTO @intSrcId, @strSrcNo, @intDestId, @strDestNo

WHILE @@FETCH_STATUS = 0  
BEGIN 
	DELETE FROM @TransactionLinks
	INSERT INTO @TransactionLinks (
		strOperation, -- Operation
		intSrcId, strSrcTransactionNo, strSrcModuleName, strSrcTransactionType, -- Source Transaction
		intDestId, strDestTransactionNo, strDestModuleName, strDestTransactionType	-- Destination Transaction
	)
	SELECT 'Process',
		@intSrcId, @strSrcNo, 'Transports', 'Transport Load',
		@intDestId, @strDestNo, 'Inventory', 'Inventory Receipt'
	EXEC dbo.uspICAddTransactionLinks @TransactionLinks

	FETCH NEXT FROM cur_tr_receipt   
	INTO @intSrcId, @strSrcNo, @intDestId, @strDestNo
END

CLOSE cur_tr_receipt
DEALLOCATE cur_tr_receipt

--------------------------------------------------------------------------------------------
-- Transport Load → Invoice
DECLARE cur_tr_invoice CURSOR FOR
SELECT DISTINCT tr.intLoadHeaderId, tr.strTransaction, i.intInvoiceId, i.strInvoiceNumber
FROM vyuTRLoadHeader tr
INNER JOIN tblARInvoice i ON i.intInvoiceId = tr.intInvoiceId

OPEN cur_tr_invoice

FETCH NEXT FROM cur_tr_invoice   
INTO @intSrcId, @strSrcNo, @intDestId, @strDestNo

WHILE @@FETCH_STATUS = 0  
BEGIN 
	DELETE FROM @TransactionLinks
	INSERT INTO @TransactionLinks (
		strOperation, -- Operation
		intSrcId, strSrcTransactionNo, strSrcModuleName, strSrcTransactionType, -- Source Transaction
		intDestId, strDestTransactionNo, strDestModuleName, strDestTransactionType	-- Destination Transaction
	)
	SELECT 'Process',
		@intSrcId, @strSrcNo, 'Transports', 'Transport Load',
		@intDestId, @strDestNo, 'Accounts Receivable', 'Invoice'
	EXEC dbo.uspICAddTransactionLinks @TransactionLinks

	FETCH NEXT FROM cur_tr_invoice   
	INTO @intSrcId, @strSrcNo, @intDestId, @strDestNo
END

CLOSE cur_tr_invoice
DEALLOCATE cur_tr_invoice

--------------------------------------------------------------------------------------------
-- Contract → Load Shipment
DECLARE cur_ct_ls CURSOR FOR
SELECT DISTINCT CH.intContractHeaderId, CH.strContractNumber, L.intLoadId, L.strLoadNumber
FROM tblLGLoad L
INNER JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
INNER JOIN tblLGLoadDetailContainerLink LDCL ON LD.intLoadDetailId = LDCL.intLoadDetailId
INNER JOIN tblCTContractDetail CT ON CT.intContractDetailId = LD.intPContractDetailId
INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CT.intContractHeaderId

OPEN cur_ct_ls

FETCH NEXT FROM cur_ct_ls   
INTO @intSrcId, @strSrcNo, @intDestId, @strDestNo

WHILE @@FETCH_STATUS = 0  
BEGIN 
	DELETE FROM @TransactionLinks
	INSERT INTO @TransactionLinks (
		strOperation, -- Operation
		intSrcId, strSrcTransactionNo, strSrcModuleName, strSrcTransactionType, -- Source Transaction
		intDestId, strDestTransactionNo, strDestModuleName, strDestTransactionType	-- Destination Transaction
	)
	SELECT 'Process',
		@intSrcId, @strSrcNo, 'Contracts', 'Contract',
		@intDestId, @strDestNo, 'Logistics', 'Load Shipment'
	EXEC dbo.uspICAddTransactionLinks @TransactionLinks

	FETCH NEXT FROM cur_ct_ls   
	INTO @intSrcId, @strSrcNo, @intDestId, @strDestNo
END

CLOSE cur_ct_ls
DEALLOCATE cur_ct_ls

--------------------------------------------------------------------------------------------
-- Load Shipment → Inventory Receipt
DECLARE cur_ls_ir CURSOR FOR
SELECT DISTINCT L.intLoadId, L.strLoadNumber, R.intInventoryReceiptId, R.strReceiptNumber
FROM tblLGLoad L
INNER JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
INNER JOIN tblICInventoryReceiptItem RI ON RI.intSourceId = LD.intLoadDetailId
INNER JOIN tblICInventoryReceipt R ON R.intInventoryReceiptId = RI.intInventoryReceiptId
WHERE R.intSourceType = 2

OPEN cur_ls_ir

FETCH NEXT FROM cur_ls_ir   
INTO @intSrcId, @strSrcNo, @intDestId, @strDestNo

WHILE @@FETCH_STATUS = 0  
BEGIN 
	DELETE FROM @TransactionLinks
	INSERT INTO @TransactionLinks (
		strOperation, -- Operation
		intSrcId, strSrcTransactionNo, strSrcModuleName, strSrcTransactionType, -- Source Transaction
		intDestId, strDestTransactionNo, strDestModuleName, strDestTransactionType	-- Destination Transaction
	)
	SELECT 'Process',
		@intSrcId, @strSrcNo, 'Logistics', 'Load Shipment',
		@intDestId, @strDestNo, 'Inventory', 'Inventory Receipt'
	EXEC dbo.uspICAddTransactionLinks @TransactionLinks

	FETCH NEXT FROM cur_ls_ir   
	INTO @intSrcId, @strSrcNo, @intDestId, @strDestNo
END

CLOSE cur_ls_ir
DEALLOCATE cur_ls_ir

--------------------------------------------------------------------------------------------
-- Purchase Orders → Bill
DECLARE cur_po_bill CURSOR FOR
SELECT DISTINCT po.intPurchaseId, po.strPurchaseOrderNumber, b.intBillId, b.strBillId
FROM tblAPBill b
INNER JOIN tblPOPurchase po ON po.intPurchaseId = b.intPurchaseOrderId

OPEN cur_po_bill

FETCH NEXT FROM cur_po_bill   
INTO @intSrcId, @strSrcNo, @intDestId, @strDestNo

WHILE @@FETCH_STATUS = 0  
BEGIN 
	DELETE FROM @TransactionLinks
	INSERT INTO @TransactionLinks (
		strOperation, -- Operation
		intSrcId, strSrcTransactionNo, strSrcModuleName, strSrcTransactionType, -- Source Transaction
		intDestId, strDestTransactionNo, strDestModuleName, strDestTransactionType	-- Destination Transaction
	)
	SELECT 'Process',
		@intSrcId, @strSrcNo, 'Accounts Payable', 'Purchase Order',
		@intDestId, @strDestNo, 'Accounts Payable', 'Bill'
	EXEC dbo.uspICAddTransactionLinks @TransactionLinks

	FETCH NEXT FROM cur_po_bill   
	INTO @intSrcId, @strSrcNo, @intDestId, @strDestNo
END

CLOSE cur_po_bill
DEALLOCATE cur_po_bill

--------------------------------------------------------------------------------------------
-- Sales Orders → Invoice
DECLARE cur_so_invoice CURSOR FOR
SELECT DISTINCT so.intSalesOrderId, so.strSalesOrderNumber, i.intInvoiceId, i.strInvoiceNumber
FROM tblSOSalesOrder so
INNER JOIN tblARInvoice i ON i.intSalesOrderId = so.intSalesOrderId

OPEN cur_so_invoice

FETCH NEXT FROM cur_so_invoice   
INTO @intSrcId, @strSrcNo, @intDestId, @strDestNo

WHILE @@FETCH_STATUS = 0  
BEGIN 
	DELETE FROM @TransactionLinks
	INSERT INTO @TransactionLinks (
		strOperation, -- Operation
		intSrcId, strSrcTransactionNo, strSrcModuleName, strSrcTransactionType, -- Source Transaction
		intDestId, strDestTransactionNo, strDestModuleName, strDestTransactionType	-- Destination Transaction
	)
	SELECT 'Process',
		@intSrcId, @strSrcNo, 'Accounts Receivable', 'Sales Order',
		@intDestId, @strDestNo, 'Accounts Receivable', 'Invoice'
	EXEC dbo.uspICAddTransactionLinks @TransactionLinks

	FETCH NEXT FROM cur_so_invoice   
	INTO @intSrcId, @strSrcNo, @intDestId, @strDestNo
END

CLOSE cur_so_invoice
DEALLOCATE cur_so_invoice

--------------------------------------------------------------------------------------------
-- Scale Ticket → Inventory Transfer
DECLARE cur_sc_it CURSOR FOR
SELECT DISTINCT sc.intTicketId, sc.strTicketNumber, it.intInventoryTransferId, it.strTransferNo
FROM tblSCTicket sc
INNER JOIN tblICInventoryTransfer it ON it.intInventoryTransferId = sc.intInventoryTransferId

OPEN cur_sc_it

FETCH NEXT FROM cur_sc_it   
INTO @intSrcId, @strSrcNo, @intDestId, @strDestNo

WHILE @@FETCH_STATUS = 0  
BEGIN 
	DELETE FROM @TransactionLinks
	INSERT INTO @TransactionLinks (
		strOperation, -- Operation
		intSrcId, strSrcTransactionNo, strSrcModuleName, strSrcTransactionType, -- Source Transaction
		intDestId, strDestTransactionNo, strDestModuleName, strDestTransactionType	-- Destination Transaction
	)
	SELECT 'Process',
		@intSrcId, @strSrcNo, 'Ticket Management', 'Scale Ticket',
		@intDestId, @strDestNo, 'Inventory', 'Inventory Transfer'
	EXEC dbo.uspICAddTransactionLinks @TransactionLinks

	FETCH NEXT FROM cur_sc_it   
	INTO @intSrcId, @strSrcNo, @intDestId, @strDestNo
END

CLOSE cur_sc_it
DEALLOCATE cur_sc_it

--------------------------------------------------------------------------------------------
-- Inventory Transfer → Inventory Receipt
DECLARE cur_it_ir CURSOR FOR
SELECT DISTINCT it.intInventoryTransferId, it.strTransferNo, r.intInventoryReceiptId, r.strReceiptNumber
FROM tblICInventoryReceipt r
INNER JOIN tblICInventoryReceiptItem ri ON ri.intInventoryReceiptId = r.intInventoryReceiptId
INNER JOIN tblICInventoryTransfer it ON it.intInventoryTransferId = ri.intSourceId
WHERE r.strReceiptType = 'Transfer Order'

OPEN cur_it_ir

FETCH NEXT FROM cur_it_ir   
INTO @intSrcId, @strSrcNo, @intDestId, @strDestNo

WHILE @@FETCH_STATUS = 0  
BEGIN 
	DELETE FROM @TransactionLinks
	INSERT INTO @TransactionLinks (
		strOperation, -- Operation
		intSrcId, strSrcTransactionNo, strSrcModuleName, strSrcTransactionType, -- Source Transaction
		intDestId, strDestTransactionNo, strDestModuleName, strDestTransactionType	-- Destination Transaction
	)
	SELECT 'Process',
		@intSrcId, @strSrcNo, 'Inventory', 'Inventory Transfer',
		@intDestId, @strDestNo, 'Inventory', 'Inventory Receipt'
	EXEC dbo.uspICAddTransactionLinks @TransactionLinks

	FETCH NEXT FROM cur_it_ir   
	INTO @intSrcId, @strSrcNo, @intDestId, @strDestNo
END

CLOSE cur_it_ir
DEALLOCATE cur_it_ir

--------------------------------------------------------------------------------------------
-- Load Shipment → Scale Ticket
DECLARE cur_ls_sc CURSOR FOR
SELECT DISTINCT L.intLoadId, L.strLoadNumber, sc.intTicketId, sc.strTicketNumber
FROM tblLGLoad L
INNER JOIN tblSCTicket sc ON sc.intLoadId = L.intLoadId

OPEN cur_ls_sc

FETCH NEXT FROM cur_ls_sc   
INTO @intSrcId, @strSrcNo, @intDestId, @strDestNo

WHILE @@FETCH_STATUS = 0  
BEGIN 
	DELETE FROM @TransactionLinks
	INSERT INTO @TransactionLinks (
		strOperation, -- Operation
		intSrcId, strSrcTransactionNo, strSrcModuleName, strSrcTransactionType, -- Source Transaction
		intDestId, strDestTransactionNo, strDestModuleName, strDestTransactionType	-- Destination Transaction
	)
	SELECT 'Process',
		@intSrcId, @strSrcNo, 'Logistics', 'Load Shipment',
		@intDestId, @strDestNo, 'Ticket Management', 'Scale Ticket'
	EXEC dbo.uspICAddTransactionLinks @TransactionLinks

	FETCH NEXT FROM cur_ls_sc   
	INTO @intSrcId, @strSrcNo, @intDestId, @strDestNo
END

CLOSE cur_ls_sc
DEALLOCATE cur_ls_sc

--------------------------------------------------------------------------------------------
-- Inventory Receipt → Storage Ticket Number
DECLARE cur_ir_stn CURSOR FOR
SELECT DISTINCT r.intInventoryReceiptId, r.strReceiptNumber, s.intSettleStorageId, s.strStorageTicket
FROM tblICInventoryReceipt r
INNER JOIN tblICInventoryReceiptItem ri ON ri.intInventoryReceiptId = r.intInventoryReceiptId
INNER JOIN tblGRSettleStorage s ON s.intSettleStorageId = ri.intSourceId
WHERE r.intSourceType = 4

OPEN cur_ir_stn

FETCH NEXT FROM cur_ir_stn   
INTO @intSrcId, @strSrcNo, @intDestId, @strDestNo

WHILE @@FETCH_STATUS = 0  
BEGIN 
	DELETE FROM @TransactionLinks
	INSERT INTO @TransactionLinks (
		strOperation, -- Operation
		intSrcId, strSrcTransactionNo, strSrcModuleName, strSrcTransactionType, -- Source Transaction
		intDestId, strDestTransactionNo, strDestModuleName, strDestTransactionType	-- Destination Transaction
	)
	SELECT 'Process',
		@intSrcId, @strSrcNo, 'Inventory', 'Inventory Receipt',
		@intDestId, @strDestNo, 'Ticket Management', 'Storage Ticket Number'
	EXEC dbo.uspICAddTransactionLinks @TransactionLinks

	FETCH NEXT FROM cur_ir_stn   
	INTO @intSrcId, @strSrcNo, @intDestId, @strDestNo
END

CLOSE cur_ir_stn
DEALLOCATE cur_ir_stn

--------------------------------------------------------------------------------------------
-- Storage Ticket Number → Bill
DECLARE cur_stn_bill CURSOR FOR
SELECT DISTINCT s.intSettleStorageId, s.strStorageTicket, b.intBillId, b.strBillId
FROM tblGRSettleStorage s
INNER JOIN tblAPBill b ON b.intBillId = s.intBillId

OPEN cur_stn_bill

FETCH NEXT FROM cur_stn_bill   
INTO @intSrcId, @strSrcNo, @intDestId, @strDestNo

WHILE @@FETCH_STATUS = 0  
BEGIN 
	DELETE FROM @TransactionLinks
	INSERT INTO @TransactionLinks (
		strOperation, -- Operation
		intSrcId, strSrcTransactionNo, strSrcModuleName, strSrcTransactionType, -- Source Transaction
		intDestId, strDestTransactionNo, strDestModuleName, strDestTransactionType	-- Destination Transaction
	)
	SELECT 'Process',
		@intSrcId, @strSrcNo, 'Ticket Management', 'Storage Ticket Number',
		@intDestId, @strDestNo, 'Accounts Payable', 'Bill'
	EXEC dbo.uspICAddTransactionLinks @TransactionLinks

	FETCH NEXT FROM cur_stn_bill   
	INTO @intSrcId, @strSrcNo, @intDestId, @strDestNo
END

CLOSE cur_stn_bill
DEALLOCATE cur_stn_bill

--------------------------------------------------------------------------------------------
-- Scale Ticket → Storage Ticket Number
DECLARE cur_sc_stn CURSOR FOR
SELECT DISTINCT sc.intTicketId, sc.strTicketNumber, ss.intSettleStorageId, ss.strStorageTicket
FROM tblSCTicket sc
INNER JOIN tblGRCustomerStorage cs ON cs.intTicketId = sc.intTicketId
INNER JOIN tblGRSettleStorageTicket st ON st.intCustomerStorageId = cs.intCustomerStorageId
INNER JOIN tblGRSettleStorage ss ON ss.intSettleStorageId = st.intSettleStorageId

OPEN cur_sc_stn

FETCH NEXT FROM cur_sc_stn   
INTO @intSrcId, @strSrcNo, @intDestId, @strDestNo

WHILE @@FETCH_STATUS = 0  
BEGIN 
	DELETE FROM @TransactionLinks
	INSERT INTO @TransactionLinks (
		strOperation, -- Operation
		intSrcId, strSrcTransactionNo, strSrcModuleName, strSrcTransactionType, -- Source Transaction
		intDestId, strDestTransactionNo, strDestModuleName, strDestTransactionType	-- Destination Transaction
	)
	SELECT 'Process',
		@intSrcId, @strSrcNo, 'Ticket Management', 'Scale Ticket',
		@intDestId, @strDestNo, 'Ticket Management', 'Storage Ticket Number'
	EXEC dbo.uspICAddTransactionLinks @TransactionLinks

	FETCH NEXT FROM cur_sc_stn   
	INTO @intSrcId, @strSrcNo, @intDestId, @strDestNo
END

CLOSE cur_sc_stn
DEALLOCATE cur_sc_stn

--------------------------------------------------------------------------------------------
--Storage Ticket Number → Sales Invoice
DECLARE cur_stn_si CURSOR FOR
SELECT DISTINCT ss.intSettleStorageId, ss.strStorageTicket, i.intInvoiceId, i.strInvoiceNumber
FROM tblSCTicket sc
INNER JOIN tblGRCustomerStorage cs ON cs.intTicketId = sc.intTicketId
INNER JOIN tblGRSettleStorageTicket st ON st.intCustomerStorageId = cs.intCustomerStorageId
INNER JOIN tblGRSettleStorage ss ON ss.intSettleStorageId = st.intSettleStorageId
INNER JOIN tblARInvoiceDetail id ON id.intTicketId = sc.intTicketId
INNER JOIN tblARInvoice i ON i.intInvoiceId = id.intInvoiceId

OPEN cur_stn_si

FETCH NEXT FROM cur_stn_si   
INTO @intSrcId, @strSrcNo, @intDestId, @strDestNo

WHILE @@FETCH_STATUS = 0  
BEGIN 
	DELETE FROM @TransactionLinks
	INSERT INTO @TransactionLinks (
		strOperation, -- Operation
		intSrcId, strSrcTransactionNo, strSrcModuleName, strSrcTransactionType, -- Source Transaction
		intDestId, strDestTransactionNo, strDestModuleName, strDestTransactionType	-- Destination Transaction
	)
	SELECT 'Process',
		@intSrcId, @strSrcNo, 'Ticket Management', 'Storage Ticket Number',
		@intDestId, @strDestNo, 'Accounts Receivable', 'Invoice'
	EXEC dbo.uspICAddTransactionLinks @TransactionLinks

	FETCH NEXT FROM cur_stn_si   
	INTO @intSrcId, @strSrcNo, @intDestId, @strDestNo
END

CLOSE cur_stn_si
DEALLOCATE cur_stn_si

END