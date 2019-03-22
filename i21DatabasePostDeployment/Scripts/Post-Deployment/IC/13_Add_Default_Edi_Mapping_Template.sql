IF NOT EXISTS(SELECT * FROM tblICEdiMapTemplate WHERE strName = 'Inventory Receipts')
BEGIN

	DECLARE @dtmDateCreated DATETIME = GETDATE()

	INSERT INTO tblICEdiMapTemplate(strName, dtmDateCreated, intConcurrencyId)
	SELECT 'Inventory Receipts', @dtmDateCreated, 1

	INSERT INTO tblICEdiMapTemplateSegment(intEdiMapTemplateId, strKey, strName, intSequenceNo, strIdentifier, dtmDateCreated, intConcurrencyId)
	SELECT t.intEdiMapTemplateId, s.strKey, s.strName, s.intSequenceNo, s.strIdentifier, @dtmDateCreated, 1
	FROM (
		SELECT 'Store'   [strKey], 'Store Header'   [strName], 1 [intSequenceNo], '0' [strIdentifier] UNION
		SELECT 'Invoice' [strKey], 'Invoice Header' [strName], 2 [intSequenceNo], 'A' [strIdentifier] UNION
		SELECT 'Item'    [strKey], 'Item Details'   [strName], 3 [intSequenceNo], 'B' [strIdentifier] UNION
		SELECT 'Charge'  [strKey], 'Other Charges'  [strName], 4 [intSequenceNo], 'C' [strIdentifier]
	) s
	CROSS JOIN (
		SELECT t.intEdiMapTemplateId
		FROM tblICEdiMapTemplate t
		WHERE t.strName = 'Inventory Receipts'
	) t

	INSERT INTO tblICEdiMapTemplateSegmentDetail(intEdiMapTemplateSegmentId, strKey, strName, intIndex, intLength, strDataType, strDefaultValue, strFormat, dtmDateCreated, intConcurrencyId)
	SELECT s.intEdiMapTemplateSegmentId, d.strKey, d.strName, d.intIndex, d.intLength, d.strDataType, d.strDefaultValue, d.strFormat, @dtmDateCreated, 1
	FROM (
		SELECT '0' [strIdentifier], 'RecordType'      [strKey], 'Record Type'       [strName], 1  [intIndex], 1  [intLength], 'String'   [strDataType], '' [strDefaultValue], ''       [strFormat] UNION
		SELECT '0' [strIdentifier], 'StoreNumber'     [strKey], 'Store Number/ID'   [strName], 2  [intIndex], 7  [intLength], 'String'   [strDataType], '' [strDefaultValue], ''       [strFormat] UNION
												 								  		   				  						  											       
		SELECT 'A' [strIdentifier], 'RecordType'      [strKey], 'Record Type'       [strName], 1  [intIndex], 1  [intLength], 'String'   [strDataType], '' [strDefaultValue], ''       [strFormat] UNION
		SELECT 'A' [strIdentifier], 'VendorCode'      [strKey], 'Vendor Code'       [strName], 2  [intIndex], 6  [intLength], 'String'   [strDataType], '' [strDefaultValue], ''       [strFormat] UNION
		SELECT 'A' [strIdentifier], 'InvoiceNumber'   [strKey], 'Invoice Number'    [strName], 8  [intIndex], 10 [intLength], 'String'   [strDataType], '' [strDefaultValue], ''       [strFormat] UNION
		SELECT 'A' [strIdentifier], 'InvoiceDate'     [strKey], 'Invoice Date'      [strName], 18 [intIndex], 6  [intLength], 'DateTime' [strDataType], '' [strDefaultValue], 'MMddyy' [strFormat] UNION
		SELECT 'A' [strIdentifier], 'InvoiceTotal'    [strKey], 'Invoice Total'     [strName], 24 [intIndex], 10 [intLength], 'Decimal'  [strDataType], '' [strDefaultValue], ''       [strFormat] UNION
												  							    																							       
		SELECT 'B' [strIdentifier], 'RecordType'      [strKey], 'Record Type'       [strName], 1  [intIndex], 1  [intLength], 'String'   [strDataType], '' [strDefaultValue], ''       [strFormat] UNION
		SELECT 'B' [strIdentifier], 'ItemUPC'         [strKey], 'Item UPC'          [strName], 2  [intIndex], 11 [intLength], 'String'   [strDataType], '' [strDefaultValue], ''       [strFormat] UNION
		SELECT 'B' [strIdentifier], 'ItemDescription' [strKey], 'Item Description'  [strName], 13 [intIndex], 25 [intLength], 'String'   [strDataType], '' [strDefaultValue], ''       [strFormat] UNION
		SELECT 'B' [strIdentifier], 'VendorItemCode'  [strKey], 'Vendor Item Code'  [strName], 38 [intIndex], 6  [intLength], 'String'   [strDataType], '' [strDefaultValue], ''       [strFormat] UNION
		SELECT 'B' [strIdentifier], 'UnitCost'        [strKey], 'Unit Cost'         [strName], 44 [intIndex], 6  [intLength], 'Decimal'  [strDataType], '' [strDefaultValue], ''       [strFormat] UNION
		SELECT 'B' [strIdentifier], 'UnitOfMeasure'   [strKey], 'Unit of Measure'   [strName], 50 [intIndex], 2  [intLength], 'String'   [strDataType], '' [strDefaultValue], ''       [strFormat] UNION
		SELECT 'B' [strIdentifier], 'UnitMultiplier'  [strKey], 'Unit Multiplier'   [strName], 52 [intIndex], 6  [intLength], 'Decimal'  [strDataType], '' [strDefaultValue], ''       [strFormat] UNION
		SELECT 'B' [strIdentifier], 'Quantity'        [strKey], 'Quantity'          [strName], 58 [intIndex], 5  [intLength], 'Decimal'  [strDataType], '' [strDefaultValue], ''       [strFormat] UNION
		SELECT 'B' [strIdentifier], 'RetailPrice'     [strKey], 'RetailPrice'       [strName], 63 [intIndex], 5  [intLength], 'Decimal'  [strDataType], '' [strDefaultValue], ''       [strFormat] UNION
		SELECT 'B' [strIdentifier], 'PriceMulti-pack' [strKey], 'Price Multi-pack'  [strName], 68 [intIndex], 3  [intLength], 'Decimal'  [strDataType], '' [strDefaultValue], ''       [strFormat] UNION
		SELECT 'B' [strIdentifier], 'ParentItemCode'  [strKey], 'Parent Item Code'  [strName], 71 [intIndex], 6  [intLength], 'String'   [strDataType], '' [strDefaultValue], ''       [strFormat] UNION
																																											       
		SELECT 'C' [strIdentifier], 'RecordType'      [strKey], 'Record Type'       [strName], 1  [intIndex], 1  [intLength], 'String'   [strDataType], '' [strDefaultValue], ''       [strFormat] UNION
		SELECT 'C' [strIdentifier], 'ChargeType'      [strKey], 'Charge Type'       [strName], 2  [intIndex], 3  [intLength], 'String'   [strDataType], '' [strDefaultValue], ''       [strFormat] UNION
		SELECT 'C' [strIdentifier], 'ItemDescription' [strKey], 'Item Description'  [strName], 5  [intIndex], 25 [intLength], 'String'   [strDataType], '' [strDefaultValue], ''       [strFormat] UNION
		SELECT 'C' [strIdentifier], 'Amount'          [strKey], 'Amount'            [strName], 39 [intIndex], 6  [intLength], 'String'   [strDataType], '' [strDefaultValue], ''       [strFormat]
	) d
	LEFT OUTER JOIN (
		SELECT s.intEdiMapTemplateSegmentId, s.strIdentifier, s.strKey
		FROM tblICEdiMapTemplateSegment s
			INNER JOIN tblICEdiMapTemplate t ON t.intEdiMapTemplateId = s.intEdiMapTemplateId
		WHERE t.strName = 'Inventory Receipts'
	) s ON s.strIdentifier = d.strIdentifier
END

