CREATE VIEW [dbo].[vyuEMCustomerApplicator]
	AS 


	select 
	intEntityId = A.intEntityCustomerId,
	A.strLicenseNo,
	A.dtmExpirationDate,
	A.ysnCustomerApplicator,
	A.strComment,
	B.strCustomerNumber,
	E.strName

	from tblARCustomerApplicatorLicense A
		join tblARCustomer B
			on A.intEntityCustomerId = B.[intEntityId]
		join tblEMEntity E
			on A.intEntityCustomerId = E.intEntityId


