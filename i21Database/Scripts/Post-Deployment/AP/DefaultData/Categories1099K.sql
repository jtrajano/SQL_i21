GO
MERGE INTO tblAP1099KCategory AS Target
USING (VALUES
  (1, N'Gross Payment Card/Third Party Network'),
  (2, N'Card Not Present')
)
AS Source (int1099CategoryId, strCategory)
ON Target.int1099CategoryId = Source.int1099CategoryId AND Target.strCategory = Source.strCategory
-- update matched rows
WHEN MATCHED THEN
UPDATE SET strCategory = Source.strCategory
-- insert new rows
WHEN NOT MATCHED BY TARGET THEN
INSERT (int1099CategoryId, strCategory)
VALUES (int1099CategoryId, strCategory);
GO