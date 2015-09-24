﻿
GO
IF EXISTS 
(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pttypmst]') AND type IN (N'U'))
OR EXISTS
(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblSMPaymentMethod]') AND type IN (N'U'))
BEGIN 

	EXEC('
		IF EXISTS (SELECT 1 FROM sys.objects WHERE name = ''uspNRGetPaymentType'' and type = ''P'') 
			DROP PROCEDURE [dbo].[uspNRGetPaymentType];
	')

	EXEC('
		CREATE PROCEDURE dbo.uspNRGetPaymentType
		AS
		BEGIN
			DECLARE @blnSwitchOrigini21 bit, @strOriginSystem nvarchar(5), @strVersionNumber nvarchar(6)
			
			SELECT @blnSwitchOrigini21 = ysnOriginCompatible FROM dbo.tblNRCompanyPreference 
			SELECT @strOriginSystem = strOriginSystem FROM dbo.tblNRCompanyPreference  
			SELECT @strVersionNumber = strVersionNumber FROM dbo.tblNRCompanyPreference						
			
			IF @blnSwitchOrigini21 = 1
			BEGIN		
				IF @strOriginSystem = ''PT''
				BEGIN
					Select pttyp_pay_type [strPaymentMethodId], RTRIM(pttyp_desc) [strPaymentMethodName] from dbo.pttypmst
				END
				ELSE
				BEGIN
					WITH nums AS
					   (SELECT 1 AS value, 1 AS display
						UNION ALL
						SELECT value + 1 AS value, display + 1 AS display
						FROM nums
						WHERE nums.value <= 8)
					SELECT CAST(value as nvarchar(50)) [strPaymentMethodId], CAST(display as nvarchar(50)) [strPaymentMethodName]
					FROM nums 

				END
			END
			ELSE
			BEGIN
				Select CAST(intPaymentMethodID as nvarchar(50)) [strPaymentMethodId], strPaymentMethod [strPaymentMethodName] from  dbo.tblSMPaymentMethod
			END
			
		END
		
	')
END


