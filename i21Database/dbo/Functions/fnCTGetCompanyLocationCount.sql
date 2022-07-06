CREATE FUNCTION [dbo].[fnCTGetCompanyLocationCount] 
(@intContractHeaderId INT)
RETURNS VARBINARY (MAX)
AS
BEGIN
	DECLARE @companyLogo VARBINARY (MAX);	
	DECLARE @strLogoType  NVARCHAR(50),
			@intCompanyLocationId INT,
			@locCount INT

	BEGIN 
		
		
		SELECT  @intCompanyLocationId = intCompanyLocationId FROM tblCTContractDetail 
		WHERE intContractHeaderId = @intContractHeaderId
		GROUP BY intCompanyLocationId

		SET @locCount = @@ROWCOUNT
	
	END
	
	RETURN @locCount 
END
