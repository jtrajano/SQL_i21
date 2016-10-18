CREATE FUNCTION [dbo].[fnCTGetFranchiseReweights]
(
	@intContractDetailId	INT
)
RETURNS @returntable	TABLE
(
	dblQuantity				NUMERIC(18,6),
	dblValueInCCCurrency	NUMERIC(18,6),
	intCCCurrencyId			INT,
	dblValueInOtherCurrency	NUMERIC(18,6),
	intOtherCurrencyId		INT,
	strOtherCurrency		NVARCHAR(50)	
)
AS
BEGIN

	DECLARE @intCleanCostUOMId		INT,
			@intCleanCostCurrencyId	INT

	SELECT 	@intCleanCostUOMId		= intCleanCostUOMId , 
			@intCleanCostCurrencyId = intCleanCostCurrencyId 
	FROM	tblCTCompanyPreference

	INSERT	INTO @returntable
	SELECT	SUM(dblQuantity)dblQuantity,
			SUM(dblValueInCCCurrency)dblValueInCCCurrency,
			MAX(intCCCurrencyId)intCCCurrencyId,
			SUM(dblValueInOtherCurrency)dblValueInOtherCurrency,
			MAX(intOtherCurrencyId)intOtherCurrencyId,
			MAX(strOtherCurrency)strOtherCurrency
	FROM 
	(
		SELECT	dbo.fnCTConvertQuantityToTargetItemUOM(BD.intItemId,IU.intUnitMeasureId, @intCleanCostUOMId, BD.dblNetWeight) dblQuantity,
				CASE	WHEN	BL.intCurrencyId = @intCleanCostCurrencyId THEN BD.dblTotal * -1
						ELSE	CAST(NULL AS NUMERIC(18,0)) 
				END		AS		dblValueInCCCurrency,
				@intCleanCostCurrencyId intCCCurrencyId,
				CASE	WHEN	BL.intCurrencyId = @intCleanCostCurrencyId THEN CAST(NULL AS NUMERIC(18,0))
						ELSE	BD.dblTotal * -1
				END		AS		dblValueInOtherCurrency,
				CASE	WHEN	BL.intCurrencyId = @intCleanCostCurrencyId THEN CAST(NULL AS INT)
						ELSE	BL.intCurrencyId 
				END		AS		intOtherCurrencyId,
				CASE	WHEN	BL.intCurrencyId = @intCleanCostCurrencyId THEN ''
						ELSE	CU.strCurrency 
				END		AS		strOtherCurrency
		FROM	tblAPBillDetail		BD
		JOIN	tblAPBill			BL	ON	BL.intBillId		=	BD.intBillId		LEFT			
		JOIN	tblICItemUOM		IU	ON  IU.intItemUOMId		=   BD.intWeightUOMId	LEFT
        JOIN	tblSMCurrency       CU  ON  CU.intCurrencyID    =   BL.intCurrencyId
		WHERE	intTransactionType=	11	AND intContractDetailId =	@intContractDetailId
	)t

	RETURN;
END