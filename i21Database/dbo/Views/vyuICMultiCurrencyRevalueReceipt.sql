CREATE VIEW [dbo].[vyuICMultiCurrencyRevalueReceipt]
AS
SELECT
     strTransactionType            = r.strReceiptType
    ,strTransactionId            = r.strReceiptNumber
    ,strTransactionDate            = r.dtmReceiptDate
    ,strTransactionDueDate        = CAST(NULL AS NVARCHAR(50))
    ,strVendorName                = e.strName
    ,strCommodity                = c.strDescription
    ,strLineOfBusiness            = lob.strLineOfBusiness
    ,strLocation                = loc.strLocationName
    ,strTicket                    = st.strTicketNumber
    ,strContractNumber            = hd.strContractNumber
    ,strItemId                    = i.strItemNo
    ,dblQuantity                = ri.dblOpenReceive
    ,dblUnitPrice                = ri.dblUnitCost
    ,dblAmount                    = ri.dblLineTotal
    ,intCurrencyId                = r.intCurrencyId
    ,intForexRateType            = ri.intForexRateTypeId
    ,strForexRateType            = ex.strCurrencyExchangeRateType
    ,dblForexRate                = ri.dblForexRate
    ,dblHistoricAmount            = CAST(NULL AS NUMERIC(18, 6)) -- Unknown
    ,dblNewForexRate            = 0 --Calcuate By GL
    ,dblNewAmount                = 0 --Calcuate By GL
    ,dblUnrealizedDebitGain        = 0 --Calcuate By GL
    ,dblUnrealizedCreditGain    = 0 --Calcuate By GL
    ,dblDebit                    = 0 --Calcuate By GL
    ,dblCredit                    = 0 --Calcuate By GL
FROM tblICInventoryReceipt r
    LEFT JOIN tblICInventoryReceiptItem ri ON ri.intInventoryReceiptId = r.intInventoryReceiptId
    LEFT JOIN tblICItem i ON i.intItemId = ri.intItemId
    LEFT JOIN tblICCommodity c ON c.intCommodityId = i.intCommodityId
    LEFT JOIN tblEMEntity e ON e.intEntityId = r.intEntityVendorId
    LEFT JOIN tblICCategory ct ON ct.intCategoryId = i.intCategoryId
    LEFT JOIN tblSMLineOfBusiness lob ON lob.intLineOfBusinessId = ct.intLineOfBusinessId
    LEFT JOIN tblSMCompanyLocation loc ON loc.intCompanyLocationId = r.intLocationId
    LEFT JOIN tblSMCurrencyExchangeRateType ex ON ex.intCurrencyExchangeRateTypeId = ri.intForexRateTypeId
    LEFT JOIN vyuCTContractHeaderView hd ON ri.intSourceId = hd.intContractHeaderId
    LEFT JOIN vyuSCTicketInventoryReceiptView st ON st.intInventoryReceiptItemId = ri.intInventoryReceiptItemId
        AND st.intInventoryReceiptId = r.intInventoryReceiptId
WHERE r.ysnPosted = 1
    AND ri.dblBillQty <> ri.dblOpenReceive
