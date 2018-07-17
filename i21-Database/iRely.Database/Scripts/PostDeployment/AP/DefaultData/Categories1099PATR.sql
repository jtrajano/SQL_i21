GO
MERGE INTO tblAP1099PATRCategory AS Target
USING (VALUES
  (1, N'Patronage Dividends'),
  (2, N'Nonpatronage Distributions'),
  (3, N'Per-unit retain allocations'),
  (4, N'Federal income tax withheld'),
  (5, N'Redemption of nonqualified notices and retain allocations'),
  (6, N'Domestic production activities deduction'),
  (7, N'Investment credit'),
  (8, N'Work opportunity credit'),
  (9, N'Patron''s AMT adjustment'),
  (10, N'Other credits and deductions')
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