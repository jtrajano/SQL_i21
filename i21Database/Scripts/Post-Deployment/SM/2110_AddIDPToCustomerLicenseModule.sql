GO

print('/*******************  BEGIN ADDING IDP TO CUSTOMER LICENSE MODULE *******************/')

INSERT INTO tblARCustomerLicenseModule (intCustomerLicenseInformationId, intModuleId, strModuleName, ysnEnabled, intCompanyId, intConcurrencyId)
	SELECT A.intCustomerLicenseInformationId, 125, 'IDP', 0, NULL, 1 
	FROM (SELECT DISTINCT(intCustomerLicenseInformationId) FROM tblARCustomerLicenseModule) A
	WHERE dbo.fnARCheckCustomerLicenseModuleExists(A.intCustomerLicenseInformationId, 125) = 0


print('/*******************  END UPDATING IDP TO CUSTOMER LICENSE MODULE *******************/')

GO