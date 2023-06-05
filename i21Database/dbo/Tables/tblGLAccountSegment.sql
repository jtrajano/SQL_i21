CREATE TABLE [dbo].[tblGLAccountSegment] (
    [intAccountSegmentId]   INT            IDENTITY (1, 1) NOT NULL,
    [strCode]               NVARCHAR (20)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strDescription]        NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,
	[strChartDesc]          NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,
    [intAccountStructureId] INT            NOT NULL,
    [intAccountGroupId]     INT            NULL,
    [ysnActive]             BIT            CONSTRAINT [DF_tblGLAccountSegment_ysnActive] DEFAULT ((1)) NULL,
    [ysnSelected]           BIT            CONSTRAINT [DF_tblGLAccountSegment_ysnSelected] DEFAULT ((0)) NOT NULL,
    [ysnIsNotExisting]      BIT            CONSTRAINT [DF_tblGLAccountSegment_ysnIsNotExisting] DEFAULT ((0)) NULL,
    [intConcurrencyId]      INT            DEFAULT 1 NOT NULL,
    [intAccountCategoryId] INT NULL, 
    [intEntityIdLastModified] INT NULL, 
    CONSTRAINT [PK_GLAccountSegment_AccountSegmentId] PRIMARY KEY CLUSTERED ([intAccountSegmentId] ASC),
    CONSTRAINT [FK_tblGLAccountSegment_tblGLAccountGroup] FOREIGN KEY ([intAccountGroupId]) REFERENCES [dbo].[tblGLAccountGroup] ([intAccountGroupId]),
    CONSTRAINT [FK_tblGLAccountSegment_tblGLAccountStructure] FOREIGN KEY ([intAccountStructureId]) REFERENCES [dbo].[tblGLAccountStructure] ([intAccountStructureId])
);
GO

CREATE NONCLUSTERED INDEX [IX_tblGLAccountSegment_strCode]
    ON [dbo].[tblGLAccountSegment]([strCode] ASC);
GO

CREATE NONCLUSTERED INDEX [IX_tblGLAccountSegment_intAccountStructureId]
    ON [dbo].[tblGLAccountSegment]([intAccountStructureId] ASC);
GO

CREATE NONCLUSTERED INDEX [IX_tblGLAccountSegment_intAccountGroupId]
    ON [dbo].[tblGLAccountSegment]([intAccountGroupId] ASC);
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Table Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountSegment', @level2type=N'COLUMN',@level2name=N'intAccountSegmentId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountSegment', @level2type=N'COLUMN',@level2name=N'strCode' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountSegment', @level2type=N'COLUMN',@level2name=N'strDescription' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account Structure Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountSegment', @level2type=N'COLUMN',@level2name=N'intAccountStructureId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account Group Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountSegment', @level2type=N'COLUMN',@level2name=N'intAccountGroupId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Active' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountSegment', @level2type=N'COLUMN',@level2name=N'ysnActive' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Selected' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountSegment', @level2type=N'COLUMN',@level2name=N'ysnSelected' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Is Not Existing' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountSegment', @level2type=N'COLUMN',@level2name=N'ysnIsNotExisting' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Concurrency Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountSegment', @level2type=N'COLUMN',@level2name=N'intConcurrencyId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account Category Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountSegment', @level2type=N'COLUMN',@level2name=N'intAccountCategoryId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Entity Id Last Modified' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountSegment', @level2type=N'COLUMN',@level2name=N'intEntityIdLastModified' 
GO


CREATE TRIGGER trigger_tblGLAccountSegment
	ON dbo.tblGLAccountSegment
	AFTER INSERT, UPDATE, DELETE
AS
BEGIN


DECLARE  @tblGLAccountSegmentLog table  (
 Id INT IDENTITY(1,1),
 Code NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL,
 AccountSegmentId int,
 ChartDesc_New nvarchar(50) COLLATE Latin1_General_CI_AS  NULL,
 ChardDesc_Old nvarchar(50) COLLATE Latin1_General_CI_AS  NULL,
 Description_New nvarchar(50) COLLATE Latin1_General_CI_AS  NULL,
 Description_Old nvarchar(50) COLLATE Latin1_General_CI_AS  NULL,
 AccountGroup_New INT,
 AccountGroup_Old INT,
 AccountCategory_New INT,
 AccountCategory_Old INT,
 EntityId INT
)

DECLARE @Id INT,
 @AccountSegmentId int,
 @AccountSegmentString nvarchar(50),
 @ChartDesc_New nvarchar(50),
 @ChartDesc_Old nvarchar(50) ,
 @Description_New nvarchar(50),
 @Description_Old nvarchar(50),
 @Code NVARCHAR(50),
 @EntityId INT,
 @changeDescription NVARCHAR(100),
 @AccountGroup_Old NVARCHAR(50),
 @AccountGroup_New NVARCHAR(50),
 @AccountCategory_Old NVARCHAR(100),
 @AccountCategory_New NVARCHAR(100),
 @StructureName NVARCHAR(20)

 
