GO
	IF EXISTS(SELECT strScreenId FROM tblSMScreen WHERE strScreenId =  'My Company (Portal)')
	BEGIN
		DELETE FROM tblSMScreen WHERE strScreenId = 'My Company (Portal)'
	END

	IF EXISTS(SELECT * FROM tblSMScreen WHERE strNamespace LIKE '%AccountsReceivable.view.EntityCustomer%')
	BEGIN
		WITH cte AS (
		SELECT row_number() OVER(PARTITION BY strNamespace ORDER BY intScreenId ) AS [rn]
		FROM tblSMScreen
		where strNamespace like '%AccountsReceivable.view.EntityCustomer%'
		)
		DELETE cte WHERE [rn] > 1
	END
GO