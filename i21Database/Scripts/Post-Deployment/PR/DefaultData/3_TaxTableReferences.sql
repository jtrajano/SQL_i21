/***********************************************************
	Payroll Tax Table Reference values for SQL queries
***********************************************************/

/* 2016 */
IF NOT EXISTS (SELECT TOP 1 1 FROM tblPRTaxTableReference WHERE intYear = 2016) INSERT INTO tblPRTaxTableReference (intYear, dblSSLimit, dblSSEmployeeRate, dblSSEmployerRate, dblMedEmployeeRate, dblMedEmployerRate, dblMedThresholdSingle, dblMedThresholdMarried, intConcurrencyId) VALUES (2016, 118500, 0.062, 0.062, 0.0145, 0.0145, 200000, 125000, 1)

/* 2017 */
IF NOT EXISTS (SELECT TOP 1 1 FROM tblPRTaxTableReference WHERE intYear = 2017) INSERT INTO tblPRTaxTableReference (intYear, dblSSLimit, dblSSEmployeeRate, dblSSEmployerRate, dblMedEmployeeRate, dblMedEmployerRate, dblMedThresholdSingle, dblMedThresholdMarried, intConcurrencyId) VALUES (2017, 127200, 0.062, 0.062, 0.0145, 0.0145, 200000, 125000, 1)
