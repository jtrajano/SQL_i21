CREATE VIEW [dbo].[vyuSTCheckoutChangeFund]
AS 
SELECT DISTINCT 
		intCheckoutId,  
		CASE
			WHEN REPLACE(ITEM, '_ItemId', '') = 'BegBalance'
				THEN 'Change Fund Beg Balance'
			WHEN REPLACE(ITEM, '_ItemId', '') = 'EndBalance'
				THEN 'Change Fund End Balance'
			WHEN REPLACE(ITEM, '_ItemId', '') = 'Replenishment'
				THEN 'Change Fund Replenishment'
		END COLLATE Latin1_General_CI_AS AS strType,
		intItemId, 
		dblItemAmount
FROM 
(
	SELECT ch.intCheckoutId
		, ch.dblChangeFundBegBalance			AS BegBalance_Amount
		, ch.dblChangeFundEndBalance			AS EndBalance_Amount
		, ch.dblChangeFundChangeReplenishment	AS Replenishment_Amount

		, st.intChangeFundBegBalanceItemId		AS BegBalance_ItemId
		, st.intChangeFundEndBalanceItemId		AS EndBalance_ItemId
		, st.intChangeFundReplenishItemId		AS Replenishment_ItemId
	FROM tblSTCheckoutHeader ch
	INNER JOIN tblSTStore st
		ON ch.intStoreId = st.intStoreId
)t
unpivot
(
	intItemId for ITEM in (BegBalance_ItemId, EndBalance_ItemId, Replenishment_ItemId)
) o
unpivot
(
	dblItemAmount for ITEMAMOUNT in (BegBalance_Amount, EndBalance_Amount, Replenishment_Amount)
) n
WHERE  REPLACE(ITEM, '_ItemId', '') = REPLACE(ITEMAMOUNT, '_Amount', '')