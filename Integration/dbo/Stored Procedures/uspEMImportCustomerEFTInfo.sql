IF EXISTS(select top 1 1 from sys.procedures where name = 'uspEMImportCustomerEFTInfo')
	DROP PROCEDURE uspEMImportCustomerEFTInfo
GO

CREATE PROCEDURE [dbo].[uspEMImportCustomerEFTInfo]
	@Checking BIT = 0,
	@Total INT = 0 OUTPUT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	--==========================================================
	--     Insert into [tblEMEntityEFTInformation] - Customer EFT/ACH  
	--==========================================================
	
	DECLARE @BankCount INT

	SELECT @BankCount = COUNT(*) FROM (SELECT DISTINCT ssbnk_name FROM ssbnkmst
		) Q
	WHERE	NOT EXISTS (SELECT TOP 1 1 FROM tblCMBank WHERE strBankName = LTRIM(RTRIM(ISNULL(Q.ssbnk_name, ''))) COLLATE Latin1_General_CI_AS)
	
	IF @BankCount <> 0 
	BEGIN
		EXEC uspCMImportBanksFromOrigin
	END		 	

	IF(@Checking = 0)
	BEGIN
	
		INSERT INTO [dbo].[tblEMEntityEFTInformation]
				   ([intEntityId]             
		   			,[intBankId]               
		   			,[strBankName]             
		   			,[strAccountNumber]        
		   			,[strAccountType]          
		   			,[strAccountClassification]
		   			,[dtmEffectiveDate]        
		   			,[ysnPrintNotifications]   
		   			,[ysnActive]               
		   			,[strPullARBy]             
		   			,[ysnPullTaxSeparately]    
		   			,[ysnRefundBudgetCredits]  
		   			,[ysnPrenoteSent] 
					,[dblAmount]
					,[intOrder]         				  
		   			,[strEFTType]				
		   			,[intConcurrencyId])
		SELECT CUS.intEntityId --[intEntityId]            
		   	,BNK.[intBankId] --[intBankId]              
		   	,BNK.[strBankName] --[strBankName]            
		   	,EFT.efeft_account_no--[strAccountNumber]        
		   	,CASE WHEN EFT.efeft_acct_type = 'C' THEN 'Checking' ELSE 'Saving' END --[strAccountType]          
		   	,CASE WHEN EFT.efeft_acct_class_cp = 'C' THEN 'Corporate' ELSE 'Personal' END --strAccountClassification
		   	,CONVERT(DATETIME, CAST(EFT.efeft_effective_date AS CHAR(12)), 112) --[dtmEffectiveDate]        
		   	,CASE WHEN EFT.efeft_notify_yn = 'Y' THEN 1 ELSE 0 END  --[ysnPrintNotifications]   
		   	,CASE WHEN EFT.efeft_active_yn = 'Y' THEN 1 ELSE 0 END --[ysnActive]               
		   	,CASE WHEN EFT.efeft_pull_type_bfis = 'S' THEN 'Statement Amount'
				  WHEN EFT.efeft_pull_type_bfis = 'B' THEN 'Budget Amount'
				  ELSE 'Invoice by Terms' END --[strPullARBy]             
		   	,CASE WHEN EFT.efeft_pull_tax_separate_yn = 'Y' THEN 1 ELSE 0 END --[ysnPullTaxSeparately]    
		   	,CASE WHEN EFT.efeft_refund_bdgt_credits_yn = 'Y' THEN 1 ELSE 0 END --[ysnRefundBudgetCredits]  
		   	,CASE WHEN EFT.efeft_last_prenote_date <> 0 THEN 1 ELSE 0 END --[ysnPrenoteSent] 
			,ISNULL(EFT.efeft_flat_amt,0) --dblAmount
			,0 --intOrder           				  				  
		   	,CASE WHEN EFT.efeft_src_sys ='AP' THEN 'Accounts Payable' 
				  WHEN EFT.efeft_src_sys ='AR' THEN 'Accounts Receivable' 
				  ELSE 'Payroll' END--[strEFTType]				
		   	,1--[intConcurrencyId]
		 FROM efeftmst EFT 
		INNER JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = EFT.efeft_eft_no COLLATE SQL_Latin1_General_CP1_CS_AS
		LEFT  JOIN ssbnkmst OBNK ON OBNK.ssbnk_code = EFT.efeft_bnk_no
		INNER JOIN tblCMBank BNK ON BNK.strBankName COLLATE SQL_Latin1_General_CP1_CS_AS = OBNK.ssbnk_name COLLATE SQL_Latin1_General_CP1_CS_AS
		WHERE EFT.efeft_eft_type_cv = 'C' AND  CUS.intEntityId NOT IN (SELECT intEntityId FROM [tblEMEntityEFTInformation] WHERE intEntityId = CUS.intEntityId
		AND (CASE WHEN EFT.efeft_src_sys ='AP' THEN 'Accounts Payable' WHEN EFT.efeft_src_sys ='AR' THEN 'Accounts Receivable' ELSE 'Payroll' END) = [strEFTType])

		INSERT INTO [dbo].[tblEMEntityEFTInformation]
				   ([intEntityId]             
		   			,[intBankId]               
		   			,[strBankName]             
		   			,[strAccountNumber]        
		   			,[strAccountType]          
		   			,[strAccountClassification]
		   			,[dtmEffectiveDate]        
		   			,[ysnPrintNotifications]   
		   			,[ysnActive]               
		   			,[strPullARBy]             
		   			,[ysnPullTaxSeparately]    
		   			,[ysnRefundBudgetCredits]  
		   			,[ysnPrenoteSent] 
					,[dblAmount]
					,[intOrder]         				  
		   			,[strEFTType]				
		   			,[intConcurrencyId])
		SELECT VND.intEntityId --[intEntityId]            
		   	,BNK.[intBankId] --[intBankId]              
		   	,BNK.[strBankName] --[strBankName]            
		   	,EFT.efeft_account_no--[strAccountNumber]        
		   	,CASE WHEN EFT.efeft_acct_type = 'C' THEN 'Checking' ELSE 'Saving' END --[strAccountType]          
		   	,CASE WHEN EFT.efeft_acct_class_cp = 'C' THEN 'Corporate' ELSE 'Personal' END --strAccountClassification
		   	,CONVERT(DATETIME, CAST(EFT.efeft_effective_date AS CHAR(12)), 112) --[dtmEffectiveDate]        
		   	,CASE WHEN EFT.efeft_notify_yn = 'Y' THEN 1 ELSE 0 END  --[ysnPrintNotifications]   
		   	,CASE WHEN EFT.efeft_active_yn = 'Y' THEN 1 ELSE 0 END --[ysnActive]               
		   	,CASE WHEN EFT.efeft_pull_type_bfis = 'S' THEN 'Statement Amount'
				  WHEN EFT.efeft_pull_type_bfis = 'B' THEN 'Budget Amount'
				  ELSE 'Invoice by Terms' END --[strPullARBy]             
		   	,CASE WHEN EFT.efeft_pull_tax_separate_yn = 'Y' THEN 1 ELSE 0 END --[ysnPullTaxSeparately]    
		   	,CASE WHEN EFT.efeft_refund_bdgt_credits_yn = 'Y' THEN 1 ELSE 0 END --[ysnRefundBudgetCredits]  
		   	,CASE WHEN EFT.efeft_last_prenote_date <> 0 THEN 1 ELSE 0 END --[ysnPrenoteSent] 
			,ISNULL(EFT.efeft_flat_amt,0) --dblAmount
			,0 --intOrder           				  				  
		   	,CASE WHEN EFT.efeft_src_sys ='AP' THEN 'Accounts Payable' 
				  WHEN EFT.efeft_src_sys ='AR' THEN 'Accounts Receivable' 
				  ELSE 'Payroll' END--[strEFTType]				
		   	,1--[intConcurrencyId]
		 FROM efeftmst EFT 
		INNER JOIN tblAPVendor VND ON VND.strVendorId COLLATE SQL_Latin1_General_CP1_CS_AS = EFT.efeft_eft_no COLLATE SQL_Latin1_General_CP1_CS_AS
		LEFT  JOIN ssbnkmst OBNK ON OBNK.ssbnk_code = EFT.efeft_bnk_no
		INNER JOIN tblCMBank BNK ON BNK.strBankName COLLATE SQL_Latin1_General_CP1_CS_AS = OBNK.ssbnk_name COLLATE SQL_Latin1_General_CP1_CS_AS
		WHERE EFT.efeft_eft_type_cv = 'V' AND  VND.intEntityId NOT IN (SELECT intEntityId FROM [tblEMEntityEFTInformation] WHERE intEntityId = VND.intEntityId
		AND (CASE WHEN EFT.efeft_src_sys ='AP' THEN 'Accounts Payable' WHEN EFT.efeft_src_sys ='AR' THEN 'Accounts Receivable' ELSE 'Payroll' END) = [strEFTType])
	END


	IF(@Checking = 1)
	BEGIN
	
		SELECT @Total = COUNT(efeft_eft_no)
		 FROM efeftmst EFT 
		INNER JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = EFT.efeft_eft_no COLLATE SQL_Latin1_General_CP1_CS_AS
		LEFT  JOIN ssbnkmst OBNK ON OBNK.ssbnk_code = EFT.efeft_bnk_no
		INNER JOIN tblCMBank BNK ON BNK.strBankName COLLATE SQL_Latin1_General_CP1_CS_AS = OBNK.ssbnk_name COLLATE SQL_Latin1_General_CP1_CS_AS
		WHERE  EFT.efeft_eft_type_cv = 'C' AND CUS.intEntityId NOT IN (SELECT intEntityId FROM [tblEMEntityEFTInformation] WHERE intEntityId = CUS.intEntityId
		AND (CASE WHEN EFT.efeft_src_sys ='AP' THEN 'Accounts Payable' WHEN EFT.efeft_src_sys ='AR' THEN 'Accounts Receivable' ELSE 'Payroll' END) = [strEFTType])

		SET @Total = @Total + (SELECT COUNT(efeft_eft_no)
		FROM efeftmst EFT 
		INNER JOIN tblAPVendor VND ON VND.strVendorId COLLATE SQL_Latin1_General_CP1_CS_AS = EFT.efeft_eft_no COLLATE SQL_Latin1_General_CP1_CS_AS
		LEFT  JOIN ssbnkmst OBNK ON OBNK.ssbnk_code = EFT.efeft_bnk_no
		INNER JOIN tblCMBank BNK ON BNK.strBankName COLLATE SQL_Latin1_General_CP1_CS_AS = OBNK.ssbnk_name COLLATE SQL_Latin1_General_CP1_CS_AS
		WHERE EFT.efeft_eft_type_cv = 'V' AND  VND.intEntityId NOT IN (SELECT intEntityId FROM [tblEMEntityEFTInformation] WHERE intEntityId = VND.intEntityId
		AND (CASE WHEN EFT.efeft_src_sys ='AP' THEN 'Accounts Payable' WHEN EFT.efeft_src_sys ='AR' THEN 'Accounts Receivable' ELSE 'Payroll' END) = [strEFTType]))

		RETURN @Total
	END

END

GO


