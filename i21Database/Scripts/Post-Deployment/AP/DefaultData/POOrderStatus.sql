MERGE INTO tblPOOrderStatus AS Target
USING (VALUES
  (1, N'Open'),
  (2, N'Partial'),
  (3, N'Closed'),
  (4, N'Cancelled'),
  (5, N'Washed Out'),
  (6, N'Short Closed')
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