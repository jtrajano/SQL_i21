CREATE VIEW [dbo].[vyuMFYield]
AS 
/****************************************************************
	Title: Yield View
	Description: 23.1 Merging of Old Codes
	JIRA: MFG-4651
	Created By: Jonathan Valenzuela
	Date: 07/07/2023
*****************************************************************/
SELECT Yield.intYieldId
	 , Yield.intManufacturingProcessId
	 , Yield.strInputFormula
	 , Yield.strOutputFormula
	 , Yield.strYieldFormula
	 , Yield.intConcurrencyId
	 , ManufacturingProcess.strProcessName
FROM tblMFYield AS Yield
OUTER APPLY (SELECT TOP 1 strProcessName
			 FROM tblMFManufacturingProcess AS MFManufacturingProcess
			 WHERE MFManufacturingProcess.intManufacturingProcessId = Yield.intManufacturingProcessId) AS ManufacturingProcess
