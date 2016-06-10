CREATE VIEW [dbo].[vyuSMTerm]
AS 
SELECT [Location].[strLocationNumber] AS [trloc], 
[Term].[strTerm] AS [trdesc], 
[Term].[strTermCode] AS [trtrm], 
[Term].[intDiscountDay] AS [trdays],
'D' AS [trtype],
'0.000000' AS [trpct],
'N' AS [ovr_price]
FROM tblSMCompanyLocation Location 
CROSS JOIN tblSMTerm Term
--WHERE [Term].[ysnEnergyTrac] = 1