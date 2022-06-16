/*
 '====================================================================================================================================='
				
   Script Name         :  Cash Management - Bank Import Script. 
   
   Description		   :  The purpose of this script is to import bank records from the origin system to the i21 system. 

*/
GO
IF	EXISTS(select top 1 1 from sys.procedures where name = 'uspCMImportBanksFromOrigin')
	AND (SELECT TOP 1 ysnUsed FROM #tblOriginMod WHERE strPrefix = 'AP') = 1
BEGIN 
	DROP PROCEDURE uspCMImportBanksFromOrigin

	EXEC('
		CREATE PROCEDURE [dbo].[uspCMImportBanksFromOrigin]
		AS

		-- INSERT new records for tblCMBank
		INSERT INTO tblCMBank (
				strBankName
				,strContact
				,strAddress
				,strZipCode
				,strCity
				,strState
				,strCountry
				,strPhone
				,strFax
				,strWebsite
				,strEmail
				,strRTN
				,intCreatedUserId
				,dtmCreated
				,intLastModifiedUserId
				,dtmLastModified
				,intConcurrencyId
			)
		SELECT 
				strBankName				= LTRIM(RTRIM(ISNULL(Q.ssbnk_name, '''')))
				,strContact				= (SELECT TOP 1 LTRIM(RTRIM(ISNULL(ssbnk_contact,''''))) FROM ssbnkmst WHERE ssbnk_name = Q.ssbnk_name)
				,strAddress				= (SELECT TOP 1 LTRIM(RTRIM(ISNULL(ssbnk_addr1,''''))) + char(13) + LTRIM(RTRIM(ISNULL(ssbnk_addr2,''''))) FROM ssbnkmst WHERE ssbnk_name = Q.ssbnk_name)
				,strZipCode				= (SELECT TOP 1 LTRIM(RTRIM(ISNULL(ssbnk_zip,''''))) FROM ssbnkmst WHERE ssbnk_name = Q.ssbnk_name)
				,strCity				= (SELECT TOP 1 LTRIM(RTRIM(ISNULL(ssbnk_city,''''))) FROM ssbnkmst WHERE ssbnk_name = Q.ssbnk_name)
				,strState				= (SELECT TOP 1 LTRIM(RTRIM(ISNULL(ssbnk_state,''''))) FROM ssbnkmst WHERE ssbnk_name = Q.ssbnk_name)
				,strCountry				= ''''
				,strPhone				= (SELECT TOP 1 LTRIM(RTRIM(ISNULL(ssbnk_phone,''''))) FROM ssbnkmst WHERE ssbnk_name = Q.ssbnk_name)
				,strFax					= ''''
				,strWebsite				= ''''	
				,strEmail				= (SELECT TOP 1 LTRIM(RTRIM(ISNULL(ssbnk_email_addr,''''))) FROM ssbnkmst WHERE ssbnk_name = Q.ssbnk_name)
				,strRTN					= (SELECT TOP 1 ISNULL(CAST(ssbnk_transit_route AS NVARCHAR(12)), '''') FROM ssbnkmst WHERE ssbnk_name = Q.ssbnk_name)
				,intCreatedUserId		= (SELECT TOP 1  dbo.fnConvertOriginUserIdtoi21(ssbnk_user_id) FROM ssbnkmst WHERE ssbnk_name = Q.ssbnk_name)
				,dtmCreated				= GETDATE()
				,intLastModifiedUserId	= (SELECT TOP 1  dbo.fnConvertOriginUserIdtoi21(ssbnk_user_id) FROM ssbnkmst WHERE ssbnk_name = Q.ssbnk_name)
				,dtmLastModified		= GETDATE()
				,intConcurrencyId		= 1
		FROM(
				SELECT DISTINCT ssbnk_name FROM ssbnkmst
			) Q
		WHERE	NOT EXISTS (SELECT TOP 1 1 FROM tblCMBank WHERE strBankName = LTRIM(RTRIM(ISNULL(Q.ssbnk_name, ''''))) COLLATE Latin1_General_CI_AS)
	')
END 
GO