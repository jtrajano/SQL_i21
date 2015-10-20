--THIS WILL UPDATE THE tblAPBill.intCurrencyId
IF(EXISTS(SELECT 1 FROM sys.objects WHERE name = 'tblAPBill') AND EXISTS(SELECT 1 FROM sys.objects WHERE name = 'tblSMCurrency'))
BEGIN
	EXEC('
		UPDATE A
			SET A.intCurrencyId = (SELECT TOP 1 intCurrencyID FROM tblSMCurrency WHERE strCurrency LIKE  ''%USD%'')
		FROM tblAPBill A
		WHERE A.intCurrencyId IS NULL OR A.intCurrencyId = 0
	')
END