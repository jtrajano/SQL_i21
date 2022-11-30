CREATE FUNCTION [dbo].[fnCRMCoalesceLinesOfBusinessId](@intEntityCustomerId int)
RETURNS nvarchar(max)
AS
BEGIN

	declare @strLinesOfBusinessId nvarchar(max);
	select
		@strLinesOfBusinessId = COALESCE(@strLinesOfBusinessId COLLATE Latin1_General_CI_AS + ',','') + convert(nvarchar(20),b.intLineOfBusinessId) COLLATE Latin1_General_CI_AS
	--from 
	--	tblEMEntityLineOfBusiness a, tblSMLineOfBusiness b
	--where
	--	a.intEntityId = @intEntityCustomerId
	--	and b.intLineOfBusinessId = a.intLineOfBusinessId
	from tblEMEntityLineOfBusiness a
	inner join tblSMLineOfBusiness b on b.intLineOfBusinessId = a.intLineOfBusinessId
	where
		a.intEntityId = @intEntityCustomerId

	RETURN @strLinesOfBusinessId COLLATE Latin1_General_CI_AS

END