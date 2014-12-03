GO
--NOTE When adding new status please add on the last record.
MERGE INTO tblPOOrderStatus AS Target
USING (VALUES
  (1, N'Open'),
  (2, N'Pending'),
  (3, N'Partial'),
  (4, N'Closed'),
  (5, N'Cancelled'),
  (6, N'Washed Out'),
  (7, N'Short Closed')
)
AS Source (intOrderStatusId, strStatus)
ON Target.intOrderStatusId = Source.intOrderStatusId AND Target.strStatus = Source.strStatus
-- update matched rows
WHEN MATCHED THEN
UPDATE SET strStatus = Source.strStatus
-- insert new rows
WHEN NOT MATCHED BY TARGET THEN
INSERT (intOrderStatusId, strStatus)
VALUES (intOrderStatusId, strStatus);
GO