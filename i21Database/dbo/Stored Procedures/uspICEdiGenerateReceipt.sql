CREATE PROCEDURE [dbo].[uspICEdiGenerateReceipt] 
	@VendorId INT
	, @LocationId INT
	, @StoreLocations UdtCompanyLocations READONLY
	, @UniqueId NVARCHAR(100)
	, @UserId INT
	, @strFileName NVARCHAR(500) = NULL 
	, @strFileType NVARCHAR(50) = NULL 
	, @ErrorCount INT OUTPUT
	, @TotalRows INT OUTPUT
AS
-------------------------- BUSINESS -----------------------------------------------------------
DECLARE @Start DATETIME
SET @Start = GETDATE()

SET @VendorId = NULLIF(@VendorId, 0) 

DECLARE @Stores TABLE (
	FileIndex INT
	, RecordIndex INT
	, RecordType NVARCHAR(50)
	, StoreNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
)

DECLARE @Items TABLE( 
	FileIndex INT
	, RecordIndex INT
	, ItemDescription NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, ItemUpc NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, ParentItemCode NVARCHAR(100)
	, [PriceMulti-pack] NUMERIC(38, 20)
	, Quantity NUMERIC(38, 20)
	, RecordType NVARCHAR(50)
	, RetailPrice NUMERIC(38, 20)
	, UnitCost NUMERIC(38, 20)
	, UnitMultiplier NUMERIC(38, 20)
	, UnitOfMeasure NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, VendorItemCode NVARCHAR(50) COLLATE Latin1_General_CI_AS
)

DECLARE @Invoices TABLE(
	FileIndex INT
	, RecordIndex INT
	, InvoiceDate DATETIME
	, InvoiceNumber NVARCHAR(50)
	, InvoiceTotal NUMERIC(38, 20)
	, RecordType NVARCHAR(50)
	, VendorCode NVARCHAR(50)
)

DECLARE @Charges TABLE(
	FileIndex INT
	, RecordIndex INT
	, Amount NUMERIC(38,20)
	, ChargeType NVARCHAR(50)
	, ItemDescription NVARCHAR(200) COLLATE Latin1_General_CI_AS, RecordType NVARCHAR(50)
)

INSERT INTO @Stores EXEC [dbo].[uspICEdiGenerateMappingObjects] '0', @UniqueId
INSERT INTO @Items EXEC [dbo].[uspICEdiGenerateMappingObjects] 'B', @UniqueId
INSERT INTO @Invoices EXEC [dbo].[uspICEdiGenerateMappingObjects] 'A', @UniqueId
INSERT INTO @Charges EXEC [dbo].[uspICEdiGenerateMappingObjects] 'C', @UniqueId

-- Implied decimal conversions
UPDATE @Invoices 
SET InvoiceTotal = 
	CASE 
		WHEN ISNULL(InvoiceTotal, 0) = 0 THEN 0 
		ELSE InvoiceTotal / 100.00 
	END

UPDATE @Items
SET UnitCost = 
		CASE 
			WHEN ISNULL(UnitCost, 0) = 0 THEN 0 
			ELSE UnitCost / 100.00 
		END
	,RetailPrice = 
		CASE 
			WHEN ISNULL(RetailPrice, 0) = 0 THEN 0 
			ELSE RetailPrice / 100.00 
		END

UPDATE @Charges 
SET Amount = 
	CASE 
		WHEN ISNULL(Amount, 0) = 0 THEN 0 
		ELSE Amount / 100.00 
	END

DECLARE @LogId INT

SELECT @LogId = intImportLogId 
FROM tblICImportLog 
WHERE strUniqueId = (SELECT TOP 1 strUniqueId FROM tblICEdiPricebook)

IF(@LogId IS NULL)
BEGIN
	INSERT INTO tblICImportLog(strDescription, strType, strFileType, strFileName, dtmDateImported, intUserEntityId, intConcurrencyId)
	SELECT 'Import Receipts successful', 'EDI', @strFileType, @strFileName, GETDATE(), @UserId, 1
	SET @LogId = @@IDENTITY
