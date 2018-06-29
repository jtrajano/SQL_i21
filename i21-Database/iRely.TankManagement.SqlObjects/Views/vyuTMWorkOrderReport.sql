CREATE VIEW [dbo].[vyuTMWorkOrderReport]
AS

SELECT 
	strCustomerNumber = CUS.vwcus_key COLLATE Latin1_General_CI_AS
	,intWorkOrderId = WRK.intWorkOrderID
	,intSiteId = STE.intSiteID
	,strCustomerName = (CASE WHEN CUS.vwcus_co_per_ind_cp = 'C' 
												THEN RTRIM(CUS.vwcus_last_name) + RTRIM(CUS.vwcus_first_name) + RTRIM(CUS.vwcus_mid_init) + RTRIM(CUS.vwcus_name_suffix)   
											WHEN CUS.vwcus_first_name IS NULL OR RTRIM(CUS.vwcus_first_name) = ''  
												THEN     RTRIM(CUS.vwcus_last_name) + RTRIM(CUS.vwcus_name_suffix)    
											ELSE     RTRIM(CUS.vwcus_last_name) + RTRIM(CUS.vwcus_name_suffix) + ', ' + RTRIM(CUS.vwcus_first_name) + RTRIM(CUS.vwcus_mid_init)
											END)  COLLATE Latin1_General_CI_AS
    ,strCustomerAddress = (CASE WHEN  ISNULL(RTRIM(CUS.vwcus_addr2),'') != '' AND ISNULL(RTRIM(CUS.vwcus_addr),'') != '' AND ISNULL(RTRIM(CUS.vwcus_city),'') != '' AND ISNULL(RTRIM(CUS.vwcus_state),'') != '' AND ISNULL(RTRIM(CUS.vwcus_zip),'') != '' THEN
							RTRIM(CUS.vwcus_addr) + ', ' + RTRIM(CUS.vwcus_addr2)  + ', ' + RTRIM(CUS.vwcus_city) + ', ' + RTRIM(CUS.vwcus_state) + ' ' + RTRIM(CUS.vwcus_zip)
		
							WHEN ISNULL(RTRIM(CUS.vwcus_addr2),'') = '' AND ISNULL(RTRIM(CUS.vwcus_addr),'') != '' AND ISNULL(RTRIM(CUS.vwcus_city),'') != '' AND ISNULL(RTRIM(CUS.vwcus_state),'') != '' AND ISNULL(RTRIM(CUS.vwcus_zip),'') != '' THEN
							RTRIM(CUS.vwcus_addr) + ', ' + RTRIM(CUS.vwcus_city) + ', ' + RTRIM(CUS.vwcus_state) + ' ' + RTRIM(CUS.vwcus_zip)
		
							WHEN ISNULL(RTRIM(CUS.vwcus_addr2),'') != '' AND ISNULL(RTRIM(CUS.vwcus_addr),'') = '' AND ISNULL(RTRIM(CUS.vwcus_city),'') != '' AND ISNULL(RTRIM(CUS.vwcus_state),'') != '' AND ISNULL(RTRIM(CUS.vwcus_zip),'') != '' THEN
							RTRIM(CUS.vwcus_addr2) + ', ' + RTRIM(CUS.vwcus_city) + ', ' + RTRIM(CUS.vwcus_state) + ' ' + RTRIM(CUS.vwcus_zip)
		
							WHEN ISNULL(RTRIM(CUS.vwcus_addr2),'') != '' AND ISNULL(RTRIM(CUS.vwcus_addr),'') != '' AND ISNULL(RTRIM(CUS.vwcus_city),'') = '' AND ISNULL(RTRIM(CUS.vwcus_state),'') != '' AND ISNULL(RTRIM(CUS.vwcus_zip),'') != '' THEN
							RTRIM(CUS.vwcus_addr) + ', ' + RTRIM(CUS.vwcus_addr2) + ', ' +  RTRIM(CUS.vwcus_state) + ' ' + RTRIM(CUS.vwcus_zip)
		
							WHEN ISNULL(RTRIM(CUS.vwcus_addr2),'') != '' AND ISNULL(RTRIM(CUS.vwcus_addr),'') != '' AND ISNULL(RTRIM(CUS.vwcus_city),'') != '' AND ISNULL(RTRIM(CUS.vwcus_state),'') = '' AND ISNULL(RTRIM(CUS.vwcus_zip),'') != '' THEN
							RTRIM(CUS.vwcus_addr) + ', ' + RTRIM(CUS.vwcus_addr2)  + ', ' + RTRIM(CUS.vwcus_city)  + ' ' + RTRIM(CUS.vwcus_zip)
		
							WHEN ISNULL(RTRIM(CUS.vwcus_addr2),'') != '' AND ISNULL(RTRIM(CUS.vwcus_addr),'') != '' AND ISNULL(RTRIM(CUS.vwcus_city),'') != '' AND ISNULL(RTRIM(CUS.vwcus_state),'') != '' AND ISNULL(RTRIM(CUS.vwcus_zip),'') = '' THEN
							RTRIM(CUS.vwcus_addr) + ', ' + RTRIM(CUS.vwcus_addr2)  + ', ' + RTRIM(CUS.vwcus_city)  + ', ' + RTRIM(CUS.vwcus_state)
		
							When  ISNULL(RTRIM(CUS.vwcus_addr2),'') = '' AND ISNULL(RTRIM(CUS.vwcus_addr),'') = '' AND ISNULL(RTRIM(CUS.vwcus_city),'') != '' AND ISNULL(RTRIM(CUS.vwcus_state),'') != '' AND ISNULL(RTRIM(CUS.vwcus_zip),'') != '' THEN
							RTRIM(CUS.vwcus_city) + ', ' + RTRIM(CUS.vwcus_state) + ' ' + RTRIM(CUS.vwcus_zip)
		
							When  ISNULL(RTRIM(CUS.vwcus_addr2),'') != '' AND ISNULL(RTRIM(CUS.vwcus_addr),'') = '' AND ISNULL(RTRIM(CUS.vwcus_city),'') = '' AND ISNULL(RTRIM(CUS.vwcus_state),'') != '' AND ISNULL(RTRIM(CUS.vwcus_zip),'') != '' THEN
							RTRIM(CUS.vwcus_addr2) + ', ' + RTRIM(CUS.vwcus_state) + ' ' + RTRIM(CUS.vwcus_zip)
		
							When  ISNULL(RTRIM(CUS.vwcus_addr2),'') != '' AND ISNULL(RTRIM(CUS.vwcus_addr),'') = '' AND ISNULL(RTRIM(CUS.vwcus_city),'') != '' AND ISNULL(RTRIM(CUS.vwcus_state),'') = '' AND ISNULL(RTRIM(CUS.vwcus_zip),'') != '' THEN
							RTRIM(CUS.vwcus_addr2) + ', ' + RTRIM(CUS.vwcus_city) + ' ' + RTRIM(CUS.vwcus_zip)
		
							When  ISNULL(RTRIM(CUS.vwcus_addr2),'') != '' AND ISNULL(RTRIM(CUS.vwcus_addr),'') = '' AND ISNULL(RTRIM(CUS.vwcus_city),'') != '' AND ISNULL(RTRIM(CUS.vwcus_state),'') != '' AND ISNULL(RTRIM(CUS.vwcus_zip),'') = '' THEN
							RTRIM(CUS.vwcus_addr2) + ', ' + RTRIM(CUS.vwcus_city) + ', ' + RTRIM(CUS.vwcus_state) 
		
							When  ISNULL(RTRIM(CUS.vwcus_addr2),'') = '' AND ISNULL(RTRIM(CUS.vwcus_addr),'') != '' AND ISNULL(RTRIM(CUS.vwcus_city),'') = '' AND ISNULL(RTRIM(CUS.vwcus_state),'') != '' AND ISNULL(RTRIM(CUS.vwcus_zip),'') != '' THEN
							RTRIM(CUS.vwcus_addr) + ', ' + RTRIM(CUS.vwcus_state) + ' ' + RTRIM(CUS.vwcus_zip)
		
							When  ISNULL(RTRIM(CUS.vwcus_addr2),'') = '' AND ISNULL(RTRIM(CUS.vwcus_addr),'') != '' AND ISNULL(RTRIM(CUS.vwcus_city),'') != '' AND ISNULL(RTRIM(CUS.vwcus_state),'') = '' AND ISNULL(RTRIM(CUS.vwcus_zip),'') != '' THEN
							RTRIM(CUS.vwcus_addr) + ', ' + RTRIM(CUS.vwcus_city) + ' ' + RTRIM(CUS.vwcus_zip)
		
							When  ISNULL(RTRIM(CUS.vwcus_addr2),'') = '' AND ISNULL(RTRIM(CUS.vwcus_addr),'') != '' AND ISNULL(RTRIM(CUS.vwcus_city),'') != '' AND ISNULL(RTRIM(CUS.vwcus_state),'') != '' AND ISNULL(RTRIM(CUS.vwcus_zip),'') = '' THEN
							RTRIM(CUS.vwcus_addr) + ', ' + RTRIM(CUS.vwcus_city) + ', ' + RTRIM(CUS.vwcus_state)
		
							When  ISNULL(RTRIM(CUS.vwcus_addr2),'') != '' AND ISNULL(RTRIM(CUS.vwcus_addr),'') != '' AND ISNULL(RTRIM(CUS.vwcus_city),'') = '' AND ISNULL(RTRIM(CUS.vwcus_state),'') = '' AND ISNULL(RTRIM(CUS.vwcus_zip),'') != '' THEN
							RTRIM(CUS.vwcus_addr) + ', ' + RTRIM(CUS.vwcus_addr2) + ' ' + RTRIM(CUS.vwcus_zip)
		
							When  ISNULL(RTRIM(CUS.vwcus_addr2),'') != '' AND ISNULL(RTRIM(CUS.vwcus_addr),'') != '' AND ISNULL(RTRIM(CUS.vwcus_city),'') = '' AND ISNULL(RTRIM(CUS.vwcus_state),'') != '' AND ISNULL(RTRIM(CUS.vwcus_zip),'') = '' THEN
							RTRIM(CUS.vwcus_addr) + ', ' + RTRIM(CUS.vwcus_addr2) + ', ' + RTRIM(CUS.vwcus_state)
		
							When  ISNULL(RTRIM(CUS.vwcus_addr2),'') != '' AND ISNULL(RTRIM(CUS.vwcus_addr),'') != '' AND ISNULL(RTRIM(CUS.vwcus_city),'') != '' AND ISNULL(RTRIM(CUS.vwcus_state),'') = '' AND ISNULL(RTRIM(CUS.vwcus_zip),'') = '' THEN
							RTRIM(CUS.vwcus_addr) + ', ' + RTRIM(CUS.vwcus_addr2) + ', ' + RTRIM(CUS.vwcus_city)

							END) COLLATE Latin1_General_CI_AS
	,dblCustomerPer1 = CUS.vwcus_ar_per1
	,dblCustomerPer2 = CUS.vwcus_ar_per2 
	,dblCustomerPer3 = CUS.vwcus_ar_per3 
	,dblCustomerPer4 = CUS.vwcus_ar_per4
	,strCustomerPhone = CUS.vwcus_phone COLLATE Latin1_General_CI_AS
	,strCustomerPhone2 =  CUS.vwcus_phone2 COLLATE Latin1_General_CI_AS
	,strCustomerTermDescription = (CASE 
									WHEN A.ysnUseDeliveryTermOnCS = 1 THEN 
										ISNULL(B.strTerm,'') 
									WHEN A.ysnUseDeliveryTermOnCS = 0 THEN 
										CUS.vwcus_termdescription
									END) COLLATE Latin1_General_CI_AS
	
	,strSiteAddress = REPLACE(STE.strSiteAddress,CHAR(13),' ') + ', ' + RTRIM(STE.strCity) + ', ' + RTRIM(STE.strState) + ', ' + RTRIM(STE.strZipCode) 
	,strSiteInstruction = STE.strInstruction
	,dtmDateCreated = DATEADD(DAY, DATEDIFF(DAY, 0, WRK.dtmDateCreated), 0)
	,dtmDateScheduled = WRK.dtmDateScheduled
	,strAdditonalInfo = WRK.strAdditionalInfo
	,strPerformer = PRF.strName
	,strPerformerId = PRF.strEntityNo
	,C.strWorkStatus
	,Z.strCompanyName
	,loc.strLocationName
	,CAT.strWorkOrderCategory
