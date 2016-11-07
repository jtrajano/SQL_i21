CREATE VIEW [dbo].[vyuGRDiscountIdNotMapped]
AS
SELECT
 S.intDiscountId
,S.intCurrencyId
,ST.strCurrency	
FROM tblGRDiscountId S
JOIN tblSMCurrency ST ON ST.intCurrencyID = S.intCurrencyId