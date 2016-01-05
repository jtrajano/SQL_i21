CREATE PROCEDURE [dbo].[uspPATGetCustomerPatronage] 
	@intFiscalYearId INT = NULL,
	@intCustomerPatronId INT = NULL
AS
BEGIN
				SELECT DISTINCT RRD.intPatronageCategoryId,
					   PC.strDescription,
					   PC.strCategoryCode,
					   RRD.dblRate,
					   dblVolume = SUM(CV.dblVolume),
					   dblRefundAmount = SUM(ISNULL((RRD.dblRate * CV.dblVolume),0))
				  FROM tblPATRefundRate RR
			INNER JOIN tblPATRefundRateDetail RRD
					ON RRD.intRefundTypeId = RR.intRefundTypeId
			INNER JOIN tblPATPatronageCategory PC
					ON PC.intPatronageCategoryId = RRD.intPatronageCategoryId
			INNER JOIN tblPATCustomerVolume CV
					ON CV.intPatronageCategoryId = RRD.intPatronageCategoryId
			     WHERE CV.intCustomerPatronId = @intCustomerPatronId
			  GROUP BY RRD.intPatronageCategoryId,
					   PC.strCategoryCode,
					   PC.strDescription,
					   RRD.dblRate
END
GO