END

--DELETE FROM tblICEdiMap WHERE UniqueId = @UniqueId

-- It's needed to increment each store indices by 1 since the reset file index is now based on the invoice record.
-- Need to equalize file indices of all groupings
UPDATE @Stores SET FileIndex = FileIndex + 1

-- Regenerate missing stores using a default store. The number of invoices should be equal to the number of stores.
INSERT INTO @Stores(
	FileIndex
	, RecordIndex
	, RecordType
	, StoreNumber
)

SELECT 
	missing.FileIndex
	, -1
	, '0'
	, CAST(st.intStoreNo AS NVARCHAR(500))
FROM 
	tblSTStore st
	INNER JOIN @StoreLocations sl ON sl.intCompanyLocationId = st.intCompanyLocationId
	CROSS JOIN (
		SELECT FileIndex FROM @Invoices
		EXCEPT
		SELECT FileIndex FROM @Stores
	) missing

DEClARE @ReceiptStagingTable ReceiptStagingTable
DECLARE @ReceiptOtherChargesTable ReceiptOtherChargesTableType
DECLARE @ReceiptItemLotStagingTable ReceiptItemLotStagingTable

DECLARE @ReceiptStore TABLE(
	FileIndex INT
	, RecordIndex INT
	, RecordType NVARCHAR(50)
	, StoreNumber NVARCHAR(50)
	, intStoreId INT
	, intLocationId INT
)

INSERT INTO @ReceiptStore(
	FileIndex
	, RecordIndex
	, RecordType
	, StoreNumber
	, intStoreId
	, intLocationId
)
SELECT 
	s.FileIndex
	, s.RecordIndex
	, s.RecordType
	, s.StoreNumber
	, st.intStoreId
	, st.intCompanyLocationId
FROM 
	@Stores s INNER JOIN tblSTStore st 
		ON st.intStoreNo = CAST(s.StoreNumber AS INT)
WHERE 
	CAST(s.StoreNumber AS INT) = st.intStoreNo

