CREATE FUNCTION [dbo].[fnSMGetCompanyLogo] (@strCompanyLogoName NVARCHAR(100))
RETURNS VARBINARY (MAX)
AS
BEGIN
	DECLARE @companyLogo VARBINARY (MAX)	

	SELECT @companyLogo = blbFile FROM tblSMUpload WHERE intAttachmentId = (SELECT		TOP 1 intAttachmentId 
																			FROM		dbo.tblSMAttachment AS a
																			INNER JOIN	dbo.tblSMTransaction AS b
																			ON			a.intTransactionId = b.intTransactionId
																			INNER JOIN	dbo.tblSMScreen AS c
																			ON			b.intScreenId = c.intScreenId
																			WHERE		(c.strNamespace = 'SystemManager.view.CompanyPreference' OR
																						 c.strNamespace = 'i21.view.CompanyPreferenceOption') AND
																						a.strComment = @strCompanyLogoName
																			ORDER BY	intAttachmentId DESC)


	RETURN @companyLogo
END
