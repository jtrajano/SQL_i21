CREATE VIEW [dbo].[vyuEMSearchEntityEmployeeDirectDeposit]
	AS 


	SELECT 
			d.intEntityEFTInfoId,
			a.intEntityId,   
			a.strEntityNo, 
			a.strName,  
			d.strBankName,
			d.strAccountNumber,
			c.intRank,

			d.strAccountType,
			d.dtmEffectiveDate,
			d.strDistributionType,
			d.dblAmount,
			d.intOrder,
			d.ysnActive
		FROM 		
				tblEMEntity a
			join [tblEMEntityType] b
				on b.intEntityId = a.intEntityId and b.strType = 'Employee'
			join tblPREmployee c
				on a.intEntityId = c.[intEntityId]
			join tblEMEntityEFTInformation d
				on d.intEntityId = a.intEntityId
		
