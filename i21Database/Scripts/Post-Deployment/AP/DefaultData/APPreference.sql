﻿GO
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
		,[intConcurrencyId]		= 1

	--Audit Log          
		EXEC dbo.uspSMAuditLog 
					 @keyValue			= 1									-- Primary Key Value of the Invoice. 
					,@screenName		= 'i21.view.CompanyPreferenceOption'	-- Screen Namespace
					,@entityId			= 1									-- Entity Id.
					,@actionType		= 'Added'							-- Action Type
					,@changeDescription	= 'Updated APPreference'			-- Description
					,@fromValue			= ''								-- Previous Value
					,@toValue			= ''								-- New Value
END
ELSE
BEGIN 
	IF  EXISTS(SELECT 1 FROM  tblAPCompanyPreference WHERE intCheckPrintId IS NULL)
	BEGIN
		UPDATE tblAPCompanyPreference 
		SET intCheckPrintId = 1
		--Audit Log          
		EXEC dbo.uspSMAuditLog 
					 @keyValue			= 1						-- Primary Key Value of the Invoice. 
					,@screenName		= 'i21.view.CompanyPreferenceOption'	-- Screen Namespace
					,@entityId			= 1									-- Entity Id.
					,@actionType		= 'Updated'							-- Action Type
					,@changeDescription	= 'Updated APPreference'			-- Description
					,@fromValue			= ''								-- Previous Value
					,@toValue			= ''								-- New Value
	END

	
END