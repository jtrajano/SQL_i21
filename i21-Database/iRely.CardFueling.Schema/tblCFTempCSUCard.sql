CREATE TABLE [dbo].[tblCFTempCSUCard] (
    [intCardId]                  INT            NOT NULL,
    [intNetworkId]               INT            NULL,
    [strCardNumber]              NVARCHAR (250) NULL,
    [strCardDescription]         NVARCHAR (250) NOT NULL,
    [intAccountId]               INT            NOT NULL,
    [intProductAuthId]           INT            NULL,
    [intEntryCode]               INT            NULL,
    [strCardXReference]          NVARCHAR (250) NULL,
    [strCardForOwnUse]           NVARCHAR (250) NULL,
    [intExpenseItemId]           INT            NULL,
    [intDefaultFixVehicleNumber] INT            NULL,
    [intDepartmentId]            INT            NULL,
    [dtmLastUsedDated]           DATETIME       NULL,
    [intCardTypeId]              INT            NULL,
    [dtmIssueDate]               DATETIME       NULL,
    [ysnActive]                  BIT            NULL,
    [ysnCardLocked]              BIT            NULL,
    [strCardPinNumber]           NVARCHAR (250) NULL,
    [dtmCardExpiratioYearMonth]  DATETIME       NULL,
    [strCardValidationCode]      NVARCHAR (MAX) NULL,
    [intNumberOfCardsIssued]     INT            NULL,
    [intCardLimitedCode]         INT            NULL,
    [intCardFuelCode]            INT            NULL,
    [strCardTierCode]            NVARCHAR (MAX) NULL,
    [strCardOdometerCode]        NVARCHAR (MAX) NULL,
    [strCardWCCode]              NVARCHAR (MAX) NULL,
    [strSplitNumber]             NVARCHAR (250) NULL,
    [intCardManCode]             INT            NULL,
    [intCardShipCat]             INT            NULL,
    [intCardProfileNumber]       INT            NULL,
    [intCardPositionSite]        INT            NULL,
    [intCardvehicleControl]      INT            NULL,
    [intCardCustomPin]           INT            NULL,
    [intCreatedUserId]           INT            NULL,
    [dtmCreated]                 DATETIME       NULL,
    [intLastModifiedUserId]      INT            NULL,
    [intConcurrencyId]           INT            CONSTRAINT [DF_tblCFTempCSUCard_intConcurrencyId] DEFAULT ((1)) NULL,
    [dtmLastModified]            DATETIME       NULL,
    [ysnCardForOwnUse]           BIT            NULL,
    [ysnIgnoreCardTransaction]   BIT            NULL,
    [strComment]                 NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_tblCFTempCSUCard] PRIMARY KEY CLUSTERED ([intCardId] ASC) WITH (FILLFACTOR = 70)
);


GO

CREATE TRIGGER [dbo].[TR_GUESTS_AUDIT_INSERT] ON [dbo].[tblCFTempCSUCard] FOR INSERT
AS

DECLARE @bit INT ,
       @field INT ,
       @maxfield INT ,
       @char INT ,
       @fieldname nvarchar(200) ,
       @TableName nvarchar(200) ,
       @PKCols VARCHAR(1000) ,
       @sql VARCHAR(2000), 
       @UpdateDate VARCHAR(21) ,
       @UserName nvarchar(100) ,
       @Type nvarchar(100) ,
       @PKSelect VARCHAR(1000)


--You will need to change @TableName to match the table to be audited. 
-- Here we made GUESTS for your example.
SELECT @TableName = 'tblCFCard'

-- date and user
SELECT         @UserName = SYSTEM_USER ,
       @UpdateDate = CONVERT (NVARCHAR(30),GETDATE(),126)

-- Action
IF EXISTS (SELECT * FROM inserted)
       IF EXISTS (SELECT * FROM deleted)
               SELECT @Type = 'Update'
       ELSE
               SELECT @Type = 'Added'
ELSE
       SELECT @Type = 'Delete'

-- get list of columns
SELECT * INTO #ins FROM inserted
SELECT * INTO #del FROM deleted

-- Get primary key columns for full outer join
SELECT @PKCols = COALESCE(@PKCols + ' and', ' on') 
               + ' i.' + c.COLUMN_NAME + ' = d.' + c.COLUMN_NAME
       FROM    INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk ,

              INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
       WHERE   pk.TABLE_NAME = @TableName
       AND     CONSTRAINT_TYPE = 'PRIMARY KEY'
       AND     c.TABLE_NAME = pk.TABLE_NAME
       AND     c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME

-- Get primary key select for insert
SELECT @PKSelect = 'convert(varchar(100),
coalesce(i.' + COLUMN_NAME +',d.' + COLUMN_NAME + '))'
       FROM    INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk ,
               INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
       WHERE   pk.TABLE_NAME = @TableName
       AND     CONSTRAINT_TYPE = 'PRIMARY KEY'
       AND     c.TABLE_NAME = pk.TABLE_NAME
       AND     c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME

IF @PKCols IS NULL
BEGIN
       RAISERROR('no PK on table %s', 16, -1, @TableName)
       RETURN
END

SELECT         @field = 0, 
       @maxfield = MAX(ORDINAL_POSITION) 
       FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = @TableName
WHILE @field < @maxfield
BEGIN
       SELECT @field = MIN(ORDINAL_POSITION) 
               FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME = @TableName 
               AND ORDINAL_POSITION > @field
       SELECT @bit = (@field - 1 )% 8 + 1
       SELECT @bit = POWER(2,@bit - 1)
       SELECT @char = ((@field - 1) / 8) + 1
       IF SUBSTRING(COLUMNS_UPDATED(),@char, 1) & @bit > 0
                                       OR @Type IN ('Insert','Delete')
       BEGIN
               SELECT @fieldname = COLUMN_NAME 
                       FROM INFORMATION_SCHEMA.COLUMNS 
                       WHERE TABLE_NAME = @TableName 
                       AND ORDINAL_POSITION = @field
               SELECT @sql = '
