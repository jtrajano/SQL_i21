CREATE PROCEDURE [dbo].[uspSTCheckoutValidatePaymentMethod]
	@intStoreId			INT,
	@ysnSuccess			BIT OUTPUT
AS
BEGIN
	BEGIN TRY
		SET @ysnSuccess = 1
		DECLARE		@intPaymentMethod INT = 0
		DECLARE		@intCustomerPaymentMethod INT = 0
		DECLARE		@strCustomerName NVARCHAR(150) = ''
		DECLARE		@intEntityCustomerId INT
		DECLARE		@ysnConsignmentStore BIT

		SELECT		@intEntityCustomerId = intCheckoutCustomerId, 
					@ysnConsignmentStore = ysnConsignmentStore
		FROM		tblSTStore 
		WHERE		intStoreId = @intStoreId

		IF @ysnConsignmentStore = 1
		BEGIN
			SELECT		@intPaymentMethod = intPaymentMethodID 
			FROM		tblSMPaymentMethod 
			WHERE		strPaymentMethod = 'ACH'

			SELECT		@intCustomerPaymentMethod = a.intPaymentMethodId,
						@strCustomerName = b.strName
			FROM		tblARCustomer a
			INNER JOIN	tblEMEntity b
			ON			a.intEntityId = b.intEntityId
			WHERE		a.intEntityId = @intEntityCustomerId

			IF @intPaymentMethod != @intCustomerPaymentMethod OR @intCustomerPaymentMethod IS NULL
			BEGIN
				INSERT INTO tblSTCheckoutProcessErrorWarning (intCheckoutProcessId, strMessageType, strMessage, intConcurrencyId)
				VALUES (dbo.fnSTGetLatestProcessId(@intStoreId), 'S', 'Missing or Incorrect Payment Method for the customer ' + @strCustomerName + '.', 1)

				SET @ysnSuccess = 0
			END

			IF NOT EXISTS(SELECT '' FROM tblEMEntityEFTInformation WHERE intEntityId = @intEntityCustomerId AND intBankId IS NOT NULL)
			BEGIN
				INSERT INTO tblSTCheckoutProcessErrorWarning (intCheckoutProcessId, strMessageType, strMessage, intConcurrencyId)
				VALUES (dbo.fnSTGetLatestProcessId(@intStoreId), 'S', 'Missing EFT/ACH setup for the customer ' + @strCustomerName + '.', 1)

				SET @ysnSuccess = 0
			END
		END
	END TRY
	BEGIN CATCH
		SET @ysnSuccess = 0
	END CATCH
END