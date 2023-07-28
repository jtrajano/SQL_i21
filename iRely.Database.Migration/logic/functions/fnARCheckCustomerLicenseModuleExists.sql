--liquibase formatted sql

-- changeset Von:fnARCheckCustomerLicenseModuleExists.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER FUNCTION [dbo].[fnARCheckCustomerLicenseModuleExists]
(
	@intCustomerLicenseModuleId INT,
	@intModuleId INT
)
RETURNS BIT
AS
BEGIN
	IF EXISTS (SELECT TOP 1 1 FROM tblARCustomerLicenseModule WHERE @intCustomerLicenseModuleId = intCustomerLicenseInformationId AND @intModuleId = intModuleId)
	BEGIN
		RETURN 1
	END

	RETURN 0
END



