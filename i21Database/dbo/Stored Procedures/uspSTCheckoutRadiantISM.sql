CREATE PROCEDURE [dbo].[uspSTCheckoutRadiantISM]
@intCheckoutId Int,
@strXML nvarchar(MAX)
AS
BEGIN

--START Convert XML to temporary table
If(OBJECT_ID('tempdb..#Temp') Is Not Null)
Begin
    Drop Table #Temp
End
create table #Temp
(
    strPOSCode NVARCHAR(100), 
    strInventoryItemID NVARCHAR(100), 
	strItemID NVARCHAR(100),
	strDescription NVARCHAR(100),
	intMerchandiseCode int, 

	dblActualSalesPrice decimal(18,6), 
    strReasonCode NVARCHAR(100),
    dblDiscountAmount decimal(18,6),
    intDiscountCount int, 
    dblPromotionAmount decimal(18,6), 
    intPromotionCount int,
	dblRefundAmount decimal(18,6),
	intRefundCount int,
	intSalesQuantity int,
	dblSalesAmount decimal(18,6),
	intTransactionCount int
)
--Replace single quote to double quote
SET @strXML = REPLACE(@strXML, '''','')

--start to convert XML string to XML
Declare @xml XML = @strXML
;WITH XMLNAMESPACES ('http://www.naxml.org/POSBO/Vocabulary/2003-10-16' as b)
INSERT INTO #Temp
SELECT
	 strPOSCode, 
      strInventoryItemID,
	  strItemID,
	  strDescription,
	  intMerchandiseCode,

    dblActualSalesPrice, 
    strReasonCode,
    dblDiscountAmount,
    intDiscountCount, 
    dblPromotionAmount, 
    intPromotionCount,
	dblRefundAmount,
	intRefundCount,
	intSalesQuantity,
	dblSalesAmount,
	intTransactionCount
FROM
(SELECT  
		ISNULL(x.u.value('(../b:ItemCode/b:POSCode)[1]', 'nvarchar(100)'), '') as strPOSCode,
		ISNULL(x.u.value('(../b:ItemCode/b:InventoryItemID )[1]', 'nvarchar(100)'), '') as strInventoryItemID,
		ISNULL(x.u.value('(../b:ItemID)[1]', 'nvarchar(100)'), '') as strItemID,
		ISNULL(x.u.value('(../b:Description)[1]', 'nvarchar(100)'), '') as strDescription,
		ISNULL(x.u.value('(../b:MerchandiseCode)[1]', 'int'), 0) as intMerchandiseCode,
		ISNULL(x.u.value('(b:ActualSalesPrice)[1]', 'decimal(18,6)'), 0) as dblActualSalesPrice,
		ISNULL(x.u.value('(b:ISMReasonCodeSummary/b:ReasonCode)[1]', 'nvarchar(50)'), '') as strReasonCode,
		ISNULL(x.u.value('(b:ISMReasonCodeSummary/b:ISMSalesTotals/b:DiscountAmount)[1]', 'decimal(18,6)'), ISNULL(x.u.value('(b:ISMSalesTotals/b:DiscountAmount)[1]', 'decimal(18,6)'), 0)) as dblDiscountAmount,
		ISNULL(x.u.value('(b:ISMReasonCodeSummary/b:ISMSalesTotals/b:DiscountCount)[1]', 'int'), ISNULL(x.u.value('(b:ISMSalesTotals/b:DiscountCount)[1]', 'int'), '')) as intDiscountCount,
		ISNULL(x.u.value('(b:ISMReasonCodeSummary/b:ISMSalesTotals/b:PromotionAmount)[1]', 'decimal(18,6)'), ISNULL(x.u.value('(b:ISMSalesTotals/b:PromotionAmount)[1]', 'decimal(18,6)'), 0)) as dblPromotionAmount,
		ISNULL(x.u.value('(b:ISMReasonCodeSummary/b:ISMSalesTotals/b:PromotionCount)[1]', 'int'), ISNULL(x.u.value('(b:ISMSalesTotals/b:PromotionCount)[1]', 'int'), 0)) as intPromotionCount,
		ISNULL(x.u.value('(b:ISMReasonCodeSummary/b:ISMSalesTotals/b:RefundAmount)[1]', 'decimal(18,6)'), ISNULL(x.u.value('(b:ISMSalesTotals/b:RefundAmount)[1]', 'decimal(18,6)'), 0)) as dblRefundAmount,
		ISNULL(x.u.value('(b:ISMReasonCodeSummary/b:ISMSalesTotals/b:RefundCount)[1]', 'int'), ISNULL(x.u.value('(b:ISMSalesTotals/b:RefundCount)[1]', 'int'), 0)) as intRefundCount,
		ISNULL(x.u.value('(b:ISMReasonCodeSummary/b:ISMSalesTotals/b:SalesQuantity)[1]', 'int'), ISNULL(x.u.value('(b:ISMSalesTotals/b:SalesQuantity)[1]', 'int'), 0)) as intSalesQuantity,
		ISNULL(x.u.value('(b:ISMReasonCodeSummary/b:ISMSalesTotals/b:SalesAmount)[1]', 'decimal(18,6)'), ISNULL(x.u.value('(b:ISMSalesTotals/b:SalesAmount)[1]', 'decimal(18,6)'), 0)) as dblSalesAmount,
		ISNULL(x.u.value('(b:ISMReasonCodeSummary/b:ISMSalesTotals/b:TransactionCount)[1]', 'int'), ISNULL(x.u.value('(b:ISMSalesTotals/b:TransactionCount)[1]', 'int'), 0)) as intTransactionCount
FROM    @xml.nodes('//b:ItemSalesMovement/b:ISMDetail/b:ISMSellPriceSummary') x(u)) as S
--END

	DECLARE @intStoreId Int, @strAllowRegisterMarkUpDown nvarchar(50), @intShiftNo int, @intMarkUpDownId int
	Select @intStoreId = intStoreId, @intShiftNo = intShiftNo from dbo.tblSTCheckoutHeader Where intCheckoutId = @intCheckoutId

	--INSERT INTO dbo.tblSTCheckoutItemMovements
	--SELECT DISTINCT @intCheckoutId 
	--, UOM.intItemUOMId
	--, I.strDescription
	--, IL.intVendorId
	--, ISNULL(CAST(Chk.SalesQuantity as int),0)
	--, ISNULL(CAST(Chk.ActualSalesPrice as decimal(18,6)),0)
	--, ISNULL(CAST(Chk.SalesAmount as decimal(18,6)),0)
	--, P.dblStandardCost
	--, 1
	--from #tempCheckoutInsert Chk
	--JOIN dbo.tblICItemUOM UOM ON Chk.POSCode COLLATE Latin1_General_CI_AS = UOM.strUpcCode
	--JOIN dbo.tblICItem I ON I.intItemId = UOM.intItemId
	--JOIN dbo.tblICItemLocation IL ON IL.intItemId = I.intItemId
	--JOIN dbo.tblICItemPricing P ON IL.intItemLocationId = P.intItemLocationId AND I.intItemId = P.intItemId
	--JOIN dbo.tblSMCompanyLocation CL ON CL.intCompanyLocationId = IL.intLocationId
	--JOIN dbo.tblSTStore S ON S.intCompanyLocationId = CL.intCompanyLocationId
	--WHERE S.intStoreId = @intStoreId


	--Removed DISTINCT
	INSERT INTO dbo.tblSTCheckoutItemMovements
	SELECT @intCheckoutId
	, UOM.intItemUOMId
	, I.strDescription
	, IL.intVendorId
	, ISNULL(CAST(Chk.intSalesQuantity as int),0)
	, ISNULL(CAST(Chk.dblActualSalesPrice as decimal(18,6)),0)
	, ISNULL(CAST(Chk.dblSalesAmount as decimal(18,6)),0)
	, P.dblStandardCost
	, 1
	from #Temp Chk
	JOIN dbo.tblICItemUOM UOM ON Chk.strPOSCode COLLATE Latin1_General_CI_AS = UOM.strUpcCode
	JOIN dbo.tblICItem I ON I.intItemId = UOM.intItemId
	JOIN dbo.tblICItemLocation IL ON IL.intItemId = I.intItemId
	JOIN dbo.tblICItemPricing P ON IL.intItemLocationId = P.intItemLocationId AND I.intItemId = P.intItemId
	JOIN dbo.tblSMCompanyLocation CL ON CL.intCompanyLocationId = IL.intLocationId
	JOIN dbo.tblSTStore S ON S.intCompanyLocationId = CL.intCompanyLocationId
	WHERE S.intStoreId = @intStoreId


	SELECT @strAllowRegisterMarkUpDown = strAllowRegisterMarkUpDown FROM dbo.tblSTStore Where intStoreId = @intStoreId
	IF(@strAllowRegisterMarkUpDown <> 'None')
	BEGIN

		--IF(@strAllowRegisterMarkUpDown = 'I')
	
		INSERT INTO dbo.tblSTMarkUpDown
		SELECT @intStoreId, GETDATE(), @intShiftNo
		, CASE WHEN S.strAllowRegisterMarkUpDown = 'I' THEN 'Item Level' 
				WHEN S.strAllowRegisterMarkUpDown = 'D' THEN 'Department Level'
		  END 
		, 'Regular'
		, 0
		FROM tblSTStore S WHERE intStoreId = @intStoreId

		SET @intMarkUpDownId = @@IDENTITY

		INSERT INTO dbo.tblSTMarkUpDownDetail
		SELECT @intMarkUpDownId
		, UOM.intItemUOMId
		, I.intCategoryId
		, '' [strMarkUpOrDown]
		, ISNULL(Chk.DiscountAmount, '') [strRetailShrinkRS]
		, CAST(Chk.SalesQuantity as int) [intQty]
		, CASE WHEN (SP.dtmBeginDate < GETDATE() AND SP.dtmEndDate > GETDATE()) THEN (ISNULL(CAST(Chk.ActualSalesPrice as decimal(18,6)), 0) - (ISNULL(SP.dblUnit ,0) / ISNULL(UOM.dblUnitQty, 1)) )
				ELSE (ISNULL(CAST(Chk.ActualSalesPrice as decimal(18,6)), 0) - (ISNULL(Pr.dblSalePrice ,0) / ISNULL(UOM.dblUnitQty, 1)) )
			END [dblRetailPerUnit]
		, 0 [dblTotalRetailAmount]
		, 0 [dblTotalCostAmount]
		, 'On Sale' [strNote]
		, 0 [dblActulaGrossProfit]
		, 0 [ysnSentToHost]
		, '' [strReason]
		, 0
		FROM #tempCheckoutInsert Chk
		JOIN dbo.tblICItemUOM UOM ON Chk.POSCode COLLATE Latin1_General_CI_AS = UOM.strUpcCode
		JOIN dbo.tblICItem I ON I.intItemId = UOM.intItemId
		JOIN dbo.tblICItemLocation IL ON IL.intItemId = I.intItemId
		Join dbo.tblICItemSpecialPricing SP ON I.intItemId = SP.intItemId AND IL.intItemLocationId = SP.intItemLocationId
		Join dbo.tblICItemPricing Pr ON Pr.intItemId = I.intItemId AND Pr.intItemLocationId = IL.intItemLocationId
		JOIN dbo.tblSMCompanyLocation CL ON CL.intCompanyLocationId = IL.intLocationId
		JOIN dbo.tblSTStore S ON S.intCompanyLocationId = CL.intCompanyLocationId
		WHERE S.intStoreId = @intStoreId

		UPDATE dbo.tblSTMarkUpDownDetail
		Set strMarkUpOrDown = (CASE WHEN dblRetailPerUnit > 0 THEN 'Mark Up' WHEN dblRetailPerUnit < 0 THEN 'Mark Down' END)
		, dblTotalRetailAmount = intQty * dblRetailPerUnit
		Where intMarkUpDownId = @intMarkUpDownId

		UPDATE dbo.tblSTMarkUpDownDetail
		SET strMarkUpOrDown = 'Mark Down' 
		Where strRetailShrinkRS <> ''

	END

END