FROM tblTMCustomer CST 
INNER JOIN vyuTMCustomerEntityView CUS 
	ON CST.intCustomerNumber = CUS.A4GLIdentity 
INNER JOIN tblTMSite STE 
	ON CST.intCustomerID = STE.intCustomerID
INNER JOIN tblTMWorkOrder WRK 
	ON STE.intSiteID = WRK.intSiteID
LEFT JOIN tblTMWorkStatusType C
	ON WRK.intWorkStatusTypeID = C.intWorkStatusID
LEFT JOIN tblEMEntity PRF 
	ON WRK.intPerformerID = PRF.intEntityId
LEFT JOIN tblSMTerm B
	ON STE.intDeliveryTermID = B.intTermID
LEFT JOIN tblSMCompanyLocation loc
	ON STE.intLocationId = loc.intCompanyLocationId
LEFT JOIN tblTMWorkOrderCategory CAT
	ON WRK.intWorkOrderCategoryId = CAT.intWorkOrderCategoryId
,(SELECT TOP 1 strCompanyName FROM tblSMCompanySetup)Z
,(SELECT TOP 1 ysnUseDeliveryTermOnCS FROM tblTMPreferenceCompany) A 
WHERE STE.ysnActive = 1  AND CUS.vwcus_active_yn = 'Y' 

GO



