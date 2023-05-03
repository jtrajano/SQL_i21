CREATE PROCEDURE [dbo].[uspAREntityTypeConversion]
		@EntityId INT,
		@FromType NVARCHAR(100),
		@ToType NVARCHAR(100)
	AS
	DECLARE @OutputMessage NVARCHAR(200)
	DECLARE @Location INT
	DECLARE @BillTo INT
	DECLARE @ShipTo INT
	DECLARE @activeStatus bit = 0
	DECLARE @creditHoldStatus bit = 0

	SET @OutputMessage = 'Conversion is not applicable to this type of entity.'
	SET @Location = (SELECT TOP 1 intEntityLocationId FROM tblEMEntityLocation WHERE intEntityId = @EntityId)

	SET @FromType = LOWER(@FromType)
	SET @ToType = LOWER(@ToType)

	IF @FromType = 'lead' AND @ToType = 'prospect'
	BEGIN
		IF EXISTS(SELECT TOP 1 1 FROM tblEMEntityType WHERE intEntityId = @EntityId AND strType = 'Lead')
		BEGIN

			SELECT @activeStatus = ysnActive FROM tblARLead WHERE intEntityId = @EntityId
			DELETE FROM tblEMEntityType WHERE intEntityId = @EntityId AND LOWER(strType) = 'lead'
			
			IF NOT EXISTS(SELECT TOP 1 1 FROM tblARCustomer WHERE intEntityId = @EntityId)
			BEGIN

				INSERT INTO tblARCustomer(intEntityId, dblCreditLimit, dblARBalance, intBillToId, intShipToId, ysnActive)
				SELECT @EntityId,0,0,@Location,@Location, @activeStatus

			END

			IF NOT EXISTS(SELECT TOP 1 1 FROM tblEMEntityType WHERE strType = 'Prospect' AND intEntityId = @EntityId)
			BEGIN
				INSERT INTO tblEMEntityType (intEntityId, strType, intConcurrencyId)
				SELECT @EntityId, 'Prospect', 0		
			END

			IF EXISTS (SELECT TOP 1 1 FROM tblEMEntityLocation WHERE intEntityId = @EntityId)
			BEGIN
				UPDATE tblEMEntityLocation SET intFreightTermId = (SELECT TOP 1 intFreightTermId FROM tblCRMSetting) WHERE intEntityId = @EntityId
			END
		
			SET @OutputMessage = 'success'
		END
	END
	ELSE IF @FromType = 'prospect' AND @ToType = 'customer'
	BEGIN
		IF EXISTS(SELECT TOP 1 1 FROM tblEMEntityType WHERE intEntityId = @EntityId AND strType = 'Prospect' )
		BEGIN
		
			SELECT @activeStatus = ysnActive, 
				   @creditHoldStatus = ysnCreditHold,
				   @BillTo = intBillToId,
				   @ShipTo = intShipToId
			FROM tblARCustomer WHERE intEntityId = @EntityId
			DELETE FROM tblEMEntityType WHERE intEntityId = @EntityId AND LOWER(strType) = 'prospect'	

			IF NOT EXISTS(SELECT TOP 1 1 FROM tblARCustomer WHERE intEntityId = @EntityId)
			BEGIN

				INSERT INTO tblARCustomer(intEntityId, dblCreditLimit, dblARBalance, ysnActive, ysnCreditHold, intBillToId, intShipToId)
				SELECT @EntityId,0,0,@activeStatus, @creditHoldStatus, @BillTo, @ShipTo

			END

			IF NOT EXISTS(SELECT TOP 1 1 FROM tblEMEntityType WHERE strType = 'Customer' AND intEntityId = @EntityId)
			BEGIN
				INSERT INTO tblEMEntityType (intEntityId, strType, intConcurrencyId)
				SELECT @EntityId, 'Customer', 0		
			END

			SET @OutputMessage = 'success'
		END
	END
	ELSE IF @FromType = 'prospect' AND @ToType = 'lead'
	BEGIN
		IF EXISTS(SELECT TOP 1 1 FROM tblEMEntityType WHERE intEntityId = @EntityId AND strType = 'Prospect' )
		BEGIN

			SELECT @activeStatus = ysnActive FROM tblARCustomer WHERE intEntityId = @EntityId

			DELETE FROM tblEMEntityType WHERE intEntityId = @EntityId AND LOWER(strType) = 'prospect'
			DELETE FROM tblEMEntityType WHERE intEntityId = @EntityId AND LOWER(strType) = 'customer'

			IF NOT EXISTS(SELECT TOP 1 1 FROM tblARLead WHERE intEntityId = @EntityId)
			BEGIN

				INSERT INTO tblARLead(intEntityId, ysnActive)
				SELECT @EntityId, @activeStatus

			END

			IF NOT EXISTS(SELECT TOP 1 1 FROM tblEMEntityType WHERE strType = 'Lead' AND intEntityId = @EntityId)
			BEGIN
				INSERT INTO tblEMEntityType (intEntityId, strType, intConcurrencyId)
				SELECT @EntityId, 'Lead', 0		
			END

			SET @OutputMessage = 'success'
		END
	END
		SELECT @OutputMessage
GO