CREATE VIEW vyuQMSearchApprovedPreInvoiceReconciliation
AS   --HEADER
SELECT intCatalogueReconciliationId			= CR.intCatalogueReconciliationId
     , strReconciliationNumber				= CR.strReconciliationNumber
     , strComments							= CR.strComments
     , dtmReconciliationDate				     = CR.dtmReconciliationDate	 
     , dtmPostDate							= CR.dtmPostDate
     , ysnPosted							= CR.ysnPosted
     , ysnApproved							= CASE WHEN SMT.intTransactionId IS NULL OR SMT.strApprovalStatus NOT IN ('No Need for Approval', 'Approved') THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END
     --DETAILS
     , intCatalogueReconciliationDetailId	     = CRD.intCatalogueReconciliationDetailId
     , intBillDetailId						= BD.intBillDetailId 
     , intConcurrencyId						= CRD.intConcurrencyId
     , strSupplierPreInvoiceNumber			     = CRD.strSupplierPreInvoiceNumber
     , dtmSupplierPreInvoiceDate			     = CRD.dtmSupplierPreInvoiceDate
     , dblBasePrice							= CRD.dblBasePrice
     , dblPreInvoicePrice					= CRD.dblPreInvoicePrice
     , dblQuantity							= CRD.dblQuantity
     , dblPreInvoiceQuantity				     = CRD.dblPreInvoiceQuantity
     , strGarden							= CRD.strGarden
     , strPreInvoiceGarden					= CRD.strPreInvoiceGarden
     , strGrade							= CRD.strGrade
     , strPreInvoiceGrade					= CRD.strPreInvoiceGrade
     , strChopNo							= CRD.strChopNo
     , strPreInvoiceChopNo					= CRD.strPreInvoiceChopNo
	 --NOT MAPPED
     , intSaleYear							= BD.intSaleYear
     , strBuyingCenter						= CL.strLocationName
     , strSaleNumber						= BD.strSaleNumber
     , strTeaType							= CAST('Tea Type' AS NVARCHAR(100))
     , strSupplier							= E.strName
     , strChannel							= BD.strSubBook
     , strCompanyCode						= CAST('Company Code' AS NVARCHAR(100))
     , dtmPromptDate						= BD.dtmExpectedDate
     , dtmSaleDate							= BD.dtmSaleDate
     , strLotNo							= BD.strVendorLotNumber
     , dblSupplierPreInvoicePrice			     = BD.dblCost
     , dblPreInvoiceLotQty					= BD.dblQtyReceived
     , dblTotalNoPackageBreakups			     = CAST(30 AS NUMERIC(18,6))
     , strPreInvoiceGardenInvoiceNo			= BD.strPreInvoiceGardenNumber
     , strPreInvoicePurchaseType			     = CASE WHEN B.intTransactionType = 2 THEN CAST('Vendor Prepayment' AS NVARCHAR(100))
                                                         WHEN B.intTransactionType = 3 THEN CAST('Debit Memo' AS NVARCHAR(100))
                                                         ELSE CAST('Voucher' AS NVARCHAR(100))
                                                    END
     , strPreInvoiceDocumentNo				= B.strBillId
     , dblNetWtPackages						= CAST(50 AS NUMERIC(18,6))
     , dblNoPackages						= CAST(60.8 AS NUMERIC(18,6))
     , dblNetWt2ndPackages					= CAST(70 AS NUMERIC(18,6))
     , dblNo2ndPackages						= CAST(808.6 AS NUMERIC(18,6))
     , dblNetWt3rdPackages					= CAST(90.68 AS NUMERIC(18,6))
     , dblNo3rdPackages						= CAST(660.68 AS NUMERIC(18,6))
     , strWarehouseCode						= SL.strName
FROM tblQMCatalogueReconciliationDetail CRD 
INNER JOIN tblQMCatalogueReconciliation CR ON CR.intCatalogueReconciliationId = CRD.intCatalogueReconciliationId
INNER JOIN tblAPBillDetail BD ON BD.intBillDetailId = CRD.intBillDetailId
INNER JOIN tblAPBill B ON BD.intBillId = B.intBillId
LEFT JOIN tblEMEntity E ON B.intEntityVendorId = E.intEntityId
LEFT JOIN tblSMCompanyLocation CL ON B.intShipToId = CL.intCompanyLocationId
LEFT JOIN tblICStorageLocation SL ON BD.intStorageLocationId = SL.intStorageLocationId
LEFT JOIN tblSMTransaction SMT ON SMT.intRecordId = CR.intCatalogueReconciliationId AND SMT.strTransactionNo = CR.strReconciliationNumber
LEFT JOIN tblSMScreen SMS ON SMS.intScreenId = SMT.intScreenId AND SMS.strScreenName = 'CatalogueReconciliation'