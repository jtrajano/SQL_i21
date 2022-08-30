﻿CREATE VIEW [dbo].[vyuCRMBrandOpportunityIntegration]
AS
SELECT  [Owner]						 = ISNULL(SalesPerson.strName, '')
	   ,MarketerOpportunityID		 = CONVERT(nvarchar(100), NEWID())
	   ,MarketerOwnerID				 = CONVERT(nvarchar(100), NEWID())
	   ,MarketerOwnerName			 = ISNULL(SalesPerson.strName, '')
	   ,MarketerAccountID			 = CONVERT(nvarchar(100), NEWID())
	   ,Company						 = Customer.strName
	   ,MarketerContactID			 = ''
	   ,MarketerName				 = 'WOODFORD OIL CO'
	   ,FirstName					 = CASE WHEN CHARINDEX(',', EntityContact.strName) > 0
											THEN LTRIM(RTRIM(SUBSTRING(EntityContact.strName, dbo.fnLastIndex(EntityContact.strName,' '), DATALENGTH(EntityContact.strName))))
											ELSE LTRIM(RTRIM(REPLACE(SUBSTRING(LTRIM(RTRIM(EntityContact.strName)),1,CHARINDEX(' ',LTRIM(RTRIM(EntityContact.strName)),1)),',', '')))
									   END
	   ,LastName					 = CASE WHEN CHARINDEX(',', EntityContact.strName) > 0
											THEN LTRIM(RTRIM(REPLACE(SUBSTRING(LTRIM(RTRIM(EntityContact.strName)),1,CHARINDEX(' ',LTRIM(RTRIM(EntityContact.strName)),1)),',', '')))
											ELSE LTRIM(RTRIM(SUBSTRING(EntityContact.strName, dbo.fnLastIndex(EntityContact.strName,' '), DATALENGTH(EntityContact.strName))))
									   END
	   ,Email						 = Entity.strEmail
	   ,Phone						 = Entity.strPhone
	   ,Street						 = EntityLocation.strAddress
	   ,City						 = EntityLocation.strCity
	   ,[State]						 = EntityLocation.strState
	   ,PostalCode					 = EntityLocation.strZipCode
	   ,Country						 = EntityLocation.strCountry
	   ,ContactStreet				 = EntityContactLocation.strAddress
	   ,ContactCity					 = EntityContactLocation.strCity
	   ,ContactState				 = EntityContactLocation.strState
	   ,ContactPostalCode			 = EntityContactLocation.strZipCode
	   ,ContactEmail				 = EntityContact.strEmail
	   ,ContactPhone				 = EntityContact.strPhone
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
		LEFT JOIN vyuEMEntityContact Entity
ON Entity.intEntityId = Opportunity.intCustomerId AND	
   Entity.ysnDefaultContact = 1
		LEFT JOIN tblEMEntityLocation EntityLocation
ON EntityLocation.intEntityId = Entity.intEntityId AND
   EntityLocation.ysnDefaultLocation = 1
		 LEFT JOIN vyuEMEntityContact EntityContact
ON EntityContact.intEntityContactId = Opportunity.intCustomerContactId
		LEFT JOIN tblEMEntityToContact EntityToContact
ON EntityToContact.intEntityContactId = Opportunity.intCustomerContactId
		LEFT JOIN tblEMEntityLocation EntityContactLocation
ON EntityContactLocation.intEntityLocationId = EntityToContact.intEntityLocationId
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