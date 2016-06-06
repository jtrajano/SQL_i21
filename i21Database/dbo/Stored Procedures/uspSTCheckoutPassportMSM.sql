


GO
CREATE PROCEDURE [dbo].[uspSTCheckoutPassportMSM]
@intCheckoutId Int
AS
BEGIN

    DECLARE @intStoreId int
    SELECT @intStoreId = intStoreId FROM dbo.tblSTCheckoutHeader WHERE intCheckoutId = @intCheckoutId


   -- Update dbo.tblSTCheckoutPaymentOptions
   -- SET dblRegisterAmount = chk.dblRegisterAmount  --SUM(ISNULL(CAST(chk.MiscellaneousSummaryAmount as decimal(18,6)) ,0))
   -- , intRegisterCount = chk.intRegisterCount --SUM(ISNULL(CAST(chk.MiscellaneousSummaryCount as int) ,0))
   -- FROM (SELECT SUM(ISNULL(CAST(MiscellaneousSummaryAmount as decimal(18,6)) ,0)) [dblRegisterAmount] 
			--, SUM(ISNULL(CAST(MiscellaneousSummaryCount as decimal(18,6)) ,0)) [intRegisterCount]
			--, TenderSubCode [TenderSubCode]
			--FROM #tempCheckoutInsert 
			--GROUP BY TenderSubCode
			--) chk
   -- JOIN tblSTPaymentOption PO ON PO.intRegisterMop = chk.TenderSubCode
   -- JOIN tblSTStore S ON S.intStoreId = PO.intStoreId
   -- WHERE S.intStoreId = @intStoreId AND intCheckoutId = @intCheckoutId AND tblSTCheckoutPaymentOptions.intPaymentOptionId = PO.intPaymentOptionId
       
    --Update dbo.tblSTCheckoutPaymentOptions
    --SET dblRegisterAmount = (ISNULL(CAST(chk.MiscellaneousSummaryAmount as decimal(18,6)) ,0))
    --, intRegisterCount = (ISNULL(CAST(chk.MiscellaneousSummaryCount as int) ,0))
    --FROM #tempCheckoutInsert chk
    ----JOIN tblSTPaymentOption PO ON PO.intRegisterMop = chk.TenderSubCode
    ----JOIN tblSTStore S ON S.intStoreId = PO.intStoreId
    --WHERE intCheckoutId = @intCheckoutId AND chk.MiscellaneousSummaryCode = 'sales' AND chk.MiscellaneousSummarySubCode = 'MOP' AND chk.MiscellaneousSummarySubCodeModifier = ''
    --AND intPaymentOptionId IN (SELECT intLotteryWinnersMopId FROM dbo.tblSTRegister Where intStoreId = @intStoreId)
       
    Update dbo.tblSTCheckoutPaymentOptions
    SET dblRegisterAmount = (ISNULL(CAST(chk.MiscellaneousSummaryAmount as decimal(18,6)) ,0))
    , intRegisterCount = (ISNULL(CAST(chk.MiscellaneousSummaryCount as int) ,0))
    FROM #tempCheckoutInsert chk
    --JOIN tblSTPaymentOption PO ON PO.intRegisterMop = chk.TenderSubCode
    --JOIN tblSTStore S ON S.intStoreId = PO.intStoreId
    WHERE intCheckoutId = @intCheckoutId AND chk.MiscellaneousSummaryCode = 'sales' AND chk.MiscellaneousSummarySubCode = 'MOP'
    AND intPaymentOptionId IN (SELECT intPaymentOptionId FROM dbo.tblSTPaymentOption Where intRegisterMop = chk.MiscellaneousSummarySubCodeModifier )

 
    UPDATE dbo.tblSTCheckoutHeader 
    SET dblCustomerCount = (SELECT SUM(CAST(MiscellaneousSummaryCount as int)) FROM #tempCheckoutInsert WHERE MiscellaneousSummaryCode = 'totalizer' AND MiscellaneousSummarySubCode = 'sales' AND MiscellaneousSummarySubCodeModifier = 'sales')  
    WHERE intCheckoutId = @intCheckoutId
    
    UPDATE dbo.tblSTCheckoutHeader 
    SET dblTotalTax = (SELECT SUM(CAST(MiscellaneousSummaryCount as int)) FROM #tempCheckoutInsert WHERE MiscellaneousSummaryCode = 'totalizer' AND MiscellaneousSummarySubCode = 'tax' AND MiscellaneousSummarySubCodeModifier = 'taxColl')  
    WHERE intCheckoutId = @intCheckoutId
          
    UPDATE dbo.tblSTCheckoutHeader 
    SET intTotalNoSalesCount = (SELECT SUM(CAST(MiscellaneousSummaryCount as int)) FROM #tempCheckoutInsert WHERE MiscellaneousSummaryCode = 'statistics' AND MiscellaneousSummarySubCode = 'noSales') 
    WHERE intCheckoutId = @intCheckoutId
       
    UPDATE dbo.tblSTCheckoutHeader 
    SET intFuelAdjustmentCount = (SELECT SUM(CAST(MiscellaneousSummaryCount as int)) FROM #tempCheckoutInsert WHERE MiscellaneousSummaryCode = 'statistics' AND MiscellaneousSummarySubCode ='driveOffs') 
    WHERE intCheckoutId = @intCheckoutId
       
    UPDATE dbo.tblSTCheckoutHeader 
    SET dblFuelAdjustmentAmount = (SELECT SUM(CAST(MiscellaneousSummaryAmount as decimal(18,6))) FROM #tempCheckoutInsert WHERE MiscellaneousSummaryCode = 'statistics' AND MiscellaneousSummarySubCode ='driveOffs') 
    WHERE intCheckoutId = @intCheckoutId
       
    UPDATE dbo.tblSTCheckoutHeader 
    SET intTotalRefundCount = (SELECT SUM(CAST(MiscellaneousSummaryCount as int)) FROM #tempCheckoutInsert WHERE MiscellaneousSummaryCode = 'refunds' AND MiscellaneousSummarySubCode ='total') 
    WHERE intCheckoutId = @intCheckoutId
       
    UPDATE dbo.tblSTCheckoutHeader 
    SET dblTotalRefundAmount = (SELECT SUM(CAST(MiscellaneousSummaryAmount as decimal(18,6))) FROM #tempCheckoutInsert WHERE MiscellaneousSummaryCode = 'refunds' AND MiscellaneousSummarySubCode ='total') 
    WHERE intCheckoutId = @intCheckoutId
       
    UPDATE dbo.tblSTCheckoutHeader 
    SET dblTotalPaidOuts = (SELECT SUM(CAST(MiscellaneousSummaryAmount as decimal(18,6))) FROM #tempCheckoutInsert WHERE MiscellaneousSummaryCode = 'payouts' AND MiscellaneousSummarySubCode ='total') 
    WHERE intCheckoutId = @intCheckoutId


END
