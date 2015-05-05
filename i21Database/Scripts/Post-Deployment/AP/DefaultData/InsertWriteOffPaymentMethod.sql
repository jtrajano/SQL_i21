GO
MERGE INTO tblSMPaymentMethod AS Target
USING 
(
VALUES (N'Write Off', 1)
)
AS Source (strPaymentMethod, ysnActive)
ON Target.strPaymentMethod = Source.strPaymentMethod 
-- insert new rows
WHEN NOT MATCHED BY TARGET THEN
INSERT (strPaymentMethod, ysnActive)
VALUES (strPaymentMethod, ysnActive);
GO