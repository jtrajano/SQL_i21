CREATE VIEW [dbo].[vyuARCustomerStatementFormat]
AS
SELECT intCustomerStatementFormatId = CSF.intCustomerStatementFormatId
     , strStatementFormat           = CSF.strStatementFormat
     , ysnCustomFormat              = CSF.ysnCustomFormat
FROM tblARCustomerStatementFormat CSF
CROSS APPLY (
    SELECT TOP 1 ysnEnableCustomStatement = ISNULL(ysnEnableCustomStatement, 0)
    FROM tblARCompanyPreference
    ORDER BY intCompanyPreferenceId ASC
) CP
WHERE CSF.ysnCustomFormat = CP.ysnEnableCustomStatement