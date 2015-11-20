CREATE PROCEDURE [dbo].[uspPATGetCustomerPatronage] 
	@intFiscalYearId INT = NULL,
	@intCustomerPatronId INT = NULL
AS
BEGIN
				SELECT RRD.intPatronageCategoryId,
					   PC.strCategoryCode,
					   RRD.dblRate,
					   CV.dblVolume,
					   dblRefundAmount = ISNULL((RRD.dblRate * CV.dblVolume),0)
				  FROM tblPATRefundRate RR
			INNER JOIN tblPATRefundRateDetail RRD
					ON RRD.intRefundTypeId = RR.intRefundTypeId
			INNER JOIN tblPATPatronageCategory PC
					ON PC.intPatronageCategoryId = RRD.intPatronageCategoryId
			INNER JOIN tblPATCustomerVolume CV
					ON CV.intPatronageCategoryId = RRD.intPatronageCategoryId
			     WHERE CV.intCustomerPatronId = @intCustomerPatronId 
END

GO