CREATE VIEW [dbo].[vyuICGetCustomerCurrency]
AS

SELECT	c.intEntityId
		, c.strCustomerNumber
		, c.intCurrencyId
		, cr.strCurrency
		, cr.strDescription
		, cr.ysnSubCurrency
		, cr.intMainCurrencyId
		, cr.intCent
		, defaultCurrency.intDefaultCurrencyId
		, defaultCurrency.strDefaultCurrency
FROM	tblARCustomer c INNER JOIN tblSMCurrency cr 
			ON cr.intCurrencyID = c.intCurrencyId
		OUTER APPLY (
			SELECT	TOP 1 
					p.intDefaultCurrencyId
					, pc.strCurrency strDefaultCurrency
			FROM	tblSMCompanyPreference p INNER JOIN tblSMCurrency pc 
						ON pc.intCurrencyID = p.intDefaultCurrencyId
		) defaultCurrency