/**********************************************************************************************
	BEGIN VALIDATION
**********************************************************************************************/
BEGIN 
	-- Log UPCs that don't have corresponding items
	INSERT INTO tblICImportLogDetail(
		intImportLogId
		, strType
		, intRecordNo
		, strField
		, strValue
		, strMessage
		, strStatus
		, strAction
		, intConcurrencyId
	)
	SELECT 
		@LogId
		, 'Warning'
		, i.RecordIndex
		, 'Item UPC'
		, i.ItemUpc
		, 'Cannot find the item that matches the UPC or Vendor Item Code Xref.: ' + i.ItemUpc
		, 'Imported'
		, 'Record imported.'
		, 1
	FROM 
		@Items i INNER JOIN @Invoices inv
			ON i.FileIndex = inv.FileIndex
		CROSS APPLY (
			SELECT TOP 1 
				v.*
			FROM 
				vyuAPVendor v 
			WHERE 			
				v.intEntityId = @VendorId
				OR (
					SUBSTRING(v.strVendorAccountNum, PATINDEX('%[^0]%', v.strVendorAccountNum), LEN(v.strVendorAccountNum)) =
					SUBSTRING(inv.VendorCode, PATINDEX('%[^0]%', inv.VendorCode), LEN(inv.VendorCode))
					COLLATE SQL_Latin1_General_CP1_CS_AS
					AND @VendorId IS NULL 
				)
		) v
		OUTER APPLY (
			SELECT 
				intItemId = COALESCE(itemBasedOnUpcCode.intItemId, itemBasedOnVendorItemNo.intItemId) 
			FROM (
				SELECT TOP 1 
					it.intItemId
				FROM 
					tblICItemUOM u INNER JOIN tblICItem it 
						ON it.intItemId = u.intItemId
				WHERE
					SUBSTRING(ISNULL(u.strLongUPCCode, u.strUpcCode), PATINDEX('%[^0]%', ISNULL(u.strLongUPCCode, u.strUpcCode)+'.'), LEN(ISNULL(u.strLongUPCCode, u.strUpcCode)))
					= SUBSTRING(i.ItemUpc, PATINDEX('%[^0]%', i.ItemUpc+'.'), LEN(i.ItemUpc))		
			) itemBasedOnUpcCode
			FULL OUTER JOIN (
				SELECT TOP 1 
					item.intItemId
				FROM
					tblICItem item INNER JOIN tblICItemVendorXref xref
						ON item.intItemId = xref.intItemId
					INNER JOIN tblAPVendor vendor
						ON vendor.intEntityId = xref.intVendorId
					INNER JOIN tblEMEntity e
						ON e.intEntityId = vendor.intEntityId
				WHERE					
					e.intEntityId = v.intEntityId
					AND (
						SUBSTRING(xref.strVendorProduct , PATINDEX('%[^0]%', xref.strVendorProduct +'.'), LEN(xref.strVendorProduct))					
						= SUBSTRING(i.ItemUpc, PATINDEX('%[^0]%', i.ItemUpc+'.'), LEN(i.ItemUpc))			
					)
			) itemBasedOnVendorItemNo
				ON 1 = 1
		) it
	WHERE 
		it.intItemId IS NULL

	-- Log items with invalid locations
	INSERT INTO tblICImportLogDetail(
		intImportLogId
		, strType
		, intRecordNo
		, strField
		, strValue
		, strMessage
		, strStatus
		, strAction
		, intConcurrencyId
	)
	SELECT 
		@LogId
		, 'Warning'
		, i.RecordIndex
		, 'Item Location'
		, i.ItemUpc
		, 'Item: ' + i.ItemUpc + ' does not belong to store location: ' + st.StoreNumber
		, 'Imported'
		, 'Record imported.'
		, 1
	FROM 
		@Invoices inv INNER JOIN @ReceiptStore st 
			ON inv.FileIndex = st.FileIndex
		INNER JOIN @Items i 
			ON i.FileIndex = inv.FileIndex
		CROSS APPLY (
			SELECT TOP 1 
				v.*
			FROM 
				vyuAPVendor v 
			WHERE 			
				v.intEntityId = @VendorId
				OR (
					SUBSTRING(v.strVendorAccountNum, PATINDEX('%[^0]%', v.strVendorAccountNum), LEN(v.strVendorAccountNum)) =
					SUBSTRING(inv.VendorCode, PATINDEX('%[^0]%', inv.VendorCode), LEN(inv.VendorCode))
					COLLATE SQL_Latin1_General_CP1_CS_AS
					AND @VendorId IS NULL 
				)
		) v
		CROSS APPLY (
			SELECT 
				intItemId = COALESCE(itemBasedOnUpcCode.intItemId, itemBasedOnVendorItemNo.intItemId) 
			FROM (
				SELECT TOP 1 
					it.intItemId
				FROM 
					tblICItemUOM u INNER JOIN tblICItem it 
						ON it.intItemId = u.intItemId
				WHERE
					SUBSTRING(ISNULL(u.strLongUPCCode, u.strUpcCode), PATINDEX('%[^0]%', ISNULL(u.strLongUPCCode, u.strUpcCode)+'.'), LEN(ISNULL(u.strLongUPCCode, u.strUpcCode)))
					= SUBSTRING(i.ItemUpc, PATINDEX('%[^0]%', i.ItemUpc+'.'), LEN(i.ItemUpc))		
			) itemBasedOnUpcCode
			FULL OUTER JOIN (
				SELECT TOP 1 
					item.intItemId
				FROM
					tblICItem item INNER JOIN tblICItemVendorXref xref
						ON item.intItemId = xref.intItemId
					INNER JOIN tblAPVendor vendor
						ON vendor.intEntityId = xref.intVendorId
					INNER JOIN tblEMEntity e
						ON e.intEntityId = vendor.intEntityId
				WHERE					
					e.intEntityId = v.intEntityId
					AND (
						SUBSTRING(xref.strVendorProduct , PATINDEX('%[^0]%', xref.strVendorProduct +'.'), LEN(xref.strVendorProduct))					
						= SUBSTRING(i.ItemUpc, PATINDEX('%[^0]%', i.ItemUpc+'.'), LEN(i.ItemUpc))			
					)
			) itemBasedOnVendorItemNo
				ON 1 = 1
		) lookupUom
		LEFT JOIN tblICItemLocation il 
			ON il.intItemId = lookupUom.intItemId
			AND il.intLocationId = st.intLocationId
	WHERE 
		il.intLocationId IS NULL

	-- Log item with invalid UOM setup. 
	INSERT INTO tblICImportLogDetail(
		intImportLogId
		, strType
		, intRecordNo
		, strField
		, strValue
		, strMessage
		, strStatus
		, strAction
		, intConcurrencyId
	)
	SELECT 
		@LogId
		, 'Error'
		, i.RecordIndex
		, 'Unit of Measure'
		, i.UnitOfMeasure
		, 'UOM: ' + i.UnitOfMeasure + ' in Item UPC: ' + i.ItemUpc + ' is missing or Stock Unit is not set in the Item Setup.'
		, 'Failed'
		, 'Record not imported.'
		, 1
	FROM 
		@Invoices inv INNER JOIN @ReceiptStore st 
			ON inv.FileIndex = st.FileIndex
		CROSS APPLY (
			SELECT TOP 1 
				v.*
			FROM 
				vyuAPVendor v 
			WHERE 			
				v.intEntityId = @VendorId
				OR (
					SUBSTRING(v.strVendorAccountNum, PATINDEX('%[^0]%', v.strVendorAccountNum), LEN(v.strVendorAccountNum)) =
					SUBSTRING(inv.VendorCode, PATINDEX('%[^0]%', inv.VendorCode), LEN(inv.VendorCode))
					COLLATE SQL_Latin1_General_CP1_CS_AS
					AND @VendorId IS NULL 
				)
		) v		
		INNER JOIN @Items i 
			ON i.FileIndex = inv.FileIndex
		CROSS APPLY (
			SELECT 
				intItemId = COALESCE(itemBasedOnUpcCode.intItemId, itemBasedOnVendorItemNo.intItemId, itemNotFound.intItemId) 
			FROM 
				(
					SELECT TOP 1 
						item.intItemId
					FROM 
						tblICItemUOM lookupUom INNER JOIN tblICItem item
							ON item.intItemId = lookupUom.intItemId			
					WHERE
						SUBSTRING(ISNULL(lookupUom.strLongUPCCode, lookupUom.strUpcCode), PATINDEX('%[^0]%', ISNULL(lookupUom.strLongUPCCode, lookupUom.strUpcCode)+'.'), LEN(ISNULL(lookupUom.strLongUPCCode, lookupUom.strUpcCode)))
						= SUBSTRING(i.ItemUpc, PATINDEX('%[^0]%', i.ItemUpc+'.'), LEN(i.ItemUpc))
				) itemBasedOnUpcCode
				FULL OUTER JOIN (
					SELECT TOP 1 
						item.intItemId
					FROM
						tblICItem item INNER JOIN tblICItemVendorXref xref
							ON item.intItemId = xref.intItemId
						INNER JOIN tblAPVendor vendor
							ON vendor.intEntityId = xref.intVendorId
						INNER JOIN tblEMEntity e
							ON e.intEntityId = vendor.intEntityId
					WHERE					
						e.intEntityId = v .intEntityId 
						AND (
							SUBSTRING(xref.strVendorProduct , PATINDEX('%[^0]%', xref.strVendorProduct +'.'), LEN(xref.strVendorProduct))					
							= SUBSTRING(i.ItemUpc, PATINDEX('%[^0]%', i.ItemUpc+'.'), LEN(i.ItemUpc))			
						)
				) itemBasedOnVendorItemNo
					ON 1 = 1
				FULL OUTER JOIN (
					SELECT TOP 1 
						item.intItemId
					FROM 
						tblICItem item inner join tblICCompanyPreference pref
							ON item.intItemId = pref.intItemIdHolderForReceiptImport
				) itemNotFound
					ON 1 = 1 
		) it
		LEFT OUTER JOIN tblICItemUOM stockUnit 
			ON stockUnit.intItemId = it.intItemId
			AND stockUnit.ysnStockUnit = 1
		LEFT JOIN tblICUnitMeasure symbolUOM 
			ON symbolUOM.strSymbol = i.UnitOfMeasure
		LEFT JOIN tblICItemUOM symbolItemUOM 
			ON symbolItemUOM.intItemId = it.intItemId
			AND symbolItemUOM.intUnitMeasureId = symbolUOM.intUnitMeasureId
	WHERE
		symbolItemUOM.intItemUOMId IS NULL 
		AND stockUnit.intItemUOMId IS NULL 

	-- Log error for invalid vendor. 
	INSERT INTO tblICImportLogDetail(
		intImportLogId
		, strType
		, intRecordNo
		, strField
		, strValue
		, strMessage
		, strStatus
		, strAction
		, intConcurrencyId
	)
	SELECT 
		@LogId
		, 'Error'
		, i.RecordIndex
		, 'Vendor Code'
		, inv.VendorCode
		, 'Vendor Account No.: ' + inv.VendorCode + ' is not found in the Vendor setup.'
		, 'Failed'
		, 'Record not imported.'
		, 1
	FROM 
		@Items i INNER JOIN @Invoices inv
			ON i.FileIndex = inv.FileIndex
		OUTER APPLY (
			SELECT TOP 1 
				v.*
			FROM 
				vyuAPVendor v 
			WHERE 			
				v.intEntityId = @VendorId
				OR (
					SUBSTRING(v.strVendorAccountNum, PATINDEX('%[^0]%', v.strVendorAccountNum), LEN(v.strVendorAccountNum)) =
					SUBSTRING(inv.VendorCode, PATINDEX('%[^0]%', inv.VendorCode), LEN(inv.VendorCode))
					COLLATE SQL_Latin1_General_CP1_CS_AS
					AND @VendorId IS NULL 
				)
		) v		
	WHERE 
		v.intEntityId IS NULL 

	IF EXISTS (SELECT TOP 1 1 FROM tblICImportLogDetail WHERE intImportLogId = @LogId AND strType = 'Error' AND strStatus = 'Failed') 
	BEGIN 
		GOTO LogErrors
	END 
