CREATE VIEW [dbo].[vyuGRDiscountIdNotMapped]
AS
SELECT
 DId.intDiscountId
,DId.intCurrencyId
,CUR.strCurrency	
FROM tblGRDiscountId DId
JOIN tblSMCurrency CUR ON CUR.intCurrencyID = DId.intCurrencyId