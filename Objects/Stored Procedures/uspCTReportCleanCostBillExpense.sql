CREATE PROCEDURE [dbo].[uspCTReportCleanCostBillExpense]
	
	@intCleanCostId INT = NULL
	
AS

BEGIN TRY
	
	DECLARE @ErrMsg NVARCHAR(MAX)
	
	 

	DECLARE		@strCleanCostCurrency	NVARCHAR(50),
				@strCleanCostUOM		NVARCHAR(50)
			
	SELECT		@strCleanCostCurrency	=	CY.strCurrency,
				@strCleanCostUOM		=	UM.strUnitMeasure
	FROM		tblCTCompanyPreference	CP
	LEFT JOIN	tblSMCurrency			CY	ON	CY.intCurrencyID	=	CP.intCleanCostCurrencyId
	LEFT JOIN	tblICUnitMeasure		UM	ON	UM.intUnitMeasureId	=	CP.intCleanCostUOMId
	
	SELECT		CB.*,
				ISNULL(IM.strItemNo,'Pre-Payment') strItemNo,
				OY.strCurrency strOtherCurrency,
				@strCleanCostCurrency strCleanCostCurrency,
				@strCleanCostUOM strCleanCostUOM
	FROM		tblCTCleanCostBillExpense CB
	LEFT JOIN	tblICItem		IM	ON	IM.intItemId		=	CB.intItemId
	LEFT JOIN	tblSMCurrency	OY	ON	OY.intCurrencyID	=	CB.intOtherCurrencyId
	WHERE		CB.intCleanCostId	=	@intCleanCostId
	
END TRY

BEGIN CATCH
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  	
END CATCH
GO