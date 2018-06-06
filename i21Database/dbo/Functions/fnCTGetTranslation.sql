CREATE FUNCTION [dbo].[fnCTGetTranslation]
(
	@strNamespace	    NVARCHAR(500),
	@intRecordId	    INT,
	@intLanguageId	    INT,
	@strFieldName	    NVARCHAR(500),
	@strCurrentValue   NVARCHAR(MAX)
)
RETURNS NVARCHAR(MAX)
AS 
BEGIN 
    DECLARE @strTranslation NVARCHAR(MAX)

	SELECT	@strTranslation		=   RT.strTranslation 
	FROM	tblSMScreen				SC 
	JOIN	tblSMTransaction		TR	ON  TR.intScreenId	    =   SC.intScreenId 
										AND TR.intRecordId	    =   @intRecordId
										AND SC.strNamespace	    =   @strNamespace
	JOIN	tblSMReportTranslation	RT	ON  RT.intLanguageId    =   @intLanguageId 
										AND RT.intTransactionId =   TR.intTransactionId 
										AND RT.strFieldName	    =   'Description'

    RETURN ISNULL(@strTranslation,@strCurrentValue)
END

