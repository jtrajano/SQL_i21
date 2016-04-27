CREATE FUNCTION [dbo].[fnEMGetCustomerTransportQuoteItem]
(
	@intCustomerRackQuoteHeaderId		int
)
RETURNS NVARCHAR(MAX)
BEGIN
	DECLARE @col NVARCHAR(MAX);	
	select @col = COALESCE(@col + ', ', '') + RTRIM(LTRIM(strItemNo)) 
		from tblARCustomerRackQuoteItem a
			join tblICItem item
				on item.intItemId = a.intItemId
	where a.intCustomerRackQuoteHeaderId = @intCustomerRackQuoteHeaderId
	RETURN @col
END
