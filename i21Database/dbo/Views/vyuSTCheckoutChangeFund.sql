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
			WHEN REPLACE(ITEM, '_ItemId', '') = 'FundIncreaseDecrease'
				THEN 'Change Fund Increase/Decrease'
		END COLLATE Latin1_General_CI_AS AS strType,
		CASE
			WHEN ITEM = 'BegBalance_ItemId'
				THEN 1
			WHEN ITEM = 'Replenishment_ItemId'
				THEN 2
			WHEN ITEM = 'EndBalance_ItemId'
				THEN 3
			WHEN ITEM = 'FundIncreaseDecrease_ItemId'
				THEN 4
		END AS intSequence,
		intItemId, 
		dblItemAmount
FROM 
(
	SELECT ch.intCheckoutId
		, ch.dblChangeFundBegBalance			AS BegBalance_Amount
		, ch.dblChangeFundEndBalance			AS EndBalance_Amount
		, ch.dblChangeFundChangeReplenishment	AS Replenishment_Amount
		, ch.dblChangeFundIncreaseDecrease		AS FundIncreaseDecrease_Amount
		, st.intChangeFundBegBalanceItemId		AS BegBalance_ItemId
		, st.intChangeFundEndBalanceItemId		AS EndBalance_ItemId
		, st.intChangeFundReplenishItemId		AS Replenishment_ItemId
		, -1									AS FundIncreaseDecrease_ItemId
	FROM tblSTCheckoutHeader ch
	INNER JOIN tblSTStore st
		ON ch.intStoreId = st.intStoreId
)t
unpivot
(
	intItemId for ITEM in (BegBalance_ItemId, EndBalance_ItemId, Replenishment_ItemId, FundIncreaseDecrease_ItemId)
) o
unpivot
(
	dblItemAmount for ITEMAMOUNT in (BegBalance_Amount, EndBalance_Amount, Replenishment_Amount, FundIncreaseDecrease_Amount)
) n
WHERE  REPLACE(ITEM, '_ItemId', '') = REPLACE(ITEMAMOUNT, '_Amount', '')