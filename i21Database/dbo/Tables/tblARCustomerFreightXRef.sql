CREATE TABLE [dbo].[tblARCustomerFreightXRef] (
    [intFreightXRefId]		INT             IDENTITY (1, 1) NOT NULL,
    [intEntityCustomerId]   INT             NOT NULL,
    [intSupplyPointId]		INT				NULL,
    [intCategoryId]			INT				NULL,
    [ysnFreightOnly]		BIT             NOT NULL DEFAULT ((0)),
    [strFreightType]		NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [dblFreightAmount]		NUMERIC (18, 6) NULL,
    [dblFreightRate]		NUMERIC (18, 6) NULL,
    [dblMinimumUnits]		NUMERIC (18, 6) NULL,
    [ysnFreightInPrice]		BIT             NOT NULL DEFAULT ((0)),
    [dblFreightMiles]		NUMERIC (18, 6) NULL,
    [intShipViaId]			INT				NULL,
	[intEntityLocationId]	INT				NOT NULL,
	[strZipCode]			NVARCHAR (12)   COLLATE Latin1_General_CI_AS NULL,
	[intCompanyId]			INT             NULL,
    [intConcurrencyId]		INT             NOT NULL,
	[guiApiUniqueId] UNIQUEIDENTIFIER NULL,
    [intEntityTariffTypeId] INT NULL,
    CONSTRAINT [PK_tblARCustomerFreightXRef] PRIMARY KEY CLUSTERED ([intFreightXRefId] ASC),
	CONSTRAINT [FK_tblARCustomerFreightXRef_tblICCategory] FOREIGN KEY ([intCategoryId]) REFERENCES [tblICCategory]([intCategoryId]),
	CONSTRAINT [FK_tblARCustomerFreightXRef_tblSMShipVia] FOREIGN KEY ([intShipViaId]) REFERENCES [tblSMShipVia]([intEntityId]),	
	CONSTRAINT [FK_tblARCustomerFreightXRef_tblARCustomer] FOREIGN KEY ([intEntityCustomerId]) REFERENCES [dbo].[tblARCustomer] ([intEntityId]),
	CONSTRAINT [FK_tblARCustomerFreightXRef_tblEMEntityLocation] FOREIGN KEY ([intEntityLocationId]) REFERENCES [dbo].[tblEMEntityLocation] ([intEntityLocationId]),
	CONSTRAINT [UK_tblARCustomerFreightXRef_reference_columns] UNIQUE NONCLUSTERED ([intEntityTariffTypeId] ASC, [strZipCode] ASC, [intCategoryId] ASC,[intEntityLocationId] ASC, [intShipViaId] ASC),	--THE NAME IS USED IN THE FRONT END, IF THERE ARE CHANGES PLEASE INFORM MON.GONZALES	
    CONSTRAINT [FK_tblARCustomerFreightXRef_tblEMEntityTariffType_intEntityTariffTypeId] FOREIGN KEY ([intEntityTariffTypeId]) REFERENCES [dbo].[tblEMEntityTariffType] ([intEntityTariffTypeId])
);

GO

CREATE TRIGGER [dbo].[trgARCustomerFreight]
	ON [dbo].[tblARCustomerFreightXRef]
FOR INSERT,UPDATE
AS
BEGIN
	DECLARE @ErrMsg nvarchar(max) = NULL
	DECLARE @ysnFreightInRequired BIT = NULL
	DECLARE @dblFreightRateIn DECIMAL(18,6) = NULL
	DECLARE @strFreightType NVARCHAR(100) = NULL

	SELECT TOP 1 @ysnFreightInRequired = ysnFreightInRequired FROM tblTRCompanyPreference 

	SELECT @dblFreightRateIn = dblFreightRateIn, @strFreightType = strFreightType 
		FROM 
		inserted

	IF(@ysnFreightInRequired = 1 AND @dblFreightRateIn <= 0 AND  @strFreightType = 'Rate')
	BEGIN
		RAISERROR ('Customer > Transports > Freight > Freight-In must be greater than 0.',18,1,'WITH NOWAIT') 
	END
END
GO