SELECT TOP 1 @EntityId= intEntityId from tblSMUserLogin where strResult= 'Successful' order by dtmDate desc
 
INSERT INTO  @tblGLAccountSegmentLog
SELECT 
ISNULL(Inserted.strCode, Deleted.strCode) Code,
ISNULL(Inserted.intAccountSegmentId, Deleted.intAccountSegmentId) AccountSegmentId,
Inserted.strChartDesc AS ChartDesc_New,
Deleted.strChartDesc AS ChardDesc_Old,
Inserted.strDescription AS Description_New,
Deleted.strDescription AS Description_Old,
Inserted.intAccountGroupId AS AccountGroup_New,
Deleted.intAccountGroupId AS AccountGroup_Old,
Inserted.intAccountCategoryId AS AccountCategory_New,
Deleted.intAccountCategoryId AS AccountCategory_Old,
Inserted.intEntityIdLastModified EntityId
FROM
Inserted Left JOIN Deleted 
ON Inserted.intAccountSegmentId = Deleted.intAccountSegmentId
where Deleted.intAccountSegmentId is null


IF EXISTS (SELECT 1 FROM @tblGLAccountSegmentLog)
BEGIN
	SELECT
	  TOP 1 @Id = Id,
            @Code  = Code,
            @AccountSegmentString = cast(AccountSegmentId as nvarchar(50)),
            @AccountSegmentId = AccountSegmentId,
			@StructureName = A.strStructureName,
            @EntityId = EntityId
            FROM vyuGLSegmentDetail A join @tblGLAccountSegmentLog B ON A.intAccountSegmentId = B.AccountSegmentId

	 SET @changeDescription = 'Created ' + @StructureName + ' Segment ' + @Code
	 EXEC uspSMAuditLog
		@keyValue = @AccountSegmentString,                                          -- Primary Key Value
		@screenName = 'GeneralLedger.view.SegmentAccounts',            -- Screen Namespace
		@entityId = @EntityId,                                              -- Entity Id.
		@actionType = 'Created',                                  -- Action Type (Processed, Posted, Unposted and etc.)
        
		--- Below is just optional if you need a tree level information
		@changeDescription = @changeDescription , -- Description
		@fromValue = N'',                                        -- Previous Value
		@toValue = @Code       

END

DELETE FROM @tblGLAccountSegmentLog
INSERT INTO  @tblGLAccountSegmentLog
SELECT 
ISNULL(Inserted.strCode, Deleted.strCode) Code,
ISNULL(Inserted.intAccountSegmentId, Deleted.intAccountSegmentId) AccountSegmentId,
Inserted.strChartDesc AS ChartDesc_New,
Deleted.strChartDesc AS ChardDesc_Old,
Inserted.strDescription AS Description_New,
Deleted.strDescription AS Description_Old,
Inserted.intAccountGroupId AS AccountGroup_New,
Deleted.intAccountGroupId AS AccountGroup_Old,
Inserted.intAccountCategoryId AS AccountCategory_New,
Deleted.intAccountCategoryId AS AccountCategory_Old,
Inserted.intEntityIdLastModified EntityId

FROM
Inserted  JOIN
Deleted 
ON Inserted.intAccountSegmentId = Deleted.intAccountSegmentId
if EXISTS (SELECT 1  FROM @tblGLAccountSegmentLog)
BEGIN

