CREATE VIEW [dbo].[vyuCRMCampaignContactSource]
	AS
		select intId = convert(int, ROW_NUMBER() over (order by strContactName)), strContactName,strCompanyName,strEmail,intContactId,strEntityType = (case when len(strEntityType) > 3 then substring(strEntityType,3,(LEN(strEntityType)-2)) else '' end) from
		(
		select distinct strContactName = strName, strCompanyName = strEntityName, strEmail, intContactId = intEntityContactId,strEntityType = 
				(case when vyuEMEntityContact.Customer = 1 then ', Customer' else '' end)+
				(case when vyuEMEntityContact.Vendor = 1 then ', Vendor' else '' end)+
				(case when vyuEMEntityContact.Employee = 1 then ', Employee' else '' end)+
				(case when vyuEMEntityContact.Salesperson = 1 then ', Salesperson' else '' end)+
				(case when vyuEMEntityContact.[User] = 1 then ', User' else '' end)+
				(case when vyuEMEntityContact.FuturesBroker = 1 then ', FuturesBroker' else '' end)+
				(case when vyuEMEntityContact.Terminal = 1 then ', Terminal' else '' end)+
				(case when vyuEMEntityContact.ShippingLine = 1 then ', ShippingLine' else '' end)+
				(case when vyuEMEntityContact.Trucker = 1 then ', Trucker' else '' end) from vyuEMEntityContact
		) as result