END 
/**********************************************************************************************
	END VALIDATION
**********************************************************************************************/

-- Populate receipt staging table
INSERT INTO @ReceiptStagingTable(
	strReceiptType
	, intEntityVendorId
	, intShipFromId
	, intLocationId
	, dtmDate
	, intSourceId
	, intItemId
	, intItemLocationId
	, intItemUOMId
	, dblQty
	, dblCost
	, intCostUOMId
	, intSourceType
	, strVendorRefNo
	, intCurrencyId
	, intShipViaId
	, dblUnitRetail
	, intSort
	, strImportDescription
	, strDataSource
)
SELECT 
	strReceiptType = 'Direct' 
	,intEntityVendorId = v.intEntityId 
	,intShipFromId = el.intEntityLocationId 
	,intLocationId = st.intLocationId 
	,dtmDate = CASE WHEN ISDATE(inv.InvoiceDate) = 1 THEN CAST(inv.InvoiceDate AS DATETIME) ELSE NULL END
	,intSourceId = 0 
	,intItemId = it.intItemId 
	,intItemLocationId = ISNULL(il.intItemLocationId, -1) 
	,intItemUOMId = ISNULL(symbolItemUOM.intItemUOMId, stockUnit.intItemUOMId) 
	,dblQuantity = 
		CASE 
			WHEN i.UnitMultiplier > 1 AND symbolItemUOM.intItemUOMId IS NULL THEN i.Quantity * i.UnitMultiplier 
			ELSE i.Quantity 
		END 
	,dblCost = 
		COALESCE(
			NULLIF(CASE WHEN i.UnitMultiplier > 1 THEN i.UnitCost / i.UnitMultiplier ELSE NULL END, 0) 
			, NULLIF(i.UnitCost, 0)
			, dbo.fnCalculateCostBetweenUOM(
				stockUnit.intItemUOMId
				,ISNULL(symbolItemUOM.intItemUOMId, stockUnit.intItemUOMId) 
				,COALESCE(NULLIF(pricing.dblLastCost, 0), NULLIF(pricing.dblStandardCost, 0))
			)
			, 0
		) 

	,intCostUOMId = ISNULL(symbolItemUOM.intItemUOMId, stockUnit.intItemUOMId) 
	,intSourceType = 0
	,strVendorRefNo = inv.InvoiceNumber
	,intCurrencyId = v.intCurrencyId 
	,intShipVia = el.intShipViaId
	,dblUnitRetail = 
		COALESCE(
			NULLIF(CASE WHEN i.UnitMultiplier > 1 THEN i.RetailPrice / i.UnitMultiplier ELSE NULL END, 0) 
			, NULLIF(i.RetailPrice, 0)
			, dbo.fnCalculateCostBetweenUOM(
				stockUnit.intItemUOMId
				,ISNULL(symbolItemUOM.intItemUOMId, stockUnit.intItemUOMId) 
				,NULLIF(pricing.dblSalePrice, 0)
			)
			, 0
		) 
	,intSort = i.RecordIndex
	,strImportDescription = i.ItemDescription
	,strDataSource = 'EdiGenerateReceipt'