SELECT 
            TOP 1 @Id = Id,
            @Code  = Code,
            @AccountSegmentString = cast(AccountSegmentId as nvarchar(50)),
            @AccountSegmentId = AccountSegmentId,
            @ChartDesc_New = ChartDesc_New, 
            @ChartDesc_Old=ChardDesc_Old,
            @Description_New = Description_New, 
            @Description_Old=Description_Old,
			@AccountGroup_New = GRP_New.strAccountGroup,
			@AccountGroup_Old = GRP_Old.strAccountGroup,
			@AccountCategory_New = CAT_New.strAccountCategory,
			@AccountCategory_Old = CAT_Old.strAccountCategory,
			@StructureName = A.strStructureName
            
            FROM vyuGLSegmentDetail A join @tblGLAccountSegmentLog B ON A.intAccountSegmentId = B.AccountSegmentId
			outer apply(
				select top 1 strAccountGroup from tblGLAccountGroup WHERE intAccountGroupId = AccountGroup_New
			)GRP_New
			outer apply(
				select top 1 strAccountGroup from tblGLAccountGroup WHERE intAccountGroupId = AccountGroup_Old
			)GRP_Old
			outer apply(
				select top 1 strAccountCategory from tblGLAccountCategory WHERE intAccountCategoryId = AccountCategory_New
			)CAT_New
			outer apply(
				select top 1 strAccountCategory from tblGLAccountCategory WHERE intAccountCategoryId = AccountCategory_Old
			)CAT_Old
           -- WHERE --ChartDesc_New != ChardDesc_Old AND 
            --ActionType = 'UPDATE'


			set @changeDescription = 'UPDATE ' +  @StructureName +' Segment ' + @Code 
			IF @ChartDesc_New <>  @ChartDesc_Old
			BEGIN
				 SET @changeDescription = @changeDescription + ' Chart Description'
				EXEC uspSMAuditLog
					@keyValue = @AccountSegmentString,                                          -- Primary Key Value
					@screenName = 'GeneralLedger.view.SegmentAccounts',            -- Screen Namespace
					@entityId =@EntityId,                                              -- Entity Id.
					@actionType = 'Updated',                                  -- Action Type (Processed, Posted, Unposted and etc.)
        
					--- Below is just optional if you need a tree level information
					@changeDescription = @changeDescription , -- Description
					@fromValue = @ChartDesc_Old,                                        -- Previous Value
					@toValue = @ChartDesc_New                                     -- New Value
			END
			IF @Description_New <> @Description_Old
			BEGIN
					SET @changeDescription = @changeDescription + ' Description'
					 EXEC uspSMAuditLog
					@keyValue = @AccountSegmentString,                                          -- Primary Key Value
					@screenName = 'GeneralLedger.view.SegmentAccounts',            -- Screen Namespace
					@entityId = @EntityId,                                              -- Entity Id.
					@actionType = 'Updated',                                  -- Action Type (Processed, Posted, Unposted and etc.)
        
					--- Below is just optional if you need a tree level information
					@changeDescription = @changeDescription , -- Description
					@fromValue = @Description_Old,                                        -- Previous Value
					@toValue = @Description_New                                     -- New Value
			END
			IF @AccountGroup_New <> @AccountGroup_Old
			BEGIN
					SET @changeDescription = @changeDescription + ' Account Group'
					  EXEC uspSMAuditLog
					@keyValue = @AccountSegmentString,                                          -- Primary Key Value
					@screenName = 'GeneralLedger.view.SegmentAccounts',            -- Screen Namespace
					@entityId = @EntityId,                                              -- Entity Id.
					@actionType = 'Updated',                                  -- Action Type (Processed, Posted, Unposted and etc.)
        
					--- Below is just optional if you need a tree level information
					@changeDescription = @changeDescription , -- Description
					@fromValue = @AccountGroup_Old,                                        -- Previous Value
					@toValue = @AccountGroup_New         


			END
			IF @AccountCategory_New <> @AccountCategory_Old
			BEGIN

			
					SET @changeDescription = @changeDescription + ' Account Category'
					  EXEC uspSMAuditLog
					@keyValue = @AccountSegmentString,                                          -- Primary Key Value
					@screenName = 'GeneralLedger.view.SegmentAccounts',            -- Screen Namespace
					@entityId = @EntityId,                                              -- Entity Id.
					@actionType = 'Updated',                                  -- Action Type (Processed, Posted, Unposted and etc.)
					@changeDescription = @changeDescription , -- Description
					@fromValue = @AccountCategory_Old,                                        -- Previous Value
					@toValue = @AccountCategory_New         


			END
			
	
END

DELETE FROM  @tblGLAccountSegmentLog

INSERT INTO  @tblGLAccountSegmentLog(Code,AccountSegmentId)
SELECT 
A.strCode Code,
A.intAccountSegmentId AccountSegmentId
FROM
Deleted A left join inserted B on A.intAccountSegmentId = B.intAccountSegmentId
where B.intAccountSegmentId is null

SELECT 
   TOP 1 @Id = Id,
    @Code  = Code,
    @AccountSegmentString = cast(AccountSegmentId as nvarchar(50))
    FROM  @tblGLAccountSegmentLog



IF EXISTS(SELECT 1 FROM  @tblGLAccountSegmentLog)
		BEGIN
				set @changeDescription = 'DELETE Segment ' + @Code 
					EXEC uspSMAuditLog
					@keyValue = @AccountSegmentString,                                          -- Primary Key Value
					@screenName = 'GeneralLedger.view.SegmentAccounts',            -- Screen Namespace
					@entityId = @EntityId,                                              -- Entity Id.
					@actionType = 'Deleted',                                  -- Action Type (Processed, Posted, Unposted and etc.)
					@changeDescription = @changeDescription , -- Description
					@fromValue = @Code,                                        -- Previous Value
					@toValue = N''

		END
END


