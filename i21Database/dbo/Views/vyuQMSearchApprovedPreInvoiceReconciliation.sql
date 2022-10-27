CREATE VIEW vyuQMSearchApprovedPreInvoiceReconciliation
AS   --HEADER
SELECT intCatalogueReconciliationId			= CR.intCatalogueReconciliationId
	 , strReconciliationNumber				= CR.strReconciliationNumber
	 , strComments							= CR.strComments
	 , dtmReconciliationDate				= CR.dtmReconciliationDate	 
	 , dtmPostDate							= CR.dtmPostDate
	 , ysnPosted							= CR.ysnPosted
	 , ysnApproved							= CASE WHEN SMT.intTransactionId IS NULL OR SMT.strApprovalStatus NOT IN ('No Need for Approval', 'Approved') THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END
	 --DETAILS
	 , intCatalogueReconciliationDetailId	= CRD.intCatalogueReconciliationDetailId
	 , intBillDetailId						= BD.intBillDetailId 
	 , intConcurrencyId						= CRD.intConcurrencyId
	 , strSupplierPreInvoiceNumber			= CRD.strSupplierPreInvoiceNumber
     , dtmSupplierPreInvoiceDate			= CRD.dtmSupplierPreInvoiceDate
     , dblBasePrice							= CRD.dblBasePrice
     , dblPreInvoicePrice					= CRD.dblPreInvoicePrice
     , dblQuantity							= CRD.dblQuantity
     , dblPreInvoiceQuantity				= CRD.dblPreInvoiceQuantity
     , strGarden							= CRD.strGarden
     , strPreInvoiceGarden					= CRD.strPreInvoiceGarden
     , strGrade								= CRD.strGrade
     , strPreInvoiceGrade					= CRD.strPreInvoiceGrade
     , strChopNo							= CRD.strChopNo
     , strPreInvoiceChopNo					= CRD.strPreInvoiceChopNo
	 --NOT MAPPED
	 , intSaleYear							= BD.intSaleYear
	 , strBuyingCenter						= CAST('Buying Center' AS NVARCHAR(100))
	 , strSaleNumber						= BD.strSaleNumber
	 , strTeaType							= CAST('Tea Type' AS NVARCHAR(100))
     , strSupplier							= CAST('Supplier' AS NVARCHAR(100))
     , strChannel							= CAST('Channel' AS NVARCHAR(100))
	 , strCompanyCode						= CAST('Company Code' AS NVARCHAR(100))
	 , dtmPromptDate						= CAST('03/14/2022' AS DATE)
	 , dtmSaleDate							= BD.dtmSaleDate
	 , strLotNo								= BD.strVendorLotNumber
     , dblSupplierPreInvoicePrice			= CAST(40 AS NUMERIC(18,6))
     , dblPreInvoiceLotQty					= CAST(20 AS NUMERIC(18,6))
     , dblTotalNoPackageBreakups			= CAST(30 AS NUMERIC(18,6))
     , strPreInvoiceGardenInvoiceNo			= BD.strPreInvoiceGardenNumber
     , strPreInvoicePurchaseType			= CAST('Pre Invoice Purchase Type' AS NVARCHAR(100))
     , strPreInvoiceDocumentNo				= CAST('Pre Invoice Document No' AS NVARCHAR(100))
     , dblNetWtPackages						= CAST(50 AS NUMERIC(18,6))
     , dblNoPackages						= CAST(60.8 AS NUMERIC(18,6))
     , dblNetWt2ndPackages					= CAST(70 AS NUMERIC(18,6))
     , dblNo2ndPackages						= CAST(808.6 AS NUMERIC(18,6))
     , dblNetWt3rdPackages					= CAST(90.68 AS NUMERIC(18,6))
     , dblNo3rdPackages						= CAST(660.68 AS NUMERIC(18,6))
     , strWarehouseCode						= CAST('Warehouse Code' AS NVARCHAR(100))
FROM tblQMCatalogueReconciliationDetail CRD 
INNER JOIN tblQMCatalogueReconciliation CR ON CR.intCatalogueReconciliationId = CRD.intCatalogueReconciliationId
INNER JOIN tblAPBillDetail BD ON BD.intBillDetailId = CRD.intBillDetailId
INNER JOIN tblAPBill B ON BD.intBillId = B.intBillId
LEFT JOIN tblSMTransaction SMT ON SMT.intRecordId = CR.intCatalogueReconciliationId AND SMT.strTransactionNo = CR.strReconciliationNumber
LEFT JOIN tblSMScreen SMS ON SMS.intScreenId = SMT.intScreenId AND SMS.strScreenName = 'CatalogueReconciliation'