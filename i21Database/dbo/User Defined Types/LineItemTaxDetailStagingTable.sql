/*
	This is a user-defined table type used in inserting tax details to line items. 
*/
CREATE TYPE [dbo].[LineItemTaxDetailStagingTable] AS TABLE
(		
	 [intId]								INT				 																																								
	,[intDetailId]							INT												NULL		-- Id of the line item record
	--,[intInvoiceDetailTaxId]				INT												NULL		-- Invoice Detail Tax Id(Insert new if NULL, else Update existing) 
	,[intDetailTaxId]						INT												NULL		-- Invoice Detail Tax Id(Insert new if NULL, else Update existing) 
	,[intTaxGroupId]						INT												NULL		-- Key Value tblSMTaxGroup.intTaxGroupId
	,[intTaxCodeId]							INT												NOT NULL	-- Key Value tblSMTaxCode.intTaxCodeId
	,[intTaxClassId]						INT												NULL		-- Key Value tblSMTaxClass.intTaxClassId
	,[strTaxableByOtherTaxes]				NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS	NULL		
	,[strCalculationMethod]					NVARCHAR(15)	COLLATE Latin1_General_CI_AS	NULL		
	,[dblRate]								NUMERIC(18, 6)									NULL		-- Tax Rate
	,[intTaxAccountId]						INT												NULL		-- Key Value tblGLAccount.intAccountId
	,[dblTax]								NUMERIC(18, 6)									NULL		-- The computed tax amount based from the Tax Code setup
	,[dblAdjustedTax]						NUMERIC(18, 6)									NULL		-- The tax adjusted amount either manually or programmatically
	,[ysnTaxAdjusted]						BIT												NULL		
	,[ysnSeparateOnInvoice]					BIT												NULL		
	,[ysnCheckoffTax]						BIT												NULL		
	,[ysnTaxExempt]							BIT												NULL		-- Indicate whether the tax code is marked as exempted
	,[strNotes]								NVARCHAR(500)	COLLATE Latin1_General_CI_AS	NULL		-- Details of exemption
	,[intTempDetailIdForTaxes]				INT												NULL		-- Temporary Id of parent line item detail (InvoiceIntegrationStagingTable) which are also fro processing
)