INSERT tblCFTempCSUAuditLog (    
			   strType, 
               strTableName, 
               intPK, 
               strFieldName, 
               strOldValue, 
               strNewValue, 
               dtmUpdateDate, 
               strUserName)
SELECT ''' + @Type + ''',''' 
       + @TableName + ''',' + @PKSelect
       + ',''' + @fieldname + ''''
       + ',convert(varchar(1000),d.' + @fieldname + ')'
       + ',convert(varchar(1000),i.' + @fieldname + ')'
       + ',''' + @UpdateDate + ''''
       + ',''' + @UserName + ''''
       + ' from #ins i full outer join #del d'
       + @PKCols
       + ' where i.' + @fieldname + ' <> d.' + @fieldname 
       + ' or (i.' + @fieldname + ' is null and  d.'
                                + @fieldname
                                + ' is not null)' 
       + ' or (i.' + @fieldname + ' is not null and  d.' 
                                + @fieldname
                                + ' is null)' 
               EXEC (@sql)
       END
END
GO

CREATE TRIGGER [dbo].[TR_GUESTS_AUDIT_UPDATE] ON [dbo].[tblCFTempCSUCard] FOR UPDATE
AS

DECLARE @bit INT ,
       @field INT ,
       @maxfield INT ,
       @char INT ,
       @fieldname nvarchar(200) ,
       @TableName nvarchar(200) ,
       @PKCols VARCHAR(1000) ,
       @sql VARCHAR(2000), 
       @UpdateDate VARCHAR(21) ,
       @UserName nvarchar(100) ,
       @Type nvarchar(100) ,
       @PKSelect VARCHAR(1000)


--You will need to change @TableName to match the table to be audited. 
-- Here we made GUESTS for your example.


SELECT @TableName = 'tblCFCard'

-- date and user
SELECT         @UserName = SYSTEM_USER ,
       @UpdateDate = CONVERT (NVARCHAR(30),GETDATE(),126)

-- Action
IF EXISTS (SELECT * FROM inserted)
       IF EXISTS (SELECT * FROM deleted)
               SELECT @Type = 'Update'
       ELSE
               SELECT @Type = 'Insert'
ELSE
       SELECT @Type = 'Delete'

-- get list of columns
SELECT * INTO #ins FROM inserted
SELECT * INTO #del FROM deleted

-- Get primary key columns for full outer join
SELECT @PKCols = COALESCE(@PKCols + ' and', ' on') 
               + ' i.' + c.COLUMN_NAME + ' = d.' + c.COLUMN_NAME
       FROM    INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk ,

              INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
       WHERE   pk.TABLE_NAME = @TableName
       AND     CONSTRAINT_TYPE = 'PRIMARY KEY'
       AND     c.TABLE_NAME = pk.TABLE_NAME
       AND     c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME


-- Get primary key select for insert
SELECT @PKSelect = 'convert(varchar(100),
coalesce(i.' + COLUMN_NAME +',d.' + COLUMN_NAME + '))'
       FROM    INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk ,
               INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
       WHERE   pk.TABLE_NAME = @TableName
       AND     CONSTRAINT_TYPE = 'PRIMARY KEY'
       AND     c.TABLE_NAME = pk.TABLE_NAME
       AND     c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME

IF @PKCols IS NULL
BEGIN
       RAISERROR('no PK on table %s', 16, -1, @TableName)
       RETURN
END

SELECT         @field = 0, 
       @maxfield = MAX(ORDINAL_POSITION) 
       FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = @TableName
WHILE @field < @maxfield
BEGIN
       SELECT @field = MIN(ORDINAL_POSITION) 
               FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME = @TableName 
               AND ORDINAL_POSITION > @field
       SELECT @bit = (@field - 1 )% 8 + 1
       SELECT @bit = POWER(2,@bit - 1)
       SELECT @char = ((@field - 1) / 8) + 1
       IF SUBSTRING(COLUMNS_UPDATED(),@char, 1) & @bit > 0
                                       OR @Type IN ('Insert','Delete')
       BEGIN
               SELECT @fieldname = COLUMN_NAME 
                       FROM INFORMATION_SCHEMA.COLUMNS 
                       WHERE TABLE_NAME = @TableName 
                       AND ORDINAL_POSITION = @field
               SELECT @sql = '
INSERT tblCFTempCSUAuditLog (    
			   strType, 
               strTableName, 
               intPK, 
               strFieldName, 
               strOldValue, 
               strNewValue, 
               dtmUpdateDate, 
               strUserName)
SELECT ''' + @Type + ''',''' 
       + @TableName + ''',' + @PKSelect
       + ',''' + @fieldname + ''''
       + ',convert(varchar(1000),d.' + @fieldname + ')'
       + ',convert(varchar(1000),i.' + @fieldname + ')'
       + ',''' + @UpdateDate + ''''
       + ',''' + @UserName + ''''
       + ' from #ins i full outer join #del d'
       + @PKCols
       + ' where i.' + @fieldname + ' <> d.' + @fieldname 
       + ' or (i.' + @fieldname + ' is null and  d.'
                                + @fieldname
                                + ' is not null)' 
       + ' or (i.' + @fieldname + ' is not null and  d.' 
                                + @fieldname
                                + ' is null)' 
               EXEC (@sql)
       END
END