CREATE TABLE [dbo].[tblApiSchemaCCVendorSite]
(
	guiApiUniqueId              UNIQUEIDENTIFIER NOT NULL,
    intRowNumber                INT NULL,
    intKey                      INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
	
	strAccount					NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,	-- Account					| Required
	strCustomerNumber			NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,		-- Customer	Number			| Required
	strVendorNumber				NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,		-- Vendor Number			| Required
	strSite						NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,	-- Site						| Required
	strSiteType					NVARCHAR(10) COLLATE Latin1_General_CI_AS NOT NULL,		-- Site Type Flag			| Required
	strPayType					NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,	-- AR Pay Type				| Required
	strFeeExpenseGL				NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,			-- Fee Expense GL			| Required Only If strSiteType = 'I'
	dblSharedFee				NUMERIC(18, 6) NULL,									-- Shared Fee				| Optional
	ysnPostNet					BIT NULL DEFAULT ((1))									-- Post Net					| Optional
)

