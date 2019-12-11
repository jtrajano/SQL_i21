
CREATE FUNCTION [dbo].[fnCFCardNumberToMaximaFormat](@cardNumber nvarchar(max),@mask bit = 0)
RETURNS nvarchar(max) 
AS 
BEGIN
    DECLARE @returnData		NVARCHAR(MAX)
    DECLARE @19CardNumber	NVARCHAR(MAX)
    DECLARE @segment1		NVARCHAR(MAX)
    DECLARE @segment2		NVARCHAR(MAX)
    DECLARE @segment3		NVARCHAR(MAX)
    DECLARE @segment4		NVARCHAR(MAX)

	SET @returnData = 'Invalid String' 
	IF(LEN(@cardNumber) >= 19)
	BEGIN
		SET @19CardNumber = SUBSTRING(@cardNumber,((ISNULL(LEN(@cardNumber),0) - 19) + 1), 19) 
		SET @segment1 = CASE WHEN ISNULL(@mask,0) = 0 THEN SUBSTRING(@19CardNumber,0,7)  ELSE '******' END
		SET @segment2 = CASE WHEN ISNULL(@mask,0) = 0 THEN SUBSTRING(@19CardNumber,7,5)  ELSE '*****' END
		SET @segment3 = SUBSTRING(@19CardNumber,12,4)
		SET @segment4 = SUBSTRING(@19CardNumber,16,4)

		SET @returnData = @segment1 + ' ' +  @segment2 + ' ' + @segment3 + ' ' + @segment4
	END

	RETURN @returnData

END;

--string output = String.Empty;
--if (value.Length >= 19)
--{
--    var fullDisplayCardId = value.Substring((value.Length - 19), 19);
--    var segment1 = mask == false ? fullDisplayCardId.Substring(0, 6) : "******";
--    var segment2 = mask == false ? fullDisplayCardId.Substring(6, 5) : "*****";
--    var segment3 = fullDisplayCardId.Substring(11, 4);
--    var segment4 = fullDisplayCardId.Substring(15, 4);
--    output = String.Format("{0} {1} {2} {3}", segment1, segment2, segment3, segment4);
--}
--else
--{
--    output = "Invalid String";
--}
--return output;
