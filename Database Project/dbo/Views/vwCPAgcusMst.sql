CREATE VIEW [dbo].[vwCPAgcusMst]
	AS SELECT
	agcus_key			COLLATE Latin1_General_CI_AS as strCustomerNo,
	agcus_first_name	COLLATE Latin1_General_CI_AS as strCustomerFirstName,
	agcus_last_name		COLLATE Latin1_General_CI_AS as strCustomerLastName,
	CAST(A4GLIdentity AS INT) as A4GLIdentity	
FROM agcusmst
