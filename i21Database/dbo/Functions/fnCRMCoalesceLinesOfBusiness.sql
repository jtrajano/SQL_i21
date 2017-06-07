CREATE FUNCTION [dbo].[fnCRMCoalesceLinesOfBusiness](@intEntityCustomerId int)
RETURNS nvarchar(max)
AS
BEGIN

	declare @strLinesOfBusiness nvarchar(max);
	select
		@strLinesOfBusiness = COALESCE(@strLinesOfBusiness + ', ', '') + b.strLineOfBusiness
	from 
		tblARCustomerLineOfBusiness a, tblSMLineOfBusiness b
	where
		a.intEntityCustomerId = @intEntityCustomerId
		and b.intLineOfBusinessId = a.intLineOfBusinessId

	RETURN @strLinesOfBusiness

END