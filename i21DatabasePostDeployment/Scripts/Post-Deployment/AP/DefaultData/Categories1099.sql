GO
MERGE INTO tblAP1099Category AS Target
USING (VALUES
  (1, N'Crop Insurance Proceeds'),
  (2, N'Direct Sales'),
  (3, N'Excess Golden Parachute Payments'),
  (4, N'Federal Income Tax Withheld'),
  (5, N'Fishing Boat Proceeds'),
  (6, N'Gross Proceeds Paid to an Attorney'),
  (7, N'Medical and Health Care Payments'),
  (8, N'Nonemployee Compensation'),
  (9, N'Other Income'),
  (10, N'Rents'),
  (11, N'Royalties'),
  (12, N'Substitute Payments in Lieu of Dividends or Interest')
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