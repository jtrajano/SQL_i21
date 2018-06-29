CREATE VIEW [dbo].[vyuEMCustomerGroupWithDetail]
	AS 
	SELECT
		intCustomerGroupId,
		strGroupName,
		strDescription,
		strCustomerGroupMember = dbo.fnEMGetCustomerGroupMember(a.intCustomerGroupId)  
			from tblARCustomerGroup a