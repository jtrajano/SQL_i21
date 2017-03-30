CREATE VIEW [dbo].[vyuEMSearchEntityEmployeeTax]
	AS


	SELECT 
			d.intEmployeeTaxId,
			a.intEntityId,   
			a.strEntityNo, 
			a.strName,
			e.strTax,
			e.strDescription,
			e.strPaidBy,
			e.strCalculationType,
			d.strFilingStatus,
			f.strState,
			g.strLocalName,
			d.dblAmount,
			d.dblExtraWithholding,
			d.dblLimit,
			strLiabilityAccount = h.strAccountId,--
			strExpenseAccount = i.strAccountId,--
			d.intAllowance,
			strSchool = Case WHEN f.strState = 'Ohio' then d.strVal1 when f.strState = 'Pennsylvania' then d.strVal2 else '' end,
			strMunicipality = Case WHEN f.strState = 'Ohio' then d.strVal2 when f.strState = 'Pennsylvania' then d.strVal3 else '' end,
			c.intRank

		FROM 		
				tblEMEntity a
			join [tblEMEntityType] b
				on b.intEntityId = a.intEntityId and b.strType = 'Employee'		
			join tblPREmployee c
				on c.[intEntityId] = a.intEntityId
			join tblPREmployeeTax d
				on d.intEntityEmployeeId = a.intEntityId
			join tblPRTypeTax e
				on e.intTypeTaxId= d.intTypeTaxId
			left join tblPRTypeTaxState f
				on f.intTypeTaxStateId = d.intTypeTaxStateId
			left join tblPRTypeTaxLocal g
				on g.intTypeTaxLocalId = d.intTypeTaxLocalId
			left join tblGLAccount h
				on h.intAccountId = d.intAccountId
			left join tblGLAccount i
				on i.intAccountId = d.intExpenseAccountId
			