FROM 
	@Invoices inv INNER JOIN @ReceiptStore st 
		ON inv.FileIndex = st.FileIndex
	CROSS APPLY (
		SELECT TOP 1 
			v.*
		FROM 
			vyuAPVendor v 
		WHERE 			
			v.intEntityId = @VendorId
			OR (
				SUBSTRING(v.strVendorAccountNum, PATINDEX('%[^0]%', v.strVendorAccountNum), LEN(v.strVendorAccountNum)) =
				SUBSTRING(inv.VendorCode, PATINDEX('%[^0]%', inv.VendorCode), LEN(inv.VendorCode))
				COLLATE SQL_Latin1_General_CP1_CS_AS
				AND @VendorId IS NULL 
			)
	) v
	INNER JOIN @Items i 
		ON i.FileIndex = inv.FileIndex
	CROSS APPLY (
		SELECT 
			intItemId = COALESCE(itemBasedOnUpcCode.intItemId, itemBasedOnVendorItemNo.intItemId, itemNotFound.intItemId) 
		FROM 
			(
				SELECT TOP 1 
					item.intItemId
				FROM 
					tblICItemUOM lookupUom INNER JOIN tblICItem item
						ON item.intItemId = lookupUom.intItemId			
				WHERE
					SUBSTRING(ISNULL(lookupUom.strLongUPCCode, lookupUom.strUpcCode), PATINDEX('%[^0]%', ISNULL(lookupUom.strLongUPCCode, lookupUom.strUpcCode)+'.'), LEN(ISNULL(lookupUom.strLongUPCCode, lookupUom.strUpcCode)))
					= SUBSTRING(i.ItemUpc, PATINDEX('%[^0]%', i.ItemUpc+'.'), LEN(i.ItemUpc))
			) itemBasedOnUpcCode
			FULL OUTER JOIN (
				SELECT TOP 1 
					item.intItemId
				FROM
					tblICItem item INNER JOIN tblICItemVendorXref xref
						ON item.intItemId = xref.intItemId
					INNER JOIN tblAPVendor vendor
						ON vendor.intEntityId = xref.intVendorId
					INNER JOIN tblEMEntity e
						ON e.intEntityId = vendor.intEntityId
				WHERE					
					e.intEntityId = v .intEntityId 
					AND (
						SUBSTRING(xref.strVendorProduct , PATINDEX('%[^0]%', xref.strVendorProduct +'.'), LEN(xref.strVendorProduct))					
						= SUBSTRING(i.ItemUpc, PATINDEX('%[^0]%', i.ItemUpc+'.'), LEN(i.ItemUpc))			
					)
			) itemBasedOnVendorItemNo
				ON 1 = 1
			FULL OUTER JOIN (
				SELECT TOP 1 
					item.intItemId
				FROM 
					tblICItem item inner join tblICCompanyPreference pref
						ON item.intItemId = pref.intItemIdHolderForReceiptImport
			) itemNotFound
				ON 1 = 1 
	) it
	LEFT OUTER JOIN tblEMEntityLocation el 
		ON el.intEntityId = v.intEntityId
		AND el.ysnActive = 1
		AND el.intEntityLocationId = v.intDefaultLocationId
	LEFT JOIN tblICItemLocation il 
		ON il.intItemId = it.intItemId
		AND il.intLocationId = st.intLocationId
	LEFT OUTER JOIN tblICItemUOM stockUnit 
		ON stockUnit.intItemId = it.intItemId
		AND stockUnit.ysnStockUnit = 1
	LEFT JOIN tblICUnitMeasure symbolUOM 
		ON symbolUOM.strSymbol = i.UnitOfMeasure
	LEFT JOIN tblICItemUOM symbolItemUOM 
		ON symbolItemUOM.intItemId = it.intItemId
		AND symbolItemUOM.intUnitMeasureId = symbolUOM.intUnitMeasureId
	OUTER APPLY (
		SELECT TOP 1 *
		FROM 
			tblICItemPricing p
		WHERE
			p.intItemId = it.intItemId
			AND p.intItemLocationId = il.intItemLocationId
	) pricing
