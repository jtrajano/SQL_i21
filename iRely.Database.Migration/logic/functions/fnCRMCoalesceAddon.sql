--liquibase formatted sql

-- changeset Von:fnCRMCoalesceAddon.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER FUNCTION [dbo].[fnCRMCoalesceAddon](@intEntityCustomerId int, @strCompanyId nvarchar(max))
RETURNS nvarchar(max)
AS
BEGIN

	declare @strModules nvarchar(max);
	select
		@strModules = COALESCE(@strModules COLLATE Latin1_General_CI_AS + ', ', '') + '(' + c.strApplicationName + ') ' + (case when c.strPrefix is null or rtrim(ltrim(c.strPrefix)) = '' then '' else c.strPrefix + ' - ' end) + c.strModule COLLATE Latin1_General_CI_AS
	from 
		tblARCustomerLicenseInformation a
	inner join tblARCustomerLicenseModule b on b.intCustomerLicenseInformationId = a.intCustomerLicenseInformationId
	inner join tblSMModule c on c.intModuleId = b.intModuleId
	where
		a.intEntityCustomerId = @intEntityCustomerId
		and a.strCompanyId = @strCompanyId COLLATE Latin1_General_CI_AS
		and b.ysnAddonComponent = 1
		and b.ysnEnabled = convert(bit,1)
		

	RETURN @strModules COLLATE Latin1_General_CI_AS

END



