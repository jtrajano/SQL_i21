CREATE VIEW [dbo].[vyuCRMIntegrationSearch]
AS
	SELECT 
		   intBrandId					= Brand.intBrandId
		  ,intBrandMaintenanceId		= BrandMaintenance.intBrandMaintenanceId
		  ,strBrand						= BrandMaintenance.strBrand
		  ,strIntegrationName			= Brand.strIntegrationName
		  ,strFileType					= Brand.strFileType
		  ,strIntegrationObject			= Brand.strIntegrationObject
		  ,strLoginUrl					= Brand.strLoginUrl
		  ,strUserName					= Brand.strUserName
		  ,strSendType					= Brand.strSendType
		  ,strFrequency					= Brand.strFrequency
		  ,strDayOfWeek					= Brand.strDayOfWeek
		  ,strEnvironmentType			= Brand.strEnvironmentType
		  ,ysnHoldSchedule				= Brand.ysnHoldSchedule
		  ,dtmStartTime					= Brand.dtmStartTime
		  ,dtmApprovedDate				= Brand.dtmApprovedDate
		  ,strVendorName				= Vendor.strName
		  ,strVendorContactName			= VendorContact.strName
		  ,strVendorContactPhone		= VendorContact.strPhone
		  ,strVendorContactEmail		= VendorContact.strEmail
	FROM tblCRMBrand Brand
		INNER JOIN tblCRMBrandMaintenance BrandMaintenance
	ON BrandMaintenance.intBrandMaintenanceId = Brand.intBrandMaintenanceId
		LEFT JOIN tblEMEntity Vendor
	ON Vendor.intEntityId = Brand.intVendorId
			LEFT JOIN tblEMEntity VendorContact
	ON VendorContact.intEntityId = Brand.intVendorContactId

		
GO