CREATE VIEW [dbo].[vyuSMTerm]
AS 
SELECT [strTerm], [strTermCode], [intDiscountDay], [ysnEnergyTrac]
FROM [tblSMTerm]
--WHERE ysnEnergyTrac = 1