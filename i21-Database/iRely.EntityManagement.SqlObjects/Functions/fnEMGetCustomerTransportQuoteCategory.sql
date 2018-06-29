CREATE FUNCTION [dbo].[fnEMGetCustomerTransportQuoteCategory]
(
	@intCustomerRackQuoteHeaderId		int
)
RETURNS NVARCHAR(MAX)
BEGIN
	DECLARE @col NVARCHAR(MAX);	
	select @col = COALESCE(@col + ', ', '') + RTRIM(LTRIM(strCategoryCode)) 
		from tblARCustomerRackQuoteCategory a
			join tblICCategory category
				on category.intCategoryId = a.intCategoryId
	where a.intCustomerRackQuoteHeaderId = @intCustomerRackQuoteHeaderId
	RETURN @col
END
