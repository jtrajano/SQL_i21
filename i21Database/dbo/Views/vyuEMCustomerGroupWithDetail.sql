CREATE VIEW [dbo].[vyuEMCustomerGroupWithDetail]
	AS 
	SELECT
		intCustomerGroupId,
		strGroupName,
		strDescription,
		strCustomerGroupMember = dbo.fnEMGetCustomerGroupMember(a.intCustomerGroupId) COLLATE Latin1_General_CI_AS
			from tblARCustomerGroup a