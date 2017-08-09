CREATE VIEW [dbo].[vyuHDCurrency]
	AS
		select
			f.intCurrencyID
			,f.strCurrency
			,f.strDescription
		from
			tblSMCurrency f
