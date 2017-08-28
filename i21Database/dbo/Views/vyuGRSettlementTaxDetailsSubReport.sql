CREATE VIEW [dbo].[vyuGRSettlementTaxDetailsSubReport]
AS
SELECT 
 intInventoryReceiptId
,(
		SELECT strReceiptNumber
		FROM tblICInventoryReceipt
		WHERE intInventoryReceiptId = Tax.intInventoryReceiptId
 ) AS strReceiptNumber
 ,strTaxClass
 ,dblTax
FROM vyuICGetInventoryReceiptItemTax Tax

UNION

SELECT 
intInventoryReceiptId
,(
    SELECT strReceiptNumber
    FROM tblICInventoryReceipt
	WHERE intInventoryReceiptId = Charge.intInventoryReceiptId
  ) AS strReceiptNumber
  ,strTaxClass
  ,dblTax
FROM vyuICGetInventoryReceiptChargeTax Charge
