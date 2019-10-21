CREATE FUNCTION [dbo].[fnCKSMUniqueDefaultPerCity](	
	@intCityId		as int
	,@intCountryId	AS INT
	,@ysnDefault	AS bit
	,@ysnPort		as bit
)
RETURNS BIT
AS
BEGIN
	if(@ysnDefault = 0 ) return 1
	
	if @ysnPort = 1 and exists( 
				select top 1 1 
					from tblSMCity 
						where ysnDefault = 1 
								and intCountryId = @intCountryId
								and intCityId <> @intCityId and ysnPort = 1)
		return 0;
		

	RETURN 1
END