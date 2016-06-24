CREATE VIEW [dbo].[vyuEMSearchEntityEmployeeDirectDeposit]
	AS 


	SELECT 
			d.intEntityEFTInfoId,
			a.intEntityId,   
			a.strEntityNo, 
			a.strName,  
			d.strBankName,
			d.strAccountNumber

		FROM 		
				tblEMEntity a
			join [tblEMEntityType] b
				on b.intEntityId = a.intEntityId and b.strType = 'Employee'		
			join tblEMEntityEFTInformation d
				on d.intEntityId = a.intEntityId
		