ORDER BY 
	i.RecordIndex ASC

INSERT INTO @ReceiptOtherChargesTable(
	intEntityVendorId
	, strReceiptType
	, intLocationId
	, intShipViaId
	, intShipFromId
	, intCurrencyId
	, intChargeId
	, strCostMethod
	, dblAmount
)
SELECT 
	intEntityVendorId = @VendorId 
	,strReceiptType = 'Direct'
	,intLocationId = st.intLocationId 
	,intShipViaId = v.intShipViaId 
	,intShipFromId = el.intEntityLocationId
	,intCurrencyId = v.intCurrencyId
	,intChargeId = i.intItemId
	,strCostMethod = 'Amount'
	,dblAmount = c.Amount
FROM 
	@Charges c INNER JOIN @ReceiptStore st	
		ON c.FileIndex = st.FileIndex
	INNER JOIN @Invoices inv 
		ON inv.FileIndex = c.FileIndex
	INNER JOIN tblICItem i 
		ON i.strItemNo = c.ItemDescription
	CROSS APPLY (
		SELECT TOP 1 
			v.*
		FROM 
			vyuAPVendor v 
		WHERE 			
			v.intEntityId = @VendorId
			OR (
				SUBSTRING(v.strVendorAccountNum, PATINDEX('%[^0]%', v.strVendorAccountNum), LEN(v.strVendorAccountNum)) =
				SUBSTRING(inv.VendorCode, PATINDEX('%[^0]%', inv.VendorCode), LEN(inv.VendorCode))
				COLLATE SQL_Latin1_General_CP1_CS_AS
				AND @VendorId IS NULL 
			)
	) v	
	LEFT OUTER JOIN tblEMEntityLocation el 
		ON el.intEntityId = v.intEntityId
		AND el.ysnActive = 1
		AND el.intEntityLocationId = v.intDefaultLocationId
		AND ISNULL(c.Amount, 0) <> 0

