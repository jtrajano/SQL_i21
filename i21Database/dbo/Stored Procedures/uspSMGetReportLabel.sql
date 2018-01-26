CREATE PROCEDURE [dbo].[uspSMGetReportLabel]
	@LanguageId	INT
AS	

select * from tblSMReportLabelDetail RD 
INNER JOIN tblSMReportLabels RL 
ON RD.intReportLabelsId = RL.intReportLabelsId 
WHERE RL.intLanguageId = @LanguageId
