GO
MERGE INTO tblAP1099DIVCategory AS Target
USING (VALUES
  (1, N'Total ordinary dividends'),
  (2, N'Qualified dividends'),
  (3, N'Total capital gain distr.'),
  (4, N'Unrecap. Sec. 1250 gain'),
  (5, N'Section 1202 gain'),
  (6, N'Collectibles (28%) gain'),
  (7, N'Nondividend distributions'),
  (8, N'Federal income tax withheld'),
  (9, N'Investment expenses'),
  (10, N'Foreign tax paid'),
  (11, N'Foreign country or U.S. possession'),
  (12, N'Cash liquidation distributions'),
  (13, N'Noncash liquidation distributions'),
  (14, N'Exempt-interest dividends'),
  (15, N'Specified private activity bond interest dividends'),
  (16, N'State tax withheld')
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