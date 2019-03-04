CREATE FUNCTION [dbo].[fnCFConstructFullCardNumber](@iso nvarchar(max),@entryCode int,@customerNumber nvarchar(max),@cardnumber nvarchar(max), @accountLen int ,@cardLen int)
RETURNS nvarchar(max) 
AS 
BEGIN
    DECLARE @returnData NVARCHAR(MAX)

	SET @returnData = dbo.fnCFPadString(dbo.fnCFGetLuhn(
							
		(dbo.fnCFPadString(@iso , 6, '0', 'left') 
		+ dbo.fnCFPadString(@entryCode , 1, '0', 'left') 
		+ CASE WHEN ISNULL(LEN(@customerNumber),0) > ISNULL(@accountLen ,0)
			THEN SUBSTRING(@customerNumber,(ISNULL(LEN(@customerNumber),0) - ISNULL(@accountLen ,0) + 1), ISNULL(@accountLen ,0))
			ELSE dbo.fnCFPadString(@customerNumber , ISNULL(@accountLen ,0), '0', 'left') 
			END
		+ CASE WHEN ISNULL(LEN(@cardnumber),0) > ISNULL(@cardLen ,0)
			THEN SUBSTRING(@cardnumber,(ISNULL(LEN(@cardnumber),0) - ISNULL(@cardLen ,0) + 1), ISNULL(@cardLen ,0))
			ELSE dbo.fnCFPadString(@cardnumber , ISNULL(@cardLen ,0), '0', 'left') 
			END
	),1),24,'0','left')

	RETURN @returnData

END;
