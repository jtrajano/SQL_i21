CREATE FUNCTION [dbo].[fnCTGetCompanyLogo] 
(@strCompanyLogoName NVARCHAR(100), @intContractHeaderId INT)
RETURNS VARBINARY (MAX)
AS
BEGIN
	DECLARE @companyLogo VARBINARY (MAX);	
	DECLARE @strLogoType  NVARCHAR(50),
			@intCompanyLocationId INT

	BEGIN 
		SELECT TOP 1 @intCompanyLocationId = intCompanyLocationId FROM tblCTContractDetail WHERE intContractHeaderId = @intContractHeaderId
		SELECT TOP 1 @companyLogo = imgLogo, @strLogoType = 'Logo' FROM tblSMLogoPreference
		WHERE (ysnDefault = 1 OR  ysnContract = 1)  AND intCompanyLocationId = @intCompanyLocationId
	END
	
	IF @companyLogo IS NULL 
	BEGIN
	SELECT @companyLogo = blbFile FROM tblSMUpload WHERE intAttachmentId = (SELECT		TOP 1 intAttachmentId 
																			FROM		dbo.tblSMAttachment AS a
																			INNER JOIN	dbo.tblSMTransaction AS b
																			ON			a.intTransactionId = b.intTransactionId
																			INNER JOIN	dbo.tblSMScreen AS c
																			ON			b.intScreenId = c.intScreenId
																			WHERE		c.strNamespace = 'SystemManager.view.CompanyPreference' AND
																						a.strComment = @strCompanyLogoName
																			ORDER BY	intAttachmentId DESC)

	END
	RETURN @companyLogo 
END
