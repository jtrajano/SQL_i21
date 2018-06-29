

GO
CREATE PROCEDURE [dbo].[uspSTCheckoutNucleusMSM]
@intCheckoutId Int
AS
BEGIN

    DECLARE @intStoreId int
    SELECT @intStoreId = intStoreId FROM dbo.tblSTCheckoutHeader WHERE intCheckoutId = @intCheckoutId

    Update dbo.tblSTCheckoutPaymentOptions
    SET dblRegisterAmount = ISNULL(CAST(chk.MiscellaneousSummaryAmount as decimal(18,6)) ,0)
    , dblAmount = ISNULL(CAST(chk.MiscellaneousSummaryAmount as decimal(18,6)) ,0)
    , intRegisterCount = ISNULL(CAST(chk.MiscellaneousSummaryCount as int) ,0)
    FROM #tempCheckoutInsert chk
    JOIN tblSTPaymentOption PO ON PO.intRegisterMop = chk.MiscellaneousSummarySubCodeModifier 
		AND chk.MiscellaneousSummaryCode = 'sales' AND chk.MiscellaneousSummarySubCode  = 'MOP'
    JOIN tblSTStore S ON S.intStoreId = PO.intStoreId
    WHERE S.intStoreId = @intStoreId AND intCheckoutId = @intCheckoutId AND tblSTCheckoutPaymentOptions.intPaymentOptionId = PO.intPaymentOptionId
       
    

END