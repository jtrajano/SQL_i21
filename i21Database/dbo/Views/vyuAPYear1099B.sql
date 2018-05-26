
CREATE VIEW [dbo].[vyuAPYear1099B]
AS

	SELECT
		 A.intYear,
		 A.strVendorId
	FROM vyuAP1099 A
	CROSS JOIN tblSMCompanySetup B
	CROSS JOIN tblAP1099Threshold C
	WHERE A.int1099Form = 3
GO



