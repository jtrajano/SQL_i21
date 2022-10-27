CREATE VIEW vyuQMSearchPreInvoiceCatalogueReconciliation
AS
SELECT intBillDetailId						= BD.intBillDetailId 
	 , intSaleYear							= BD.intSaleYear
	 , strBuyingCenter						= CAST('Buying Center' AS NVARCHAR(100))
	 , strSaleNumber						= BD.strSaleNumber
	 , strTeaType							= CAST('Tea Type' AS NVARCHAR(100))
     , strSupplier							= CAST('Supplier' AS NVARCHAR(100))
     , strChannel							= CAST('Channel' AS NVARCHAR(100))
     , strSupplierPreInvoiceNo				= CAST('Buying Supplier Pre-Invoice No' AS NVARCHAR(100))
	 , strCompanyCode						= CAST('Company Code' AS NVARCHAR(100))
	 , dtmSupplierPreInvoiceDate			= CAST('04/14/2022' AS DATE)
	 , dtmPromptDate						= CAST('03/14/2022' AS DATE)
	 , dtmSaleDate							= BD.dtmSaleDate
	 , strLotNo								= BD.strVendorLotNumber
     , dblSupplierPreInvoicePrice			= CAST(40 AS NUMERIC(18,6))
     , dblPreInvoiceLotQty					= CAST(20 AS NUMERIC(18,6))
     , dblTotalNoPackageBreakups			= CAST(30 AS NUMERIC(18,6))
     , strPreInvoiceGarden					= BD.strPreInvoiceGarden
     , strPreInvoiceGrade					= CAST('Pre Invoice Grade' AS NVARCHAR(100))
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
FROM tblAPBillDetail BD
INNER JOIN tblAPBill B ON BD.intBillId = B.intBillId
LEFT JOIN tblQMCatalogueReconciliationDetail CRD ON BD.intBillDetailId = CRD.intBillDetailId
WHERE B.ysnPosted = 0
  AND CRD.intCatalogueReconciliationDetailId IS NULL