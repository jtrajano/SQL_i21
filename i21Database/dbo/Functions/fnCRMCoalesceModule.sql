CREATE FUNCTION [dbo].[fnCRMCoalesceModule](@intEntityCustomerId int, @strCompanyId nvarchar(max))
RETURNS nvarchar(max)
AS
BEGIN

	declare @strModules nvarchar(max);
	select
		@strModules = COALESCE(@strModules + ', ', '') + b.strModuleName
	from 
		tblARCustomerLicenseInformation a
		,tblARCustomerLicenseModule b
	where
		b.intCustomerLicenseInformationId = a.intCustomerLicenseInformationId
		and a.intEntityCustomerId = @intEntityCustomerId
		and a.strCompanyId = @strCompanyId
		and b.ysnEnabled = convert(bit,1)

	RETURN @strModules

END