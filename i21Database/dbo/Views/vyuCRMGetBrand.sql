CREATE VIEW [dbo].[vyuCRMGetBrand]
AS
	SELECT 
		   intBrandId					= Brand.intBrandId
		  ,strBrand						= Brand.strBrand
		  ,strFileType					= Brand.strFileType
		  ,strIntegrationObject			= Brand.strIntegrationObject
		  ,strLoginUrl					= Brand.strLoginUrl
		  ,strUserName					= Brand.strUserName
		  ,strPassword					= dbo.fnAESDecryptASym(Brand.strPassword) COLLATE Latin1_General_CI_AS
		  ,strSendType					= Brand.strSendType
		  ,strFrequency					= Brand.strFrequency
		  ,strDayOfWeek					= Brand.strDayOfWeek
		  ,strEnvironmentType			= Brand.strEnvironmentType
		  ,ysnHoldSchedule				= Brand.ysnHoldSchedule
		  ,dtmStartTime					= Brand.dtmStartTime
		  ,dtmApprovedDate				= Brand.dtmApprovedDate
		  ,intVendorId					= Brand.intVendorId
		  ,intVendorContactId			= Brand.intVendorContactId
		  ,strNote						= Brand.strNote
		  ,intConcurrencyId				= Brand.intConcurrencyId
		  ,strVendorName				= Vendor.strName
		  ,strVendorContactName			= VendorContact.strName
		  ,strVendorContactPhone		= VendorContact.strPhone
		  ,strVendorContactEmail		= VendorContact.strEmail
	FROM tblCRMBrand Brand
		LEFT JOIN tblEMEntity Vendor
	ON Vendor.intEntityId = Brand.intVendorId
			LEFT JOIN tblEMEntity VendorContact
	ON VendorContact.intEntityId = Brand.intVendorId

		
GO