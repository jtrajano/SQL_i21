GO

DECLARE @entityId INT
SELECT TOP 1 @entityId = intEntityId FROM tblEMEntity

IF NOT EXISTS(SELECT 1 FROM  tblAPCompanyPreference)
BEGIN
	INSERT INTO  tblAPCompanyPreference (
		[intApprovalListId]	   
		,[intDefaultAccountId]  
		,[intWithholdAccountId] 
		,[intDiscountAccountId] 
		,[intInterestAccountId] 
		,[dblWithholdPercent]
		,[strReportGroupName]
		,[strClaimReportName]
		,[intCheckPrintId]
		,[intVoucherInvoiceNoOption]
		,[intDebitMemoInvoiceNoOption]
		,[ysnRemittanceAdvice_DisplayVendorAccountNumber]
		,[intConcurrencyId] 
	)
	SELECT
		
		[intApprovalListId]		= NULL
		,[intDefaultAccountId]	= NULL 
		,[intWithholdAccountId] = NULL
		,[intDiscountAccountId] = NULL
		,[intInterestAccountId] = NULL
		,[dblWithholdPercent]	= 0.00
		,[strReportGroupName]	= ''
		,[strClaimReportName]	= ''
		,[intCheckPrintId]		= 1
		,[intVoucherInvoiceNoOption] = NULL -- Blank
		,[intDebitMemoInvoiceNoOption] = NULL -- Blank
		,CAST(1 AS BIT )
		,[intConcurrencyId]		= 1

		--Audit Log          
		IF @entityId IS NOT NULL
		BEGIN
			EXEC dbo.uspSMAuditLog 
						 @keyValue			= 1									-- Primary Key Value of the Invoice. 
						,@screenName		= 'AccountsPayable.view.CompanyPreferenceOption'	-- Screen Namespace
						,@entityId			= null									-- Entity Id.
						,@actionType		= 'Added'							-- Action Type
						,@changeDescription	= 'Check Print Options For Accounts Payable Company Preference Option Default Data'			-- Description
						,@fromValue			= '0'								-- Previous Value
						,@toValue			= '1'								-- New Value
		END
END
ELSE
BEGIN 
	IF  EXISTS(SELECT 1 FROM  tblAPCompanyPreference WHERE intCheckPrintId IS NULL)
	BEGIN
		UPDATE tblAPCompanyPreference 
		SET intCheckPrintId = 1
		--Audit Log          
		IF @entityId IS NOT NULL
		BEGIN
			EXEC dbo.uspSMAuditLog 
					 @keyValue			= 1						-- Primary Key Value of the Invoice. 
					,@screenName		= 'AccountsPayable.view.CompanyPreferenceOption'	-- Screen Namespace
					,@entityId			= null									-- Entity Id.
					,@actionType		= 'Updated'							-- Action Type
					,@changeDescription	= 'Check Print Options For Accounts Payable Company Preference Option Default Data'			-- Description
					,@fromValue			= '0'								-- Previous Value
					,@toValue			= '1'								-- New Value
		END		
	END

	IF  EXISTS(SELECT 1 FROM  tblAPCompanyPreference WHERE ysnRemittanceAdvice_DisplayVendorAccountNumber IS NULL)
	BEGIN
		UPDATE tblAPCompanyPreference 
		SET ysnRemittanceAdvice_DisplayVendorAccountNumber = 1        
		IF @entityId IS NOT NULL
		BEGIN
			EXEC dbo.uspSMAuditLog 
					 @keyValue			= 1						-- Primary Key Value of the Invoice. 
					,@screenName		= 'AccountsPayable.view.CompanyPreferenceOption'	-- Screen Namespace
					,@entityId			= null									-- Entity Id.
					,@actionType		= 'Updated'							-- Action Type
					,@changeDescription	= 'Display Vendor Account Number in Remittance Report For Accounts Payable Company Preference Option Default Data'			-- Description
					,@fromValue			= '0'								-- Previous Value
					,@toValue			= '1'								-- New Value
		END		
	END

END
GO
