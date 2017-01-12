CREATE FUNCTION dbo.fnRKRKConvertProductTypeKeyToName (
	@strCommodityAttributeId nvarchar(max)
	)
RETURNS NVARCHAR(MAX)
AS
BEGIN

	DECLARE @result AS NVARCHAR(MAX)=''
	if (isnull(@strCommodityAttributeId,'') <> '')
	BEGIN
		SELECT @result=@result+strDescription +',' from tblICCommodityAttribute where intCommodityAttributeId in (select Ltrim(rtrim(Item)) Collate Latin1_General_CI_AS from [dbo].[fnSplitString](@strCommodityAttributeId, ','))
		SELECT @result=LEFT(@result, LEN(@result)-1)		
	END

	RETURN @result
	

END