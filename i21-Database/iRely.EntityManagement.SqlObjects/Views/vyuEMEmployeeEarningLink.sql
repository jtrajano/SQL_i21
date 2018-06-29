CREATE VIEW [dbo].[vyuEMEmployeeEarningLink]
	AS 

select 
	a.intEntityEmployeeId,
	a.intEmployeeEarningId,	
	b.strEarning,
	b.strDescription
	from tblPREmployeeEarning a
		join tblPRTypeEarning b
			on a.intTypeEarningId = b.intTypeEarningId
