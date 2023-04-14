CREATE TABLE [dbo].[tblEMEntityType] (
    [intEntityTypeId]  INT            IDENTITY (1, 1) NOT NULL,
    [intEntityId]      INT            NOT NULL,
    [strType]          NVARCHAR (100) COLLATE Latin1_General_CI_AS NOT NULL,
    [intConcurrencyId] INT            NOT NULL,
    CONSTRAINT [PK_dbo.tblEMEntityType] PRIMARY KEY CLUSTERED ([intEntityTypeId] ASC),
    CONSTRAINT [FK_dbo.tblEMEntityType_dbo.tblEMEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].tblEMEntity ([intEntityId]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_intEntityId]
    ON [dbo].[tblEMEntityType]([intEntityId] ASC)
	INCLUDE(intEntityTypeId, strType); 

GO
CREATE NONCLUSTERED INDEX [IX_tblEMEntityType_intEntityId_strType]
    ON [dbo].[tblEMEntityType]([intEntityId] ASC, [strType] ASC);

GO
CREATE TRIGGER trg_tblEMEntityType
ON dbo.tblEMEntityType
AFTER DELETE 
AS
BEGIN
	DECLARE @strType NVARCHAR(100);
	DECLARE @intEntityId INT;
	DECLARE @relatedEntityTypeCount INT;
	DECLARE @error NVARCHAR(500);

	SELECT	@intEntityId = intEntityId,
			@strType = strType
	FROM	DELETED;

	IF(	@strType = 'Broker' OR @strType = 'Forwarding Agent' OR 
		@strType = 'Futures Broker' OR @strType = 'Insurer' OR 
		@strType = 'Shipping Line' OR @strType = 'Terminal' OR @strType = 'Vendor')
	BEGIN
		SELECT	@relatedEntityTypeCount = COUNT(*) 
		FROM	tblEMEntityType 
		WHERE	intEntityId = @intEntityId AND 
				strType IN ('Broker','Forwarding Agent', 'Futures Broker', 'Insurer', 'Shipping Line', 'Terminal', 'Vendor')
	
		IF(@relatedEntityTypeCount = 0)
		BEGIN
			DELETE	a
			FROM	tblAPVendor AS a
			WHERE	intEntityId = @intEntityId;
		END
	END	
	ELSE IF(@strType = 'Customer' OR @strType = 'Prospect')
	BEGIN
		SELECT	@relatedEntityTypeCount = COUNT(*) 
		FROM	tblEMEntityType 
		WHERE	intEntityId = @intEntityId AND 
				strType IN ('Customer','Prospect')
	
		IF(@relatedEntityTypeCount = 0)
		BEGIN
			DELETE	a
			FROM	tblARCustomer AS a
			WHERE	intEntityId = @intEntityId;
		END
	END
	ELSE IF(@strType = 'Lead')
	BEGIN
		DELETE	a
		FROM	tblARLead AS a
		WHERE	intEntityId = @intEntityId;
	END
	ELSE IF(@strType = 'Salesperson')
	BEGIN
		DELETE	a
		FROM	tblARSalesperson AS a
		WHERE	intEntityId = @intEntityId;
	END
	ELSE IF(@strType = 'Ship Via')
	BEGIN
		DELETE	a
		FROM	tblSMShipVia AS a
		WHERE	intEntityId = @intEntityId;
	END
	ELSE IF(@strType = 'Employee')
	BEGIN
		DELETE	a
		FROM	tblPREmployee AS a
		WHERE	intEntityId = @intEntityId;
	END
	ELSE IF(@strType = 'User')
	BEGIN
		DELETE	a
		FROM	tblSMUserSecurity AS a
		WHERE	intEntityId = @intEntityId;
	END
	ELSE IF(@strType = 'Veterinary')
	BEGIN
		DELETE	a
		FROM	tblVTVeterinary AS a
		WHERE	intEntityId = @intEntityId;
	END
END
GO