CREATE VIEW [dbo].[vyuAPPaymentMethodBlank]
AS
SELECT 0 intPaymentMethodID,
	   'Blank' strPaymentMethod,
	   'N/A' strDescription,
	   NULL strPaymentMethodCode,
	   CAST(1 AS BIT) ysnActive,
	   NULL strPrefix,
	   1 intNumber,
	   1 intConcurrencyId

UNION

SELECT intPaymentMethodID,
	   strPaymentMethod,
	   strDescription,
	   strPaymentMethodCode,
	   ysnActive,
	   strPrefix,
	   intNumber,
	   intConcurrencyId
FROM tblSMPaymentMethod