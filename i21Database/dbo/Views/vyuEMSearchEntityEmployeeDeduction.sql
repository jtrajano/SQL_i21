CREATE VIEW [dbo].[vyuEMSearchEntityEmployeeDeduction]
	AS 

	SELECT 
			d.intEmployeeDeductionId,
			a.intEntityId,   
			a.strEntityNo, 
			a.strName,  
			e.strDeduction,
			d.dblAmount,
			c.intRank

		FROM 		
				tblEMEntity a
			join [tblEMEntityType] b
				on b.intEntityId = a.intEntityId and b.strType = 'Employee'		
			join tblPREmployee c
				on c.[intEntityId] = a.intEntityId
			join tblPREmployeeDeduction d
				on d.intEntityEmployeeId = a.intEntityId
			join tblPRTypeDeduction e
				on d.intTypeDeductionId  = e.intTypeDeductionId
