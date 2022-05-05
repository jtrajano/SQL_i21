CREATE VIEW [dbo].[vyuLGCustomerConsumptionSite]
AS  
	SELECT 
		TMS.intSiteID
		,strSiteID = RIGHT('000'+ CAST(TMS.intSiteNumber AS NVARCHAR(4)),4)  COLLATE Latin1_General_CI_AS
		,TMS.strDescription
		,intCustomerID = E.intEntityId
		,E.strName
		,E.strEntityNo
		,ELCS.intEntityLocationId
		,EL.strLocationName
		,TMC.intCurrentSiteNumber
		,ysnLocationActive = EL.ysnActive
		,ysnSiteActive = TMS.ysnActive 
		,TMS.intConcurrencyId
	FROM 
		tblEMEntityLocationConsumptionSite ELCS
		INNER JOIN tblEMEntityLocation EL ON EL.intEntityLocationId = ELCS.intEntityLocationId
		INNER JOIN tblEMEntity E ON E.intEntityId = EL.intEntityId 
		LEFT JOIN tblTMCustomer TMC ON TMC.intCustomerNumber = E.intEntityId 
		INNER JOIN tblTMSite TMS ON TMS.intSiteID = ELCS.intSiteID
GO