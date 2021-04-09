﻿CREATE PROCEDURE [dbo].[uspEMEACustomerExport]
	@dtmFrom	DATE,
	@dtmTo		DATE
AS

TRUNCATE TABLE tblAREACustomerExport

INSERT INTO tblAREACustomerExport (
	  intEntityId
	, strEntityNo
	, strName
	, ysnGroupRequired
	, ysnLocationRequired
	, ysnCreditHold
	, ysnTaxable
	, ysnVFDDealer
	, ysnVFDAcknowledged
	, intOrganicType
	, strLastName
	, strFirstName
	, strAddress1
	, strAddress2
	, strCountry
	, strCity
	, strStateProv
	, strPostalCode
	, strPhone
	, strMobile
	, strFax
	, strEmail
	, strWebsite
	, strComment
	, strLicenseApplicator
	, dtmLicenseExpirationDate
	, dblARBalance
	, dblCreditLimit
	, dblShipToLatitude
	, dblShipToLongitude
)
SELECT intEntityId			= intId
	, strEntityNo			= LTRIM(RTRIM(Id))
	, strName				= LTRIM(RTRIM([Description]))
	, ysnGroupRequired		= GroupRequired
	, ysnLocationRequired	= LocationRequired
	, ysnCreditHold			= CreditHold
	, ysnTaxable			= Taxable
	, ysnVFDDealer			= VFDDealer
	, ysnVFDAcknowledged	= VFDAcknowledged
	, intOrganicType		= OrganicType
	, strLastName			= LTRIM(RTRIM(LastName))
	, strFirstName			= LTRIM(RTRIM(FirstName))
	, strAddress1			= LTRIM(RTRIM(Address1))
	, strAddress2			= LTRIM(RTRIM(Address2))
	, strCountry			= LTRIM(RTRIM(Country))
	, strCity				= LTRIM(RTRIM(City))
	, strStateProv			= LTRIM(RTRIM(StateProv))
	, strPostalCode			= LTRIM(RTRIM(PostalCode))
	, strPhone				= LTRIM(RTRIM(Phone))
	, strMobile				= LTRIM(RTRIM(Mobile))
	, strFax				= LTRIM(RTRIM(Fax))
	, strEmail				= LTRIM(RTRIM(Email))
	, strWebsite			= LTRIM(RTRIM(Website))
	, strComment			= LTRIM(RTRIM(Comment))
	, strLicenseApplicator  = LicenseApplicator
	, dtmLicenseExpirationDate = LicenseExpirationDate
	, dblARBalance			= ARBalance
	, dblCreditLimit		= CreditLimit
	, dblShipToLatitude		= ShipToLatitude
	, dblShipToLongitude	= ShipToLongitude
FROM vyuEMEAExportCustomer 
WHERE (CAST(ModifiedDate AS DATE) BETWEEN @dtmFrom AND @dtmTo) OR (@dtmFrom IS NULL OR @dtmTo IS NULL)

RETURN 0
