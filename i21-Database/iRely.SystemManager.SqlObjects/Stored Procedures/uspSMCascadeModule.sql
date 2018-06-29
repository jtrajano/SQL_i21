CREATE PROCEDURE [dbo].[uspSMCascadeModule]
AS
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

DECLARE @currentRow INT
DECLARE @totalRows INT

SET @currentRow = 1
SELECT @totalRows = Count(*) FROM [tblARCustomerLicenseInformation]

WHILE (@currentRow <= @totalRows)
BEGIN

Declare @informationId INT
SELECT @informationId = intCustomerLicenseInformationId FROM (  
	SELECT ROW_NUMBER() OVER(ORDER BY intCustomerLicenseInformationId ASC) AS 'ROWID', *
	FROM [tblARCustomerLicenseInformation]
) a
WHERE ROWID = @currentRow

INSERT INTO tblARCustomerLicenseModule(intCustomerLicenseInformationId, intModuleId, strModuleName, ysnEnabled)
SELECT @informationId, intModuleId, strModule, 0 
FROM tblSMModule
WHERE intModuleId NOT IN 
(
	SELECT intModuleId FROM [tblARCustomerLicenseModule] WHERE intCustomerLicenseInformationId = @informationId
)
AND ysnCustomerModule = 1

SET @currentRow = @currentRow + 1

END