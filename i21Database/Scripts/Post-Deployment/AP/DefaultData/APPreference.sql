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
		IF @entityId IS NOT NULL
		BEGIN
			EXEC dbo.uspSMAuditLog 
						 @keyValue			= 1									-- Primary Key Value of the Invoice. 
						,@screenName		= 'AccountsPayable.view.CompanyPreferenceOption'	-- Screen Namespace
						,@entityId			= 1									-- Entity Id.
						,@actionType		= 'Added'							-- Action Type
						,@changeDescription	= 'Check Print Options'			-- Description
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
					,@entityId			= 1									-- Entity Id.
					,@actionType		= 'Updated'							-- Action Type
					,@changeDescription	= 'Check Print Options'			-- Description
					,@fromValue			= '0'								-- Previous Value
					,@toValue			= '1'								-- New Value
		END		
	END
END