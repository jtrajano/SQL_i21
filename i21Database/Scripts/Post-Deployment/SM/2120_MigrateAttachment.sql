PRINT N'START MIGRATE ATTACHMENT'
BEGIN

-- START - Insert 'view' to strScreen
UPDATE		dbo.tblSMAttachment
SET			strScreen = STUFF(strScreen, CHARINDEX('.', strScreen), 0, '.view')
WHERE		LEN(strScreen) - LEN(REPLACE(strScreen, '.', '')) < 2
-- END - Insert 'view' to strScreen

-- START - Datafix for incorrect strRecordNo in BankReconciliation records
UPDATE		dbo.tblSMAttachment
SET			strRecordNo = SUBSTRING(REPLACE(strRecordNo, 'BankRec-', ''), 0, CHARINDEX('-',REPLACE(strRecordNo, 'BankRec-', '')))
WHERE		strScreen = 'CashManagement.view.BankReconciliation'
		AND	strRecordNo LIKE 'BankRec%'
-- END - Datafix for incorrect strRecordNo in BankReconciliation records

-- START - Create tblSMScreen records that are not existing
INSERT INTO tblSMScreen (strNamespace, strScreenId, strScreenName, strModule)
	SELECT				DISTINCT strScreen AS strNamespace,
						'' AS strScreenId,
						dbo.fnSMAddSpaceToTitleCase(SUBSTRING(SUBSTRING(a.strScreen,CHARINDEX('.',a.strScreen) + 1, LEN(a.strScreen)), CHARINDEX('.', SUBSTRING(a.strScreen,CHARINDEX('.',a.strScreen) + 1, LEN(a.strScreen))) + 1, LEN(SUBSTRING(a.strScreen,CHARINDEX('.',a.strScreen) + 1, LEN(a.strScreen)))), 0) AS strScreenName,
						CASE WHEN SUBSTRING(a.strScreen,0,CHARINDEX('.',a.strScreen)) = 'i21' THEN 'System Manager'  --module
	 					ELSE dbo.fnSMAddSpaceToTitleCase(SUBSTRING(a.strScreen,0,CHARINDEX('.',a.strScreen)),0) END AS strModule
	FROM				dbo.tblSMAttachment AS a
	LEFT OUTER JOIN		tblSMScreen AS b 
	ON					b.strNamespace = a.strScreen
	WHERE				ISNULL(b.strNamespace,'') = '' AND ISNULL(a.strScreen,'') <> ''
-- END - Create tblSMScreen records that are not existing

-- START - Create tblSMTransaction records that are not existing
INSERT INTO tblSMTransaction (intScreenId, intRecordId, intConcurrencyId)
SELECT 
	DISTINCT 
	A.intScreenId,
	CAST(A.strRecordNo AS INT),
	1
FROM 
	(  
		SELECT 
			E.strScreen,
			F.intScreenId,
			E.strRecordNo
		FROM tblSMAttachment E
		INNER JOIN tblSMScreen F ON E.strScreen = F.strNamespace
	) A LEFT OUTER JOIN 
	tblSMTransaction B ON A.intScreenId = B.intScreenId AND CAST(A.strRecordNo AS INT) = B.intRecordId 
WHERE		ISNULL(B.intRecordId, '') = '' 
		AND ISNULL(A.strRecordNo, '') <> '' 
		AND ISNULL(A.strRecordNo, '') <> 0 
		--AND A.strScreen <> 'CashManagement.view.BankReconciliation'
-- END - Create tblSMTransaction records that are not existing

-- START - Update intTransactionId column based on strScreen and strRecordNo
UPDATE		dbo.tblSMAttachment
SET			intTransactionId = (SELECT		a.intTransactionId
								FROM		dbo.tblSMTransaction AS a
								INNER JOIN	dbo.tblSMScreen AS b
								ON			a.intScreenId = b.intScreenId
								WHERE		b.strNamespace = c.strScreen AND
											a.intRecordId = c.strRecordNo)
FROM		dbo.tblSMAttachment AS c
WHERE		c.intTransactionId IS NULL
		--AND c.strScreen <> 'CashManagement.view.BankReconciliation'
-- END - Update intTransactionId column based on strScreen and strRecordNo

END
PRINT N'END MIGRATE ATTACHMENT'