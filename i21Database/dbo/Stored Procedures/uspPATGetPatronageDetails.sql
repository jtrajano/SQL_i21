CREATE PROCEDURE [dbo].[uspPATGetPatronageDetails] 
	 @intCustomerId INT = NULL
	,@intFiscalYear INT = NULL
AS
BEGIN
	SELECT CV.intPatronageCategoryId,
		   PC.strCategoryCode,
		   PC.strDescription,
		   PC.strPurchaseSale,
		   PC.strUnitAmount,
		   CV.dblVolume,
		   CV.intConcurrencyId
	  FROM tblPATCustomerVolume CV
INNER JOIN tblPATPatronageCategory PC
		ON PC.intPatronageCategoryId = CV.intPatronageCategoryId
	 WHERE intCustomerPatronId = @intCustomerId AND intFiscalYear = @intFiscalYear

END

GO
