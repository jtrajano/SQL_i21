CREATE VIEW [dbo].[vyuCRMBrandOpportunityIntegration]
AS
SELECT  [Owner]						 = ISNULL(SalesPerson.strName, '')
	   ,MarketerOpportunityID		 = CONVERT(nvarchar(100), NEWID())
	   ,MarketerOwnerID				 = CONVERT(nvarchar(100), NEWID())
	   ,MarketerOwnerName			 = ISNULL(SalesPerson.strName, '')
	   ,MarketerAccountID			 = CONVERT(nvarchar(100), NEWID())
	   ,Company						 = Customer.strName
	   ,MarketerContactID			 = ''
	   ,MarketerName				 = 'WOODFORD OIL CO'
	   ,FirstName					 = CASE WHEN CHARINDEX(',', Contact.strName) > 0
											THEN LTRIM(RTRIM(SUBSTRING(Contact.strName, dbo.fnLastIndex(Contact.strName,' '), DATALENGTH(Contact.strName))))
											ELSE LTRIM(RTRIM(REPLACE(SUBSTRING(LTRIM(RTRIM(Contact.strName)),1,CHARINDEX(' ',LTRIM(RTRIM(Contact.strName)),1)),',', '')))
									   END
	   ,LastName					 = CASE WHEN CHARINDEX(',', Contact.strName) > 0
											THEN LTRIM(RTRIM(REPLACE(SUBSTRING(LTRIM(RTRIM(Contact.strName)),1,CHARINDEX(' ',LTRIM(RTRIM(Contact.strName)),1)),',', '')))
											ELSE LTRIM(RTRIM(SUBSTRING(Contact.strName, dbo.fnLastIndex(Contact.strName,' '), DATALENGTH(Contact.strName))))
									   END
	   ,Email						 = Contact.strEmail
	   ,Phone						 = Contact.strPhone
	   ,Street						 = ContactLocation.strAddress
	   ,City						 = ContactLocation.strCity
	   ,[State]						 = ContactLocation.strState
	   ,PostalCode					 = ContactLocation.strZipCode
	   ,Country						 = ContactLocation.strCountry
	   ,ContactStreet				 = ContactLocation.strAddress
	   ,ContactCity					 = ContactLocation.strCity
	   ,ContactState				 = ContactLocation.strState
	   ,ContactPostalCode			 = ContactLocation.strZipCode
	   ,ContactEmail				 = Contact.strEmail
	   ,ContactPhone				 = Contact.strPhone
	   ,Volume						 = Opportunity.intVolume
	   ,IndustrySegment				 = IndustrySegment.strIndustrySegment
	   ,NextSteps					 = Opportunity.strDescription
	   ,CloseDate					 = Opportunity.dtmClose
	   ,StageName					 = SalesPipeStatus.strStatus
	   ,OpportunityName				 = Opportunity.strName
	   ,OpportunityDescription		 = Opportunity.strOpportunityDescription
	   ,OpportunityType				 = OpportunityType.strOpportunityType
	   ,Product						 = ''
	   ,UnitOfMeasure				 = 'Gallons'
	   ,CurrencyIsocode				 = 'USD'
	   ,RBLProposal					 = ''
	   ,ISOCLEANCertifiedLubricants  = ''
	   ,PrivateLabel				 = ''
	   ,MSA							 = ''
	   ,intOpportunityId			 = Opportunity.intOpportunityId
	   ,intBrandMaintenanceId		 = Opportunity.intBrandMaintenanceId
FROM tblCRMOpportunity Opportunity
		LEFT JOIN vyuEMEntityContact Contact
ON Contact.intEntityContactId = Opportunity.intCustomerContactId
		LEFT JOIN tblEMEntityLocation ContactLocation
ON ContactLocation.intEntityId = Contact.intEntityId AND
   ContactLocation.ysnDefaultLocation = 1
		LEFT JOIN tblEMEntity Customer
ON Customer.intEntityId = Opportunity.intCustomerId
		LEFT JOIN tblEMEntity SalesPerson 
ON SalesPerson.intEntityId = Opportunity.intInternalSalesPerson
		LEFT JOIN tblCRMIndustrySegment IndustrySegment
ON IndustrySegment.intIndustrySegmentId = Opportunity.intIndustrySegmentId
		LEFT JOIN tblCRMSalesPipeStatus SalesPipeStatus
ON SalesPipeStatus.intSalesPipeStatusId = Opportunity.intSalesPipeStatusId
		LEFT JOIN tblCRMOpportunityType OpportunityType
ON OpportunityType.intOpportunityTypeId = Opportunity.intOpportunityTypeId
WHERE Opportunity.intBrandMaintenanceId IS NOT NULL


GO