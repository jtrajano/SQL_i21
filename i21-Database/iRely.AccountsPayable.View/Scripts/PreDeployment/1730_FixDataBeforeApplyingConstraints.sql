--TEMPLATE

if not exists( SELECT  top 1 1  FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS WHERE CONSTRAINT_NAME ='FK_tblAPAppliedPreapaidAndDebit_intBillDetailApplied' )
BEGIN

	DECLARE @tbl TABLE(
		id int identity(1,1),
		strCurTab nvarchar(100),
		strCurCol nvarchar(100),
		strRelTab nvarchar(100),
		strRelCol nvarchar(100)    
	)

	INSERT INTO @tbl(strCurTab, strCurCol, strRelTab, strRelCol) SELECT 'tblAPAppliedPrepaidAndDebit', 'intBillDetailApplied', 'tblAPBillDetail', 'intBillDetailId'
	INSERT INTO @tbl(strCurTab, strCurCol, strRelTab, strRelCol) SELECT 'tblAPAppliedPrepaidAndDebit', 'intBillId', 'tblAPBill', 'intBillId'

	INSERT INTO @tbl(strCurTab, strCurCol, strRelTab, strRelCol) SELECT 'tblAPBill', 'intBankInfoId', 'tblCMBankAccount', 'intBankAccountId'
	INSERT INTO @tbl(strCurTab, strCurCol, strRelTab, strRelCol) SELECT 'tblAPBill', 'intPurchaseOrderId', 'tblPOPurchase', 'intPurchaseId'
	INSERT INTO @tbl(strCurTab, strCurCol, strRelTab, strRelCol) SELECT 'tblAPBill', 'intPayToAddressId', 'tblEMEntityLocation', 'intEntityLocationId'
	INSERT INTO @tbl(strCurTab, strCurCol, strRelTab, strRelCol) SELECT 'tblAPBill', 'intStoreLocationId', 'tblSMCompanyLocation', 'intCompanyLocationId'

	INSERT INTO @tbl(strCurTab, strCurCol, strRelTab, strRelCol) SELECT 'tblAPBillDetail', 'intUnitOfMeasureId', 'tblICItemUOM', 'intItemUOMId'
	INSERT INTO @tbl(strCurTab, strCurCol, strRelTab, strRelCol) SELECT 'tblAPBillDetail', 'intCostUOMId', 'tblICItemUOM', 'intItemUOMId'
	INSERT INTO @tbl(strCurTab, strCurCol, strRelTab, strRelCol) SELECT 'tblAPBillDetail', 'intWeightUOMId', 'tblICItemUOM', 'intItemUOMId'
	INSERT INTO @tbl(strCurTab, strCurCol, strRelTab, strRelCol) SELECT 'tblAPBillDetail', 'intInventoryReceiptItemId', 'tblICInventoryReceiptItem', 'intInventoryReceiptItemId'
	INSERT INTO @tbl(strCurTab, strCurCol, strRelTab, strRelCol) SELECT 'tblAPBillDetail', 'intPaycheckHeaderId', 'tblPRPaycheck', 'intPaycheckId'
	INSERT INTO @tbl(strCurTab, strCurCol, strRelTab, strRelCol) SELECT 'tblAPBillDetail', 'intPurchaseDetailId', 'tblPOPurchaseDetail', 'intPurchaseDetailId'
	INSERT INTO @tbl(strCurTab, strCurCol, strRelTab, strRelCol) SELECT 'tblAPBillDetail', 'intLoadDetailId', 'tblLGLoadDetail', 'intLoadDetailId'
	INSERT INTO @tbl(strCurTab, strCurCol, strRelTab, strRelCol) SELECT 'tblAPBillDetail', 'intLoadId', 'tblLGLoad', 'intLoadId'
 
	INSERT INTO @tbl(strCurTab, strCurCol, strRelTab, strRelCol) SELECT 'tblPOPurchase', 'intFreightTermId', 'tblSMFreightTerms', 'intFreightTermId'
	INSERT INTO @tbl(strCurTab, strCurCol, strRelTab, strRelCol) SELECT 'tblPOPurchase', 'intCurrencyId', 'tblSMCurrency', 'intCurrencyID'
	INSERT INTO @tbl(strCurTab, strCurCol, strRelTab, strRelCol) SELECT 'tblPOPurchase', 'intOrderById', 'tblEMEntity', 'intEntityId'
	INSERT INTO @tbl(strCurTab, strCurCol, strRelTab, strRelCol) SELECT 'tblPOPurchase', 'intLocationId', 'tblSMCompanyLocation', 'intCompanyLocationId'
	INSERT INTO @tbl(strCurTab, strCurCol, strRelTab, strRelCol) SELECT 'tblPOPurchase', 'intContractHeaderId', 'tblCTContractHeader', 'intContractHeaderId'

	INSERT INTO @tbl(strCurTab, strCurCol, strRelTab, strRelCol) SELECT 'tblPOPurchaseDetail', 'intItemId', 'tblICItem', 'intItemId'
	INSERT INTO @tbl(strCurTab, strCurCol, strRelTab, strRelCol) SELECT 'tblPOPurchaseDetail', 'intCostUOMId', 'tblICItemUOM', 'intItemUOMId'
	INSERT INTO @tbl(strCurTab, strCurCol, strRelTab, strRelCol) SELECT 'tblPOPurchaseDetail', 'intWeightUOMId', 'tblICItemUOM', 'intItemUOMId'
 
	INSERT INTO @tbl(strCurTab, strCurCol, strRelTab, strRelCol) SELECT 'tblAPVendor', 'intCurrencyId', 'tblSMCurrency', 'intCurrencyID'
	INSERT INTO @tbl(strCurTab, strCurCol, strRelTab, strRelCol) SELECT 'tblAPVendor', 'intPaymentMethodId', 'tblSMPaymentMethod', 'intPaymentMethodID'
	INSERT INTO @tbl(strCurTab, strCurCol, strRelTab, strRelCol) SELECT 'tblAPVendor', 'intBillToId', 'tblEMEntityLocation', 'intEntityLocationId'
	INSERT INTO @tbl(strCurTab, strCurCol, strRelTab, strRelCol) SELECT 'tblAPVendor', 'intShipFromId', 'tblEMEntityLocation', 'intEntityLocationId'

	INSERT INTO @tbl(strCurTab, strCurCol, strRelTab, strRelCol) SELECT 'tblAPVendorLien', 'intEntityLienId', 'tblEMEntity', 'intEntityId'
 
	INSERT INTO @tbl(strCurTab, strCurCol, strRelTab, strRelCol) SELECT 'tblAPVendorPricing', 'intEntityLocationId', 'tblEMEntityLocation', 'intEntityLocationId'  


	INSERT INTO @tbl(strCurTab, strCurCol, strRelTab, strRelCol) SELECT 'tblAPVendorTaxException', 'intItemId', 'tblICItem', 'intItemId'
	INSERT INTO @tbl(strCurTab, strCurCol, strRelTab, strRelCol) SELECT 'tblAPVendorTaxException', 'intCategoryId', 'tblICCategory', 'intCategoryId'
	INSERT INTO @tbl(strCurTab, strCurCol, strRelTab, strRelCol) SELECT 'tblAPVendorTaxException', 'intTaxCodeId', 'tblSMTaxCode', 'intTaxCodeId'
	INSERT INTO @tbl(strCurTab, strCurCol, strRelTab, strRelCol) SELECT 'tblAPVendorTaxException', 'intTaxClassId', 'tblSMTaxClass', 'intTaxClassId'
	INSERT INTO @tbl(strCurTab, strCurCol, strRelTab, strRelCol) SELECT 'tblAPVendorTaxException', 'intEntityVendorLocationId', 'tblEMEntityLocation', 'intEntityLocationId'
 


	DECLARE @CurrentTable nvarchar(100)
	DECLARE @CurrentColumn nvarchar(100)
	DECLARE @RelTable nvarchar(100)
	DECLARE @RelColumn nvarchar(100)
	DECLARE @id int

	WHILE EXISTS(SELECT TOP 1 1 FROM @tbl)
	BEGIN
		select top 1 
			@id = id ,
			@CurrentTable = strCurTab,
			@CurrentColumn = strCurCol,
			@RelTable = strRelTab,
			@RelColumn = strRelCol

		from @tbl
   
   
	   PRINT 'CHECKING TABLE ' + @CurrentTable + ' with column ' + @CurrentColumn + ' against table ' + @RelTable + ' for column ' + @RelColumn
   
		if EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = @CurrentTable and [COLUMN_NAME] = @CurrentColumn)
			AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = @RelTable and [COLUMN_NAME] = @RelColumn)
		BEGIN
			--PRINT 'CONSTRAINT [FK_' + @CurrentTable + '_' + @CurrentColumn + '] FOREIGN KEY ([' + @CurrentColumn  + ']) REFERENCES ' + @RelTable + '([' + @RelColumn + ']),'
			PRINT '---EXECUTE---'

			EXEC('
					DECLARE @NewCMD nvarchar(max)
					set @NewCMD = ''''
					SELECT @NewCMD = 
				''ALTER TABLE '' + R.TABLE_NAME + '' DROP CONSTRAINT ['' + R.CONSTRAINT_NAME + '']''
				
			FROM INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE U
			INNER JOIN INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS FK
				ON U.CONSTRAINT_CATALOG = FK.UNIQUE_CONSTRAINT_CATALOG
				AND U.CONSTRAINT_SCHEMA = FK.UNIQUE_CONSTRAINT_SCHEMA
				AND U.CONSTRAINT_NAME = FK.UNIQUE_CONSTRAINT_NAME
			INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE R
				ON R.CONSTRAINT_CATALOG = FK.CONSTRAINT_CATALOG
				AND R.CONSTRAINT_SCHEMA = FK.CONSTRAINT_SCHEMA
				AND R.CONSTRAINT_NAME = FK.CONSTRAINT_NAME
			WHERE U.TABLE_NAME = ''' + @CurrentTable + '''

					IF @NewCMD <> ''''
					BEGIN
						EXEC(@NewCMD)
					END
						
					ALTER TABLE ' + @CurrentTable + ' ALTER COLUMN ' + @CurrentColumn + ' INT NULL
					UPDATE ' + @CurrentTable + ' 
						set ' + @CurrentColumn + ' = null 
					WHERE ' + @CurrentColumn + ' not in (select ' + @RelColumn + ' from ' + @RelTable + ')
			')
		END 
		--ELSE
		--BEGIN
		--	PRINT 'CHECK ' + @CurrentTable + ' -- ' + @CurrentColumn + '--' + @RelTable + '--' + @RelColumn
		--END
		PRINT 'End CHECKING TABLE ' + @CurrentTable + ' with column ' + @CurrentColumn + ' against table ' + @RelTable + ' for column ' + @RelColumn
		delete from @tbl where id = @id

	END








END

