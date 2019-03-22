CREATE FUNCTION [dbo].[isOpenAccountingDateByModule](@dtmDate DATETIME, @strModuleName NVARCHAR(100))
RETURNS BIT 
AS
BEGIN

DECLARE @isOpen BIT = 0 

SELECT TOP 1 @isOpen = 1 
FROM	dbo.tblGLFiscalYearPeriod 
WHERE	dbo.fnDateGreaterThanEquals(@dtmDate, dtmStartDate) = 1
		AND dbo.fnDateLessThanEquals(@dtmDate, dtmEndDate) = 1
		AND ISNULL(
		CASE 
		WHEN @strModuleName = 'Accounts Receivable' THEN ysnAROpen 
		WHEN @strModuleName = 'Accounts Payable' THEN ysnAPOpen
		WHEN @strModuleName = 'Inventory' THEN ysnINVOpen
		WHEN @strModuleName = 'Cash Management' THEN ysnCMOpen
		WHEN @strModuleName = 'Payroll' THEN ysnPROpen
		WHEN @strModuleName = 'Fixed Assets' THEN ysnFAOpen
		WHEN @strModuleName = 'Contracts' THEN ysnCTOpen
		ELSE 1
		END, 0) = 1
RETURN @isOpen

END