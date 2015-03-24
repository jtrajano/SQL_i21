GO

IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuTMConsumptionSiteSearch')
	DROP VIEW vyuTMConsumptionSiteSearch
GO

CREATE VIEW [dbo].[vyuTMConsumptionSiteSearch]
AS

SELECT 
	C.vwcus_key AS strCustomerNumber
	,(	CASE WHEN C.vwcus_co_per_ind_cp = 'C'   
		THEN    RTRIM(C.vwcus_last_name) + RTRIM(C.vwcus_first_name) + RTRIM(C.vwcus_mid_init) + RTRIM(C.vwcus_name_suffix)   
		ELSE    
			CASE WHEN C.vwcus_first_name IS NULL OR RTRIM(C.vwcus_first_name) = ''  
				THEN     RTRIM(C.vwcus_last_name) + RTRIM(C.vwcus_name_suffix)    
			ELSE     RTRIM(C.vwcus_last_name) + RTRIM(C.vwcus_name_suffix) + ', ' + RTRIM(C.vwcus_first_name) + RTRIM(C.vwcus_mid_init)    
			END   
		END
	 ) AS strCustomerName
	,C.vwcus_phone AS strPhone
	,A.intSiteID
	,A.strSiteAddress
	,A.strCity
	,A.strBillingBy
	,B.intCustomerID AS intCustomerId
	,A.strDescription
	,A.strLocation
	,A.intSiteNumber
	,intConcurrencyId = 0
FROM tblTMSite A
INNER JOIN tblTMCustomer B
	ON A.intCustomerID = B.intCustomerID
INNER JOIN vwcusmst C
	ON B.intCustomerNumber = C.A4GLIdentity
WHERE C.vwcus_active_yn = 'Y'
	AND A.ysnActive = 1

GO