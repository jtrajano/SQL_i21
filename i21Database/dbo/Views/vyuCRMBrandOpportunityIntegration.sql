CREATE VIEW [dbo].[vyuCRMBrandOpportunityIntegration]
AS
SELECT  [Owner]						 = SalesPerson.strName
	   ,MarketerOpportunityID		 = CONVERT(nvarchar(100), NEWID())
	   ,MarketerOwnerID				 = CONVERT(nvarchar(100), NEWID())
	   ,MarketerOwnerName			 = SalesPerson.strName
	   ,MarketerAccountID			 = CONVERT(nvarchar(100), NEWID())
	   ,Company						 = Customer.strName
	   ,MarketerContactID			 = ''
	   ,MarketerName				 = ''
	   ,FirstName					 = Contact.strName
	   ,LastName					 = Contact.strName
	   ,Email						 = Customer.strEmail
	   ,Phone						 = Customer.strPhone
	   ,Street						 = CustomerLocation.strAddress
	   ,City						 = CustomerLocation.strCity
	   ,[State]						 = CustomerLocation.strState
	   ,PostalCode					 = CustomerLocation.strZipCode
	   ,Country						 = CustomerLocation.strCountry
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
		LEFT JOIN tblEMEntity SalesPerson
ON SalesPerson.intEntityId = Opportunity.intInternalSalesPerson
		LEFT JOIN tblEMEntity Contact
ON Contact.intEntityId = Opportunity.intCustomerContactId
		LEFT JOIN tblEMEntityLocation ContactLocation
ON ContactLocation.intEntityId = Contact.intEntityId AND
   ContactLocation.ysnDefaultLocation = 1
		LEFT JOIN tblEMEntity Customer
ON Customer.intEntityId = Opportunity.intCustomerId
		LEFT JOIN tblEMEntityLocation CustomerLocation
ON CustomerLocation.intEntityId = Customer.intEntityId AND
   CustomerLocation.ysnDefaultLocation = 1
		LEFT JOIN tblCRMIndustrySegment IndustrySegment
ON IndustrySegment.intIndustrySegmentId = Opportunity.intIndustrySegmentId
		LEFT JOIN tblCRMSalesPipeStatus SalesPipeStatus
ON SalesPipeStatus.intSalesPipeStatusId = Opportunity.intSalesPipeStatusId
		LEFT JOIN tblCRMOpportunityType OpportunityType
ON OpportunityType.intOpportunityTypeId = Opportunity.intOpportunityTypeId
WHERE Opportunity.intBrandMaintenanceId IS NOT NULL

GO