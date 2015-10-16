CREATE PROCEDURE [dbo].[uspSTstgInsertPricebookSendFile]
	@StoreLocation int
	, @Register int
	, @Category nvarchar(max)
	, @BeginingChangeDate Datetime
	, @EndingChangeDate Datetime
	, @ExportEntirePricebookFile bit
	, @strGenerateXML nvarchar(max) OUTPUT
	, @intImportFileHeaderId INT OUTPUT
AS
BEGIN
	
	DECLARE @XMLGatewayVersion nvarchar(100)
	SELECT @XMLGatewayVersion = dblXmlVersion FROM dbo.tblSTRegister WHERE intRegisterId = @Register

--Insert data into Procebook staging table	
	INSERT INTO tblSTstgPricebookSendFile
	SELECT 
		ST.intStoreNo [StoreLocationID]
		, 'iRely' [VendorName]  	
		, 'Rel. 13.2.0' [VendorModelVersion]
		, 'update' [TableActionType]
		, 'addchange' [RecordActionType] 
		, CONVERT(nvarchar(10), GETDATE(), 21) [RecordActionEffectiveDate]
		, CASE I.strStatus WHEN 'Active' THEN 'addchange' WHEN 'Phased Out' THEN 'delete' ELSE 'addchange' END as [ITTDetailRecordActionType] 
		, CASE WHEN ISNULL(ST.intMaxPlu,0) > ISNULL(CAST(IUOM.strUpcCode as int),0) THEN 'PLU' ELSE 'upcA' END [POSCodeFormatFormat]
		, CASE	WHEN ISNULL(ST.intMaxPlu,0) > ISNULL(CAST(IUOM.strUpcCode as int),0) THEN RIGHT('0000'+ISNULL(IUOM.strUpcCode,''),4) 
				ELSE RIGHT('00000000000'+ISNULL(IUOM.strLongUPCCode,''),11) 
			END [POSCode]
		, IUM.strUnitMeasure [PosCodeModifierName] 
		, '0' [PosCodeModifierValue] 
		, CASE I.strStatus WHEN 'Active' THEN 'yes' ELSE 'no' END as [ActiveFlagValue]
		, Prc.dblSalePrice [InventoryValuePrice]
		, Cat.strCategoryCode [MerchandiseCode]
		, CASE WHEN GETDATE() between SplPrc.dtmBeginDate AND SplPrc.dtmEndDate THEN SplPrc.dblUnitAfterDiscount 
			ELSE Prc.dblSalePrice END  [RegularSellPrice]
		, I.strDescription [Description]
		, 'item' [LinkCodeType]
		, NULL [LinkCodeValue]
		, CASE WHEN IL.intItemTypeCode = 0 THEN 1 WHEN (@XMLGatewayVersion = '3.30' AND IL.ysnCarWash = 1) 
			THEN 10 ElSE ISNULL(IL.intItemTypeCode,1) END [ItemTypeCode]
		, CASE WHEN IL.intItemTypeCode = 0 THEN 1 WHEN (@XMLGatewayVersion = '3.30' AND IL.ysnCarWash = 1) 
			THEN 1 ElSE ISNULL(IL.intItemTypeSubCode,1) END [ItemTypeSubCode]
		, CASE WHEN R.strRegisterClass = 'SAPPHIRE' 
					THEN CASE WHEN ISNULL(SubCat.strRegProdCode, '') = '' OR SubCat.strRegProdCode = 0 THEN 7 
						ELSE SubCat.strRegProdCode 
					END 
				ELSE  ISNULL(SubCat.strRegProdCode, '40') 
			END [PaymentSystemsProductCode]
		, CASE	WHEN IL.ysnFoodStampable = 1 THEN 4096 WHEN IL.ysnFoodStampable = 0 THEN 2048 
				WHEN IL.ysnIdRequiredLiquor = 1 THEN 4 WHEN IL.ysnIdRequiredCigarette = 1 THEN 2 
				WHEN IL.ysnOpenPricePLU = 1 THEN 128
				ELSE 2048
			END [SalesRestrictCode]
		, IUOM.dblUnitQty [SellingUnits]
		, CASE	WHEN IL.ysnTaxFlag1 = 1 THEN R.intTaxStrategyIdForTax1 WHEN IL.ysnTaxFlag2 = 1 THEN R.intTaxStrategyIdForTax2 
				WHEN IL.ysnTaxFlag3 = 1 THEN R.intTaxStrategyIdForTax3 WHEN IL.ysnTaxFlag4 = 1 THEN R.intTaxStrategyIdForTax4
				ELSE R.intNonTaxableStrategyId
			END [TaxStrategyID]	
		, 'ICR' [ProhibitSaleLocationType]	
		, CASE WHEN (@XMLGatewayVersion = '3.30' AND ISNULL(SubCat.strRegProdCode, '40') = '102') THEN 'No' 
				WHEN (@XMLGatewayVersion = '3.30' AND ISNULL(SubCat.strRegProdCode, '40') <> '102') THEN 'Yes' 
				WHEN (@XMLGatewayVersion = '3.41' AND IL.ysnCarWash = 1) THEN 'No' 
				WHEN (@XMLGatewayVersion = '3.41' AND IL.ysnCarWash = 0) THEN 'Yes' 
				ELSE 'Yes'
			END [ProhibitSaleLocationValue]	
		, CASE WHEN IL.ysnApplyBlueLaw1 = 1 THEN 110 ELSE NULL END [SalesRestrictionStrategyID]
		, 0 [PriceMethodCode]
		, IL.strDescription [ReceiptDescription]
		, IL.ysnFoodStampable [FoodStampableFlg]
		, IL.ysnPromotionalItem [DiscountableFlg]
		, IL.ysnQuantityRequired [QuantityRequiredFlg]
		, CASE WHEN R.strRegisterClass = 'SAPPHIRE' 
					THEN CASE WHEN R.strRegisterName = 'Sapphire' THEN RIGHT('0000000000000'+ISNULL(IUOM.strLongUPCCode,''),13) 
						WHEN R.strRegisterName = 'Commander' THEN 
							CASE WHEN ISNULL(ST.intMaxPlu,0) > ISNULL(CAST(IUOM.strUpcCode as int),0) 
								THEN IUOM.strUpcCode 
								ELSE RIGHT('0000000000000'+ISNULL(IUOM.strLongUPCCode,''),13) 
							END
					END 
				ELSE  NULL 
			END [UPCValue]
		, 'absent' [UPCCheckDigit]
		, 'keyboard' [UPCSource]
		, IL.intDepositPLUId [Fee]	
		, CASE WHEN IL.ysnPromotionalItem = 1 THEN '1' ELSE NULL END [FlagSysId1]
		, CASE WHEN IL.ysnSaleable = 0 THEN '2' ELSE NULL END [FlagSysId2]
		, CASE WHEN IL.ysnReturnable = 0 THEN '3' ELSE NULL END [FlagSysId3]
		, CASE WHEN IL.ysnFoodStampable = 1 THEN '4' ELSE NULL END [FlagSysId4]
		, CASE WHEN IL.ysnTaxFlag1 = 1 THEN '1' ELSE NULL END [TaxRateSysId1]
		, CASE WHEN IL.ysnTaxFlag2 = 1 THEN '2' ELSE NULL END [TaxRateSysId2]
		, CASE WHEN IL.ysnTaxFlag3 = 1 THEN '3' ELSE NULL END [TaxRateSysId3]
		, CASE WHEN IL.ysnTaxFlag4 = 1 THEN '4' ELSE NULL END [TaxRateSysId4]
		, CASE WHEN IL.ysnIdRequiredLiquor = 1 THEN '1' ELSE NULL END [IdCheckSysId1]
		, CASE WHEN IL.ysnIdRequiredCigarette = 1 THEN '2' ELSE NULL END [IdCheckSysId2]
		, CASE WHEN IL.ysnApplyBlueLaw1 = 1 THEN '1' ELSE NULL END [BlueLawSysId1]
		, CASE WHEN IL.ysnApplyBlueLaw2 = 1 THEN '2' ELSE NULL END [BlueLawSysId2]
	from tblICItem I
	JOIN tblICItemLocation IL ON IL.intItemId = I.intItemId
	JOIN tblSMCompanyLocation L ON L.intCompanyLocationId = IL.intLocationId
	JOIN tblICItemUOM IUOM ON IUOM.intItemId = I.intItemId 
	JOIN tblICUnitMeasure IUM ON IUM.intUnitMeasureId = IUOM.intUnitMeasureId 
	JOIN tblSTStore ST ON ST.intCompanyLocationId = L.intCompanyLocationId 
	JOIN tblICCategory Cat ON Cat.intCategoryId = I.intCategoryId
	LEFT JOIN tblSTSubcategoryRegProd SubCat ON SubCat.intStoreId = ST.intStoreId
	JOIN tblSTRegister R ON R.intStoreId = ST.intStoreId
	JOIN tblICItemPricing Prc ON Prc.intItemId = I.intItemId
	JOIN tblICItemSpecialPricing SplPrc ON SplPrc.intItemId = I.intItemId
	WHERE I.ysnFuelItem = 0 AND R.intRegisterId = @Register AND ST.intStoreId = @StoreLocation 
	AND ','+@Category +',' like '%,'+cast(Cat.intCategoryId as varchar(100))+',%'
	
	
	SELECT @intImportFileHeaderId = intImportFileHeaderId FROM dbo.tblSMImportFileHeader 
	Where strLayoutTitle = 'Pricebook File' AND strFileType = 'XML'
	
--Generate XML for the pricebook data availavle in staging table
	Exec dbo.uspSMGenerateDynamicXML @intImportFileHeaderId, 'tblSTstgPricebookSendFile~intPricebookSendFile > 0', 0, @strGenerateXML OUTPUT

--Once XML is generated delete the data from pricebook  staging table.
	DELETE FROM dbo.tblSTstgPricebookSendFile	
	
END