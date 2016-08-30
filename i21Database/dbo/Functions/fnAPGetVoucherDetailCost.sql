CREATE FUNCTION [dbo].[fnAPGetVoucherDetailCost]
(
	@voucherDetailId INT
)
RETURNS DECIMAL(18,6)
AS
BEGIN
	DECLARE @cost DECIMAL(18,6);

	SELECT
		@cost = CASE WHEN B.intTransactionType = 2
					THEN	(A.dblCost / 
								(CASE WHEN A.ysnSubCurrency = 1 THEN B.intSubCurrencyCents ELSE 1 END) --check if sub currency
							) 
							*
							(
								(CASE WHEN A.dblUnitQty > 0 THEN A.dblUnitQty ELSE 1 END) --Contract already sent converted UOM unit qty
							)
					 ELSE
						 CASE WHEN A.dblNetWeight > 0 
								THEN
								(A.dblCost /
								(CASE WHEN A.ysnSubCurrency = 1 THEN B.intSubCurrencyCents ELSE 1 END)) 
								*
								(
									(CASE WHEN A.dblWeightUnitQty > 0 THEN A.dblWeightUnitQty ELSE 1 END) 
									/
									(CASE WHEN A.dblCostUnitQty > 0 THEN A.dblCostUnitQty ELSE 1 END)
								)
								ELSE
								(A.dblCost /
								(CASE WHEN A.ysnSubCurrency = 1 THEN B.intSubCurrencyCents ELSE 1 END)) 
								*
								(
									(CASE WHEN A.dblUnitQty > 0 THEN A.dblUnitQty ELSE 1 END) 
									/
									(CASE WHEN A.dblCostUnitQty > 0 THEN A.dblCostUnitQty ELSE 1 END)
								)
								END
					 END
	FROM tblAPBillDetail A
	INNER JOIN tblAPBill B ON A.intBillId = B.intBillId
	WHERE A.intBillDetailId = @voucherDetailId

	RETURN @cost;
END
