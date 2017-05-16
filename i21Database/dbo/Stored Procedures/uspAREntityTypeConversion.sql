	CREATE PROCEDURE [dbo].[uspAREntityTypeConversion]
		@EntityId INT,
		@FromType NVARCHAR(100),
		@ToType NVARCHAR(100)
	AS
	DECLARE @OutputMessage NVARCHAR(200)
	SET @OutputMessage = 'Conversion is not applicable to this type of entity.'

	SET @FromType = LOWER(@FromType)
	SET @ToType = LOWER(@ToType)

	IF @FromType = 'lead' AND @ToType = 'prospect'
	BEGIN
		IF EXISTS(SELECT TOP 1 1 FROM tblEMEntityType WHERE intEntityId = @EntityId AND strType = 'Lead')
		BEGIN
			DELETE FROM tblEMEntityType WHERE intEntityId = @EntityId AND LOWER(strType) = 'lead'

			IF NOT EXISTS(SELECT TOP 1 1 FROM tblARCustomer WHERE intEntityId = @EntityId)
			BEGIN

				INSERT INTO tblARCustomer(intEntityId, dblCreditLimit, dblARBalance)
				SELECT @EntityId,0,0

			END

			IF NOT EXISTS(SELECT TOP 1 1 FROM tblEMEntityType WHERE strType = 'Prospect' AND intEntityId = @EntityId)
			BEGIN
				INSERT INTO tblEMEntityType (intEntityId, strType, intConcurrencyId)
				SELECT @EntityId, 'Prospect', 0		
			END
		
			SET @OutputMessage = 'success'
		END
	END
	ELSE IF @FromType = 'prospect' AND @ToType = 'customer'
	BEGIN
		IF EXISTS(SELECT TOP 1 1 FROM tblEMEntityType WHERE intEntityId = @EntityId AND strType = 'Prospect' )
		BEGIN
			DELETE FROM tblEMEntityType WHERE intEntityId = @EntityId AND LOWER(strType) = 'prospect'



			IF NOT EXISTS(SELECT TOP 1 1 FROM tblARCustomer WHERE intEntityId = @EntityId)
			BEGIN

				INSERT INTO tblARCustomer(intEntityId, dblCreditLimit, dblARBalance)
				SELECT @EntityId,0,0

			END

			IF NOT EXISTS(SELECT TOP 1 1 FROM tblEMEntityType WHERE strType = 'Prospect' AND intEntityId = @EntityId)
			BEGIN
				INSERT INTO tblEMEntityType (intEntityId, strType, intConcurrencyId)
				SELECT @EntityId, 'Customer', 0		
			END

			SET @OutputMessage = 'success'
		END
	END

		SELECT @OutputMessage