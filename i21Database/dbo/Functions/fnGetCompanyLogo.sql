CREATE FUNCTION [dbo].[fnGetCompanyLogo] ()
RETURNS VARBINARY (MAX)
AS
BEGIN
	DECLARE @companyLogo VARBINARY (MAX)

	SELECT @companyLogo = blbFile FROM tblSMUpload WHERE intAttachmentId = (SELECT TOP 1 intAttachmentId FROM tblSMAttachment WHERE strScreen = 'SystemManager.CompanyPreference' AND strComment = 'Header' ORDER BY intAttachmentId DESC)

	RETURN @companyLogo
END
