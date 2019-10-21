CREATE PROCEDURE [dbo].[uspSMGetReportLabel]
	@LanguageId INT
AS	

--DECLARE @LanguageID INT 

--SELECT @LanguageID = intLanguageId FROM tblEMEntity WHERE intEntityId = @EntityId

SELECT * FROM tblSMReportLabelDetail RD 

INNER JOIN tblSMReportLabels RL ON RD.intReportLabelsId = RL.intReportLabelsId 

WHERE RL.intLanguageId = @LanguageId