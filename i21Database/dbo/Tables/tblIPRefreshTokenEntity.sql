CREATE TABLE [dbo].[tblIPRefreshTokenEntity] (
	intRefreshTokenEntityId INT IDENTITY(1, 1)
	,intConcurrencyId INT NULL CONSTRAINT DF_tblIPRefreshTokenEntity_intConcurrencyId DEFAULT 0
	,Token NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,ExpiryDate DATETIME
	,IsUsed BIT DEFAULT 0
	,Active BIT DEFAULT 1
	,CONSTRAINT [PK_tblIPRefreshTokenEntity_intRefreshTokenEntityId] PRIMARY KEY (intRefreshTokenEntityId)
	)
