CREATE PROCEDURE [dbo].[uspCTReportCleanCostOtherExpense]
	
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
	
	SELECT		OB.*,
				ET.strExpenseDescription,
				OY.strCurrency strOtherCurrency,
				@strCleanCostCurrency strCleanCostCurrency,
				@strCleanCostUOM strCleanCostUOM
	FROM		tblCTCleanCostOtherExpense	OB
	LEFT JOIN	tblCTCleanCostExpenseType	ET	ON	ET.intExpenseTypeId	=	OB.intExpenseTypeId
	LEFT JOIN	tblSMCurrency				OY	ON	OY.intCurrencyID	=	OB.intOtherCurrencyId
	WHERE		OB.intCleanCostId	=	@intCleanCostId
	
END TRY

BEGIN CATCH
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')
END CATCH
GO