IF EXISTS(SELECT * FROM @ReceiptStagingTable)
BEGIN 
	EXEC dbo.uspICAddItemReceipt 
		@ReceiptStagingTable
		, @ReceiptOtherChargesTable
		, @UserId
		, @ReceiptItemLotStagingTable
END
ELSE
BEGIN
	INSERT INTO tblICImportLogDetail(
		intImportLogId
		, strType
		, intRecordNo
		, strField
		, strValue
		, strMessage
		, strStatus
		, strAction
		, intConcurrencyId
	)
	SELECT 
		@LogId
		, 'Error'
		, -1
		, NULL
		, NULL
		, 'Unable to generate receipts. 
		Possible reasons: 
		<ul>
			<li>No store headers found in file and no selected location.</li>
			<li>Store headers found but the locations do not exists in the system.</li>
			<li>Vendor is invalid. The Vendor Account No. is not found in the system.</li>
			<li>Items are not in the store location(s).</li>
			<li>Placeholder item for Receipt Import is missing in the Company Configuration &#8594; Inventory.</li>
		</ul>
		'
		, 'Failed'
		, 'No record(s) imported.'
		, 1 
	GOTO LogErrors;
	RETURN
END

-- Log valid items
INSERT INTO tblICImportLogDetail(
	intImportLogId
	, strType
	, intRecordNo
	, strField
	, strValue
	, strMessage
	, strStatus
	, strAction
	, intConcurrencyId
)
SELECT 
	@LogId
	, 'Info'
	, rs.intSort
	, 'Receipt Item'
	, i.strItemNo
	, 'Import successful.'
	, 'Success'
	, 'Record inserted.'
	, 1
