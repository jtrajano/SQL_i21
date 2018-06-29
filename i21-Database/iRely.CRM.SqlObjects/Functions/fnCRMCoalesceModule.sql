CREATE FUNCTION [dbo].[fnCRMCoalesceModule](@intEntityCustomerId int, @strCompanyId nvarchar(max))
RETURNS nvarchar(max)
AS
BEGIN

	declare @strModules nvarchar(max);
	select
		@strModules = COALESCE(@strModules + ', ', '') + '(' + c.strApplicationName + ') ' + (case when c.strPrefix is null or rtrim(ltrim(c.strPrefix)) = '' then '' else c.strPrefix + ' - ' end) + c.strModule
	from 
		tblARCustomerLicenseInformation a
		,tblARCustomerLicenseModule b
		,tblSMModule c
	where
		b.intCustomerLicenseInformationId = a.intCustomerLicenseInformationId
		and a.intEntityCustomerId = @intEntityCustomerId
		and a.strCompanyId = @strCompanyId
		and b.ysnEnabled = convert(bit,1)
		and c.intModuleId = b.intModuleId

	RETURN @strModules

END