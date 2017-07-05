PRINT('CT - 172To173 Started')

GO
UPDATE tblCTWeightGrade SET strWhereFinalized = CASE WHEN strWhereFinalized = '1' THEN 'Origin' ELSE 'Destination' END WHERE strWhereFinalized IN ('1','2')
GO


PRINT('CT - 172To173 End')