GO
PRINT 'Start Tax Report Type Upsert'
declare @TempTaxReportType table (
	intId				INT,
	strType				NVARCHAR(100),
	intSort				INT

)
INSERT INTO @TempTaxReportType(intId, strType, intSort)
values	(1, 'Checkoff Tax', 1),
		(2, 'City Sales Tax', 2),
		(3,	'City Excise Tax', 3),
		(4, 'County Sales Tax', 4),
		(5, 'County Excise Tax', 5),
		(6, 'Federal Excise Tax', 6),
		(7, 'Federal Lust Tax', 7),
		(8, 'Federal Oil Spill Tax', 8),
		(9, 'Federal Other Tax', 9),
		(10, 'Local Other Tax', 10),
		(11, 'Prepaid Sales Tax', 11),
		(12, 'State Excise Tax', 12),
		(13, 'State Other Tax', 13),
		(14, 'State Sales Tax', 14),
		(15, 'Tonnage Tax', 15)


SET IDENTITY_INSERT  tblSMTaxReportType ON 

MERGE dbo.tblSMTaxReportType AS t
USING (select intId, strType, intSort from @TempTaxReportType) AS s
    ON t.intTaxReportTypeId = s.intId
WHEN NOT MATCHED THEN 
    INSERT (intTaxReportTypeId, strType, intSort, ysnSystemDefault) 
    VALUES (s.intId, s.strType, s.intSort, 1);





SET IDENTITY_INSERT  tblSMTaxReportType OFF

PRINT 'End Tax Report Type Upsert'
GO