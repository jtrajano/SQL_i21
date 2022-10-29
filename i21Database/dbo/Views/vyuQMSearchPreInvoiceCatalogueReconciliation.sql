CREATE VIEW vyuQMSearchPreInvoiceCatalogueReconciliation
AS
SELECT intBillDetailId					    = BD.intBillDetailId 
	  , intSaleYear							      = BD.intSaleYear
	  , strBuyingCenter						    = CL.strLocationName
	  , strSaleNumber						      = BD.strSaleNumber
	  , strTeaType							      = CT.strCatalogueType
    , strSupplier							      = E.strName
    , strChannel							      = SB.strSubBook
    , strSupplierPreInvoiceNo			  = B.strVendorOrderNumber
	  , strCompanyCode						    = PG.strName
	  , dtmSupplierPreInvoiceDate		  = B.dtmDate
	  , dtmPromptDate						      = BD.dtmExpectedDate
	  , dtmSaleDate							      = BD.dtmSaleDate
	  , strLotNo								      = BD.strVendorLotNumber
    , dblSupplierPreInvoicePrice	  = BD.dblCost
    , dblPreInvoiceLotQty					  = BD.dblQtyReceived
    , dblTotalNoPackageBreakups		  = CAST(30 AS NUMERIC(18,6))
    , strPreInvoiceGarden					  = BD.strPreInvoiceGarden
    , strPreInvoiceGrade					  = BD.strComment
    , strPreInvoiceGardenInvoiceNo  = BD.strPreInvoiceGardenNumber
    , strPreInvoicePurchaseType			= CASE WHEN B.intTransactionType = 2 THEN CAST('Vendor Prepayment' AS NVARCHAR(100))
                                           WHEN B.intTransactionType = 3 THEN CAST('Debit Memo' AS NVARCHAR(100))
                                           ELSE CAST('Voucher' AS NVARCHAR(100))
                                      END
    , strPreInvoiceDocumentNo				= B.strBillId
    , dblNetWtPackages						  = BD.dblNetWeightPerPackage
    , dblNoPackages						      = BD.dblNumberOfPackages
    , dblNetWt2ndPackages					  = BD.dblNetWeightPerPackage2
    , dblNo2ndPackages						  = BD.dblNumberOfPackages2
    , dblNetWt3rdPackages					  = BD.dblNetWeightPerPackage3
    , dblNo3rdPackages						  = BD.dblNumberOfPackages3
    , strWarehouseCode						  = SL.strName
FROM tblAPBillDetail BD
INNER JOIN tblAPBill B ON BD.intBillId = B.intBillId
LEFT JOIN tblEMEntity E ON B.intEntityVendorId = E.intEntityId
LEFT JOIN tblSMCompanyLocation CL ON B.intShipToId = CL.intCompanyLocationId
LEFT JOIN tblQMCatalogueReconciliationDetail CRD ON BD.intBillDetailId = CRD.intBillDetailId
LEFT JOIN tblICStorageLocation SL ON BD.intStorageLocationId = SL.intStorageLocationId
LEFT JOIN tblCTSubBook SB ON BD.intSubBookId = SB.intSubBookId
LEFT JOIN tblSMPurchasingGroup PG ON BD.intPurchasingGroupId = PG.intPurchasingGroupId
LEFT JOIN tblQMCatalogueType CT ON BD.intCatalogueTypeId = CT.intCatalogueTypeId
WHERE B.ysnPosted = 0
  AND CRD.intCatalogueReconciliationDetailId IS NULL