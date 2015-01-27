/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblICReasonCodeWorkCenter]
	(
		[intReasonCodeWorkCenterId] INT NOT NULL IDENTITY, 
		[intReasonCodeId] INT NOT NULL, 
		[strWorkCenterId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
		[intSort] INT NULL DEFAULT ((0)), 
		[intConcurrencyId] INT NULL DEFAULT ((0)), 
		CONSTRAINT [PK_tblICReasonCodeWorkCenter] PRIMARY KEY ([intReasonCodeWorkCenterId]), 
		CONSTRAINT [FK_tblICReasonCodeWorkCenter_tblICReasonCode] FOREIGN KEY ([intReasonCodeId]) REFERENCES [tblICReasonCode]([intReasonCodeId]) ON DELETE CASCADE 
	)

	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Identity Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICReasonCodeWorkCenter',
		@level2type = N'COLUMN',
		@level2name = N'intReasonCodeWorkCenterId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Reason Code Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICReasonCodeWorkCenter',
		@level2type = N'COLUMN',
		@level2name = N'intReasonCodeId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Work Center Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICReasonCodeWorkCenter',
		@level2type = N'COLUMN',
		@level2name = N'strWorkCenterId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Sort Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICReasonCodeWorkCenter',
		@level2type = N'COLUMN',
		@level2name = N'intSort'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Concurrency Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICReasonCodeWorkCenter',
		@level2type = N'COLUMN',
		@level2name = N'intConcurrencyId'