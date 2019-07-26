﻿CREATE PROCEDURE [dbo].[uspEMEACustomerExport]
	@dtmFrom	date,
	@dtmTo		date
AS
	truncate table tblAREACustomerExport

	insert into tblAREACustomerExport

	(intEntityId, strEntityNo, strName, ysnGroupRequired, ysnLocationRequired, ysnCreditHold, ysnTaxable, ysnVFDDealer, ysnVFDAcknowledged, intOrganicType, 
	strLastName, strFirstName, strAddress1, strAddress2, strCity, strStateProv, strPostalCode, strPhone, strMobile, strFax, strEmail, strWebsite, strComment)

	select	intId, Id, [Description], GroupRequired, LocationRequired, CreditHold, Taxable, VFDDealer, VFDAcknowledged, OrganicType,
		LastName, FirstName, Address1, Address2, City, StateProv, PostalCode, Phone, Mobile, Fax, Email, Website, Comment
	from vyuEMEAExportCustomer 
		where (cast(ModifiedDate as date) between @dtmFrom and @dtmTo) OR (@dtmFrom IS NULL OR @dtmTo IS NULL)

	--select 
	--	intEntityId, strEntityNo, strName, ysnGroupRequired, ysnLocationRequired, ysnCreditHold, ysnTaxable, ysnVFDDealer, ysnVFDAcknowledged, intOrganicType, 
	--	strLastName, strFirstName, strAddress1, strAddress2, strCity, strStateProv, strPostalCode, strPhone, strMobile, strFax, strEmail, strWebsite
	--from tblAREACustomerExport



RETURN 0