FROM 
	@ReceiptStagingTable rs	INNER JOIN tblICItem i 
		ON rs.intItemId = i.intItemId

LogErrors:

SELECT 
	@ErrorCount = COUNT(*) 
FROM 
	tblICImportLogDetail 
WHERE 
	intImportLogId = @LogId 
	AND strType IN ('Error') 

DECLARE @WarningCount AS INT = 0 
SELECT 
	@WarningCount = COUNT(*) 
FROM 
	tblICImportLogDetail 
WHERE 
	intImportLogId = @LogId 
	AND strType = 'Warning'

SELECT @TotalRows = COUNT(*) FROM @Items

DECLARE @TotalRowsImported INT
SELECT @TotalRowsImported = COUNT(*) FROM @ReceiptStagingTable

DECLARE @ElapsedInMs INT = DATEDIFF(MILLISECOND, @Start, DATEADD(SECOND, 3, GETDATE())) -- Add 3 seconds for importing to staging table
DECLARE @ElapsedInSec FLOAT = CAST(@ElapsedInMs / 1000.00 AS FLOAT)

IF @ErrorCount > 0 OR @WarningCount > 0 
BEGIN
	UPDATE tblICImportLog SET 
		strDescription = 
			dbo.fnICFormatErrorMessage (
				'Import finished with %i error(s) and %i warning(s).'
				,@ErrorCount 
				,@WarningCount 
				,DEFAULT 
				,DEFAULT 
				,DEFAULT 
				,DEFAULT 
				,DEFAULT 
				,DEFAULT 
				,DEFAULT 
				,DEFAULT 
			) 	
		,intTotalErrors = @ErrorCount
		,intTotalRows = @TotalRows
		,intTotalWarnings = @WarningCount
		,intRowsImported = @TotalRowsImported
		,dblTimeSpentInSeconds = @ElapsedInSec
		,intRowsUpdated = 0 
	WHERE 
		intImportLogId = @LogId
END

IF(@TotalRows = 0 AND @ErrorCount = 0 AND @WarningCount = 0)
BEGIN
	UPDATE tblICImportLog 
	SET 
		strDescription = 'There''s no record to import.' 
	WHERE 
		intImportLogId = @LogId	
END
ELSE
BEGIN
	IF @ErrorCount = 0 AND @WarningCount = 0 
	BEGIN
		UPDATE tblICImportLog SET 
			strDescription = 'Import Receipts successful.',
			intTotalErrors = @ErrorCount,
			intTotalRows = @TotalRows,
			intTotalWarnings = @WarningCount,
			intRowsImported = @TotalRowsImported,
			dblTimeSpentInSeconds = @ElapsedInSec,
			intRowsUpdated = 0 --CASE WHEN (@TotalRows - @ErrorCount) < 0 THEN 0 ELSE @TotalRows - @ErrorCount END
		WHERE 
			intImportLogId = @LogId	

		--INSERT INTO tblICImportLogDetail(intImportLogId, strType, intRecordNo, strField, strValue, strMessage, strStatus, strAction, intConcurrencyId)
		--SELECT @LogId, 'Info', 0, NULL, NULL, 'Import successful.', 'Success', 'Record inserted', 1
	END
END