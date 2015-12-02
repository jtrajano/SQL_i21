CREATE PROCEDURE [dbo].[uspPATGetFiscalPatronage]
	@intFiscalYearId INT = NULL
AS
BEGIN
				SELECT DISTINCT RRD.intPatronageCategoryId,
					   PC.strCategoryCode,
					   RRD.dblRate,
					   SUM(CV.dblVolume),
					   dblRefundAmount = SUM(ISNULL((RRD.dblRate * CV.dblVolume),0))
				  FROM tblPATRefundRate RR
			INNER JOIN tblPATRefundRateDetail RRD
					ON RRD.intRefundTypeId = RR.intRefundTypeId
			INNER JOIN tblPATPatronageCategory PC
					ON PC.intPatronageCategoryId = RRD.intPatronageCategoryId
			INNER JOIN tblPATCustomerVolume CV
					ON CV.intPatronageCategoryId = RRD.intPatronageCategoryId
			     WHERE CV.intFiscalYear = @intFiscalYearId
			  GROUP BY RRD.intPatronageCategoryId, PC.strCategoryCode, RRD.dblRate
END
GO