DECLARE @TaxAuthorityCode NVARCHAR(10) = 'NM'
	, @TaxAuthorityId INT

SELECT @TaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = @TaxAuthorityCode AND ysnFilingForThisTA = 1

IF(@TaxAuthorityId IS NOT NULL)
BEGIN

	PRINT ('Deploying New Mexico Tax Forms')



END

GO