GO
	PRINT 'START OF CREATING [uspTMRecreateBudgetCalculationItemPricingView] SP'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspTMRecreateBudgetCalculationItemPricingView]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].uspTMRecreateBudgetCalculationItemPricingView
GO

CREATE PROCEDURE uspTMRecreateBudgetCalculationItemPricingView 
AS
BEGIN
	IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuTMBudgetCalculationItemPricing')
	BEGIN
		DROP VIEW vyuTMBudgetCalculationItemPricing
	END

	IF ((SELECT TOP 1 ysnUseOriginIntegration FROM tblTMPreferenceCompany) = 1
		AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwitmmst') = 1
	)
	BEGIN
		EXEC ('
			CREATE VIEW [dbo].[vyuTMBudgetCalculationItemPricing]  
			AS 
				SELECT
					A.*
					,strItemNumber = A.strItemNo
				FROM dbo.tblTMBudgetCalculationItemPricing A
				
			
		')
	END
	ELSE
	BEGIN
		EXEC ('
			CREATE VIEW [dbo].[vyuTMBudgetCalculationItemPricing]  
			AS 

				SELECT
					A.*
					,strItemNumber = B.strItemNo
				FROM dbo.tblTMBudgetCalculationItemPricing A
				INNER JOIN tblICItem B
					ON A.intItemId = B.intItemId
		
		
		')
	END
END


GO
	PRINT 'END OF CREATING [uspTMRecreateBudgetCalculationItemPricingView] SP'
GO
	
GO
	PRINT 'BEGIN OF EXECUTE uspTMRecreateBudgetCalculationItemPricingView'
GO 
	EXEC ('uspTMRecreateBudgetCalculationItemPricingView')
GO 
	PRINT 'END OF EXECUTE uspTMRecreateBudgetCalculationItemPricingView'
GO
