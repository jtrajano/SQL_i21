print('/*******************  BEGIN Update Commission Schedule Entity *******************/')
GO

UPDATE
	tblARCommissionSchedule
SET
	intEntityId = (SELECT TOP 1 ID.[strDataType] FROM dbo.fnARSplitValues(tblARCommissionSchedule.strEntityIds, ',') ID INNER JOIN tblARCustomer ARC ON CAST(ID.[strDataType] AS INT) = ARC.intEntityId)
WHERE
	LEN(LTRIM(RTRIM(ISNULL(tblARCommissionSchedule.strEntityIds, '')))) > 0
	AND tblARCommissionSchedule.strScheduleType = 'Individual'

GO
print('/*******************  Update Commission Schedule Entity  *******************/')