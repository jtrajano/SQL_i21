CREATE VIEW [dbo].[vyuEMSearchEntityEmployeeEarnings]
	AS 


	SELECT 
			d.intEmployeeEarningId,
			a.intEntityId,   
			a.strEntityNo, 
			a.strName,  
			e.strEarning,
			d.dblRateAmount,
			f.strPayGroup,
			c.intRank

		FROM 		
				tblEMEntity a
			join [tblEMEntityType] b
				on b.intEntityId = a.intEntityId and b.strType = 'Employee'		
			join tblPREmployee c
				on c.[intEntityId] = a.intEntityId
			join tblPREmployeeEarning d
				on d.intEntityEmployeeId = a.intEntityId
			join tblPRTypeEarning e
				on e.intTypeEarningId = d.intTypeEarningId
			join tblPRPayGroup f
				on d.intPayGroupId = f.intPayGroupId

		
