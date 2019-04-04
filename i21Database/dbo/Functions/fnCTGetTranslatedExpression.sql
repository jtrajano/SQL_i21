﻿create FUNCTION [dbo].[fnCTGetTranslatedExpression]
(
	@strLabelName nvarchar(500),
	@intLanguageId int,
	@strExpression nvarchar(500)

)
RETURNS NVARCHAR(500)
AS
BEGIN 
	DECLARE @strCustomLabel NVARCHAR(MAX);

	select top 1
		@strCustomLabel = b.strCustomLabel
	from
		tblSMReportLabels a
		,tblSMReportLabelDetail b
	where
		b.intReportLabelsId = a.intReportLabelsId
		and a.strName = isnull(@strLabelName, '')
		and a.intLanguageId = isnull(@intLanguageId, 0)
		and b.strLabelName = isnull(@strExpression, '');

	RETURN ISNULL(@strCustomLabel,@strExpression);
END