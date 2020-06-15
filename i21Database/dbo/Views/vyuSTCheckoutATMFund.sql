CREATE VIEW [dbo].[vyuSTCheckoutATMFund]
AS 
SELECT DISTINCT 
		intCheckoutId,  
		CASE
			WHEN REPLACE(ITEM, '_ItemId', '') = 'BegBalance'
				THEN 'ATM Beg Balance'
			WHEN REPLACE(ITEM, '_ItemId', '') = 'Withdrawal'
				THEN 'ATM Withdrawals'
			WHEN REPLACE(ITEM, '_ItemId', '') = 'Replenished'
				THEN 'ATM Replenishment'
			WHEN REPLACE(ITEM, '_ItemId', '') = 'EndBalanceActual'
				THEN 'ATM End Balance'
			WHEN REPLACE(ITEM, '_ItemId', '') = 'Variance'
				THEN 'ATM Variance'
		END COLLATE Latin1_General_CI_AS AS strType,
		intItemId, 
		dblItemAmount
FROM 
(
	SELECT ch.intCheckoutId
	, ch.dblATMBegBalance					AS BegBalance_Amount
	, ch.dblATMReplenished					AS Replenished_Amount
	, ch.dblATMWithdrawal					AS Withdrawal_Amount
	, ch.dblATMEndBalanceActual			AS EndBalanceActual_Amount
	, ch.dblATMVariance					AS Variance_Amount

	, st.intATMFundBegBalanceItemId	AS BegBalance_ItemId
	, st.intATMFundReplenishedItemId	AS Replenished_ItemId
	, st.intATMFundWithdrawalItemId	AS Withdrawal_ItemId
	, st.intATMFundEndBalanceItemId	AS EndBalanceActual_ItemId
	, st.intATMFundVarianceItemId		AS Variance_ItemId
FROM tblSTCheckoutHeader ch
INNER JOIN tblSTStore st
	ON ch.intStoreId = st.intStoreId
) t
unpivot
(
	intItemId for ITEM in (BegBalance_ItemId, Replenished_ItemId, Withdrawal_ItemId, EndBalanceActual_ItemId, Variance_ItemId)
) o
unpivot
(
	dblItemAmount for ITEMAMOUNT in (BegBalance_Amount, Replenished_Amount, Withdrawal_Amount, EndBalanceActual_Amount, Variance_Amount)
) n
WHERE  REPLACE(ITEM, '_ItemId', '') = REPLACE(ITEMAMOUNT, '_Amount', '')